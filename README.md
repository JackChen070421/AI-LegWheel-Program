# 轮腿平衡步兵（RoboMaster）— 项目总览

> 项目根：`D:\RM\LG-AI-process`　最后更新：2026-10-19（S2 迁移完成）  
> 给 AI/新同学：先读 [`AGENTS.md`](AGENTS.md)；参数以 [`docs/04-parameters/parameters.md`](docs/04-parameters/parameters.md) 为准。

## 1. 一句话

RoboMaster 轮腿平衡步兵：两条腿 + 两个驱动轮，靠 LQR/VMC 保持平衡与运动；未来加云台（板1）与气弹簧。当前是“新车硬件更新、旧代码适配”阶段。

## 2. 当前阶段

- 新车：底盘装完、布线完成；**尚未装气弹簧、云台**；
- 旧车：已拆；旧车代码/历史版本**暂未并入**（等后续统一移入，见 [TODO-06](docs/00-plan/todo/06-git-baseline-deletion.md)）；
- 固件：基于旧版底盘代码，已改轮重/车重并重算过 K；但仓内存在**三份 K 候选**，生效来源待确认（P0-1/2）；
- 云台：代码已有 `Cloud` 与 `board_comm` 骨架，硬件未做；`BOARD_COMM_GIMBAL_PRESENT=0`，板间通信“只收不发”。

## 3. 硬件一览

| 部件 | 当前配置 | 备注 |
|---|---|---|
| 主控（板2） | DM-MC02 / STM32H723VGTx | 资料在 `researchs/hardwares/DM-MC02/` |
| 关节电机 | 4 × DM-8009P | 具体型号/减速比待确认（A11） |
| 驱动轮电机 | 2 × M3508 + C620 | 代码里只有左右 2 个轮电机 |
| IMU | 固件支持 DM IMU / N100 | 实车用哪个、安装位置待确认（A12） |
| 遥控 | SBUS 接收机（ET16S） | 当前控制入口 |
| 烧录/调试 | DAPLink 无线 + VOFA | 资料在 `researchs/hardwares/Daplink/` |
| 供电 | 电池 → 继电器 → 分电板 | 调试期继电器用于安全 |
| 重量 | 底盘总重 **14.3 kg**；单轮 **0.55 kg** | 用户 2026-10-19 口述；其余待测 |

> 结构/接线旧描述已迁入 [`docs/02-architecture/hardware-overview.md`](docs/02-architecture/hardware-overview.md)。

## 4. 软件结构（摘要）

- **控制环**：FreeRTOS，`ControlLoopTask` 1 kHz：INS → 观测器 → `Chassis.Controller()` → 电机下发 → SDM02（仅起跳压缩段）；
- **状态机**：NORMAL / RECOVERING / JUMPING / JOINT_DEBUG / ESTOP / STEP_UP / SPIN；
- **算法**：LQR（4×10 实时 K，40×6 拟合系数）+ VMC + LESO + 卡尔曼/四元数 EKF；
- **通信**：CAN1 关节、CAN2 轮/云台预留、CAN3 板间；USART 接 IMU/遥控/VOFA；
- 详细结构与证据见 [`docs/02-architecture/system.md`](docs/02-architecture/system.md)。

## 5. 快速开始

### 编译 / 烧录（Keil）

> 本机工具（2026-10-19 只读检查）：Keil MDK 5.38 + STM32CubeMX >6.17 + VS Code 1.142 + ARM GNU GCC 15.3；安装根 `C:\STM32+Vscode+Keil5`（**只读**）。CMake 未安装/不启用；`build/` 已删（删除即可，不恢复）。CubeMX 用于板级初始化、保留 `.ioc`；不要直接重新生成。

1. 打开 `firmware/LegWheel/MDK-ARM/LegWheel.uvprojx`；
2. Build；产物在 `MDK-ARM/LegWheel/LegWheel.hex`（S0 已留档 494,095 B）；
3. 烧录：DAPLink 无线 / ST-Link（具体步骤待补，见 build 文档）。

**注意**：
- CMake 未安装/不启用；`build/` 已删除（用户 2026-10-19 确认删除即可，不恢复）；
- `.ioc` 停在 2026-08-27，`freertos.c` 已改到 2026-10-18；**不要直接重新生成**，会覆盖用户代码；CubeMX 保留（后续加通信口可能用），但本机只有 F1 固件包，H7 包缺失；
- 详见 [`docs/02-architecture/build-and-flash.md`](docs/02-architecture/build-and-flash.md)。

### 仿真（MATLAB）

当前在 `simulation/chassis-lqr/`。LQR 链路与三份 K 候选见 [TODO-01](docs/00-plan/todo/01-k-matrix.md)。

### 调试观测

VOFA 13 路、115200（以代码为准）；日志/标定以后放 `experiments/`。

## 6. 目录导航（S2 已完成）

| 路径 | 内容 |
|---|---|
| `firmware/LegWheel/` | 底盘固件（Keil 工程） |
| `firmware/gimbal/` | 云台固件（预留） |
| `simulation/chassis-lqr/` | MATLAB/Simulink LQR 链路 |
| `researchs/` | 外部参考/厂商资料（只读，原地） |
| `docs/` | 文档中心（00–09） |
| `hardware/`、`experiments/`、`tools/`、`archive/` | 硬件/实验/工具/快照（新建/预留） |

## 7. 文档地图

| 文档 | 用途 |
|---|---|
| [`AGENTS.md`](AGENTS.md) | agent 入口 + 黄金原则 |
| [`docs/01-product/overview.md`](docs/01-product/overview.md) | 目标、阶段、验收 |
| [`docs/02-architecture/system.md`](docs/02-architecture/system.md) | 软硬件/控制/通信结构 |
| [`docs/04-parameters/parameters.md`](docs/04-parameters/parameters.md) | 参数台账（唯一事实源） |
| [`docs/00-plan/open-questions.md`](docs/00-plan/open-questions.md) | 16 条 P0 问题清单 |
| [`docs/00-plan/todo/`](docs/00-plan/todo/README.md) | 逐项解决的待办 |
| [`docs/09-references/index.md`](docs/09-references/index.md) | 外部资料索引 |
| [`CHANGELOG.md`](CHANGELOG.md) | 变更/回退记录 |

## 8. 当前 P0（摘要）

1. K 矩阵生效来源与生成链（P0-1/2）；
2. 唯一构建入口/工具链（P0-3）；
3. 14.3 kg 口径 + `0.788` vs `1.067`（P0-4/5）；
4. 轮距定义与三种用法（P0-6）；
5. `BOARD_PROTOCOL.md`、急停、状态映射（P0-7/8/9）；
6. 旧车代码位置（P0-10，远端暂不需要）；Tier A 已删、Tier B 保留（P0-11）。

完整清单与状态见 [`docs/00-plan/open-questions.md`](docs/00-plan/open-questions.md)。

## 9. 变更与回退

- git：`main`；基线 tag `pre-structure-20261019`（S0）、`s0-baseline`；
- 全量快照：`archive/snapshots/snapshot-20261019.tar`（1.71 GiB，SHA-256 见 [S0-BASELINE](archive/manifests/S0-BASELINE.md)）；
- Tier A 删除记录：`archive/manifests/TIER-A-DELETION-20261019.*`；
- 变更记录： [`CHANGELOG.md`](CHANGELOG.md)。

## 10. 参考与许可

- 上海交大交龙战队 2023 平衡步兵开源（文档/视频）：`researchs/codes/上海交大开源/`（仅学习参考，未经允许不得商用）；
- 山海机甲开源（底盘/云台代码）：`researchs/codes/山海机甲开源/`；
- 知乎《RoboMaster 平衡步兵机器人控制系统设计》：`researchs/papers/`；
- DM-MC02 板卡资料/例程：`researchs/hardwares/DM-MC02/`；
- 以上资料**只读**，不改、不移动、不提交进 git（大文件已忽略）。
