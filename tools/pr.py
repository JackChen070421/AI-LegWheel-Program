#!/usr/bin/env python3
"""推送当前分支并创建 / 复用 GitHub Pull Request。

用法（在仓库根或任意子目录执行）：
    python tools/pr.py --check          # 只校验 token 身份，不推送
    python tools/pr.py                  # 推送当前分支 + 建 PR，输出 PR 链接
    python tools/pr.py --base main      # 指定目标分支（默认 main）
    python tools/pr.py --title "xxx"    # 指定 PR 标题（默认取最新 commit 标题）
    python tools/pr.py --allow-main     # 允许从 main 直接推送（默认拒绝）

token 来源（按优先级）：
    1) 环境变量 GITHUB_TOKEN
    2) %USERPROFILE%\\.dsh\\secrets\\github-token.txt   （单行，勿放仓库内）

安全：token 不会打印；git 输出经脱敏后才回显。
背景：本机 schannel 后端报 SEC_E_NO_CREDENTIALS，故固定用 openssl 后端，
      并禁用凭据助手（受限模式下凭据助手会拉 sh.exe 失败）。
"""

import argparse
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

# Windows 控制台默认 GBK，会把人读的中文输出显示成乱码：统一切到 UTF-8。
if os.name == "nt":
    try:
        import ctypes

        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
    except Exception:
        pass
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

API = "https://api.github.com"
TOKEN_FILE = os.path.join(os.path.expanduser("~"), ".dsh", "secrets", "github-token.txt")


def die(msg, code=2):
    print(f"错误: {msg}", file=sys.stderr)
    sys.exit(code)


def run_git(args, token=None):
    """跑 git，返回 (returncode, stdout, stderr)；stderr/stdout 中的 token 会被脱敏。"""
    env = dict(os.environ, GIT_TERMINAL_PROMPT="0")
    p = subprocess.run(
        ["git"] + args,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        env=env,
    )
    out, err = p.stdout, p.stderr
    if token:
        out, err = out.replace(token, "***"), err.replace(token, "***")
    return p.returncode, out.strip(), err.strip()


def read_token():
    tok = os.environ.get("GITHUB_TOKEN", "").strip()
    if tok:
        return tok, "环境变量 GITHUB_TOKEN"
    if os.path.isfile(TOKEN_FILE):
        with open(TOKEN_FILE, "r", encoding="utf-8-sig") as f:
            tok = f.read().strip()
        if tok:
            return tok, TOKEN_FILE
    die(
        "找不到 GitHub token。请二选一：\n"
        f"  a) 把 token 写到 {TOKEN_FILE}（单行）\n"
        "  b) 设置环境变量 GITHUB_TOKEN\n"
        "token 需具备 Contents: write 与 Pull requests: write。"
    )


def api(method, path, token, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(
        API + path,
        data=data,
        method=method,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "ai-legwheel-pr-tool",
            **({"Content-Type": "application/json"} if data else {}),
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        raw = e.read().decode(errors="replace")
        try:
            msg = json.loads(raw).get("message", raw)
        except Exception:
            msg = raw
        if e.code == 401:
            die(f"token 无效或已过期（401: {msg}）", 3)
        if e.code == 403:
            die(f"权限不足（403: {msg}）；确认 token 有 Contents/Pull requests 写权限", 3)
        if e.code == 404:
            die(f"仓库或资源不存在（404: {msg}）；确认 token 授权了本仓库", 3)
        die(f"GitHub API {method} {path} 失败: {e.code} {msg}", 3)


def parse_remote(url):
    m = re.search(r"github\.com[:/]+([^/]+)/([^/.]+?)(?:\.git)?$", url.strip())
    if not m:
        die(f"无法从 remote 解析 owner/repo: {url}")
    return m.group(1), m.group(2)


def main():
    ap = argparse.ArgumentParser(description="推送当前分支并创建 GitHub PR")
    ap.add_argument("--check", action="store_true", help="只校验 token，不推送")
    ap.add_argument("--base", default="main", help="目标分支（默认 main）")
    ap.add_argument("--title", default=None, help="PR 标题（默认最新 commit 标题）")
    ap.add_argument("--body", default=None, help="PR 描述")
    ap.add_argument("--allow-main", action="store_true", help="允许从 main 推送")
    args = ap.parse_args()

    token, src = read_token()

    # --check：只验身份
    if args.check:
        me = api("GET", "/user", token)
        print(f"token 有效：登录名 {me.get('login')}（来源: {src}）")
        return

    rc, root, err = run_git(["rev-parse", "--show-toplevel"])
    if rc != 0:
        die(f"不在 git 仓库内: {err}")
    os.chdir(root)

    rc, remote, err = run_git(["remote", "get-url", "origin"])
    if rc != 0:
        die(f"取不到 origin: {err}")
    owner, repo = parse_remote(remote)

    rc, branch, err = run_git(["rev-parse", "--abbrev-ref", "HEAD"])
    if rc != 0:
        die(f"取不到当前分支: {err}")
    if branch == args.base and not args.allow_main:
        die(f"当前在 {branch} 上：PR 需要独立分支。先 `git switch -c <type>/<slug>` 再提交")

    rc, dirty, _ = run_git(["status", "--porcelain"])
    if dirty:
        print("提示: 工作区有未提交改动（不会被本次推送包含）：")
        for line in dirty.splitlines()[:10]:
            print("   ", line)

    # 推送：token 走 URL，禁用凭据助手 + 固定 openssl 后端
    push_url = f"https://x-access-token:{token}@github.com/{owner}/{repo}.git"
    rc, out, err = run_git(
        ["-c", "credential.helper=", "-c", "http.sslbackend=openssl",
         "push", push_url, f"HEAD:refs/heads/{branch}"],
        token=token,
    )
    if rc != 0:
        die(f"推送失败:\n{err or out}", 4)
    print(f"已推送分支 {branch} → {owner}/{repo}")

    # 已有开着的 PR 就复用
    head = f"{owner}:{branch}"
    existing = api("GET", f"/repos/{owner}/{repo}/pulls?state=open&head={head}", token)
    if isinstance(existing, list) and existing:
        pr = existing[0]
        print(f"PR 已存在，未新建：{pr['html_url']}")
        return

    if args.title:
        title = args.title
    else:
        rc, title, _ = run_git(["log", "-1", "--pretty=%s"])
        title = title or f"{branch} → {args.base}"

    body = args.body
    if body is None:
        rc, log, _ = run_git(["log", f"origin/{args.base}..HEAD", "--pretty=- %h %s"])
        body = f"分支 `{branch}` 的改动：\n\n{log}" if rc == 0 and log else ""

    pr = api(
        "POST",
        f"/repos/{owner}/{repo}/pulls",
        token,
        {"title": title, "head": branch, "base": args.base, "body": body},
    )
    print(f"PR 已创建：{pr['html_url']}")


if __name__ == "__main__":
    main()
