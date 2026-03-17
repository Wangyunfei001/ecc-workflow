---
name: review
description: 执行代码审查。
---

# /review 命令

执行代码审查。

## 用法

```bash
/review                    # 审查最近变更
/review @[文件路径]        # 审查指定文件
/review --staged           # 审查暂存区
/review --spec @[spec]     # 对照 Spec 审查
```

## 示例

```bash
# 审查最近一次提交
/review

# 审查指定文件
/review @src/api/users.ts

# 审查暂存区变更
/review --staged

# 对照 Spec 进行合规性审查
/review --spec @docs/specs/features/user-login.md

# 只做安全审查
/review --security-only

# 快速审查（跳过低优先级）
/review --quick
```

## 执行流程

1. **获取变更**
   ```bash
   git diff --staged      # 或 git diff HEAD~1
   ```

2. **分层审查**
   - 🔴 CRITICAL: 安全漏洞
   - 🟠 HIGH: 代码质量
   - 🟡 MEDIUM: 性能问题
   - 🔵 LOW: 代码风格

3. **Spec 合规检查**（如指定 `--spec`）
   - 字段是否匹配
   - API 响应是否一致
   - 错误码是否正确

4. **输出报告**

## 审查维度

### 🔴 CRITICAL — 安全漏洞

| 检查项 | 说明 |
|--------|------|
| 硬编码凭证 | API keys, passwords, tokens |
| SQL 注入 | 字符串拼接的查询 |
| XSS 漏洞 | 未转义的用户输入 |
| 路径遍历 | 用户控制的文件路径 |

### 🟠 HIGH — 代码质量

| 检查项 | 阈值 |
|--------|------|
| 函数过长 | > 50 行 |
| 文件过大 | > 400 行 |
| 嵌套过深 | > 4 层 |
| 缺少错误处理 | 异步无 try/catch |

### 🟡 MEDIUM — 性能

| 检查项 | 说明 |
|--------|------|
| N+1 查询 | 循环中的 DB 查询 |
| 缺少索引 | 大表无索引查询 |
| 内存泄漏 | 未清理的订阅 |

### 🔵 LOW — 风格

| 检查项 | 说明 |
|--------|------|
| 命名规范 | x, tmp, data |
| 缺少注释 | 复杂逻辑无说明 |
| TODO 无追踪 | 没有关联 issue |

## 输出格式

```markdown
# 代码审查报告

## 📊 概览

| 级别 | 数量 |
|------|------|
| 🔴 CRITICAL | 0 |
| 🟠 HIGH | 2 |
| 🟡 MEDIUM | 1 |
| 🔵 LOW | 3 |

## 🟠 HIGH Issues

### [H-001] 缺少输入校验
**文件:** `src/api/users.ts:42`
**问题:** 用户输入未校验
**修复:**
```typescript
const schema = z.object({
  email: z.string().email()
});
const data = schema.parse(req.body);
```

## ✅ 审查结论

**状态:** ⚠️ NEEDS WORK
**建议:** 修复 H-001、H-002 后重新提交
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--staged` | 审查暂存区 | false |
| `--spec` | 指定对照的 Spec 文件 | - |
| `--security-only` | 只做安全审查 | false |
| `--quick` | 快速模式（跳过 LOW） | false |
| `--output` | 输出报告文件 | - |

## 审查结论

| 状态 | 条件 | 建议 |
|------|------|------|
| ❌ BLOCKED | 有 CRITICAL | 必须修复 |
| ⚠️ NEEDS WORK | 有 HIGH | 建议修复 |
| ✅ APPROVED | 无 CRITICAL/HIGH | 可以合并 |

## 完成后必须输出

当代码审查完成后，**必须**在回复末尾显示以下引导块：

### 审查通过时：

```markdown
---

✅ **代码审查通过**

📊 审查结果: APPROVED
🔴 CRITICAL: 0 | 🟠 HIGH: 0 | 🟡 MEDIUM: [N] | 🔵 LOW: [N]

👉 **下一步操作**:
1. 运行 `/sync` 同步文档（确保代码与文档一致）
2. 提交代码或创建 PR
```

### 审查未通过时：

```markdown
---

⚠️ **代码审查未通过**

📊 审查结果: NEEDS WORK
🔴 CRITICAL: [N] | 🟠 HIGH: [N]

👉 **下一步操作**:
1. 根据上方审查报告修复 [列出关键问题编号]
2. 修复后重新运行 `/review`
```

> **⚠️ 规则**: 此引导块为强制输出项，不可省略。

## 相关命令

- `/implement` - 实现代码
- `/sync` - 文档同步
- `/security` - 专项安全审查
