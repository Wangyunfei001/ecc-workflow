---
name: spec
description: 生成技术规格文档。
---

# /spec 命令

生成技术规格文档。

## 用法

```bash
/spec [需求描述]
/spec @[需求文件]
```

## 示例

```bash
# 直接描述需求
/spec 用户登录功能，支持邮箱和手机号

# 基于已有文档
/spec @docs/requirements/login.md

# 指定输出位置
/spec 用户注册 --output docs/specs/features/user-register.md
```

## 执行流程

1. **解析需求**
   - 提取核心功能点
   - 识别关键实体
   - 确定边界条件

2. **生成 Spec**
   - 使用 `@spec-writer` Agent
   - 按照标准模板输出
   - 保存到 `docs/specs/`

3. **输出提示**
   - 显示生成的文件路径
   - 提示下一步操作

## 输出格式

```markdown
---
title: [功能名称]
status: draft
created: YYYY-MM-DD
---

# [功能名称] 技术规格

## 1. 概述
## 2. 功能需求
## 3. 数据模型
## 4. API 设计
## 5. UI/组件设计
## 6. 边界情况
## 7. 安全考虑
## 8. 测试策略
## 9. 验收清单
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--output` | 指定输出路径 | `docs/specs/features/<name>.md` |
| `--template` | 使用自定义模板 | 标准模板 |
| `--category` | 分类 (feature/api/component) | feature |

## 下一步

生成 Spec 后：
1. 在 Obsidian 中审查文档
2. 修改并将 `status` 改为 `approved`
3. 运行 `/implement @docs/specs/xxx.md`

## 相关命令

- `/implement` - 基于 Spec 实现代码
- `/plan` - 生成实施计划
- `/review` - 代码审查
