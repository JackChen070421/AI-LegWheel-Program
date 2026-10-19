# 交付前独立审阅（Supervisor / t4）

> 日期：2026-10-19　对象：`structure-proposal.md`、`open-questions.md`、`agent-execution-policy.md`、`CHANGELOG.md`
> 方式：只读；抽查 18 条事实（其中 12 条具名 `path:line`，6 条为文件/目录统计）+ 4 个文档内一致性检查。
> **verdict：needs_revision**（2 high / 2 medium / 1 low，均为文档层可修，不涉及代码改动）

## 1. 覆盖度（t1/t2/t3 关键结论）
| 结论 | 落点 | 判定 |
|---|---|---|
| K 三份候选、生效=src、孤儿头 | proposal §2.1-6、§12；questions P0-1/B1 | ✅ |
| 14.3 kg 自洽（0.554×2+1.067×2+11.058） | proposal §2.1-5、附录；questions §0/P0-4 | ✅ 算式复核正确 |
| Keil/CMake 双入口、hex 10-18 vs CMake 10-02 | proposal §2.1-3、§12；questions P0-3/C1 | ✅ |
| `.ioc`(08-27) vs `freertos.c`(10-18) 漂移 | proposal §2.1-4、§12；questions C3 | ✅ |
| `BOARD_PROTOCOL.md` 缺失 | proposal §2.1-7、§12；questions P0-7/D1 | ✅ 全库无此文件 |
| 轮距 `2*`/`1*`/`0.5*` 三种用法 | proposal §12；questions A2/B5 | ✅ 措辞留“可能/待确认”，未写成 bug |
| 清理体量 / 空文件空目录 / zip 重复 | proposal §2、§7；questions E1–E6 | ✅ 见 §2 复核 |
| t3 的“双构建、旧绝对路径、无 .git” | proposal §2.1-1/3 | ✅ |

遗漏（不阻断）：t1 的“Boardcomm/ET16S/Cloud 均 `osDelay(1)` 忙轮询、无超时保护”未进问题清单；主频“待确认”未列入 C 类。

## 2. 事实抽查（全部通过）
- `Chassis.cpp:13` = `const float k_wheel_radius = 0.06;` ✅
- `Chassis.cpp:1558` 含 `2.0f * LEG_FF_WHEEL_TRACK`；`:1596` 含 `LEG_FF_WHEEL_TRACK * sin(Roll)`；`:1873` 含 `0.5f * LEG_FF_WHEEL_TRACK` ✅（`:1549` 只是 `if(Track>1e-6)` 卫语句，见 F5）
- `Chassis.h:52-55` = 11.058f / 1.067f / 1.0f(RATIO) / 0.4f ✅
- `vmc.cpp:22-23` = `k_m_wheel=0.554f`、`k_m_leg=0.788f` ✅
- `lqr_coeffs.cpp:6`、`:48` = normal / off_ground 两份 40×6 ✅
- `LegWheel.uvprojx:341` `ARM_MATH_CM7`、`:1153` `..\Drivers\CMSIS\DSP\Lib\ARM\arm_cortexM7lfdp_math.lib` ✅
- `LegWheel.ioc` 2026-08-27；`freertos.c` 2026-10-18 21:38 ✅
- `MDK-ARM/LegWheel/LegWheel.hex` = 494,095 B，2026-10-18 21:38 ✅
- `build/` = 34 文件 5.05 MB，2026-10-02；`slprj/` 43 文件 0.94 MB；`uvguix` 7 个 1.12 MB ✅
- 空目录 7 个、0 字节文件 3 个、最长路径 184 字符（<240）✅
- 上交 zip 407,008,202 B；zip 40 个文件条目 vs 解压 40 个非 zip 文件，**逐文件字节大小多重集完全一致** ✅（“内容重复”有据）
- 文档间唯一 Markdown 链接 `structure-proposal.md:16 → ./open-questions.md` 有效 ✅
- Tier A 合计 ≈414 MB（388.1 MiB zip + 7.2 MB 零碎）✅

## 3. findings（按严重度）

### F1 · high · 唯一 Keil 产物会落在迁移后的“空壳”目录里
`structure-proposal.md:192` 用 `git mv` 整体迁移，但 `.gitignore:239` 忽略 `**/*.hex`；hex 未被跟踪 → `git mv` 不会搬运它，而 §4（`:153`）又写 `codes-chassis/`（空壳）→“删除或归档”，Tier A/B/C 均未列 `MDK-ARM/LegWheel/LegWheel.hex`。结果：当前唯一可用的 Keil 产物（`:48`、`:453` 当作构建事实）与 build/tmp/uvguix 残留一起留在旧路径，可能被当空壳删除。
**requiredFix**：S2 改用文件系统移动（或 `git add -A` 前先移动整目录）；新增“保留产物”行明确 `LegWheel.hex` 随工程进入 `firmware/LegWheel/`；S2 验证改为 manifest 前后对比，而不是只看 `git status`。

### F2 · high · `.gitignore` 按迁移后路径书写，但 S0 首次提交发生在迁移前
`structure-proposal.md:249-253` 忽略的是 `firmware/LegWheel/Drivers/CMSIS/...`，而 S0（`:178`）在目录仍为 `codes-chassis/...` 时提交 → 这些规则一条都不命中，`Drivers/` 242 MB（含 DSP 176.7 MB）会被全部跟踪进首次提交；S2 后即使路径命中，已跟踪文件也不会自动变忽略，Tier B 的“git 忽略”目标落空。且该规则连 E6（`open-questions.md:134`）要求保留的 `DSP/Lib/ARM/arm_cortexM7lfdp_math.lib` 一起忽略，未来一旦 `git rm --cached`，新克隆将缺这个被 `uvprojx:1153` 引用的库。
**requiredFix**：在 `.gitignore` 中补迁移前路径（`codes-chassis/**/Drivers/CMSIS/DSP/` 等）或把 git init 移到 S2 之后；为 `DSP/Lib/**` 加否定规则；在文档中写明“哪些 CMSIS 路径始终跟踪”。

### F3 · medium · P0 数量自相矛盾（9 vs 10），且 P0 集合未定义
`structure-proposal.md:16` 与 `:435` 写“P0 未决 9 条”，`open-questions.md:29` 标题写“这 10 条”，实际 P0-1…P0-10 共 10 条；另有一批 P0 未进速答表（A1 轮半径、A11 电机型号、A12 IMU、C3 `.ioc`、D3 CAN3 仲裁、F6 删除授权，见 `open-questions.md:50,60,61,99,116,150`）。因此“9 条”与任何口径都不符，且迁移阻塞项 F6 未被 §13 的“至少前 5 条”覆盖。
**requiredFix**：统一定义 P0 集合（速答表 + 补充 P0 清单），把两处“9 条”改为实际数；将 F6 明确为 S3 的准入门槛。

### F4 · medium · A–H 分类内 P0 重复且缺交叉引用
`open-questions.md:51` A2 与 `:76` B5 是同一个轮距问题、都标 P0 且互不指向；A3/A4 重复 P0-4/P0-5（`:52-53`），B6 重复 P0-8（`:77`），C2 与 P0-3 重叠（`:98`），D3 为 P0 但速答表无对应项（`:116`）。按 §10 的回答顺序会出现“同一问题被问两遍/漏答 D3”。
**requiredFix**：保留速答表为唯一 P0 入口，分类表内重复项改为“见 P0-x”；或反之，并在 §10 顺序中显式包含 D3/F6。

### F5 · low · 证据行号偏差
`open-questions.md:20` 把 `LEG_FF_WHEEL_TRACK` 标为 `Chassis.h:54`，实际在 `:55`（`:54` 是 `LEG_FF_LEG_MASS_RATIO`）；同表 `:51` 的 A2 证据把 `Chassis.cpp:1549` 当成用法，实为条件卫语句。
**requiredFix**：改为 `Chassis.h:55`；A2 证据改为 `Chassis.cpp:1558,1596,1873,1877,1921,2010,2015`。

## 4. 其他检查结论（无 finding）
- 链接：`structure-proposal.md` 仅 1 个相对链接，目标存在；其余路径为代码块示例文本，不算坏链。
- 结构方案：目录树符合 C（`firmware/`、`simulation/` 迁移，`researchs/` 原地 + 索引）；S0–S4 顺序、tag、回退命令自洽（除 F1/F2）。
- 执行规范：时间盒、大文件阈值、防截断（>60 行落文件）、卡死判定与上报模板齐备、可直接执行；已回应“长时间思考/卡死/输出截断”。
- 未复核（不作结论）：主频实际值、`BOARD_PROTOCOL` 协议设计、线上状态编码、`verify_leg_kinematics.m` 的 7 参调用（未逐行确认）。

## 5. 结论
方案可用、证据扎实，需先修 F1/F2（否则 S0–S3 会丢 hex、仓库膨胀且忽略规则失效），F3/F4/F5 为文档一致性修正。修完即可 pass。
