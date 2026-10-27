# 环境与可复现性（Environment）

> 最后更新：2026-10-25（新建；数据来自 2026-10-19 只读检查 + 2026-10-25 自检）。  
> **本文件是“环境 / 安装 / 自检”的唯一事实源**；构建步骤看 [`build-and-flash.md`](./build-and-flash.md)，参数看 [`../04-parameters/parameters.md`](../04-parameters/parameters.md)。  
> 一句话：源码自含（HAL/CMSIS/FreeRTOS/DSP 已入库、工程全相对路径），但**构建依赖 Windows + Keil MDK 5.38（ARMCLANG 6.19）+ 有效授权**；**仿真依赖 MATLAB ≥ R2024a + Simulink + Control/Symbolic 工具箱**；**实车依赖同款硬件**。

## 1. 角色与最低要求

| 你想做什么 | 必须装 | 可以不装 | 说明 |
|---|---|---|---|
| 读代码、改纯算法 | Git + 编辑器 | Keil、MATLAB、硬件 | 源码自含，克隆即可读 |
| 编译固件 | Windows 10/11 x64 + Keil MDK 5.38 + ARMCLANG 6.19 + 有效授权 | MATLAB、硬件 | 免费评估版 32 KB 上限；本固件镜像约 172 KB，不够 |
| 生成/改 K、跑仿真 | MATLAB ≥ R2024a + Simulink + Control System Toolbox + Symbolic Math Toolbox | Keil、硬件 | `.slx` 由 R2024a 保存 |
| 烧录/实车联调 | 上述构建环境 + DAPLink/ST-Link + 台架 | — | 烧录步骤仍 TBD（C4）；先台架、轮子离地 |

> **许可**：Keil 授权通常与机器绑定，不能直接共享；MATLAB 同理。不要把授权码提交进仓库或截图外发。

## 2. 版本矩阵（唯一事实源）

| 组件 | 本机已验证 | 要求 / 证据 | 级别 |
|---|---|---|---|
| OS | Windows 11 x64 | Keil MDK 仅 Windows | 硬 |
| Keil MDK | 5.38.0.0（注册表 `HKLM\SOFTWARE\WOW6432Node\Keil\Products\MDK`，Version=V5.38） | 工程声明 AC6.19，需 MDK 5.38；[`LegWheel.uvprojx:13`](../../firmware/LegWheel/MDK-ARM/LegWheel.uvprojx#L13) `pCCUsed=6190000::V6.19::ARMCLANG` | 硬 |
| ARM Compiler | ARMCLANG 6.19（LLVM 16；`armclang --version` 显示 MDK Plus 5.38 / Compiler 6.19） | 同上 | 硬 |
| Keil 授权 | `TOOLS.INI` 含 `LIC0`（内容不记录、不展示） | 镜像 175,648 B（hex 494,095 B）远超评估版 32 KB；授权档位以 Arm 条款为准 | 硬 |
| STM32H7xx_DFP | 4.1.3 | 器件 STM32H723VGTx；SVD 在 `Packs/Keil/STM32H7xx_DFP/4.1.3/CMSIS/SVD/STM32H723.svd` | 建议（器件库/SVD/下载算法） |
| ARM_Compiler pack | 1.7.2 | Keil 的编译器包；独立安装 AC6 时可能不需要 | 建议 |
| CMSIS pack | 5.9.0（工程声明 6.1.0） | 源码自带 `Drivers/CMSIS/Include`，当前编译不依赖 RTE 包 | 不硬 |
| STM32CubeMX | > 6.17.0-RC5 | 只在副本生成；[`LegWheel.ioc:428`](../../firmware/LegWheel/LegWheel.ioc#L428) 要 `STM32Cube FW_H7 V1.12.1`（本机仓库缺），[`:444`](../../firmware/LegWheel/LegWheel.ioc#L444) 仍写 `MDK-ARM V5.27`（漂移） | 可选 |
| MATLAB | 24.2 / R2024b（`D:\MATLAB`） | `.slx` 元数据为 R2024a → 需 ≥ R2024a；更旧版本打不开模型 | 仿真硬 |
| Simulink | 随 MATLAB | `simulation/chassis-lqr/balance_robot_real.slx` | 仿真硬 |
| Control System Toolbox | 已装 | `lqrd` / `ctrb`：[`Calc_K_and_fit.m:82`](../../simulation/chassis-lqr/Calc_K_and_fit.m#L82)、[`:87`](../../simulation/chassis-lqr/Calc_K_and_fit.m#L87) | 仿真硬 |
| Symbolic Math Toolbox | 已装 | `syms` / `jacobian` / `matlabFunction`：`k_calc_chuan_real2.m`、`Variables_and_Equations.m`、`Num_function.m` | 仿真硬 |
| Git | 2.54.0 | 克隆 / 回退 / 对比 | 建议 |
| CMake | 未安装 | 项目明确不启用（见 build-and-flash §4） | 不需要 |
| VS Code | 1.142 | IntelliSense；配置仍待修（TODO-02） | 可选 |
| VOFA+ | 任意 | 调试观测：13 路 JustFloat、115200 | 可选 |

> `researchs/`（5,401 文件 / 1.1 GB）与 `archive/snapshots/`（1.71 GiB）被 `.gitignore` 排除。克隆只有 **819 个跟踪文件 / 约 7 MB**，但 docs 中 **45 处** `researchs/` 引用会失效（2026-10-25 统计，不含本文件；§6）。

## 3. 从零安装（Windows）

1. **装 Keil MDK 5.38**（含 Arm Compiler 6.19）。装完确认存在 `<Keil>\UV4\UV4.exe` 与 `<Keil>\ARM\ARMCLANG\bin\armclang.exe`。
2. **装器件包**：Pack Installer 安装 `STM32H7xx_DFP` 4.1.3（或兼容更新版）与 `ARM_Compiler`；离线环境可双击 `.pack`。
3. **激活授权**：Keil → File → License Management。本工程镜像约 172 KB，评估版 32 KB 不够。
4. **克隆仓库**：`git clone <repo> D:\RM\LG-AI-process`（路径随意，避免深层中文/空格路径）。
5. **不要重新生成 `.ioc`**：`.ioc` 已漂移且本机缺 H7 固件包，直接生成会覆盖用户代码；工作流见 build-and-flash §3。
6. **自检**：`powershell -NoProfile -ExecutionPolicy Bypass -File tools\check-env.ps1`；无 FAIL 再继续。
7. **编译**：打开 `firmware/LegWheel/MDK-ARM/LegWheel.uvprojx` → Build；产物 `MDK-ARM/LegWheel/LegWheel.hex`。
8. **仿真**：装 MATLAB R2024a+、Simulink、Control System Toolbox、Symbolic Math Toolbox；打开 `simulation/chassis-lqr/balance_robot_real.slx`。

## 4. 验证

### 4.1 环境自检脚本（推荐，只读）

```powershell
# Windows PowerShell 5.1 或 PowerShell 7 均可
powershell -NoProfile -ExecutionPolicy Bypass -File tools\check-env.ps1

# 可覆盖探测结果；-Strict 让 WARN 也返回非零（适合 CI/交接门禁）
pwsh -File tools/check-env.ps1 -KeilRoot "C:\Keil_v5" -MatlabRoot "D:\MATLAB" -Strict
```

- 输出：每条检查一行 `PASS / WARN / FAIL / INFO`，最后汇总计数；
- 退出码：`0` 无 FAIL；`1` 有 FAIL（`-Strict` 时 WARN 也返回 1）；`2` 参数/仓库路径错误；
- **只读**：不写文件、不改注册表、不显示授权码；
- 检查范围：OS/仓库/git、Keil 安装与授权、编译器与 pack、`uvprojx` 全部源文件/include、DSP 库、已知 hex、MATLAB/工具箱、CubeMX/CMake/VSCode、`researchs/` 缺失情况。

### 4.2 手动确认（脚本不替代）

1. 打开 `LegWheel.uvprojx` → Build；确认 `LegWheel.hex` 时间/大小更新（已知基线 494,095 B，2026-10-18）。
2. 可选无头编译：`& "<Keil>\UV4\UV4.exe" -b firmware\LegWheel\MDK-ARM\LegWheel.uvprojx -j0 -o build.log`；**本机未复验**（受限/无桌面会话下 UV4 可能崩溃），以 GUI Build 为准。
3. MATLAB：`matlab -batch "ver"` 应列出 Simulink / Control System Toolbox / Symbolic Math Toolbox；打开 `.slx` 无版本错误。

## 5. 支持边界（不承诺）

- 当前只在 **1 台 Windows 11** 机器验证过 Build（2026-10-19，用户确认）；**没有 CI，也没有第二台机器复验**。
- 自检脚本做的是静态完整性检查，**不等于真实编译/烧录通过**。
- Linux / macOS 不能直接编译（Keil 无 Linux 版）；要跨平台需另立 GCC/CMake 任务（当前明确不启用）。
- 授权与 MATLAB 许可由使用者自行解决；本仓库不包含、不代为分发。

## 6. 已知坑

1. **`.ioc` 漂移** + 本机缺 H7 固件包：不要直接重新生成（build-and-flash §3；open-questions C3）。
2. **IntelliSense**：入库的 [`c_cpp_properties.json:6`](../../firmware/LegWheel/MDK-ARM/.vscode/c_cpp_properties.json#L6) 仍指向 `d:\RM\27-transistor-codes\...`，新人打开即全红；脚本会 WARN。修复见 [TODO-02](../00-plan/todo/02-build-entry.md)。
3. **资料缺失**：`researchs/`、`archive/snapshots/` 不在 git；45 处文档链接失效，需另行获取资料。
4. **CMSIS 版本错位**：工程声明 6.1.0，本机 5.9.0；当前靠源码自带 CMSIS 编译，若改用 RTE 组件需补齐。
5. **评估版限制**：32 KB；本固件约 172 KB。
6. **文档里的本机路径**（`D:\RM\...`、`C:\STM32+Vscode+Keil5`）只是示例；脚本用注册表 / 参数探测，不依赖它们。
7. **无 `LICENSE`**：对外分发前需补（见建议）。

## 7. 维护规则

- 版本 / 安装方式变化：先改本文件，再改脚本与 `build-and-flash.md`；
- 新机器验证通过：在 §2 增加“第二台机器”记录（版本 + 日期 + 结果）；
- 脚本与文档不一致时，以脚本输出为准并修文档；
- 授权码、机器名等敏感信息**永不**写入本文件。
