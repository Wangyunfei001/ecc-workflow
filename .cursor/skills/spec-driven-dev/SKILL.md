---
name: spec-driven-dev
description: 规格驱动开发工作流。5阶段门禁模式的编排skill，协调各Phase skills完成从需求到代码的完整流水线。
version: 3.0.0
globs: []
apply_when: |
  - 新功能开发
  - 复杂的业务逻辑实现
  - 涉及多人协作的任务
  - 需要文档化的功能
priority: 25
requires: []
outputs: []
---

# 规格驱动开发 (Spec-Driven Development) v3.0

## 概述

**核心原则**：在写任何代码之前，先把需求理解清楚，把设计想明白。

```
┌────────────────────────────────────────────────────────────────────┐
│                  Spec-Driven Development v3.0                       │
│                       （5 阶段门禁模式）                              │
├────────────────────────────────────────────────────────────────────┤
│  Phase 1: 需求分析 ──▶ 🚧 Gate 1                                    │
│  Phase 2: 任务规划 ──▶ 🚧 Gate 2                                    │
│  Phase 3: 架构设计 ──▶ 🚧 Gate 3 (可选)                             │
│  Phase 4: 规格撰写 ──▶ 🚧 Gate 4                                    │
│  Phase 5: 代码实现 ──▶ ✅ 闭环完成                                   │
└────────────────────────────────────────────────────────────────────┘
```

## 门禁检查点

| Gate | 检查内容 | 通过标志 | 详细Skill |
|------|----------|----------|-----------|
| Gate 1 | 需求完整、边界清晰 | `status: approved` | [requirement-analysis](../requirement-analysis/SKILL.md) |
| Gate 2 | 任务合理、风险可控 | `status: approved` | [task-planning](../task-planning/SKILL.md) |
| Gate 3 | 架构合理、技术可行 | `status: approved` | [architecture-design](../architecture-design/SKILL.md) |
| Gate 4 | 规格精确、可实现 | `status: approved` | [spec-writing](../spec-writing/SKILL.md) |

## 快速命令

| 阶段 | 命令 | Agent |
|------|------|-------|
| 需求分析 | `/analyze` | @requirement-analyst |
| 任务规划 | — | @planner |
| 架构设计 | — | @architect |
| 规格撰写 | `/spec` | @spec-writer |
| 代码实现 | `/implement` | @strict-coder |
| 代码审查 | `/review` | @code-reviewer |
| 文档同步 | `/sync` | @librarian |

## 何时跳过阶段

| 场景 | 可跳过 | 不可跳过 |
|------|--------|----------|
| 简单功能 | Phase 3 | Gate 1, Gate 4, Phase 5 |
| 紧急修复 | 简化 Phase 1 | Gate 4, Phase 5 |
| Bug 修复 | 使用 TDD 替代 | — |

## 相关资源

- [需求模板](../../templates/requirement-template.md)
- [Spec模板](../../templates/spec-template.md)
- [ADR模板](../../templates/adr-template.md)
