# SHORTCUT.md — 用户指令 ↔ AI 动作

> 用法：AI 收到指令后先在本表找相似说法（近义 / 缩写 / 中英混写都算）——命中就**直接执行对应代码，不再反问流程**；未命中走 [`AGENTS.md`](AGENTS.md) 常规流程。
> 只收用户明确要求的指令；AGENTS.md 的规则（安全、不改工作区外文件、不提交构建产物）对本表同样有效，不在此重复。

---

## SC-01 · 提交到仓库

| 项 | 内容 |
|---|---|
| 用户说法 | 提交到仓库 / 推到仓库 / 上传 / push / 提个 PR / 创建 pull request |
| AI 动作 | 建分支 → 提交 → 推送 → 建 PR → 回报 PR 链接 |

```powershell
git switch -c <type>/<slug>      # 在 main 上必须先建分支，否则开不了 PR
git add <文件1> <文件2>          # 逐个 add；不要 -A（Keil 的 uvprojx/uvoptx 常驻假脏）
git commit -m "<type>: <摘要>"   # type: feat / fix / docs / struct / chore
```

推送（token 从仓库外的 `%USERPROFILE%\.dsh\secrets\github-token.txt` 读入，**不写进仓库、不回显**）：

```powershell
git -c credential.helper= push https://x-access-token:<token>@github.com/JackChen070421/AI-LegWheel-Program.git HEAD:refs/heads/<分支>
```

建 PR：打开 `https://github.com/JackChen070421/AI-LegWheel-Program/compare/main...<分支>?expand=1` → **Create pull request**；也可由 AI 用一次性脚本调 GitHub API 建（脚本不落仓库）。

- 本机 schannel 坏（`SEC_E_NO_CREDENTIALS`），git 连 GitHub 一律加 `-c http.sslbackend=openssl`（仓库级 `.git/config` 已配，无需每次写）。
- 无 token 时退回：把上面的推送命令交给用户，在他自己的终端执行。

**回报内容**：commit hash + 分支名 + PR 链接 + `CHANGELOG.md` 是否已记一条。

---

## 新增指令

用户说"以后 X 就做 Y"→ 在下方按同格式加 `## SC-0N · <标题>`：说法一行 + 动作一行 + 可复制代码块。
