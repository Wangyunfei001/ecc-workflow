# AGENTS.md

## Cursor Cloud 专用说明

### 概述

本仓库为 **ecc-workflow**，一个 Cursor IDE 插件，完全由 Markdown、JSON 和 Bash 文件组成。无包管理器、无构建系统、无运行时服务、无自动化测试套件。

### 关键目录

| 目录 | 内容 |
|---|---|
| `agents/` | 10 个 AI agent 角色定义（architect、planner、coder、reviewer 等） |
| `skills/` | 13 个 skill 定义，每个有 `SKILL.md` 入口 |
| `commands/` | 11 个斜杠命令定义（`/analyze`、`/spec`、`/implement` 等） |
| `rules/` | 5 套规则（质量门禁、路由、编码规范、安全） |
| `templates/` | 3 个文档模板（ADR、需求、Spec） |
| `hooks/` | 自动化 hooks 配置（`hooks.json`） |
| `scripts/` | `install.sh`（将插件安装到项目）和 `verify-setup.sh`（验证持续学习配置） |
| `.cursor-plugin/` | Cursor Marketplace 的 `plugin.json` 清单 |

### 语法检查 / 验证

无传统 linter。可通过以下方式验证正确性：
- `bash -n scripts/install.sh scripts/verify-setup.sh` — Shell 语法检查
- `jq empty .cursor-plugin/plugin.json hooks/hooks.json hooks/hooks.core.json hooks/hooks.compat.json hooks/hooks.learning.json` — JSON 验证
- 验证所有 13 个 skills 均有 `SKILL.md`：`for d in skills/*/; do test -f "$d/SKILL.md" && echo "OK $d" || echo "MISSING $d"; done`

### 运行安装脚本

`scripts/install.sh` 为交互式（会提示确认）。非交互式使用时可通过管道传入 `echo "Y"`：
```
echo "Y" | bash scripts/install.sh [--enable-hooks] <target-project-path>
```

### TaskGraph 协议状态

任务分解与编排现采用统一的 TaskGraph 协议：

- 规范: `docs/architecture/task-graph-protocol.md`
- 命令级协议段：`orchestrate`、`learn-project`、`analyze`、`implement`、`review`
- 路由对齐: `rules/agent-routing.md`
- 能力探针: `scripts/verify-setup.sh --mode learning`

本仓库仍依赖 prompt/rule 驱动的编排，不包含独立的运行时 DAG 调度服务。

### 重构规范状态

重构规范包已就绪，应作为后续脚本变更的实现基线：

- `docs/architecture/plugin-contract.md`
- `docs/specs/features/installer-redesign.md`
- `docs/specs/features/hooks-layering.md`
- `docs/specs/features/verify-redesign.md`
- `docs/migration/legacy-to-marketplace.md`

重要：这些文档定义目标行为，不代表当前 shell 脚本已全部更新。
