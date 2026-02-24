---
name: evolve
description: 将相关的 Instinct 聚类演化为 Skill、Command 或 Agent
---

# /evolve 命令

将积累的 Instinct 聚类演化为更高级的可复用资源。

## 用法

```bash
/evolve                    # 自动检测可聚类的 instinct
/evolve --domain testing   # 只演化特定领域
/evolve --force            # 强制演化所有
```

## 演化规则

当同一领域的高置信度 Instinct >= 3 个时，建议演化为：

- **Skill** - 领域知识和最佳实践
- **Command** - 快捷操作流程
- **Agent** - 专家角色定义

## 演化流程

1. 读取所有高置信度 (>0.7) 的 Instinct
2. 按领域 (domain) 分组聚类
3. 检测可演化的组（>= 3 个 Instinct）
4. 生成对应的 Skill/Command/Agent
5. 保存到 `~/.cursor/homunculus/evolved/`

## 示例输出

```markdown
# 演化报告

## 检测到可聚类的 Instinct 组

### 组 1: TypeScript 编码风格
- prefer-functional-style (0.85)
- use-const-over-let (0.70)
- prefer-arrow-functions (0.65)

**建议:** 生成 `skills/typescript-style.md`
```

## 相关命令

- [/instinct-status](../skills/continuous-learning/commands/instinct-status.md) - 查看 Instinct
- [/instinct-export](./instinct-export.md) - 导出 Instinct
- [/instinct-import](./instinct-import.md) - 导入 Instinct

## 相关资源

- [Continuous Learning Skill](../skills/continuous-learning/SKILL.md)
- [完整文档](../skills/continuous-learning/commands/evolve.md)
