# experiments — 实测数据（原始）

> 这里放**原始数据**：VOFA/串口日志、标定数据、视频、测试报告附件。  
> 文字记录/复盘放 [`docs/05-experiments/`](../docs/05-experiments/README.md)。

| 目录 | 内容 | git |
|---|---|---|
| `logs/` | VOFA/串口 CSV、bin、原始文本 | `.csv/.bin` 忽略；大文件不进 git |
| `calibration/` | IMU/电机零点/腿长/云台中值等标定 | 小文本可进；原始数据视大小 |
| `reports/` | 测试报告/复盘附件 | 文本进 git；大附件给路径 |

命名：`YYYY-MM-DD-主题[-v2].扩展名`；在 `docs/05-experiments/` 的记录里引用路径。

规则：不覆盖旧数据；失败数据也保留；大文件放这里但不提交，必要时外部备份。
