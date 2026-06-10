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

> 财政-货币政策互动 · 理性预期均衡的确定性与多重性 · 政策动态与解读 · 每日荐读

最新一期：[$ld]($latest)

左侧菜单可浏览全部往期（手机上点左上角展开）。
EOF
fi

# 3) 提交并推送（无改动则跳过）
git add -A
if ! git diff --cached --quiet; then
  git commit -m "digest: $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
fi
