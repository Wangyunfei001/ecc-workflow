#!/bin/bash

# ECC Workflow 安装脚本 v4.0
# 默认: marketplace core 模式
# 可选: --enable-learning 启用 continuous-learning 增强

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"

TARGET_DIR="."
ENABLE_LEARNING=false
DRY_RUN=false
VERIFY_AFTER=false
VERIFY_ONLY=false
MARKETPLACE_MODE=true

print_help() {
    echo "ECC Workflow 安装脚本 v4.0"
    echo ""
    echo "用法:"
    echo "  $0 [选项] [目标项目路径]"
    echo ""
    echo "选项:"
    echo "  --marketplace       使用官方核心模式（默认）"
    echo "  --enable-learning   启用 continuous-learning 增强层"
    echo "  --dry-run           仅打印将执行动作，不写入文件"
    echo "  --verify-after      安装后自动运行验证脚本"
    echo "  --verify            仅执行验证（转调 scripts/verify-setup.sh）"
    echo "  --enable-hooks      兼容旧参数，等价于 --enable-learning"
    echo "  -h, --help          显示帮助"
}

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] $*"
    else
        eval "$@"
    fi
}

copy_component() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ ! -d "$src" ]; then
        echo -e "  ${YELLOW}⚠ 跳过 ${name}：源目录不存在 ${src}${NC}"
        return 0
    fi

    run_cmd "mkdir -p \"$dst\""
    run_cmd "cp -R \"$src\"/. \"$dst\"/"
    echo -e "  ✓ ${name} 已复制"
}

compose_project_hooks() {
    local hooks_src_dir="$1"
    local hooks_out="$2"
    local core_file="$hooks_src_dir/hooks.core.json"
    local compat_file="$hooks_src_dir/hooks.compat.json"
    local learning_file="$hooks_src_dir/hooks.learning.json"

    if [ ! -f "$core_file" ]; then
        echo -e "  ${RED}✗ 缺少 core hooks 文件: $core_file${NC}"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        local layers="core+compat"
        if [ "$ENABLE_LEARNING" = true ]; then
            layers="core+compat+learning"
        fi
        echo "[dry-run] compose hooks layers => ${layers} -> $hooks_out"
        return 0
    fi

    if command -v jq >/dev/null 2>&1; then
        local input_files=("$core_file" "$compat_file")
        if [ "$ENABLE_LEARNING" = true ] && [ -f "$learning_file" ]; then
            input_files+=("$learning_file")
        fi

        jq -s '
            reduce .[] as $cfg (
              {version: 1, hooks: {preToolUse: [], postToolUse: [], beforeSubmitPrompt: [], stop: []}};
              .hooks.preToolUse += ($cfg.hooks.preToolUse // []) |
              .hooks.postToolUse += ($cfg.hooks.postToolUse // []) |
              .hooks.beforeSubmitPrompt += ($cfg.hooks.beforeSubmitPrompt // []) |
              .hooks.stop += ($cfg.hooks.stop // [])
            )
        ' "${input_files[@]}" > "$hooks_out"
    else
        cp "$core_file" "$hooks_out"
        echo -e "  ${YELLOW}⚠ 未检测到 jq，已降级为仅 core hooks${NC}"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --marketplace)
            MARKETPLACE_MODE=true
            shift
            ;;
        --enable-learning|--enable-hooks)
            ENABLE_LEARNING=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verify-after)
            VERIFY_AFTER=true
            shift
            ;;
        --verify)
            VERIFY_ONLY=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

if [ "$VERIFY_ONLY" = true ]; then
    VERIFY_MODE="core"
    if [ "$ENABLE_LEARNING" = true ]; then
        VERIFY_MODE="learning"
    fi
    exec bash "$SCRIPT_DIR/verify-setup.sh" --mode "$VERIFY_MODE" --target "$TARGET_DIR"
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误：目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"

USER_CURSOR_DIR="$HOME/.cursor"
HOMUNCULUS_DIR="$USER_CURSOR_DIR/homunculus"
PROJECT_CURSOR_DIR="$TARGET_DIR/.cursor"
BACKUP_DIR="$PROJECT_CURSOR_DIR/.ecc-backup/$(date +%Y%m%d%H%M%S)"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}   ECC Workflow 安装脚本 v4.0        ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo
echo -e "${BLUE}模式:${NC} marketplace(core) = ${MARKETPLACE_MODE}, learning = ${ENABLE_LEARNING}"
echo -e "${BLUE}目标项目:${NC} $TARGET_DIR"
echo -e "${BLUE}dry-run:${NC} $DRY_RUN"
echo

if [ "$DRY_RUN" = false ]; then
    read -p "确认执行安装？[Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n "${REPLY:-}" ]]; then
        echo -e "${YELLOW}安装取消${NC}"
        exit 0
    fi
fi

echo -e "${GREEN}[1/5] 创建目录与备份...${NC}"
run_cmd "mkdir -p \"$PROJECT_CURSOR_DIR\"/{agents,skills,commands,rules,hooks,templates}"
run_cmd "mkdir -p \"$BACKUP_DIR\""

for dir in agents skills commands rules hooks templates; do
    if [ -d "$PROJECT_CURSOR_DIR/$dir" ] && [ "$DRY_RUN" = false ]; then
        cp -R "$PROJECT_CURSOR_DIR/$dir" "$BACKUP_DIR/" 2>/dev/null || true
    fi
done
echo -e "  ✓ 备份目录: $BACKUP_DIR"

echo -e "${GREEN}[2/5] 复制核心组件（根目录映射）...${NC}"
copy_component "$WORKFLOW_DIR/agents" "$PROJECT_CURSOR_DIR/agents" "agents"
copy_component "$WORKFLOW_DIR/skills" "$PROJECT_CURSOR_DIR/skills" "skills"
copy_component "$WORKFLOW_DIR/commands" "$PROJECT_CURSOR_DIR/commands" "commands"
copy_component "$WORKFLOW_DIR/rules" "$PROJECT_CURSOR_DIR/rules" "rules"
copy_component "$WORKFLOW_DIR/hooks" "$PROJECT_CURSOR_DIR/hooks" "hooks"
copy_component "$WORKFLOW_DIR/templates" "$PROJECT_CURSOR_DIR/templates" "templates"

if [ -d "$WORKFLOW_DIR/hooks" ]; then
    compose_project_hooks "$WORKFLOW_DIR/hooks" "$PROJECT_CURSOR_DIR/hooks.json"
    echo -e "  ✓ 项目级 hooks 已按分层合成: .cursor/hooks.json"
fi

echo -e "${GREEN}[3/5] 处理 learning 增强层...${NC}"
if [ "$ENABLE_LEARNING" = true ]; then
    run_cmd "mkdir -p \"$USER_CURSOR_DIR/hooks\""
    run_cmd "mkdir -p \"$HOMUNCULUS_DIR\"/{instincts/personal,instincts/inherited,evolved/agents,evolved/skills,evolved/commands,observations.archive,exports}"
    run_cmd "touch \"$HOMUNCULUS_DIR/observations.jsonl\""

    if [ -f "$WORKFLOW_DIR/skills/continuous-learning/hooks/observe.sh" ]; then
        run_cmd "cp \"$WORKFLOW_DIR/skills/continuous-learning/hooks/observe.sh\" \"$USER_CURSOR_DIR/hooks/observe.sh\""
        run_cmd "chmod +x \"$USER_CURSOR_DIR/hooks/observe.sh\""
        echo -e "  ✓ observe.sh 已安装到 ~/.cursor/hooks/"
    else
        echo -e "  ${YELLOW}⚠ 未找到 observe.sh，跳过${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠ 未启用 learning 模式（如需启用请加 --enable-learning）${NC}"
fi

echo -e "${GREEN}[4/5] 写入项目辅助文件...${NC}"
run_cmd "mkdir -p \"$TARGET_DIR/docs/CODEMAPS\""
if [ ! -f "$TARGET_DIR/docs/CODEMAPS/overview.md" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] create docs/CODEMAPS/overview.md"
    else
        cat > "$TARGET_DIR/docs/CODEMAPS/overview.md" << 'EOF'
# 项目代码地图

## 目录结构

请根据实际项目补充目录与模块说明。
EOF
    fi
    echo -e "  ✓ docs/CODEMAPS/overview.md"
fi

echo -e "${GREEN}[5/5] 完成与下一步...${NC}"
echo -e "  • 已安装核心组件到 ${PROJECT_CURSOR_DIR}"
if [ "$ENABLE_LEARNING" = true ]; then
    echo -e "  • 已启用 learning 增强目录: ${HOMUNCULUS_DIR}"
fi
echo -e "  • 备份路径: ${BACKUP_DIR}"

if [ "$VERIFY_AFTER" = true ]; then
    VERIFY_MODE="core"
    if [ "$ENABLE_LEARNING" = true ]; then
        VERIFY_MODE="learning"
    fi
    echo
    echo -e "${BLUE}运行安装后验证（mode=${VERIFY_MODE}）...${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] bash \"$SCRIPT_DIR/verify-setup.sh\" --mode \"$VERIFY_MODE\" --target \"$TARGET_DIR\""
    else
        bash "$SCRIPT_DIR/verify-setup.sh" --mode "$VERIFY_MODE" --target "$TARGET_DIR"
    fi
fi

echo
echo -e "${GREEN}安装流程结束。${NC}"
