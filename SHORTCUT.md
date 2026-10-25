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
python tools/pr.py --check       # 验 token（首次或换 token 时跑）
python tools/pr.py               # 推送 + 建 PR，输出 PR 链接
```

- token：`%USERPROFILE%\.dsh\secrets\github-token.txt`（单行，**勿放仓库内**）或环境变量 `GITHUB_TOKEN`；需 `Contents: write` + `Pull requests: write`。
- 无 token 时退回手动：`git push -u origin <分支>`，再到 `compare/main...<分支>` 点 Create pull request；本机 schannel 坏（`SEC_E_NO_CREDENTIALS`），git 报错时加 `-c http.sslbackend=openssl` —— `tools/pr.py` 已内置。

**回报内容**：commit hash + 分支名 + PR 链接 + `CHANGELOG.md` 是否已记一条。

---

## 新增指令

用户说"以后 X 就做 Y"→ 在下方按同格式加 `## SC-0N · <标题>`：说法一行 + 动作一行 + 可复制代码块。
