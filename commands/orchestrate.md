---
name: orchestrate
description: 编排完整的开发流程。
---

# /orchestrate 命令

编排完整的开发流程。

## 用法

```bash
/orchestrate [workflow] [描述]
```

## 工作流类型

### feature — 新功能开发

```bash
/orchestrate feature "用户登录功能"
```

流程：
```
requirement-analyst → [Gate 1] → planner → spec-writer → [Gate 4: Human Review] → strict-coder → code-reviewer → security-reviewer → librarian
```

> **⚠️ 重要**：`requirement-analyst` 阶段**必须**进行多轮需求澄清（结构化追问），
> 确保需求清晰后才能进入后续阶段。禁止跳过此阶段直接开始规划。

### bugfix — Bug 修复

```bash
/orchestrate bugfix "登录页面白屏"
```

流程：
```
bug-hunter → tdd-guide → code-reviewer → librarian
```

### refactor — 重构

```bash
/orchestrate refactor "支付模块解耦"
```

流程：
```
architect → planner → strict-coder → code-reviewer → librarian
```

### security — 安全审查

```bash
/orchestrate security "认证模块"
```

流程：
```
security-reviewer → code-reviewer → architect
```

### custom — 自定义流程

```bash
/orchestrate custom "architect,tdd-guide,code-reviewer" "重新设计缓存层"
```

## 执行模式

### 顺序执行（默认）

每个 Agent 完成后，将输出交接给下一个 Agent。

#### feature 工作流详细步骤

**Step 1: requirement-analyst（需求澄清）**
- 使用 `@requirement-analyst` 进行**多轮结构化追问**
- **必须**覆盖：用户场景、功能范围、验收标准、约束依赖、优先级
- 每轮最多 5 个问题，追问 → 回答 → 追问 → … → 确认
- 追问清单完成度 >=80% 才能通过
- 输出：`docs/requirements/YYYY-MM-DD-<name>.md`
- **暂停**等待用户确认（Gate 1）

**Step 2: planner（任务规划）**
- Gate 1 通过后，使用 `@planner` 分析需求文档
- 拆解任务、识别依赖、评估风险
- 输出：`docs/plans/YYYY-MM-DD-<name>.md`

**Step 3: spec-writer（规格撰写）**
- 使用 `@spec-writer` 生成技术规格
- 输出：`docs/specs/features/<name>.md`
- **暂停**等待用户确认（Gate 4）

**Step 4-6: 实现 → 审查 → 同步**
- `@strict-coder` 严格按 Spec 实现
- `@code-reviewer` + `@security-reviewer` 审查
- `@librarian` 同步文档

#### 交接模板

```markdown
## HANDOFF: planner → spec-writer

### 上下文
[规划摘要]

### 关键决策
[架构决策]

### 待处理
[需要 spec-writer 完成的内容]
```

### 并行执行

独立的审查可以并行运行：

```bash
/orchestrate feature "用户功能" --parallel-review
```

```
strict-coder
     │
     ├──▶ code-reviewer (并行)
     │
     ├──▶ security-reviewer (并行)
     │
     └──▶ 合并结果
```

### TaskGraph 协议（推荐）

`/orchestrate` 应优先按 TaskGraph 解释执行，而不是仅依赖自然语言箭头链。

```yaml
workflow_id: wf-feature-user-login
goal: "实现用户登录功能"
tasks:
  - id: T1
    name: planning
    owner: planner
    depends_on: []
    parallelizable: false
  - id: T2
    name: spec_writing
    owner: spec-writer
    depends_on: [T1]
    parallelizable: false
  - id: T3
    name: implementation
    owner: strict-coder
    depends_on: [T2]
    parallelizable: false
  - id: T4
    name: quality_review
    owner: code-reviewer
    depends_on: [T3]
    parallelizable: true
  - id: T5
    name: security_review
    owner: security-reviewer
    depends_on: [T3]
    parallelizable: true
  - id: T6
    name: doc_sync
    owner: librarian
    depends_on: [T4, T5]
    parallelizable: false
checkpoints:
  - id: C1
    after_tasks: [T2]
    type: human_review
merge:
  after: [T4, T5]
  strategy: all_must_pass
```

执行规则：

- 仅当 `depends_on` 全部完成后，任务可进入运行态
- 仅 `parallelizable=true` 的任务可并行
- 审查并行分支必须经过统一合并策略再进入下游任务

## 检查点

### 人工介入点

在关键节点暂停，等待人工确认：

```
requirement-analyst ──▶ [CHECKPOINT: Gate 1 需求确认] ──▶ planner ──▶ spec-writer ──▶ [CHECKPOINT: Gate 4 Spec审查] ──▶ strict-coder
```

#### Gate 1 — 需求确认

```markdown
⏸️ **检查点: 需求澄清完成**

需求文档已生成: docs/requirements/YYYY-MM-DD-xxx.md

请审查并确认：
1. 追问清单已完成 (>=80%)
2. 核心功能、边界、验收标准已明确
3. 确认后将 status 改为 approved
4. 回复 "继续" 进入规划阶段，或 "补充 [内容]"
```

#### Gate 4 — Spec 审查

```markdown
⏸️ **检查点: Spec 审查**

Spec 已生成: docs/specs/features/user-login.md

请审查并确认：
1. 打开 Obsidian 查看文档
2. 确认后将 status 改为 approved
3. 回复 "继续" 或 "修改 [内容]"
```

## 输出报告

```markdown
# 编排报告

## 📊 概览

**工作流:** feature
**任务:** 用户登录功能
**Agent 链:** requirement-analyst → planner → spec-writer → strict-coder → code-reviewer → librarian
**总耗时:** 55 分钟

## 📝 各阶段输出

### Requirement Analyst (10 min)
- 进行 3 轮需求澄清
- 追问清单完成度: 90%
- 输出: docs/requirements/2026-02-02-login.md

### Planner (5 min)
- 拆解为 8 个子任务
- 识别 3 个风险点
- 输出: docs/plans/2026-02-02-login.md

### Spec Writer (10 min)
- 定义 2 个 Interface
- 定义 3 个 API 端点
- 输出: docs/specs/features/user-login.md

### Strict Coder (20 min)
- 实现 5 个文件
- 添加 12 个测试
- 测试通过率: 100%

### Code Reviewer (5 min)
- 发现 2 个 MEDIUM 问题
- 状态: ✅ APPROVED

### Librarian (5 min)
- 更新 Spec 变更日志
- 更新 Codemap

## 📁 变更文件

### 新增
- src/types/user.ts
- src/api/auth.ts
- src/components/LoginForm.vue

### 修改
- src/api/index.ts
- docs/CODEMAPS/overview.md

## ✅ 完成状态

- [x] 需求澄清完成 (Gate 1 通过)
- [x] 规划完成
- [x] Spec 已批准 (Gate 4 通过)
- [x] 代码实现
- [x] 审查通过
- [x] 文档同步

**建议:** 可以提交 PR
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--parallel-review` | 并行审查 | false |
| `--skip-security` | 跳过安全审查 | false |
| `--auto-approve` | 自动批准检查点 | false |
| `--output` | 输出报告路径 | - |
| `--task-graph` | 输出本次执行的 TaskGraph | false |

## 常用场景

### 快速功能开发

```bash
# 跳过安全审查，适合内部工具
/orchestrate feature "管理后台" --skip-security
```

### 安全敏感功能

```bash
# 强化安全审查
/orchestrate feature "支付功能"
# 自动包含 security-reviewer
```

### 紧急修复

```bash
# 最小流程
/orchestrate custom "bug-hunter,strict-coder,code-reviewer" "紧急修复 #123"
```

## 下一步

编排完成后：
1. 查看编排报告
2. 在 Obsidian 中确认文档更新
3. 创建 PR 或直接提交

## 相关命令

- `/spec` - 单独生成 Spec
- `/implement` - 单独实现
- `/review` - 单独审查
- `/sync` - 单独同步
