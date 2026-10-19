# 项目结构审计（Harness Engineering）— 2026-10-19

> 范围：S2 迁移后的全仓结构、文档、构建配置、git 状态、冗余/占位。  
> 结论：**骨架符合 harness engineering，可作为长期基线**；剩余问题集中在 **Keil include/VSCode 配置、CubeMX 工作流、K 来源**，其中前两项等你回答 TODO-02。

## 1. 当前结构

```text
LG-AI-process/
├─ AGENTS.md / README.md / CHANGELOG.md / .gitignore
├─ docs/00-governance … 09-references
├─ docs/00-plan/（提案、问题清单、todo、审计/审阅记录）
├─ firmware/LegWheel/（Keil 工程；Build 已验证）
├─ firmware/gimbal/（预留）
├─ simulation/chassis-lqr/（11 .m + .slx + .mat）
├─ hardware/（structure/electronics/wiring/bom，预留）
├─ experiments/（logs/calibration/reports，预留）
├─ tests/（Host/协议/日志回放，预留）
├─ tools/（脚本，预留）
├─ researchs/（1.1 GB 外部资料，只读）
└─ archive/（快照/legacy/清单/记录）
```

## 2. 做得好的部分

| 项 | 状态 |
|---|---|
| agent 入口 | `AGENTS.md` 77 行，含 9 条黄金原则、目录地图、事实源、修改规则 |
| 文档分层 | `docs/00–09` 每层有 README；README/参数/K/构建/实验/质量/参考均有落点 |
| 单一事实源 | 参数台账、K 草案、构建文档已建立；其他文档链接而非复制 |
| 决策/记录 | ADR-0001、`CHANGELOG.md`、S0/S1/S2 记录、Tier A/清理清单 |
| 质量 | 质量门、review 清单、独立审阅报告（t4/t5/t8） |
| 回退 | 1.8 GB 全量快照 + git tag（S0/S1/S2） |
| 资料隔离 | `researchs/` 只读、git 忽略；Tier B 不删；大文件不进 git |
| 卫生 | 无空目录/0B 文件（排除 researchs）；无 `codes-chassis`/根 `STRUCTURES.md`；坏链 0 |
| 生成物 | Keil build 输出（`.o/.d/.map/.axf/.htm` 等）已忽略；`.slxc`/MathWorks 已忽略 |

## 3. findings

| # | 优先级 | 问题 | 影响 | 动作 |
|---|---|---|---|---|
| F1 | P0 | `uvprojx` 34 个 include 中 19 个不存在（旧按设备分目录） | 工程有误导性配置；Build 目前仍通过 | 待你确认后删除 19 条、备份、Build 验证（TODO-02） |
| F2 | P0 | `MDK-ARM/.vscode/c_cpp_properties.json` 指向 `d:\RM\27-transistor-codes\...` | IntelliSense 失效/误导 | 待确认是否用 VSCode：重生成或归档 |
| F3 | P0 | K 来源未定（三份候选） | 调参不可复现 | 建了 `docs/03-theory/k-matrix.md` 草案；TODO-01 |
| F4 | P1 | CubeMX 重新生成 `uvprojx` 的流程未定义 | 手工 include 修复可能被覆盖 | 待你回答：重生成还是只生成代码手动合并 |
| F5 | P1 | `can-protocol.md`、`state-machine.md` 未建 | 云台联调/状态验收缺单一来源 | S4/TODO-05；`system.md` 暂含状态表 |
| F6 | P1 | `hardware-overview.md` 仍是旧车描述 | 硬件文档不新 | 待新车参数/结构补齐 |
| F7 | P2 | `tests/` 仅占位、无 CI | 回归依赖人工 | 已加 `tests/README.md`；CI 以后 |
| F8 | P2 | `final-s2-manifest` 生成后文档又有编辑 | 清单与当前文件有轻微漂移 | 下次基线重生成 |
| F9 | P2 | `researchs` 拼写（应为 research） | 纯命名 | C 方案保留原名；索引已建 |
| F10 | P2 | TODO 状态有少量滞后（如 06 写 S1） | 可读性 | 随任务更新 |

## 4. harness 评分卡

| 原则 | 状态 | 备注 |
|---|---|---|
| 仓库即事实源 | ✅ | docs + ADR + changelog + 参数/K/构建 |
| AGENTS.md 做地图 | ✅ | 77 行，指向 docs |
| 分层文档 | ✅ | 00–09 + 00-plan |
| 单一事实源 | 🟡 | 参数/构建 ✅；K 草案；协议/状态待建 |
| 决策记录 | ✅ | ADR-0001 |
| 变更/回退 | ✅ | CHANGELOG + tag + snapshot + 删除清单 |
| 质量门 | ✅ | checklist + 独立 review |
| 实验记录 | ✅ | 模板 + experiments 目录 |
| 参考资料隔离 | ✅ | researchs 只读、git 忽略 |
| 工具/脚本 | 🟡 | 仅 README，脚本待写 |
| 测试 | 🟡 | 仅 README，框架待建 |
| CI | ❌ | 尚未需要；后续可做编译检查 |
| 占位/预留 | ✅ | firmware/gimbal、hardware、experiments、tests、tools |
| 命名 | 🟡 | 英文目录/中文内容；researchs 拼写保留 |

## 5. 本次审计已做的修正

- 记录 **Keil Build 已验证**、实际编译器 **ARMCLANG 6.19**；
- 新增 [`docs/03-theory/k-matrix.md`](../03-theory/k-matrix.md) 草案（K 唯一事实源占位）；
- 新增 [`tests/README.md`](../../tests/README.md) 占位；
- `.gitignore` 补 `*.htm`/`*.build_log.htm`/`*.slxc`/`MathWorks/graphicsState.bin`/`.claude/`；
- 删除 Keil 生成的 `LegWheel.htm`、`LegWheel.build_log.htm`（Build 可再生成）；
- 更新 README/AGENTS/build/TODO-02/roadmap/open-questions 的编译状态与路径。

## 6. 下一步

1. **你回答 TODO-02 的 6 个问题**（见 `docs/00-plan/todo/02-build-entry.md`），我再动 `uvprojx`；
2. 之后做 **TODO-01（K 三份差异）**；
3. P1 文档（can-protocol/state-machine/hardware-overview）等有数据再写；
4. CI/测试框架等有需要再开。
