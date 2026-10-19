# 外部资料索引（researchs）

> 统计时间：2026-10-19（Tier A 删除后）。`researchs/` 总计约 **1,095.7 MB / 5,401 文件**，只读。  
> 使用前先看 [`README.md`](./README.md) 的规则与限制。

## 1. 汇总

| 路径 | 体量 | 文件数 | 用途 | 处理 |
|---|---:|---:|---|---|
| `researchs/codes/上海交大开源/` | 392.6 MB | 40 | 轮腿建模/腿机构/控制器文档 + 测试视频 + 手写稿 | 理论/控制参考 |
| `researchs/codes/山海机甲开源/` | 44.4 MB | 404 | 底盘/云台参考代码（Keil 工程） | 代码参考 |
| `researchs/hardwares/DM-MC02/` | 649.3 MB | 4,943 | 板卡说明书/2D/3D/例程 | 硬件/驱动参考 |
| `researchs/hardwares/Daplink/` | 5.0 MB | 6 | 无线 DAP 调试器资料 | 烧录/调试 |
| `researchs/papers/` | 4.4 MB | 7 | 知乎原理文章 PDF/图 + 浙大串联腿 PDF | 理论参考 |

## 2. 上海交大开源（`codes/上海交大开源/`）

| 内容 | 说明 |
|---|---|
| `README.md`、`plan.md` | 项目说明、研发计划（含已完成项） |
| `WBR_modeling.html`、`WBR_leg.html`、`WBR_control.html` | 建模/腿部/控制器文档；正文可抽，公式多为 base64 图片，**不可直接读** |
| `assets/control_system/` | 系统/控制器/观测器框图（5 图） |
| `assets/test_video/` | 打滑/底盘/跳跃/整车测试（12 个 mp4 + 1 张 jpg） |
| `note/` | 手写稿（建模/腿/功率/自适应/其他，9 图，未 OCR） |
| ~~`…开源.zip`~~ | 与解压目录重复，2026-10-19 Tier A 已删除；解压文件保留 |

引用限制：HTML 中的公式图无法读取；`.slx` 未随包提供；视频只能看文件名/时长，不能自动分析内容。  
许可：README 明确“仅技术交流，未经允许不得商用”。

## 3. 山海机甲开源（`codes/山海机甲开源/`）

| 内容 | 说明 |
|---|---|
| `底盘/` | 底盘 Keil 工程（AHRS/CarBody/Control/Function/Hardware/INS/Library/Motor/Start/System/UI/User） |
| `云台/` | 云台 Keil 工程（含 USB） |
| `山海机甲开源.zip` | 9.9 MB 压缩包（与目录可能重复，暂留） |

用途：模块划分/驱动写法/状态机参考；**不直接抄**，先对照当前代码与许可。

## 4. DM-MC02（`hardwares/DM-MC02/`）

| 内容 | 体量 | 用途 |
|---|---:|---|
| `说明书/` | 板卡使用说明 + STM32H723/BMI088/OV5640 等数据手册 | 硬件/引脚/外设 |
| `2D图纸/` | 原理图/管脚图/LCD 模块（PDF） | 接线/封装 |
| `3D模型/` | SolidWorks/STEP（887 文件） | 结构/干涉检查 |
| `例程/` | 18 个 CtrBoard-H7 例程（FDCAN/IMU/USB/LCD/…，4,037 文件） | 驱动参考 |
| `图片/` | 板卡图片 | 识别 |

注意：`USAGE.md` 里有死链（`图纸/2d/...`、`模型/3d/...`、`示例/...`、`datasheets/...`），实际目录名是中文；以目录为准。

## 5. Daplink（`hardwares/Daplink/`）

- 无线 DAP 调试器手册/宣传册（PDF）、按键提醒/杜邦线更换说明（JPG）、Win7 驱动 exe；
- 用途：烧录/调试接线；具体步骤待补到 `docs/02-architecture/build-and-flash.md`。

## 6. papers（`papers/`）

| 文件 | 说明 |
|---|---|
| `原理参考：RoboMaster平衡步兵机器人控制系统设计-韭菜的菜，知乎/` | 知乎文章 PDF（3.85 MB）+ 5 张截图 + contents.md；理论参考，图片未 OCR |
| `设计参考：串联退机器人建模与控制开源文档/` | 浙大串联腿 PDF（3.85 MB，56 页，文本可读）；与当前串联腿实现最接近 |

> “串联退”应为“串联腿”笔误，保留原名。

## 7. 引用方式

- 文档里写相对路径，例如：`researchs/codes/上海交大开源/WBR_control.html`；
- 外部结论标“参考：上交/知乎/…”，不要写成“本项目实测”；
- 需要具体公式/图片时，先确认能否抽取；不能读就请用户提供截图/文字。
