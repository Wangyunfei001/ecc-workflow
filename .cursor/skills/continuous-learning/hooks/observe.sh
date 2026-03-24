#!/bin/bash

# ECC 工作流观察脚本 (Shell 封装层)
# 实际逻辑已迁移至 observe.mjs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v node >/dev/null 2>&1 && [ -f "$SCRIPT_DIR/observe.mjs" ]; then
    exec node "$SCRIPT_DIR/observe.mjs" "$@"
else
    echo "Warning: Node.js is required to run the observer hook properly." >&2
    # Fallback content could go here if really necessary, but we are enforcing Node.js first as per plan.
    exit 0
fi