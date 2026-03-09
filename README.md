# ecc-workflow

面向 Cursor 的规范驱动开发工作流 + 持续学习。

## 从 Marketplace 安装

从 Cursor Marketplace 安装：

1. 打开 Cursor Marketplace
2. 搜索 `ecc-workflow`
3. 点击 **Install**

或在对话中直接安装：

```bash
/add-plugin ecc-workflow
```

## 快速开始（5 分钟）

在新项目或现有项目中使用以下最小流程：

```bash
# 1) 澄清需求（Phase 1）
/analyze Build user login with email and phone support

# 2) 规划实施任务（Phase 2）
@planner @docs/requirements/<your-requirement-file>.md

# 3) 编写可实施的 Spec（Phase 4）
/spec @docs/plans/<your-plan-file>.md

# 4) 实现与验证（Phase 5）
/implement @docs/specs/features/<your-spec-file>.md
/review
/sync
```

对于复杂功能，在 `@planner` 和 `/spec` 之间运行 `@architect`。

## 本插件提供的内容

- `rules/`: 质量门禁、路由、编码与安全护栏
- `skills/`: 5 阶段规范驱动工作流与学习循环
- `agents/`: 需求/规划/架构/Spec/编码/审查/文档同步等角色
- `commands/`: `/analyze`、`/spec`、`/implement`、`/review`、`/sync` 及学习相关命令
- `hooks/`: 可选的项目钩子，用于提醒、检查与安全提示

## 典型流程

1. 运行 `/analyze` 澄清需求。
2. 使用 `@planner`，可选 `@architect` 进行规划/设计。
3. 运行 `/spec` 生成可实施级 Spec。
4. 运行 `/implement`，然后 `/review` 和 `/sync`。
5. 使用 `/learn-project` 和 `/evolve` 提升长期质量。

## 目录结构

```text
.
├── .cursor-plugin/plugin.json
├── rules/
├── skills/
├── agents/
├── commands/
├── hooks/
├── templates/
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## 说明

- `hooks/hooks.json` 为可选，用于项目级自动化。
- 现有 `templates/` 保留供 skill/command 引用。

## 重构状态

插件重构文档已就绪，首轮实现已在本仓库中落地。

- 契约: `docs/architecture/plugin-contract.md`
- 安装器重构: `docs/specs/features/installer-redesign.md`
- Hooks 分层: `docs/specs/features/hooks-layering.md`
- Verify 重构: `docs/specs/features/verify-redesign.md`
- 迁移指南: `docs/migration/legacy-to-marketplace.md`

当前方向：

- 优先核心模式（官方 Cursor 插件/hook 流程）
- 可选学习模式（`homunculus`）作为增强层
- 通过显式 `compat` 层保持向后兼容

已实现要点：

- `scripts/install.sh` 现支持 core/learning 模式安装及分层 hooks 组合。
- `scripts/verify-setup.sh` 现支持基于模式的验证及分组检查。
- `hooks/` 拆分为 `core`、`compat`、`learning` 三层。
- `observe.sh` 现支持 stdin 优先解析，并支持环境变量回退。

## TaskGraph 协议

任务分解现遵循统一协议：

- 协议规范: `docs/architecture/task-graph-protocol.md`
- 含协议段的命令：
  - `commands/orchestrate.md`
  - `commands/learn-project.md`
  - `commands/analyze.md`
  - `commands/implement.md`
  - `commands/review.md`
- 路由对齐: `rules/agent-routing.md`

若要在 Cursor UI 中触发并行 subagent 卡片，需确保命令/提示中指示 agent 在同一轮次启动多个 subagent，并包含简洁的 `description` 字段。

## 验证清单

```bash
bash -n scripts/install.sh scripts/verify-setup.sh
jq empty .cursor-plugin/plugin.json hooks/hooks.json hooks/hooks.core.json hooks/hooks.compat.json hooks/hooks.learning.json
for d in skills/*/; do test -f "$d/SKILL.md" && echo "OK $d" || echo "MISSING $d"; done
bash scripts/verify-setup.sh --mode core --target <target-project>
bash scripts/verify-setup.sh --mode learning --target <target-project>
```

## 许可证

MIT
