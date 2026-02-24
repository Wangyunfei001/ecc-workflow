---
name: instinct-import
description: 导入他人分享的 Instinct 到本地
---

# /instinct-import 命令

导入团队成员分享的 Instinct 文件到本地。

## 用法

```bash
/instinct-import <file>
/instinct-import team-instincts.json
/instinct-import --dry-run team-instincts.json
```

## 功能说明

- 读取导入文件（JSON 格式）
- 验证格式和版本兼容性
- 检查冲突（ID 重复）
- 写入到 `~/.cursor/homunculus/instincts/inherited/`
- 生成导入报告

## 冲突处理

当导入的 Instinct ID 已存在时，按置信度保留更高版本。

## 新成员入职流程

```bash
# 1. 克隆团队仓库
git clone team-repo

# 2. 导入团队 Instinct
/instinct-import team-instincts/coding-standards.json
/instinct-import team-instincts/testing-patterns.json

# 3. 查看导入结果
/instinct-status
```

## 相关命令

- [/instinct-status](../skills/continuous-learning/commands/instinct-status.md) - 查看 Instinct
- [/instinct-export](./instinct-export.md) - 导出 Instinct
- [/evolve](../skills/continuous-learning/commands/evolve.md) - 演化 Instinct

## 相关资源

- [Continuous Learning Skill](../skills/continuous-learning/SKILL.md)
- [完整文档](../skills/continuous-learning/commands/instinct-import.md)
