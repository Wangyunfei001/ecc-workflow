# 更新日志

## 1.2.0 - 2026-03-23

- **运行时架构升级 (Node First)**：
  - 核心脚本迁移至 Node.js (ESM)，使用零依赖的 `*.mjs` 替代复杂的 Shell 脚本，避免 `jq` 依赖和跨平台差异。
  - `install.sh` 与 `verify-setup.sh` 重构为薄分发器，当存在 Node 时调用对应的 `install.mjs` 和 `verify-setup.mjs`。
- **持续学习层重构**：
  - 用 `observe.mjs` 替代 `observe.sh` 处理 Hooks 事件。原生支持 stdin JSON 解析和安全的文件写入。
  - `observe.sh` 现仅作为兼容现有用户的薄包装，向后兼容。
- **规范驱动工作流 (Spec-driven Workflow) 增强**：
  - 新增 `scripts/gate-check.mjs`，支持对需求、计划、架构和规格文档进行自动化检查（Gate 1-4），并在 `ONBOARDING.md` 更新工作流。
  - 新增 `scripts/check-spec-code-alignment.mjs`，作为 Git pre-commit 钩子或提示使用，避免代码偏离 Spec。
- **上下文管理**：
  - 正式发布 `/compact` 命令 (`commands/compact.md`) 与配套的快照脚本 `snapshot-context.mjs`。
  - 引入 Agent 结构化交接协议：新增 `templates/handoff.yml.example`，优化多阶段 Agent 之间的上下文传递。
- **Instinct 管理**：
  - 新增 `scripts/instinct-decay.mjs` 周期性降低长时间未被强化的 Instinct 置信度。
  - 更新 `instinct-import` 策略，增加新人置信度上限与语义冲突指导。

## 1.1.2 - 2026-03-17

- 修复 `skills/continuous-learning/hooks/observe.sh` 文件权限：从 `644` 改为 `755`（添加可执行位），确保 Cursor hooks 运行时能直接调用。
- 修复 `/orchestrate` 特性工作流：新增 requirement-analyst 作为第一阶段（Phase 1），添加 Gate 1 需求确认检查点，更新 `rules/agent-routing.md` 路由优先级。
- 修复所有命令（`/analyze`、`/spec`、`/implement`、`/review`、`/sync`）：新增 `完成后必须输出` 强制下一步推荐输出块，确保工作流步骤完成后始终显示可操作的下一步提示。
- 文档全量中文化：将 `AGENTS.md`、`CHANGELOG.md`、`README.md`、架构文档、规格文档、迁移指南、规则、模板等全部翻译为中文。
- 新增 Obsidian 初始配置文件（`app.json`、`appearance.json`、`core-plugins.json`、`workspace.json`）。

## 1.1.0 - 2026-02-25

- 新增 TaskGraph 协议以支持多智能体编排：
  - `docs/architecture/task-graph-protocol.md`
  - 在 `orchestrate`、`learn-project`、`analyze`、`implement`、`review` 命令中增加 TaskGraph 协议段
  - `rules/agent-routing.md` 中增加 TaskGraph 调度规则
  - verify-setup 增加对协议文档与 observe.sh 能力的探针
- 新增重构文档：
  - `docs/architecture/plugin-contract.md`
  - `docs/specs/features/installer-redesign.md`
  - `docs/specs/features/hooks-layering.md`
  - `docs/specs/features/verify-redesign.md`
  - `docs/migration/legacy-to-marketplace.md`
- 重写 `scripts/install.sh` 至 v4.0：
  - 根目录组件映射（`agents/`、`skills/`、`commands/`、`rules/`、`hooks/`、`templates/`）
  - 模式感知安装（默认 `core`，可选 `--enable-learning`）
  - `--dry-run`、`--verify-after` 及 verify 转发
  - 分层 hooks 组合写入 `.cursor/hooks.json`
- 重写 `scripts/verify-setup.sh` 至 v4.0：
  - `--mode core|learning`
  - 分组检查（Contract / Install / Hooks / Learning）
  - ERROR/WARN/INFO 级别输出及严格模式支持
  - observe 能力探针（`stdin` + `input_raw`）
- 引入分层 hooks 文件：
  - `hooks/hooks.core.json`
  - `hooks/hooks.compat.json`
  - `hooks/hooks.learning.json`
- 升级 `skills/continuous-learning/hooks/observe.sh`：
  - 优先使用 stdin JSON，其次环境变量回退
  - 通过 `jq` 安全记录 JSON
  - 当原始输入非 JSON 时使用 `input_raw` 回退字段
- 更新 `README.md`、`AGENTS.md`、`hooks/README.md` 以反映新行为。

## 1.0.2 - 2026-02-24

- 将 `hooks/hooks.json` 迁移至新版 Cursor Hooks  schema（`version` + `hooks`）。
- 更新 hook 事件名为 `preToolUse`、`postToolUse`、`beforeSubmitPrompt`、`stop`。
- 重写 `hooks/README.md` 以匹配最新 Cursor hooks 文档与故障排查流程。
- 更新插件元数据版本至 `1.0.2`。

## 1.0.1 - 2026-02-24

- 改进 README，增加面向 Marketplace 的安装与快速开始章节。
- 新增 `docs/marketplace-submission.md`，包含双语提交文案。
- 更新插件元数据版本至 `1.0.1`。

## 1.0.0 - 2026-02-24

- 将仓库转换为单插件 Marketplace 就绪布局。
- 为 `ecc-workflow` 新增 `.cursor-plugin/plugin.json`。
- 在 `assets/logo.png` 添加 Marketplace 图标，并在 `plugin.json` 中配置 `logo` 字段。
- 将 `.cursor` 组件迁移至 `rules/`、`skills/`、`agents/`、`commands/`、`hooks/`。
- 为提交兼容性补充缺失的 command/rule frontmatter。
- 刷新根目录 README 并包含插件分发元数据。
