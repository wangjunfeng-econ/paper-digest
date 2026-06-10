#!/bin/bash
# 监听到 archive/ 有新简报时，自动重建目录并 push 到 GitHub。
# 由 launchd（com.paperdigest.push.plist）在文件变动时触发。
set -euo pipefail

REPO="$HOME/PaperDigest"
cd "$REPO"

# 1) 重建侧栏目录 _sidebar.md（按日期倒序）
{
  echo "- [首页](/)"
  echo "- 往期简报"
  for f in $(ls -1 archive/digest-*.md 2>/dev/null | sort -r); do
    d=$(basename "$f" .md | sed 's/^digest-//')
    echo "  - [$d]($f)"
  done
} > _sidebar.md

# 2) 更新首页"最新一期"链接
latest=$(ls -1 archive/digest-*.md 2>/dev/null | sort -r | head -1 || true)
if [ -n "${latest:-}" ]; then
  ld=$(basename "$latest" .md | sed 's/^digest-//')
  cat > README.md <<EOF
# 每日学术简报

> 财政-货币政策互动 · 理性预期均衡 · 政策解读 · 每日荐读

本站每日自动汇编量化宏观经济学的前沿动态，聚焦**财政-货币政策互动、FTPL** 与**理性预期均衡的确定性与多重性**等方向，由 AI 以资深研究者的视角撰写并择要点评。

最新一期 → **[$ld]($latest)**

---

## 栏目设置

- **一、前沿追踪** — 上述方向的最新工作论文，逐篇三段式解读（文章简介 / 专家总结 / 学术价值与定位）。
- **二、政策动态与解读** — 中国与 OECD 的重要货币、财政政策，并解释其中关键名词。
- **三、每日荐读** — 主领域近五年顶刊文献与多重均衡经典各荐一篇，附学术点评。
- **四、邻近领域进展** — 新兴市场与中国宏观、HANK、内生增长等支线速览。

## 关于本站

简报每天上午自动生成并发布；往期可在侧栏（手机点左上角菜单）翻阅或搜索。内容由自动化流程汇编，仅供学术参考。
EOF
fi

# 3) 提交并推送（无改动则跳过）
git add -A
if ! git diff --cached --quiet; then
  git commit -m "digest: $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
fi
