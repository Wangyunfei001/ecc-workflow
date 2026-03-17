---
description: 质量门禁
alwaysApply: false
---

# 质量门禁

代码合并前必须通过的质量检查。

## 门禁级别

### Level 1: 阻塞（必须通过）

| 检查项 | 工具 | 阈值 |
|--------|------|------|
| TypeScript 编译 | `tsc --noEmit` | 0 错误 |
| ESLint 错误 | `eslint` | 0 error |
| 单元测试 | `npm test` | 100% 通过 |
| 安全漏洞 | `npm audit` | 0 critical/high |

### Level 2: 警告（建议修复）

| 检查项 | 工具 | 阈值 |
|--------|------|------|
| ESLint 警告 | `eslint` | < 10 warning |
| 测试覆盖率 | `jest --coverage` | > 80% |
| 复杂度 | `eslint complexity` | < 15 |
| 依赖漏洞 | `npm audit` | 0 moderate |

### Level 3: 提示（可选修复）

| 检查项 | 工具 | 阈值 |
|--------|------|------|
| 代码格式 | `prettier` | 统一格式 |
| 拼写检查 | `cspell` | 无明显错误 |
| TODO 注释 | grep | 关联 issue |

## 检查命令

### 完整检查

```bash
# 运行所有检查
npm run check

# 等效于
vue-tsc --noEmit && \
eslint . --ext .ts,.vue && \
npx vitest run --coverage && \
npm audit
```

### 快速检查

```bash
# 只检查变更文件
npm run check:staged

# 等效于
lint-staged
```

### 单项检查

```bash
# 类型检查
npm run typecheck

# Lint 检查
npm run lint

# 测试
npm test

# 安全检查
npm audit
```

## CI/CD 集成

### GitHub Actions

```yaml
name: Quality Gates

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          
      - name: Install
        run: npm ci
        
      - name: TypeScript
        run: npm run typecheck
        
      - name: Lint
        run: npm run lint
        
      - name: Test
        run: npm test -- --coverage
        
      - name: Security
        run: npm audit --audit-level=high
        
      - name: Coverage Report
        uses: codecov/codecov-action@v4
```

### Pre-commit Hook

```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm run check"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

## Spec 合规检查

### 检查内容

1. **数据模型一致性**
   - 代码中的 Interface 与 Spec 定义匹配
   - 字段类型、必填性一致

2. **API 合规性**
   - 端点路径与 Spec 一致
   - 请求/响应格式与 Spec 一致
   - 错误码与 Spec 一致

3. **业务逻辑**
   - 验证规则符合 Spec
   - 边界条件处理符合 Spec

### 检查命令

```bash
# 对照 Spec 检查代码
/review --spec @docs/specs/features/xxx.md
```

## 审查清单

### 代码审查

- [ ] 符合编码规范
- [ ] 无安全漏洞
- [ ] 有充分测试
- [ ] 文档已更新

### PR 审查

- [ ] PR 描述清晰
- [ ] 关联 Issue/Spec
- [ ] CI 检查通过
- [ ] 至少 1 人 approve

### 发布审查

- [ ] 所有测试通过
- [ ] 无 critical 漏洞
- [ ] 文档同步
- [ ] 回滚方案就绪

## 豁免流程

### 紧急修复

```markdown
## 豁免申请

**PR:** #123
**原因:** 生产环境紧急修复
**豁免项:** 测试覆盖率 (当前 65%, 阈值 80%)
**承诺:** 48 小时内补充测试
**审批人:** @tech-lead
```

### 技术债务

```markdown
## 技术债务记录

**文件:** src/legacy/old-module.ts
**问题:** 复杂度超标 (20, 阈值 15)
**原因:** 历史代码，重构成本高
**计划:** Q2 重构
**跟踪:** TECH-456
```

## 报告格式

```markdown
# 质量门禁报告

## 📊 概览

| 检查项 | 状态 | 详情 |
|--------|------|------|
| TypeScript | ✅ | 0 errors |
| ESLint | ✅ | 0 errors, 3 warnings |
| Tests | ✅ | 45/45 passed |
| Coverage | ⚠️ | 78% (阈值 80%) |
| Security | ✅ | 0 vulnerabilities |

## ❌ 阻塞项

无

## ⚠️ 警告项

### 测试覆盖率不足

当前: 78%
阈值: 80%
差距: 2%

未覆盖文件:
- src/utils/helpers.ts (60%)

## ✅ 结论

**状态:** 通过（有警告）
**建议:** 补充 helpers.ts 的测试后合并
```

## 相关配置

- [ESLint 配置](../../.eslintrc.js)
- [TypeScript 配置](../../tsconfig.json)
- [Jest 配置](../../jest.config.js)
- [Prettier 配置](../../.prettierrc)
