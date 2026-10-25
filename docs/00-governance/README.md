# 00-governance — 协作与记录规范

> 这里放“怎么协作、怎么记录、怎么回退”。agent 入口仍是 [`../../AGENTS.md`](../../AGENTS.md)。

## 文件/规范

| 主题 | 位置 |
|---|---|
| agent 入口 + 黄金原则 | [`AGENTS.md`](../../AGENTS.md) |
| 用户指令 → 固定动作（快捷指令） | [`SHORTCUT.md`](../../SHORTCUT.md) |
| 执行纪律/防卡死/提示词 | [`../00-plan/agent-execution-policy.md`](../00-plan/agent-execution-policy.md) |
| 结构提案 | [`../00-plan/structure-proposal.md`](../00-plan/structure-proposal.md) |
| 变更记录 | [`CHANGELOG.md`](../../CHANGELOG.md) |
| 决策记录 | [`../07-decisions/`](../07-decisions/README.md) |
| 快照/删除清单 | `archive/manifests/`（[S0](../../archive/manifests/S0-BASELINE.md)、[Tier A](../../archive/manifests/TIER-A-DELETION-20261019.md)） |

## 命名与写作

- 目录/文件名：英文 `kebab-case`；文档内容中文；具体资料文件保留中文名；
- 日期：`YYYY-MM-DD`；ADR：`NNNN-title.md`；实验：`YYYY-MM-DD-主题.md`；
- 每个数值给来源；不确定写 `TBD` 并进 `docs/00-plan/open-questions.md`；
- 单文档正文 ≤300 行（提案/ADR/附录/证据索引不计）。

## 记录规则

1. **每次改动**写 `CHANGELOG.md`（时间、类型、内容、验证、回退）；**倒序排列：最新在上**；
2. **结构/构建/参数来源**变更写 ADR（`docs/07-decisions/`）；
3. **删除/迁移**前有快照或 git 提交；删除清单进 `archive/manifests/`；
4. **实验**用 `docs/05-experiments/test-log-template.md`；
5. **审阅**：非作者抽查 ≥5 条证据，报告放 `docs/00-plan/supervisor-review*.md`。

## 回退

| 场景 | 命令/位置 |
|---|---|
| 回到 S0 | `git reset --hard pre-structure-20261019` |
| 回到 S0 记录 | `git reset --hard s0-baseline` |
| 数据文件（含 Tier A/研究资料） | 从 `archive/snapshots/snapshot-20261019.tar` 解包 |
| 单个文件 | `git checkout <tag> -- <path>` 或从快照取 |

> 当前不 push 远端（用户 2026-10-19 决定）；快照是唯一异地前的完整备份。

## AI 协作

- 先读 `AGENTS.md` → 本目录 → 任务相关文档；
- 不编造；不确定先问；时间盒/卡死上报按 `agent-execution-policy.md`；
- 长产出落文件，消息只放摘要；改完给“改了什么/验证/证据/未决/下一步”。

## 目录约定

| 目录 | 放什么 |
|---|---|
| `docs/00-plan/` | 提案、问题清单、待办、执行规范（临时/规划） |
| `docs/00-governance/` | 本目录：协作、记录、回退 |
| `docs/01-product/` | 目标、阶段、验收、路线图 |
| `docs/02-architecture/` | 软硬件/控制/通信/构建 |
| `docs/03-theory/` | 动力学、VMC、LQR、LESO、状态机 |
| `docs/04-parameters/` | 参数台账（唯一事实源） |
| `docs/05-experiments/` | 实验/标定/报告 |
| `docs/06-plans/` | 计划/backlog |
| `docs/07-decisions/` | ADR |
| `docs/08-quality/` | 质量门/review |
| `docs/09-references/` | 外部资料索引 |
