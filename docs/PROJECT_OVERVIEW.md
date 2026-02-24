# Cursor ECC 工作流系统 - 项目概览

## 基本信息

- **项目名称**: Cursor ECC Workflow System
- **项目类型**: AI研发流水线配置系统
- **版本**: v2.2 (2026-02-03)
- **技术栈**: Markdown文档 + Cursor AI + Obsidian (可选)
- **目标用户**: 重度Cursor用户、AI辅助开发团队

## 项目概述

Cursor ECC工作流系统是一个基于Everything Claude Code (ECC)的企业级AI研发流水线,专为重度Cursor用户设计。核心理念是**Code Before Coding**——在编码之前先设计,将"Chat式编程"升级为"流水线式工程"。

## 核心架构

### 5阶段门禁模式

```
Phase 1: 需求分析 ──▶ 需求文档 ──▶ 🚧 Gate 1
Phase 2: 任务规划 ──▶ 实施计划 ──▶ 🚧 Gate 2
Phase 3: 架构设计 ──▶ 架构方案 + ADR ──▶ 🚧 Gate 3
Phase 4: 规格撰写 ──▶ Spec文档 ──▶ 🚧 Gate 4
Phase 5: 代码实现 ──▶ 代码 ──▶ ✅ 完成
```

每个Gate都是**强制停止点**,必须人工审查通过才能继续。

### 双层记忆架构

| 层级 | 位置 | 内容 | 管理 | 共享方式 |
|------|------|------|------|---------|
| **项目级** | `docs/` | Spec、计划、ADR、Codemap | Obsidian + Git | Git自动 |
| **用户级** | `~/.cursor/homunculus/` | Instinct、编码习惯 | Hooks + Observer | export/import |

## 核心组件

### 10个Agent角色

1. **requirement-analyst** - 需求分析专家 (Phase 1)
2. **planner** - 任务规划专家 (Phase 2)
3. **architect** - 架构设计专家 (Phase 3)
4. **spec-writer** - 规格文档撰写专家 (Phase 4)
5. **strict-coder** - 严格实现专家 (Phase 5)
6. **code-reviewer** - 代码审查专家
7. **security-reviewer** - 安全审查专家
8. **tdd-guide** - TDD引导专家
9. **librarian** - 文档同步专家
10. **bug-hunter** - 故障排查专家

### 4个核心Skill

1. **spec-driven-dev** - 规格驱动开发工作流 (v2.0)
2. **continuous-learning** - 持续学习系统 (v2.0 双模学习)
3. **doc-sync** - 文档同步工作流
4. **strategic-context** - 上下文管理高级技能

### 11个命令

| 类别 | 命令 | 用途 |
|------|------|------|
| **核心开发** | `/analyze` | 需求分析(Phase 1) |
| | `/spec` | 生成规格文档(Phase 4) |
| | `/implement` | 基于Spec实现(Phase 5) |
| | `/review` | 代码审查 |
| | `/sync` | 文档同步 |
| | `/orchestrate` | 完整流程编排 |
| **持续学习** | `/learn-project` | 主动学习项目(NEW v2.2) |
| | `/instinct-status` | 查看Instinct |
| | `/evolve` | 演化Instinct |
| | `/instinct-export` | 导出Instinct |
| | `/instinct-import` | 导入Instinct |

## 技术决策

### v2.0 核心改进

- ✅ 新增需求分析阶段 — 强制追问机制
- ✅ 新增架构设计阶段 — 技术方案对比、ADR记录
- ✅ 5阶段门禁模式 — 每个阶段都有强制检查点
- ✅ 追问驱动开发 — 不假设,不确定就问

### v2.2 重大更新

- ✅ **主动学习系统** — `/learn-project`命令快速建立项目认知
- ✅ **双模学习架构** — 主动学习(快速) + 被动学习(渐进)
- ✅ **6类输出产物** — 项目文档、技术文档、Onboarding指南、Codemap、编码规范、Instincts
- ✅ **3种学习深度** — Quick (5-10分钟)、Medium (20-30分钟)、Deep (1小时+)

## 项目结构

```
.cursor/
├── agents/          # 10个Agent定义
├── commands/        # 11个快捷命令
├── skills/          # 4个可复用工作流
├── rules/           # 4个全局规则
├── hooks/           # 自动化钩子
└── templates/       # 4个文档模板

docs/
├── requirements/    # 需求文档 (Phase 1)
├── plans/          # 实施计划 (Phase 2)
├── architecture/   # 架构方案 (Phase 3)
├── adrs/           # 架构决策记录 (Phase 3)
├── specs/          # 技术规格 (Phase 4)
│   ├── features/
│   ├── apis/
│   └── components/
└── CODEMAPS/       # 代码地图

~/.cursor/homunculus/
├── observations.jsonl    # 观察日志
├── instincts/
│   ├── personal/        # 自动学习的Instinct
│   └── inherited/       # 从团队导入的
└── evolved/
    ├── agents/
    ├── skills/
    └── commands/
```

## 核心模块

### 规格驱动开发 (Spec-Driven Development)

**理念**: 在写任何代码之前,先把需求理解清楚,把设计想明白。

**流程**:
1. 需求分析 → 需求文档
2. 任务规划 → 实施计划
3. 架构设计 → 架构方案 + ADR
4. 规格撰写 → Spec文档
5. 代码实现 → 严格按Spec实现

**适用场景**: 新功能开发、复杂业务逻辑、多人协作任务

### 持续学习 (Continuous Learning) v2.0

**双模学习架构**:
- **主动学习** (`/learn-project`): 首次接触项目时,快速建立项目认知(5-60分钟)
- **被动学习** (Hooks + Observer): 日常开发中自动观察和学习(持续进行)

**输出产物**:
- 项目文档: PROJECT_OVERVIEW.md, ONBOARDING.md
- 技术文档: architecture.md, api-conventions.md
- 编码规范: project-standards.md (Cursor规则)
- Instincts: 初始置信度0.5-0.7,被动学习持续强化

### 文档同步 (Doc Sync)

**理念**: 确保代码变更后,相关文档自动更新,防止文档与代码不一致。

**角色**: librarian Agent负责反向更新文档。

## 与ECC的集成

本工作流完全兼容Everything Claude Code插件,采用**互补设计**:

- **本工作流**: 专注于Spec驱动开发流程
- **ECC**: 提供语言特定技能(golang-patterns, python-patterns, django-patterns等)

**推荐组合**:
- Go项目: 本工作流 + `go-reviewer` + `golang-patterns`
- Python项目: 本工作流 + `python-reviewer` + `python-patterns`
- 数据库操作: 本工作流 + `database-reviewer` + `postgres-patterns`

## 适用场景

### 最适合

- 需要文档化的企业级项目
- 多人协作的复杂系统
- 需要严格质量控制的项目
- AI辅助开发但需要流程化管理

### 不适合

- 简单的脚本或工具
- 一次性原型项目
- 紧急热修复(可简化流程)
- 个人学习项目(除非想练习规范化开发)

## 学习路径

### 新用户(Day 1)

1. 阅读 `README.md` 了解整体架构
2. 阅读 `快速开始.md` 快速上手
3. 执行 `/learn-project --depth=quick` 学习项目本身
4. 尝试完整流程: `/analyze` → `@planner` → `/spec` → `/implement`

### 团队推广

1. 技术负责人先使用1-2周,积累经验
2. 主动学习团队项目: `/learn-project --depth=medium`
3. 导出学习成果: `/instinct-export`
4. 团队成员导入: `/instinct-import`
5. 定期同步Instinct和规范

## 相关资源

- [团队推广指南](./team-adoption-guide.md)
- [记忆架构说明](./memory-architecture.md)
- [v2.2变更摘要](./v2.2-changes-summary.md)
- [持续学习配置](./continuous-learning-setup.md)

## 维护状态

- **当前版本**: v2.2
- **最近更新**: 2026-02-03
- **维护状态**: 活跃开发
- **授权协议**: MIT
