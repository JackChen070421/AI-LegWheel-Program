# AGENTS.md — 轮腿平衡步兵项目

> 本文件是 agent 的**唯一入口**：先读这里，再按“先读什么”进入 `docs/`。  
> 最后更新：2026-10-25（新增 `SHORTCUT.md` 指令规范；上次结构变更 S2 = 2026-10-19）。项目根：`D:\RM\LG-AI-process`。

## 0. 黄金原则（Golden Principles）

1. **先快照，后改动**：任何删除、迁移、重构前必须有快照或 git 提交；删除清单写进 `CHANGELOG.md`，并能从 `archive/manifests/` 回退。
2. **Tier A 不留在工作区**：可再生的 `build/`、`*.uvguix.*`、`slprj/`、`tmp/`、日志、重复文件、空文件，发现即清理；不提交、不长期保留（2026-10-19 已删除一批，见 `archive/manifests/TIER-A-DELETION-20261019.*`）。
3. **参考资料隔离**：旧车代码、历史版本、外部项目统一放 `archive/legacy/` 或 `researchs/`；未确认前**不并入当前工作区**，避免干扰主线。当前旧车代码尚未提供（见 `docs/00-plan/todo/06-git-baseline-deletion.md`）。
4. **单一事实源**：参数看 `docs/04-parameters/parameters.md`；K 矩阵看 `docs/03-theory/k-matrix.md`（草案）；构建看 `docs/02-architecture/build-and-flash.md`。其他文档只链接，不复制数值。
5. **不编造数据**：每个数值/结论给 `path:line`、实测日期/条件，或注明“用户口述 + 日期”；不确定写 `TBD` 并进 `docs/00-plan/open-questions.md`。
6. **`researchs/` 只读**：不修改、不移动、不删除；需要引用时给路径。Tier B 大资料保留但 git 忽略。
7. **小步提交**：一次一件事；结构变更写 ADR（`docs/07-decisions/`）；每次改动写 `CHANGELOG.md`。
8. **安全优先**：急停、电机、电源、云台联调相关改动必须先台架验证（轮子离地/限流），不直接上实车。
9. **工具安装目录只读**：`C:\STM32+Vscode+Keil5` 只允许浏览（列目录/读版本），**不修改、不移动、不写**；Keil/CubeMX/VSCode 的安装/升级/配置由你操作。

## 1. 项目一句话

RoboMaster 轮腿平衡步兵：底盘（STM32H723 + FreeRTOS + 1 kHz 控制环 + 7 状态机）+ 未来云台（板1）。当前处于“新车参数更新、旧代码适配”阶段；旧车已拆，新车已装底盘/布线，未装气弹簧和云台。

## 2. 先读什么（按顺序）

> **收到用户指令的第一步：查 [`SHORTCUT.md`](SHORTCUT.md)** —— 命中已登记的 `SC`（当前仅 `SC-01` 提交到仓库）即视为已授权，直接执行对应代码，不再反问流程；未命中走常规流程。

1. `README.md` — 项目现状与快速开始；
2. `docs/01-product/overview.md` — 目标、阶段、验收；
3. `docs/02-architecture/system.md` — 硬件/软件/控制/通信结构；
4. `docs/04-parameters/parameters.md` — 唯一参数台账（已知/待测/来源）；
5. 本次任务相关的 `docs/03-theory/`、`docs/05-experiments/`、`docs/02-architecture/build-and-flash.md`；
6. 有阻塞先看 `docs/00-plan/open-questions.md` 与 `docs/00-plan/todo/`。

## 3. 目录地图（当前状态）

| 路径 | 内容 | 状态 |
|---|---|---|
| `firmware/LegWheel/` | 底盘固件（Keil 工程） | **已迁入（S2, 2026-10-19）** |
| `firmware/gimbal/` | 未来云台固件（板1） | 预留 |
| `simulation/chassis-lqr/` | MATLAB/Simulink LQR 链路 | **已迁入（S2, 2026-10-19）** |
| `docs/` | 所有文档（中文内容，英文目录/文件名） | 已建 00–09 骨架 |
| `researchs/` | 外部参考/厂商资料（只读） | 原地保留；索引在 `docs/09-references/index.md` |
| `hardware/` | 我们自己的结构/电气/BOM/接线 | 预留 |
| `experiments/` | 实测日志、标定、报告 | 预留 |
| `tests/` | Host 单元测试/协议测试/日志回放 | 预留 |
| `tools/` | 构建/烧录/日志解析/文档抽取脚本 | 预留 |
| `archive/` | 快照、legacy、Tier A 记录 | 已有 S0 快照与删除记录 |

## 4. 事实源与构建

- **参数**：`docs/04-parameters/parameters.md`。用户已确认：整车 14.3 kg、单轮 0.55 kg；其余见文档。
- **K 矩阵**：当前固件读 `lqr_coeffs.cpp`；另有孤儿副本/仿真副本，**来源未定**（P0-1/2，见 TODO-01）。未确认前不要改 K。
- **构建**：Keil MDK 5.38（UV4；工程实际用 **ARMCLANG V6.19 / LLVM 16**，`pCCUsed=6190000::V6.19::ARMCLANG`）`firmware/LegWheel/MDK-ARM/LegWheel.uvprojx`；唯一已知产物 `firmware/LegWheel/MDK-ARM/LegWheel/LegWheel.hex`（494,095 B）。**Keil Build 已由用户验证通过（2026-10-19）**。
- **本机工具链（2026-10-19 只读检查）**：安装根 `C:\STM32+Vscode+Keil5`（只读）：Keil 5.38、ARM Compiler 6.19（ARMCLANG/LLVM 16）、STM32CubeMX >6.17.0-RC5、VS Code 1.142；ARM GNU GCC 15.3.1 在 `C:\Program Files (x86)\Arm\...`；**CMake 未在安装目录/PATH 找到**。
- **CubeMX**：用于板级初始化；后续新增通信口可能再用；`.ioc`/`.mxproject` 保留。但 `.ioc` 已漂移（08-27 vs freertos 10-18），**不要直接重新生成**；本机 CubeMX 只有 F1 固件包，H7 包缺失。
- **CMake**：未安装/不启用（用户 2026-10-19 确认可能理解错；`build/` 删除即可、不恢复）；当前以 Keil + CubeMX 为准。
- **仿真**：MATLAB/Simulink，`simulation/chassis-lqr/`。
- **调试观测**：VOFA 13 路、115200（以代码为准）。

## 5. 修改规则

- 改代码必须：说明改了哪几行、为什么、如何验证；不能验证就标“未验证”。
- 不移动/删除 `researchs/`；不删除任何文件，除非有快照 + 用户明确授权。
- 不修改工作区外文件；**推送远端只在命中 [`SHORTCUT.md`](SHORTCUT.md) 的 `SC-01`（提交到仓库 → push + PR 链接）时执行**，其余情况不 push（用户 2026-10-25 授权变更，见 `CHANGELOG.md`）。
- 不把大二进制（视频/3D/例程/zip）提交进 git；遵守 `.gitignore`。
- 文档改动：每个数值给来源；相对链接可点；单文档正文 ≤300 行（提案/ADR/附录不计）。
- **日期必须实测**：写"今天/本次"的日期前先跑 `Get-Date`，**不得沿用上一条 CHANGELOG 或旧文档里的日期**（2026-10-25 曾因此误记 10-19）。
- **`CHANGELOG.md` 倒序**：最新在上；同一日期内，后发生的写在上方。
- 旧车/外部代码要并入时，先放 `archive/legacy/` 并在 TODO-06 记录，不要直接混入 `firmware/`。

## 6. 当前 P0 与待办

- `docs/00-plan/open-questions.md`：16 条 P0（速答 11 + 补充 5）。
- `docs/00-plan/todo/`：逐项解决的用户待办（K 来源、构建入口、质量口径、轮距、协议/急停/状态、基线/删除、补充 P0）。
- 当前建议顺序：先 06/02（不依赖测量）→ 01 → 03 → 04 → 05 → 07。

## 7. 交付格式

```text
改了什么 / 验证了什么 / 证据（path:line）/ 未决问题 / 下一步
```

> 如果发现本文与代码/实测冲突：以证据为准，先改文档并在 `CHANGELOG.md` 记录；不要静默改代码。
