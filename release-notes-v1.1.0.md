# ECC Workflow v1.1.0

## TaskGraph 协议与插件重构 (2026-02-25)

### TaskGraph 多智能体编排
- 新增 `docs/architecture/task-graph-protocol.md` 协议文档
- 在 `orchestrate`、`learn-project`、`analyze`、`implement`、`review` 命令中增加 TaskGraph 协议段
- `rules/agent-routing.md` 中增加 TaskGraph 调度规则
- verify-setup 增加对协议文档与 observe.sh 能力的探针

### 插件重构文档与实现
- **文档**：plugin-contract、installer-redesign、hooks-layering、verify-redesign、legacy-to-marketplace
- **install.sh v4.0**：根目录组件映射、core/learning 模式、`--dry-run`/`--verify-after`、分层 hooks 合成
- **verify-setup.sh v4.0**：`--mode core|learning`、分组检查、observe 能力探针
- **分层 hooks**：`hooks.core.json`、`hooks.compat.json`、`hooks.learning.json`
- **observe.sh**：stdin JSON 优先、环境变量回退、`input_raw` 保留非 JSON 输入

### 文档更新
- README、AGENTS.md、hooks/README.md 已同步新行为与 TaskGraph 说明

详见 [CHANGELOG.md](https://github.com/Wangyunfei001/ecc-workflow/blob/main/CHANGELOG.md).
