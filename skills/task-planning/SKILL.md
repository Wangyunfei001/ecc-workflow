---
name: task-planning
description: 任务规划工作流（Phase 2）。将需求拆解为可执行的任务列表。
version: 1.0.0
globs: ["docs/plans/**/*.md"]
apply_when: |
  - 需求文档已approved
  - @planner 调用
  - 需要任务拆解
priority: 40
requires: ["requirement-analysis"]
outputs: ["docs/plans/YYYY-MM-DD-*.md"]
---

# 任务规划 (Phase 2)

## 目标

将需求拆解为可执行的任务，识别依赖和风险。

## 输入

状态为 `approved` 的需求文档

## 触发方式

```bash
"@planner @docs/requirements/xxx.md"
```

## 输出

- **位置**: `docs/plans/YYYY-MM-DD-<name>.md`
- **内容**: 任务列表、依赖关系、风险识别

## Gate 2 检查

| 检查项 | 标准 |
|--------|------|
| 任务粒度 | 每个 2-5 分钟 |
| 依赖关系 | 明确标注 |
| 风险识别 | 已列出并有缓解措施 |

通过后将 `status` 改为 `approved`

## 下一阶段

通过 Gate 2 后 → `@architect` 进行架构设计（复杂功能）或直接 `/spec`（简单功能）

## 相关资源

- [planner Agent](../../agents/planner.md)
