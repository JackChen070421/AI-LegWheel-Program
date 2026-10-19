# tools — 脚本与工具

> 放构建/烧录/日志解析/文档抽取的**可复用脚本**；一次性命令放 `archive/`。当前均为预留。

## 计划

| 脚本 | 用途 | 状态 |
|---|---|---|
| `build-keil.ps1` | 调 Keil/UV4 编译并检查 hex | 待写（需 P0-3） |
| `flash.ps1` | DAPLink/ST-Link 烧录 | 待写（需 C4） |
| `extract-html.ps1` | 上交 HTML 去标签/抽正文/保留 `texencoding` | 待写 |
| `log-to-csv.py` | VOFA/串口日志转 CSV/摘要 | 待写 |
| `check-links.ps1` | 检查 docs 相对链接 | 待写 |

## 规则

- 脚本要能重复运行、幂等；不把输出写进仓库（放 `experiments/` 或临时目录）；
- 不在脚本里硬编码个人路径/密钥；路径用参数或仓库相对路径；
- 每个脚本头部写用途、用法、依赖；
- 新增脚本在 `docs/02-architecture/build-and-flash.md` 或本文登记。
