# shortcut.md — 常用指令流（操作指南，非授权来源）

> 用途：把用户的自然语言请求稳定映射为**可复核的操作**，减少误操作，尤其是 Git/GitHub 与 `main` 分支。  
> 适用范围：本项目 `D:\RM\LG-AI-process` 的所有 AI 会话（含 subagent）。  
> 最后核验：2026-10-27。变更记录见 `CHANGELOG.md`（最新在前）。
>
> **当前默认策略（2026-10-27）**：默认**不直接 push `main`**、不合并到远端库；功能分支 push / PR / merge 需用户当次明确授权。**本文件不授予权限**；任何直接修改 `main` 的请求仍按 §3 的红线处理。

## 0. 三条硬规则

1. **先看后动**：任何写操作前先跑 §2 的上下文检查；先说明“要改什么/影响哪些文件/如何回退”。
2. **main 不直改**：直接 commit/push/merge/reset `main` 一律视为高危；默认改为“功能分支 + PR”。确需直改时，先确认权限，再让用户明确确认（§3）。
3. **不猜权限、不编状态**：云端能不能访问、PR 能不能合并，以命令/页面结果为准；失败就报告，不反复重试、不假装成功。

### 0.1 控制面边界（必读）

- 本文件是**操作指南**，不是授权/审批来源。任何“可执行”的结论都必须同时满足：用户当次明确请求 + 平台审批/权限允许；文件里写“应该做”不等于“已经授权”。
- 下面的自然语言表是**意图识别参考**，不是精确匹配、自动触发器或预授权；即使说法完全一样，也要先做 §2 预检，并按 §3/§4 的确认门处理。
- 真正可靠的控制面是：用户当次指令、审批（approval）、沙箱/工具策略、分支保护；不要用“在某张表里命中”替代这些。

## 1. 项目与工具（2026-10-26 实测）

| 项 | 当前值 |
|---|---|
| 本地仓库 | `D:\RM\LG-AI-process` |
| 远端 `origin` | `https://github.com/JackChen070421/AI-LegWheel-Program.git` |
| 默认分支 | `main`；本地 `main` 跟踪 `origin/main` |
| Git | 2.54.0.windows.1 |
| GitHub CLI | **未安装**（`gh` 不在 PATH） |
| 云端凭据 | **不可用**：`git ls-remote --heads origin` 返回 `SEC_E_NO_CREDENTIALS`（2026-10-26）；需先由用户完成 GitHub 登录/凭据配置 |
| 分支保护 | **未核验**（当前无云端访问权限，不能假设 `main` 受保护） |

### 1.1 云端操作通道（按可用性选择）

| 通道 | 状态 | 用途 |
|---|---|---|
| 本地 `git` | ✅ 可用 | status/log/diff/commit/branch/本地 merge |
| `gh` | ❌ 未安装 | 认证后可查 PR/CI、创建/合并 PR；安装与登录由用户执行 |
| 浏览器 GitHub | ⚠️ 需用户已登录 | 查看/创建/合并 PR、查看 Actions；Agent 不假设已登录 |
| GitHub 插件 | ❌ 当前 DSH 工具集无此工具 | 若未来环境提供，读写仍受本文件约束 |

> 凭据/登录属于用户环境配置；不要把 token 写进仓库、命令历史或聊天记录。`gh` 未安装时，不要用“插件已连接”之类说法代替真实状态。

## 2. 操作前的上下文检查（只读）

在仓库根目录执行：

```sh
git status --short --branch
git branch --show-current
git remote -v
git log --oneline -8 --decorate
git diff --stat
git diff --cached --stat
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git rev-list --left-right --count HEAD...'@{upstream}'
```

判定顺序：

1. **工作区是否干净**：有未提交改动时，先列出文件；不自动 `stash`/`reset`/`checkout -- .`。保留方式（提交/暂存/放弃）由用户选。
2. **当前分支/目标任务**：不是目标分支时，说明切换会带走的改动；脏工作区不硬切。
3. **upstream/远端是否可达**：无 upstream、凭据失败、网络失败都如实报告；不猜测 `origin/main` 就是当前分支的上游。
4. **ahead/behind**：有分叉时先说明，再让用户选 merge/rebase/PR；不自动强推或重置。
5. **写操作预告**：给出“命令 + 影响文件 + 回退方式”，再执行。只读检查不需要确认。

## 3. main 分支红线（最高优先级）

### 3.1 什么算“直接修改 main”

以下自然语言/操作都按高危处理，**不得直接执行**：

- 在 `main` 上 `commit` / `amend`；
- `git push origin main`（含 `--force` / `--force-with-lease`）；
- 本地把功能分支 `merge` 进 `main` 后再推送；
- `reset` / `rebase` / 删除 / 重建 `main`；
- 在 GitHub 网页直接编辑 `main` 上的文件；
- 任何“绕过 PR/检查/评审”的合并。

### 3.2 执行前必须做的四步

1. **确认权限**：`git ls-remote --heads origin`（只读）是否成功；有 `gh` 时 `gh auth status`；能否在 GitHub 设置中看到分支保护。无权限就停止。
2. **确认影响**：`git status`、`git diff`、目标 commit、将要覆盖的远端提交；说明对协作者的影响。
3. **用户明确确认**：复述“请求 + 命令 + 影响 + 回退”，然后问：
   > 这将直接修改 `main`。确认继续吗？（建议改用分支 + PR）

   只有明确肯定（“确认/可以/继续”）才算；沉默、模糊、只发表情都不算。
4. **留退路**：先建备份分支或 tag；记录当前 `main` SHA；确认可回退。

### 3.3 推荐路径

- 默认：`main` → 新建 `feat/`/`fix/`/`docs/` 分支 → 提交 → push 分支 → PR → 检查/评审 → 合并 PR。
- `main` 的合并优先走 PR；PR 合并默认 merge commit，并校验 head SHA（§4.8）。
- 即使有直推权限，也不把“有权限”当作“可以直接改”。

## 4. Git / GitHub 自然语言 → 操作

> 以下默认假设用户已提出该操作；仍需遵守 §0/§2/§3。云端写操作当前默认禁用（见页首）。

### 4.1 “帮我从 GitHub 云端同步到本地” / “拉取最新代码”

默认同步**当前分支**的上游；用户明确说主分支时才切 `main`。

```sh
git fetch origin
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git pull --ff-only
```

- 无 upstream：先确认对应远程分支；`git branch --set-upstream-to=origin/<branch>`；不把 `origin/main` 拉进任意功能分支。
- 工作区脏：先列文件，问保留方式；不覆盖本地修改。
- 已分叉：`git rev-list --left-right --count HEAD...'@{upstream}'`，说明后再选 merge/rebase；不 `reset --hard`。
- 凭据失败：停止并报告（当前即此状态），不要反复重试或改用匿名 URL。
- `--ff-only` 是默认；需要生成合并提交时必须先说明并获确认。

### 4.2 “帮我看看云端有哪些更新”

只读，不改工作区：

```sh
git fetch origin
git log --oneline --decorate HEAD..'@{upstream}'
git diff --stat HEAD...'@{upstream}'
```

凭据不可用时报告“无法读取云端”，不要用本地缓存假装最新。

### 4.3 “帮我提交本次修改”

```sh
git diff
git diff --cached
git add -- <file_1> <file_2>
git diff --cached
git commit -m "<type>: <summary>"
```

- 先按任务分组；**只暂存本次相关文件**，不用 `git add -A` 扫入无关改动（当前工作区可能已有上一轮未提交内容）。
- 提交信息：`feat|fix|docs|struct|test|chore: 摘要`，正文写“改了什么/为什么/验证”；不编造验证结果。
- 不提交密钥、token、大二进制、构建产物；遵守 `.gitignore`。
- 项目改动同步 `CHANGELOG.md`（新记录写顶部，最新在前）。
- 用户只说“提交”时**只提交本地**，不自动 push。

### 4.4 “帮我推送到 GitHub” / “上传本地提交”

**默认不推送。** 项目口径：`main` 不直推；功能分支 push / PR 需用户当次明确授权，本文件不构成授权。当前环境：`gh` 未安装；校园网证书拦截下 HTTPS 需先连 VPN/可信网络（2026-10-27 实测：VPN + 可信根后可 `git ls-remote`）。

正确回应：

> 我可以推送功能分支并创建 PR，但需要你当次明确确认；`main` 仍不直推。确认后我按 §4.5/§4.6 执行。

获得当次明确授权后（且目标不是 `main`）：

```sh
git branch --show-current
git push -u origin <branch>
```

- `main`：按 §3，默认拒绝直推；改为分支 + PR。
- 被拒（non-fast-forward）：先 `git fetch` 并说明分叉；不 `--force`；由用户选 merge/rebase。
- 任何 `--force`/`--force-with-lease`：必须单独说明影响并获确认；`main` 上永远禁止。
- 只有未提交改动时，明确告知“push 不会上传未提交文件”。

### 4.5 “帮我新建一个分支开发这个功能”

命名：`feat/<slug>`、`fix/<slug>`、`docs/<slug>`、`chore/<slug>`；先查重 `git branch --list '<prefix>*'`。

从最新 `main` 开发（工作区干净）：

```sh
git switch main
git pull --ff-only origin main   # 凭据不可用则基于本地 main，并说明
git switch -c feat/<slug>
```

把当前未提交工作带到新分支：直接 `git switch -c feat/<slug>`，不先切/拉 `main`；说明 base commit。

### 4.6 “帮我创建 PR”

前置：分支已推送、云端凭据可用、base=`main`。body 至少含：改了什么 / 验证 / 证据（`path:line`）/ 风险 / 回退。

```sh
git push -u origin <branch>
gh pr create --base main --head <branch> --title "<title>" --body-file <body_file>
```

- `gh` 未安装：用浏览器创建；Agent 可以引导并核对，但不得声称“已创建”。
- 创建后回报：PR 编号/URL、base、head、head SHA；**不在同一步自动合并**。

### 4.7 “帮我看看 PR / CI 状态”

只读。有 `gh` 时：

```sh
gh pr view <pr_number> --json number,title,state,baseRefName,headRefName,headRefOid,mergeable,reviewDecision,statusCheckRollup
gh pr checks <pr_number>
```

无 `gh` 时用浏览器；必须核对 PR 编号与当前分支，避免看错 PR。报告：base/head、head SHA、检查结果、评审结论、是否可合并。

### 4.8 “帮我合并这个 PR”

合并前逐项核对，任一不满足就停止并报告：

- [ ] PR 编号正确，base=`main`，head 是预期分支；
- [ ] head SHA 与最近一次验证的提交一致；
- [ ] 必需检查通过（CI 绿）；
- [ ] 评审已批准（项目要求时）；
- [ ] `mergeable` 无冲突、无待处理评论；
- [ ] 没有绕过分支保护。

```sh
gh pr merge <pr_number> --merge --match-head-commit <head_sha>
```

- 默认 merge commit；用户指定 squash/rebase 时按指定方式，但仍校验 head SHA。
- 合并后：若本地在 `main` 且工作区干净，`git fetch origin && git pull --ff-only`；否则只报告“云端已合并、本地未更新”。
- 用户未要求时不删除分支。
- 无 `gh` 时由用户在浏览器合并；Agent 只做核对与事后同步，不代点“合并”除非用户明确要求且页面已登录。

### 4.9 “把 A 分支合并到 B 分支”（本地合并）

先 fetch 并确认 A/B 是本地还是远程；目标为 `main` 时按 §3 处理（优先 PR）。

```sh
git fetch origin
git switch <target_branch>
git pull --ff-only
git merge --no-ff <source_branch>
```

- 冲突：先 `git status`，只解决能明确判断的部分；涉及功能取舍时向用户说明具体冲突，不猜。
- 解决后重新验证；合并提交信息写清来源分支。
- 本地合并**不会自动推送**；用户只要求合并时到此为止。

### 4.10 通过 GitHub 插件操作（若当前环境提供）

插件只替代“云端读写通道”，不替代 §2 预检和 §3 红线。常见说法与动作：

- “列出未合并的 PR” → 只读列表，汇报编号/标题/base/head/状态；
- “看 PR #12 的修改、检查和评审” → 只读；核对 base/head/head SHA；
- “把当前分支推送并创建 PR，目标 main” → 先按 §4.4 获授权并 push 分支，再按 §4.6 创建；不自动合并；
- “检查 PR #12，满足条件就合并” → 按 §4.8 逐项核对；任何一项不满足就停止，不能“先合并再补检查”。

当前 DSH 工具集没有 GitHub 插件；上述流程仅在插件可用时执行，仍以真实返回结果为准。

## 5. 其他自然语言 → 意图规范

> 目标不是“多做事”，而是先判断**该不该写、写哪里、写到什么程度**。默认先只读；写操作前说明并等确认。  
> 表中“用户说法”只是示例，不构成精确触发器或预授权；命中后仍按确认门执行。

| 用户说法 | 意图 | 默认动作 | 写文件 | 确认门 |
|---|---|---|---|---|
| “帮我看看目前项目进展到哪一步了？” | 状态审计 | 读 `AGENTS.md`、`README.md`、`CHANGELOG.md` 顶部、`progress-*`、`open-questions.md`、`todo/`、`git status/log`；交叉核对“文档声称 vs 实际证据” | 否 | 无 |
| “我接下来该做什么？” | 决策建议 | 在上项基础上，列 2–3 个可选下一步（收益/成本/风险/依赖），给推荐；不直接开工 | 否 | 开始执行前确认 |
| “继续上次的工作” | 恢复上下文 | `git status` + 最近 commit + CHANGELOG 顶部 + progress；复述停点与计划 | 否 | 写操作前确认 |
| “检查一下项目/文档有没有问题” | 审计 | 坏链、过期声明、矛盾、未提交改动、验证缺失；输出 findings（severity + `path:line`） | 否 | 修复前确认 |
| “整理/更新文档” | 文档变更 | 先读再改；单一事实源；相对链接；单文档正文 ≤300 行；同步 CHANGELOG | 是 | 大改/删除前确认 |
| “记录一下这个决定” | 决策记录 | 写 `docs/07-decisions/` ADR 或 CHANGELOG；日期、背景、选项、结论、来源 | 是 | 结论不清时先问 |
| “帮我实现 X” | 代码变更 | 先给最小改动计划 → 改 → 验证 → CHANGELOG；不顺手重构 | 是 | 安全关键（电机/急停/电源）先台架 |
| “这个参数是多少？” | 参数查询 | 查 `docs/04-parameters/parameters.md` 与代码；给 `path:line`/日期；没有就写 TBD | 否 | 无 |
| “这个报错/编译失败怎么办？” | 诊断 | 复现、读日志、定位根因；先解释再改 | 否 | 修复前说明 |
| “清理/删除这些文件” | 破坏性操作 | 先快照/提交，列清单与体量，说明回退；不删 `researchs/` | 是 | **必须明确确认** |
| “装个工具/改环境” | 环境变更 | 用户执行安装；Agent 只读检查；安装根 `C:\STM32+Vscode+Keil5` 只读 | 否 | 不擅自安装 |
| “直接在 main 上改” | 高危 | 转 §3：权限确认 → 影响说明 → 用户确认 → 备份；优先分支 + PR | 是 | **必须明确确认** |

### 5.1 状态汇报固定格式

```text
阶段：<当前阶段/分支>
已完成：<3–5 条，带证据>
进行中：<正在做的>
未提交：<文件/是否干净>
阻塞：<缺权限/缺数据/待确认>
证据：path:line / 命令输出摘要
建议下一步：<1–3 条，按优先级>
```

### 5.2 “我接下来该做什么”的推荐结构

1. 先列**阻塞项**（没有它就无法继续）；
2. 再列**低成本高收益**项（文档同步、链接修复、验证）；
3. 再列**需要用户拍板/实测**项；
4. 每项给：收益、成本、风险、依赖；
5. 只给建议，不擅自开始；用户确认后再进入执行。

## 6. 记录与收尾

- 每次改动写 `CHANGELOG.md`：**新记录追加在文件顶部**，越靠前日期越新；同日按“后发生在前”。历史记录已按此方向重排。
- 报告格式：改了什么 / 验证了什么 / 证据（`path:line`）/ 未决问题 / 下一步。
- 未验证就写“未验证”；不把“命令跑过”当成“功能正确”。
- 工作区未提交、未推送时明确说明；不把本地改动说成“已上传”。

## 7. 参考

- [Git pull：快进与分支同步](https://git-scm.com/docs/git-pull)
- [GitHub CLI：PR 合并及 head SHA 校验](https://cli.github.com/manual/gh_pr_merge)
- [GitHub CLI：登录](https://cli.github.com/manual/gh_auth_login)
- [OpenAI 插件概览](https://developers.openai.com/plugins)
- 项目内：`AGENTS.md`（黄金原则）、`CHANGELOG.md`（变更记录）、`docs/00-plan/agent-execution-policy.md`（执行纪律）
