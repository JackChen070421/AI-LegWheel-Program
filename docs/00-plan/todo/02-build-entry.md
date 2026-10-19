# TODO-02 · 构建入口与工具链（Keil / CubeMX / CMake）

> 状态：🔎 部分确认（2026-10-19）　优先级：P0　负责人：你 + AI  
> 对应：`open-questions.md` P0-3、C1、C2、C3、C4、C5、C6  
> 关联：[`docs/02-architecture/build-and-flash.md`](../../02-architecture/build-and-flash.md)

## 1. 要解决的问题

1. **P0-3**：编译/烧录的事实入口是什么（Keil / CubeMX / CMake / VSCode）？
2. 工具链版本、路径、烧录步骤？
3. **CubeMX 保留怎么用**：后续加通信口时怎么改 `.ioc` 而不覆盖用户代码？
4. `build/`（CMake 产物）是否需要恢复？
5. 旧绝对路径（`compile_flags.txt`、`_inc_list.txt`）是否要修？

## 2. 为什么现在要解决

- Keil 有最新 hex（2026-10-18 21:38，494,095 B），CMake 产物停在 2026-10-02；
- 工程根没有 `CMakeLists.txt`，`build/` 是历史残留；
- `.ioc` 停在 08-27，`freertos.c` 已到 10-18；直接 CubeMX 重新生成会覆盖用户代码；
- 结构迁移（S2）前必须知道“什么不能碰”，否则可能把唯一可复现的构建配置弄丢。

## 3. 用户已说明（2026-10-19）

- **CubeMX 要保留**：用于开发板初始化；后续如果新增/调用通信口，可能还要用 CubeMX；
- 工具安装根：`C:\STM32+Vscode+Keil5`；
- **agent 只读**：不要修改安装路径，只能浏览（已写入 AGENTS.md 黄金原则 9）；
- 关于 “CMake”：你的表述是“CubeMX 设置开发板初始化的时候用的”；实际检查**未在本机找到 cmake.exe**（详见 §4），需要确认你指的是 CubeMX 工作流、`LegWheel/build/`，还是另一台机器/CLion。

## 4. 目前已知（2026-10-19 只读检查）

| 事实 | 证据/值 |
|---|---|
| Keil µVision | `C:\STM32+Vscode+Keil5\MDK\Core\UV4\UV4.exe`，**5.38.0.0** |
| ARMCC | 5.06.0.189 |
| ARMCLANG | 16.0.0（LLVM 16） |
| Keil H7 器件包 | `STM32H7xx_DFP` 4.1.3 |
| Keil ARM_Compiler 包 | 1.7.2 |
| STM32CubeMX | `...\STM32CubeMx\Core\STM32CubeMX.exe`，**>6.17.0-RC5** |
| VS Code | 1.142.0 |
| ARM GNU GCC | `C:\Program Files (x86)\Arm\GNU Toolchain mingw-w64-i686-arm-none-eabi\...`，**15.3.1** |
| CMake | **未找到**（安装根/PATH/常见路径都没有） |
| CubeMX 固件包 | 本机只有 `STM32Cube_FW_F1_V1.8.7`；**H7 包缺失** |
| 工程 | `MDK-ARM/LegWheel.uvprojx`；`CreateHexFile=1`；hex 494,095 B / 10-18 |
| `.ioc` 漂移 | `LegWheel.ioc` 2026-08-27 vs `freertos.c` 2026-10-18 |
| 旧路径 | `compile_flags.txt` → `d:\RM-electro-control\...`；`_inc_list.txt` → `D:/Github/...` |
| `build/` | 2026-10-02 的 CMake 产物；Tier A 已删；可在 S0 快照中恢复（5 MB），但 cache 指向已不存在的 `C:/Program Files/toolchain/...`、`C:/msys64` |

## 5. 可选方案

| 方案 | 做法 | 代价/风险 |
|---|---|---|
| **A. Keil 编译 + CubeMX 管初始化**（推荐） | Keil UV4 编译/烧录；CubeMX 只改 `.ioc` 的板级/外设，生成后在副本上人工合并；CMake 暂不使用 | 换机需装 Keil + H7 DFP；CubeMX 需 H7 固件包；要严格“副本生成”纪律 |
| **B. 只用 Keil** | 不动 CubeMX；新通信口手工改 `Core/` 初始化 | 最稳；但改外设易错，后续维护差 |
| **C. CMake/CLion** | 安装 CMake，重建顶层 `CMakeLists.txt` + toolchain | 本机无 CMake；工作量大；需与 Keil 验证 hex 一致 |
| **D. 恢复 build/** | 从 S0 快照恢复 `LegWheel/build/` | 只有旧产物；cache 路径失效，不能直接复现；仅作参考 |

## 6. 要回答它，需要做什么

1. 确认：日常是 **VSCode + Keil Assistant 触发 UV4**，还是直接开 Keil？工程实际用 ARMCC 5.06 还是 ARMCLANG 16？
2. 确认烧录方式（DAPLink 无线 / ST-Link / JLink）与步骤；
3. 确认“CMake”具体指什么：
   - 如果是 CubeMX 工作流 → 记录为“CubeMX 保留”，不恢复 build/；
   - 如果是 `LegWheel/build/` → 可从快照恢复 5 MB（但不解决路径失效）；
   - 如果是另一台机器/CLion → 给路径/版本，单独配置。
4. 若继续用 CubeMX 改 H7 外设：需要安装 **STM32Cube_FW_H7**（你操作；安装目录只读）；并约定“先复制 `.ioc`/工程到临时目录生成，再人工合并”的流程。
5. 决定是否修 `compile_flags.txt`/`_inc_list.txt`（或只记录、不改）。

## 7. 解决后的落地动作

- 更新 [`build-and-flash.md`](../../02-architecture/build-and-flash.md)：入口、版本、烧录步骤、CubeMX 流程、CMake 现状；
- 如果恢复 `build/`：在 `archive/manifests/` 记录来源/原因，并在 `.gitignore` 保持忽略；
- 更新 `open-questions.md` P0-3/C1/C2/C3/C4/C5/C6；
- 在 `CHANGELOG.md` 记录决定；
- 不在安装目录下做任何修改。

## 8. 讨论记录

- 2026-10-19：S0 已把 `LegWheel.hex` 纳入快照；构建入口待确认。
- 2026-10-19：用户确认 CubeMX 保留（板级初始化/后续通信口），工具安装根 `C:\STM32+Vscode+Keil5` 只读；本机检查到 Keil 5.38 / CubeMX 6.17 / VSCode 1.142 / ARM GCC 15.3，CMake 未找到；H7 固件包缺失。
