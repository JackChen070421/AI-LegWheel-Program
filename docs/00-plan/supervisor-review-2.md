# 交付前二次审阅（Supervisor / t5）

> 日期：2026-10-19　对象：`structure-proposal.md`、`open-questions.md`、`agent-execution-policy.md`、`CHANGELOG.md`（均为 F1–F5 修订后版本）
> 方式：只读；逐条比对 F1–F5 + 8 项新改动抽查（路径/编号/体量/链接/长度规则）。
> **verdict：pass**　findings：0（无阻断项；2 条非阻断建议见 §4）

## 1. F1–F5 逐条确认
| # | 要求 | 证据 | 判定 |
|---|---|---|---|
| F1 | S2 改文件系统移动 + `git add -A` | proposal:197-199（`Move-Item`、`git add -A`）；:151 映射表同步 | ✅ |
| F1 | hex 留档行 + archive 副本 | :153（留档行）、:194（`Copy-Item … archive\legacy\hex-2026-10-18\`）、:317 Tier C 声明不删 | ✅ |
| F1 | S2 验证 manifest 前后对比（含 hex SHA-256/494,095 B） | :204、:180、:422 | ✅ |
| F1 | 空壳删除前置条件 | :154（两子目录完整移动 + manifest 通过 + hex 校验后才删） | ✅ |
| F2 | `**/` 同时命中迁移前后 | :255-257（`**/Drivers/CMSIS/DSP/*` + 注释说明 S0 在迁移前提交） | ✅ |
| F2 | DSP 忽略、`DSP/Lib/**` 否定保留 | :257-259（`!…/Lib/`、`!…/Lib/**`，否定项在后，父目录未被排除 → git 语义成立） | ✅ |
| F2 | S0 `git check-ignore -v` 验证 | :179（DSP 源码应忽略、`arm_cortexM7lfdp_math.lib` 不应忽略） | ✅ |
| F2 | archive hex 被 `**/*.hex` 忽略的说明 | :275（并给出 `!archive/legacy/**/*.hex` 可选保留） | ✅ |
| F3 | P0 = 16（11 + 5） | proposal:16、:449；questions:55；速答表实有 P0-1…P0-11（questions:33-43） | ✅ |
| F3 | P0-11 存在 | questions:43（Tier A 删除授权，S3 准入门槛） | ✅ |
| F3 | 计数与编号一致 | questions:29 “11 条”、:55 “16 条”、:198 “P0-1~P0-11”；无残留 9/10 条 | ✅ |
| F4 | A2↔B5/A3↔P0-4/A4↔P0-5/B6↔P0-8/C2↔P0-3/F6↔P0-11 | questions:64、65、66、89、90、111、163 均带“（P0-x 详细版）/见 P0-x” | ✅ |
| F4 | D3 进补充 P0；§10 含 D3/F6 | questions:53（§1.1 表）、:129、:201（D3）、:200（P0-11/F6） | ✅ |
| F5 | 轮距行号 `Chassis.h:55` | questions:20 | ✅ |
| F5 | A2 证据去掉 1549 | questions:64（1549 已标注为卫语句，仅作说明，不再作为用法） | ✅ |

## 2. 新改动抽查（8 项，均未引入新矛盾）
1. 编号：P0-1…P0-11 连续无重复；补充 5 项 A1/A11/A12/C3/D3 与 §1.1 表一致。
2. 路径：`archive/legacy/hex-2026-10-18/` 在 §4:153、S1:184、S2:194、§6.2:275、Tier C:317 五处完全一致。
3. 体量：hex 494,095 B 在 7 处出现且一致（:48/:153/:180/:195/:422/:317/附录:467）；Tier A ≈414 MB、Tier B ≈1.2 GB 未变。
4. 链接：全文唯一相对链接 `structure-proposal.md:16 → ./open-questions.md` 仍有效；无新增链接。
5. `.gitignore` 语法：`DSP/*` 只忽略直接子项，`!DSP/Lib/` 重新纳入目录、`!DSP/Lib/**` 纳入内容；否定规则位于其后、父目录未被整体排除，git 可正确恢复 `arm_cortexM7lfdp_math.lib`。
6. S2 步骤编号 1–6 自洽：留档（1）→ 移动（2）→ `git add -A`（3）→ 更新引用（4）→ 验证（5）→ 回退（6）。
7. `MDK-ARM/tmp/` 的“CMake 临时目录”描述经核为真（内含 `CMakeFiles/3.31.5/…`），非误标。
8. 文档长度规则：policy:129 与 proposal:406 表述一致（正文 ≤300 行，提案/ADR/附录/证据索引不计）；open-questions 204 行、policy 139 行、CHANGELOG 62 行均达标，proposal 477 行属“提案”豁免 → 规则自洽。

## 3. 覆盖度回顾
t1/t2/t3 关键结论仍全部在文：K 三份、14.3 kg 自洽、双构建入口、`.ioc` 漂移、`BOARD_PROTOCOL.md` 缺失、轮距三种用法（措辞保留“可能/待确认”）、清理体量、空文件/空目录、zip 重复。

## 4. 非阻断建议（不构成 finding）
- `open-questions.md:91/149/159` 的 B7、E8、F2 仍标 P0 且未加“见 P0-9/P0-10”，依赖 :55 的非穷举“如”来支撑“16 条”计数；语义上确为重复项，计数无误，下次顺手补指针更稳。
- 本轮新增 `docs/00-plan/supervisor-review-2.md` 后，`CHANGELOG.md` 需补一行记录（t4 的 `supervisor-review.md` 已在 :46 登记）。

## 5. 结论
F1–F5 全部修复且未引入新矛盾，可交付。S2 前仍以 P0 答案与用户确认为准（提案本身未执行任何迁移/删除）。
