# Cursor ECC工作流系统 - 代码地图

本文档提供项目的结构化代码地图,帮助快速定位和理解各个模块。

## 项目结构概览

```
ecc-workflow/
├── .cursor/              # Cursor配置和工作流定义
│   ├── agents/          # 10个Agent角色定义
│   ├── commands/        # 11个快捷命令
│   ├── skills/          # 4个可复用工作流
│   ├── rules/           # 4个全局规则
│   ├── hooks/           # 自动化钩子配置
│   └── templates/       # 4个文档模板
│
├── docs/                # 项目级记忆(跟随Git)
│   ├── requirements/    # Phase 1: 需求文档
│   ├── plans/          # Phase 2: 实施计划
│   ├── architecture/   # Phase 3: 架构方案
│   ├── adrs/           # Phase 3: 架构决策记录
│   ├── specs/          # Phase 4: 技术规格
│   └── CODEMAPS/       # 代码地图
│
└── scripts/            # 安装和验证脚本
```

## 模块详解

### .cursor/agents/ - Agent角色定义

所有Agent都是Markdown文件,定义了角色的职责、工具和工作流程。

#### Phase 1: 需求分析
- **requirement-analyst.md** (538行)
  - 职责: 需求澄清、追问、确认
  - 工具: Read, Grep, Glob, AskQuestion
  - 输出: `docs/requirements/YYYY-MM-DD-<name>.md`
  - 追问清单: 5大类(用户场景、功能范围、验收标准、约束依赖、优先级风险)

#### Phase 2: 任务规划
- **planner.md** (228行)
  - 职责: 需求验证、任务拆解、依赖识别、风险评估
  - 工具: Read, Grep, Glob
  - 输出: `docs/plans/YYYY-MM-DD-<name>.md`
  - 前置检查: 需求文档必须存在且approved

#### Phase 3: 架构设计
- **architect.md** (424行)
  - 职责: 系统设计、技术选型、架构决策(ADR)
  - 工具: Read, Grep, Glob
  - 输出: `docs/architecture/<feature>.md` + `docs/adrs/ADR-xxx.md`
  - 技术追问清单: 4大类(数据、API、架构、技术选型)

#### Phase 4: 规格撰写
- **spec-writer.md** (310行)
  - 职责: 撰写技术规格文档(Spec)
  - 工具: Read, Grep, Glob, Write
  - 输出: `docs/specs/[category]/[feature-name].md`
  - 核心原则: 文档驱动、精准无歧义、可验证、边界清晰

#### Phase 5: 代码实现与审查
- **strict-coder.md** (235行)
  - 职责: 100%按Spec实现,禁止自由发挥
  - 工具: Read, Write, Grep, Glob, Bash
  - 核心原则: Spec即法律、禁止发散、精准对应、遇惑则问

- **code-reviewer.md**
  - 职责: 代码质量审查
  - 审查维度: Spec合规性、代码质量、安全性、测试覆盖

- **security-reviewer.md**
  - 职责: 安全漏洞分析
  - 关注: 认证、授权、数据加密、输入校验

#### 辅助Agent
- **tdd-guide.md**
  - 职责: TDD驱动开发
  - 触发: 新功能/Bug修复

- **librarian.md**
  - 职责: 文档与代码同步
  - 触发: 代码变更后

- **bug-hunter.md**
  - 职责: 故障分析与修复
  - 触发: 错误排查

### .cursor/skills/ - 可复用工作流

#### spec-driven-dev/ (v2.0)
- **SKILL.md** (441行)
  - 规格驱动开发工作流
  - 5阶段门禁模式
  - 适用: 新功能开发、复杂重构

#### continuous-learning/ (v2.0)
- **SKILL.md** (617行)
  - 双模学习系统
  - 主动学习: `/learn-project`命令
  - 被动学习: Hooks + Observer
  - 输出: 文档 + Instincts

- **commands/**
  - `learn-project.md` (468行) - 主动学习命令详细文档
  - `instinct-status.md` - 查看Instinct状态
  - `instinct-export.md` - 导出Instinct
  - `instinct-import.md` - 导入Instinct
  - `evolve.md` - 演化Instinct

- **agents/**
  - `observer.md` - 后台观察Agent,分析会话生成Instinct

#### doc-sync/
- **SKILL.md**
  - 文档同步工作流
  - 确保代码变更后文档更新

#### strategic-context/
- **SKILL.md**
  - 上下文管理高级技能
  - 战略性压缩、迭代检索、评估框架

### .cursor/commands/ - 快捷命令

#### 核心开发命令
- **analyze.md** - `/analyze` 需求分析(Phase 1)
- **spec.md** - `/spec` 生成规格文档(Phase 4)
- **implement.md** - `/implement` 基于Spec实现(Phase 5)
- **review.md** - `/review` 代码审查
- **sync.md** - `/sync` 文档同步
- **orchestrate.md** - `/orchestrate` 完整流程编排

#### 持续学习命令
- **learn-project.md** (540行) - `/learn-project` 主动学习项目
- **instinct-status.md** - `/instinct-status` 查看Instinct
- **evolve.md** - `/evolve` 演化Instinct
- **instinct-export.md** - `/instinct-export` 导出Instinct
- **instinct-import.md** - `/instinct-import` 导入Instinct

### .cursor/rules/ - 全局规则

- **coding-standards.md** - 编码规范
- **quality-gates.md** - 质量门禁
- **security.md** - 安全规范
- **agent-routing.md** - Agent路由规则

### .cursor/templates/ - 文档模板

- **requirement-template.md** - 需求文档模板(Phase 1)
- **spec-template.md** - 技术规格模板(Phase 4)
- **adr-template.md** - 架构决策记录模板(Phase 3)
- **handoff-template.md** - 交接文档模板

### docs/ - 项目级记忆

#### 工作流输出目录
```
docs/
├── requirements/      # Phase 1输出
│   └── YYYY-MM-DD-<name>.md
├── plans/            # Phase 2输出
│   └── YYYY-MM-DD-<name>.md
├── architecture/     # Phase 3输出
│   └── <feature>.md
├── adrs/            # Phase 3输出
│   └── ADR-XXX-<title>.md
└── specs/           # Phase 4输出
    ├── features/    # 功能规格
    ├── apis/        # API规格
    └── components/  # 组件规格
```

#### 系统文档
- **PROJECT_OVERVIEW.md** - 项目概览
- **ONBOARDING.md** - 新人上手指南
- **memory-architecture.md** - 记忆架构说明
- **team-adoption-guide.md** - 团队推广指南
- **continuous-learning-setup.md** - 持续学习配置
- **learn-project-feature.md** - learn-project功能说明
- **v2.2-changes-summary.md** - v2.2变更摘要

### scripts/ - 工具脚本

- **install.sh** - 安装脚本,配置Hooks
- **verify-setup.sh** - 验证配置是否正确

## 数据流向

### 开发流程数据流

```
用户需求
    │
    ▼
[requirement-analyst] ──▶ docs/requirements/xxx.md
    │                          │
    │ 🚧 Gate 1                │
    ▼                          ▼
[planner] ──▶ docs/plans/xxx.md
    │              │
    │ 🚧 Gate 2    │
    ▼              ▼
[architect] ──▶ docs/architecture/xxx.md + docs/adrs/ADR-xxx.md
    │                          │
    │ 🚧 Gate 3                │
    ▼                          ▼
[spec-writer] ──▶ docs/specs/features/xxx.md
    │                  │
    │ 🚧 Gate 4        │
    ▼                  ▼
[strict-coder] ──▶ 代码实现
    │                  │
    ▼                  ▼
[code-reviewer] ──▶ 审查反馈
    │                  │
    ▼                  ▼
[librarian] ──▶ 更新Spec和Codemap
```

### 学习系统数据流

```
主动学习:
/learn-project ──▶ 扫描代码库 ──▶ 生成文档 + Instincts

被动学习:
日常开发 ──▶ Hooks捕获 ──▶ observations.jsonl
                                  │
                                  ▼
                             Observer Agent
                                  │
                                  ▼
                     ~/.cursor/homunculus/instincts/
```

## 关键文件位置

### 最常访问的文件

| 文件 | 用途 | 更新频率 |
|------|------|---------|
| `docs/requirements/` | 需求文档 | 每个新功能 |
| `docs/specs/features/` | 功能规格 | 每个新功能 |
| `.cursor/agents/` | Agent定义 | 很少 |
| `.cursor/commands/` | 命令文档 | 很少 |

### 配置文件

| 文件 | 用途 |
|------|------|
| `~/.cursor/settings.json` | Cursor全局配置(需手动配置Hooks) |
| `~/.cursor/homunculus/config.json` | 持续学习系统配置 |
| `.cursor/hooks/hooks.json` | Hooks配置 |

## 模块依赖关系

### Agent依赖

```
requirement-analyst (独立)
    ↓
planner (依赖需求文档)
    ↓
architect (依赖实施计划,可选)
    ↓
spec-writer (依赖架构方案或实施计划)
    ↓
strict-coder (依赖Spec)
    ↓
code-reviewer (依赖代码)
    ↓
librarian (依赖代码变更)
```

### Skill依赖

```
spec-driven-dev
    ├── 依赖所有Phase 1-5 Agent
    └── 集成doc-sync

continuous-learning
    ├── learn-project (主动学习)
    │   └── 依赖 Grep, Glob, Read, SemanticSearch
    └── observer (被动学习)
        └── 依赖 Hooks
```

## 扩展点

### 添加新Agent

1. 在`.cursor/agents/`创建新Agent定义
2. 定义name, description, tools, model
3. 编写角色职责和工作流程
4. 在`.cursor/rules/agent-routing.md`添加路由规则

### 添加新命令

1. 在`.cursor/commands/`创建命令文档
2. 定义命令用法、参数、示例
3. 关联对应的Agent或Skill

### 添加新Skill

1. 在`.cursor/skills/`创建新目录
2. 编写`SKILL.md`主文档
3. 创建子目录(如commands/, agents/)
4. 在主README中注册新Skill

## 相关文档

- [项目概览](../PROJECT_OVERVIEW.md) - 整体架构
- [新人上手指南](../ONBOARDING.md) - 快速开始
- [架构文档](../technical/architecture.md) - 技术架构
- [记忆架构说明](../memory-architecture.md) - 双层记忆

---

**更新日期**: 2026-02-03  
**维护**: 自动更新(通过/learn-project)
