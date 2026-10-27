<#
.SYNOPSIS
    LG-AI-process 环境自检（只读，不改文件/注册表）。

.DESCRIPTION
    检查本仓库构建/仿真所依赖的环境，逐项输出 PASS / WARN / FAIL / INFO。
    只做静态检查：不编译、不烧录、不显示授权码。

    兼容 Windows PowerShell 5.1 与 PowerShell 7+。

.PARAMETER RepoRoot
    仓库根目录。默认取脚本所在 tools/ 的上一级。

.PARAMETER KeilRoot
    Keil 安装根（含 UV4 目录）或 UV4.exe 路径。默认自动探测：
    参数 -> KEIL_ROOT 环境变量 -> 注册表 -> PATH -> 常见安装路径。

.PARAMETER MatlabRoot
    MATLAB 安装根（含 bin\matlab.exe）。默认读注册表 / PATH。

.PARAMETER CubeMxPath
    STM32CubeMX.exe 路径（可选）。默认在常见位置与 Keil 同级工具目录探测。

.PARAMETER Strict
    WARN 也返回退出码 1（适合交接/CI 门禁）。

.PARAMETER NoColor
    关闭彩色输出（重定向日志时用）。

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File tools\check-env.ps1

.EXAMPLE
    pwsh -File tools/check-env.ps1 -KeilRoot "C:\Keil_v5" -Strict

.NOTES
    退出码：0 = 无 FAIL；1 = 有 FAIL（-Strict 时含 WARN）；2 = 参数/仓库路径错误。
    文档：docs/02-architecture/environment.md
#>
[CmdletBinding()]
param(
    [string]$RepoRoot,
    [string]$KeilRoot,
    [string]$MatlabRoot,
    [string]$CubeMxPath,
    [switch]$Strict,
    [switch]$NoColor
)

# Windows PowerShell 5.1 下 param 默认值里 $PSScriptRoot 可能为空，这里兜底
if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    $RepoRoot = Split-Path -Parent $scriptDir
}

$ErrorActionPreference = 'Continue'
$script:PassCount = 0
$script:WarnCount = 0
$script:FailCount = 0
$script:Results = New-Object System.Collections.Generic.List[object]

function Write-Section {
    param([string]$Title)
    Write-Host ''
    if ($NoColor) { Write-Host ("== " + $Title + " ==") }
    else { Write-Host ("== " + $Title + " ==") -ForegroundColor Cyan }
}

function Add-Result {
    param(
        [ValidateSet('PASS', 'WARN', 'FAIL', 'INFO')][string]$Status,
        [string]$Area,
        [string]$Message,
        [string]$Detail = ''
    )
    $script:Results.Add([PSCustomObject]@{
        Status  = $Status
        Area    = $Area
        Message = $Message
        Detail  = $Detail
    })
    switch ($Status) {
        'PASS' { $script:PassCount++ }
        'WARN' { $script:WarnCount++ }
        'FAIL' { $script:FailCount++ }
    }

    $line = ("  {0}  [{1}] {2}" -f $Status.PadRight(4), $Area, $Message)
    if ($NoColor) {
        Write-Host $line
        if ($Detail) { Write-Host ("          " + $Detail) }
    }
    else {
        $color = switch ($Status) {
            'PASS' { 'Green' }
            'WARN' { 'Yellow' }
            'FAIL' { 'Red' }
            default { 'Gray' }
        }
        Write-Host $line -ForegroundColor $color
        if ($Detail) { Write-Host ("          " + $Detail) -ForegroundColor DarkGray }
    }
}

function Test-Existing {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return (Test-Path -LiteralPath $Path)
}

function Get-MaxVersionDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $items = @()
    foreach ($d in @(Get-ChildItem -LiteralPath $Path -Directory -ErrorAction SilentlyContinue)) {
        $v = $null
        if ([version]::TryParse($d.Name, [ref]$v)) {
            $items += [PSCustomObject]@{ Version = $v; FullName = $d.FullName }
        }
    }
    if ($items.Count -eq 0) { return $null }
    return ($items | Sort-Object -Property Version -Descending | Select-Object -First 1)
}

function Resolve-KeilCore {
    param([string]$Candidate)
    if ([string]::IsNullOrWhiteSpace($Candidate)) { return $null }
    $t = $Candidate.Trim().TrimEnd('\')
    if ($t -match '\.exe$') {
        # ...\UV4\UV4.exe -> ...\Core
        $t = Split-Path -Parent (Split-Path -Parent $t)
    }
    for ($i = 0; $i -lt 7 -and $t; $i++) {
        foreach ($sub in @('', 'MDK\Core', 'Core', 'MDK')) {
            $probe = if ($sub) { Join-Path $t $sub } else { $t }
            if (Test-Path -LiteralPath (Join-Path $probe 'UV4\UV4.exe')) { return $probe }
        }
        $t = Split-Path -Parent $t
    }
    return $null
}

function Find-KeilCore {
    param([string]$Hint)
    $candidates = New-Object System.Collections.Generic.List[string]
    foreach ($c in @($Hint, $env:KEIL_ROOT)) {
        if (-not [string]::IsNullOrWhiteSpace($c)) { $candidates.Add($c) }
    }
    foreach ($key in @(
            'HKLM:\SOFTWARE\WOW6432Node\Keil\Products\MDK',
            'HKLM:\SOFTWARE\Keil\Products\MDK',
            'HKCU:\SOFTWARE\Keil\Products\MDK')) {
        try {
            $item = Get-ItemProperty -Path $key -ErrorAction Stop
            if ($item.Path) { $candidates.Add([string]$item.Path) }
        }
        catch { }
    }
    $cmd = Get-Command 'UV4.exe' -ErrorAction SilentlyContinue
    if ($cmd) { $candidates.Add($cmd.Source) }
    foreach ($p in @(
            'C:\Keil_v5',
            'C:\Keil',
            'C:\Program Files\Keil_v5',
            'C:\Program Files (x86)\Keil_v5')) {
        $candidates.Add($p)
    }
    foreach ($c in $candidates) {
        $core = Resolve-KeilCore -Candidate $c
        if ($core) { return $core }
    }
    return $null
}

function Find-Matlab {
    param([string]$Hint)
    $best = $null

    if (-not [string]::IsNullOrWhiteSpace($Hint)) {
        $hintRoot = $Hint.TrimEnd('\')
        if (Test-Path -LiteralPath (Join-Path $hintRoot 'bin\matlab.exe')) {
            $hv = $null
            $mexe = Join-Path $hintRoot 'bin\matlab.exe'
            $fv = (Get-Item -LiteralPath $mexe).VersionInfo.FileVersion
            if ($fv -match '^(\d+\.\d+)') {
                $null = [version]::TryParse($Matches[1], [ref]$hv)
            }
            return [PSCustomObject]@{ Version = $hv; Root = $hintRoot }
        }
    }

    foreach ($key in @(
            'HKLM:\SOFTWARE\MathWorks\MATLAB',
            'HKLM:\SOFTWARE\WOW6432Node\MathWorks\MATLAB',
            'HKCU:\SOFTWARE\MathWorks\MATLAB')) {
        if (-not (Test-Path -LiteralPath $key)) { continue }
        foreach ($child in @(Get-ChildItem -LiteralPath $key -ErrorAction SilentlyContinue)) {
            $v = $null
            if (-not [version]::TryParse($child.PSChildName, [ref]$v)) { continue }
            $props = Get-ItemProperty -Path $child.PSPath -ErrorAction SilentlyContinue
            if (-not $props -or -not $props.MATLABROOT) { continue }
            if (-not $best -or $v -gt $best.Version) {
                $best = [PSCustomObject]@{ Version = $v; Root = [string]$props.MATLABROOT }
            }
        }
    }
    if ($best) { return $best }

    $cmd = Get-Command 'matlab.exe' -ErrorAction SilentlyContinue
    if ($cmd) {
        $root = Split-Path -Parent (Split-Path -Parent $cmd.Source)
        $v = $null
        $fv = (Get-Item -LiteralPath $cmd.Source).VersionInfo.FileVersion
        if ($fv -match '^(\d+\.\d+)') { $null = [version]::TryParse($Matches[1], [ref]$v) }
        return [PSCustomObject]@{ Version = $v; Root = $root }
    }
    return $null
}

function Format-MatlabVersion {
    param($Version)
    if (-not $Version) { return '未知版本' }
    if ($Version.Major -ge 20) {
        $letter = ''
        if ($Version.Minor -eq 1) { $letter = 'a' }
        elseif ($Version.Minor -eq 2) { $letter = 'b' }
        return ("R" + (2000 + $Version.Major) + $letter + " (" + $Version.ToString() + ")")
    }
    return $Version.ToString()
}

# ---------------------------------------------------------------------------
# 头部
# ---------------------------------------------------------------------------
$started = Get-Date
if (-not $NoColor) { Write-Host 'LG-AI-process 环境自检（只读）' -ForegroundColor Cyan }
else { Write-Host 'LG-AI-process 环境自检（只读）' }
Write-Host ("仓库: " + $RepoRoot)
Write-Host ("时间: " + $started.ToString('yyyy-MM-dd HH:mm:ss') + "  主机: " + $env:COMPUTERNAME)

# 仓库有效性
$repoOk = $false
if (-not [string]::IsNullOrWhiteSpace($RepoRoot) -and (Test-Path -LiteralPath $RepoRoot)) {
    $RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
    $projPath = Join-Path $RepoRoot 'firmware\LegWheel\MDK-ARM\LegWheel.uvprojx'
    $repoOk = Test-Path -LiteralPath $projPath
}
if (-not $repoOk) {
    Write-Host ''
    Write-Host "错误：找不到仓库或 LegWheel.uvprojx。用 -RepoRoot 指定仓库根。" -ForegroundColor Red
    Write-Host "当前: $RepoRoot" -ForegroundColor Red
    exit 2
}

# ---------------------------------------------------------------------------
# 1. 基础
# ---------------------------------------------------------------------------
Write-Section '1/6 基础环境'

if ($env:OS -eq 'Windows_NT') {
    Add-Result PASS 'OS' ([Environment]::OSVersion.VersionString + '（Windows）')
}
else {
    Add-Result FAIL 'OS' '非 Windows' 'Keil MDK 仅支持 Windows；Linux/macOS 无法直接编译'
}

Add-Result INFO 'PowerShell' ($PSVersionTable.PSVersion.ToString()) '脚本兼容 5.1+'

$gitCmd = Get-Command 'git.exe' -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (& git --version 2>$null | Out-String).Trim()
    Add-Result PASS 'Git' $gitVer
    try {
        $tracked = @(git -C $RepoRoot ls-files 2>$null).Count
        if ($tracked -gt 0) { Add-Result INFO 'Git' ("跟踪文件 " + $tracked + " 个") }
    }
    catch { }
}
else {
    Add-Result WARN 'Git' '未检测到 git' '文件仍可用；克隆/回退/对比需要 git'
}

$researchs = Join-Path $RepoRoot 'researchs'
if (Test-Path -LiteralPath $researchs) {
    Add-Result INFO '资料' 'researchs/ 存在'
}
else {
    $refCount = 0
    $docsDir = Join-Path $RepoRoot 'docs'
    if (Test-Path -LiteralPath $docsDir) {
        $mdFiles = @(Get-ChildItem -LiteralPath $docsDir -Recurse -Filter '*.md' -ErrorAction SilentlyContinue)
        if ($mdFiles.Count -gt 0) {
            $refCount = @(Select-String -Path $mdFiles.FullName -Pattern 'researchs/' -SimpleMatch).Count
        }
    }
    Add-Result WARN '资料' ("researchs/ 缺失（git 忽略）；docs 中 " + $refCount + " 处引用会失效") '需要厂商资料/例程时另行获取'
}

$snapshots = Join-Path $RepoRoot 'archive\snapshots'
if (Test-Path -LiteralPath $snapshots) {
    Add-Result INFO '资料' 'archive/snapshots/ 存在'
}
else {
    Add-Result INFO '资料' 'archive/snapshots/ 不在仓库' '1.71 GiB 快照需另行获取；回退依赖它'
}

# ---------------------------------------------------------------------------
# 2. Keil
# ---------------------------------------------------------------------------
Write-Section '2/6 Keil MDK / 编译器'

$keilCore = $null
$explicitKeilRoot = -not [string]::IsNullOrWhiteSpace($KeilRoot)
if ($explicitKeilRoot) { $keilCore = Resolve-KeilCore -Candidate $KeilRoot }
else { $keilCore = Find-KeilCore }
$packsRoot = $null
if (-not $keilCore) {
    if ($explicitKeilRoot) {
        Add-Result FAIL 'Keil' '指定的 -KeilRoot 无效或结构不符（需含 UV4\UV4.exe）' $KeilRoot
    }
    else {
        Add-Result FAIL 'Keil' '未检测到 Keil MDK（UV4.exe）' '用 -KeilRoot 或 KEIL_ROOT 指定安装根（含 UV4 目录）'
    }
}
else {
    $uv4 = Join-Path $keilCore 'UV4\UV4.exe'
    $uv4Ver = (Get-Item -LiteralPath $uv4).VersionInfo.FileVersion
    Add-Result PASS 'Keil' ("UV4.exe " + $uv4Ver) $uv4
    if ($uv4Ver -notmatch '^5\.38') {
        Add-Result WARN 'Keil' ("MDK 版本 " + $uv4Ver + "，工程按 5.38 / AC6.19 验证") '其它 MDK 版本可能不认识 V6.19 编译器'
    }

    $ini = Join-Path $keilCore 'TOOLS.INI'
    if (-not (Test-Path -LiteralPath $ini)) {
        $ini = Join-Path (Split-Path -Parent $keilCore) 'TOOLS.INI'
    }
    if (Test-Path -LiteralPath $ini) {
        $iniText = [IO.File]::ReadAllText($ini)
        if ($iniText -match '(?m)^\s*LIC0\s*=') {
            Add-Result PASS 'Keil' '授权：已发现 LIC0（内容不显示）'
        }
        else {
            Add-Result FAIL 'Keil' '未发现 LIC0 授权' '评估版 32 KB 上限；本固件约 172 KB，会链接失败'
        }
        $m = [regex]::Match($iniText, 'RTEPATH\s*=\s*"([^"]+)"')
        if ($m.Success) { $packsRoot = $m.Groups[1].Value }
    }
    else {
        Add-Result WARN 'Keil' '未找到 TOOLS.INI' '无法确认授权/包路径'
    }

    $armclang = Join-Path $keilCore 'ARM\ARMCLANG\bin\armclang.exe'
    if (Test-Path -LiteralPath $armclang) {
        $verOut = ''
        try { $verOut = (& $armclang --version 2>&1 | Out-String) } catch { }
        $m = [regex]::Match($verOut, 'Compiler for Embedded\s+([0-9]+\.[0-9]+)')
        if ($m.Success) {
            Add-Result PASS '编译器' ("ARMCLANG " + $m.Groups[1].Value)
            if ($m.Groups[1].Value -ne '6.19') {
                Add-Result WARN '编译器' ("ARMCLANG " + $m.Groups[1].Value + " 与工程钉版 6.19 不一致") 'uvprojx 要求 V6.19；需改工程或装 6.19'
            }
        }
        else {
            Add-Result WARN '编译器' 'ARMCLANG 存在但版本未识别' $armclang
        }
    }
    else {
        Add-Result FAIL '编译器' '未找到 armclang.exe' ('期望: ' + $armclang)
    }
}

if ($keilCore -and -not $packsRoot) {
    $packsRoot = Join-Path (Split-Path -Parent $keilCore) 'Packs'
}
if ($keilCore -and $packsRoot) {
    $packsRoot = $packsRoot.TrimEnd('\')
    if (-not (Test-Path -LiteralPath $packsRoot)) {
        Add-Result WARN 'Pack' '未找到 Pack 根目录' $packsRoot
    }
    else {
        $h7 = Get-MaxVersionDir (Join-Path $packsRoot 'Keil\STM32H7xx_DFP')
        if ($h7) { Add-Result PASS 'Pack' ("STM32H7xx_DFP " + $h7.Version) }
        else { Add-Result WARN 'Pack' '未找到 STM32H7xx_DFP' '器件库/SVD/下载算法缺失；编译可能仍依赖源码自带 HAL/CMSIS' }

        $acPack = Get-MaxVersionDir (Join-Path $packsRoot 'Keil\ARM_Compiler')
        if ($acPack) { Add-Result INFO 'Pack' ("ARM_Compiler " + $acPack.Version) }
        else { Add-Result WARN 'Pack' '未找到 ARM_Compiler pack' '独立安装 AC6 时可能不需要' }

        $cmsis = Get-MaxVersionDir (Join-Path $packsRoot 'ARM\CMSIS')
        if ($cmsis) { Add-Result INFO 'Pack' ("CMSIS " + $cmsis.Version + "（工程声明 6.1.0）") }
        else { Add-Result INFO 'Pack' '未找到 CMSIS pack（源码自带 CMSIS，通常不影响）' }

        $svd = $null
        try {
            $svd = Get-ChildItem -LiteralPath (Join-Path $packsRoot 'Keil\STM32H7xx_DFP') -Recurse -Filter 'STM32H723.svd' -ErrorAction SilentlyContinue | Select-Object -First 1
        }
        catch { }
        if ($svd) { Add-Result INFO 'Pack' '器件 SVD（STM32H723）可用' }
        else { Add-Result INFO 'Pack' '未找到 STM32H723.svd（调试器件视图会受影响）' }
    }
}

# ---------------------------------------------------------------------------
# 3. 工程完整性
# ---------------------------------------------------------------------------
Write-Section '3/6 工程完整性（uvprojx）'

$proj = $null
try {
    $xmlText = [IO.File]::ReadAllText($projPath)
    [xml]$proj = $xmlText
    Add-Result PASS '工程' 'LegWheel.uvprojx 可解析'
}
catch {
    Add-Result FAIL '工程' 'LegWheel.uvprojx 解析失败' $_.Exception.Message
}

if ($proj) {
    $pinNode = $proj.SelectSingleNode('//pCCUsed')
    if ($pinNode -and $pinNode.InnerText -match '6190000::V6\.19::ARMCLANG') {
        Add-Result PASS '工程' '编译器钉版 V6.19 / ARMCLANG'
    }
    elseif ($pinNode) {
        Add-Result WARN '工程' ("编译器声明 " + $pinNode.InnerText) '与已记录的 V6.19 不一致'
    }
    else {
        Add-Result WARN '工程' '未找到 pCCUsed' '无法确认编译器版本'
    }

    $devNode = $proj.SelectSingleNode('//Device')
    if ($devNode) { Add-Result INFO '工程' ("器件 " + $devNode.InnerText) }

    $projDir = Split-Path -Parent $projPath
    $filePaths = @()
    foreach ($n in @($proj.SelectNodes('//FilePath'))) {
        $p = $n.InnerText.Trim()
        if ($p) { $filePaths += $p }
    }
    $missingFiles = @()
    foreach ($fp in $filePaths) {
        $full = [IO.Path]::GetFullPath((Join-Path $projDir ($fp -replace '\\', '/')))
        if (-not (Test-Path -LiteralPath $full)) { $missingFiles += $fp }
    }
    if ($missingFiles.Count -eq 0) {
        Add-Result PASS '工程' ("源文件 " + $filePaths.Count + "/" + $filePaths.Count + " 存在")
    }
    else {
        $example = ($missingFiles | Select-Object -First 5) -join '; '
        Add-Result FAIL '工程' ("源文件缺失 " + $missingFiles.Count + "/" + $filePaths.Count) $example
    }

    $incPaths = @()
    foreach ($n in @($proj.SelectNodes('//IncludePath'))) {
        foreach ($part in ($n.InnerText -split ';')) {
            $trimmed = $part.Trim()
            if (-not $trimmed) { continue }
            # C 编译器(Cads)与汇编(Aads)两个 IncludePath 节点会重复，按归一化路径去重
            $norm = ($trimmed -replace '\\', '/')
            if ($incPaths -notcontains $norm) { $incPaths += $norm }
        }
    }
    $missingInc = @()
    foreach ($inc in $incPaths) {
        if ([IO.Path]::IsPathRooted($inc)) {
            $full = $inc
        }
        else {
            $full = [IO.Path]::GetFullPath((Join-Path $projDir ($inc -replace '\\', '/')))
        }
        if (-not (Test-Path -LiteralPath $full)) { $missingInc += $inc }
    }
    if ($missingInc.Count -eq 0) {
        Add-Result PASS '工程' ("include 路径 " + $incPaths.Count + "/" + $incPaths.Count + " 存在")
    }
    else {
        $example = ($missingInc | Select-Object -First 5) -join '; '
        Add-Result FAIL '工程' ("include 路径缺失 " + $missingInc.Count + "/" + $incPaths.Count) $example
    }
}

$lib = Join-Path $RepoRoot 'firmware\LegWheel\Drivers\CMSIS\DSP\Lib\ARM\arm_cortexM7lfdp_math.lib'
if (Test-Path -LiteralPath $lib) { Add-Result PASS '工程' 'CMSIS DSP 库存在' }
else { Add-Result FAIL '工程' 'CMSIS DSP 库缺失' $lib }

$startup = Join-Path $RepoRoot 'firmware\LegWheel\MDK-ARM\startup_stm32h723xx.s'
$sct = Join-Path $RepoRoot 'firmware\LegWheel\MDK-ARM\LegWheel\LegWheel.sct'
$uvoptx = Join-Path $RepoRoot 'firmware\LegWheel\MDK-ARM\LegWheel.uvoptx'
foreach ($pair in @(@($startup, '启动文件'), @($sct, 'scatter 文件'), @($uvoptx, 'uvoptx 调试配置'))) {
    if (Test-Path -LiteralPath $pair[0]) { Add-Result PASS '工程' ($pair[1] + ' 存在') }
    else { Add-Result FAIL '工程' ($pair[1] + ' 缺失') $pair[0] }
}

$knownHex = Join-Path $RepoRoot 'archive\legacy\hex-2026-10-18\LegWheel.hex'
if (Test-Path -LiteralPath $knownHex) {
    $hexLen = (Get-Item -LiteralPath $knownHex).Length
    if ($hexLen -eq 494095) {
        Add-Result INFO '工程' '已知基线 hex 494,095 B 存在'
    }
    else {
        Add-Result WARN '工程' ("已知基线 hex 大小 " + $hexLen + " B（记录为 494,095 B）") $knownHex
    }
}
else {
    Add-Result WARN '工程' '已知基线 hex 缺失' '回退/对比需要它；见 archive/manifests/S0-BASELINE.md'
}

$cppProps = Join-Path $RepoRoot 'firmware\LegWheel\MDK-ARM\.vscode\c_cpp_properties.json'
if (Test-Path -LiteralPath $cppProps) {
    try {
        $props = [IO.File]::ReadAllText($cppProps) | ConvertFrom-Json
        $badCount = 0
        $badExample = ''
        foreach ($cfg in @($props.configurations)) {
            foreach ($inc in @($cfg.includePath)) {
                if ($inc -match '^[A-Za-z]:[\\/]') {
                    if (-not (Test-Path -LiteralPath $inc)) {
                        $badCount++
                        if (-not $badExample) { $badExample = $inc }
                    }
                }
            }
        }
        if ($badCount -gt 0) {
            Add-Result WARN 'IDE' ("c_cpp_properties.json 含 " + $badCount + " 条失效绝对路径") ("示例: " + $badExample + "；属 TODO-02，会让人误以为工程坏了")
        }
        else {
            Add-Result PASS 'IDE' 'c_cpp_properties.json 路径有效'
        }
    }
    catch {
        Add-Result WARN 'IDE' 'c_cpp_properties.json 无法解析' $_.Exception.Message
    }
}
else {
    Add-Result INFO 'IDE' '无 c_cpp_properties.json（可选）'
}

# ---------------------------------------------------------------------------
# 4. 仿真（MATLAB）
# ---------------------------------------------------------------------------
Write-Section '4/6 仿真环境（MATLAB）'

$mat = Find-Matlab -Hint $MatlabRoot
if (-not [string]::IsNullOrWhiteSpace($MatlabRoot) -and -not (Test-Path -LiteralPath (Join-Path $MatlabRoot 'bin\matlab.exe'))) {
    Add-Result WARN 'MATLAB' '指定的 -MatlabRoot 无效，已回退自动探测' $MatlabRoot
}
if (-not $mat) {
    Add-Result WARN 'MATLAB' '未检测到 MATLAB' '只读 .m/.mat 可行；跑仿真/生成 K 需要 R2024a+ 与工具箱'
}
else {
    $verText = Format-MatlabVersion $mat.Version
    Add-Result PASS 'MATLAB' ("MATLAB " + $verText) $mat.Root
    if ($mat.Version -and $mat.Version -lt [version]'24.1') {
        Add-Result WARN 'MATLAB' '版本低于 R2024a' 'balance_robot_real.slx 由 R2024a 保存，旧版可能打不开'
    }
    foreach ($tb in @(
            @('control', 'Control System Toolbox'),
            @('simulink', 'Simulink'),
            @('symbolic', 'Symbolic Math Toolbox'))) {
        $tbPath = Join-Path $mat.Root ('toolbox\' + $tb[0])
        if (Test-Path -LiteralPath $tbPath) {
            Add-Result PASS 'MATLAB' ($tb[1] + ' 已安装')
        }
        else {
            Add-Result WARN 'MATLAB' ($tb[1] + ' 未找到') ('期望目录: ' + $tbPath + '；K 生成/仿真会失败')
        }
    }
}

$slx = Join-Path $RepoRoot 'simulation\chassis-lqr\balance_robot_real.slx'
if (Test-Path -LiteralPath $slx) { Add-Result INFO '仿真' 'balance_robot_real.slx 存在' }
else { Add-Result FAIL '仿真' 'balance_robot_real.slx 缺失' $slx }

# ---------------------------------------------------------------------------
# 5. 可选工具
# ---------------------------------------------------------------------------
Write-Section '5/6 可选工具'

$cubeCandidates = @()
if (-not [string]::IsNullOrWhiteSpace($CubeMxPath)) { $cubeCandidates += $CubeMxPath }
$cubeCandidates += (Join-Path $env:ProgramFiles 'STMicroelectronics\STM32Cube\STM32CubeMX\STM32CubeMX.exe')
$pf86 = ${env:ProgramFiles(x86)}
if ($pf86) {
    $cubeCandidates += (Join-Path $pf86 'STMicroelectronics\STM32Cube\STM32CubeMX\STM32CubeMX.exe')
}
$cubeCandidates += 'C:\STM32CubeMX\STM32CubeMX.exe'
if ($keilCore) {
    $toolRoot = Split-Path -Parent (Split-Path -Parent $keilCore)
    if ($toolRoot) {
        $cubeCandidates += (Join-Path $toolRoot 'STM32CubeMx\Core\STM32CubeMX.exe')
        $cubeCandidates += (Join-Path $toolRoot 'STM32CubeMX\STM32CubeMX.exe')
    }
}
$cubeExe = $null
foreach ($c in $cubeCandidates) {
    if (Test-Path -LiteralPath $c) { $cubeExe = $c; break }
}
if ($cubeExe) {
    $cubeVer = (Get-Item -LiteralPath $cubeExe).VersionInfo.FileVersion
    Add-Result INFO 'CubeMX' ("STM32CubeMX " + $cubeVer) $cubeExe
    $h7Repo = @()
    $cubeRepo = $null
    if ($env:USERPROFILE) { $cubeRepo = Join-Path $env:USERPROFILE 'STM32Cube\Repository' }
    if ($cubeRepo -and (Test-Path -LiteralPath $cubeRepo)) {
        $h7Repo = @(Get-ChildItem -LiteralPath $cubeRepo -Directory -Filter 'STM32Cube_FW_H7_*' -ErrorAction SilentlyContinue)
    }
    if ($h7Repo.Count -gt 0) {
        $h7Names = ($h7Repo | ForEach-Object { $_.Name }) -join ', '
        Add-Result INFO 'CubeMX' ("H7 固件包: " + $h7Names)
    }
    else {
        Add-Result WARN 'CubeMX' '未找到 H7 固件包（STM32Cube_FW_H7_*）' '不要重新生成 .ioc；工作流见 build-and-flash §3'
    }
}
else {
    Add-Result INFO 'CubeMX' '未检测到（可选；仅在重配外设时用）'
}

$cmakeCmd = Get-Command 'cmake.exe' -ErrorAction SilentlyContinue
if ($cmakeCmd) {
    $cmakeVer = (& cmake --version 2>$null | Select-Object -First 1)
    Add-Result INFO 'CMake' ($cmakeVer + '（项目未启用）')
}
else {
    Add-Result INFO 'CMake' '未安装（符合项目现状：不启用）'
}

$codeCmd = Get-Command 'code.cmd' -ErrorAction SilentlyContinue
if ($codeCmd) { Add-Result INFO 'VSCode' 'code CLI 可用' }
else { Add-Result INFO 'VSCode' '未检测到 code CLI（可选）' }

# ---------------------------------------------------------------------------
# 6. 汇总
# ---------------------------------------------------------------------------
$elapsed = ((Get-Date) - $started).TotalSeconds
Write-Host ''
if ($NoColor) { Write-Host ('-' * 64) } else { Write-Host ('-' * 64) -ForegroundColor DarkGray }
$summary = ("PASS {0} | WARN {1} | FAIL {2}" -f $script:PassCount, $script:WarnCount, $script:FailCount)
Write-Host $summary
Write-Host ("耗时 " + [math]::Round($elapsed, 1) + " s")
Write-Host "文档: docs/02-architecture/environment.md"

if ($script:FailCount -gt 0) {
    Write-Host ''
    Write-Host '结论：存在阻塞项（FAIL），先修复再编译/烧录。' -ForegroundColor Red
    exit 1
}
if ($Strict -and $script:WarnCount -gt 0) {
    Write-Host ''
    Write-Host '结论：-Strict 模式下 WARN 视为失败。' -ForegroundColor Yellow
    exit 1
}
Write-Host ''
Write-Host '结论：无阻塞项（WARN 不阻止构建）。'
exit 0
