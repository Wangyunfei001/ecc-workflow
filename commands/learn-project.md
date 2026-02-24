---
name: learn-project
description: 主动学习项目。深度分析代码库，提取架构、规范、模式，生成项目知识库和初始Instincts。
---

# /learn-project 命令

主动学习项目。深度分析代码库，提取架构、规范、模式，生成项目知识库和初始Instincts。

## 用法

```bash
/learn-project [OPTIONS]
```

## 示例

```bash
# 默认中等深度学习
/learn-project

# 快速学习（5-10分钟）
/learn-project --depth=quick

# 深度学习（1小时+）
/learn-project --depth=deep

# 只学习特定维度
/learn-project --focus=architecture,patterns

# 更新已有学习成果
/learn-project --update
```

## 执行流程

```
┌─────────────────────────────────────────────────────────────┐
│                  /learn-project 执行流程                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 🔍 项目扫描                                              │
│     ├── 识别项目类型（前端/后端/全栈）                        │
│     ├── 检测技术栈                                           │
│     ├── 分析目录结构                                         │
│     └── 读取关键配置文件                                      │
│                                                             │
│  2. 📊 深度分析（根据 --depth）                              │
│     ├── quick:  README + 配置 + 目录结构                    │
│     ├── medium: + 核心模块 + API + 测试                     │
│     └── deep:   + 全量代码 + 业务逻辑 + 领域模型             │
│                                                             │
│  3. 🧠 知识提取（6个维度）                                   │
│     ├── 项目架构和技术栈                                     │
│     ├── 项目结构和文件组织                                   │
│     ├── 编码风格和规范                                       │
│     ├── API设计规范                                          │
│     ├── 业务逻辑和领域知识                                   │
│     └── 测试策略和质量要求                                   │
│                                                             │
│  4. 📝 生成文档（6类产物）                                   │
│     ├── docs/PROJECT_OVERVIEW.md                           │
│     ├── docs/ONBOARDING.md                                 │
│     ├── docs/CODEMAPS/overview.md                          │
│     ├── docs/technical/architecture.md                     │
│     ├── docs/technical/api-conventions.md                  │
│     └── .cursor/rules/project-standards.md                │
│                                                             │
│  5. 💾 生成 Instincts                                       │
│     ├── 架构 Instincts (置信度 0.7)                         │
│     ├── 编码规范 Instincts (置信度 0.6)                     │
│     ├── API设计 Instincts (置信度 0.6)                      │
│     └── 存储到 ~/.cursor/homunculus/instincts/             │
│                                                             │
│  6. ✅ 完成报告                                              │
│     └── 显示学习摘要和生成文件列表                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 学习深度

| 深度 | 时长 | 分析范围 | 生成Instincts |
|------|------|---------|--------------|
| **quick** | 5-10分钟 | 项目结构、主要依赖、README | 3-5个 |
| **medium** | 20-30分钟 | + 核心模块、API设计、测试策略 | 8-12个 |
| **deep** | 1小时+ | + 业务逻辑、领域模型、全量规范 | 15-25个 |

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--depth` | 学习深度 (quick/medium/deep) | medium |
| `--focus` | 只关注特定维度，逗号分隔 | 全部6个维度 |
| `--output` | 指定输出目录 | docs/ |
| `--skip-instincts` | 不生成Instincts | false |
| `--update` | 更新已有学习成果 | false |

## 执行实现

### 使用 Subagent 执行 ⭐ 重要

`/learn-project` 是一个**复杂的多步骤任务**，应该使用 **`explore` subagent** 来执行。

**为什么使用 explore subagent？**
- 需要系统性探索整个代码库
- 需要搜索和分析大量文件
- 需要提取模式和规范
- 任务耗时较长（5-60分钟）

**执行策略：**

```typescript
// 伪代码：AI 看到 /learn-project 命令时的执行逻辑
if (command === '/learn-project') {
  const depth = params.depth || 'medium';
  const focus = params.focus || 'all';
  
  // 使用 explore subagent 执行
  Task({
    subagent_type: 'explore',
    description: `Learn project with ${depth} depth`,
    prompt: `
      Execute /learn-project command with the following requirements:
      
      Depth: ${depth}
      Focus: ${focus}
      
      Tasks:
      1. Scan project structure and detect tech stack
      2. Analyze ${depth === 'deep' ? 'all' : 'core'} modules
      3. Extract knowledge from 6 dimensions:
         - Architecture and tech stack
         - Project structure
         - Code style and conventions
         - API design patterns
         - Business logic and domain knowledge
         - Testing strategy
      4. Generate 6 types of outputs:
         - Project documentation (7 files)
         - Coding standards (.cursor/rules/)
         - Initial Instincts (8-${depth === 'deep' ? 25 : 12})
      5. Generate final report
      
      Thoroughness: ${depth === 'quick' ? 'quick' : depth === 'deep' ? 'very thorough' : 'medium'}
    `
  });
}
```

**实际使用示例：**

当用户输入 `/learn-project --depth=medium` 时，AI 应该：

1. **识别命令并启动 subagent**
   ```
   "我会使用 explore subagent 来深度学习这个项目..."
   ```

2. **调用 Task tool**
   ```typescript
   Task({
     subagent_type: 'explore',
     description: 'Learn project with medium depth',
     prompt: '详细的学习任务...'
   })
   ```

3. **Subagent 执行**
   - 探索代码库（使用 Glob, Grep, Read, SemanticSearch）
   - 分析架构和模式
   - 生成文档
   - 生成 Instincts

4. **返回结果**
   - 显示学习报告
   - 列出生成的文件

---

### 详细执行步骤

以下是 explore subagent 内部应该执行的步骤：

### Phase 1: 项目扫描

```typescript
// 伪代码
async function scanProject() {
  // 1. 识别项目类型
  const projectType = await detectProjectType();
  // 检查: package.json, go.mod, pom.xml, requirements.txt, etc.
  
  // 2. 读取配置文件
  const configs = await readConfigs([
    'package.json',
    'tsconfig.json', 
    '.eslintrc',
    'go.mod',
    'pom.xml',
    'pyproject.toml',
    'Cargo.toml'
  ]);
  
  // 3. 分析目录结构
  const structure = await analyzeDirectoryStructure();
  
  return { projectType, configs, structure };
}
```

**具体操作:**

1. 使用 `LS` 工具列出项目根目录
2. 使用 `Read` 工具读取配置文件
3. 使用 `Glob` 工具查找特定文件类型
4. 使用 `Grep` 工具搜索关键模式

### Phase 2: 深度分析

根据 `--depth` 参数决定分析范围：

**Quick 模式:**
- 读取 README.md
- 读取主配置文件（package.json等）
- 扫描顶层目录结构（仅1层）
- 识别主要框架和依赖

**Medium 模式:**
- Quick 的所有内容
- 使用 `SemanticSearch` 查找核心模块
- 分析 3-5 个关键文件
- 提取 API 路由和端点
- 识别测试文件和框架

**Deep 模式:**
- Medium 的所有内容
- 分析所有主要模块
- 提取领域模型和业务逻辑
- 分析数据流和架构模式
- 识别所有设计模式使用

### Phase 3: 知识提取

```typescript
// 伪代码
async function extractKnowledge(scanResult) {
  const knowledge = {
    architecture: await analyzeArchitecture(),
    structure: await analyzeStructure(),
    codeStyle: await analyzeCodeStyle(),
    apiDesign: await analyzeAPIDesign(),
    business: await analyzeBusinessLogic(),
    testing: await analyzeTestingStrategy()
  };
  
  return knowledge;
}
```

**具体提取内容:**

1. **架构和技术栈**
   - 框架版本
   - 依赖列表
   - 架构模式（MVC、微服务、Monorepo等）
   - 构建工具

2. **项目结构**
   - 目录命名规范
   - 模块划分方式
   - 文件组织逻辑

3. **编码规范**
   - 命名约定（camelCase, snake_case等）
   - 函数 vs 类的使用偏好
   - 注释风格

4. **API设计**
   - RESTful / GraphQL / gRPC
   - 路由命名模式
   - 请求/响应格式

5. **业务逻辑**
   - 核心领域概念
   - 关键业务流程
   - 数据模型

6. **测试策略**
   - 测试框架（Jest, pytest等）
   - 测试组织方式
   - 覆盖率要求

### Phase 4: 生成文档

```typescript
// 伪代码
async function generateDocs(knowledge) {
  await writeFile('docs/PROJECT_OVERVIEW.md', {
    projectInfo: knowledge.basic,
    architecture: knowledge.architecture,
    techStack: knowledge.techStack,
    keyModules: knowledge.keyModules
  });
  
  await writeFile('docs/ONBOARDING.md', {
    gettingStarted: generateGettingStarted(),
    developmentWorkflow: generateWorkflow(),
    commonTasks: generateCommonTasks()
  });
  
  // ... 其他文档
}
```

**文档模板:**

1. **PROJECT_OVERVIEW.md**
```markdown
# 项目概览

## 基本信息
- 项目名称: [name]
- 项目类型: [type]
- 技术栈: [stack]

## 架构
[architecture description]

## 核心模块
[key modules]

## 技术决策
[key technical decisions]
```

2. **ONBOARDING.md**
```markdown
# 新人上手指南

## 快速开始
1. 环境准备
2. 安装依赖
3. 启动开发服务器

## 开发流程
[workflow]

## 常见任务
- 如何添加新功能
- 如何运行测试
- 如何构建部署

## 编码规范
[coding standards]
```

3. **project-standards.md**
```markdown
# 项目编码规范

## 命名规范
[naming conventions]

## 代码组织
[code organization]

## 最佳实践
[best practices]
```

### Phase 5: 生成 Instincts

```typescript
// 伪代码
async function generateInstincts(knowledge) {
  const instincts = [];
  
  // 从架构中提取 Instinct
  if (knowledge.architecture.pattern === 'Repository') {
    instincts.push(createInstinct({
      id: `project-${projectName}-repository-pattern`,
      trigger: 'when creating data access layer',
      confidence: 0.7,
      domain: 'architecture',
      behavior: 'Use Repository pattern',
      evidence: [...],
      examples: [...]
    }));
  }
  
  // 从编码规范中提取 Instinct
  if (knowledge.codeStyle.preferFunctions) {
    instincts.push(createInstinct({
      id: `project-${projectName}-prefer-functions`,
      trigger: 'when writing new code',
      confidence: 0.6,
      domain: 'code-style',
      behavior: 'Prefer functions over classes',
      evidence: [...],
      examples: [...]
    }));
  }
  
  // ... 更多 Instincts
  
  await saveInstincts(instincts);
}
```

**Instinct 生成规则:**

| 发现 | Instinct | 置信度 |
|------|----------|--------|
| 使用特定架构模式（5+处） | 架构 Instinct | 0.7 |
| 一致的命名规范（10+处） | 规范 Instinct | 0.6 |
| 统一的API设计（5+处） | API Instinct | 0.6 |
| 特定测试模式（5+处） | 测试 Instinct | 0.6 |
| 业务领域概念（3+处） | 业务 Instinct | 0.5 |

### Phase 6: 生成报告

```typescript
// 伪代码
function generateReport(result) {
  console.log(`
# 项目学习完成 (${depth} Mode)

## 📋 项目信息
- 名称: ${result.projectName}
- 类型: ${result.projectType}
- 技术栈: ${result.techStack.join(', ')}

## 📄 生成文件 (${result.files.length}个)
${result.files.map(f => `✅ ${f}`).join('\n')}

## 🧠 生成 Instincts (${result.instincts.length}个)
- 架构相关: ${result.instincts.architecture.length} (置信度 ${avgConfidence})
- 编码规范: ${result.instincts.codeStyle.length} (置信度 ${avgConfidence})
- API设计: ${result.instincts.apiDesign.length} (置信度 ${avgConfidence})

## 🎯 建议下一步
1. 阅读 docs/ONBOARDING.md
2. 运行测试验证环境
3. 查看 docs/technical/architecture.md

⏱️ 用时: ${elapsed} 分钟
  `);
}
```

## 输出产物详解

### 1. docs/PROJECT_OVERVIEW.md

项目概览文档，包含：
- 项目基本信息
- 架构说明
- 技术栈
- 核心模块
- 依赖关系

### 2. docs/ONBOARDING.md

新人上手指南，包含：
- 环境准备
- 安装依赖
- 启动项目
- 开发流程
- 常见任务

### 3. docs/CODEMAPS/overview.md

代码地图，包含：
- 目录结构
- 模块关系
- 关键文件位置
- 数据流向

### 4. docs/technical/architecture.md

架构文档，包含：
- 架构模式
- 设计决策
- 技术选型
- 系统边界

### 5. docs/technical/api-conventions.md

API规范，包含：
- 接口命名规范
- 请求/响应格式
- 错误处理
- 版本控制

### 6. docs/technical/testing-strategy.md

测试策略，包含：
- 测试框架
- 测试类型
- 覆盖率要求
- 测试组织

### 7. .cursor/rules/project-standards.md

项目编码规范（Cursor规则），包含：
- 命名约定
- 代码格式
- 设计模式偏好
- 最佳实践

### 8. ~/.cursor/homunculus/instincts/personal/*.md

生成的 Instincts，例如：
- `project-[name]-architecture.md`
- `project-[name]-patterns.md`
- `project-[name]-conventions.md`

## 与工作流的关系

```
/learn-project (主动学习)
    │
    ├─▶ 生成项目文档
    ├─▶ 生成编码规范
    └─▶ 生成初始 Instincts (置信度 0.5-0.7)
         │
         ▼
    日常开发 (被动学习)
    Hooks 观察 → Observer 分析
         │
         ├─▶ 强化已有 Instincts (置信度提升)
         └─▶ 新增个人偏好 Instincts
              │
              ▼
         /evolve (演化)
         聚类 Instincts → Skills/Commands/Agents
```

## 使用场景

### 场景1: 首次接触新项目

```bash
# Day 1
git clone company/new-project
cd new-project
/learn-project --depth=medium

# 输出:
# ✅ 学习完成！生成 10 个 Instincts
# ✅ 已生成 docs/ONBOARDING.md

# 然后开始开发
/analyze 实现用户登录功能
```

### 场景2: 加入正在进行的项目

```bash
# 团队成员 A 已经学习过
# 导出他的学习成果
/instinct-export

# 你导入
/instinct-import @team-instincts.json

# 补充学习项目特定内容
/learn-project --depth=quick --update
```

### 场景3: 项目重构后更新认知

```bash
# 项目从 JavaScript 迁移到 TypeScript
# 架构从 MVC 改为 微服务

# 更新学习
/learn-project --update

# AI 会:
# - 更新文档
# - 调整 Instincts 置信度
# - 生成新的 Instincts
```

## 常见问题

### Q: 学习会修改代码吗？

A: **不会**。`/learn-project` 是只读操作，只会生成文档和 Instincts，不会修改任何代码。

### Q: 学习时间太长怎么办？

A: 使用 `--depth=quick` 快速学习（5-10分钟），或使用 `--focus` 只学习特定维度。

### Q: 生成的 Instincts 不准确？

A: 
1. 主动学习生成的 Instincts 初始置信度较低（0.5-0.7）
2. 被动学习会根据你的实际使用调整置信度
3. 你可以手动删除不需要的 Instincts

### Q: 已有项目文档，还需要学习吗？

A: 建议学习。AI 会分析实际代码，可能发现文档未覆盖的模式和规范。

### Q: 多久执行一次？

A: 
- 首次接触项目: 必须执行
- 项目重大变更: 使用 `--update` 更新
- 日常开发: 不需要，被动学习会持续观察

## 相关命令

- `/instinct-status` - 查看学习到的 Instincts
- `/evolve` - 将 Instincts 演化为 Skills
- `/instinct-export` - 导出学习成果
- `/instinct-import` - 导入他人学习成果
- `/analyze` - 开始需求分析（在学习之后执行）

## 相关文档

- [Continuous Learning Skill](../skills/continuous-learning/SKILL.md)
- [learn-project 详细文档](../skills/continuous-learning/commands/learn-project.md)
