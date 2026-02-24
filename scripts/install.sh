#!/bin/bash

# ECC Workflow 安装脚本 v3.0
# 
# 使用方法:
#   ./scripts/install.sh [target-project-path]              # 基本安装
#   ./scripts/install.sh --enable-hooks [target-project]    # 安装并自动配置hooks
#   ./scripts/install.sh --verify [target-project]          # 验证安装完整性
# 
# 安装内容:
# 1. 项目级配置 (.cursor/, docs/) - 跟随 Git，团队共享
# 2. 用户级配置 (~/.cursor/homunculus/) - 个人记忆，不共享

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$(dirname "$SCRIPT_DIR")"

# 参数解析
ENABLE_HOOKS=false
VERIFY_ONLY=false
TARGET_DIR="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --enable-hooks)
            ENABLE_HOOKS=true
            shift
            ;;
        --verify)
            VERIFY_ONLY=true
            shift
            ;;
        -h|--help)
            echo "ECC Workflow 安装脚本 v3.0"
            echo ""
            echo "使用方法:"
            echo "  $0 [选项] [目标项目路径]"
            echo ""
            echo "选项:"
            echo "  --enable-hooks    自动配置 settings.json 启用 Hooks"
            echo "  --verify          仅验证安装完整性（不执行安装）"
            echo "  -h, --help        显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                          # 安装到当前目录"
            echo "  $0 /path/to/project         # 安装到指定目录"
            echo "  $0 --enable-hooks           # 安装并自动配置hooks"
            echo "  $0 --verify                 # 验证当前目录安装状态"
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# 用户级目录
USER_CURSOR_DIR="$HOME/.cursor"
HOMUNCULUS_DIR="$USER_CURSOR_DIR/homunculus"

# === 验证模式 ===
if [ "$VERIFY_ONLY" = true ]; then
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}   ECC Workflow 安装验证             ${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo
    
    ERRORS=0
    
    # 检查目标目录
    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}错误：目标目录不存在: $TARGET_DIR${NC}"
        exit 1
    fi
    cd "$TARGET_DIR"
    
    echo -e "${BLUE}[检查项目级配置]${NC}"
    
    # 检查必需目录
    REQUIRED_DIRS=(".cursor/agents" ".cursor/skills" ".cursor/templates" "docs/requirements" "docs/specs")
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "  ✓ $dir"
        else
            echo -e "  ${RED}✗ $dir 缺失${NC}"
            ((ERRORS++))
        fi
    done
    
    # 检查核心skills
    echo -e ""
    echo -e "${BLUE}[检查核心Skills]${NC}"
    CORE_SKILLS=(
        ".cursor/skills/spec-driven-dev/SKILL.md"
        ".cursor/skills/continuous-learning/SKILL.md"
        ".cursor/skills/requirement-analysis/SKILL.md"
        ".cursor/skills/task-planning/SKILL.md"
        ".cursor/skills/architecture-design/SKILL.md"
        ".cursor/skills/spec-writing/SKILL.md"
        ".cursor/skills/code-implementation/SKILL.md"
        ".cursor/skills/active-learning/SKILL.md"
        ".cursor/skills/passive-learning/SKILL.md"
        ".cursor/skills/instinct-evolution/SKILL.md"
        ".cursor/skills/eval-integration/SKILL.md"
        ".cursor/skills/doc-sync/SKILL.md"
        ".cursor/skills/strategic-context/SKILL.md"
    )
    for skill in "${CORE_SKILLS[@]}"; do
        if [ -f "$skill" ]; then
            echo -e "  ✓ $(basename $(dirname $skill))"
        else
            echo -e "  ${RED}✗ $(basename $(dirname $skill)) 缺失${NC}"
            ((ERRORS++))
        fi
    done
    
    # 检查核心agents
    echo -e ""
    echo -e "${BLUE}[检查核心Agents]${NC}"
    CORE_AGENTS=(".cursor/agents/requirement-analyst.md" ".cursor/agents/spec-writer.md")
    for agent in "${CORE_AGENTS[@]}"; do
        if [ -f "$agent" ]; then
            echo -e "  ✓ $(basename $agent)"
        else
            echo -e "  ${RED}✗ $(basename $agent) 缺失${NC}"
            ((ERRORS++))
        fi
    done
    
    # 检查模板
    echo -e ""
    echo -e "${BLUE}[检查模板]${NC}"
    TEMPLATES=(".cursor/templates/requirement-template.md" ".cursor/templates/spec-template.md")
    for template in "${TEMPLATES[@]}"; do
        if [ -f "$template" ]; then
            echo -e "  ✓ $(basename $template)"
        else
            echo -e "  ${RED}✗ $(basename $template) 缺失${NC}"
            ((ERRORS++))
        fi
    done
    
    # 检查用户级配置
    echo -e ""
    echo -e "${BLUE}[检查用户级配置]${NC}"
    if [ -d "$HOMUNCULUS_DIR" ]; then
        echo -e "  ✓ ~/.cursor/homunculus/"
    else
        echo -e "  ${YELLOW}⚠ ~/.cursor/homunculus/ 缺失（可选）${NC}"
    fi
    
    if [ -f "$USER_CURSOR_DIR/hooks/observe.sh" ]; then
        echo -e "  ✓ ~/.cursor/hooks/observe.sh"
    else
        echo -e "  ${YELLOW}⚠ ~/.cursor/hooks/observe.sh 缺失（可选）${NC}"
    fi
    
    # 输出结果
    echo -e ""
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}=====================================${NC}"
        echo -e "${GREEN}   验证通过！所有核心组件已安装       ${NC}"
        echo -e "${GREEN}=====================================${NC}"
        exit 0
    else
        echo -e "${RED}=====================================${NC}"
        echo -e "${RED}   验证失败！发现 $ERRORS 个问题       ${NC}"
        echo -e "${RED}=====================================${NC}"
        echo -e "请运行 ${YELLOW}./scripts/install.sh${NC} 重新安装"
        exit 1
    fi
fi

# === 安装模式 ===
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}   ECC Workflow 安装脚本 v3.0        ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo
echo -e "${BLUE}本脚本将安装两部分内容:${NC}"
echo -e "  1. ${YELLOW}项目级${NC} - .cursor/, docs/ (提交到 Git，团队共享)"
echo -e "  2. ${YELLOW}用户级${NC} - ~/.cursor/homunculus/ (个人记忆，不共享)"
if [ "$ENABLE_HOOKS" = true ]; then
    echo -e "  3. ${YELLOW}自动配置${NC} - 自动更新 settings.json 启用 Hooks"
fi
echo

# 检查目标目录
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误：目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

cd "$TARGET_DIR"
TARGET_DIR="$(pwd)"

echo -e "${YELLOW}目标项目: $TARGET_DIR${NC}"
echo -e "${YELLOW}用户目录: $HOMUNCULUS_DIR${NC}"
echo

# 确认安装
read -p "确认安装 ECC Workflow？[Y/n] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
    echo -e "${YELLOW}安装取消${NC}"
    exit 0
fi

echo
echo -e "${GREEN}[1/6] 创建项目级目录结构...${NC}"

# 创建 .cursor 目录结构（项目级）
mkdir -p .cursor/{agents,skills,commands,rules,hooks,templates,contexts}

# 创建文档目录结构（项目级 - Obsidian 记忆）
mkdir -p docs/{requirements,plans,architecture,adrs,specs/features,specs/apis,specs/components,CODEMAPS}

echo -e "  ✓ .cursor/ 目录已创建 (项目级)"
echo -e "  ✓ docs/ 目录已创建 (Obsidian 记忆)"

echo
echo -e "${GREEN}[2/6] 创建用户级记忆目录...${NC}"

# 创建 homunculus 目录结构（用户级 - 个人记忆）
mkdir -p "$HOMUNCULUS_DIR"/{instincts/personal,instincts/inherited,evolved/agents,evolved/skills,evolved/commands,observations.archive}

# 创建 identity.json（如果不存在）
if [ ! -f "$HOMUNCULUS_DIR/identity.json" ]; then
    CREATED_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    cat > "$HOMUNCULUS_DIR/identity.json" << EOF
{
  "version": "1.0",
  "created": "${CREATED_DATE}",
  "preferences": {
    "language": "zh-CN",
    "code_style": "functional",
    "test_first": true
  },
  "stats": {
    "sessions": 0,
    "instincts_learned": 0,
    "corrections_made": 0
  }
}
EOF
    echo -e "  ✓ identity.json 已创建"
fi

# 创建空的 observations.jsonl
touch "$HOMUNCULUS_DIR/observations.jsonl"

echo -e "  ✓ ~/.cursor/homunculus/ 已创建 (用户级记忆)"
echo -e "  ✓ observations.jsonl 已创建 (观察日志)"

echo
echo -e "${GREEN}[3/6] 复制工作流文件...${NC}"

# 复制 Agents
if [ -d "$WORKFLOW_DIR/.cursor/agents" ]; then
    cp -r "$WORKFLOW_DIR/.cursor/agents/"* .cursor/agents/ 2>/dev/null || true
    echo -e "  ✓ Agents 已复制"
fi

# 复制 Skills（包括新拆分的skills）
if [ -d "$WORKFLOW_DIR/.cursor/skills" ]; then
    cp -r "$WORKFLOW_DIR/.cursor/skills/"* .cursor/skills/ 2>/dev/null || true
    echo -e "  ✓ Skills 已复制"
fi

# 复制 Commands
if [ -d "$WORKFLOW_DIR/.cursor/commands" ]; then
    cp -r "$WORKFLOW_DIR/.cursor/commands/"* .cursor/commands/ 2>/dev/null || true
    echo -e "  ✓ Commands 已复制"
fi

# 复制 Rules
if [ -d "$WORKFLOW_DIR/.cursor/rules" ]; then
    cp -r "$WORKFLOW_DIR/.cursor/rules/"* .cursor/rules/ 2>/dev/null || true
    echo -e "  ✓ Rules 已复制"
fi

# 复制 Hooks
if [ -d "$WORKFLOW_DIR/.cursor/hooks" ]; then
    cp -r "$WORKFLOW_DIR/.cursor/hooks/"* .cursor/hooks/ 2>/dev/null || true
    echo -e "  ✓ Hooks 已复制"
fi

# 复制 Templates（包括新的输出模板）
if [ -d "$WORKFLOW_DIR/.cursor/templates" ]; then
    cp -r "$WORKFLOW_DIR/.cursor/templates/"* .cursor/templates/ 2>/dev/null || true
    echo -e "  ✓ Templates 已复制"
fi

echo
echo -e "${GREEN}[4/6] 配置 Hooks 观察脚本...${NC}"

# 复制观察脚本到用户目录
if [ -f "$WORKFLOW_DIR/.cursor/skills/continuous-learning/hooks/observe.sh" ]; then
    mkdir -p "$USER_CURSOR_DIR/hooks"
    cp "$WORKFLOW_DIR/.cursor/skills/continuous-learning/hooks/observe.sh" "$USER_CURSOR_DIR/hooks/"
    chmod +x "$USER_CURSOR_DIR/hooks/observe.sh"
    echo -e "  ✓ observe.sh 已复制到 ~/.cursor/hooks/"
fi

# 自动配置 settings.json（如果启用）
if [ "$ENABLE_HOOKS" = true ]; then
    echo
    echo -e "${GREEN}[4.5/6] 自动配置 settings.json...${NC}"
    
    SETTINGS_FILE="$USER_CURSOR_DIR/settings.json"
    
    if [ -f "$SETTINGS_FILE" ]; then
        # 检查是否已有hooks配置
        if grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null; then
            echo -e "  ${YELLOW}⚠ settings.json 已包含 hooks 配置，跳过${NC}"
        else
            # 备份原文件
            cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d%H%M%S)"
            echo -e "  ✓ 已备份 settings.json"
            
            # 使用 jq 合并配置（如果可用）
            if command -v jq &> /dev/null; then
                HOOKS_CONFIG='{"hooks":{"PreToolUse":[{"matcher":"*","hooks":[{"type":"command","command":"~/.cursor/hooks/observe.sh pre"}]}],"PostToolUse":[{"matcher":"*","hooks":[{"type":"command","command":"~/.cursor/hooks/observe.sh post"}]}]}}'
                jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$HOOKS_CONFIG") > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
                echo -e "  ✓ hooks 配置已添加到 settings.json"
            else
                echo -e "  ${YELLOW}⚠ jq 未安装，请手动配置 settings.json${NC}"
            fi
        fi
    else
        # 创建新的 settings.json
        cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/hooks/observe.sh pre"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/hooks/observe.sh post"
      }]
    }]
  }
}
EOF
        echo -e "  ✓ settings.json 已创建并配置 hooks"
    fi
else
    # 提示用户手动配置
    echo -e "  ${YELLOW}⚠️ 请手动将以下内容添加到 ~/.cursor/settings.json 以启用自进化:${NC}"
    cat << 'EOF'

{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/hooks/observe.sh pre"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.cursor/hooks/observe.sh post"
      }]
    }]
  }
}

EOF
    echo -e "  ${BLUE}提示: 使用 --enable-hooks 选项可自动配置${NC}"
fi

echo
echo -e "${GREEN}[5/6] 创建示例文件...${NC}"

# 创建 CODEMAPS/overview.md
if [ ! -f docs/CODEMAPS/overview.md ]; then
    cat > docs/CODEMAPS/overview.md << 'EOF'
# 项目代码地图

## 目录结构

```
project/
├── src/                    # 源代码
│   ├── api/               # API 端点
│   ├── components/        # UI 组件
│   ├── types/             # TypeScript 类型
│   └── utils/             # 工具函数
├── docs/                   # 文档
│   ├── specs/             # 技术规格
│   ├── plans/             # 实施计划
│   └── adrs/              # 架构决策
└── tests/                  # 测试文件
```

## 模块说明

[在此添加各模块的简要说明]
EOF
    echo -e "  ✓ CODEMAPS/overview.md 已创建"
fi

# 创建 .gitignore 追加（如果不存在相关规则）
if [ -f .gitignore ]; then
    if ! grep -q "# ECC Workflow" .gitignore 2>/dev/null; then
        cat >> .gitignore << 'EOF'

# ECC Workflow
.cursor/homunculus/observations.jsonl
.cursor/homunculus/observations.archive/
EOF
        echo -e "  ✓ .gitignore 已更新"
    fi
fi

echo
echo -e "${GREEN}[6/6] 验证安装...${NC}"

# 统计安装的文件
AGENT_COUNT=$(find .cursor/agents -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find .cursor/skills -type d -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
COMMAND_COUNT=$(find .cursor/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
RULE_COUNT=$(find .cursor/rules -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
TEMPLATE_COUNT=$(find .cursor/templates -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}   安装完成！                        ${NC}"
echo -e "${GREEN}=====================================${NC}"
echo
echo -e "已安装组件:"
echo -e "  ${BLUE}[项目级 - 团队共享]${NC}"
echo -e "  • Agents:    ${AGENT_COUNT} 个"
echo -e "  • Skills:    ${SKILL_COUNT} 个"
echo -e "  • Commands:  ${COMMAND_COUNT} 个"
echo -e "  • Rules:     ${RULE_COUNT} 个"
echo -e "  • Templates: ${TEMPLATE_COUNT} 个"
echo -e "  • docs/      Obsidian 记忆目录"
echo
echo -e "  ${BLUE}[用户级 - 个人记忆]${NC}"
echo -e "  • ~/.cursor/homunculus/instincts/   Instinct 存储"
echo -e "  • ~/.cursor/homunculus/evolved/     演化产物"
echo -e "  • ~/.cursor/homunculus/observations.jsonl  观察日志"
echo
echo -e "${YELLOW}下一步:${NC}"
echo -e "  1. 提交项目级配置: git add .cursor/ docs/ && git commit -m 'chore: add ECC workflow v3.0'"
if [ "$ENABLE_HOOKS" = false ]; then
    echo -e "  2. 配置 Hooks 启用自进化（见上方说明，或重新运行 --enable-hooks）"
fi
echo -e "  3. 验证安装: ./scripts/install.sh --verify"
echo -e "  4. 运行第一个命令: /analyze \"你的第一个功能\""
echo -e "  5. 查看 Skill 组合文档: docs/skill-composition.md"
echo
echo -e "${GREEN}Happy Coding!${NC}"
