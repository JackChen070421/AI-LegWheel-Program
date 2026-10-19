# TODO-02 · 唯一构建入口与工具链

> 状态：⬜ 未开始　优先级：P0　负责人：你 + AI  
> 对应：`open-questions.md` P0-3、C1、C2、C5、C6  
> 关联：`docs/02-architecture/build-and-flash.md`（待建）

## 1. 要解决的问题

1. **P0-3**：唯一构建入口是 Keil、CMake/CLion，还是两者都维护？
2. 工具链版本/安装路径是什么？
3. `build/` 的 CMake 产物是否还需要保留？

## 2. 为什么现在要解决

- Keil 有最新 hex（2026-10-18 21:38，494,095 B），CMake 产物停在 2026-10-02；
- 工程根没有 `CMakeLists.txt`，`build/` 是历史残留；
- `compile_flags.txt` 指向 `d:\RM-electro-control\...`，`_inc_list.txt` 指向 `D:/Github/Transistor-Wheeled-Legged-Robot/software` → 换机不可构建；
- 结构迁移（S2）前必须知道“什么不能碰”，否则可能把唯一可复现的构建配置弄丢。

## 3. 目前已知（证据）

| 事实 | 证据 |
|---|---|
| MCU | STM32H723VGTx（`LegWheel.ioc`、`LegWheel.uvprojx`） |
| Keil 工程 | `MDK-ARM/LegWheel.uvprojx`，相对路径可用；`CreateHexFile=1`，输出 `MDK-ARM/LegWheel/LegWheel.hex` |
| 最新 hex | 494,095 B，2026-10-18 21:38 |
| CMake 产物 | `build/` 2026-10-02；有 `.elf/.hex/.bin`；工程根无 `CMakeLists.txt` |
| 旧绝对路径 | `compile_flags.txt`、`_inc_list.txt`、`CMakeCache.txt` |
| `.ioc` 漂移 | 2026-08-27，`freertos.c` 2026-10-18；重新生成会覆盖用户代码 |

## 4. 可选方案

| 方案 | 做法 | 代价/风险 |
|---|---|---|
| **A. Keil 唯一**（推荐） | 以 `LegWheel.uvprojx` 为事实入口；CMake 归档；写清 Keil 版本/器件包/烧录步骤 | 换机需装 Keil + 器件包；无 CI |
| **B. CMake 唯一** | 重建顶层 `CMakeLists.txt` + toolchain 文件；弃用 Keil | 工作量大；需验证 hex 一致；风险高 |
| **C. 双入口** | Keil 日常、CMake 做 CI | 维护两份配置；容易漂移 |

## 5. 要回答它，需要做什么

1. 确认你平时点哪个：Keil `Build`、CLion/CMake，还是让 AI/别人代编译？
2. 记录 Keil 版本、ARM Compiler 版本、STM32H7 器件包版本；
3. 记录烧录方式（DAPLink 无线 / ST-Link / JLink）与步骤；
4. 在干净目录试一次“只靠仓库文件 + 工具链”的构建，确认缺什么；
5. 决定 `build/` 是删除还是留作历史证据。

## 6. 解决后的落地动作

- 新建 `docs/02-architecture/build-and-flash.md`：入口、版本、命令、产物路径、烧录步骤、已知坑（`.ioc` 不要重新生成）；
- `.gitignore` 忽略 `build/`、`*.hex`、`uvguix`，但 `MDK-ARM/LegWheel/LegWheel.hex` 在 `archive/legacy/` 留档；
- 如选 CMake，补 `CMakeLists.txt` 与 toolchain 文件；
- 更新 `open-questions.md` P0-3/C1/C2/C5/C6。

## 7. 讨论记录

- 2026-10-19：S0 已把 `LegWheel.hex` 纳入快照；构建入口待你确认。
