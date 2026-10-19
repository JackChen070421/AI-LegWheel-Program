# K 矩阵来源（草案）

> 状态：**草案；生效来源未定**（P0-1/P0-2）。  
> 这是 K 的唯一事实源；在来源确定前，**不要改 K**。行动项见 [`../00-plan/todo/01-k-matrix.md`](../00-plan/todo/01-k-matrix.md)。

## 1. 候选

| 候选 | 位置 | 现状 | 备注 |
|---|---|---|---|
| A | `firmware/LegWheel/Algorithm/src/lqr_coeffs.cpp`（`K_coeffs_normal` / `K_coeffs_off_ground`） | **固件 `LqrGains` 实际读取**；40×6 | 当前最可能是“生效者”，但对应哪组质量/几何未确认 |
| B | `archive/legacy/k-evidence/K_coeffs_normal.h` | 2026-10-19 从固件 `Algorithm/inc/` 移入；全仓库无 `#include` | 第三套数值；作为证据保留，不参与编译 |
| C | `simulation/chassis-lqr/K_coeffs_normal.h` | 仿真目录；与 A 的 normal 40 行逐行同值（t7 复核） | 链路证据；是否由新链生成待确认 |

## 2. 生成链

- **旧链**：`k_calc_chuan_real2.m` → `lqr_coeffs2.cpp`；Ts=0.001；单文件 syms→solve→jacobian；腿长拟合 `0.4710·l + 0.0083` 等。
- **新链**：`Variables_and_Equations.m` → `Linear_and_CalcMatrix.m` → `Num_function.m` → `Calc_K_and_fit.m` → `K_coeffs_normal.h`；Ts=0.002；用 `Leg_data.m` 实测表插值。

## 3. 待确认（P0）

1. 最近一次实车稳定运行时烧的是哪份 hex、对应哪份 K？
2. 用旧链还是新链重算？Q/R、Ts、腿长拟合分别取哪套？
3. K 对应的质量/几何口径（见参数台账与 TODO-03/04）。

## 4. 规则

- 任何 K 变更：先更新本文件（来源、Q/R、Ts、腿长、复现命令），再改代码/仿真；
- 不把仿真/旧文档的 K 数值当作当前车参数；
- 不删除候选 B/C，直到来源确定；
- 与 TODO-01、`open-questions.md` P0-1/2 保持同步。
