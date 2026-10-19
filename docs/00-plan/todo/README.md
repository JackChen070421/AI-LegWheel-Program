# 用户待办（P0）— 逐项解决

> 建立：2026-10-19。你目前无法回答这些问题，**这不是阻塞**：每个文件是一个可独立推进的议题。  
> 用法：挑一个 → 让 AI 读本文件 + 相关代码 → AI 给选项/测量方法 → 你拍板 → AI 记录结论 → 更新状态与 `open-questions.md`。

## 状态图例
⬜ 未开始 · 🔎 调研中 · 🧪 待实测 · ✅ 已解决 · ⏸ 挂起

## 清单

| 文件 | 覆盖 | 优先级 | 状态 | 建议顺序 |
|---|---|---|---|---|
| [01-k-matrix.md](./01-k-matrix.md) | P0-1/P0-2：K 矩阵来源与生成链 | P0 | ⬜ | 3 |
| [02-build-entry.md](./02-build-entry.md) | P0-3：唯一构建入口/工具链 | P0 | ✅ Keil+CubeMX；🔎 烧录/编译器 | 2 |
| [03-mass-parameters.md](./03-mass-parameters.md) | P0-4/P0-5：14.3 kg 口径、0.788 vs 1.067 | P0 | ⬜ | 4 |
| [04-wheel-track.md](./04-wheel-track.md) | P0-6：轮距定义与三种用法 | P0 | ⬜ | 5 |
| [05-protocol-estop-state.md](./05-protocol-estop-state.md) | P0-7/8/9：协议、急停、状态映射 | P0 | ⬜ | 6 |
| [06-git-baseline-deletion.md](./06-git-baseline-deletion.md) | P0-10/P0-11：基线范围、旧车代码、删除授权 | P0 | ✅ S0/Tier A；⏸ 旧车代码 | 1 |
| [07-supplement-p0.md](./07-supplement-p0.md) | A1/A11/A12/C3/D3：轮径、电机、IMU、.ioc、CAN3 | P0 | ⬜ | 7 |

> 建议先做 **06**（不依赖技术答案，且 S0 已在做）→ **02** → **01** → **03** → **04** → **05** → **07**。

## 每个文件的固定结构

1. **要解决的问题**（对应 `open-questions.md` 的编号）
2. **为什么现在要解决**
3. **目前已知（证据 `path:line`）**
4. **可选方案**（A/B/C，供你判断；AI 不替你拍板）
5. **要回答它，需要做什么**（查资料/测量/做实验/问人）
6. **解决后的落地动作**（更新哪份文档/哪个参数）
7. **讨论记录**（日期 + 结论 + 谁确认）

## 解决后的联动

- 把本文件状态改为 ✅，写结论与日期；
- 更新 `docs/00-plan/open-questions.md` 对应行；
- 更新目标文档：`docs/04-parameters/parameters.md`、`docs/03-theory/k-matrix.md`、`docs/02-architecture/build-and-flash.md`；
- 在 `CHANGELOG.md` 记一条；
- 如果影响迁移，回到 `structure-proposal.md` 的 S0–S4。

## 与 AI 协作的推荐提示词

```text
请读 docs/00-plan/todo/<本文件>、docs/00-plan/open-questions.md 的相关条目，
以及 <相关代码/文档>。不要改文件。
给我：① 当前已知证据（path:line）② 2–3 个可选方案及代价
③ 为了回答还缺什么（测量/查资料/实验）④ 推荐哪个，为什么。
我确认后再更新文档。
```
