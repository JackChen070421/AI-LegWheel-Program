# 变更记录

本文件记录项目结构、文档、代码的变更，便于回退。  
格式：日期 / 类型 / 内容 / 验证 / 回退。

---

## 2026-10-19 — 结构提案（仅新增文档，未动现有文件）

### 新增
- `docs/00-plan/structure-proposal.md` — 目标目录树、现状→目标映射、S0–S4 步骤、清理清单、git/回退方案、AGENTS.md 草案、README 重写大纲、验收标准
- `docs/00-plan/open-questions.md` — P0 速答表 + A–H 分类问题清单（参数/控制/构建/云台/资料/治理/未来/实验）
- `docs/00-plan/agent-execution-policy.md` — 时间盒、大文件规则、防截断交接、卡死判定、提示词模板、监管者职责
- `CHANGELOG.md` — 本文件

### 未做（明确边界）
- 未移动、删除、重命名任何现有文件/目录
- 未修改 `README.md`、`STRUCTURES.md`、`ARCHITECTURE.md`、`docs/papers.md`
- 未修改固件/仿真代码、构建配置、`.ioc`
- 未执行 git init、未生成快照、未 push

### 依据
- 根目录 `README.md`（今晚四步、对 AI 的要求）
- AgentTeams `lg-ai-process-structure` 的 t1（固件/构建）、t2（仿真/资料）、t3（监管审阅）
- Captain 定点复核：`Chassis.cpp:13`、`Chassis.h:52-55`、`vmc.cpp:22-23`、`lqr_coeffs.cpp:6/48`、`MDK-ARM/LegWheel.uvprojx:341/1153`、`MDK-ARM/LegWheel/LegWheel.hex`（494,095 B，2026-10-18 21:38）、`build/`（2026-10-02）、`LegWheel.ioc`（2026-08-27）vs `freertos.c`（2026-10-18）

### 验证
- 新增文件可读；文内相对链接指向 `docs/00-plan/` 内文件
- 现有文件未改动；工作区除新增 `docs/00-plan/` 与 `CHANGELOG.md` 外无变化
- 未运行构建/烧录（今晚不涉及）

### 回退
- 删除上述新增文件即可；现有文件未动，无需回退。
- 环境备注（非文件内容变更）：开工前修复了工作区根目录的 Windows 文件权限，报告与回滚脚本在 `D:\RM\dsh-acl-recovery-20261019\`。

### 下一步（待用户确认）
- 回答 `open-questions.md` 的 P0（至少 K 来源、构建入口、质量口径、轮距、协议、基线范围）
- 确认目标目录树、Tier A 删除清单、git 范围
- 之后按 S0 → S1 执行；S2 前另出迁移检查单

---

## 2026-10-19 — 监管审阅后的修订（F1–F5）

### 新增（监管者）
- `docs/00-plan/supervisor-review.md` — t4 独立审阅报告，verdict=needs_revision（2 high / 2 medium / 1 low）
- `docs/00-plan/supervisor-review-2.md` — t5 二次审阅报告，verdict=pass（0 findings）

### 修订
- `structure-proposal.md`：
  - **F1**：S2 改为文件系统 `Move-Item` + `git add -A`（`git mv` 不会搬未跟踪的 hex）；新增 `LegWheel.hex` 留档行与 `archive/legacy/hex-2026-10-18/` 副本；S2 验证改为 manifest 前后对比（含 hex SHA-256/494,095 B）；`codes-chassis/` 空壳删除增加前置条件。
  - **F2**：`.gitignore` 改用迁移前/后都命中的 `**/` 模式；DSP 源码忽略、`DSP/Lib/**` 用否定规则保留；S0 增加 `git check-ignore -v` 验证（DSP 源码应忽略、`arm_cortexM7lfdp_math.lib` 不应忽略）。
  - **F3/F4**：P0 统一定义为 16 条（速答表 11 + 补充 5）；新增 P0-11（Tier A 删除授权）；补充 §1.1 与交叉引用；更新回答顺序。
  - **F5**：轮距行号改为 `Chassis.h:55`；A2 证据去掉卫语句 `Chassis.cpp:1549`。
- `open-questions.md`：同步上述 P0 编号/交叉引用/行号修正。
- `agent-execution-policy.md`：文档长度规则明确为“正文 ≤300 行（提案/ADR/附录/证据索引不计）”。
- 收尾：B7/E8/F2 补交叉引用（P0-9/P0-10），P0 计数说明同步。

### 验证
- 监管者 t4 的 18 条事实抽查全部通过；F1–F5 已逐条修订。
- 监管者 t5 二次审阅：verdict=pass，0 findings；F1–F5 逐条确认，另抽查 8 项新改动无矛盾。
- 未移动/删除/重命名任何现有文件；未改代码/构建配置。

### 待办
- t5 已 pass，本次文档交付完成。
- 后续 S0–S4 执行前，仍需用户回答 P0（速答 11 + 补充 5）并确认目录树/删除清单/git 范围。

---

## 2026-10-19 — 用户待办文件夹 + S0 基线

### 新增：用户待办
- `docs/00-plan/todo/README.md` — 待办索引、状态图例、与 AI 协作提示词
- `docs/00-plan/todo/01-k-matrix.md` — P0-1/P0-2
- `docs/00-plan/todo/02-build-entry.md` — P0-3
- `docs/00-plan/todo/03-mass-parameters.md` — P0-4/P0-5
- `docs/00-plan/todo/04-wheel-track.md` — P0-6
- `docs/00-plan/todo/05-protocol-estop-state.md` — P0-7/P0-8/P0-9
- `docs/00-plan/todo/06-git-baseline-deletion.md` — P0-10/P0-11
- `docs/00-plan/todo/07-supplement-p0.md` — A1/A11/A12/C3/D3
- `docs/00-plan/todo/TEMPLATE.md`

### S0 基线（完成）
- **全量快照**：`archive/snapshots/snapshot-20261019.tar`，1,838,510,080 B，SHA-256 `6ac9cd8b…a75d075`，8,451 条目；排除 `archive/snapshots`、`.git`、`.agent-teams`。
- **manifest**：`archive/manifests/manifest-20261019.csv`，7,147 行，总字节 1,822,177,166；文本 + hex 记 SHA-256。
- **Keil 产物留档**：`archive/legacy/hex-2026-10-18/LegWheel.hex`，494,095 B，SHA-256 `c41529ff…1dd9ce`（与源文件一致）。
- **git 基线**：`main` 首次提交 `1d05ac4af853737431aab669c4b4277dbeef31ce`，tag `pre-structure-20261019`；770 个跟踪文件，pack 24.92 MiB。
- **`.gitignore`**：跟踪固件源码/必要 HAL/CMSIS/FreeRTOS/文档；忽略 `researchs/`、build/slprj/uvguix、DSP 的 GCC/IAR/其他 ARM 库（164 MB），只保留 `DSP/Lib/ARM/arm_cortexM7lfdp_math.lib`（2.1 MB）；`arm_math.h` 来自 `Middlewares/ST/ARM/DSP/Inc/`（已跟踪）。
- **记录**：`archive/manifests/S0-BASELINE.md`（快照/清单/回退命令）。
- **未做**：未删除/移动任何现有文件；未执行 S1/S2；Tier A 删除仍等 P0-11 授权。

### 验证
- `tar -tf` 退出码 0；快照关键文件存在、排除项不存在；hex 源/留档 SHA-256 一致。
- `git status` clean；`git check-ignore` 对 researchs/build/DSP 源码/GCC 库/源 hex 命中，对 DSP ARM lib / Middlewares arm_math.h / archive hex 不命中。
- 提交后 `git ls-files` 770；无 researchs/build/uvguix/zip/mp4/sldasm 被跟踪。

### 待办
- S0 报告与 `.gitignore` 细化将作为第二次提交（`docs: record S0 baseline`）；tag 保持在首次提交。
- Tier A 删除、旧车代码位置、远端、S1 是否执行，等用户决定。

---

## 2026-10-19 — 用户决定（TODO-06）

- **远端**：暂时不需要；本地 git + 快照即可（以后要再加）。
- **git 范围**：文本-only + 全量快照（S0 已按此执行）。
- **Tier A/B 解释**补入 `docs/00-plan/todo/06-git-baseline-deletion.md` §2.2：
  - Tier A ≈414 MB：可重建/重复/无用的构建缓存与空文件；
  - Tier B ≈1.2 GB：大体积外部参考资料，保留不删、git 忽略；
  - Tier C：构建/文档必需，不动。
- **旧车代码/历史版本需求清单**补入 TODO-06 §2.3；工作区扫描未发现旧车代码，仅有厂商参考资料；待用户提供路径或确认“没有”。
- 未删除、未移动任何文件。
