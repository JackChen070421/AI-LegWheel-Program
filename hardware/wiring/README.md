# hardware/wiring — 接线/线束

放：供电链路、CAN1/2/3、USART、SWD、接插件定义、线束照片/标签。

当前（来自 [`../../docs/02-architecture/hardware-overview.md`](../../docs/02-architecture/hardware-overview.md)，待核对）：

- 电池 → 继电器 → 一分二分电板；
- 一路 → 一分四 → 4 关节；
- 一路 → 一分多 → 板2 + 2 轮；
- 板2 给遥控接收机/DAPLink/IMU 供电；
- CAN1 关节、CAN2 轮+云台预留、CAN3 板间。

规则：改线后更新本文 + 照片；关键接插件给 pinout 表。
