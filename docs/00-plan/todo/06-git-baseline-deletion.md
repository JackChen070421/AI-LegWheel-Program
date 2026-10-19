# TODO-06 · Git 基线范围、旧车代码、删除授权

> 状态：✅ S0 已完成（2026-10-19）；⏳ 待 P0-11 删除授权、旧车代码/远端  
> 优先级：P0　负责人：你 + AI  
> 对应：`open-questions.md` P0-10、P0-11、E1、E2、E8、F1、F2、F6  
> 关联：`docs/00-plan/structure-proposal.md` §6–§7、`archive/manifests/S0-BASELINE.md`、`CHANGELOG.md`

## 1. 要解决的问题

1. **P0-10**：git 基线只跟踪文本（推荐）还是全量/LFS？旧车代码/历史版本在哪？是否需要远端？
2. **P0-11**：Tier A 删除是否授权？Tier B 是否需要逐项确认？

## 2. 当前进展（2026-10-19）

- ✅ **S0 已完成**：全量快照 + manifest + git 初始提交 + tag `pre-structure-20261019`；
- ✅ 快照：`archive/snapshots/snapshot-20261019.tar`，1,838,510,080 B，SHA-256 `6ac9cd8b…a75d075`，8,451 条目；
- ✅ git：`main` / `1d05ac4af853737431aab669c4b4277dbeef31ce` / 770 文件 / pack 24.92 MiB；
- ✅ hex 留档：`archive/legacy/hex-2026-10-18/LegWheel.hex`（494,095 B，SHA-256 已记）；
- ✅ 详细记录：`archive/manifests/S0-BASELINE.md`；
- ⏳ **未删除任何文件**；Tier A 删除要等你授权（P0-11）；
- ⏳ 旧车代码位置、远端仓库仍待确认（P0-10 剩余部分）。

## 3. 目前已知（证据）

| 事实 | 证据 |
|---|---|
| 无 `.git` | 全工作区 0 个 `.git` 目录 |
| 总体量 | 1.70 GB / 7,131 文件 |
| 研究资料 | `researchs/` 1,483.8 MB / 5,403 文件（约 87%） |
| 可安全回收 | Tier A ≈414 MB（build/uvguix/slprj/tmp/zip/空目录） |
| 可归档 | Tier B ≈1.2 GB（例程 524.5、3D 98.6、视频 ≈365、DSP 源码 176.7、山海 44.4） |
| 唯一 Keil 产物 | `LegWheel.hex` 494,095 B，2026-10-18 21:38 |
| 旧车代码 | 未找到独立副本；README 说“旧车被拆了，换新车” |

## 4. 需要你拍板

| 事项 | 选项 | 当前状态 |
|---|---|---|
| git 范围 | A 文本-only + 全量快照 / B 全量 + LFS | **已采用 A**（2026-10-19）：770 文件 / pack 24.92 MiB + 1.71 GiB tar 快照 |
| 远端 | 本地 / 私有 GitHub / Gitee / 其他 | ⏳ 先本地；远端等你确认 |
| Tier A 删除 | 立即删 / 归档 3–7 天后删 / 暂不删 | ⏳ 待你授权（P0-11）；先归档到 `archive/trash-20261019/` |
| Tier B | 保留 / 移出工作区 / 删除 | ⏳ 只移出 git，不删；是否移出工作区看磁盘（D 盘剩 15.4 GB） |
| 旧车代码 | 在哪？是否归档 | ⏳ 未找到；找到后进 `archive/legacy/` |

## 5. 要回答它，需要做什么

1. 确认旧车代码/历史版本是否在别的盘、压缩包、队友电脑；
2. 确认是否有远端仓库、是否允许 push；
3. 逐项确认 Tier A 删除清单（`structure-proposal.md` §7）；
4. 决定 Tier B 是否移出工作区（D 盘只剩 15.4 GB 空闲）。

## 6. 解决后的落地动作

- ✅ S0 已完成，记录见 `archive/manifests/S0-BASELINE.md`：
  - 快照 `archive/snapshots/snapshot-20261019.tar`（1,838,510,080 B；SHA-256 `6ac9cd8b…a75d075`）；
  - manifest `archive/manifests/manifest-20261019.csv`（7,147 行）；
  - git 提交 `1d05ac4af853737431aab669c4b4277dbeef31ce`，tag `pre-structure-20261019`；
  - hex 留档 `archive/legacy/hex-2026-10-18/LegWheel.hex`（494,095 B）。
- ⏳ Tier A 删除前，把清单复制到 `archive/trash-20261019/` 并保留 3–7 天；
- ⏳ 更新 `open-questions.md` P0-10/P0-11/E1/E2/E8/F1/F2/F6；
- ✅ 更新 `CHANGELOG.md`（S0 段）。

## 7. 讨论记录

- 2026-10-19：S0 启动；用户确认“可以移动/清理/改 README”，但删除仍需逐项授权。
- 2026-10-19 20:50：S0 完成（快照 + manifest + git + tag）；未删除任何文件。
