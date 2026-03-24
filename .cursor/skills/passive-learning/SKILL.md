---
name: passive-learning
description: 被动学习工作流。通过Hooks自动观察开发会话，提取编码模式和偏好生成Instincts。
version: 1.0.0
globs: []
apply_when: |
  - 日常开发（自动后台运行）
  - Hooks启用后自动生效
priority: 20
requires: []
outputs: ["~/.cursor/homunculus/instincts/personal/*.md"]
---

# 被动学习 (Passive Learning)

## 目标

从日常开发会话中自动提取编码模式、偏好和最佳实践，生成Instincts。

## 工作原理

```
日常开发 → Hooks捕获 → observations.jsonl → Observer Agent → Instincts
```

## 检测模式

| 模式类型 | 说明 | 示例 |
|----------|------|------|
| 用户纠正 | 用户修改AI生成的代码 | 类→函数式 |
| 错误解决 | 用户解决特定错误的方式 | 特定的debug方法 |
| 重复流程 | 重复执行的操作序列 | 测试优先 |
| 工具偏好 | 偏好使用的工具/命令 | 偏好vitest而非jest |

## 启用方式

在 `~/.cursor/settings.json` 中配置：

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{"type": "command", "command": "~/.cursor/hooks/observe.sh pre"}]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{"type": "command", "command": "~/.cursor/hooks/observe.sh post"}]
    }]
  }
}
```

## 置信度机制

| 分数 | 含义 | 行为 |
|------|------|------|
| 0.3 | 试探性 | 建议但不强制 |
| 0.5 | 中等 | 相关时应用 |
| 0.7 | 强 | 自动应用 |
| 0.9 | 近乎确定 | 核心行为 |

**提升条件**: 重复观察、用户未纠正、多来源验证
**下降条件**: 用户纠正、长期未观察、矛盾证据

## 查看学习成果

```bash
/instinct-status
```

## 隐私说明

- 观察数据**仅存储在本地**
- 只有**模式（Instinct）**可导出，不共享实际代码或对话

## 相关资源

- [Observer Agent](../continuous-learning/agents/observer.md)
- [Instinct演化](../instinct-evolution/SKILL.md)
