---
name: spec-writing
description: 规格撰写工作流（Phase 4）。输出可直接实现的技术规格文档。
version: 1.0.0
globs: ["docs/specs/**/*.md"]
apply_when: |
  - 架构方案已approved
  - /spec 命令触发
  - @spec-writer 调用
priority: 60
requires: ["architecture-design"]
outputs: ["docs/specs/features/*.md", "docs/specs/apis/*.md"]
---

# 规格撰写 (Phase 4)

## 目标

输出可直接实现的技术规格，作为代码实现的**唯一真理来源**。

## 输入

状态为 `approved` 的架构方案

## 触发方式

```bash
"/spec @docs/architecture/xxx.md"
"@spec-writer @docs/architecture/xxx.md"
```

## Spec 文档结构

```markdown
# 功能名称

## 1. 概述
## 2. 功能需求
## 3. 数据模型（字段类型、约束）
## 4. API 设计（路径、参数、响应、错误码）
## 5. UI/组件设计
## 6. 边界情况
## 7. 安全考虑
## 8. 测试策略
## 9. 验收清单
```

## 输出

- **位置**: `docs/specs/features/[feature-name].md`
- **状态**: `status: draft` → 审查后改为 `status: approved`

## Gate 4 检查

| 检查项 | 标准 |
|--------|------|
| 数据模型 | 字段类型、约束精确 |
| API | 路径、参数、响应完整 |
| 错误处理 | 覆盖所有错误码 |
| 边界情况 | 已考虑 |

## 下一阶段

通过 Gate 4 后 → `/implement` 代码实现

## 相关资源

- [spec-writer Agent](../../agents/spec-writer.md)
- [Spec模板](../../templates/spec-template.md)
