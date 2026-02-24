# ECC Workflow Skill 组合指南

## 概述

ECC Workflow v3.0 采用**模块化架构**，将大型 Skills 拆分为更小、更专注的组件。本文档说明各 Skills 如何组合工作。

## Skills 架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ECC Workflow v3.0 Skills                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Global Skills (Priority 10-20)                                  │    │
│  │  ├── strategic-context (10)     上下文管理、压缩、评估           │    │
│  │  ├── continuous-learning (20)   持续学习概览                      │    │
│  │  │   ├── active-learning        主动学习 /learn-project          │    │
│  │  │   ├── passive-learning       被动学习 Hooks                    │    │
│  │  │   └── instinct-evolution     Instinct演化 /evolve             │    │
│  │  └── eval-integration (15)      评估集成、门禁量化                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Domain Skills (Priority 25-70) - Spec-Driven-Dev                │    │
│  │  ├── spec-driven-dev (25)       编排skill、流程概览              │    │
│  │  │   ├── requirement-analysis (30)   Phase 1 需求分析            │    │
│  │  │   ├── task-planning (40)          Phase 2 任务规划            │    │
│  │  │   ├── architecture-design (50)    Phase 3 架构设计            │    │
│  │  │   ├── spec-writing (60)           Phase 4 规格撰写            │    │
│  │  │   └── code-implementation (60)    Phase 5 代码实现            │    │
│  │  └── doc-sync (70)              文档同步、反向更新                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Skill 优先级说明

| Priority | 类别 | Skills | 说明 |
|----------|------|--------|------|
| 10 | Global | strategic-context | 始终可用，上下文管理 |
| 15 | Global | eval-integration | 门禁评估，贯穿全流程 |
| 20 | Global | continuous-learning, active-learning, passive-learning, instinct-evolution | 学习系统 |
| 25 | Domain | spec-driven-dev | 编排入口 |
| 30 | Domain | requirement-analysis | Phase 1 |
| 40 | Domain | task-planning | Phase 2 |
| 50 | Domain | architecture-design | Phase 3 |
| 60 | Domain | spec-writing, code-implementation | Phase 4-5 |
| 70 | Domain | doc-sync | 闭环同步 |

## Skill 选择决策树

```
用户请求
    │
    ├── 需要理解现有项目？
    │   └── YES → /learn-project (active-learning)
    │
    ├── 开发新功能？
    │   └── YES → spec-driven-dev 流程
    │       ├── /analyze (requirement-analysis) → Gate 1
    │       ├── @planner (task-planning) → Gate 2
    │       ├── @architect (architecture-design) → Gate 3 (可选)
    │       ├── /spec (spec-writing) → Gate 4
    │       └── /implement (code-implementation)
    │
    ├── 修复 Bug？
    │   └── YES → 直接使用 TDD 或 bug-hunter
    │
    ├── 代码变更后需要同步文档？
    │   └── YES → /sync (doc-sync)
    │
    ├── 上下文窗口接近满载？
    │   └── YES → /compact (strategic-context)
    │
    ├── 想查看学习成果？
    │   └── YES → /instinct-status (continuous-learning)
    │
    └── 想演化 Instincts？
        └── YES → /evolve (instinct-evolution)
```

## 常见工作流组合

### 1. 新功能开发（完整流程）

```bash
# 1. 需求分析
/analyze 用户登录功能，支持邮箱和手机号

# 2. 审查需求文档，确认后改为 approved

# 3. 任务规划
@planner @docs/requirements/xxx.md

# 4. 审查实施计划

# 5. 架构设计（复杂功能）
@architect @docs/plans/xxx.md

# 6. 审查架构方案和ADR

# 7. 规格撰写
/spec @docs/architecture/xxx.md

# 8. 审查Spec，确认后改为 approved

# 9. 代码实现
/implement @docs/specs/features/xxx.md

# 10. 代码审查
/review

# 11. 文档同步
/sync
```

**触发的Skills**: requirement-analysis → task-planning → architecture-design → spec-writing → code-implementation → doc-sync

### 2. 简单功能开发（跳过架构）

```bash
/analyze 添加用户头像上传
# → 审查需求
@planner @docs/requirements/xxx.md
# → 审查计划（跳过架构设计）
/spec @docs/plans/xxx.md
# → 审查Spec
/implement @docs/specs/features/xxx.md
/sync
```

**触发的Skills**: requirement-analysis → task-planning → spec-writing → code-implementation → doc-sync

### 3. 新项目快速上手

```bash
# 快速建立项目认知
/learn-project --depth=medium

# 查看学习成果
/instinct-status

# 开始开发（此时AI已了解项目架构）
/analyze 新功能描述
```

**触发的Skills**: active-learning → (正常开发流程)

### 4. 长会话上下文管理

```bash
# 完成Phase 1后
/compact

# 继续Phase 2
@planner ...

# 完成Phase 2后
/compact

# 继续Phase 3
...
```

**触发的Skills**: strategic-context（贯穿全流程）

### 5. 团队协作共享

```bash
# 成员A: 导出学习成果
/instinct-export --min-confidence 0.7

# 成员B: 导入团队知识
/instinct-import team-instincts.json

# 演化为可复用资源
/evolve
```

**触发的Skills**: instinct-evolution

## Skills 依赖关系

```
requirement-analysis
        ↓
task-planning
        ↓
architecture-design (可选)
        ↓
spec-writing
        ↓
code-implementation
        ↓
doc-sync

持续学习系统（并行运行）:
active-learning ──┐
                  ├── instinct-evolution
passive-learning ─┘

上下文管理（贯穿全流程）:
strategic-context

评估集成（贯穿门禁）:
eval-integration
```

## 与 Agent 的对应关系

| Skill | Agent | 命令 |
|-------|-------|------|
| requirement-analysis | @requirement-analyst | /analyze |
| task-planning | @planner | — |
| architecture-design | @architect | — |
| spec-writing | @spec-writer | /spec |
| code-implementation | @strict-coder | /implement |
| doc-sync | @librarian | /sync |
| — | @code-reviewer | /review |
| — | @observer | (后台自动) |

## 文件输出位置

| Skill | 输出位置 |
|-------|----------|
| requirement-analysis | docs/requirements/YYYY-MM-DD-*.md |
| task-planning | docs/plans/YYYY-MM-DD-*.md |
| architecture-design | docs/architecture/*.md, docs/adrs/ADR-*.md |
| spec-writing | docs/specs/features/*.md |
| code-implementation | src/ |
| doc-sync | 更新 docs/ 下相关文档 |
| active-learning | docs/PROJECT_OVERVIEW.md, docs/CODEMAPS/*.md |
| passive-learning | ~/.cursor/homunculus/instincts/personal/*.md |
| instinct-evolution | ~/.cursor/homunculus/evolved/* |

## 最佳实践

1. **始终从需求分析开始** — 即使是简单功能，也要明确需求边界
2. **善用门禁检查** — Gate 是质量保证的关键，不要跳过
3. **定期压缩上下文** — 在阶段切换时使用 /compact
4. **让学习系统工作** — 启用 Hooks 让系统自动学习你的偏好
5. **团队共享 Instincts** — 定期导出高置信度的 Instincts 给团队

## 故障排除

### Q: 不知道该用哪个命令？

A: 参考上方决策树，或直接描述你的需求，AI会自动选择合适的 Skill。

### Q: 门禁检查总是失败？

A: 查看 eval-integration Skill 中的具体评估标准，确保文档满足量化指标。

### Q: 学习系统没有生成 Instincts？

A: 检查 Hooks 是否正确配置（运行 `./scripts/install.sh --verify`），并确保有足够的开发活动。
