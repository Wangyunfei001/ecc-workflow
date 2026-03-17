---
name: implement
description: 基于 Spec 文档实现代码。
---

# /implement 命令

基于 Spec 文档实现代码。

## 用法

```bash
/implement @[spec文件路径]
```

## 示例

```bash
# 基于 Spec 实现
/implement @docs/specs/features/user-login.md

# 实现部分功能
/implement @docs/specs/features/user-login.md --only "API"

# 跳过测试
/implement @docs/specs/features/user-login.md --skip-tests
```

## 前置条件

1. **Spec 状态必须为 `approved`**
   - `status: draft` → 拒绝执行
   - `status: review` → 拒绝执行
   - `status: approved` → 开始实现

2. **Spec 结构完整**
   - 必须包含数据模型定义
   - 必须包含 API 或组件定义

## 执行流程

1. **加载 Spec**
   - 读取指定的 Spec 文件
   - 验证状态为 `approved`
   - 提取实现清单

2. **逐项实现**
   - 使用 `@strict-coder` Agent
   - 严格按 Spec 定义实现
   - 遇到不明确处暂停询问

3. **添加测试**
   - 按 Spec 测试策略添加测试
   - 运行测试确认通过

4. **报告进度**
   - 显示实现进度
   - 列出变更文件
   - 提示下一步

## TaskGraph 协议（推荐）

`/implement` 应以 Spec 产物为输入，按“实现 -> 测试 -> 报告”闭环执行。

```yaml
workflow_id: wf-implement-from-spec
goal: "按 approved spec 实现并验证"
tasks:
  - id: T0
    name: validate_spec_gate
    owner: strict-coder
    depends_on: []
    parallelizable: false
    done_criteria:
      - "spec status = approved"
      - "spec 结构完整"
  - id: T1
    name: build_implementation_plan
    owner: strict-coder
    depends_on: [T0]
    parallelizable: false
  - id: T2
    name: implement_items
    owner: strict-coder
    depends_on: [T1]
    parallelizable: true
  - id: T3
    name: add_and_run_tests
    owner: strict-coder
    depends_on: [T2]
    parallelizable: false
  - id: T4
    name: publish_progress_report
    owner: strict-coder
    depends_on: [T3]
    parallelizable: false
merge:
  after: [T2]
  strategy: all_must_pass
```

## 核心原则

### 严格模式

```typescript
// ✅ Spec 定义什么，就实现什么
interface User {
  id: string;
  email: string;
}

// ❌ 不允许自作主张添加
interface User {
  id: string;
  email: string;
  avatar?: string;  // Spec 没有！
}
```

### 遇惑则问

```markdown
⚠️ **Spec 缺失提醒**

在实现 `POST /api/users` 时发现：
1. 密码加密方式未指定 → 建议 bcrypt，确认？
2. 邮箱校验规则未明确 → 建议 RFC 5322，确认？
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--only` | 只实现指定部分 | 全部 |
| `--skip-tests` | 跳过测试 | false |
| `--dry-run` | 只显示计划，不执行 | false |

## 输出示例

```markdown
## 实现进度 [3/5]

### ✅ 已完成
1. User interface - `src/types/user.ts`
2. UserStatus enum - `src/types/user.ts`
3. POST /api/users - `src/api/users.ts`

### 🔄 当前
4. GET /api/users/:id

### ⏳ 待完成
5. LoginForm component

### 📝 变更清单
- 新增: `src/types/user.ts`
- 新增: `src/api/users.ts`
- 修改: `src/api/index.ts`
```

## 错误处理

### Spec 未批准

```
❌ 错误：Spec 状态为 "draft"，不允许实现

请先完成审查并将 status 改为 "approved"：
1. 打开 docs/specs/features/user-login.md
2. 审查内容
3. 修改 status: approved
4. 重新运行 /implement
```

### Spec 结构不完整

```
❌ 错误：Spec 缺少必要章节

缺失：
- 4. API 设计
- 6. 边界情况

请补充后重试。
```

## 完成后必须输出

当代码实现完成后，**必须**在回复末尾显示以下引导块：

```markdown
---

✅ **代码实现完成**

📝 变更文件: [列出新增和修改的文件]
🧪 测试状态: [X/Y 通过]

👉 **下一步操作**:
1. 运行 `/review` 进行代码审查（检查质量和安全）
2. 审查通过后运行 `/sync` 同步文档
3. 最后提交代码或创建 PR
```

> **⚠️ 规则**: 此引导块为强制输出项，不可省略。

## 相关命令

- `/spec` - 生成 Spec 文档
- `/review` - 代码审查
- `/sync` - 文档同步
