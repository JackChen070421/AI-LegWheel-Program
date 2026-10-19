# tests — 测试（预留）

> 当前没有测试框架；先占位，避免以后临时造目录。

## 计划

| 类型 | 内容 | 状态 |
|---|---|---|
| Host 单元测试 | PID/LQR/VMC/CRC/协议解析等纯逻辑 | 待建 |
| 协议测试 | CAN 帧编解码、状态映射、超时/仲裁 | 待建（依赖 `docs/02-architecture/can-protocol.md`） |
| 日志回放 | 用 `experiments/logs/` 的 VOFA 数据回归控制逻辑 | 待建 |
| 台架检查 | 电机方向/限位/急停/电流 | 见 `docs/08-quality/review-checklist.md` |

## 规则

- 测试代码不进入 `firmware/` 的发布构建；
- 每个测试写清输入、期望、如何运行；
- 硬件相关测试必须在轮子离地/限流条件下进行；
- 新增测试在 `CHANGELOG.md` 记录。
