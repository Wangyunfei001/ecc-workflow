---
name: doc-sync
description: 文档同步工作流。确保代码变更后，相关文档自动更新。防止文档与代码不一致导致的"熵增"问题。
version: 2.0.0
globs: ["docs/**/*.md", "src/**/*"]
apply_when: |
  - 代码审查通过后
  - 合并PR后
  - /sync 命令触发
  - @librarian 调用
  - 完成一个开发阶段后
priority: 70
requires: ["code-implementation"]
outputs: ["docs/specs/**/*.md", "docs/CODEMAPS/*.md"]
---

# 文档同步 (Doc Sync)

## 概述

Doc Sync 是一个**反向同步**工作流，确保代码变更后，相关文档保持更新。

```
┌─────────────────────────────────────────────────────────────────┐
│                        Doc Sync Flow                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  代码变更 ──▶ 检测变更类型 ──▶ 定位相关文档 ──▶ 执行同步        │
│                                                                 │
│  同步范围:                                                       │
│  ├── Spec 文档 (数据模型、API 定义)                              │
│  ├── Codemap (目录结构、模块关系)                                │
│  ├── README (使用说明、配置变更)                                 │
│  └── ADR (架构决策记录)                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 何时使用

**自动触发场景：**
- 代码审查通过后
- 合并 PR 后
- 完成一个开发阶段后

**手动触发场景：**
```bash
"/sync"                        # 同步所有变更
"/sync @docs/specs/user.md"    # 同步指定文档
```

## 同步规则

### 代码 → 文档映射

| 代码变更类型 | 需要更新的文档 | 优先级 |
|-------------|---------------|--------|
| 新增 Interface/Type | Spec 数据模型章节 | 高 |
| 新增 API 端点 | Spec API 设计章节 | 高 |
| 修改 API 响应 | Spec API 设计章节 | 高 |
| 新增组件 | Spec 组件设计章节 | 中 |
| 新增错误码 | Spec 错误处理章节 | 中 |
| 文件/目录结构变化 | CODEMAPS | 中 |
| 配置项变更 | README | 低 |
| 依赖变更 | README | 低 |

### 自动同步 vs 人工确认

**自动同步（无需确认）：**
- 新增字段/端点
- 类型定义变更
- 文件结构变化
- 版本号更新

**需要人工确认：**
- 删除字段/端点（可能是 Breaking Change）
- 业务逻辑变更
- 权限/安全相关变更
- 架构层面调整

## 工作流程

### Step 1: 检测变更

```bash
# 获取变更文件列表
git diff --name-only HEAD~1

# 示例输出
src/api/users.ts
src/types/user.ts
src/components/UserProfile.vue
```

### Step 2: 分析变更内容

对每个变更文件，提取关键信息：

```markdown
## 变更分析

### src/types/user.ts
**类型:** TypeScript 类型定义
**变更内容:**
- 新增字段: `lastLoginAt: Date`
- 修改字段: `status` 从 string 改为 enum

### src/api/users.ts
**类型:** API 端点
**变更内容:**
- 新增端点: `PUT /api/users/:id`
- 修改响应: `GET /api/users/:id` 增加 `lastLoginAt`
```

### Step 3: 定位相关文档

```markdown
## 文档映射

| 变更文件 | 相关文档 | 需更新章节 |
|----------|----------|-----------|
| src/types/user.ts | docs/specs/features/user.md | 3.1 数据模型 |
| src/api/users.ts | docs/specs/features/user.md | 4.1 API 端点, 4.2 详细定义 |
| - | docs/CODEMAPS/overview.md | 模块结构 |
```

### Step 4: 执行同步

#### 更新 Spec 文档

```markdown
## docs/specs/features/user.md

### 3.1 数据模型 (更新)

```typescript
interface User {
  id: string;
  email: string;
  name: string;
  status: UserStatus;    // [更新] 改为枚举类型
  lastLoginAt?: Date;    // [新增] 最后登录时间
  createdAt: Date;
  updatedAt: Date;
}

enum UserStatus {        // [新增]
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  BANNED = 'banned'
}
```

### 4.1 端点列表 (更新)

| 方法 | 端点 | 描述 | 版本 |
|------|------|------|------|
| POST | /api/users | 创建用户 | v1.0 |
| GET | /api/users/:id | 获取用户 | v1.0 → v1.1 |
| PUT | /api/users/:id | 更新用户 | v1.1 ✨新增 |
```

#### 更新变更日志

```markdown
## 变更历史

| 版本 | 日期 | 变更内容 | 关联 Commit |
|------|------|----------|-------------|
| 1.1 | 2026-02-02 | 添加 lastLoginAt, 用户更新端点 | abc123 |
| 1.0 | 2026-01-15 | 初始版本 | def456 |
```

#### 更新 Codemap

```markdown
## docs/CODEMAPS/overview.md

### 用户模块

```
src/
├── api/
│   └── users.ts        # 用户 API [v1.1: +PUT]
├── types/
│   └── user.ts         # 用户类型 [v1.1: +lastLoginAt, +UserStatus]
└── components/
    └── UserProfile.vue # 用户资料组件
```
```

### Step 5: 生成同步报告

```markdown
# 文档同步报告

## 📊 概览

**触发:** Commit abc123
**时间:** 2026-02-02 15:30
**同步文档:** 2 个

## 📝 变更详情

### docs/specs/features/user.md
- ✅ 更新数据模型（+lastLoginAt, status 改为 enum）
- ✅ 添加 PUT /api/users/:id 端点定义
- ✅ 更新 GET 响应字段
- ✅ 追加变更日志

### docs/CODEMAPS/overview.md
- ✅ 更新用户模块结构

## ⚠️ 需要人工确认

无

## ✅ 同步完成
```

## 冲突处理

### 场景 1: 代码与 Spec 不一致

```markdown
⚠️ **发现不一致**

| 项目 | Spec 定义 | 代码实现 |
|------|-----------|----------|
| User.email | required | optional |

**选择处理方式:**
1. 更新 Spec（代码是正确的新实现）
2. 报告问题（代码需要修改）
3. 人工介入
```

### 场景 2: 文档不存在

```markdown
📝 **缺少对应文档**

代码 `src/api/payments.ts` 没有对应的 Spec 文档。

**建议:**
运行 `@spec-writer` 为该模块创建 Spec。
```

### 场景 3: Breaking Change

```markdown
⚠️ **检测到 Breaking Change**

API `GET /api/users/:id` 的响应格式发生了不兼容变更：
- 删除字段: `avatar`
- 类型变更: `status` string → enum

**建议:**
1. 在 Spec 中标记为 Breaking Change
2. 更新 API 版本号
3. 添加迁移指南
```

## 自动化配置

### Git Hooks 集成

```json
// .cursor/hooks/hooks.json
{
  "PostToolUse": [
    {
      "matcher": "tool == 'Write' && tool_input.path matches '.*\\.ts$'",
      "hooks": [
        {
          "type": "command",
          "command": "echo '[Doc Sync] 代码变更，建议运行 /sync 同步文档'"
        }
      ]
    }
  ]
}
```

### CI/CD 集成

```yaml
# .github/workflows/doc-check.yml
name: Doc Sync Check

on: [pull_request]

jobs:
  check-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check doc freshness
        run: |
          # 检查 Spec 最后更新时间
          # 如果代码变更后文档未更新，发出警告
```

## 最佳实践

### 1. 养成习惯

每次完成代码变更后，运行 `/sync`。

### 2. 保留历史

不要直接删除旧内容，使用 `[deprecated]` 标记：

```markdown
~~`avatar: string`~~ [deprecated v1.1]
```

### 3. 关联 Commit

在变更日志中关联 Git commit：

```markdown
| 1.1 | 2026-02-02 | 添加用户更新 | [abc123](link) |
```

### 4. 定期审计

每周/每月审查文档与代码的一致性：

```bash
"/sync --audit"  # 全量审计模式
```

## 相关资源

- [Librarian Agent](../../agents/librarian.md)
- [Spec 模板](../../templates/spec-template.md)
- [Codemap 规范](../../templates/codemap-template.md)
