# 03-theory — 控制理论

> 这里放“为什么这样控”：动力学、VMC、LQR、LESO、状态机。  
> 只写有来源的公式/结论；参数引用 `docs/04-parameters/`，代码给 `path:line`。

## 计划中的文档

| 文件 | 内容 | 状态 |
|---|---|---|
| [`k-matrix.md`](./k-matrix.md) | K 三份候选、生效来源、生成链、Q/R、Ts、腿长拟合、复现命令 | **草案**（P0-1/2，[TODO-01](../00-plan/todo/01-k-matrix.md)） |
| `vmc-lqr-leso.md` | VMC 腿长/腿角映射、LQR 状态/输入、LESO 观测器 | 待写（S4） |
| `state-machine.md` | 7 状态 + 子状态、进入/退出、优先级、急停、线上映射 | 待写（P0-7/8/9，[TODO-05](../00-plan/todo/05-protocol-estop-state.md)） |
| `kinematics.md` | 五连杆几何、正逆解、轮距/腿长量纲 | 待写（P0-6，[TODO-04](../00-plan/todo/04-wheel-track.md)） |

## 当前可用参考

- 上海交大交龙开源：`researchs/codes/上海交大开源/WBR_modeling.html`、`WBR_leg.html`、`WBR_control.html`（正文可抽，公式多为内嵌图片，agent 不能直接读图）；
- 知乎原理文章：`researchs/papers/`（PDF 可读，图片未 OCR）；
- 浙大串联腿 PDF（`researchs/papers/设计参考：串联退机器人建模与控制开源文档/`）——与当前串联腿实现最接近；
- 代码：`firmware/LegWheel/Algorithm/` 的 `lqr.*`、`vmc.*`、`leso.*`、`lqr_coeffs.cpp`。

## 规则

- 公式给来源（论文/HTML/代码行号）；推导过程放附录，不塞进正文；
- 不把仿真/旧文档的数值当成当前车参数；
- 结论与代码冲突时，先记录冲突，再决定改代码还是改文档（不静默改）。
