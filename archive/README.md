# archive — 快照 / 历史 / 删除记录

> 这里放“可回退”的东西：全量快照、legacy、删除清单、待删暂存。日常文件不要放这里。

| 目录 | 内容 |
|---|---|
| `manifests/` | 文件清单、S0 记录、Tier A 删除记录 |
| `legacy/` | 旧版 hex、未来旧车代码/历史版本 |
| `snapshots/` | 全量 tar 快照（git 忽略） |
| `trash-20261019/` | 本次 Tier A 直接删除的说明（无文件） |

## 规则

- 删除/迁移前必须：快照或 git 提交 + 清单；
- 旧车/外部代码先放 `legacy/`，不要在 `firmware/` 里混用；
- 快照不进 git；恢复命令见 [`manifests/S0-BASELINE.md`](./manifests/S0-BASELINE.md)。
