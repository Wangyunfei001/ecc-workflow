---
name: sync
description: 同步文档与代码。
---

# /sync 命令

同步文档与代码。

## 用法

```bash
/sync                      # 同步最近变更
/sync @[spec文件]          # 同步指定 Spec
/sync --audit              # 全量审计模式
/sync --dry-run            # 只显示需要同步的内容
```

## 示例

```bash
# 同步最近代码变更到文档
/sync

# 同步指定 Spec
/sync @docs/specs/features/user-login.md

# 全量审计（检查所有文档）
/sync --audit

# 预览模式
/sync --dry-run

# 强制同步（跳过确认）
/sync --force
```

## 执行流程

1. **检测变更**
   ```bash
   git diff HEAD~1 --name-only
   ```

2. **分析变更**
   - 识别变更类型（类型/API/组件）
   - 定位相关文档

3. **执行同步**
   - 更新 Spec 文档
   - 更新 Codemap
   - 追加变更日志

4. **生成报告**

## 同步规则

### 代码 → 文档映射

| 代码变更 | 文档更新 | 自动/确认 |
|----------|----------|-----------|
| 新增 Interface | Spec 数据模型 | 自动 |
| 新增 API | Spec API 设计 | 自动 |
| 修改 API 响应 | Spec API 设计 | 自动 |
| 删除字段 | Spec 对应章节 | 需确认 |
| 类型变更 | Spec 对应章节 | 需确认 |
| 文件结构变化 | CODEMAPS | 自动 |

### 需要人工确认的场景

```markdown
⚠️ **需要确认**

检测到以下变更可能是破坏性变更（Breaking Change）：

1. **删除字段: User.avatar**
   - 是否从 Spec 中移除？ [Y/n]

2. **类型变更: status string → enum**
   - 是否更新 Spec？ [Y/n]
```

## 输出格式

```markdown
# 文档同步报告

## 📊 概览

**触发:** Commit abc123 - "feat: add user update"
**时间:** 2026-02-02 15:30
**同步:** 2 个文档

## 📝 变更详情

### docs/specs/features/user.md
- ✅ 更新数据模型
- ✅ 添加 PUT 端点
- ✅ 追加变更日志

### docs/CODEMAPS/overview.md
- ✅ 更新模块结构

## ✅ 同步完成
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--audit` | 全量审计 | false |
| `--dry-run` | 预览模式 | false |
| `--force` | 跳过确认 | false |
| `--output` | 输出报告 | - |

## 冲突处理

### 代码与 Spec 不一致

```markdown
⚠️ **发现不一致**

| 项目 | Spec | 代码 |
|------|------|------|
| User.email | required | optional |

选择处理方式:
1. 更新 Spec（代码正确）
2. 报告问题（代码需修改）
3. 人工介入
```

### 文档不存在

```markdown
📝 **缺少对应文档**

代码 `src/api/payments.ts` 没有 Spec。

建议运行:
/spec @src/api/payments.ts --reverse
```

## 最佳实践

### 1. 养成习惯

每次完成代码变更后运行 `/sync`。

### 2. 定期审计

```bash
# 每周运行一次全量审计
/sync --audit
```

### 3. CI 集成

```yaml
# .github/workflows/doc-check.yml
- name: Check doc sync
  run: /sync --dry-run --strict
```

## 完成后必须输出

当文档同步完成后，**必须**在回复末尾显示以下引导块：

```markdown
---

✅ **文档同步完成**

📄 已同步: [列出更新的文档]
📝 变更日志: 已追加

👉 **下一步操作**:
1. 在 Obsidian 中查看更新的文档
2. 确认变更日志正确
3. 提交文档变更（`git add docs/ && git commit`）
4. 如需全量检查，运行 `/sync --audit`
```

> **⚠️ 规则**: 此引导块为强制输出项，不可省略。

## 相关命令

- `/review` - 代码审查
- `/spec` - 生成 Spec
- `/audit` - 全量文档审计
