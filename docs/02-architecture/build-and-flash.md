# 构建与烧录（Build & Flash）

> 最后更新：2026-10-19（S1）  
> 状态：**以 Keil 为当前事实入口**；CMake 为历史残留（已删除）；工具链版本/烧录步骤待确认（P0-3/C1/C2/C4）。

## 1. 当前唯一可用入口：Keil

| 项 | 值 |
|---|---|
| 工程 | `codes-chassis/轮腿底盘控制代码/LegWheel/MDK-ARM/LegWheel.uvprojx`（S2 后迁到 `firmware/LegWheel/`） |
| 器件 | STM32H723VGTx |
| 输出 | `MDK-ARM/LegWheel/LegWheel.hex` |
| 已知产物 | 494,095 B，2026-10-18 21:38；S0 已留档 `archive/legacy/hex-2026-10-18/LegWheel.hex` |
| Keil / ARM Compiler / 器件包版本 | **TBD**（需你确认，P0-3/C2） |
| 烧录 | DAPLink 无线 / ST-Link（步骤 TBD，C4） |

### 构建步骤（待你确认后补齐细节）

1. 关闭占用（Keil 会锁文件）；
2. 打开 `LegWheel.uvprojx`；
3. `Build`（或 `Rebuild`）；
4. 确认生成 `MDK-ARM/LegWheel/LegWheel.hex`；
5. 用 DAPLink/ST-Link 烧录；烧录后先台架验证（轮子离地、限流）。

> **不要**为了“清爽”删除 `MDK-ARM/LegWheel/LegWheel.hex`；它是当前唯一已知可用的构建产物。

## 2. CMake / CLion：历史残留，不要依赖

| 事实 | 证据 |
|---|---|
| `build/` 是 2026-10-02 的 CMake 产物（elf/hex/bin） | `build/CMakeCache.txt`、文件时间 |
| 工程根**没有** `CMakeLists.txt` | 全仓库只在 CMSIS/DSP 厂商目录有 |
| `compile_flags.txt` 指向 `d:\RM-electro-control\...` | `compile_flags.txt` |
| `_inc_list.txt` 指向 `D:/Github/Transistor-Wheeled-Legged-Robot/software` | `_inc_list.txt` |
| `build/` 已在 Tier A 删除 | `archive/manifests/TIER-A-DELETION-20261019.*` |

结论：**CMake 目前不可复现**；如果以后要 CI/CLion，需要重建顶层 `CMakeLists.txt` + toolchain 文件（单独任务）。

## 3. `.ioc` 警告

- `LegWheel.ioc` 停在 **2026-08-27**；`Core/Src/freertos.c` 已改到 **2026-10-18**；
- 直接 CubeMX 重新生成会覆盖用户代码（FreeRTOS 任务、外设初始化等）；
- 结论：**不要直接重新生成**。若必须用 CubeMX，先在副本上生成、再人工合并，并记录到 CHANGELOG。

## 4. 仿真（MATLAB）

| 项 | 值 |
|---|---|
| 当前路径 | `codes-chassis/轮腿底盘LQR仿真/simulation/`（S2 后到 `simulation/chassis-lqr/`） |
| 关键脚本 | `k_calc_chuan_real2.m`、`Variables_and_Equations.m`、`Linear_and_CalcMatrix.m`、`Calc_K_and_fit.m`、`Leg_data.m` |
| K 链路/来源 | 三份候选未定，见 [TODO-01](../00-plan/todo/01-k-matrix.md) |
| 限制 | `.slx`/`.mat` 是二进制，agent 不能直接读；需要你导出/截图 |

## 5. 调试观测

- VOFA：13 路 JustFloat，115200；`VofaTask` 5 ms（约 110 Hz）；
- 串口/无线：DAPLink 串口可发数据给上位机；
- 后续日志放 `experiments/logs/`（预留）。

## 6. 验证清单（每次构建/烧录）

- [ ] Keil Build 无错误；警告数记录；
- [ ] hex 大小/时间更新；
- [ ] 烧录后能进 NORMAL，IMU 姿态合理；
- [ ] 遥控通道方向/量程正确；
- [ ] 急停有效（台架，轮子离地）；
- [ ] 变更写入 `CHANGELOG.md`。

## 7. 待确认（P0-3/C1/C2/C4/C5）

1. 你实际用 Keil 还是 CMake/CLion？
2. Keil/ARM Compiler/器件包版本？
3. 烧录用 DAPLink 无线还是 ST-Link？具体步骤？
4. 是否需要修复 `compile_flags.txt` / `_inc_list.txt` 的旧绝对路径？
5. `build/` 是否需要以新方式重建（CI）？

> 以上未确认前，不要改构建配置；只记录。见 [TODO-02](../00-plan/todo/02-build-entry.md)。
