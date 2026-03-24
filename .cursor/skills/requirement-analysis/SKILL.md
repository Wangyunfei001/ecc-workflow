---
name: requirement-analysis
description: 需求分析工作流（Phase 1）。通过结构化追问确保需求清晰、边界明确。
version: 1.0.0
globs: ["docs/requirements/**/*.md"]
apply_when: |
  - 用户请求分析需求
  - 新功能开发启动
  - /analyze 命令触发
  - @requirement-analyst 调用
priority: 30
requires: []
outputs: ["docs/requirements/YYYY-MM-DD-*.md"]
---

# 需求分析 (Phase 1)

## 目标

确保充分理解需求，消除歧义。这是工作流的**第一道门禁**。

## 触发方式

```bash
"/analyze [需求描述]"
"@requirement-analyst 我需要开发 [功能描述]"
```

## 追问清单（必须完成）

| 类别 | 问题 |
|------|------|
| 用户 | 目标用户是谁？ |
| 功能 | 核心功能是什么？ |
| 验收 | 怎样算"完成"？ |
| 边界 | 明确不做什么？ |
| 约束 | 有哪些约束？ |

## 输出

- **位置**: `docs/requirements/YYYY-MM-DD-<name>.md`
- **状态**: `status: clarified` → 审查后改为 `status: approved`

## Gate 1 检查

1. 打开需求文档
2. 确认追问清单已完成（>=80%）
3. 将 `status` 改为 `approved`

## 下一阶段

通过 Gate 1 后 → `@planner` 进行任务规划

## 相关资源

- [需求模板](../../templates/requirement-template.md)
- [requirement-analyst Agent](../../agents/requirement-analyst.md)
