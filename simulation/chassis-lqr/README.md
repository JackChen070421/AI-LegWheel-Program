# simulation/chassis-lqr — 底盘 LQR 仿真（待迁入）

> S2 会把 `codes-chassis/轮腿底盘LQR仿真/simulation/` 的内容迁到这里。

## 当前源位置

`codes-chassis/轮腿底盘LQR仿真/simulation/`

## 关键脚本

`k_calc_chuan_real2.m`、`Variables_and_Equations.m`、`Linear_and_CalcMatrix.m`、`Num_function.m`、`Calc_K_and_fit.m`、`Leg_data.m`、`leg_fk.m`、`leg_ik.m`、`verify_leg_kinematics.m`。

## 注意

- 旧链/新链并存，K 来源未定（P0-1/2）；
- 迁移后相对 `load` 路径要保持可用；
- 迁移验证：至少一个不依赖硬件的 `.m` 能跑。
