# Tier A 删除记录（2026-10-19）

> 授权：用户 2026-10-19「删除所有的 Tier A」。  
> 方式：先记录清单 → 直接删除（S0 全量快照已存在，可回退）。  
> **未删除任何 Tier B/Tier C 文件。**

## 汇总

| 项 | 值 |
|---|---:|
| 清单行数 | 101（94 个文件 + 7 个空目录） |
| 总字节 | 414,476,633 B（395.3 MiB / 414.5 MB） |
| 清单 | `archive/manifests/TIER-A-DELETION-20261019.csv` |
| 回退 | 从 `archive/snapshots/snapshot-20261019.tar` 解包对应路径 |

## 删除内容

| 目标 | 文件数 | 字节 | 说明 |
|---|---:|---:|---|
| `LegWheel/build/` | 34 | 5,296,000+ | CMake 历史产物（2026-10-02） |
| `MDK-ARM/*.uvguix.*` | 7 | 1,121,259 | Keil 个人界面状态，会自动重建 |
| `MDK-ARM/tmp/` | 3 | 6,000+ | CMake 临时目录 |
| `MDK-ARM/.vscode/{keil-assistant.log,uv4.log,uv4.log.lock}` | 3 | 16,154 | 日志/锁；保留 settings.json/c_cpp_properties.json |
| `simulation/slprj/` | 43 | 985,000+ | MATLAB 缓存 |
| `上海交通大学RoboMaster2023平衡步兵控制系统开源.zip` | 1 | 407,008,202 | 与解压目录内容重复（GBK 文件名差异） |
| 0 字节占位：`ARCHITECTURE.md`、`docs/papers.md`、山海 `uv4.log.lock` | 3 | 0 | 由 S1 新文档取代 |
| 空目录：MathWorks/ServiceHost、slprj 空子目录、山海 4 个 | 7 | 0 | 无内容 |

> `LegWheel/MDK-ARM/LegWheel/LegWheel.hex`（494,095 B，唯一 Keil 产物）**保留**；`LegWheel/MDK-ARM/LegWheel.uvoptx/uvprojx`、`JLinkSettings.ini`、`dsp` lib 等均未动。

## 验证

- 删除后：`build/`、`tmp/`、`slprj/`、上交 zip 均不存在；
- `archive/legacy/hex-2026-10-18/LegWheel.hex` 仍存在，SHA-256 与源一致；
- 工作区（含快照）约 3.03 GB；不含快照约 1.29 GB；
- 清单中的 `build/tmp/slprj` 明细由 S0 manifest 补全（删除前枚举与 S0 manifest 一致）。

## 回退示例

```powershell
mkdir D:\RM\restore-tier-a
tar -xf D:\RM\LG-AI-process\archive\snapshots\snapshot-20261019.tar -C D:\RM\restore-tier-a `
  ./codes-chassis/轮腿底盘控制代码/LegWheel/build `
  ./codes-chassis/轮腿底盘控制代码/LegWheel/MDK-ARM/tmp `
  ./codes-chassis/轮腿底盘LQR仿真/simulation/slprj `
  "./researchs/codes/上海交大开源/上海交通大学RoboMaster2023平衡步兵控制系统开源.zip"
```

> Tier B 未删：DM-MC02 例程/3D、上交视频、DSP 源码、山海代码仍在 `researchs/`，由 `.gitignore` 忽略。
