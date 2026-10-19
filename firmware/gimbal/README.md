# firmware/gimbal — 云台固件（预留）

> 板1 云台固件的位置；当前**尚未开始**。

## 计划

- 硬件/板卡选型（P1，TODO-05 D2）；
- 电机：yaw/pitch（GM6020？）、拨盘（M2006？）——待定；
- 与底盘板2 的 CAN3 协议（0x10F/0x11F/0x12F/0x14F，待写 `BOARD_PROTOCOL.md`）；
- 自瞄/图传/键鼠接口（后期）。

## 规则

- 协议先写 `docs/02-architecture/can-protocol.md`，再写代码；
- 控制权仲裁/超时/急停必须先定义（TODO-05）；
- 不与底盘固件混编；独立工程/目录。
