# S2 迁移记录（2026-10-19）

> 授权：用户 2026-10-19「进行迁移吧，采用多智能体协作，在迁移过程中删去多余的、对项目帮助不大的文件」。  
> 方式：Captain 执行文件系统迁移；firmware-scout / theory-scout / supervisor 并行验证与冗余审计（只读）。  
> 回退：S0 快照 + git 提交。

## 1. 迁移结果

| 原路径 | 新路径 | 状态 |
|---|---|---|
| `codes-chassis/轮腿底盘控制代码/LegWheel/` | `firmware/LegWheel/` | ✅ 已移动 |
| `codes-chassis/轮腿底盘控制代码/README.md` | `firmware/LegWheel/README.md` | ✅ 已移动并加迁入说明 |
| `codes-chassis/轮腿底盘LQR仿真/simulation/*` | `simulation/chassis-lqr/*` | ✅ 已合并 |
| `codes-chassis/轮腿底盘LQR仿真/README.md` | `simulation/chassis-lqr/README.md` | ✅ 已移动并加迁入说明 |
| `STRUCTURES.md`（根） | `docs/02-architecture/hardware-overview.md` | ✅ 已移动并加迁入说明 |
| `codes-chassis/`（空壳） | — | ✅ 已删除（确认无文件） |

> 未使用 `git mv`：它不会搬未跟踪的 hex/缓存；改用 `Move-Item` + `git add -A`。唯一 Keil 产物 `LegWheel.hex` 随工程移动，`archive/legacy/hex-2026-10-18/` 留档仍在。

## 2. Manifest 对比

| 项 | 值 |
|---|---|
| 迁移前 manifest | `archive/manifests/pre-s2-manifest-20261019.csv`，7,092 行 / 1,407,783,239 B |
| 迁移后 manifest | `archive/manifests/post-s2-manifest-20261019.csv`，7,091 行 / 1,407,782,628 B |
| 映射后缺失 | **0** |
| 内容变化 | **1**：`simulation/chassis-lqr/README.md`（S1 占位 README 被源项目 README 覆盖，预期行为） |
| 新增文件 | 0（本记录/审计文件生成前） |
| 清理后 final manifest | `archive/manifests/final-s2-manifest-20261019.csv`，7,089 行 / 1,407,786,484 B（清理 7 项、归档/删除后的当前状态） |
| Hex 校验 | `archive/legacy/.../LegWheel.hex` SHA-256 `c41529ff…1dd9ce`；移动后 `firmware/LegWheel/MDK-ARM/LegWheel/LegWheel.hex` 大小 494,095 B |

映射规则：
- `codes-chassis/轮腿底盘控制代码/LegWheel/` → `firmware/LegWheel/`
- `codes-chassis/轮腿底盘控制代码/README.md` → `firmware/LegWheel/README.md`
- `codes-chassis/轮腿底盘LQR仿真/simulation/` → `simulation/chassis-lqr/`
- `codes-chassis/轮腿底盘LQR仿真/README.md` → `simulation/chassis-lqr/README.md`
- `STRUCTURES.md` → `docs/02-architecture/hardware-overview.md`

## 3. 结构验证

- `firmware/LegWheel/MDK-ARM/LegWheel.uvprojx` 存在；`MDK-ARM/LegWheel/LegWheel.hex` 存在；
- **Keil 风险**：114 个 `<FilePath>` 都存在，但 **19 个 include 目录不存在**（旧“按设备分目录”布局）；编译前需修（TODO-02/C5）。
- `simulation/chassis-lqr/`：11 个 `.m` + `balance_robot_real.slx` + `.mat` 等；
- `codes-chassis/` 已不存在；`STRUCTURES.md` 根目录已不存在；
- 文档路径引用已更新（README/AGENTS/build-and-flash/system/roadmap 等）。

## 4. 回退

```powershell
# 反向移动（若尚未提交）
Move-Item firmware\LegWheel codes-chassis\轮腿底盘控制代码\LegWheel
# 仿真合并的回退建议直接用 git：
git reset --hard s1-structure-skeleton

# 全量回退
tar -xf archive\snapshots\snapshot-20261019.tar -C <临时目录>
```

## 5. 清理（多智能体审计后）

- Tier A 已在此前删除；
- 本次清理 7 项 / 28,087 B，记录见 `archive/manifests/S2-CLEANUP-20261019.csv`：
  - 删除（可再生缓存）：`simulation/chassis-lqr/balance_robot_real.slxc`（5,082 B）、`MathWorks/.../graphicsState.bin`（2 B + 空目录链）、`firmware/LegWheel/.claude/settings.local.json`（112 B，外部工具本地设置）；
  - 移入 `archive/legacy/`：
    - `k-evidence/K_coeffs_normal.h`（3,677 B，孤儿 K 证据）；
    - `stale-configs/compile_flags.txt`（4,458 B）、`stale-configs/_inc_list.txt`（3,357 B）（旧绝对路径失效）；
    - `unused-headers/dji_motor.h`（11,399 B，未被 include、非 Keil FilePath）。
- **未删**：山海 zip（未证实重复）、`.mat`、仿真侧 K 副本、`lqr_coeffs2.cpp`、`compare_k_fixed.m`、`.vscode` 配置、Tier B 资料。

## 6. 状态

- [x] 文件移动
- [x] manifest 对比（0 缺失）
- [x] 多智能体验证/冗余审计（t6 PASS / t7 PASS / t8 PASS）
- [x] 删除清单与执行（7 项 / 28,087 B）
- [x] git 提交：`d03f9dffa95d97c275a236f382f439210af3c67c`（`struct: migrate firmware and simulation into target tree (S2)`）
- [x] tag：`s2-migration`（最终记录 commit）
- [x] final manifest 重算（7,089 行 / 1,407,786,484 B）
- [ ] Keil 打开/编译验证（需要你或后续任务；19 个 include 目录失效待修）
