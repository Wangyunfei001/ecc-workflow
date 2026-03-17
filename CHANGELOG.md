# 更新日志

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
