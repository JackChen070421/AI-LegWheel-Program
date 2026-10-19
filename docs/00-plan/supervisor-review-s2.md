# S2 迁移独立审阅与全仓冗余清单（Supervisor / t8）

> 日期：2026-10-19　范围：工作区当前状态（迁移未提交，按要求不审 git 提交）
> 方法：独立重跑 manifest 映射（PowerShell 解析 pre/post CSV，不采信 t6/t7 结论）、SHA-256、结构存在性、全仓链接扫描、冗余清点。
> **verdict：pass**　findings：0（1 条非阻断文档提示见 §5；未做符号级死代码分析，见 §4 说明）

## 1. Manifest 映射与 hex（独立复算，PASS）
- `pre-s2-manifest-20261019.csv` 7,092 数据行 → `post-s2-manifest-20261019.csv` 7,091 数据行。
- 按 S2 记录的五条映射规则重放后：**missing=0、added=0、changed=1**，唯一变化 `simulation/chassis-lqr/README.md` 611 B → 219 B（S1 占位被源 README 覆盖），与 `archive/manifests/S2-MIGRATION-20261019.md:24-29` 一致。
- hex：`firmware/LegWheel/MDK-ARM/LegWheel/LegWheel.hex` 与 `archive/legacy/hex-2026-10-18/LegWheel.hex` 同为 **494,095 B / SHA-256 `c41529fff5f9308fca2542d34d96af1ad121191067c1959abdc40342081dd9ce`**，与 t6/t7 所述一致。
- 说明：`firmware/` 下当前仅 2 个 tracked 文件、749 deletions/794 untracked（t6 结论）；按要求不要求提交，仅记录状态。

## 2. 结构（PASS）
- `firmware/LegWheel/` 8/8 子目录齐全（Applications/Algorithm/Devices/Bsp/Core/MDK-ARM/Drivers/Middlewares）；LegWheel 子树 1,611 文件（`firmware/` 全树 1,613 = 1,611 + 顶层 README + gimbal/README，与 t6 计数吻合）。
- `simulation/chassis-lqr/` 21 个文件（11 `.m` + `.slx` + 5 `.mat` + K 头 + `lqr_coeffs2.cpp` + csv + README），另有 `MathWorks/` 残留 1 文件。
- `codes-chassis/`、根 `STRUCTURES.md` 均 **不存在**；`docs/02-architecture/hardware-overview.md`（1,727 B）存在，首行注明“来源：原根目录 STRUCTURES.md”，正文即旧车结构清单 → 来源成立。

## 3. 文档路径与链接（PASS）
- 全仓（除 `researchs/`）Markdown 本地链接 **88 条，坏链 0**（含中文路径、锚点除外）。
- `README.md`、`AGENTS.md`、`docs/02-architecture/build-and-flash.md`、`system.md`、`docs/06-plans/roadmap.md`：均只引用 `firmware/...`、`simulation/chassis-lqr/` 等新路径，未检出 `codes-chassis` / 根 `STRUCTURES.md` 残留。
- `structure-proposal.md` 头部已更新为“S0–S2 已执行（2026-10-19）”。

## 4. 全仓冗余/无用清单（只列不删）
| 路径 | 大小 | 为什么 | 置信度 |
|---|---:|---|---|
| `firmware/LegWheel/compile_flags.txt` | 4,458 B | 全部 include 根为 `d:\RM-electro-control\wheelleg\github\Transistor-Wheeled-Legged-Robot\software\...`（已不存在），对 clangd/IntelliSense 是误导 | high（失效）/ medium（可否直接删） |
| `firmware/LegWheel/_inc_list.txt` | 3,357 B | 根为 `D:/Github/Transistor-Wheeled-Legged-Robot/software`，同上 | high（失效）/ medium（可否直接删） |
| `firmware/LegWheel/Algorithm/inc/K_coeffs_normal.h` | 3,677 B | 全仓库无 `#include`（孤儿副本，且为第三套数值） | high（未使用）/**不建议删**（K 证据，应移 `archive/legacy/` 或并入 k-matrix 文档） |
| `simulation/chassis-lqr/balance_robot_real.slxc` | 5,082 B | Simulink 编译缓存，可自动再生 | high（可删） |
| `simulation/chassis-lqr/MathWorks/MATLAB/R2024a/graphicsState.bin` | 2 B | MATLAB 图形状态残留（连同空目录链） | high（可删） |
| `researchs/codes/山海机甲开源/山海机甲开源.zip` | 9,979,117 B | zip 内 404 个文件 vs 解压 403 个、字节大小多重集 **5 处不一致** → **不能判为完全重复**；`docs/09-references/index.md:36` 已写“可能重复，暂留” | low（重复性未证）/**暂不删** |
| `researchs/.../CtrBoard-H7_LCD/LCD取模教程.zip` | 1,697,960 B | 厂商例程自带资料，非本仓产物 | low（Tier B 保留） |
| `simulation/chassis-lqr/K_coeffs_normal.h` | 3,707 B | 与固件 `src/lqr_coeffs.cpp` 的 40×6 数值逐行相同（t7 结论），属链路证据 | medium（保留；不删） |
| `simulation/chassis-lqr/lqr_coeffs2.cpp` | 5,735 B | 旧链产物（`k/k_off` 命名），与现行 K 不同源 | medium（建议 archive，不删） |
| `simulation/chassis-lqr/*.mat`（5 个） | 43 KB | `xdd/leg_data/num_matrix/state_and_control_matrix/lqr_fitting_results`，可由 4 个 `.m` 重跑再生 | medium（保留，体积可忽略） |
| `firmware/LegWheel/MDK-ARM/.vscode/{c_cpp_properties.json,settings.json}` | 23 KB | VS Code C/C++ 配置，仍可用（路径需核对） | low（保留） |
| `firmware/LegWheel/.claude/settings.local.json` | 112 B | 外部工具（Claude Code）本地设置，与本仓 harness 无关 | low（可删可留） |
| `archive/legacy/hex-2026-10-18/LegWheel.hex` | 494,095 B | 与现工程 hex 同哈希 | —（**基线留档，禁止删**） |

- 已确认消失：`build/`、`MDK-ARM/tmp/`、`slprj/`、`*.uvguix.*`、0 字节文件、空目录（全仓 0 个 0 B / 0 个空目录）。
- 未做：头文件级“未被任何源文件 include”的全量符号分析（成本高）；仅对已知孤儿 K 头做了验证。

## 5. 建议 Captain 执行的删除（仅 high 置信度）
1. `simulation/chassis-lqr/balance_robot_real.slxc`（5,082 B，缓存）。
2. `simulation/chassis-lqr/MathWorks/`（2 B 文件 + 空目录链，残留）。
- 不建议删：`compile_flags.txt`/`_inc_list.txt` 先“重生成或移入 archive”再删（可能有编辑器依赖）；`K_coeffs_normal.h`（孤儿）与 `lqr_coeffs2.cpp` 是 K 来源证据，移 `archive/legacy/` 而非删除；山海 zip 先做内容比对再定。

## 6. 非阻断文档提示
- `docs/00-plan/structure-proposal.md:464` 附录仍写 `firmware（现 codes-chassis/...）/Applications/src/Chassis.cpp:13`，“现 codes-chassis”在 S2 后已不成立；建议改为 `firmware/LegWheel/Applications/src/Chassis.cpp:13`。属历史提案内的措辞残留，不影响交付。

## 7. 结论
迁移完整性、清单一致性、hex 留档、结构/文档路径全部复核通过；无阻断项，**pass**。冗余清单如上，删除动作待 Captain 按 high 项执行并记录 CHANGELOG。
