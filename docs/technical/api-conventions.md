# Cursor ECC工作流系统 - API设计规范

## 概述

本文档定义了Cursor ECC工作流系统的API设计规范。虽然本项目主要是文档驱动的配置系统,但理解API设计原则有助于在使用工作流开发实际项目时遵循最佳实践。

## Agent通信"API"

### Agent间通信协议

Agent之间通过**文档文件**通信,可以视为一种文件系统API:

#### 输入规范

每个Agent定义明确的输入文档要求:

**示例: planner Agent的输入**
```markdown
输入: docs/requirements/YYYY-MM-DD-<name>.md
要求: status: approved
验证: 必须包含目标用户、核心功能、验收标准
```

#### 输出规范

每个Agent定义明确的输出文档格式:

**示例: planner Agent的输出**
```markdown
输出: docs/plans/YYYY-MM-DD-<name>.md
格式:
---
title: [功能名称] 实施计划
status: draft
created: YYYY-MM-DD
requirement: docs/requirements/xxx.md
---

# 内容结构
- 概述
- 需求背景
- 技术方案
- 任务分解
- 测试策略
- 风险与缓解
- 验收检查清单
```

### 文档状态流转

文档状态是Agent间协作的关键信号:

```
draft ──▶ review ──▶ approved ──▶ implementing ──▶ implemented
  │         │           │              │               │
  │         │           │              │               ▼
  │         │           │              │          deprecated
  │         ▼           ▼              ▼
  └───▶ rejected    revising      blocked
```

**状态约定**:
- `draft`: 初稿,仍在编辑
- `review`: 提交审查,等待反馈
- `approved`: 已批准,可作为下游输入
- `implementing`: 正在实现
- `implemented`: 已完成实现
- `rejected`: 被拒绝,需重新设计
- `revising`: 修订中
- `blocked`: 被阻塞,等待外部条件
- `deprecated`: 已废弃

## 命令"API"设计

### 命令格式规范

所有命令遵循统一格式:

```bash
/command [OPTIONS] [@references]
```

**组成部分**:
- `/command`: 命令名(小写,连字符分隔)
- `[OPTIONS]`: 可选参数
- `[@references]`: 文件引用

### 核心命令API

#### `/analyze` - 需求分析

**用途**: 触发需求分析阶段(Phase 1)

**语法**:
```bash
/analyze <需求描述>
```

**输入**: 自然语言需求描述

**输出**: `docs/requirements/YYYY-MM-DD-<name>.md`

**示例**:
```bash
/analyze 用户登录功能,支持邮箱和手机号
```

#### `/spec` - 生成规格

**用途**: 触发规格撰写阶段(Phase 4)

**语法**:
```bash
/spec @<architecture-or-plan-doc>
```

**输入**: 
- 架构方案: `@docs/architecture/xxx.md`
- 或实施计划: `@docs/plans/xxx.md`(跳过Phase 3时)

**输出**: `docs/specs/features/xxx.md`

**示例**:
```bash
/spec @docs/architecture/user-login.md
/spec @docs/plans/user-login.md
```

#### `/implement` - 代码实现

**用途**: 触发代码实现阶段(Phase 5)

**语法**:
```bash
/implement @<spec-doc>
```

**输入**: 
- Spec文档: `@docs/specs/features/xxx.md`
- 要求: `status: approved`

**输出**: 代码实现

**约束**:
- 只实现Spec中定义的内容
- 不添加任何额外功能
- 遇到缺失信息立即询问

**示例**:
```bash
/implement @docs/specs/features/user-login.md
```

#### `/learn-project` - 主动学习

**用途**: 主动学习项目代码库

**语法**:
```bash
/learn-project [OPTIONS]
```

**参数**:
- `--depth=<quick|medium|deep>`: 学习深度(默认medium)
- `--focus=<dimensions>`: 只学习特定维度,逗号分隔
- `--update`: 更新已有学习成果
- `--skip-instincts`: 不生成Instincts
- `--output=<dir>`: 指定输出目录(默认docs/)

**输出**:
1. `docs/PROJECT_OVERVIEW.md`
2. `docs/ONBOARDING.md`
3. `docs/CODEMAPS/overview.md`
4. `docs/technical/architecture.md`
5. `docs/technical/api-conventions.md`
6. `.cursor/rules/project-standards.md`
7. `~/.cursor/homunculus/instincts/personal/project-*.md`

**示例**:
```bash
/learn-project --depth=medium
/learn-project --depth=quick --focus=architecture,patterns
/learn-project --update
```

### 命令返回格式

所有命令应返回结构化的执行报告:

```markdown
# <命令名> 执行结果

## 状态
✅ 成功 / ❌ 失败 / ⚠️ 部分成功

## 输出文件
- ✅ docs/xxx.md
- ✅ .cursor/rules/xxx.md

## 执行摘要
[简要说明执行了什么]

## 下一步
[建议的后续操作]

## 耗时
X分Y秒
```

## 文档"API"规范

### 文档Frontmatter规范

所有工作流文档必须包含YAML frontmatter:

```yaml
---
title: 文档标题
status: draft | review | approved | implemented
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: agent-name 或 human
version: x.y.z
tags: [tag1, tag2]
---
```

**必需字段**:
- `title`: 文档标题
- `status`: 文档状态
- `created`: 创建日期

**推荐字段**:
- `updated`: 最后更新日期
- `author`: 作者
- `version`: 版本号

**特定Agent的额外字段**:

**requirement文档**:
```yaml
analyst: requirement-analyst
priority: P0 | P1 | P2
```

**plan文档**:
```yaml
requirement: docs/requirements/xxx.md
```

**architecture文档**:
```yaml
requirement: docs/requirements/xxx.md
plan: docs/plans/xxx.md
```

**spec文档**:
```yaml
architecture: docs/architecture/xxx.md
# 或
plan: docs/plans/xxx.md
category: feature | api | component
```

### 文档内链规范

#### Markdown链接

```markdown
# 相对路径
[需求文档](../requirements/2026-02-03-user-login.md)

# 绝对路径(从项目根)
[需求文档](/docs/requirements/2026-02-03-user-login.md)
```

#### Obsidian Wikilinks(可选)

如果使用Obsidian:

```markdown
# 双括号链接
[[requirements/2026-02-03-user-login]]

# 带显示文本
[[requirements/2026-02-03-user-login|用户登录需求]]

# 跨文件夹
[[2026-02-03-user-login]]  # Obsidian会自动查找
```

### 文档命名规范

#### 时间戳命名(Phase 1-2)

```
docs/requirements/YYYY-MM-DD-<feature-name>.md
docs/plans/YYYY-MM-DD-<feature-name>.md
```

**示例**:
- `docs/requirements/2026-02-03-user-login.md`
- `docs/plans/2026-02-03-user-login.md`

#### 功能命名(Phase 3-4)

```
docs/architecture/<feature-name>.md
docs/specs/features/<feature-name>.md
docs/specs/apis/<api-name>.md
docs/specs/components/<component-name>.md
```

**示例**:
- `docs/architecture/user-login.md`
- `docs/specs/features/user-login.md`
- `docs/specs/apis/auth-api.md`
- `docs/specs/components/login-form.md`

#### ADR编号命名

```
docs/adrs/ADR-<NNN>-<title>.md
```

**示例**:
- `docs/adrs/ADR-001-auth-strategy.md`
- `docs/adrs/ADR-002-database-choice.md`

**编号规则**:
- 3位数字,前导零
- 按创建顺序递增
- 不重用已废弃的编号

## Instinct"API"规范

### Instinct文件格式

```yaml
---
id: unique-id
trigger: "触发条件描述"
confidence: 0.3-0.9
domain: architecture | code-style | api-design | testing | security
source: learn-project | session-observation | manual
created: YYYY-MM-DD
updated: YYYY-MM-DD
observations: 5
---

# Instinct标题

## 行为
[具体应该做什么]

## 证据
- 观察1
- 观察2
- ...

## 示例
```language
// 代码示例
```
```

### Instinct命名规范

```
<domain>-<specific-pattern>.md
```

**示例**:
- `architecture-repository-pattern.md`
- `code-style-prefer-functional.md`
- `api-design-restful-naming.md`
- `testing-always-test-first.md`

### Instinct导出格式

**导出文件**: `instincts-YYYY-MM-DD.json`

**JSON结构**:
```json
{
  "exportDate": "2026-02-03T10:30:00Z",
  "version": "2.0",
  "minConfidence": 0.7,
  "instincts": [
    {
      "id": "prefer-functional-style",
      "trigger": "when writing new functions",
      "confidence": 0.85,
      "domain": "code-style",
      "source": "session-observation",
      "behavior": "使用函数式模式而非类",
      "evidence": ["观察1", "观察2"],
      "examples": ["示例代码"]
    }
  ]
}
```

## 错误处理规范

### Agent错误响应

当Agent遇到错误时,应返回结构化错误信息:

```markdown
❌ **执行失败**

## 错误类型
<error-type>

## 错误描述
[人类可读的错误说明]

## 原因分析
[为什么会发生这个错误]

## 解决建议
1. [建议步骤1]
2. [建议步骤2]

## 相关文档
- [链接到相关文档]
```

### 常见错误类型

| 错误类型 | 说明 | 解决方案 |
|---------|------|---------|
| `MISSING_INPUT` | 缺少必需的输入文档 | 提供缺失的文档路径 |
| `INVALID_STATUS` | 文档状态不符合要求 | 将文档状态改为approved |
| `INCOMPLETE_DOC` | 文档内容不完整 | 补充缺失的章节 |
| `SPEC_AMBIGUOUS` | Spec定义模糊 | 明确模糊的字段定义 |
| `CONFLICT` | 文档间存在冲突 | 解决冲突或说明优先级 |

## 版本控制规范

### 文档版本化

所有项目级文档(docs/)应该:
- 使用Git版本控制
- 每次重大变更创建新commit
- commit message格式:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**type类型**:
- `docs`: 文档变更
- `spec`: Spec变更
- `requirement`: 需求变更
- `architecture`: 架构变更

**示例**:
```bash
git commit -m "spec(user-login): 添加手机号登录支持

- 新增手机号字段定义
- 新增验证码发送API
- 更新错误码列表

Refs: #123"
```

### 文档变更历史

在文档末尾维护变更历史:

```markdown
## 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|---------|------|
| 1.2 | 2026-02-03 | 添加手机号登录 | @developer |
| 1.1 | 2026-02-02 | 添加lastLoginAt字段 | @developer |
| 1.0 | 2026-01-15 | 初始版本 | @product |
```

## 最佳实践

### 1. 文档即契约

将文档视为Agent间的契约:
- 输入要求必须明确
- 输出格式必须一致
- 状态流转必须遵守

### 2. 失败快速原则

遇到问题立即失败并报告:
- 不要尝试猜测缺失信息
- 不要跳过必需的验证
- 不要继续执行不符合前置条件的操作

### 3. 幂等性

多次执行相同命令应产生相同结果:
- `/learn-project --update` 可重复执行
- `/spec @doc` 多次执行生成相同Spec(如果输入未变)

### 4. 可追溯性

所有决策都有文档记录:
- 需求决策 → 需求文档的"决策记录"章节
- 技术决策 → ADR文档
- 实现决策 → Spec文档

## 相关文档

- [项目概览](../PROJECT_OVERVIEW.md)
- [技术架构](./architecture.md)
- [编码规范](../../.cursor/rules/project-standards.md)
- [代码地图](../CODEMAPS/overview.md)

---

**规范版本**: v2.2  
**最后更新**: 2026-02-03
