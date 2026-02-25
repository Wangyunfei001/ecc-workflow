#!/bin/bash

# ECC Workflow 验证脚本 v4.0
# 支持模式:
#   --mode core      仅验证官方核心能力
#   --mode learning  验证核心 + continuous-learning 增强层

set -euo pipefail

MODE="core"
STRICT=false
JSON_OUTPUT=false
TARGET_DIR="."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
USER_CURSOR_DIR="$HOME/.cursor"
HOMUNCULUS_DIR="$USER_CURSOR_DIR/homunculus"

ERRORS=0
WARNS=0
INFOS=0

err() {
    ERRORS=$((ERRORS + 1))
    echo "[ERROR] $1"
}

warn() {
    WARNS=$((WARNS + 1))
    echo "[WARN] $1"
}

info() {
    INFOS=$((INFOS + 1))
    echo "[INFO] $1"
}

check_file() {
    local path="$1"
    local level="$2"
    local message="$3"
    if [ -f "$path" ]; then
        info "$message: OK ($path)"
    else
        if [ "$level" = "error" ]; then
            err "$message: 缺失 ($path)"
        else
            warn "$message: 缺失 ($path)"
        fi
    fi
}

check_dir() {
    local path="$1"
    local level="$2"
    local message="$3"
    if [ -d "$path" ]; then
        info "$message: OK ($path)"
    else
        if [ "$level" = "error" ]; then
            err "$message: 缺失 ($path)"
        else
            warn "$message: 缺失 ($path)"
        fi
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --strict)
            STRICT=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [--mode core|learning] [--strict] [--json] [--target <path>]"
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

if [ "$MODE" != "core" ] && [ "$MODE" != "learning" ]; then
    echo "无效 mode: $MODE (仅支持 core|learning)"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "目标目录不存在: $TARGET_DIR"
    exit 1
fi

cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"
PROJECT_CURSOR_DIR="$TARGET_DIR/.cursor"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ECC Workflow 配置验证 (mode=$MODE)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "[Group] Contract"
check_file "$WORKFLOW_DIR/.cursor-plugin/plugin.json" "error" "plugin manifest"
check_dir "$WORKFLOW_DIR/agents" "error" "repo agents"
check_dir "$WORKFLOW_DIR/skills" "error" "repo skills"
check_dir "$WORKFLOW_DIR/commands" "error" "repo commands"
check_dir "$WORKFLOW_DIR/rules" "error" "repo rules"
check_dir "$WORKFLOW_DIR/hooks" "error" "repo hooks"

echo ""
echo "[Group] Install"
check_dir "$PROJECT_CURSOR_DIR/agents" "error" "project agents"
check_dir "$PROJECT_CURSOR_DIR/skills" "error" "project skills"
check_dir "$PROJECT_CURSOR_DIR/commands" "error" "project commands"
check_dir "$PROJECT_CURSOR_DIR/rules" "error" "project rules"
check_file "$PROJECT_CURSOR_DIR/hooks.json" "error" "project hooks.json"

echo ""
echo "[Group] Hooks"
check_file "$PROJECT_CURSOR_DIR/hooks/hooks.core.json" "error" "layer file hooks.core.json"
check_file "$PROJECT_CURSOR_DIR/hooks/hooks.compat.json" "warn" "layer file hooks.compat.json"
if [ "$MODE" = "learning" ]; then
    check_file "$PROJECT_CURSOR_DIR/hooks/hooks.learning.json" "warn" "layer file hooks.learning.json"
fi

if [ -f "$PROJECT_CURSOR_DIR/hooks.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq -e '.version | numbers' "$PROJECT_CURSOR_DIR/hooks.json" >/dev/null 2>&1; then
            info "hooks version 字段合法"
        else
            err "hooks version 字段不合法（应为数字）"
        fi

        if jq -e '.hooks | type=="object"' "$PROJECT_CURSOR_DIR/hooks.json" >/dev/null 2>&1; then
            info "hooks 顶层对象合法"
        else
            err "hooks 顶层对象缺失或类型错误"
        fi

        if jq -e '.hooks.preToolUse' "$PROJECT_CURSOR_DIR/hooks.json" >/dev/null 2>&1; then
            info "preToolUse 已配置"
        else
            warn "preToolUse 未配置"
        fi

        if [ "$MODE" = "learning" ]; then
            if jq -e '.hooks.preToolUse[]?.command | strings | contains("observe.sh")' "$PROJECT_CURSOR_DIR/hooks.json" >/dev/null 2>&1; then
                info "learning hook 已合并到 preToolUse"
            else
                warn "learning hook 可能未合并到 preToolUse"
            fi
        fi
    else
        warn "未检测到 jq，跳过 hooks 结构化校验"
    fi
fi

echo ""
if [ "$MODE" = "learning" ]; then
    echo "[Group] Learning"
    check_dir "$HOMUNCULUS_DIR" "warn" "homunculus 根目录"
    check_dir "$HOMUNCULUS_DIR/instincts/personal" "warn" "instincts/personal"
    check_dir "$HOMUNCULUS_DIR/instincts/inherited" "warn" "instincts/inherited"
    check_file "$HOMUNCULUS_DIR/observations.jsonl" "warn" "observations.jsonl"
    check_file "$USER_CURSOR_DIR/hooks/observe.sh" "warn" "observe.sh"
    if [ -f "$USER_CURSOR_DIR/hooks/observe.sh" ]; then
        if [ -x "$USER_CURSOR_DIR/hooks/observe.sh" ]; then
            info "observe.sh 可执行"
        else
            warn "observe.sh 不可执行"
        fi

        # 能力探针: 验证 observe.sh 是否包含 stdin 优先 + input_raw 记录能力
        if grep -Eq "STDIN_PAYLOAD|input_raw" "$USER_CURSOR_DIR/hooks/observe.sh" >/dev/null 2>&1; then
            info "observe.sh 能力探针通过（stdin/input_raw）"
        else
            warn "observe.sh 可能为旧版本（缺少 stdin/input_raw 能力）"
        fi
    fi
else
    info "core 模式下跳过 learning 组检查"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  验证结果"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ERROR: $ERRORS"
echo "WARN:  $WARNS"
echo "INFO:  $INFOS"

if [ "$JSON_OUTPUT" = true ]; then
    echo "{\"mode\":\"$MODE\",\"errors\":$ERRORS,\"warnings\":$WARNS,\"infos\":$INFOS}"
fi

if [ "$ERRORS" -gt 0 ]; then
    exit 1
fi

if [ "$STRICT" = true ] && [ "$WARNS" -gt 0 ]; then
    exit 1
fi

exit 0
