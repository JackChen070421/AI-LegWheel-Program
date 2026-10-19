# 02-architecture — 架构

> 这里放“系统怎么组成、数据怎么流、怎么构建/烧录”。  
> 只写结构与证据；参数数值引用 `docs/04-parameters/`。

## 文件

| 文件 | 内容 |
|---|---|
| [`system.md`](./system.md) | 硬件/软件/控制/通信结构、任务表、状态机、模块地图 |
| [`build-and-flash.md`](./build-and-flash.md) | Keil/CubeMX 现状、构建步骤、烧录、`.ioc` 注意事项 |
| [`hardware-overview.md`](./hardware-overview.md) | 车体/接线旧描述（2026-10-19 从根目录 `STRUCTURES.md` 迁入，待更新） |
| 待建 | `can-protocol.md`（云台协议，等 P0-7/D3）、`state-machine.md`（S4） |

## 维护规则

- 结构图用文本/表格，保证 diff 可读；
- 每个关键结论给 `path:line`；
- 不把代码整段复制进来，链接文件/行号；
- 构建方式变了先改 `build-and-flash.md`，再改 README。
