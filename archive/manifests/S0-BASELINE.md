# S0 基线记录（2026-10-19）

> 状态：**完成**（快照 + manifest + git 基线 + tag）  
> 执行人：Captain（AI）　授权：用户 2026-10-19「做 S0 基线」  
> 范围：工作区 `D:\RM\LG-AI-process`；**未删除、未移动任何现有文件**。

## 1. 全量快照

| 项 | 值 |
|---|---|
| 路径 | `archive/snapshots/snapshot-20261019.tar` |
| 大小 | 1,838,510,080 B（≈1.71 GiB） |
| SHA-256 | `6ac9cd8b557228892cbbb3579a49ce83ef73c45e20322b45eb2e6b880a75d075` |
| 条目数 | 8,451（文件 + 目录） |
| 格式 | 未压缩 tar（bsdtar 3.8.9），便于核对/解包 |
| 排除 | `archive/snapshots`、`.git`、`.agent-teams`（避免自包含与运行时目录） |
| 含 | `.gitignore`、`docs/00-plan/todo/*`、`archive/manifests/manifest-20261019.csv`、`archive/legacy/hex-2026-10-18/LegWheel.hex` |

验证：`tar -tf` 退出码 0；上述排除项均未出现；关键文件均存在。

## 2. 文件清单（manifest）

| 项 | 值 |
|---|---|
| 路径 | `archive/manifests/manifest-20261019.csv` |
| 行数 | 7,147（含表头；对应 7,146 个文件） |
| 总字节 | 1,822,177,166 |
| 字段 | Path / Bytes / LastWriteTimeUtc / Ext / Sha256 / Kind |
| 哈希范围 | 文本类扩展名 + `LegWheel.hex`；二进制记大小/时间 |
| 备注 | 生成于 `.gitignore`/S0 报告之前；迁移前会重新生成一份完整 manifest |

## 3. Keil 产物留档

| 项 | 值 |
|---|---|
| 源 | `codes-chassis/轮腿底盘控制代码/LegWheel/MDK-ARM/LegWheel/LegWheel.hex` |
| 留档 | `archive/legacy/hex-2026-10-18/LegWheel.hex` |
| 大小 | 494,095 B |
| SHA-256 | `c41529fff5f9308fca2542d34d96af1ad121191067c1959abdc40342081dd9ce` |
| 说明 | 当前唯一已知可用的 Keil 产物；已纳入 git 跟踪（`.gitignore` 否定规则） |

## 4. Git 基线

| 项 | 值 |
|---|---|
| 分支 | `main` |
| 首次提交 | `1d05ac4af853737431aab669c4b4277dbeef31ce` |
| 提交信息 | `chore: S0 baseline before harness restructure` |
| Tag | `pre-structure-20261019`（annotated） |
| 跟踪文件 | 770（第二次提交前）/ 771（含本报告） |
| 跟踪字节 | 75,293,881（工作区文件；提交时 pack 24.92 MiB；`git gc --prune=now` 后 pack 5.45 MiB） |
| 提交时状态 | clean |

范围说明：
- **跟踪**：固件源码/工程文件、HAL/CMSIS（DSP 只保留 `Lib/ARM/arm_cortexM7lfdp_math.lib`）、FreeRTOS、文档、TODO、manifest、hex 留档；
- **忽略**：`researchs/`、`build/`、`slprj/`、`uvguix`、`*.hex`（源目录）、`archive/snapshots/`、`.agent-teams/`、DSP 的 GCC/IAR/其他 ARM 库（164 MB）；
- `arm_math.h` 实际来自 `Middlewares/ST/ARM/DSP/Inc/arm_math.h`（已跟踪），Keil IncludePath 也是该路径。
- 收尾：`git gc --prune=now` 删除首次 `git add` 后 reset 产生的未引用对象；`git fsck` clean，pack 5.45 MiB。

## 5. 回退命令

```powershell
# 1) 解包快照到临时目录核对（不要直接覆盖工作区）
mkdir D:\RM\restore-check
tar -xf D:\RM\LG-AI-process\archive\snapshots\snapshot-20261019.tar -C D:\RM\restore-check

# 2) 回到 S0 提交（会丢弃 S0 之后的提交/工作区改动）
cd D:\RM\LG-AI-process
git reset --hard pre-structure-20261019

# 3) 恢复 hex 留档
#    若 archive 被误删，从快照中取：
tar -xf D:\RM\LG-AI-process\archive\snapshots\snapshot-20261019.tar -C D:\RM\restore-check ./archive/legacy/hex-2026-10-18/LegWheel.hex
```

## 6. 未做 / 后续

- 未删除 Tier A/B 任何文件；删除仍需用户逐项授权（P0-11）。
- 未移动 `firmware/`/`simulation/`（S2 才做）。
- 未回答 P0 参数/K/协议问题；见 `docs/00-plan/todo/`。
- 下一步：S1 只新增目录/文档；S2 前重生成 manifest 并确认 P0。
