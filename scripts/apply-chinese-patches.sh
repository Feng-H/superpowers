#!/bin/bash
#
# 应用中文触发词补丁
#
# 使用方法:
#   ./scripts/apply-chinese-patches.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CHINESE_SUFFIX=' | 在任何创造性工作之前必须使用 - 创建功能、构建组件、添加功能或修改行为。在实现前探索用户意图、需求和设计。中文触发词: 做个功能、写个组件、加个功能、头脑风暴、讨论一下、帮我设计、新功能"'

echo "🇨🇳 应用中文补丁..."
echo ""

# 1. 应用 brainstorming 中文触发词
BRAINSTORMING_FILE="$PROJECT_DIR/skills/brainstorming/SKILL.md"

if [ -f "$BRAINSTORMING_FILE" ]; then
    echo "📝 修改: skills/brainstorming/SKILL.md"

    # 检查是否已经有中文触发词
    if grep -q "中文触发词:" "$BRAINSTORMING_FILE"; then
        echo "   ⏭️  已有中文触发词，跳过"
    else
        # 使用 awk 添加中文触发词 - 找到以 description: 开头且包含 implementation." 的行
        awk -v suffix="$CHINESE_SUFFIX" '
            /^description:.*implementation\."$/ {
                sub(/"$/, suffix)
            }
            {print}
        ' "$BRAINSTORMING_FILE" > "$BRAINSTORMING_FILE.tmp" && mv "$BRAINSTORMING_FILE.tmp" "$BRAINSTORMING_FILE"
        echo "   ✅ 已添加中文触发词"
    fi
else
    echo "   ⚠️  文件不存在: $BRAINSTORMING_FILE"
fi

echo ""
echo "✅ 补丁应用完成!"
echo ""
echo "查看修改: git diff skills/brainstorming/SKILL.md"
