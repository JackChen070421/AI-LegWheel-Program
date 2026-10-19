# firmware — 固件

> 这里只放**可编译的固件工程**；参考资料放 `researchs/`，实验数据放 `experiments/`。

| 目录 | 内容 | 状态 |
|---|---|---|
| `LegWheel/` | 底盘固件（STM32H723VGTx + FreeRTOS + 1 kHz） | **已迁入（S2, 2026-10-19）** |
| `gimbal/` | 云台固件（板1） | 预留 |

## 构建入口

- Keil：`firmware/LegWheel/MDK-ARM/LegWheel.uvprojx`；
- 产物：`MDK-ARM/LegWheel/LegWheel.hex`；
- 详见 [`../docs/02-architecture/build-and-flash.md`](../docs/02-architecture/build-and-flash.md)。

## 规则

- 不把 `build/`、`uvguix`、hex/elf 提交进 git（`.gitignore` 已处理）；
- 厂商 HAL/CMSIS/FreeRTOS 保持原样，改动要记录；
- 旧车/外部代码先放 `archive/legacy/`，不要直接混入。
