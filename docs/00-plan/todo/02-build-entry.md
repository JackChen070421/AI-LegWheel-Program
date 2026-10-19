# TODO-02 · 构建入口与工具链（Keil / CubeMX / CMake）

> 状态：✅ include 清理 + Build 复验通过；⏳ VSCode 配置/烧录/`compile_flags` 待做　优先级：P0　负责人：你 + AI  
> 对应：`open-questions.md` P0-3、C1、C2、C3、C4、C5、C6  
> 关联：[`docs/02-architecture/build-and-flash.md`](../../02-architecture/build-and-flash.md)

## 1. 要解决的问题

1. **P0-3**：编译/烧录的事实入口是什么（Keil / CubeMX / CMake / VSCode）？
2. 工具链版本、路径、烧录步骤？
3. **CubeMX 保留怎么用**：后续加通信口时怎么改 `.ioc` 而不覆盖用户代码？
4. `build/`（CMake 产物）是否需要恢复？
5. 旧绝对路径（`compile_flags.txt`、`_inc_list.txt`，已归档到 `archive/legacy/stale-configs/`）是否要重生成/放回？

## 2. 为什么现在要解决

- Keil 有最新 hex（2026-10-18 21:38，494,095 B），CMake 产物停在 2026-10-02；
- 工程根没有 `CMakeLists.txt`，`build/` 是历史残留；
- `.ioc` 停在 08-27，`freertos.c` 已到 10-18；直接 CubeMX 重新生成会覆盖用户代码；
- 结构迁移（S2）前必须知道“什么不能碰”，否则可能把唯一可复现的构建配置弄丢。

## 3. 用户已说明（2026-10-19）

- **CubeMX 要保留**：用于开发板初始化；后续如果新增/调用通信口，可能还要用 CubeMX；
- 工具安装根：`C:\STM32+Vscode+Keil5`；
- **agent 只读**：不要修改安装路径，只能浏览（已写入 AGENTS.md 黄金原则 9）；
- 关于 “CMake”：你的表述是“CubeMX 设置开发板初始化的时候用的”；实际检查**未在本机找到 cmake.exe**（详见 §4）。
- **2026-10-19 后续澄清**：你确认可能是理解错了，`firmware/LegWheel/build/` **删除即可，不恢复**；CubeMX 仍保留。当前工作流按 **Keil 编译/烧录 + CubeMX 板级初始化** 记录；CMake 记为“未安装/不启用”，以后真要用再单独开任务。

## 4. 目前已知（2026-10-19 只读检查）

| 事实 | 证据/值 |
|---|---|
| Keil µVision | `C:\STM32+Vscode+Keil5\MDK\Core\UV4\UV4.exe`，**5.38.0.0** |
| ARMCC | 5.06.0.189 |
| ARMCLANG | ARM Compiler **6.19** / LLVM 16（`pCCUsed=6190000::V6.19::ARMCLANG`） |
| Keil H7 器件包 | `STM32H7xx_DFP` 4.1.3 |
| Keil ARM_Compiler 包 | 1.7.2 |
| STM32CubeMX | `...\STM32CubeMx\Core\STM32CubeMX.exe`，**>6.17.0-RC5** |
| VS Code | 1.142.0 |
| ARM GNU GCC | `C:\Program Files (x86)\Arm\GNU Toolchain mingw-w64-i686-arm-none-eabi\...`，**15.3.1** |
| CMake | **未找到**（安装根/PATH/常见路径都没有） |
| CubeMX 固件包 | 本机只有 `STM32Cube_FW_F1_V1.8.7`；**H7 包缺失** |
| 工程 | `MDK-ARM/LegWheel.uvprojx`；`CreateHexFile=1`；hex 494,095 B / 10-18 |
| `.ioc` 漂移 | `LegWheel.ioc` 2026-08-27 vs `freertos.c` 2026-10-18 |
| 旧路径（已归档） | `archive/legacy/stale-configs/compile_flags.txt` → `d:\RM-electro-control\...`；`_inc_list.txt` → `D:/Github/...` |
| Keil include 目录 | **34 → 15**：已删除 19 条失效（2026-10-19）；**Build 复验成功** | 备份 `archive/legacy/config-backups/LegWheel.uvprojx-20261019.bak` |
| Keil Build | ✅ 原配置可编译；✅ 清理后再次 Build 成功（2026-10-19） | 用户口述 |
| `build/` | 2026-10-02 的 CMake 产物；Tier A 已删；可在 S0 快照中恢复（5 MB），但 cache 指向已不存在的 `C:/Program Files/toolchain/...`、`C:/msys64` |

## 5. 可选方案

| 方案 | 做法 | 代价/风险 |
|---|---|---|
| **A. Keil 编译 + CubeMX 管初始化**（推荐） | Keil UV4 编译/烧录；CubeMX 只改 `.ioc` 的板级/外设，生成后在副本上人工合并；CMake 暂不使用 | 换机需装 Keil + H7 DFP；CubeMX 需 H7 固件包；要严格“副本生成”纪律 |
| **B. 只用 Keil** | 不动 CubeMX；新通信口手工改 `Core/` 初始化 | 最稳；但改外设易错，后续维护差 |
| **C. CMake/CLion** | 安装 CMake，重建顶层 `CMakeLists.txt` + toolchain | 本机无 CMake；工作量大；需与 Keil 验证 hex 一致 |
| **D. 恢复 build/** | 从 S0 快照恢复 `firmware/LegWheel/build/` | **用户 2026-10-19 确认不需要**：删除即可，不恢复 |

## 6. 要回答它，需要做什么

1. **Keil Build 已确认通过（2026-10-19）**：日常是直接开 Keil，还是 VSCode/Keil Assistant 触发 UV4？（编译器已确认 ARMCLANG 6.19）
2. 确认烧录方式（DAPLink 无线 / ST-Link / JLink）与步骤；
3. **CMake 已澄清（2026-10-19）**：可能是理解错；`firmware/LegWheel/build/` 删除即可、不恢复；CMake 未安装/不启用。以后真要用再单独开任务。
4. 若继续用 CubeMX 改 H7 外设：需要安装 **STM32Cube_FW_H7**（你操作；安装目录只读）；并约定“先复制 `.ioc`/工程到临时目录生成，再人工合并”的流程。
5. 决定是否修 `archive/legacy/stale-configs/compile_flags.txt`/`_inc_list.txt`（或只记录、不改），以及是否修 Keil 的 19 个失效 include 目录。

### 6.1 需要你确认（阻塞我动手）

1. **✅ 允许直接改 `uvprojx` 并已完成**：删除 19 条失效 include（保留 15 条）；备份在 `archive/legacy/config-backups/`；**Build 复验成功**。
2. **✅ CubeMX 工作流选 B**：只在副本上生成代码，手动合并；**不直接用 CubeMX 覆盖当前 `uvprojx`/工程**。
3. **✅ VSCode：用，打开 `firmware/LegWheel`**。下一步：在 `firmware/LegWheel/.vscode/c_cpp_properties.json` 生成当前路径配置；旧的 `MDK-ARM/.vscode`（指向 `d:\RM\27-transistor-codes...`）归档/删除。
4. **`compile_flags.txt`/`_inc_list.txt` 是否重生成**（给 clangd/IntelliSense）？还是保持归档？
5. **烧录方式**：DAPLink 无线 / ST-Link / JLink？不影响 include 清理，但 TODO-02 闭环需要。
6. **编译器确认**：工程实际是 ARMCLANG 6.19；以后是否只维护 ARMCLANG（不再管 ARMCC 5.06）？

### 6.2 拟保留的 15 条 include（删除 19 条后）

```text
../Core/Inc
../Drivers/STM32H7xx_HAL_Driver/Inc
../Drivers/STM32H7xx_HAL_Driver/Inc/Legacy
../Middlewares/Third_Party/FreeRTOS/Source/include
../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2
../Middlewares/Third_Party/FreeRTOS/Source/portable/RVDS/ARM_CM4F
../Drivers/CMSIS/Device/ST/STM32H7xx/Include
../Drivers/CMSIS/Include
..\Applications\inc
../Algorithm
../Algorithm/inc
../Drivers/CMSIS/DSP
..\Bsp\inc
../Middlewares/ST/ARM/DSP/Inc
..\Devices\inc
```

> 删除的 19 条：`../Devices/{WS2812,IBUS,IMU,Saber_C3,M1505B,SBUS,M6020,DM8009P,M3508,tpid,VOFA+,N100,dji_motor,GM6020,M2006,XRobot_IMU}`、`../Bsp/{UART,DWT}`、`..\Devices\SDM02`。

## 7. 解决后的落地动作

- 更新 [`build-and-flash.md`](../../02-architecture/build-and-flash.md)：入口、版本、烧录步骤、CubeMX 流程、CMake 现状；
- 改 `uvprojx` 前备份 `LegWheel.uvprojx.bak-20261019`；改后由用户 Build 验证；失败则回退；
- 如果恢复 `build/`：在 `archive/manifests/` 记录来源/原因，并在 `.gitignore` 保持忽略；
- 更新 `open-questions.md` P0-3/C1/C2/C3/C4/C5/C6；
- 在 `CHANGELOG.md` 记录决定；
- 不在安装目录下做任何修改。

## 8. 讨论记录

- 2026-10-19：S0 已把 `LegWheel.hex` 纳入快照；构建入口待确认。
- 2026-10-19：用户确认 CubeMX 保留（板级初始化/后续通信口），工具安装根 `C:\STM32+Vscode+Keil5` 只读；本机检查到 Keil 5.38 / CubeMX 6.17 / VSCode 1.142 / ARM GCC 15.3，CMake 未找到；H7 固件包缺失。
- 2026-10-19 后续：用户确认 CMake 可能是理解错，`build/` 删除即可、不恢复；当前按 Keil + CubeMX 记录。
- 2026-10-19：**用户确认 Keil 可正常编译**；工程实际编译器 ARMCLANG 6.19；34 个 include 中 19 个失效（Build 不受影响）。
- 2026-10-19：用户允许改 `uvprojx`；CubeMX 工作流选 **B（只生成代码、手动合并）**。已备份并删除 19 条失效 include，剩 15 条；待 Build 复验。
- 2026-10-19：**清理后 Build 成功**；用户确认 VSCode 使用，打开 `firmware/LegWheel`。下一步生成其 `.vscode/c_cpp_properties.json`，归档 `MDK-ARM/.vscode` 旧配置。
