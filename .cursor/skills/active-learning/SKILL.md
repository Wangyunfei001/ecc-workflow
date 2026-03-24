---
name: active-learning
description: 主动学习工作流。通过/learn-project命令快速分析项目代码库，生成文档和初始Instincts。
version: 1.0.0
globs: []
apply_when: |
  - 首次接触新项目
  - /learn-project 命令触发
  - 需要快速建立项目认知
priority: 20
requires: []
outputs: ["docs/PROJECT_OVERVIEW.md", "docs/ONBOARDING.md", "docs/CODEMAPS/*.md"]
---

# 主动学习 (Active Learning)

## 目标

快速分析项目代码库，建立项目认知，生成文档和初始Instincts。

## 触发方式

```bash
/learn-project --depth=quick    # 5-10分钟
/learn-project --depth=medium   # 20-30分钟（推荐）
/learn-project --depth=deep     # 1小时+
/learn-project --update         # 更新已有学习成果
```

## 学习内容

| 分析项 | 输出 |
|--------|------|
| 项目架构和技术栈 | PROJECT_OVERVIEW.md |
| 项目结构和文件组织 | CODEMAPS/overview.md |
| 编码规范和设计模式 | project-standards.md |
| API设计规范 | api-conventions.md |
| 业务逻辑和领域知识 | 初始Instincts |

## 输出产物

```
docs/
├── PROJECT_OVERVIEW.md      # 项目概览
├── ONBOARDING.md            # 新人指南
├── CODEMAPS/overview.md     # 代码地图
└── technical/
    ├── architecture.md      # 架构文档
    └── api-conventions.md   # API约定

.cursor/rules/
└── project-standards.md     # 项目编码规范

~/.cursor/homunculus/instincts/personal/
└── project-arch-*.md        # 初始Instincts (置信度 0.5-0.7)
```

## 最佳实践

```bash
# 推荐流程
git clone new-project
cd new-project
/learn-project --depth=medium   # 先建立项目认知
# ... 然后开始开发
```

## 与被动学习的协同

主动学习生成的Instincts（置信度0.5-0.7）会在后续被动学习中：
- 被验证 → 置信度提升至0.7+
- 被纠正 → 置信度降低或移除

## 相关资源

- [/learn-project命令](../../commands/learn-project.md)
- [被动学习](../passive-learning/SKILL.md)
