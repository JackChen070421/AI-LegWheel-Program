# 变更记录

本文件记录项目结构、文档、代码的变更，便于回退。  
格式：日期 / 类型 / 内容 / 验证 / 回退。

> **记录方向（2026-10-26 起）**：事件记录**从下往上**写——新记录追加在本文件顶部（第一条 `---` 之后），**越靠前日期越新**；同日按“后发生在前”。历史记录已按此方向重排（内容未改）。

---

## 2026-10-27 — PR #2 已创建

- PR #2：<https://github.com/JackChen070421/AI-LegWheel-Program/pull/2>
- head `docs/shortcut-instruction-flow` → base `main@651b64f`；只含本地修改，**不包含** #1 的 `SHORTCUT.md` 或其提交。
- 未合并；未修改 `main`。

---

## 2026-10-27 — 远端口径统一；准备 PR #2

### 背景

- 远端已有 open PR #1（作者 Koahoshi，分支 `docs/shortcut-md`，含 `SHORTCUT.md`）；维护者指出：push 口径在 `AGENTS.md`/`docs/00-governance/README.md`/`open-questions.md` 不一致、用文档做授权不可靠、自然语言模糊匹配不能当控制面。
- 本 PR 从 `main` 新建，只记录本地修改；**不包含 #1 的 `SHORTCUT.md` 或其提交**。

### 变更

- `shortcut.md`：增加 §0.1“控制面边界”（指南≠授权；自然语言表≠精确触发/预授权；控制面=用户当次指令+审批+工具策略）；更新默认策略与推送章节；入口统一标注“非授权来源”。
- `AGENTS.md`、`README.md`、`docs/00-governance/README.md`、`docs/00-plan/open-questions.md`、`docs/06-plans/roadmap.md`、`docs/00-plan/todo/06-git-baseline-deletion.md`、`docs/00-plan/agent-execution-policy.md`：统一为“默认不直推 `main`；功能分支 push/PR/merge 逐次授权；文档不构成授权”。
- `docs/00-plan/structure-proposal.md`：历史提案加注，指向 `shortcut.md` §3。
- 旧 `shortcuts.md` 在 2026-10-27 检查时已不存在；不纳入本 PR。

### 验证

- `shortcut.md` 300 行（≤300）；相对链接 0 坏链。
- `grep` 复核：现行文档不再写“远端暂不需要/当前不 push”；仅历史记录与带注记的历史提案保留旧说法。
- `git ls-remote --heads origin` 在 VPN + 放宽沙箱后成功；远端分支 `main`、`docs/shortcut-md`。
- 未改 `main`、未合并 #1；PR #2 创建后补记链接。

### 未做

- 未合并/关闭 PR #1；未推送 `main`。

---

## 2026-10-26 — 指令流 shortcut.md + CHANGELOG 最新在前

### 新增

- `shortcut.md` — 本项目自然语言 → Git/GitHub/项目操作的唯一指令流：项目与工具现状、操作前上下文检查、`main` 分支红线（权限确认 + 用户明确确认 + 优先 PR）、同步/提交/推送/分支/PR/合并/回退命令、进展与“下一步”等意图规范、状态汇报格式。

### 变更

- `CHANGELOG.md` — 明确“事件从下往上记录、最新在前”的规则；全部历史记录按日期降序重排（内容未改，新增本段）。
- `AGENTS.md` — §2 入口加入 `shortcut.md`；§5 增加指令流入口、`main` 红线、远端写操作授权、记录方向；§7 要求交付时说明是否提交/推送。
- `README.md` — 文档地图加入 `shortcut.md`；快速开始提示 Git/GitHub 操作先读该文件。
- `docs/00-governance/README.md` — 协作规范索引加入 `shortcut.md`；记录规则补充“最新在前”。
- `docs/00-plan/agent-execution-policy.md` — §7 禁止事项引用 `shortcut.md`（main/远端写操作单一事实源）。
- `docs/00-plan/todo/06-git-baseline-deletion.md` — 关联文件与讨论记录补充 2026-10-26 远端实测。
- `shortcuts.md` — 曾加“已废弃/非本项目语境”警示；2026-10-27 检查时该文件已不存在（未纳入本 PR）。

### 验证

- `shortcut.md`：298 行（2026-10-27 修订后 300 行，仍 ≤300）；相对链接目标存在；`AGENTS.md`/`README.md`/`CHANGELOG.md` 均可到达。
- `CHANGELOG.md`：共 13 个日期段（2026-10-26 ×1、2026-10-25 ×1、2026-10-19 ×11）；历史 12 段逐段原文保留，仅顺序变化；顶部首段为 2026-10-26。
- 历史段落未被删改：按 `^---$` 分段、反转、重拼，逐段 SHA-256 与重排前一致。
- 未执行 `git add` / `commit` / `push` / PR / merge；`git ls-remote --heads origin` 仍报 `SEC_E_NO_CREDENTIALS`（2026-10-26），未做任何远端写操作。
- 未改代码、构建配置、`researchs/`；本任务未删除/移动任何文件。

### 回退

- 删除 `shortcut.md`，撤销 `AGENTS.md`/`README.md`/`docs/00-governance/README.md`/`docs/00-plan/agent-execution-policy.md`/`docs/00-plan/todo/06-git-baseline-deletion.md` 的本次改动；
- `CHANGELOG.md` 恢复为“旧→新”顺序：使用修改前备份或编辑器历史回退（本次未提交）。

### 未做 / 未验证

- 未验证 GitHub 云端操作（`gh` 未安装、凭据缺失）；`shortcut.md` 中云端流程为规范/待验证，不表示已实际跑通。
- 未运行构建/烧录；本次仅文档与规则变更。

---

## 2026-10-25 — 环境文档 + 自检脚本

### 新增

- `docs/02-architecture/environment.md` — 环境/安装/自检的唯一事实源：角色最低要求、版本矩阵（Keil 5.38 / ARMCLANG 6.19 / 授权 / H7 DFP / MATLAB R2024a+ 与工具箱）、从零安装、验证、支持边界、已知坑；
- `tools/check-env.ps1` — 只读环境自检（Windows PowerShell 5.1 与 7+ 兼容）：OS/Git/资料、Keil 安装与授权、ARMCLANG 版本、pack、`uvprojx` 的 114 个源文件与 15 条 include、DSP 库、基线 hex、IntelliSense 失效路径、MATLAB 与工具箱、CubeMX/CMake/VSCode；退出码 0/1/2，`-Strict` 把 WARN 当失败，支持 `-KeilRoot`/`-MatlabRoot`/`-RepoRoot` 覆盖。

### 更新

- `docs/02-architecture/build-and-flash.md` §1：删除重复的版本表，改为链接 `environment.md`（单一事实源）；
- `docs/02-architecture/README.md`：索引新增 `environment.md`；
- `README.md` §5、`AGENTS.md` §2/§4：环境信息指向 `environment.md`；
- `tools/README.md`：登记 `check-env.ps1`（状态 ✅）。

### 验证

- `pwsh -File tools/check-env.ps1 -NoColor` → **PASS 18 / WARN 2 / FAIL 0**，退出码 0；
- `powershell -File tools/check-env.ps1 -NoColor`（Windows PowerShell 5.1）→ 同样 18/2/0，退出码 0；
- 失败路径：`-KeilRoot` 无效 → FAIL + 退出 1；`-RepoRoot` 无效 → 退出 2；`-Strict` → 退出 1；从 `C:\` 运行仍能定位仓库；
- 自检实测：Keil 5.38.0.0 + LIC0 + ARMCLANG 6.19 + DFP 4.1.3；工程 114/114 源文件、15/15 include；MATLAB R2024b + Control/Simulink/Symbolic；WARN 两项为已知问题（IntelliSense 19 条失效路径＝TODO-02、CubeMX 缺 H7 固件包）。

### 回退

- 删除 `docs/02-architecture/environment.md`、`tools/check-env.ps1`，并对上述文档 `git checkout` 即可；未改代码、未改构建配置。

### 未做 / 未验证

- 未做真实编译（Build 仍以 2026-10-19 用户 GUI 验证为准）；脚本不做无头编译与烧录；
- 未在第二台机器复验；`researchs/` 与快照未纳入仓库（保持 `.gitignore`）。

---

## 2026-10-19 — TODO-02 Build 复验通过 + 今日收工

- 用户确认 **清理后 Keil Build 成功**；include 34 → 15 的修改验证通过；
- 用户确认 **使用 VSCode，打开 `firmware/LegWheel`**；下次生成 `firmware/LegWheel/.vscode/c_cpp_properties.json`，归档旧 `MDK-ARM/.vscode`；
- 新增 `docs/00-plan/progress-20261019.md`（今日进度快照/恢复入口）；
- 更新 TODO-02/build-and-flash/open-questions/structure-audit/roadmap/README；
- tag：`todo2-include-cleanup`（本次记录 commit）。

---

## 2026-10-19 — TODO-02 Keil include 清理（待 Build 复验）

- 用户允许修改 `uvprojx`；CubeMX 工作流选 **B：只在副本生成、手动合并**；
- 备份：`archive/legacy/config-backups/LegWheel.uvprojx-20261019.bak`（55,476 B）；
- 删除 19 条失效 include，保留 15 条；XML 解析通过、`<FilePath>` 114 个不变、静态检查 **0 missing**；
- **Build 复验待做**：Keil 当前是打开状态，需关闭/重开（不要保存旧工程）后 Build；失败则用备份覆盖回退；
- VSCode/IntelliSense、烧录方式、`compile_flags` 仍待确认；
- 文档同步：build-and-flash / TODO-02 / open-questions / structure-audit。

---

## 2026-10-19 — Keil Build 验证 + 结构审计

### 验证/更新

- 用户确认 **Keil 可正常编译**（2026-10-19）；
- 工程实际编译器：**ARMCLANG V6.19 / LLVM 16**（`pCCUsed=6190000::V6.19::ARMCLANG`）；
- `uvprojx` 34 个 include：**15 存在 / 19 不存在**（旧“按设备分目录”布局；Build 不受影响，待清理）；
- 新增 `docs/03-theory/k-matrix.md`（K 唯一事实源草案）；
- 新增 `tests/README.md`（Host/协议/日志回放占位）；
- `.gitignore` 补 `*.htm`、`*.build_log.htm`、`*.slxc`、`MathWorks/graphicsState.bin`、`.claude/`；
- 删除 Keil 生成的 `LegWheel.htm`、`LegWheel.build_log.htm`（Build 可再生）；
- 新增 `docs/00-plan/structure-audit-20261019.md`（结构审计：P0/P1/P2 findings + harness 评分卡）；
- 更新 AGENTS/README/build-and-flash/TODO-02/open-questions/roadmap 的编译状态与 include 信息。

### 待办

- TODO-02 的 6 个问题（是否允许改 `uvprojx`、CubeMX 工作流、VSCode/IntelliSense、compile_flags、烧录、ARMCLANG 唯一化）；
- K 来源（TODO-01）、can-protocol/state-machine、hardware-overview 更新。

---

## 2026-10-19 — S2 代码/仿真迁移

### 移动

- `codes-chassis/轮腿底盘控制代码/LegWheel/` → `firmware/LegWheel/`（含原 README）
- `codes-chassis/轮腿底盘LQR仿真/simulation/*` → `simulation/chassis-lqr/`（含原 README）
- `STRUCTURES.md` → `docs/02-architecture/hardware-overview.md`
- 删除空壳 `codes-chassis/`

### 验证

- pre/post manifest：7,092 → 7,091 行；映射后 **missing=0**；changed=1（`simulation/chassis-lqr/README.md` 占位被源 README 覆盖，预期）；
- `firmware/LegWheel/MDK-ARM/LegWheel/LegWheel.hex` 494,095 B；`archive/legacy/...` SHA-256 `c41529…1dd9ce`；
- 文档路径引用已更新（README/AGENTS/build-and-flash/system/roadmap 等）；
- 多智能体审计：t6 PASS、t7 PASS、t8 PASS（0 findings）；报告 `docs/00-plan/supervisor-review-s2.md`；
- 清理 7 项 / 28,087 B：`.slxc`、`MathWorks`、`.claude` 删除；K 头、`compile_flags.txt`、`_inc_list.txt`、`dji_motor.h` 移入 `archive/legacy/`；
- 清理后 final manifest：7,089 行 / 1,407,786,484 B；
- **Keil 风险**：114 个 `<FilePath>` 存在，但 19 个 include 目录失效（待修）；
- 迁移提交：`d03f9df`；tag `s2-migration`（最终记录 commit）。

### 未做

- Tier B 未删（按计划保留）；
- git commit/tag、Keil 编译验证均已完成（见下条审计记录）。

### 记录

- `archive/manifests/pre-s2-manifest-20261019.csv`
- `archive/manifests/post-s2-manifest-20261019.csv`
- `archive/manifests/final-s2-manifest-20261019.csv`
- `archive/manifests/S2-CLEANUP-20261019.csv`
- `archive/manifests/S2-MIGRATION-20261019.md`
- `docs/00-plan/supervisor-review-s2.md`

---

## 2026-10-19 — 工具链只读检查 + CubeMX 保留

### 用户决定

- **CubeMX 保留**：用于开发板初始化；后续新增/调用通信口可能还要用；
- 工具安装根：`C:\STM32+Vscode+Keil5`；**agent 只读**，不修改安装路径，只能浏览；
- 关于 CMake：用户表述与 CubeMX 初始化相关；实际本机未找到 CMake，待确认具体所指（CubeMX 工作流 / `LegWheel/build/` / 另一台机器）。

### 只读检查结果

| 工具 | 版本 |
|---|---|
| Keil µVision（UV4） | 5.38.0.0 |
| ARMCC | 5.06.0.189 |
| ARMCLANG | 16.0.0（LLVM 16） |
| STM32CubeMX | >6.17.0-RC5 |
| VS Code | 1.142.0 |
| ARM GNU GCC | 15.3.1 |
| Keil H7 DFP | 4.1.3 |
| Keil ARM_Compiler 包 | 1.7.2 |
| CMake | **未找到**（安装根/PATH/常见路径） |
| CubeMX 固件包 | 仅 F1 1.8.7；**H7 包缺失** |

### 结论/记录

- **2026-10-19 后续澄清**：用户确认 CMake 可能是理解错；`LegWheel/build/` **删除即可、不恢复**；CubeMX 仍保留；当前工作流按 **Keil 编译/烧录 + CubeMX 板级初始化** 记录，CMake 不启用。
- 未修改 `C:\STM32+Vscode+Keil5` 下任何文件；仅列目录/读版本/执行 `--version`；
- `.ioc`、`.mxproject`、Keil 工程、`archive/legacy/hex` 均保留；
- `LegWheel/build/`（CMake 生成物）已在 Tier A 删除；如需恢复，可从 S0 快照取（约 5 MB），但 cache 路径已失效；
- 更新 `AGENTS.md`（黄金原则 9 + 工具链）、`docs/02-architecture/build-and-flash.md`、`docs/00-plan/todo/02-build-entry.md`、`open-questions.md`、`README.md`；
- 未改代码/构建配置。

---

## 2026-10-19 — S1 结构骨架（新增目录/文档）

### 新增

- `AGENTS.md` — agent 入口 + 8 条黄金原则（含 Tier A 清理、旧车代码隔离）
- `README.md` — 重写；旧版存 `docs/01-product/legacy-readme-2026-10-19.md`
- `docs/00-governance/README.md`
- `docs/01-product/{README.md,overview.md,legacy-readme-2026-10-19.md}`
- `docs/02-architecture/{README.md,system.md,build-and-flash.md}`
- `docs/03-theory/README.md`
- `docs/04-parameters/{README.md,parameters.md}`
- `docs/05-experiments/{README.md,test-log-template.md}`
- `docs/06-plans/{README.md,roadmap.md}`
- `docs/07-decisions/{README.md,0001-hybrid-structure.md}`
- `docs/08-quality/{README.md,review-checklist.md}`
- `docs/09-references/{README.md,index.md}`
- `firmware/{README.md,gimbal/README.md}`
- `simulation/{README.md,chassis-lqr/README.md}`
- `hardware/{README.md,structure/README.md,electronics/README.md,wiring/README.md,bom/README.md}`
- `experiments/{README.md,logs/README.md,calibration/README.md,reports/README.md}`
- `tools/README.md`
- `archive/{README.md,manifests/README.md,legacy/README.md,snapshots/README.md,trash-20261019/README.md}`

### 变更

- `docs/00-plan/todo/06-git-baseline-deletion.md`：Tier A 已删；新增 §2.4 旧车代码后续移入流程（用户 2026-10-19 决定暂不提供、后续统一移入，避免干扰）。
- `docs/00-plan/open-questions.md`：P0-10/E8 状态更新（旧车代码暂不提供；远端暂不需要）。
- `docs/00-plan/todo/README.md`：06 状态更新。

### 未做

- 未移动 `firmware/LegWheel`、`simulation/chassis-lqr`（S2 待 P0）。
- 未删除 Tier B；未 push 远端。
- 未改控制代码/构建配置。

### 验证

- 链接检查：60 个 Markdown，0 坏链（本地相对链接）。
- 结构树：`docs/00–09`、`firmware/`、`simulation/`、`hardware/`、`experiments/`、`tools/`、`archive/` 均有 README。
- 旧 README 已归档；当前 README 可读。
- 修正：`docs/04-parameters/parameters.md` 质量预算口述值 0.55 的合计应为 **14.292**（原稿误写 13.992）；0.554 精确值仍为 14.300。

---

## 2026-10-19 — Tier A 删除（用户授权）

- 用户 2026-10-19 授权「删除所有的 Tier A」；S0 快照已存在，可回退。
- 共 **101 行（94 文件 + 7 空目录），414,476,633 B（395.3 MiB）**。
- 删除内容：`LegWheel/build/`、`MDK-ARM/*.uvguix.*`、`MDK-ARM/tmp/`、`.vscode` 日志、`simulation/slprj/`、上交重复 zip、0 B 占位（`ARCHITECTURE.md`/`docs/papers.md`/山海 lock）、7 个空目录。
- **保留**：`MDK-ARM/LegWheel/LegWheel.hex`（494,095 B，唯一 Keil 产物）、`uvprojx/uvoptx`、JLink 配置、DSP lib、Tier B 全部参考资料。
- 清单/回退：`archive/manifests/TIER-A-DELETION-20261019.csv` / `.md`；S0 快照可解包恢复。
- 记录：TODO-06、open-questions P0-11/F6、S0-BASELINE 已同步。

---

## 2026-10-19 — 用户决定（TODO-06）

- **远端**：暂时不需要；本地 git + 快照即可（以后要再加）。
- **git 范围**：文本-only + 全量快照（S0 已按此执行）。
- **Tier A/B 解释**补入 `docs/00-plan/todo/06-git-baseline-deletion.md` §2.2：
  - Tier A ≈414 MB：可重建/重复/无用的构建缓存与空文件；
  - Tier B ≈1.2 GB：大体积外部参考资料，保留不删、git 忽略；
  - Tier C：构建/文档必需，不动。
- **旧车代码/历史版本需求清单**补入 TODO-06 §2.3；工作区扫描未发现旧车代码，仅有厂商参考资料；待用户提供路径或确认“没有”。
- 未删除、未移动任何文件。

---

## 2026-10-19 — 用户待办文件夹 + S0 基线

### 新增：用户待办
- `docs/00-plan/todo/README.md` — 待办索引、状态图例、与 AI 协作提示词
- `docs/00-plan/todo/01-k-matrix.md` — P0-1/P0-2
- `docs/00-plan/todo/02-build-entry.md` — P0-3
- `docs/00-plan/todo/03-mass-parameters.md` — P0-4/P0-5
- `docs/00-plan/todo/04-wheel-track.md` — P0-6
- `docs/00-plan/todo/05-protocol-estop-state.md` — P0-7/P0-8/P0-9
- `docs/00-plan/todo/06-git-baseline-deletion.md` — P0-10/P0-11
- `docs/00-plan/todo/07-supplement-p0.md` — A1/A11/A12/C3/D3
- `docs/00-plan/todo/TEMPLATE.md`

### S0 基线（完成）
- **全量快照**：`archive/snapshots/snapshot-20261019.tar`，1,838,510,080 B，SHA-256 `6ac9cd8b…a75d075`，8,451 条目；排除 `archive/snapshots`、`.git`、`.agent-teams`。
- **manifest**：`archive/manifests/manifest-20261019.csv`，7,147 行，总字节 1,822,177,166；文本 + hex 记 SHA-256。
- **Keil 产物留档**：`archive/legacy/hex-2026-10-18/LegWheel.hex`，494,095 B，SHA-256 `c41529ff…1dd9ce`（与源文件一致）。
- **git 基线**：`main` 首次提交 `1d05ac4af853737431aab669c4b4277dbeef31ce`，tag `pre-structure-20261019`；770 个跟踪文件，pack 24.92 MiB。
- **`.gitignore`**：跟踪固件源码/必要 HAL/CMSIS/FreeRTOS/文档；忽略 `researchs/`、build/slprj/uvguix、DSP 的 GCC/IAR/其他 ARM 库（164 MB），只保留 `DSP/Lib/ARM/arm_cortexM7lfdp_math.lib`（2.1 MB）；`arm_math.h` 来自 `Middlewares/ST/ARM/DSP/Inc/`（已跟踪）。
- **记录**：`archive/manifests/S0-BASELINE.md`（快照/清单/回退命令）。
- **未做**：未删除/移动任何现有文件；未执行 S1/S2；Tier A 删除仍等 P0-11 授权。

### 验证
- `tar -tf` 退出码 0；快照关键文件存在、排除项不存在；hex 源/留档 SHA-256 一致。
- `git status` clean；`git check-ignore` 对 researchs/build/DSP 源码/GCC 库/源 hex 命中，对 DSP ARM lib / Middlewares arm_math.h / archive hex 不命中。
- 提交后 `git ls-files` 770；无 researchs/build/uvguix/zip/mp4/sldasm 被跟踪。

### 待办
- S0 报告与 `.gitignore` 细化将作为第二次提交（`docs: record S0 baseline`）；tag 保持在首次提交。
- Tier A 删除、旧车代码位置、远端、S1 是否执行，等用户决定。

---

## 2026-10-19 — 监管审阅后的修订（F1–F5）

### 新增（监管者）
- `docs/00-plan/supervisor-review.md` — t4 独立审阅报告，verdict=needs_revision（2 high / 2 medium / 1 low）
- `docs/00-plan/supervisor-review-2.md` — t5 二次审阅报告，verdict=pass（0 findings）

### 修订
- `structure-proposal.md`：
  - **F1**：S2 改为文件系统 `Move-Item` + `git add -A`（`git mv` 不会搬未跟踪的 hex）；新增 `LegWheel.hex` 留档行与 `archive/legacy/hex-2026-10-18/` 副本；S2 验证改为 manifest 前后对比（含 hex SHA-256/494,095 B）；`codes-chassis/` 空壳删除增加前置条件。
  - **F2**：`.gitignore` 改用迁移前/后都命中的 `**/` 模式；DSP 源码忽略、`DSP/Lib/**` 用否定规则保留；S0 增加 `git check-ignore -v` 验证（DSP 源码应忽略、`arm_cortexM7lfdp_math.lib` 不应忽略）。
  - **F3/F4**：P0 统一定义为 16 条（速答表 11 + 补充 5）；新增 P0-11（Tier A 删除授权）；补充 §1.1 与交叉引用；更新回答顺序。
  - **F5**：轮距行号改为 `Chassis.h:55`；A2 证据去掉卫语句 `Chassis.cpp:1549`。
- `open-questions.md`：同步上述 P0 编号/交叉引用/行号修正。
- `agent-execution-policy.md`：文档长度规则明确为“正文 ≤300 行（提案/ADR/附录/证据索引不计）”。
- 收尾：B7/E8/F2 补交叉引用（P0-9/P0-10），P0 计数说明同步。

### 验证
- 监管者 t4 的 18 条事实抽查全部通过；F1–F5 已逐条修订。
- 监管者 t5 二次审阅：verdict=pass，0 findings；F1–F5 逐条确认，另抽查 8 项新改动无矛盾。
- 未移动/删除/重命名任何现有文件；未改代码/构建配置。

### 待办
- t5 已 pass，本次文档交付完成。
- 后续 S0–S4 执行前，仍需用户回答 P0（速答 11 + 补充 5）并确认目录树/删除清单/git 范围。

---

## 2026-10-19 — 结构提案（仅新增文档，未动现有文件）

### 新增
- `docs/00-plan/structure-proposal.md` — 目标目录树、现状→目标映射、S0–S4 步骤、清理清单、git/回退方案、AGENTS.md 草案、README 重写大纲、验收标准
- `docs/00-plan/open-questions.md` — P0 速答表 + A–H 分类问题清单（参数/控制/构建/云台/资料/治理/未来/实验）
- `docs/00-plan/agent-execution-policy.md` — 时间盒、大文件规则、防截断交接、卡死判定、提示词模板、监管者职责
- `CHANGELOG.md` — 本文件

### 未做（明确边界）
- 未移动、删除、重命名任何现有文件/目录
- 未修改 `README.md`、`STRUCTURES.md`、`ARCHITECTURE.md`、`docs/papers.md`
- 未修改固件/仿真代码、构建配置、`.ioc`
- 未执行 git init、未生成快照、未 push

### 依据
- 根目录 `README.md`（今晚四步、对 AI 的要求）
- AgentTeams `lg-ai-process-structure` 的 t1（固件/构建）、t2（仿真/资料）、t3（监管审阅）
- Captain 定点复核：`Chassis.cpp:13`、`Chassis.h:52-55`、`vmc.cpp:22-23`、`lqr_coeffs.cpp:6/48`、`MDK-ARM/LegWheel.uvprojx:341/1153`、`MDK-ARM/LegWheel/LegWheel.hex`（494,095 B，2026-10-18 21:38）、`build/`（2026-10-02）、`LegWheel.ioc`（2026-08-27）vs `freertos.c`（2026-10-18）

### 验证
- 新增文件可读；文内相对链接指向 `docs/00-plan/` 内文件
- 现有文件未改动；工作区除新增 `docs/00-plan/` 与 `CHANGELOG.md` 外无变化
- 未运行构建/烧录（今晚不涉及）

### 回退
- 删除上述新增文件即可；现有文件未动，无需回退。
- 环境备注（非文件内容变更）：开工前修复了工作区根目录的 Windows 文件权限，报告与回滚脚本在 `D:\RM\dsh-acl-recovery-20261019\`。

### 下一步（待用户确认）
- 回答 `open-questions.md` 的 P0（至少 K 来源、构建入口、质量口径、轮距、协议、基线范围）
- 确认目标目录树、Tier A 删除清单、git 范围
- 之后按 S0 → S1 执行；S2 前另出迁移检查单
