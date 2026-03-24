---
name: instinct-status
description: 查看已学习的 Instinct 状态和统计信息
---

# /instinct-status 命令

查看持续学习系统中已学习的 Instinct 状态。

## 用法

```bash
/instinct-status
/instinct-status --domain code-style
/instinct-status --min-confidence 0.7
```

## 功能说明

展示：
- Instinct 总数和分类统计
- 高置信度 Instinct 列表
- 最近学习的 Instinct
- 按领域分组的 Instinct

## 实现方式

读取 `~/.cursor/homunculus/instincts/` 目录下的所有 Instinct 文件，解析 frontmatter 并统计。

## 相关命令

- [/evolve](../skills/continuous-learning/commands/evolve.md) - 演化 Instinct 为 Skill
- [/instinct-export](../skills/continuous-learning/commands/instinct-export.md) - 导出 Instinct
- [/instinct-import](../skills/continuous-learning/commands/instinct-import.md) - 导入 Instinct

## 相关资源

- [Continuous Learning Skill](../skills/continuous-learning/SKILL.md)
- [记忆架构说明](../../docs/memory-architecture.md)
