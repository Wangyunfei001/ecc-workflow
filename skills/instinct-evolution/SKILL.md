---
name: instinct-evolution
description: Instinct演化工作流。将积累的Instincts聚类演化为Skills、Commands、Agents。
version: 1.0.0
globs: []
apply_when: |
  - /evolve 命令触发
  - Instincts数量达到阈值（30+）
  - 需要生成项目定制的工作流
priority: 20
requires: ["passive-learning"]
outputs: ["~/.cursor/homunculus/evolved/**/*"]
---

# Instinct 演化

## 目标

将积累的Instincts聚类，演化为更高层次的复用资源：Skills、Commands、Agents。

## 触发方式

```bash
/evolve
```

## 演化流程

```
instincts/personal/*.md
        │
        ▼
   聚类分析（按domain）
        │
        ▼
   生成演化建议
        │
        ▼ (用户确认)
evolved/
├── skills/      # 领域知识
├── commands/    # 快捷操作
└── agents/      # 专家角色
```

## 聚类规则

| Instinct数量 | 建议演化产物 |
|--------------|-------------|
| 3+ 同domain | Skill |
| 5+ 操作序列 | Command |
| 10+ 角色相关 | Agent |

## 演化示例

```markdown
## 检测到可聚类的 Instinct 组

### 组 1: TypeScript 编码风格
- prefer-functional-style (0.85)
- use-const-over-let (0.70)
- prefer-arrow-functions (0.65)

**建议:** 生成 `skills/typescript-style.md`

### 组 2: 测试驱动开发
- always-test-first (0.80)
- write-unit-tests (0.75)
- check-coverage (0.60)

**建议:** 生成 `commands/tdd.md`

是否执行演化？[Y/n]
```

## 团队共享

```bash
# 导出Instincts
/instinct-export --min-confidence 0.7

# 其他成员导入
/instinct-import team-instincts.json
```

## 目录结构

```
~/.cursor/homunculus/
├── instincts/
│   ├── personal/     # 个人学习
│   └── inherited/    # 团队导入
└── evolved/
    ├── skills/       # 演化的Skill
    ├── commands/     # 演化的Command
    └── agents/       # 演化的Agent
```

## 相关资源

- [/evolve命令](../../commands/evolve.md)
- [/instinct-export命令](../../commands/instinct-export.md)
