---
name: architecture-design
description: 架构设计工作流（Phase 3）。确定技术方案，记录架构决策（ADR）。
version: 1.0.0
globs: ["docs/architecture/**/*.md", "docs/adrs/**/*.md"]
apply_when: |
  - 实施计划已approved
  - @architect 调用
  - 需要技术选型或架构决策
priority: 50
requires: ["task-planning"]
outputs: ["docs/architecture/*.md", "docs/adrs/ADR-*.md"]
---

# 架构设计 (Phase 3)

## 目标

确定技术方案，记录架构决策。

## 输入

状态为 `approved` 的实施计划

## 触发方式

```bash
"@architect @docs/plans/xxx.md"
```

## 技术追问清单

| 问题 | 说明 |
|------|------|
| 是否需要新的数据模型？ | 字段设计、关系 |
| 是否需要新的 API？ | 端点、参数、响应 |
| 对现有架构有何影响？ | 兼容性、迁移 |
| 有哪些技术选型需要决策？ | 框架、库、工具 |

## 输出

- **架构方案**: `docs/architecture/<feature>.md`
- **ADR**: `docs/adrs/ADR-xxx.md`

## Gate 3 检查

| 检查项 | 标准 |
|--------|------|
| 架构方案 | 技术可行 |
| ADR | 记录完整（问题、决策、后果） |
| 技术选型 | 已确认 |

通过后将 `status` 改为 `approved`

## 下一阶段

通过 Gate 3 后 → `/spec` 撰写技术规格

## 相关资源

- [architect Agent](../../agents/architect.md)
- [ADR模板](../../templates/adr-template.md)
