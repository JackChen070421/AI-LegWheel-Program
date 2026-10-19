/**
 * @file board_comm.cpp
 * @author lxr(784457420@qq.com)/ZS(2729511164@qq.com)
 * @brief 板间通信（板2 = 底盘），协议见 BOARD_PROTOCOL.md
 * @version 2.0
 * @date 2026-10-2
 *
 */
#include "board_comm.h"

#include <math.h>
#include <string.h>

#include "bsp_dwt.h"  // DWT_GetTimeline_ms，记录收帧时刻供超时判定

/********变量定义********/

Board2_FUN_t Board2_FUN = Board2_FunGroundInit;
/* 全局零初始化即可：model_mode == 0 == model_Normal（门控云台 yaw 输出，默认放行）
 * 不用 {.model_mode = ...} 指定初始化器 —— ARMCC 默认 C++ 标准不支持。 */
BoardComm_t BoardComm;

/* ---- 裁判系统数据接口（占位实现）----
 * TODO: 裁判系统串口驱动接入后替换本段实现 */
uint16_t Referee_GetBloodVolume(void) { return 0; }
float    Referee_GetBulletSpeed(void) { return 0.0f; }
uint8_t  Referee_GetOwnColor(void) { return 0; }  // 1=红 2=蓝
uint8_t  Referee_GetGameStart(void) { return 0; }

/**
  * @brief 初始化板间通讯
  * @param _phcan 板间 CAN 句柄
  * @retval None
  */
void BoardCommInit(FDCAN_HandleTypeDef* _phcan)
{
    BoardComm.fdcan = _phcan;
    /* 云台未接入时禁止发送：CAN3 无对端应答，重传会把控制器推入 bus-off。
     * 见 board_comm.h 的 BOARD_COMM_GIMBAL_PRESENT。 */
    BoardComm.tx_enable = BOARD_COMM_GIMBAL_PRESENT;
}

/**
  * @brief 发 0x11F：裁判系统数据给云台
  * @param None
  * @retval None
  * @attention 血量大端、弹速小端，两者编码方式不同，勿用同一种写法
  */
void Board2_To_1(void)
{
    if (BoardComm.tx_enable == 0) return;  // 云台未接入，见 BOARD_COMM_GIMBAL_PRESENT

    uint8_t data[8] = {0};  // 每帧清零，不要用 |= 累加

    // [0:1] 血量：大端
    uint16_t hp = Referee_GetBloodVolume();
    data[0] = (uint8_t)(hp >> 8);
    data[1] = (uint8_t)(hp & 0xFF);

    // [2:5] 弹速：小端 float，整块拷贝
    float speed = Referee_GetBulletSpeed();
    memcpy(data + 2, &speed, sizeof(speed));

    // [6] 己方颜色；[7].bit0 比赛开始，其余位保留
    data[6] = Referee_GetOwnColor();
    data[7] = (uint8_t)(Referee_GetGameStart() & 0x01u);

    Can_Fun.fdcanx_send_data(BoardComm.fdcan, CAN_ID_GIMBAL, data, 8);
}

/**
  * @brief 发 0x14F：yaw 电机实际角度给云台
  * @param None
  * @retval None
  */
void Board2_SendYawAngle(void)
{
    if (BoardComm.tx_enable == 0) return;  // 云台未接入，见 BOARD_COMM_GIMBAL_PRESENT

    uint8_t data[8] = {0};
    memcpy(data, &BoardComm.yaw_angle, sizeof(BoardComm.yaw_angle));
    Can_Fun.fdcanx_send_data(BoardComm.fdcan, CAN_ID_DOUBLE_YAWANGLE, data, 8);
}

/**
  * @brief 收 0x10F：云台下发的指令
  * @param RxMessage 接收到的数据
  * @retval None
  */
void Board2_getGimbalCmd(FDCan_Export_Data_t RxMessage)
{
    const uint8_t* data = RxMessage.FDCANx_Export_RxMessage;

    // [0:1] yaw 方向速度指令，大端，单位 rad/s ×1000
    BoardComm.yaw_velocity = (float)(int16_t)((uint16_t)data[0] << 8 | data[1]);
    // [2] 自瞄开关
    BoardComm.auto_aim_flag = data[2];
    // [3] 云台请求的底盘状态，见 ChassisReqState
    BoardComm.chassis_state_req = (ChassisReqState)data[3];
    // [4:7] 目标腿长，小端 float
    float leg;
    memcpy(&leg, data + 4, sizeof(leg));
    BoardComm.target_leg_length = (isfinite(leg) && leg > 0.0f) ? leg : 0.0f;

    // 链路有效性接口位：记录收帧时刻与「收到过」标志，超时判定由消费端做
    BoardComm.last_rx_ms[0] = (uint32_t)DWT_GetTimeline_ms();
    BoardComm.cmd_valid |= 0x01u;

    /* @attention 本函数【只解析、不执行】。
     * 目前云台板尚未做出，底盘由 SBUS 遥控器直连控制，板间通信只是先把架构搭出来。
     * 这里绝不能去改 Cloud.Target_Yaw / 底盘状态机 —— 那会与遥控器争抢控制权。
     * 待云台建成后，再单独设计"遥控器 vs 云台指令"的仲裁与超时保护，另行接入。
     *
     * TODO(接入云台时)：
     *   1) yaw_velocity 的线上单位是 rad/s ×1000，与旧协议的原始刻度不同；
     *      旧代码用 raw * 0.06f 逐帧累加到 Cloud.Target_Yaw，新单位下必须按 dt 重新推导。
     *   2) chassis_state_req 只存不消费。Chassis::ChangeState() 是私有的
     *      （Chassis.h:914），需要先在 Chassis 上加公开请求接口才能生效；
     *      且线上编码与本地 RobotStatus 不同：线上 SPIN=4 → 本地 STATE_SPIN=7。
     *   3) target_leg_length / yaw_torque / yaw_target_velocity 同理，均只存不消费。 */
}

/**
  * @brief 收 0x12F：云台下发的 yaw 力矩与目标角速度
  * @param RxMessage 接收到的数据
  * @retval None
  */
void Board2_getYawTorque(FDCan_Export_Data_t RxMessage)
{
    const uint8_t* data = RxMessage.FDCANx_Export_RxMessage;

    float torque;
    float velocity;
    memcpy(&torque, data, sizeof(torque));
    memcpy(&velocity, data + 4, sizeof(velocity));

    BoardComm.yaw_torque = isfinite(torque) ? torque : 0.0f;
    BoardComm.yaw_target_velocity = isfinite(velocity) ? velocity : 0.0f;

    // 链路有效性接口位：记录收帧时刻与「收到过」标志，超时判定由消费端做
    BoardComm.last_rx_ms[1] = (uint32_t)DWT_GetTimeline_ms();
    BoardComm.cmd_valid |= 0x02u;
}
