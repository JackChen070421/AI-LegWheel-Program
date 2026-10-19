# 系统结构（硬件 / 软件 / 控制 / 通信）

> 最后更新：2026-10-19（S1）  
> 事实源：`firmware（当前 codes-chassis/.../LegWheel）` 代码 + `STRUCTURES.md` + 用户口述。  
> 参数数值见 [`../04-parameters/parameters.md`](../04-parameters/parameters.md)；未确认项见 [`../00-plan/open-questions.md`](../00-plan/open-questions.md)。

## 1. 硬件拓扑

| 部件 | 配置 | 证据/备注 |
|---|---|---|
| 主控（板2，底盘） | DM-MC02 / STM32H723VGTx | `LegWheel.ioc`、`LegWheel.uvprojx` |
| 关节电机 | 4 × DM-8009P（左前/左后/右前/右后） | `Chassis.h` 成员 `lf/lb/rf/rb_joint_` |
| 驱动轮 | 2 × M3508 + C620 | `Chassis.h` `left_wheel/right_wheel`；STRUCTURES 写“4 个轮毂电机”疑为笔误 |
| IMU | 固件支持 DM IMU / N100 | `ins.h` `INS_IMU_SOURCE`；实车待确认 |
| 遥控 | SBUS 接收机（ET16S） | `Devices/SBUS.*`、`freertos.c` `StartET16STask` |
| 无线烧录 | DAPLink（塔克） | `researchs/hardwares/Daplink/` |
| 供电 | 电池 → 继电器 → 分电板 → 电机/板2 | `STRUCTURES.md` |
| 云台（板1） | 未做 | `Cloud.*` 为 yaw/拨盘骨架；`BOARD_COMM_GIMBAL_PRESENT=0` |

接线要点（旧描述，待迁入硬件文档）：

- CAN1：4 个关节电机；
- CAN2：2 个轮电机；预留云台 yaw / 供弹拨盘；
- CAN3：板间通信（与云台板1）；
- USART：IMU、SBUS、VOFA；SWD 接 DAPLink。

## 2. 软件任务

| 任务 | 优先级 | 栈 | 周期/行为 | 主要工作 |
|---|---:|---:|---|---|
| `ControlLoopTask` | 48 | 512 words | 1 ms（`vTaskDelayUntil`） | INS → 观测器 → 底盘控制 → 电机下发 |
| `VofaTask` | 32 | — | 5 ms（约 110 Hz） | 13 路 JustFloat 遥测 |
| `BoardcommTask` | 24 | — | `osDelay(1)` 忙轮询 | CAN3 板间通信 |
| `ET16STask` | 24 | — | `osDelay(1)` | SBUS 解析 |
| `CloudTask` | 24 | — | `osDelay(1)` | 云台控制（当前无硬件） |
| `defaultTask` | 8 | — | 500 ms | 空闲 |

**1 kHz 主循环顺序**（`Core/Src/freertos.c`）：

```text
INS_Task()        // 读 IMU
ObserveTask()     // 卡尔曼/LESO/腿解算
ChassisTask()     // Chassis.Controller(): SetState → 状态 switch → TorControl
DM_MotorTask()    // 4 个关节电机 CAN 打包
WheelMotorTask()  // 2 个轮电机电流
SDM02Task()       // 仅起跳压缩段开测距
vTaskDelayUntil() // 1 ms
```

> 注意：`execution_time` 已计算但未使用；Boardcomm/ET16S/Cloud 是 `osDelay(1)` 忙轮询，无超时保护（P1，见 open-questions B15/C7）。

## 3. 状态机

`Chassis.h` `enum RobotStatus`：

| 状态 | 值 | 含义 | 子状态 |
|---|---:|---|---|
| `STATE_NORMAL` | 1 | 平地行驶/平衡 | — |
| `STATE_RECOVERING` | 2 | 倒地自起 | 5 个：SETTLE / ROLL_TO_SAGITTAL / SWEEP / CENTER_LEGS / BALANCE |
| `STATE_JUMPING` | 3 | 跳跃 | 6 个主动子状态：COMPRESS / ASCEND / RETRACT / LAND_PREP / LAND_IMPACT / LAND_SETTLE |
| `STATE_JOINT_DEBUG` | 4 | 关节调试 | 编译条件未启用（待确认） |
| `STATE_ESTOP` | 5 | 急停 | — |
| `STATE_STEP_UP` | 6 | 上台阶 | NONE / APPROACH（已废弃）/ CLEAR_LEG / RETRACT_LEG / EXTEND_LEG / FINISH |
| `STATE_SPIN` | 7 | 小陀螺原地旋转 | — |

状态优先级（代码注释/实现归纳，待逐行确认）：**失联 & SA 急停 > DM 电机故障 > 动作态（跳跃/恢复/上台阶）> 地面态（NORMAL/SPIN）**。  
线上/本地编号不同（云台请求用线上编码），映射见 [`../00-plan/todo/05-protocol-estop-state.md`](../00-plan/todo/05-protocol-estop-state.md)。

## 4. 模块地图

| 目录 | 职责 | 关键文件 |
|---|---|---|
| `Applications/` | 应用层：底盘状态机/控制、云台、板间通信、INS、任务管理 | `Chassis.cpp/h`（245 KB / 5,523 行）、`Cloud.*`、`board_comm.*`、`ins.*`、`Task_manager.*` |
| `Algorithm/` | LQR、LESO、VMC、PID、卡尔曼、四元数 EKF、K 系数 | `lqr.*`、`leso.*`、`vmc.*`、`kalman_filter.*`、`quaternion_ekf.*`、`lqr_coeffs.cpp` |
| `Devices/` | 电机/IMU/遥控/测距/灯 | `DM_8009P.*`、`M3508.*`、`GM6020.*`、`SBUS.*`、`SDM02.*`、`vofa.*` |
| `Bsp/` | DWT、FDCAN、UART | `bsp_dwt.*`、`BSP_fdcan.*`、`bsp_uart.*` |
| `Core/` | CubeMX 生成：main、时钟、外设、FreeRTOS | `main.c`、`freertos.c`、`fdcan.c`、`usart.c` |
| `Drivers/`、`Middlewares/` | ST HAL/CMSIS、FreeRTOS | 厂商代码，基本不改 |

> 结构风险：`Chassis.cpp` 单文件承载全部 7 状态控制律；`Lqr/Leso/Vmc` 反向 include `Chassis.h`，形成循环依赖。拆分是后续工程任务，不在 S1 做。

## 5. 通信

| 总线 | 对端 | 用途 | 证据 |
|---|---|---|---|
| CAN1 | 4 关节 | 关节力矩/状态 | `BSP_fdcan.cpp`、`DM_8009P.*` |
| CAN2 | 2 轮 + 预留云台 yaw/拨盘 | 轮电流/云台 | `M3508.*`、`GM6020.*` |
| CAN3 | 云台板1（未接） | 板间协议 0x10F/0x11F/0x12F/0x14F | `board_comm.h` |
| USART | IMU / SBUS / VOFA | 姿态/遥控/遥测 | `ins.*`、`SBUS.*`、`vofa.*` |
| SWD | DAPLink | 烧录/调试 | `STRUCTURES.md` |

`BOARD_PROTOCOL.md` 被 `board_comm.*` 引用但**全仓库不存在**；协议 v0.1 待写（P0-7/D3）。

## 6. 已知缺口（与结构相关）

| 缺口 | 影响 | 跟踪 |
|---|---|---|
| K 三份候选，生效来源不明 | 调参不可复现 | P0-1/2，TODO-01 |
| `LEG_FF_WHEEL_TRACK` 三种用法 | 滚转/偏航可能差 2 倍 | P0-6，TODO-04 |
| `BOARD_PROTOCOL.md` 缺失 | 云台联调无契约 | P0-7，TODO-05 |
| `.ioc` 漂移 | 重新生成覆盖用户代码 | P0-3/C3，TODO-02 |
| 急停注释与实现不一致 | 安全 | P0-8，TODO-05 |
| 线上/本地状态编号不同 | 切错状态 | P0-9，TODO-05 |
| 忙轮询任务无超时 | 异常时占 CPU/无降级 | P1，open-questions B15 |
