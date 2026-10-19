# 05-experiments — 实验与标定

> 这里放“怎么验证、测到了什么”：测试记录、标定数据、报告。  
> 原则：可复现、可追溯、不编造；每条记录带日期、车况、参数、动作、结果。

## 目录

| 目录 | 放什么 | git |
|---|---|---|
| [`logs/`](../../experiments/logs/README.md) | VOFA/串口日志、CSV、原始数据 | `.csv/.bin` 默认忽略；大文件不进 git |
| [`calibration/`](../../experiments/calibration/README.md) | IMU、电机零点、腿长、云台中值等标定 | 小文本可进；原始数据视大小 |
| [`reports/`](../../experiments/reports/README.md) | 测试报告、复盘、对比 | 进 git |

## 命名

- 记录：`YYYY-MM-DD-主题.md`（如 `2026-10-20-第一次平地平衡.md`）；
- 日志：`YYYY-MM-DD-主题.csv` / `.bin` / `.mp4`；
- 标定：`YYYY-MM-DD-传感器-方法.md`；
- 同一主题多次测试加 `-v2`。

## 最小记录字段

见 [`test-log-template.md`](./test-log-template.md)；至少包含：

1. 日期/时间、git commit、谁操作；
2. 车况（电池电压、气弹簧/云台是否装、轮胎）；
3. 参数（引用 `docs/04-parameters/parameters.md` + 本次改动）；
4. 动作（状态、输入、场地）；
5. 结果（成功/失败、视频/日志路径、异常）；
6. 结论与下一步（是否改参数/K/代码）。

## 规则

- 不把“感觉”写成“数据”；没有测量就写“主观观察”；
- 失败记录同样保留（比成功更有用）；
- 大文件放 `experiments/`，不要提交进 git；需要时在记录里给路径；
- 每次实验后更新 `docs/04-parameters/`（如果测到新值）与 `CHANGELOG.md`。
