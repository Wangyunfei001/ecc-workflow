#!/bin/bash

# ECC 工作流观察脚本
# 用于捕获工具调用并记录到 observations.jsonl
# 使用方法: observe.sh [pre|post]

set -e

# 配置
HOMUNCULUS_DIR="${HOMUNCULUS_DIR:-$HOME/.cursor/homunculus}"
OBSERVATIONS_FILE="$HOMUNCULUS_DIR/observations.jsonl"
MAX_FILE_SIZE_MB=10

# 确保目录存在
mkdir -p "$HOMUNCULUS_DIR"
mkdir -p "$HOMUNCULUS_DIR/instincts/personal"
mkdir -p "$HOMUNCULUS_DIR/instincts/inherited"
mkdir -p "$HOMUNCULUS_DIR/evolved/agents"
mkdir -p "$HOMUNCULUS_DIR/evolved/skills"
mkdir -p "$HOMUNCULUS_DIR/evolved/commands"
mkdir -p "$HOMUNCULUS_DIR/observations.archive"

# 检查文件大小，超过阈值则归档
check_and_archive() {
    if [ -f "$OBSERVATIONS_FILE" ]; then
        FILE_SIZE=$(stat -f%z "$OBSERVATIONS_FILE" 2>/dev/null || stat -c%s "$OBSERVATIONS_FILE" 2>/dev/null || echo 0)
        MAX_SIZE=$((MAX_FILE_SIZE_MB * 1024 * 1024))
        
        if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
            ARCHIVE_NAME="observations-$(date +%Y%m%d-%H%M%S).jsonl"
            mv "$OBSERVATIONS_FILE" "$HOMUNCULUS_DIR/observations.archive/$ARCHIVE_NAME"
            echo "Archived observations to $ARCHIVE_NAME" >&2
        fi
    fi
}

# 记录观察
record_observation() {
    local phase="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # 从环境变量获取工具调用信息
    local tool_name="${TOOL_NAME:-unknown}"
    local tool_input="${TOOL_INPUT:-{}}"
    local tool_output="${TOOL_OUTPUT:-}"
    local user_prompt="${USER_PROMPT:-}"
    local session_id="${SESSION_ID:-$(date +%Y%m%d)}"
    
    # 构建 JSON 记录
    local record=$(cat <<EOF
{"timestamp":"$timestamp","phase":"$phase","session_id":"$session_id","tool":"$tool_name","input":$tool_input,"output_preview":"${tool_output:0:200}","user_prompt_preview":"${user_prompt:0:200}"}
EOF
)
    
    # 追加到观察文件
    echo "$record" >> "$OBSERVATIONS_FILE"
}

# 主逻辑
main() {
    local phase="${1:-unknown}"
    
    case "$phase" in
        pre)
            # PreToolUse: 记录即将执行的工具调用
            check_and_archive
            record_observation "pre"
            ;;
        post)
            # PostToolUse: 记录工具执行结果
            record_observation "post"
            ;;
        *)
            echo "Usage: observe.sh [pre|post]" >&2
            exit 1
            ;;
    esac
}

main "$@"
