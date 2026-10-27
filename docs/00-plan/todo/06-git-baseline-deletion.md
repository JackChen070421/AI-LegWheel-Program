# TODO-06 · Git 基线范围、旧车代码、删除授权

> 状态：✅ S0 已完成；✅ Tier A 已删除；⏳ 旧车代码后续统一移入（不阻塞 S1）  
> 优先级：P0　负责人：你 + AI  
> 对应：`open-questions.md` P0-10、P0-11、E1、E2、E8、F1、F2、F6  
> 关联：`docs/00-plan/structure-proposal.md` §6–§7、`archive/manifests/S0-BASELINE.md`、`CHANGELOG.md`、`shortcut.md`

## 1. 要解决的问题

1. **P0-10**：git 基线只跟踪文本（推荐）还是全量/LFS？旧车代码/历史版本在哪？是否需要远端？
2. **P0-11**：Tier A 删除是否授权？Tier B 是否需要逐项确认？

## 2. 当前进展（2026-10-19）

- ✅ **S0 已完成**：全量快照 + manifest + git 初始提交 + tag `pre-structure-20261019`；
- ✅ 快照：`archive/snapshots/snapshot-20261019.tar`，1,838,510,080 B，SHA-256 `6ac9cd8b…a75d075`，8,451 条目；
- ✅ git：`main` / `1d05ac4af853737431aab669c4b4277dbeef31ce` / 770 文件 / pack 24.92 MiB；
- ✅ hex 留档：`archive/legacy/hex-2026-10-18/LegWheel.hex`（494,095 B，SHA-256 已记）；
- ✅ 详细记录：`archive/manifests/S0-BASELINE.md`；
- ✅ **Tier A 已删除**（2026-10-19；见 §2.2/删除记录）；Tier B 未删；
- ⏳ 旧车代码/历史版本：用户暂不提供，后续统一移入 `archive/legacy/`，不并入当前工作区（见 §2.4）。

### 2.1 用户决定（2026-10-19）

- **远端：暂时不需要（2026-10-19 决定）**；本地 git 即可（备份靠快照）。**2026-10-27 更新：`origin` 已配置；push/PR 需逐次授权，`main` 不直推。**
- **git 范围：文本-only + 全量快照**（S0 已执行）；不把 1.7 GB 二进制塞进 git。
- **旧车代码/历史版本**：用户 2026-10-19 决定“暂不提供，后续统一移入，担心干扰”——先隔离，后续按 §2.4 流程并入。
- **Tier A 删除：✅ 已授权并删除**（2026-10-19，明细见 `archive/manifests/TIER-A-DELETION-20261019.*`）；**Tier B 不删**（解释见 §2.2）。

### 2.2 Tier A / Tier B 是什么

| 级别 | 含义 | 例子 | 体量 | 建议处理 |
|---|---|---|---:|---|
| **Tier A** | 可重建/重复/无用的构建与缓存 | `build/`、`uvguix`、`slprj`、`tmp`、日志、上交重复 zip、空目录、0 字节占位 | ≈414 MB | 归档到 `archive/trash-20261019/` → 确认后删；不影响源码/构建 |
| **Tier B** | 大体积外部参考资料 | DM-MC02 例程 524.5 MB、3D 98.6 MB、上交视频 ≈365 MB、CMSIS DSP 源码 176.7 MB、山海 44.4 MB | ≈1.2 GB | **保留、不删**；git 忽略；可选移到外部硬盘 |
| **Tier C** | 构建/文档必需 | HAL 14.9 MB、FreeRTOS 1.6 MB、现有源码/文档 | — | 不动 |

> 一句话：**Tier A 是“删了也能再生成”的垃圾；Tier B 是“留着有用但太大”的参考；Tier C 是“不能动”的依赖。**

### 2.3 旧车代码/历史版本：我需要看什么

**必须（有的话最好给我一个完整版本）：**

1. 一个**已知能稳定跑**的旧车固件快照：`Applications/`、`Algorithm/`、`Devices/`、`Bsp/`、`Core/` + `MDK-ARM/*.uvprojx` + `.ioc` + 对应 hex；
2. 旧车的**参数表/K 矩阵**（质量、轮径、轮距、腿长、K 系数），哪怕只是代码里的宏；
3. 如果旧车代码和当前 `LegWheel` 是同一套，只需要**最后一个改动前的版本**。

**有用但不必须：**

- 旧车测试记录/视频/VOFA 日志（能看出“旧车正常”是什么样）；
- 旧车最后烧录的 hex；
- 参数变更的聊天记录/笔记（比代码更能解释“为什么改”）。

**不需要：**

- 每个中间版本的完整副本（1–2 个关键版本足够）；
- 旧版本里的 `Drivers/`、`Middlewares/`、build 产物、3D 模型、视频（和现在重复）；
- 与研究资料重复的厂商例程。

**如果找不到：**

- 直接说“没有”；我会把 `docs/04-parameters/parameters.md` 标为“无旧车基线”，只按当前代码 + 仿真 + 你的口述建立 v0.1；
- 后续靠实车测试逐步补，不再追溯旧车。

**提供方式：**

- 告诉我路径即可（我可以只读）；如果要放进仓库，建议复制到 `archive/legacy/old-car-<日期>/`，**不移动原文件**。

### 2.4 旧车代码移入流程（待执行，用户 2026-10-19 决定）

> 状态：⏸ 暂不提供；用户后续统一移入，避免干扰当前工作区。**不阻塞 S1/S2**。

1. 用户把旧车代码/历史版本放到 `archive/legacy/old-car-<日期>/`（或给外部路径，只读）；
2. AI 只读：列目录，定位 `Applications/`、`Algorithm/`、`MDK-ARM/*.uvprojx`、`.ioc`、hex、参数宏/K；
3. 生成 `archive/manifests/old-car-<日期>.csv`（路径/大小/时间）+ 一页差异报告：旧车 vs 当前 `LegWheel` 的参数/K/状态机差异；
4. **不在 `firmware/` 里直接合并**；只把结论写进 `docs/04-parameters/`、`docs/03-theory/`；
5. 如需编译/运行旧车代码，单独拷到临时目录，不覆盖当前工程；
6. 在 TODO-06 与 `CHANGELOG.md` 记录移入日期/来源/差异。

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
| 远端 | 本地 / 私有 GitHub / Gitee / 其他 | ✅ **已配置 origin**（2026-10-27）；push/PR 逐次授权，`main` 不直推 |
| Tier A 删除 | 立即删 / 归档 3–7 天后删 / 暂不删 | ✅ **已删除**（2026-10-19）：101 行 / 414,476,633 B；可从 S0 快照回退（见 §2.2、`archive/manifests/TIER-A-DELETION-20261019.*`） |
| Tier B | 保留 / 移出工作区 / 删除 | ⏳ 保留、不删；git 忽略；是否移出工作区看磁盘（D 盘剩 15.4 GB）（见 §2.2） |
| 旧车代码 | 在哪？是否归档 | ⏸ 用户暂不提供；后续统一移入 `archive/legacy/`，不并入 `firmware/`（见 §2.4） |

## 5. 要回答它，需要做什么

1. 确认旧车代码/历史版本是否在别的盘、压缩包、队友电脑；
2. 确认远端写操作授权（`origin` 已配置；push/PR 逐次授权，`main` 不直推）；
3. 逐项确认 Tier A 删除清单（`structure-proposal.md` §7）；
4. 决定 Tier B 是否移出工作区（D 盘只剩 15.4 GB 空闲）。

## 6. 解决后的落地动作

- ✅ S0 已完成，记录见 `archive/manifests/S0-BASELINE.md`：
  - 快照 `archive/snapshots/snapshot-20261019.tar`（1,838,510,080 B；SHA-256 `6ac9cd8b…a75d075`）；
  - manifest `archive/manifests/manifest-20261019.csv`（7,147 行）；
  - git 提交 `1d05ac4af853737431aab669c4b4277dbeef31ce`，tag `pre-structure-20261019`；
  - hex 留档 `archive/legacy/hex-2026-10-18/LegWheel.hex`（494,095 B）。
- ✅ Tier A 已删除（2026-10-19）：清单/回退见 `archive/manifests/TIER-A-DELETION-20261019.*`；唯一 Keil 产物 hex 保留；
- ⏳ 更新 `open-questions.md` P0-10/P0-11/E1/E2/E8/F1/F2/F6；
- ✅ 更新 `CHANGELOG.md`（S0 段）。

## 7. 讨论记录

- 2026-10-19：S0 启动；用户确认“可以移动/清理/改 README”，但删除仍需逐项授权。
- 2026-10-19 20:50：S0 完成（快照 + manifest + git + tag）；未删除任何文件。
- 2026-10-19 21:00：用户确认**暂不需要远端**；git 采用文本-only + 全量快照；Tier A/B 解释补入 §2.2；旧车代码待路径/确认（§2.3）。工作区内扫描未发现旧车代码/历史版本，仅有厂商参考资料。
- 2026-10-19 21:10：用户授权**删除所有 Tier A**；101 行（94 文件 + 7 空目录），414,476,633 B；S0 快照可回退；Tier B 未删。
- 2026-10-19 21:20：用户决定旧车代码**暂不提供，后续统一移入**（避免干扰）；已写 §2.4 移入流程，不阻塞 S1/S2。
- 2026-10-26：Git/GitHub 指令流与 `main` 红线集中到 `shortcut.md`；远端仍不 push/不合并；本机 `gh` 未安装、`git ls-remote` 报 `SEC_E_NO_CREDENTIALS`（当日实测）。
- 2026-10-27：远端已配置；push/PR 需逐次授权，`main` 不直推（统一口径见 `shortcut.md` §3）；VPN 下 `git ls-remote` 已成功。
