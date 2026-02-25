---
name: analyze
description: 需求分析入口。工作流的第一步，确保在开发前充分理解需求。
---

# /analyze 命令

需求分析入口。工作流的第一步，确保在开发前充分理解需求。

## 用法

```bash
/analyze [需求描述]
/analyze @[需求文件]
```

## 示例

```bash
# 直接描述需求
/analyze 我想做一个用户登录功能

# 基于已有文档
/analyze @docs/prd/login.md

# 指定输出位置
/analyze 用户注册 --output docs/requirements/user-register.md
```

## 执行流程

```
┌─────────────────────────────────────────────────────────────┐
│                     /analyze 执行流程                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 初步理解                                                 │
│     └── 总结需求，确认大方向                                  │
│                                                             │
│  2. 结构化追问（核心环节）                                    │
│     ├── 用户与场景                                           │
│     ├── 功能范围                                             │
│     ├── 验收标准                                             │
│     ├── 约束与依赖                                           │
│     └── 优先级与风险                                         │
│                                                             │
│  3. 迭代确认                                                 │
│     └── 追问 → 回答 → 追问 → ... → 全部确认                   │
│                                                             │
│  4. 输出需求文档                                             │
│     └── docs/requirements/YYYY-MM-DD-<name>.md               │
│                                                             │
│  5. Gate 1 检查                                              │
│     └── 用户审查 → status: approved                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## TaskGraph 协议（推荐）

`/analyze` 的核心是“先收敛目标，再并行澄清关键问题，再统一确认”。

```yaml
workflow_id: wf-analyze-requirement
goal: "形成可实现、可验收的需求文档"
tasks:
  - id: T1
    name: initial_understanding
    owner: requirement-analyst
    depends_on: []
    parallelizable: false
  - id: T2A
    name: clarify_users_and_scenarios
    owner: requirement-analyst
    depends_on: [T1]
    parallelizable: true
  - id: T2B
    name: clarify_scope
    owner: requirement-analyst
    depends_on: [T1]
    parallelizable: true
  - id: T2C
    name: clarify_acceptance
    owner: requirement-analyst
    depends_on: [T1]
    parallelizable: true
  - id: T2D
    name: clarify_constraints
    owner: requirement-analyst
    depends_on: [T1]
    parallelizable: true
  - id: T2E
    name: clarify_priority_and_risk
    owner: requirement-analyst
    depends_on: [T1]
    parallelizable: true
  - id: T3
    name: iterative_confirmation
    owner: requirement-analyst
    depends_on: [T2A, T2B, T2C, T2D, T2E]
    parallelizable: false
  - id: T4
    name: write_requirement_doc
    owner: requirement-analyst
    depends_on: [T3]
    parallelizable: false
checkpoints:
  - id: C1
    after_tasks: [T4]
    type: human_review
merge:
  after: [T2A, T2B, T2C, T2D, T2E]
  strategy: all_must_pass
```

## 追问清单

命令执行时会检查以下信息是否完整：

### 必须确认（缺失则追问）

- [ ] 目标用户是谁？
- [ ] 核心功能是什么？
- [ ] 怎样算"完成"？
- [ ] 明确不做什么？

### 应该确认（建议追问）

- [ ] 用户当前如何解决这个问题？
- [ ] 有哪些技术约束？
- [ ] 成功的衡量指标？
- [ ] 功能优先级排序？

### 可选确认（视情况追问）

- [ ] 非功能需求（性能、安全等）
- [ ] 时间/预算限制
- [ ] 后续扩展计划

## 输出格式

```markdown
---
title: [功能名称]
status: clarified
created: YYYY-MM-DD
analyst: requirement-analyst
---

# [功能名称] 需求文档

## 1. 概述
## 2. 用户场景
## 3. 功能需求（P0/P1/P2）
## 4. 非功能需求
## 5. 范围边界
## 6. 约束与依赖
## 7. 风险与缓解
## 8. 验收清单
## 9. 决策记录
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--output` | 指定输出路径 | `docs/requirements/<name>.md` |
| `--quick` | 快速模式，减少追问 | false |
| `--template` | 使用自定义模板 | 标准模板 |

## 与工作流的关系

```
/analyze ──▶ 需求文档 (approved)
                │
                ▼
        @planner ──▶ 实施计划 (approved)
                         │
                         ▼
                 @architect ──▶ 技术方案 + ADR (approved)
                                    │
                                    ▼
                            @spec-writer ──▶ Spec (approved)
                                                │
                                                ▼
                                        /implement ──▶ 代码
```

## Gate 1 检查清单

需求文档完成后，人工审查以下内容：

- [ ] 用户场景清晰、完整
- [ ] 功能需求有明确验收标准
- [ ] "不做什么"已明确记录
- [ ] 约束和依赖已识别
- [ ] 风险已评估

审查通过后：
1. 将 `status: clarified` 改为 `status: approved`
2. 执行 `@planner @docs/requirements/xxx.md`

## 常见问题

### Q: 用户不愿意回答太多问题？

A: 使用 `--quick` 模式，只问最关键的 4 个问题。但要提醒用户：跳过的问题可能导致后续返工。

### Q: 需求太模糊无法追问？

A: 先确认大方向，建议用户：
1. 提供参考产品/竞品
2. 描述一个典型使用场景
3. 画个简单草图

### Q: 已有 PRD 文档，还需要 /analyze？

A: 需要。PRD 通常是产品视角，/analyze 会从技术实现角度补充追问，确保开发可落地。

## 相关命令

- `@planner` - 基于需求制定实施计划
- `@architect` - 技术架构设计
- `/spec` - 生成技术规格
- `/implement` - 代码实现
