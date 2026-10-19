# 项目结构方案（Harness Engineering）— 提案 v0.1

> 日期：2026-10-19  
> 状态：**提案；S0 已执行（2026-10-19），S1–S4 未执行**。本文不移动、不删除、不改写任何现有文件。  
> 更新：S0 快照 + git 基线已完成，见 `archive/manifests/S0-BASELINE.md`；tag `pre-structure-20261019`。
> 依据：根目录 `README.md` 的今晚四步；t1（固件/构建）、t2（仿真/资料）、t3（监管审阅）三份简报；Captain 定点复核（`Chassis.cpp:13`、`Chassis.h:52-55`、`vmc.cpp:22-23`、`lqr_coeffs.cpp:6`、`MDK-ARM/LegWheel/LegWheel.hex` 等）。  
> 约定：**目录/文件名用英文；文档内容用中文；具体资料文件保留中文名**（按你 2026-10-19 的决定）。

---

## 0. 一页结论

1. 采用 **C 混合结构**：新建目标树；`firmware/`、`simulation/` 迁移；`researchs/` **原地保留**并建索引。
2. 先建立 **三个单一事实源**：参数台账、K 矩阵来源、构建入口。没有这三者，后面所有调参都不可追溯。
3. 先 **回退再动手**：全量快照 + git 基线 + 变更记录；删除分三级，先归档、后删除。
4. 分 **S0–S4 五步**执行，预计 3–4 小时；**今晚不执行**，只等你对本文和 P0 问题拍板。
5. P0 共 16 条（速答表 11 条 + 分类表补充 5 条）见 [`open-questions.md`](./open-questions.md)。S1（只新增）可以先做；**S2（迁移）前必须回答与参数/构建相关的 P0**。

---

## 1. 目的与边界

### 1.1 目的
把仓库从“能跑的代码 + 零散资料”整理成 harness-engineering 结构：

- agent 进入仓库后，先读 `AGENTS.md` 就能知道**去哪找、能改什么、怎么验证、怎么回退**；
- 所有关键结论有**来源**（`path:line` 或实测记录），不靠记忆和猜测；
- 文档、代码、参数、实验记录各有唯一位置，避免“同名文件三套值”；
- 预留云台、气弹簧、实验数据、工具脚本的位置，后续不再临时造目录。

### 1.2 今晚边界
- ✅ 只新增 `docs/00-plan/` 下的提案、问题清单、执行规范、变更记录；
- ❌ 不移动/删除/重命名任何现有文件；
- ❌ 不改控制代码、不改构建配置、不改 README 正文；
- ❌ 不安装软件、不 push 远端。

### 1.3 不在本提案内
控制算法重构、`Chassis.cpp` 拆分、K 矩阵重算、参数实测、云台联调——这些是**结构落地之后**的工程任务，本提案只给它们留位置。

---

## 2. 现状盘点（实测）

| 区域 | 体量 | 文件数 | 角色 | 目标动作 |
|---|---:|---:|---|---|
| `codes-chassis/轮腿底盘控制代码/LegWheel` | 251.4 MB | 1,657 | 底盘固件（STM32H723VGTx + FreeRTOS，1 kHz） | 整体迁入 `firmware/LegWheel/` |
| ├ `Drivers/` | 242.1 MB | 1,446 | STM32 HAL/CMSIS（CMSIS 227.2，其中 DSP 源码 176.7；HAL 14.9） | 保留；git 只跟踪必要部分 |
| ├ `build/` | 5.0 MB | 34 | CMake 历史产物（2026-10-02） | 归档后删除 |
| └ `MDK-ARM/` | 1.8 MB | 26 | Keil 工程；`LegWheel/LegWheel.hex` 494,095 B，2026-10-18 21:38 | 保留；uvguix/tmp 清理 |
| `codes-chassis/轮腿底盘LQR仿真` | 2.0 MB | 66 | MATLAB/Simulink LQR 链路 | 整体迁入 `simulation/chassis-lqr/` |
| `researchs/` | 1,483.8 MB | 5,403 | 外部参考/厂商资料 | **原地保留**（C 方案），建索引 |
| ├ 上海交大开源 | 780.8 MB | 41 | 文档+视频+zip（zip 407,008,202 B，与解压内容重复） | 索引；zip 归档后删除 |
| ├ 山海机甲开源 | 44.4 MB | 405 | 底盘/云台参考代码 | 索引；git 忽略 |
| ├ DM-MC02 | 649.3 MB | 4,943 | 板卡资料（例程 524.5、3D 98.6、2D 15.7） | 索引；git 忽略 |
| ├ Daplink | 5.0 MB | 6 | 无线烧录器资料 | 索引 |
| └ papers | 4.4 MB | 7 | 知乎原理文章 PDF/图 | 索引 |
| `docs/` | 0 B | 1 | 只有空 `papers.md` | 重建为文档中心 |
| 根目录 | — | 6 项 | `README.md`、`STRUCTURES.md`、`ARCHITECTURE.md`(0 B)、`docs/` | 重写/归档 |

**总览**：1.70 GB / 7,131 文件；其中 `.c` 2,678、`.h` 2,275、`.sldasm` 662。真正自有源码约 772 KB（Applications 336 + Algorithm 157 + Devices 102 + Bsp 28 + Core 149）。

### 2.1 与结构直接相关的 8 个事实

1. **没有版本控制**：全工作区 0 个 `.git`；README 却写“查看 git 提交历史”。这是“方便回退”当前最大的缺口。
2. **没有 agent 入口**：无 `AGENTS.md`、无 `CLAUDE.md`；agent 每次都要从目录名猜。
3. **构建入口不清**：Keil 工程与 CMake 产物并存。Keil hex 最新（10-18），CMake 产物停在 10-02；工程根无 `CMakeLists.txt`；`compile_flags.txt` 指向 `d:\RM-electro-control\...`，`_inc_list.txt` 指向 `D:/Github/Transistor-Wheeled-Legged-Robot/software`。
4. **CubeMX 漂移**：`LegWheel.ioc` 停在 2026-08-27，`freertos.c` 已改到 2026-10-18；重新生成会覆盖用户代码。
5. **参数三套**：`Chassis.h:52-55`（11.058 / 1.067 / 0.4）、`vmc.cpp:22-23`（0.554 / 0.788）、仿真 `k_calc_chuan_real2.m`（0.612 / 0.788 / 10.085）。其中 `0.554×2 + 1.067×2 + 11.058 = 14.300 kg`，正好等于你给的新整车重量，说明代码这组是“新数据”，但缺少台账和口径说明。
6. **K 矩阵三份候选**：`lqr_coeffs.cpp:6`（固件实际读）、`Algorithm/inc/K_coeffs_normal.h`（未被任何文件 include 的孤儿副本）、仿真目录同名文件（旧链结果，数值不同）。
7. **文档-代码脱节**：`BOARD_PROTOCOL.md` 被 `board_comm.h`/`board_comm.cpp` 引用但全仓库不存在；DM-MC02 `USAGE.md` 的 `图纸/2d`、`模型/3d`、`示例`、`datasheets` 均不存在；`ARCHITECTURE.md` 与 `docs/papers.md` 是 0 字节。
8. **参考资料体量大**：`researchs/` 占 1.45 GB（约 87%），其中可归档/清理约 1.2–1.4 GB；但 `CMSIS/DSP` 的源码虽未参与编译，其 `DSP/Lib/ARM/arm_cortexM7lfdp_math.lib` 被 Keil 引用（`LegWheel.uvprojx:1153`），不能整目录删。

### 2.2 目录卫生
- 空目录 7 个：`simulation/MathWorks/ServiceHost`、`slprj/_sfprj/EMLReport/sz78x...`、山海 `底盘/{Algorithm,Listings,Objects}`、`云台/{Listings,Objects}`。
- 0 字节文件 3 个：`ARCHITECTURE.md`、`docs/papers.md`、山海 `底盘/.vscode/uv4.log.lock`。
- 路径长度：无超过 240 字符的路径，迁移不受 MAX_PATH 限制。
- 中文/GBK：上交 zip 内文件名是 GBK（解压后中文名正常），后续若再解压/比较需注意编码。

---

## 3. 目标目录树（英文名，中文注释）

```text
LG-AI-process/
├─ AGENTS.md                     # agent 唯一入口：地图 + 规则（中文，≤150 行）
├─ README.md                     # 项目总览（中文，重写）
├─ CHANGELOG.md                  # 结构/文档/代码变更记录（回退依据）
├─ .gitignore
├─ docs/
│  ├─ 00-plan/                   # 本次提案、问题清单、执行规范
│  ├─ 00-governance/             # AI 协作、命名、提交、回退、review 规范
│  ├─ 01-product/                # 目标、需求、验收标准、路线图
│  ├─ 02-architecture/           # 硬件/软件/控制/通信/数据流架构
│  ├─ 03-theory/                 # 动力学、VMC、LQR、LESO、状态机
│  ├─ 04-parameters/             # 参数台账（唯一事实源）
│  ├─ 05-experiments/            # 标定、测试记录、报告
│  ├─ 06-plans/                  # 迭代计划、backlog
│  ├─ 07-decisions/              # ADR（架构决策记录）
│  ├─ 08-quality/                # 测试策略、验收清单、review 模板
│  └─ 09-references/             # 外部资料索引（指向 researchs/，不搬原文件）
├─ firmware/
│  ├─ LegWheel/                  # 现有底盘工程整体迁入（保留 Keil 工程名）
│  └─ gimbal/                    # 预留：板1 云台固件
├─ simulation/
│  └─ chassis-lqr/               # 现有 MATLAB/Simulink 链路
├─ hardware/                     # 我们自己的结构/电气/BOM/接线（新建）
│  ├─ structure/
│  ├─ electronics/
│  ├─ wiring/
│  └─ bom/
├─ experiments/                  # 实测数据（新建，预留）
│  ├─ logs/
│  ├─ calibration/
│  └─ reports/
├─ tools/                        # 构建/烧录/日志解析/文档抽取脚本
├─ researchs/                    # 外部资料原地保留（C 方案）
│  ├─ codes/
│  ├─ hardwares/
│  └─ papers/
└─ archive/                      # 历史版本/废弃文件（先归档，后删除）
   ├─ snapshots/
   ├─ legacy/
   └─ trash-YYYYMMDD/
```

### 3.1 各目录规则

| 目录 | 放什么 | 不放什么 |
|---|---|---|
| `docs/` | 人读/agent 读的文档、索引、决策、参数台账 | 代码、二进制、视频 |
| `firmware/LegWheel/` | 可编译的底盘固件及必要厂商库 | 构建缓存、个人 Keil 界面文件 |
| `firmware/gimbal/` | 未来板1 固件 | 当前先留空 + README |
| `simulation/chassis-lqr/` | `.m`/`.slx`/`.mat` 源与必要结果 | `slprj/` 缓存、临时数据 |
| `hardware/` | 我们自己车的结构/电气/BOM/接线 | 厂商板卡资料（留在 `researchs/`） |
| `experiments/` | 实测日志、标定、报告 | 代码、厂商资料 |
| `tools/` | 构建/烧录/解析/抽取脚本 | 一次性临时脚本（放 `archive/`） |
| `researchs/` | 外部参考、厂商资料（只读） | 我们自己的代码/文档 |
| `archive/` | 快照、旧版本、待删文件 | 日常使用文件 |

命名规则：
- 目录/文件：英文 `kebab-case`（如 `parameters.md`、`build-and-flash.md`）；
- 文档内容：中文；英文术语保留（LQR、VMC、LESO、CAN）；
- 资料文件：保留原中文名（如 `上海交通大学RoboMaster2023平衡步兵控制系统开源.zip`）；
- 日期：`YYYY-MM-DD`；ADR：`0001-title.md`；实验记录：`YYYY-MM-DD-主题.md`。

---

## 4. 现状 → 目标映射

| 现有路径 | 目标路径 | 动作 | 风险 | 回退 |
|---|---|---|---|---|
| `codes-chassis/轮腿底盘控制代码/LegWheel/` | `firmware/LegWheel/` | **文件系统整体移动**（`Move-Item`，随后 `git add -A`）；先复制 hex 副本 | Keil 工程内相对路径不变；`compile_flags.txt`/`_inc_list.txt` 的旧绝对路径仍失效（本来就失效）；未跟踪的 hex/缓存会随目录移动 | 反向 `Move-Item` / 快照恢复 |
| `codes-chassis/轮腿底盘LQR仿真/` | `simulation/chassis-lqr/` | 文件系统整体移动 | `.m` 的相对 load 路径不变；`.slx` 若引用绝对路径需检查 | 同上 |
| `LegWheel/MDK-ARM/LegWheel/LegWheel.hex` | 随工程进入 `firmware/LegWheel/...`；另存 `archive/legacy/hex-2026-10-18/` | 复制留档 + 随目录移动 | **唯一 Keil 产物**（494,095 B，2026-10-18 21:38）；被 `.gitignore` 忽略，`git mv` 不会搬它 | 快照 / archive 副本 |
| `codes-chassis/`（迁移后的空壳） | — | **仅在两个子目录完整移动、manifest 对比通过、hex 副本校验后**才删除/归档空壳 | 漏移未跟踪文件 | 快照 |
| `researchs/` | `researchs/`（原地） | 保留 + 建 `docs/09-references/index.md` | 无 | — |
| `STRUCTURES.md` | `docs/02-architecture/hardware-overview.md` | 内容重写/迁移 | 旧内容丢失；需先备份 | 快照 |
| `README.md` | `README.md` | 原地重写 | 旧内容丢失；先归档旧版 | 快照 + `docs/01-product/legacy-readme-2026-10-19.md` |
| `ARCHITECTURE.md`（0 B） | `docs/02-architecture/` | 填内容或删除 | 无 | 快照 |
| `docs/papers.md`（0 B） | `docs/09-references/index.md` | 替换 | 无 | 快照 |
| `LegWheel/build/` | `archive/trash-20261019/build/` → 删除 | 归档后删 | 不影响 Keil；CMake 本就不可复现 | 快照 |
| `MDK-ARM/*.uvguix.*` | `archive/trash-20261019/uvguix/` → 删除 | 删除 | Keil 会重建；个人界面布局丢失 | 快照 |
| `simulation/slprj/` | `archive/trash-20261019/slprj/` → 删除 | 删除 | MATLAB 会重建 | 快照 |
| `上交...zip` | `archive/trash-20261019/` → 删除 | 归档后删 | 解压目录已完整；保留 zip 可防误删 | 快照 |
| `MDK-ARM/tmp/`、`.vscode` 日志 | `archive/trash-20261019/` → 删除 | 删除 | 无 | 快照 |
| 7 个空目录 | — | 删除 | 无 | 快照 |

> 迁移原则：**先整目录移动，再拆内部**；一次只动一类，动完立刻验证 Keil 能打开、能编译、能烧录。

---

## 5. 分阶段执行（S0–S4）

### S0 回退基线（预计 20–30 min）
1. 关闭 Keil / MATLAB / VOFA，确认无文件占用。
2. 先建 `archive/manifests/`、`archive/snapshots/`、`archive/legacy/`；生成文件清单：`archive/manifests/manifest-20261019.csv`（路径、大小、修改时间；文本文件加 SHA-256；`LegWheel.hex` 单独记 SHA-256，迁移后校验）。
3. 全量快照（二选一）：
   - **A（推荐）**：`archive/snapshots/` 下用 `tar -a -c -f` 或 `7z` 打包；约 1.7 GB，确保磁盘空间。
   - **B**：`robocopy` 镜像到工作区外（需你确认路径；按你的规则，工作区外写入要单独授权）。
4. `git init`；写 `.gitignore`（规则必须同时命中**迁移前** `codes-chassis/...` 与**迁移后** `firmware/...`，见 §6.2）；用 `git check-ignore -v` 抽查：DSP 源码应被忽略、`DSP/Lib/ARM/arm_cortexM7lfdp_math.lib` **不应**被忽略；首次提交；打 tag `pre-structure-20261019`。
5. 验证：随机抽 3 个文件对比快照/清单；`LegWheel.hex` SHA-256 与大小（494,095 B）一致；`git status` 干净；Keil 工程能打开。

### S1 只新增（预计 40–60 min，低风险）
1. 创建 `docs/00-governance` … `docs/09-references` 骨架；每个目录放 `README.md`（中文，说明“放什么/不放什么/维护者”）。
2. 创建 `firmware/gimbal/`、`simulation/`、`experiments/{logs,calibration,reports}`、`hardware/{structure,electronics,wiring,bom}`、`tools/`、`archive/{snapshots,legacy,legacy/hex-2026-10-18}`，各放 `README.md` + `.gitkeep`。
3. 写根 `AGENTS.md`（草案见 §8）。
4. 写 `docs/09-references/index.md`（researchs 全量索引：路径、体量、用途、是否可删）。
5. 写 `docs/04-parameters/parameters.md` v0.1（已知值 + 待测 + 来源，见问题清单）。
6. 写 `docs/02-architecture/build-and-flash.md`（Keil 事实入口、工具链、烧录方式、失效路径说明）。
7. 重写 `README.md`（大纲见 §9）；旧版先存 `docs/01-product/legacy-readme-2026-10-19.md`。
8. 提交：`docs: add harness structure skeleton`。

### S2 迁移代码/仿真（预计 30 min，中风险）
1. **先留档唯一 Keil 产物**（防止 `git mv` 不搬未跟踪文件）：
   `Copy-Item codes-chassis\轮腿底盘控制代码\LegWheel\MDK-ARM\LegWheel\LegWheel.hex archive\legacy\hex-2026-10-18\LegWheel.hex`
   记录 SHA-256 与大小（494,095 B）。
2. **用文件系统整体移动**（不要用 `git mv`，它不会搬未跟踪的 hex/缓存）：
   `Move-Item "codes-chassis\轮腿底盘控制代码\LegWheel" "firmware\LegWheel"`
   `Move-Item "codes-chassis\轮腿底盘LQR仿真" "simulation\chassis-lqr"`
3. `git add -A`（git 会把已跟踪文件识别为重命名；未跟踪的 hex 随目录移动）。
4. 更新所有文档/README 中的旧路径引用（用 `rg` 查 `codes-chassis`、`轮腿底盘`）。
5. 验证：
   - Keil 打开 `firmware/LegWheel/MDK-ARM/LegWheel.uvprojx`，编译一次；
   - MATLAB 打开 `simulation/chassis-lqr/simulation/`，跑一个不依赖硬件的 `.m`（如 `verify_leg_kinematics.m` 若可独立运行）；
   - **manifest 前后对比**：路径/大小/修改时间；文本 SHA-256；`LegWheel.hex` 单独校验，确认无文件丢失；
   - `git status` 只应显示重命名/新增（hex 被忽略属正常）。
6. 回退：`git reset --hard pre-structure-20261019` + 反向 `Move-Item`；或快照恢复。

### S3 清理/归档（预计 30 min，中风险）
1. 按 §7 的 Tier A 清单，**先移动**到 `archive/trash-20261019/`，验证 Keil 仍能编译、MATLAB 仍能跑。
2. 观察 3–7 天后再真正删除（或你确认后立即删）。
3. Tier B 只做“移出 git / 可选移出工作区”，不删除。
4. 更新 `docs/09-references/index.md` 与 `CHANGELOG.md`。

### S4 治理收尾（预计 40–60 min）
1. `docs/04-parameters/parameters.md` 补 P0 参数（你回答后）。
2. `docs/03-theory/k-matrix.md`：写清 K 的三份候选、哪份生效、生成命令、如何复现。
3. `docs/07-decisions/0001-hybrid-structure.md`：记录本方案的选择与被否决项。
4. `docs/08-quality/`：测试清单、验收标准、review 模板。
5. 打 tag `v0.1-structure`；`CHANGELOG.md` 记录全过程。
6. 验收：见 §11。

总预计：**3–4 小时**（含验证）；不含你回答 P0 的时间。

---

## 6. 版本控制与回退

### 6.1 两层回退
| 层 | 手段 | 覆盖 | 限制 |
|---|---|---|---|
| 全量 | `archive/snapshots/` 或工作区外镜像 | 1.7 GB 全部，含研究资料/3D/视频 | 占空间；打包耗时 |
| 文本 | git 仓库 | 代码/文档/脚本/索引 | 不跟踪二进制大文件 |

**建议**：两层都做。git 用于日常 diff/回退；快照用于“删错了/迁移失败”。

### 6.2 `.gitignore` 草案
```gitignore
# agent / runtime
.agent-teams/

# build / generated
**/build/
**/slprj/
**/*.uvguix.*
**/tmp/
**/*.hex
**/*.elf
**/*.bin
**/__pycache__/
**/*.log
**/uv4.log*
**/*.lock

# large vendor/reference trees (index in docs/09-references)
# 注意：S0 在迁移前提交，规则必须同时命中迁移前 codes-chassis/... 与迁移后 firmware/...
researchs/
**/Drivers/CMSIS/DSP/*
!**/Drivers/CMSIS/DSP/Lib/
**/Drivers/CMSIS/DSP/Lib/*
!**/Drivers/CMSIS/DSP/Lib/ARM/
**/Drivers/CMSIS/DSP/Lib/ARM/*
!**/Drivers/CMSIS/DSP/Lib/ARM/arm_cortexM7lfdp_math.lib
**/Drivers/CMSIS/NN/
**/Drivers/CMSIS/Core_A/
**/Drivers/CMSIS/docs/
**/Drivers/CMSIS/DSP_Lib_TestSuite/

# experiment data (large)
experiments/logs/*.csv
experiments/logs/*.bin
archive/snapshots/
```

> 注意（F2 修订）：`**/` 前缀让规则在 S0（`codes-chassis/...`）和 S2 后（`firmware/...`）都命中；若只用 `firmware/...`，S0 首次提交会把 Drivers 242 MB（含 DSP 176.7 MB）全部跟踪，Tier B 的“git 忽略”就落空。`DSP/*` 忽略源码；`Lib/*` 先忽略全部库，再用 `!Lib/ARM/` + `!Lib/ARM/*` + `!.../arm_cortexM7lfdp_math.lib` 只保留 Keil 引用的那一个（GCC/IAR/其他 ARM 库共 164 MB 不跟踪）。`arm_math.h` 实际来自 `Middlewares/ST/ARM/DSP/Inc/arm_math.h`（必须跟踪）。提交前用 `git check-ignore -v` 验证：DSP 源码/GCC 库应忽略、`DSP/Lib/ARM/arm_cortexM7lfdp_math.lib` 与 Middlewares 的 `arm_math.h` 不应忽略。
>
> `researchs/` 整体忽略后，其索引在 `docs/09-references/index.md` 里维护；若你希望 README 也进 git，可改为“只忽略大文件、保留 `*.md`”。这需要你拍板（问题 E1）。
>
> `archive/legacy/hex-2026-10-18/LegWheel.hex` 默认被 `**/*.hex` 忽略（靠快照留档）；若你希望它随 git 保留，追加 `!archive/legacy/**/*.hex`。

### 6.3 提交规范
- `docs:` 文档；`struct:` 目录/迁移；`feat:` 功能；`fix:` 修复；`chore:` 清理/工具。
- 一次提交只做一件事；S0–S4 各至少一个提交。
- 迁移用文件系统 `Move-Item` 后 `git add -A`（git 自动识别重命名）；不要用 `git mv` 搬含未跟踪产物的目录；删除前先 `git rm` 或移动。
- tag：`pre-structure-20261019`、`v0.1-structure`。

### 6.4 回退演练（S0 后做一次）
1. 复制一个无关文件到 `archive/trash-20261019/`，删除原文件；
2. 从快照恢复，对比大小/修改时间；
3. 记录耗时与命令到 `docs/00-governance/rollback.md`。

---

## 7. 清理/归档清单（只提案，未执行）

### Tier A：安全清理（预计回收 ≈ 414 MB）
| 路径 | 体量 | 理由 | 动作 |
|---|---:|---|---|
| `LegWheel/build/` | 5.0 MB | CMake 历史产物；无顶层 CMakeLists；2026-10-02 停更 | 归档 → 删除 |
| `MDK-ARM/*.uvguix.*`（7 个） | 1.12 MB | Keil 个人界面状态，会自动重建 | 删除 |
| `simulation/slprj/` | 0.94 MB | MATLAB 缓存 | 删除 |
| `MDK-ARM/tmp/` | <1 MB | CMake 临时目录 | 删除 |
| `MDK-ARM/.vscode/{uv4.log,uv4.log.lock,keil-assistant.log}` | ≈40 KB | 日志/锁 | 删除 |
| `上交...开源.zip` | 407,008,202 B | 与解压目录内容重复（zip 内 40 个文件，解压 41 个=40+zip 本身；仅文件名 GBK 编码差异） | 归档 → 删除 |
| 7 个空目录 | 0 | 无内容 | 删除 |
| `ARCHITECTURE.md`、`docs/papers.md`（0 B） | 0 | 占位；先写新文档再删 | 替换后删除 |
| 山海 `底盘/.vscode/uv4.log.lock`（0 B） | 0 | 锁文件 | 删除 |

> 删除前必须：① 快照已生成；② `archive/trash-20261019/` 已放副本；③ Keil/MATLAB 验证通过。

### Tier B：归档/移出 git（不删除，约 1.2 GB）
| 路径 | 体量 | 建议 |
|---|---:|---|
| `DM-MC02/.../例程/` | 524.5 MB | 保留作参考；git 忽略；可选移到外部硬盘 |
| `DM-MC02/.../3D模型/` | 98.6 MB | 保留；git 忽略 |
| `上海交大/assets/test_video/` | ≈365 MB | 保留；git 忽略 |
| `CMSIS/DSP/` 源码 | 176.7 MB | **保留 `DSP/Lib/ARM/arm_cortexM7lfdp_math.lib`**（Keil 引用）；源码可只留必要头文件，其余归档 |
| `山海机甲开源/` | 44.4 MB | 保留；git 忽略 |

### Tier C：保留
`Drivers/STM32H7xx_HAL_Driver` 14.9 MB、`Middlewares` 1.6 MB、`papers` 4.4 MB、`Daplink` 5.0 MB、现有源码/文档；**`LegWheel/MDK-ARM/LegWheel/LegWheel.hex`（494,095 B，唯一 Keil 产物）随工程迁移，另存 `archive/legacy/hex-2026-10-18/`，不列入任何删除清单**。

> 若把 Tier B 全部移出工作区，可再省约 1.2 GB；但会降低离线可查性。建议先只做 Tier A，Tier B 等你确认。

---

## 8. `AGENTS.md` 草案（约 50 行，落地时放根目录）

```markdown
# AGENTS.md — 轮腿平衡步兵项目

## 项目一句话
RoboMaster 轮腿平衡步兵：底盘（STM32H723 + FreeRTOS + 1 kHz 控制环 + 7 状态机）
+ 未来云台（板1）。当前处于新车参数更新/旧代码适配阶段。

## 先读什么（按顺序）
1. README.md（现状与快速开始）
2. docs/01-product/overview.md（目标与验收）
3. docs/02-architecture/system.md（软硬件结构）
4. docs/04-parameters/parameters.md（唯一参数台账）
5. 本次任务相关的 docs/03-theory 或 docs/05-experiments

## 目录地图
- firmware/LegWheel/：底盘固件（Keil 工程）
- firmware/gimbal/：云台固件（预留）
- simulation/chassis-lqr/：MATLAB/Simulink
- docs/：全部文档；docs/09-references/ 指向 researchs/
- researchs/：外部资料，只读
- experiments/：实测数据
- tools/：构建/烧录/解析脚本

## 事实源优先级
参数：docs/04-parameters/parameters.md > 代码宏 > 仿真脚本 > 旧文档。
构建：docs/02-architecture/build-and-flash.md（Keil 为当前事实入口）。
K 矩阵：docs/03-theory/k-matrix.md（必须写清生效文件与生成命令）。
冲突时：停下来提问，不要擅自选一个。

## 修改规则
- 不编造数字；每个结论给 path:line 或实测记录。
- 不移动/删除 researchs/；不删除任何文件除非有快照 + 用户确认。
- 改代码必须：编译通过 + 说明验证方式；不能验证就标记“未验证”。
- 每次改动写 CHANGELOG.md；结构性改动先写 ADR。
- 不提交二进制大文件；遵守 .gitignore。
- 不修改工作区外文件；不 push 远端。

## 构建与验证
- Keil：firmware/LegWheel/MDK-ARM/LegWheel.uvprojx
- 产物：MDK-ARM/LegWheel/LegWheel.hex
- 烧录：DAPLink（无线）或 ST-Link；见 build-and-flash.md
- 仿真：MATLAB 打开 simulation/chassis-lqr/simulation/
- 参数验证：VOFA 13 路，115200；见 tools/

## 提问规则
P0 阻塞（参数来源、K 来源、协议、构建入口）先问，不猜。
不确定的写成 `TBD`，进 docs/00-plan/open-questions.md。

## 交付格式
改了什么 / 验证了什么 / 证据（path:line）/ 未决问题 / 下一步。
```

---

## 9. `README.md` 重写大纲（中文）

```text
# 轮腿平衡步兵（RoboMaster）— 项目总览
1. 项目是什么 / 当前阶段（新车、旧代码、云台待装）
2. 硬件一览（板2 DM-MC02、4 关节 + 2 轮、IMU、遥控、继电器、电池）
3. 软件架构（1 kHz 控制环、7 状态机、LQR/VMC/LESO、板间通信骨架）
4. 快速开始（Keil 打开/编译/烧录；MATLAB 仿真；VOFA 观测）
5. 目录导航（firmware/simulation/docs/researchs/experiments/tools）
6. 文档地图（AGENTS.md、参数台账、架构、理论、问题清单）
7. 当前已知问题（链到 open-questions 的 P0）
8. 变更与回退（CHANGELOG、git、快照）
9. 参考与许可（上交/山海/知乎/DM-MC02；仅学习参考）
```

原则：**先给结论，再给细节；每节不超过 10 行；所有链接可点；不复制长表格**。旧 README 内容归档到 `docs/01-product/legacy-readme-2026-10-19.md`。

---

## 10. 命名、写作与引用规范

1. **目录/文件名**：英文 `kebab-case`；不出现空格、中文（资料文件除外）。
2. **文档内容**：中文为主；术语首次出现给英文/缩写。
3. **引用**：`path:line`；外部资料给 URL 或本地路径；实测给日期、条件、工具。
4. **不确定**：一律 `TBD` / `待测`，并进 `open-questions.md`；禁止用“应该是”当结论。
5. **单位**：SI（m、kg、s、rad、N、N·m）；角度可附 deg。
6. **单一事实源**：参数表、K 来源、构建入口各只有一处；其他文档链接过去，不复制数值。
7. **文档长度**：单文档正文 ≤300 行（提案/ADR/附录/证据索引不计）；超长拆分；每篇开头给“结论/适用对象/更新日期”。
8. **链接检查**：S4 用脚本检查 `docs/` 内相对链接；坏链进 CHANGELOG。

---

## 11. 验收标准（S4 结束）

- [ ] 根目录有 `AGENTS.md`、`README.md`、`CHANGELOG.md`、`.gitignore`。
- [ ] 目标树存在；每个新建目录有 `README.md` 说明用途。
- [ ] `firmware/LegWheel/` 能打开 Keil 工程并编译；`mdk hex` 生成。
- [ ] `simulation/chassis-lqr/` 至少一个 `.m` 可独立运行。
- [ ] `docs/04-parameters/parameters.md` 覆盖已知/待测/来源；P0 参数有明确状态。
- [ ] `docs/03-theory/k-matrix.md` 写清生效 K、生成链、复现命令。
- [ ] `docs/09-references/index.md` 覆盖 researchs 全部一级目录。
- [ ] `git log` 有 S0–S4 提交；tag `v0.1-structure`；`git status` 干净。
- [ ] 快照可恢复（演练一次）。
- [ ] 没有文件因迁移丢失（manifest 前后对比；`LegWheel.hex` 单独校验 SHA-256/494,095 B）。
- [ ] `open-questions.md` 的 P0 要么已答，要么明确延期并记录风险。

---

## 12. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| K 矩阵三份候选，生效来源不明 | 调参结果不可复现 | S1 先写 `k-matrix.md`；P0 未答前不改 K |
| 轮距 `LEG_FF_WHEEL_TRACK` 三种用法（`2*`/`1*`/`0.5*`） | 力/速度可能差 2 倍 | 先确认物理定义；不改代码，只记录 |
| Keil vs CMake 双入口 | 换机不可复现 | 以 Keil hex 为事实；CMake 归档；S1 写构建文档 |
| `.ioc` 与 `freertos.c` 漂移 | 重新生成覆盖用户代码 | 明确“不重新生成”；如需生成先在副本上做 |
| 无 git | 无法回退 | S0 立即建立基线 |
| `BOARD_PROTOCOL.md` 缺失 | 云台联调无契约 | P0；先写协议草案再联调 |
| 大批参考文件 | 仓库臃肿、agent 读错 | `researchs/` 只读 + 索引；git 忽略 |
| 删除误伤 | 丢资料 | Tier A 先归档；快照；逐项确认 |
| 中文/GBK 文件名 | 迁移/解压乱码 | 迁移用 `Move-Item` + `git add -A`；zip 不再解压；新文件 UTF-8 |
| 你时间有限 | P0 答不完 | S1 可先做；S2 前只等 P0 四项 |

---

## 13. 今晚不做 & 下一步

**今晚不做**：任何移动/删除/重命名；README 正文不改；代码不改；构建配置不改。

**下一步（你确认后）**：
1. 你回答 `open-questions.md` 的 P0（速答表 11 条 + 补充 P0 5 条）；至少先答 P0-1/2/3/4/5/6/7/10 与 A1/A11/A12/C3/D3；P0-11 是 S3 删除准入门槛；
2. 你确认本提案的目录树、Tier A 删除清单、git 范围；
3. 我再按 S0→S1 执行；S2 前单独给你一份“迁移前检查单”。

---

## 附录 A：证据索引（本提案引用的关键事实）

| 事实 | 证据 |
|---|---|
| 轮半径 0.06 m | `firmware（现 codes-chassis/.../LegWheel）/Applications/src/Chassis.cpp:13` |
| 车体 11.058 / 腿 1.067 / 轮距 0.4 | `.../Applications/inc/Chassis.h:52-55` |
| vmc 轮 0.554 / 腿 0.788 | `.../Algorithm/src/vmc.cpp:22-23` |
| 14.3 kg 自洽 | 0.554×2 + 1.067×2 + 11.058 = 14.300 |
| K 实际读取 | `.../Algorithm/src/lqr_coeffs.cpp:6`（`K_coeffs_normal`）、`:48`（`K_coeffs_off_ground`） |
| 孤儿 K 头 | `.../Algorithm/inc/K_coeffs_normal.h`（全仓库无 include） |
| 状态枚举 | `.../Applications/inc/Chassis.h:662` 起 |
| 1 kHz / 任务 | `.../Core/Src/freertos.c`；`FreeRTOSConfig.h` `configTICK_RATE_HZ=1000` |
| Keil 最新产物 | `.../MDK-ARM/LegWheel/LegWheel.hex` 494,095 B，2026-10-18 21:38 |
| CMake 残留 | `.../build/` 2026-10-02；工程根无 `CMakeLists.txt` |
| 失效绝对路径 | `compile_flags.txt`（`d:\RM-electro-control\...`）、`_inc_list.txt`（`D:/Github/...`） |
| `.ioc` 漂移 | `LegWheel.ioc` 2026-08-27 vs `freertos.c` 2026-10-18 |
| 板间协议缺失 | `board_comm.h` 注释引用 `BOARD_PROTOCOL.md`；全仓库不存在 |
| 云台骨架 | `board_comm.h` `BOARD_COMM_GIMBAL_PRESENT 0`；`Cloud.h` `Cloud_Yaw_Center 4060` / `ReverseCenter 7809` |
| DSP lib 被引用 | `MDK-ARM/LegWheel.uvprojx:341`（`ARM_MATH_CM7`）、`:1153`（`arm_cortexM7lfdp_math.lib`） |
| 上交 zip 重复 | 407,008,202 B；zip 40 文件 vs 解压 41（含 zip 本身），仅 GBK 文件名差异 |
| 空目录/0 字节 | `simulation/MathWorks/ServiceHost` 等 7 个；`ARCHITECTURE.md`、`docs/papers.md` 等 3 个 |

> 注：文中 `firmware（现 codes-chassis/...）` 仅表示迁移后的预期路径；当前实际路径以 §4 映射表为准。
