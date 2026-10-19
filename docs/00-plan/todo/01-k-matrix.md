# TODO-01 · K 矩阵来源与生成链

> 状态：⬜ 未开始　优先级：P0　负责人：你 + AI  
> 对应：`open-questions.md` P0-1、P0-2、B1、B2、B3  
> 关联：`docs/03-theory/k-matrix.md`（待建）

## 1. 要解决的问题

1. **P0-1**：固件实际生效的 K 到底是哪一份？
2. **P0-2**：以后重算 K 用哪条生成链？

## 2. 为什么现在要解决

- 三份候选同时存在，调参结果无法复现；
- 换参数（轮重、车重、气弹簧）后必须重算 K，届时必须先确定“以哪份为准”；
- 如果一直不解决，后续所有“车变稳了/变差了”都无法归因。

## 3. 目前已知（证据）

| 候选 | 位置 | 状态 |
|---|---|---|
| A | `firmware/LegWheel/Algorithm/src/lqr_coeffs.cpp:6`（normal）、`:48`（off_ground） | **固件 `LqrGains` 实际读取**；40×6 系数 |
| B | `firmware/LegWheel/Algorithm/inc/K_coeffs_normal.h` | 全仓库无 `#include`，孤儿副本；数值与 A 不同 |
| C | `simulation/chassis-lqr/simulation/K_coeffs_normal.h` | 仿真目录同名文件；与 A 不同 |

生成链：

- **旧链**：`k_calc_chuan_real2.m` → `lqr_coeffs2.cpp`；Ts=0.001；Q/R 一套；腿长拟合 `0.4710·l + 0.0083` 等。
- **新链**：`Variables_and_Equations.m` → `Linear_and_CalcMatrix.m` → `Num_function.m` → `Calc_K_and_fit.m` → `K_coeffs_normal.h`；Ts=0.002；用 `Leg_data.m` 实测表插值。

## 4. 可选方案

| 方案 | 做法 | 代价/风险 |
|---|---|---|
| **A. 冻结现状** | 确认 A 生效，写清来源；暂不重算 | 最快；但不知道 A 对应哪组质量/腿长 |
| **B. 旧链重算** | 用 `k_calc_chuan_real2.m` 以新参数重算，覆盖 A | 链路短、可复现；可能仍沿用旧建模假设 |
| **C. 新链重算** | 用 `Leg_data` 实测表 + 新链重算 | 更贴近实车；脚本/数据完整性未知，工作量大 |

> AI 不替你拍板；先做“差异对比”，再决定。

## 5. 要回答它，需要做什么

1. 对比 A/B/C 三份系数矩阵的数值差异（逐行/逐元素最大相对误差）；
2. 查 `lqr_coeffs.cpp` 的注释/生成时间/来源（无 git，只能看注释与文件时间）；
3. 回忆或查记录：**最近一次实车能稳定平衡时，烧的是哪份 hex、对应哪份 K**（这是最关键的证据）；
4. 用同一组参数分别跑旧链/新链，比较 K 与闭环极点；
5. 确认 `Leg_data.m` 的实测表是否对应新车（腿长/质量）。

## 6. 解决后的落地动作

- 新建 `docs/03-theory/k-matrix.md`：生效文件、生成链、Q/R、Ts、腿长拟合、复现命令、三份差异；
- 在 `docs/04-parameters/parameters.md` 记录“K 对应哪组质量/几何”；
- 把 B（孤儿头）移到 `archive/legacy/` 或标注“仅参考”；
- 更新 `open-questions.md` P0-1/P0-2/B1/B2/B3 状态；
- 若重算，记录新旧 K 的对比与实车验证结果。

## 7. 讨论记录

- 2026-10-19：创建；待你确认“最近一次稳定运行对应哪份 K”。
