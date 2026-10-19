# ADR-0001：采用 C 混合结构 + 文本-only git + 全量快照

- 状态：accepted
- 日期：2026-10-19
- 决策人：用户 + Captain
- 关联：`docs/00-plan/structure-proposal.md`、`archive/manifests/S0-BASELINE.md`、`docs/00-plan/todo/06-git-baseline-deletion.md`

## 背景

- 工作区 1.70 GB / 7,131 文件，其中 `researchs/` 约 1.1 GB（厂商资料/视频/3D/参考代码）；
- 没有 git；README 却让看提交历史；
- 代码/仿真目录名带中文，迁移有风险；
- 旧车代码/历史版本暂未提供，用户担心干扰当前工作区；
- K 矩阵有三份候选，构建入口不清，参数口径未定（P0）。

## 选项

| 方案 | 做法 | 代价 |
|---|---|---|
| A | 只新增文档，现有目录不动 | 最安全；但结构长期混乱 |
| B | 一次性物理迁移到新树 | 快；但无回退、风险高 |
| **C** | 新建目标树；代码/仿真 S2 迁移；`researchs/` 原地索引 | 分步、可回退；需要两阶段 |
| D | 全量 git/LFS | 1.7 GB 进 git，慢/重，收益低 |

## 决定

1. 采用 **C 混合结构**：
   - `firmware/LegWheel/`、`simulation/chassis-lqr/` 作为目标位置，**已于 S2（2026-10-19）迁移**；
   - `researchs/` 原地保留，只建索引（`docs/09-references/index.md`）；
   - 新增 `docs/00–09`、`hardware/`、`experiments/`、`tools/`、`archive/`。
2. **文本-only git + 全量 tar 快照**：
   - git 跟踪源码/文档/必要库（771 文件，pack 5.46 MiB）；
   - 快照 `archive/snapshots/snapshot-20261019.tar`（1.71 GiB）覆盖全部数据文件；
   - 不把 1.7 GB 二进制放进 git。
3. **Tier A 删除**：可再生的构建缓存/重复文件/空文件，用户 2026-10-19 授权删除（101 行 / 414 MB）；**Tier B 保留**（参考资料，git 忽略）。
4. **旧车/外部代码隔离**：后续统一放 `archive/legacy/`，未确认前不并入 `firmware/`。
5. **远端**：暂不需要；本地 git + 快照即可（以后要再加）。

## 后果

- 仓库轻、回退快；研究资料仍可查；
- S2 已完成（2026-10-19）：manifest 前后对比 0 缺失；待 Keil 打开/编译验证；剩余风险是 `.ioc` 漂移与旧绝对路径。
- 旧车基线缺失，参数表只能从当前代码/仿真/实测建立（已标 TBD）；
- Tier B 占磁盘；D 盘剩约 15 GB，暂不移动。

## 被否决

- **A**：解决不了“单一事实源/可回退/可移植”；
- **B**：没有 git 时一次性迁移风险太高；
- **D**：全量 git/LFS 对 1.7 GB 参考资料不划算，且会拖慢日常操作。
