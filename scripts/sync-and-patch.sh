#!/bin/bash
#
# 同步上游更新并自动应用中文补丁
#
# 使用方法:
#   ./scripts/sync-and-patch.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔄 Superpowers 中文版同步脚本"
echo "================================"
echo ""

# 检查是否有未提交的更改
if [ -n "$(git -C "$PROJECT_DIR" status --porcelain)" ]; then
    echo "⚠️  检测到未提交的更改:"
    git -C "$PROJECT_DIR" status --short
    echo ""
    read -p "是否继续？未提交的更改可能会被覆盖 (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 已取消"
        exit 1
    fi
fi

# 添加 upstream remote（如果不存在）
if ! git -C "$PROJECT_DIR" remote get-url upstream &>/dev/null; then
    echo "📌 添加 upstream remote..."
    git -C "$PROJECT_DIR" remote add upstream https://github.com/obra/superpowers.git
fi

# 获取上游更新
echo ""
echo "📥 获取上游更新..."
git -C "$PROJECT_DIR" fetch upstream

# 获取当前分支
CURRENT_BRANCH=$(git -C "$PROJECT_DIR" branch --show-current)
MAIN_BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref origin/HEAD | sed 's|origin/||')

# 确保在主分支
if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
    echo "📍 切换到主分支: $MAIN_BRANCH"
    git -C "$PROJECT_DIR" checkout "$MAIN_BRANCH"
fi

# 合并上游更新
echo ""
echo "🔀 合并 upstream/$MAIN_BRANCH..."
git -C "$PROJECT_DIR" merge "upstream/$MAIN_BRANCH" -m "Merge upstream: sync with upstream"

# 应用中文补丁
echo ""
echo "🇨🇳 应用中文补丁..."
if [ -f "$PROJECT_DIR/scripts/apply-chinese-patches.sh" ]; then
    bash "$PROJECT_DIR/scripts/apply-chinese-patches.sh"
else
    echo "⚠️  补丁脚本不存在，跳过"
fi

echo ""
echo "✅ 同步完成!"
echo ""
echo "下一步:"
echo "  1. 检查修改: git diff"
echo "  2. 提交更新: git commit -am 'chore: sync with upstream and apply chinese patches'"
echo "  3. 更新插件: /plugin update superpowers  (在 Claude Code 中)"
