---
description: Agent 路由规则
alwaysApply: false
---

# Agent 路由规则

定义何时自动激活哪个 Agent。

## 路由表

### 自动路由

| 触发条件 | 激活 Agent | 优先级 |
|----------|------------|--------|
| 新功能需求（未经澄清） | `requirement-analyst` | 最高 |
| 请求开发新功能（需求已批准） | `planner` | 高 |
| 需要写技术规格 | `spec-writer` | 高 |
| Spec 已批准，需要实现 | `strict-coder` | 高 |
| 代码刚写完/修改 | `code-reviewer` | 高 |
| 涉及认证/支付/用户数据 | `security-reviewer` | 高 |
| 需要修复 Bug | `bug-hunter` | 高 |
| 需要写测试 | `tdd-guide` | 中 |
| 架构设计/技术选型 | `architect` | 中 |
| 代码变更后同步文档 | `librarian` | 低 |

### 关键词触发

```yaml
requirement-analyst:
  keywords:
    - "需求分析"
    - "需求澄清"
    - "分析需求"
  patterns:
    - "我想做一个..."
    - "帮我实现..."
    - "我需要..."
    - "开发一个..."
  note: "当需求未经澄清时，优先触发 requirement-analyst 而非 planner"

planner:
  keywords:
    - "开发功能"
    - "新功能"
    - "实现需求"
    - "功能规划"
  patterns:
    - "基于需求文档规划..."
    - "帮我拆解任务..."

spec-writer:
  keywords:
    - "写 Spec"
    - "技术规格"
    - "文档"
    - "定义接口"
  patterns:
    - "设计一下..."
    - "帮我写规格..."

strict-coder:
  keywords:
    - "实现"
    - "编码"
    - "基于 Spec"
  patterns:
    - "基于 @docs/specs/... 实现"
    - "/implement"

code-reviewer:
  keywords:
    - "审查"
    - "review"
    - "检查代码"
  patterns:
    - "/review"
    - "帮我看看代码"

security-reviewer:
  keywords:
    - "安全"
    - "漏洞"
    - "认证"
    - "权限"
  file_patterns:
    - "*/auth/*"
    - "*/payment/*"
    - "*/admin/*"

bug-hunter:
  keywords:
    - "bug"
    - "报错"
    - "异常"
    - "不工作"
  patterns:
    - "TypeError:"
    - "Error:"
    - "帮我看看为什么..."

architect:
  keywords:
    - "架构"
    - "设计"
    - "技术选型"
    - "重构"
  patterns:
    - "应该怎么设计..."
    - "有什么好的架构..."

librarian:
  keywords:
    - "同步文档"
    - "更新文档"
    - "文档不一致"
  patterns:
    - "/sync"
    - "更新一下文档"
```

## 组合路由

### 功能开发流程

```
用户: "我要开发用户登录功能"
     │
     ▼
[requirement-analyst] 需求澄清（多轮追问）
     │
     ▼
Gate 1 (需求确认)
     │
     ▼ (approved)
[planner] 任务规划
     │
     ▼
[spec-writer] 撰写 Spec
     │
     ▼
Gate 4 / Human Review (检查点)
     │
     ▼ (approved)
[strict-coder] 实现代码
     │
     ├──▶ [security-reviewer] (自动，因为涉及认证)
     │
     ▼
[code-reviewer] 审查代码
     │
     ▼
[librarian] 同步文档
```

### Bug 修复流程

```
用户: "登录页面报错 TypeError"
     │
     ▼
[bug-hunter] 定位问题
     │
     ▼
[tdd-guide] 写回归测试
     │
     ▼
[strict-coder] 修复代码
     │
     ▼
[code-reviewer] 审查修复
```

### 重构流程

```
用户: "支付模块需要重构"
     │
     ▼
[architect] 设计新架构
     │
     ▼
[planner] 制定重构计划
     │
     ▼
[strict-coder] 分步重构
     │
     ├──▶ [security-reviewer] (自动，因为涉及支付)
     │
     ▼
[code-reviewer] 审查变更
     │
     ▼
[librarian] 更新文档
```

## 并行执行

### 独立审查并行

当触发代码审查时，可以并行执行：

```
code-reviewer ───┬───▶ 质量审查
                 │
security-reviewer ───▶ 安全审查
                 │
                 ▼
            合并结果
```

### 配置并行

```yaml
parallel_review:
  enabled: true
  agents:
    - code-reviewer
    - security-reviewer
  merge_strategy: "all_must_pass"
```

## 优先级冲突

当多个 Agent 同时匹配时：

1. **安全 > 功能** — 涉及安全的任务优先触发 `security-reviewer`
2. **具体 > 通用** — 明确的 `/command` 优先于关键词匹配
3. **主动 > 被动** — 用户明确指定的 Agent 优先

### 示例

```
用户: "实现用户密码重置功能"

匹配:
- requirement-analyst (模式: "实现...功能"，需求未澄清)
- planner (关键词: 功能)
- spec-writer (关键词: 功能)
- security-reviewer (关键词: 密码)

执行顺序:
1. requirement-analyst (先澄清需求，多轮追问)
2. planner (需求 approved 后规划)
3. spec-writer (再写 Spec)
4. strict-coder (实现时)
5. security-reviewer (审查时，因为涉及密码)
```

## 手动覆盖

### 指定 Agent

```bash
# 明确指定 Agent
@architect 帮我设计缓存方案

# 跳过自动路由
@strict-coder --skip-review 快速修复一下
```

### 禁用自动路由

```bash
# 临时禁用
/config auto-routing off

# 单次禁用
"不要自动审查，直接帮我写代码"
```

## 监控与调优

### 路由日志

```markdown
## 路由记录

| 时间 | 输入 | 匹配规则 | 激活 Agent |
|------|------|----------|------------|
| 15:30 | "开发登录功能" | keyword: 开发功能 | planner |
| 15:35 | "/implement @spec" | command: /implement | strict-coder |
| 15:40 | (代码变更) | auto: after-code | code-reviewer |
```

### 路由统计

```markdown
## 本周路由统计

| Agent | 激活次数 | 来源 |
|-------|----------|------|
| planner | 12 | 关键词: 8, 命令: 4 |
| strict-coder | 25 | 命令: 20, 自动: 5 |
| code-reviewer | 30 | 自动: 28, 手动: 2 |
```

## 自定义路由

### 添加项目特定规则

```yaml
# .cursor/rules/custom-routing.yaml
custom_routes:
  - name: "API 变更触发文档检查"
    trigger:
      file_pattern: "src/api/**/*.ts"
      change_type: "modify"
    actions:
      - agent: librarian
        priority: high
        
  - name: "数据库迁移需要 DBA 审查"
    trigger:
      file_pattern: "migrations/**/*.sql"
    actions:
      - agent: database-reviewer
        priority: critical
```

---

## ECC Agent 路由（扩展）

以下 Agent 来自 Everything Claude Code，可直接使用。本工作流不重复定义，以避免冲突。

### ECC Agent 路由表

| 触发条件 | ECC Agent | 说明 |
|----------|-----------|------|
| Go 代码变更 | `go-reviewer` | **Go 项目必须使用** |
| Python 代码变更 | `python-reviewer` | **Python 项目必须使用** |
| 数据库操作/SQL | `database-reviewer` | PostgreSQL 专家 |
| E2E 测试需求 | `e2e-runner` | Playwright 端到端测试 |
| 代码清理/重构 | `refactor-cleaner` | 死代码清理 |
| 文档/Codemap 更新 | `doc-updater` | 运行 /update-codemaps |
| Go 构建失败 | `go-build-resolver` | Go 构建错误修复 |

### ECC Agent 关键词触发

```yaml
# ECC Agents - 直接使用，不在本工作流重复定义
go-reviewer:
  keywords:
    - "Go 代码"
    - "Go 审查"
    - "golang"
  file_patterns:
    - "*.go"
  note: "Go 项目必须使用此 Agent 进行代码审查"

python-reviewer:
  keywords:
    - "Python 代码"
    - "Python 审查"
    - "PEP 8"
  file_patterns:
    - "*.py"
  note: "Python 项目必须使用此 Agent 进行代码审查"

database-reviewer:
  keywords:
    - "SQL"
    - "数据库"
    - "查询优化"
    - "索引"
    - "迁移"
  file_patterns:
    - "*.sql"
    - "migrations/**/*"
  note: "PostgreSQL 专家，Supabase 最佳实践"

e2e-runner:
  keywords:
    - "E2E 测试"
    - "端到端"
    - "Playwright"
    - "用户流程测试"
  note: "生成、维护、运行 E2E 测试"

refactor-cleaner:
  keywords:
    - "死代码"
    - "清理代码"
    - "未使用"
    - "重复代码"
  note: "运行 knip/depcheck/ts-prune 分析"

doc-updater:
  keywords:
    - "更新 Codemap"
    - "生成文档"
    - "README 更新"
  commands:
    - "/update-codemaps"
    - "/update-docs"
  note: "生成 docs/CODEMAPS/*"

go-build-resolver:
  keywords:
    - "Go 构建失败"
    - "go build error"
    - "go vet"
  note: "修复 Go 构建、vet、linter 问题"
```

### 语言特定审查路由

根据文件类型自动路由到对应的语言审查 Agent：

```
代码变更
    │
    ├── *.go ──────────▶ [go-reviewer] (ECC)
    │                         │
    │                         ▼
    │                    [code-reviewer] (本工作流，通用质量)
    │
    ├── *.py ──────────▶ [python-reviewer] (ECC)
    │                         │
    │                         ▼
    │                    [code-reviewer] (本工作流，通用质量)
    │
    ├── *.ts/*.vue ────▶ [code-reviewer] (本工作流)
    │
    └── *.sql ─────────▶ [database-reviewer] (ECC)
```

### ECC + 本工作流组合流程

#### Go 项目完整流程

```
需求 ──▶ [requirement-analyst] ──▶ Gate 1 ──▶ [planner] ──▶ [spec-writer] ──▶ Gate 4 / Human Review
                                              │
                                              ▼ (approved)
                                        [strict-coder]
                                              │
    ┌─────────────────────────────────────────┼─────────────────────────────────┐
    │                                         │                                 │
    ▼                                         ▼                                 ▼
[go-reviewer]                          [code-reviewer]                 [security-reviewer]
   (ECC)                                 (本工作流)                       (共享)
    │                                         │                                 │
    └─────────────────────────────────────────┼─────────────────────────────────┘
                                              │
                                              ▼
                                        [librarian]
```

#### 数据库相关流程

```
SQL 变更 ──▶ [database-reviewer] (ECC) ──▶ 审查通过 ──▶ [librarian]
                     │
                     ▼
              优化建议/安全检查
```

## 相关资源

- [Agent 列表](../agents/)
- [命令列表](../commands/)
- [Orchestrate 命令](../commands/orchestrate.md)
- [ECC 使用指南](https://github.com/affaan-m/everything-claude-code)
