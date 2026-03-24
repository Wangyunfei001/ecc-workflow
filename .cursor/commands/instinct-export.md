---
name: instinct-export
description: 导出已学习的 Instinct 供团队共享
---

# /instinct-export 命令

导出个人学习的 Instinct 到 JSON 文件，供团队成员共享。

## 用法

```bash
/instinct-export
/instinct-export --min-confidence 0.7
/instinct-export --domain code-style
```

## 功能说明

- 扫描 `~/.cursor/homunculus/instincts/personal/` 目录
- 筛选符合条件的 Instinct
- 生成 JSON 导出文件
- 保存到 `~/.cursor/homunculus/exports/`

## 导出文件格式

```json
{
  "version": "1.0",
  "exported_at": "2026-02-03T10:30:00Z",
  "instincts": [...]
}
```

## 团队协作流程

1. 个人导出高置信 Instinct
2. 提交到团队仓库
3. 其他成员通过 `/instinct-import` 导入

## 相关命令

- [/instinct-status](../skills/continuous-learning/commands/instinct-status.md) - 查看 Instinct
- [/instinct-import](./instinct-import.md) - 导入 Instinct
- [/evolve](../skills/continuous-learning/commands/evolve.md) - 演化 Instinct

## 相关资源

- [Continuous Learning Skill](../skills/continuous-learning/SKILL.md)
- [完整文档](../skills/continuous-learning/commands/instinct-export.md)
