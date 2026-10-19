# 构建与烧录（Build & Flash）

> 最后更新：2026-10-19（工具链只读检查）  
> 状态：**Keil + CubeMX 为当前事实工作流**；CMake 未安装/不启用（用户 2026-10-19）；烧录步骤待确认（C4）。  
> 安装根 `C:\STM32+Vscode+Keil5` **只读**：只浏览/读版本，不修改、不移动、不写（AGENTS.md 黄金原则 9）。

## 1. 本机工具链（2026-10-19 只读检查）

| 工具 | 路径 | 版本 | 用途/备注 |
|---|---|---|---|
| Keil µVision | `C:\STM32+Vscode+Keil5\MDK\Core\UV4\UV4.exe` | **5.38.0.0** | 编译/烧录入口 |
| ARMCC | `...\MDK\Core\ARM\ARMCC\bin\armcc.exe` | 5.06.0.189 | 旧编译器；工程可能用 ARMCLANG |
| ARMCLANG | `...\MDK\Core\ARM\ARMCLANG\bin\armclang.exe` | 16.0.0（LLVM 16） | AC6 编译器 |
| STM32CubeMX | `...\STM32CubeMx\Core\STM32CubeMX.exe` | **>6.17.0-RC5** | 板级初始化/外设配置；`.ioc` 保留 |
| VS Code | `...\VScode\Core\Code.exe` | 1.142.0 | 编辑器/Keil Assistant（待确认） |
| ARM GNU GCC | `C:\Program Files (x86)\Arm\GNU Toolchain mingw-w64-i686-arm-none-eabi\bin\arm-none-eabi-gcc.exe` | **15.3.1** | 不在安装根；CMake 旧 cache 指向 15.2（失效） |
| CMake | **未找到** | — | 安装根/PATH/常见路径均无；`build/` 旧 cache 指向 `C:/msys64`、`C:/Program Files/toolchain/...`（不存在） |
| Keil H7 器件包 | `...\MDK\Packs\Keil\STM32H7xx_DFP` | 4.1.3 | STM32H7 支持 |
| Keil ARM_Compiler 包 | `...\MDK\Packs\Keil\ARM_Compiler` | 1.7.2 | 编译器包 |
| CubeMX 固件包 | `...\STM32CubeMx\Packs` | 仅 F1 1.8.7 | **H7 固件包缺失**；用 CubeMX 配 H7 前需你安装 |

> 安装/升级/配置由你操作；agent 只读。不要为了让 agent “能编译”去改安装目录。

## 2. Keil（当前编译入口）

| 项 | 值 |
|---|---|
| 工程 | `firmware/LegWheel/MDK-ARM/LegWheel.uvprojx` |
| 器件 | STM32H723VGTx；H7 DFP 4.1.3 |
| 编译器 | ARMCC 5.06 / ARMCLANG 16（工程实际用哪个待确认） |
| 输出 | `MDK-ARM/LegWheel/LegWheel.hex` |
| 已知产物 | 494,095 B，2026-10-18 21:38；S0 已留档 `archive/legacy/hex-2026-10-18/LegWheel.hex` |
| 烧录 | DAPLink 无线 / ST-Link（步骤 TBD，C4） |

### 构建步骤（待你确认后补齐细节）

1. 关闭占用（Keil 会锁文件）；
2. 打开 `LegWheel.uvprojx`（可经 VSCode Keil Assistant，实际编译仍由 UV4 完成）；
3. `Build`（或 `Rebuild`）；
4. 确认生成 `MDK-ARM/LegWheel/LegWheel.hex`；
5. 用 DAPLink/ST-Link 烧录；烧录后先台架验证（轮子离地、限流）。

> **不要**删除 `MDK-ARM/LegWheel/LegWheel.hex`；它是当前唯一已知可用的构建产物。

## 3. CubeMX（板级初始化；保留）

- 用户 2026-10-19：**CubeMX 用于开发板初始化，后续新增通信口可能还要用，保留**；
- 版本 >6.17.0-RC5；`.ioc`、`.mxproject` 保留；
- **本机 CubeMX 只有 F1 固件包**；H7 固件包缺失。若要用 CubeMX 重新配 H7，需要先安装 `STM32Cube_FW_H7`（你操作，安装目录只读）；
- `.ioc` 停在 2026-08-27，`freertos.c` 已改到 2026-10-18；**不要直接重新生成**，会覆盖用户代码。若必须用：先在副本上生成，再人工合并，并记录到 CHANGELOG；
- CubeMX 生成工程类型（Keil/CMake）与“是否还在用 CubeMX 改外设”待确认（C3）。

## 4. CMake（现状：未找到，不可复现）

| 事实 | 证据 |
|---|---|
| 安装根/PATH/常见路径均无 `cmake.exe` | 2026-10-19 只读检查 |
| `build/` 是 2026-10-02 的 CMake 产物（elf/hex/bin） | 文件时间；已在 Tier A 删除 |
| CMakeCache 指向 `C:/Program Files/toolchain/arm-gnu-toolchain-15.2...`、`C:/msys64/usr/bin/make.exe` | `build/CMakeCache.txt`（已删，S0 快照有） |
| 工程根**没有** `CMakeLists.txt` | 全仓库只在 CMSIS/DSP 厂商目录有 |
| `compile_flags.txt` 原指向 `d:\RM-electro-control\...` | 已归档 `archive/legacy/stale-configs/compile_flags.txt`（2026-10-19，路径失效） |
| `_inc_list.txt` 原指向 `D:/Github/Transistor-Wheeled-Legged-Robot/software` | 已归档 `archive/legacy/stale-configs/_inc_list.txt`（2026-10-19，路径失效） |
| Keil `uvprojx` 的 114 个 `<FilePath>` 都存在，但 **19 个 include 目录不存在** | 2026-10-19 迁移审计（旧“按设备分目录”布局）；编译前需修 include 路径（TODO-02/C5） |

结论：**CMake 未安装/不启用**；`LegWheel/build/` 已在 Tier A 删除，用户 2026-10-19 确认**删除即可、不恢复**。当前以 Keil + CubeMX 为准；如果以后真的要用 CMake/CLion，再单独开任务（安装 + 重建顶层 `CMakeLists.txt` + toolchain）。

## 5. 仿真（MATLAB）

| 项 | 值 |
|---|---|
| 当前路径 | `simulation/chassis-lqr/`（S2 已迁入） |
| 关键脚本 | `k_calc_chuan_real2.m`、`Variables_and_Equations.m`、`Linear_and_CalcMatrix.m`、`Calc_K_and_fit.m`、`Leg_data.m` |
| K 链路/来源 | 三份候选未定，见 [TODO-01](../00-plan/todo/01-k-matrix.md) |
| 限制 | `.slx`/`.mat` 是二进制，agent 不能直接读；需要你导出/截图 |

## 6. 调试观测

- VOFA：13 路 JustFloat，115200；`VofaTask` 5 ms（约 110 Hz）；
- 串口/无线：DAPLink 串口可发数据给上位机；
- 后续日志放 `experiments/logs/`（预留）。

## 7. 验证清单（每次构建/烧录）

- [ ] Keil Build 无错误；警告数记录；
- [ ] hex 大小/时间更新；
- [ ] 烧录后能进 NORMAL，IMU 姿态合理；
- [ ] 遥控通道方向/量程正确；
- [ ] 急停有效（台架，轮子离地）；
- [ ] 变更写入 `CHANGELOG.md`。

## 8. 待确认（P0-3/C1/C2/C3/C4）

1. 实际编译是 Keil UV4，还是 VSCode/Keil Assistant 触发？工程用 ARMCC 还是 ARMCLANG？
2. 烧录用 DAPLink 无线还是 ST-Link？步骤？
3. **CMake 已澄清（2026-10-19）**：可能是理解错；`build/` 删除即可、不恢复；CMake 未安装/不启用。以后真要用再单独开任务。
4. CubeMX 是否继续用于新增通信口？H7 固件包是否要安装（你操作）？
5. 是否需要修复 `archive/legacy/stale-configs/compile_flags.txt` / `_inc_list.txt` 并放回（或改为相对路径）？

> 以上未确认前，不改构建配置；只记录。见 [TODO-02](../00-plan/todo/02-build-entry.md)。
