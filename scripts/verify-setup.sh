#!/bin/bash

# ECC 工作流配置验证脚本
# 用于检查 continuous-learning 系统是否正确配置

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ECC 工作流 - Continuous Learning 配置验证"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 配置
HOMUNCULUS_DIR="$HOME/.cursor/homunculus"
SETTINGS_FILE="$HOME/.cursor/settings.json"
HOOKS_DIR="$HOME/.cursor/hooks"

# 计数器
PASSED=0
FAILED=0

# 检查函数
check() {
    local desc="$1"
    local cmd="$2"
    
    printf "%-50s" "  $desc"
    
    if eval "$cmd" >/dev/null 2>&1; then
        echo "✅"
        PASSED=$((PASSED + 1))
    else
        echo "❌"
        FAILED=$((FAILED + 1))
    fi
}

# 1. 检查配置文件
echo "📋 检查配置文件"
echo "────────────────────────────────────────────────────"
check "settings.json 存在" "test -f '$SETTINGS_FILE'"
check "settings.json 包含 Hooks" "grep -q 'PreToolUse' '$SETTINGS_FILE'"
check "config.json 存在" "test -f '$HOMUNCULUS_DIR/config.json'"
check "observe.sh 存在" "test -f '$HOOKS_DIR/observe.sh'"
check "observe.sh 可执行" "test -x '$HOOKS_DIR/observe.sh'"
echo ""

# 2. 检查目录结构
echo "📂 检查目录结构"
echo "────────────────────────────────────────────────────"
check "homunculus/ 目录" "test -d '$HOMUNCULUS_DIR'"
check "observations.jsonl 文件" "test -f '$HOMUNCULUS_DIR/observations.jsonl'"
check "observations.archive/ 目录" "test -d '$HOMUNCULUS_DIR/observations.archive'"
check "instincts/personal/ 目录" "test -d '$HOMUNCULUS_DIR/instincts/personal'"
check "instincts/inherited/ 目录" "test -d '$HOMUNCULUS_DIR/instincts/inherited'"
check "evolved/skills/ 目录" "test -d '$HOMUNCULUS_DIR/evolved/skills'"
check "evolved/commands/ 目录" "test -d '$HOMUNCULUS_DIR/evolved/commands'"
check "evolved/agents/ 目录" "test -d '$HOMUNCULUS_DIR/evolved/agents'"
check "exports/ 目录" "test -d '$HOMUNCULUS_DIR/exports' || mkdir -p '$HOMUNCULUS_DIR/exports'"
echo ""

# 3. 检查命令文件
echo "⚙️  检查命令实现"
echo "────────────────────────────────────────────────────"
WORKFLOW_DIR="$(cd "$(dirname "$0")/.." && pwd)"
check "instinct-status 命令" "test -f '$WORKFLOW_DIR/.cursor/commands/instinct-status.md'"
check "instinct-export 命令" "test -f '$WORKFLOW_DIR/.cursor/commands/instinct-export.md'"
check "instinct-import 命令" "test -f '$WORKFLOW_DIR/.cursor/commands/instinct-import.md'"
check "evolve 命令" "test -f '$WORKFLOW_DIR/.cursor/commands/evolve.md'"
check "instinct-export 详细文档" "test -f '$WORKFLOW_DIR/.cursor/skills/continuous-learning/commands/instinct-export.md'"
check "instinct-import 详细文档" "test -f '$WORKFLOW_DIR/.cursor/skills/continuous-learning/commands/instinct-import.md'"
echo ""

# 4. 检查文档
echo "📖 检查文档"
echo "────────────────────────────────────────────────────"
check "使用指南" "test -f '$WORKFLOW_DIR/docs/continuous-learning-setup.md'"
check "SKILL 文档" "test -f '$WORKFLOW_DIR/.cursor/skills/continuous-learning/SKILL.md'"
check "Observer Agent" "test -f '$WORKFLOW_DIR/.cursor/skills/continuous-learning/agents/observer.md'"
check "记忆架构文档" "test -f '$WORKFLOW_DIR/docs/memory-architecture.md'"
check "变更日志" "test -f '$WORKFLOW_DIR/CHANGELOG.md'"
check "配置完成文档" "test -f '$WORKFLOW_DIR/CONFIG_COMPLETE.md'"
echo ""

# 5. 系统状态
echo "📊 系统状态"
echo "────────────────────────────────────────────────────"

# 观察文件大小
if [ -f "$HOMUNCULUS_DIR/observations.jsonl" ]; then
    OBS_SIZE=$(stat -f%z "$HOMUNCULUS_DIR/observations.jsonl" 2>/dev/null || stat -c%s "$HOMUNCULUS_DIR/observations.jsonl" 2>/dev/null || echo 0)
    OBS_LINES=$(wc -l < "$HOMUNCULUS_DIR/observations.jsonl" 2>/dev/null || echo 0)
    printf "  %-50s%s\n" "观察文件大小" "${OBS_SIZE} bytes"
    printf "  %-50s%s\n" "观察记录数" "$OBS_LINES 条"
else
    printf "  %-50s%s\n" "观察文件" "不存在 ❌"
fi

# Instinct 数量
PERSONAL_COUNT=$(ls "$HOMUNCULUS_DIR/instincts/personal/" 2>/dev/null | wc -l | tr -d ' ')
INHERITED_COUNT=$(ls "$HOMUNCULUS_DIR/instincts/inherited/" 2>/dev/null | wc -l | tr -d ' ')
printf "  %-50s%s\n" "个人 Instinct" "$PERSONAL_COUNT 个"
printf "  %-50s%s\n" "导入 Instinct" "$INHERITED_COUNT 个"

# 演化资源数量
SKILLS_COUNT=$(ls "$HOMUNCULUS_DIR/evolved/skills/" 2>/dev/null | wc -l | tr -d ' ')
COMMANDS_COUNT=$(ls "$HOMUNCULUS_DIR/evolved/commands/" 2>/dev/null | wc -l | tr -d ' ')
AGENTS_COUNT=$(ls "$HOMUNCULUS_DIR/evolved/agents/" 2>/dev/null | wc -l | tr -d ' ')
printf "  %-50s%s\n" "演化的 Skills" "$SKILLS_COUNT 个"
printf "  %-50s%s\n" "演化的 Commands" "$COMMANDS_COUNT 个"
printf "  %-50s%s\n" "演化的 Agents" "$AGENTS_COUNT 个"

echo ""

# 总结
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  验证结果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  ✅ 通过: %d\n" "$PASSED"
printf "  ❌ 失败: %d\n" "$FAILED"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "  🎉 配置完美！系统已就绪。"
    echo ""
    echo "  下一步："
    echo "  1. 重启 Cursor（让 Hooks 生效）"
    echo "  2. 正常开发，系统会自动收集数据"
    echo "  3. 运行 /instinct-status 查看学习成果"
    echo ""
    echo "  详细使用说明："
    echo "  cat docs/continuous-learning-setup.md"
else
    echo "  ⚠️  有 $FAILED 项检查失败，请检查配置。"
    echo ""
    echo "  解决方案："
    echo "  1. 确保运行过 scripts/install.sh"
    echo "  2. 检查 ~/.cursor/settings.json 是否正确"
    echo "  3. 查看详细文档: docs/continuous-learning-setup.md"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
