# 07-decisions — 架构决策记录（ADR）

> 这里记录“为什么这样选”，避免以后反复争论。  
> 命名：`NNNN-short-title.md`；状态：proposed / accepted / superseded。

## 索引

| ADR | 主题 | 状态 |
|---|---|---|
| [`0001-hybrid-structure.md`](./0001-hybrid-structure.md) | C 混合结构 + 文本-only git + 全量快照 + Tier A 删除 | accepted 2026-10-19 |

## 规则

- 一个决定一个文件；写清背景、选项、决定、后果；
- 被推翻时保留原文，标 `superseded by NNNN`，不删；
- 影响结构/构建/参数来源的决定必须写 ADR；
- 小改动只写 `CHANGELOG.md`，不用 ADR。
