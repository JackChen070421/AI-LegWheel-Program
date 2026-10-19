/**
 * @file board_comm.h
 * @author
 * @brief 板间通信（板2 = 底盘）
 * @version 2.0
 * @date 2026-10-2
 * @attention 底盘是板2
 *   收 0x10F  yaw 速度指令 / 自瞄标志 / 请求状态 / 目标腿长
 *   收 0x12F  yaw 力矩 / yaw 目标角速度
 *   发 0x11F  血量 / 弹速 / 颜色 / 比赛开始
 *   发 0x14F  yaw 电机实际角度
 * 完整字节布局见 BOARD_PROTOCOL.md
 * 总线：hfdcan3（收发统一走 CAN3，句柄由 BoardCommInit 注入）
 *
 * @attention 【当前只搭架构，不接管控制】
 *   云台板尚未做出，底盘实际由 SBUS 遥控器接收机直连控制。
 *   因此本模块的接收解析函数一律「只存不消费」：不改 Cloud.Target_Yaw，
 *   不改底盘状态机。任何把 BoardComm 字段接进控制回路的改动，都必须先设计好
 *   「遥控器 vs 云台指令」的仲裁与命令超时保护，否则会与遥控器争抢控制权。
 *
 * @todo 已留好裁判系统相关接口；yaw 指令的缩放系数保留 0.06f，待定？；model_mode保留且默认，待定
 */

#ifndef BSP_BOARDCOMMUNICATION_H
#define BSP_BOARDCOMMUNICATION_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include "BSP_fdcan.h"

/*
0x11f - 裁判系统相关数据，8字节标准帧
0-1 大端 机器人血量
2-5 小端 弹速
6 己方颜色 1=红 2=蓝
7 比赛开始标志 0=未开始，1=开始

0x14f - yaw电机实际角度
0-7 小端 double
*/
#define CAN_ID_CHASSIS 0x10f  // 1 -> 2，底盘接受，yaw command, flags, leg length
#define CAN_ID_GIMBAL 0x11f   // 2 -> 1，云台接受，HP, bullet speed, color, game flag
#define CAN_ID_TORQUE 0x12F   // 1 -> 2，yaw torque and target velocity
#define CAN_ID_DOUBLE_YAWANGLE 0x14f  // 2 -> 1，yaw 电机实际角度
#define CAN_ID_CHASSIS_IMU 0x13F      // 底盘回传 IMU 数据帧（底盘→云台），暂未接入
#define CAN_ID_KEYCOMMAND 0x22f       // 图传键鼠数据的接收ID为0x22f，暂未接入
#define CAN_ID_TARGETANGLE 0x15f      // 规格未定义，暂未接入

/* 工作模式：0 为正常，1 为录制；mid / down 为档位 */
#define model_Normal 0
#define model_Record 1

/* 云台板是否已接入：0 = 未接入（当前默认），板间通信只收不发。
 * 原因：CAN3 上没有对端节点应答时，hfdcan3 的 AutoRetransmission 是使能的，
 *       每帧都会重传到 TEC 累加进 bus-off，连上云台前都会一直发不出去。
 * 云台建成后把这里改成 1 即可恢复发送；也可以在运行期直接置 BoardComm.tx_enable。
 * 接收不受影响：不发送时控制器保持 error-active，云台一上电就能收到帧。 */
#define BOARD_COMM_GIMBAL_PRESENT 0

/* 0x10F[3] 云台请求的底盘状态 —— 线上编码，见 BOARD_PROTOCOL.md
 * @attention 与 Chassis.h 的 RobotStatus 编号【不同】，接入状态机时必须显式映射，
 *            绝不可以直接把两者混用：
 *              线上：RECOVER=0 NORMAL=1 STEPUP=2 JUMP=3 SPIN=4 ESTOP=5
 *              本地：STATE_RECOVERING=2 STATE_NORMAL=1 STATE_STEP_UP=6
 *                    STATE_JUMPING=3 STATE_SPIN=7 STATE_ESTOP=5
 * @attention 枚举名一律加 CHASSIS_REQ_ 前缀。Chassis.h 的 RobotStatus 已经占用了
 *            STATE_NORMAL / STATE_SPIN 等全局标识符，同名会在同时 include 两者的
 *            编译单元（如 BSP_fdcan.cpp）里造成重定义错误。
 */
typedef enum {
    CHASSIS_REQ_RECOVER = 0,
    CHASSIS_REQ_NORMAL  = 1,
    CHASSIS_REQ_STEPUP  = 2,
    CHASSIS_REQ_JUMP    = 3,
    CHASSIS_REQ_SPIN    = 4,
    CHASSIS_REQ_ESTOP   = 5
} ChassisReqState;

/* 板间通信数据（板2 视角），按收发方向分组 */
typedef struct {
    /* ---- 发往板1（云台）---- */
    uint16_t blood_volume;        // 0x11F[0:1] 大端  裁判系统血量
    float    bullet_speed;        // 0x11F[2:5] 小端  裁判系统弹速 m/s
    uint8_t  own_color;           // 0x11F[6]         己方颜色 1=红 2=蓝
    uint8_t  game_start;          // 0x11F[7].bit0    比赛开始标志
    double   yaw_angle;           // 0x14F[0:7] 小端  云台yaw轴角度（暂定，归一化 ±4096）

    /* ---- 收自板1（云台）---- */
    float    yaw_velocity;        // 0x10F[0:1]  yaw 方向速度指令 rad/s ×1000
    uint8_t  auto_aim_flag;       // 0x10F[2]    自瞄开关（遥控器）
    ChassisReqState chassis_state_req;  // 0x10F[3]    云台请求的底盘状态（只存不消费）
    float    target_leg_length;   // 0x10F[4:7]  目标腿长 m
    float    yaw_torque;          // 0x12F[0:3]  yaw 力矩 N·m
    float    yaw_target_velocity; // 0x12F[4:7]  yaw 目标角速度 rad/s

    /* ---- 本地/链路 ---- */
    uint8_t  model_mode;          // model_Normal / model_Record，门控云台yaw输出
                                  // TODO: 新协议无此传输位，暂恒为 model_Normal
    FDCAN_HandleTypeDef *fdcan;   // 板间 CAN 句柄
    uint8_t  tx_enable;           // 0 = 不发（云台未接入），1 = 正常发送，见 BOARD_COMM_GIMBAL_PRESENT

    /* ---- 链路有效性（只留接口位，不接线）----
     * 协议要求：板2 在命令超时或 ESTOP 时停止运动输出，且须等两帧都有效。
     * 这里只记录「收到时刻」和「是否收到过」，超时判定与清位由接入云台后的消费端实现。 */
    uint32_t last_rx_ms[2];       // [0]=0x10F 最近接收时刻，[1]=0x12F 最近接收时刻（DWT 毫秒）
    uint8_t  cmd_valid;           // bit0=收到过 0x10F，bit1=收到过 0x12F；只置位不清零
} BoardComm_t;

extern BoardComm_t BoardComm;

/* ---- 裁判系统数据接口（占位）----
 * TODO: 裁判系统串口驱动接入后替换实现即可，上层打包逻辑无需改动。
 * 当前恒返回 0。 */
uint16_t Referee_GetBloodVolume(void);
float    Referee_GetBulletSpeed(void);
uint8_t  Referee_GetOwnColor(void);
uint8_t  Referee_GetGameStart(void);

typedef struct {
    void (*Board2_getGimbalCmd)(FDCan_Export_Data_t RxMessage); // 收 0x10F
    void (*Board2_getYawTorque)(FDCan_Export_Data_t RxMessage); // 收 0x12F
    void (*Board2_To_1)(void);                                  // 发 0x11F
    void (*Board2_SendYawAngle)(void);                          // 发 0x14F
    void (*BoardCommInit)(FDCAN_HandleTypeDef* _phcan);
} Board2_FUN_t;

#define Board2_FunGroundInit \
    {                        \
        &Board2_getGimbalCmd, \
        &Board2_getYawTorque, \
        &Board2_To_1,         \
        &Board2_SendYawAngle, \
        &BoardCommInit        \
    }

/********全局变量声明********/
extern Board2_FUN_t Board2_FUN;

/********函数声明********/
void Board2_To_1(void);
void Board2_SendYawAngle(void);
void Board2_getGimbalCmd(FDCan_Export_Data_t RxMessage);
void Board2_getYawTorque(FDCan_Export_Data_t RxMessage);
void BoardCommInit(FDCAN_HandleTypeDef* _phcan);

#ifdef __cplusplus
}
#endif
#endif
