# 08-quality — 质量与验收

> 这里放“怎么算做对了”：质量门、测试策略、review 清单。  
> 执行纪律见 [`../00-plan/agent-execution-policy.md`](../00-plan/agent-execution-policy.md)。

## 文件

| 文件 | 内容 |
|---|---|
| [`review-checklist.md`](./review-checklist.md) | 文档/代码/实验交付前的检查清单 |

## 质量门（v0.1）

| 对象 | 必须通过 | 证据 |
|---|---|---|
| 文档 | 数值有来源；链接可点；无编造；TBD 有编号 | `path:line` / 实测日期 / `open-questions` |
| 代码 | 编译通过；说明验证方式；不能验证标“未验证” | Keil build 输出 / 台架记录 |
| 实验 | 有日期、车况、参数、动作、结果 | `docs/05-experiments/` 模板 |
| 结构/删除 | 有快照/提交；删除清单可回退 | `archive/manifests/`、`CHANGELOG.md` |
| 审阅 | 非作者抽查 ≥5 条证据 | `docs/00-plan/supervisor-review*.md` |

## 安全门

- 急停、电机、电源、云台联调：**轮子离地/限流**台架验证后才能上实车；
- 任何“取消限幅/提高电流/改急停”的改动必须单独说明并留记录；
- 不确定时先降级（限速/限力矩），不要靠调参硬顶。
