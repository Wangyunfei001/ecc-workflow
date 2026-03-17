# ECC Workflow v1.1.2

## Bug 修复与改进 (2026-03-17)

### Bug 修复

- **observe.sh 可执行权限**：修复 `skills/continuous-learning/hooks/observe.sh` 文件权限（`644` → `755`），确保 Cursor hooks 运行时可直接调用，不再需要手动 `chmod +x`。

- **`/orchestrate` 特性工作流补全**：补充遗漏的需求分析阶段——
  - 新增 requirement-analyst 作为第一步（Phase 1）
  - 添加 Gate 1 需求确认检查点，防止未确认需求直接进入规划
  - 更新 `commands/orchestrate.md` 与 `rules/agent-routing.md` 以反映新路由优先级

- **命令强制下一步输出**：为 `/analyze`、`/spec`、`/implement`、`/review`、`/sync` 各命令新增 `完成后必须输出` 章节，包含结构化下一步推荐块，避免工作流步骤完成后缺少明确行动指引。

### 文档

- 项目文档全量中文化：`AGENTS.md`、`CHANGELOG.md`、`README.md`、架构文档、规格文档、迁移指南、规则、模板均已翻译为中文，保留必要英文专业术语。

### 其他

- 新增 Obsidian 初始配置文件（`.obsidian/app.json`、`appearance.json`、`core-plugins.json`、`workspace.json`），支持以 Obsidian 作为项目知识库浏览器。

---

详见 [CHANGELOG.md](https://github.com/Wangyunfei001/ecc-workflow/blob/main/CHANGELOG.md).
