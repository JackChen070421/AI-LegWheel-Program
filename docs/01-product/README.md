# 01-product — 产品与需求

> 这里放“要做成什么”：目标、阶段、需求、验收标准、路线图。  
> 不放代码细节；代码/架构见 `docs/02-architecture/`。

## 文件

| 文件 | 内容 |
|---|---|
| [`overview.md`](./overview.md) | 项目目标、当前阶段、范围、验收口径 |
| [`legacy-readme-2026-10-19.md`](./legacy-readme-2026-10-19.md) | 旧版 README 原文（2026-10-19 重写前） |
| 路线图 | 暂放 [`docs/06-plans/roadmap.md`](../06-plans/roadmap.md) |

## 维护规则

- 验收标准必须可测试（动作、指标、条件）；不能测试的写 `TBD` 并进 `docs/00-plan/open-questions.md`。
- 需求变化先改本文，再改代码；在 `CHANGELOG.md` 记录。
- 不复制参数数值；引用 [`docs/04-parameters/parameters.md`](../04-parameters/parameters.md)。
