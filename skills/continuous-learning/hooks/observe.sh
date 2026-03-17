#!/bin/bash

# ECC 工作流观察脚本
# 用于捕获工具调用并记录到 observations.jsonl
# 使用方法: observe.sh [pre|post]

set -euo pipefail

# 配置
HOMUNCULUS_DIR="${HOMUNCULUS_DIR:-$HOME/.cursor/homunculus}"
OBSERVATIONS_FILE="$HOMUNCULUS_DIR/observations.jsonl"
MAX_FILE_SIZE_MB=10
STDIN_PAYLOAD=""

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

    # 默认从环境变量兜底，兼容旧行为
    local tool_name="${TOOL_NAME:-unknown}"
    local tool_input="${TOOL_INPUT:-{}}"
    local tool_output="${TOOL_OUTPUT:-}"
    local user_prompt="${USER_PROMPT:-}"
    local session_id="${SESSION_ID:-$(date +%Y%m%d)}"

    # 若有 stdin JSON 且可解析，优先使用 stdin 字段
    if [ -n "$STDIN_PAYLOAD" ] && command -v jq >/dev/null 2>&1; then
        if echo "$STDIN_PAYLOAD" | jq empty >/dev/null 2>&1; then
            local stdin_tool_name
            stdin_tool_name="$(echo "$STDIN_PAYLOAD" | jq -r '.tool_name // .toolName // .tool.name // empty')"
            local stdin_tool_output
            stdin_tool_output="$(echo "$STDIN_PAYLOAD" | jq -r '.tool_output // .toolOutput // .output // empty')"
            local stdin_user_prompt
            stdin_user_prompt="$(echo "$STDIN_PAYLOAD" | jq -r '.user_prompt // .userPrompt // .prompt // empty')"
            local stdin_session_id
            stdin_session_id="$(echo "$STDIN_PAYLOAD" | jq -r '.session_id // .sessionId // empty')"
            local stdin_tool_input
            stdin_tool_input="$(echo "$STDIN_PAYLOAD" | jq -c '.tool_input // .toolInput // .input // {}')"

            if [ -n "$stdin_tool_name" ]; then
                tool_name="$stdin_tool_name"
            fi
            if [ -n "$stdin_tool_output" ]; then
                tool_output="$stdin_tool_output"
            fi
            if [ -n "$stdin_user_prompt" ]; then
                user_prompt="$stdin_user_prompt"
            fi
            if [ -n "$stdin_session_id" ]; then
                session_id="$stdin_session_id"
            fi
            tool_input="$stdin_tool_input"
        fi
    fi

    # 使用 jq 生成 JSON，避免引号/换行破坏记录
    if command -v jq >/dev/null 2>&1; then
        local safe_tool_input="$tool_input"
        local input_raw=""
        if ! echo "$safe_tool_input" | jq -e . >/dev/null 2>&1; then
            input_raw="$safe_tool_input"
            safe_tool_input="{}"
        fi

        jq -nc \
            --arg timestamp "$timestamp" \
            --arg phase "$phase" \
            --arg session_id "$session_id" \
            --arg tool "$tool_name" \
            --arg output_preview "${tool_output:0:200}" \
            --arg user_prompt_preview "${user_prompt:0:200}" \
            --arg input_raw "$input_raw" \
            --argjson input "$safe_tool_input" \
            '{
              timestamp: $timestamp,
              phase: $phase,
              session_id: $session_id,
              tool: $tool,
              input: $input,
              input_raw: (if $input_raw == "" then null else $input_raw end),
              output_preview: $output_preview,
              user_prompt_preview: $user_prompt_preview
            }' >> "$OBSERVATIONS_FILE"
    else
        # 无 jq 时保底记录（输入按字符串存储）
        printf '{"timestamp":"%s","phase":"%s","session_id":"%s","tool":"%s","input":"%s","output_preview":"%s","user_prompt_preview":"%s"}\n' \
            "$timestamp" "$phase" "$session_id" "$tool_name" "$tool_input" "${tool_output:0:200}" "${user_prompt:0:200}" >> "$OBSERVATIONS_FILE"
    fi
}

# 主逻辑
main() {
    local phase="${1:-unknown}"

    # 优先读取 stdin，支持 Cursor hooks 的 JSON 输入。
    # 交互终端（TTY）下不读取，避免手工执行时阻塞。
    # 非 TTY 但无输入时，避免无限等待。
    if [ ! -t 0 ]; then
        if command -v timeout >/dev/null 2>&1; then
            STDIN_PAYLOAD="$(timeout 0.1s cat 2>/dev/null || true)"
        elif [ -p /dev/stdin ]; then
            STDIN_PAYLOAD="$(cat || true)"
        else
            STDIN_PAYLOAD=""
        fi
    fi
    
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
