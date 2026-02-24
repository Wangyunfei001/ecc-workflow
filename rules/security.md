---
description: 安全规范
alwaysApply: false
---

# 安全规范

代码安全必须遵守的规范和检查清单。

## OWASP Top 10 防护

### A01 访问控制失效

```typescript
// ✅ Good - 验证权限
app.delete('/api/posts/:id', authenticate, async (req, res) => {
  const post = await getPost(req.params.id);
  if (post.authorId !== req.user.id && !req.user.isAdmin) {
    throw new ForbiddenError('无权删除');
  }
  await deletePost(req.params.id);
});

// ❌ Bad - 缺少权限检查
app.delete('/api/posts/:id', async (req, res) => {
  await deletePost(req.params.id);  // 任何人都能删除
});
```

### A02 加密失败

```typescript
// ✅ Good - 使用强加密
import bcrypt from 'bcrypt';

const hash = await bcrypt.hash(password, 12);
const isValid = await bcrypt.compare(input, hash);

// ❌ Bad - 弱加密或明文
const hash = md5(password);  // MD5 不安全
await db.insert({ password });  // 明文存储
```

### A03 注入

```typescript
// ✅ Good - 参数化查询
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ❌ Bad - SQL 注入风险
const user = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

### A04 不安全设计

```typescript
// ✅ Good - 速率限制
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use('/api/', limiter);

// ✅ Good - 输入验证
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});
```

### A05 安全配置错误

```typescript
// ✅ Good - 安全 Headers
app.use(helmet());

// ✅ Good - CORS 配置
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true
}));

// ❌ Bad - 宽松 CORS
app.use(cors({ origin: '*' }));
```

### A06 组件漏洞

```bash
# 定期检查依赖漏洞
npm audit

# 自动修复
npm audit fix

# CI 中阻止高危漏洞
npm audit --audit-level=high
```

### A07 认证失败

```typescript
// ✅ Good - 安全的 Session
app.use(session({
  secret: process.env.SESSION_SECRET,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 24 * 60 * 60 * 1000  // 24 小时
  }
}));

// ✅ Good - 登录失败限制
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: '尝试次数过多'
});
```

### A08 完整性失败

```typescript
// ✅ Good - 验证请求来源
app.use(csrf());

// ✅ Good - 签名验证
function verifyWebhook(payload: string, signature: string) {
  const expected = crypto
    .createHmac('sha256', WEBHOOK_SECRET)
    .update(payload)
    .digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected)
  );
}
```

### A09 日志失败

```typescript
// ✅ Good - 安全日志
logger.info('User login', {
  userId: user.id,
  ip: req.ip,
  userAgent: req.headers['user-agent']
});

// ✅ Good - 敏感数据脱敏
logger.info('Payment processed', {
  userId: user.id,
  cardLast4: card.number.slice(-4),  // 只记录后 4 位
  amount: payment.amount
});

// ❌ Bad - 记录敏感信息
logger.info('Login', { email, password });  // 泄露密码
```

### A10 SSRF

```typescript
// ✅ Good - 验证 URL
function isAllowedUrl(url: string): boolean {
  const parsed = new URL(url);
  const allowedHosts = ['api.example.com', 'cdn.example.com'];
  return allowedHosts.includes(parsed.hostname);
}

// ❌ Bad - 用户控制的请求
app.get('/fetch', async (req, res) => {
  const response = await fetch(req.query.url);  // SSRF 风险
});
```

## 凭证管理

### 环境变量

```typescript
// ✅ Good - 使用环境变量
const apiKey = process.env.API_KEY;
const dbUrl = process.env.DATABASE_URL;

// ❌ Bad - 硬编码
const apiKey = 'sk-abc123456';
const dbUrl = 'postgres://user:pass@host/db';
```

### .env 文件

```bash
# .env.example (提交到 Git)
API_KEY=
DATABASE_URL=
JWT_SECRET=

# .env (不提交，添加到 .gitignore)
API_KEY=sk-actual-key
DATABASE_URL=postgres://...
JWT_SECRET=...
```

### 密钥轮换

```typescript
// 支持多个密钥，便于轮换
const JWT_SECRETS = process.env.JWT_SECRETS?.split(',') || [];

function verifyToken(token: string): Payload {
  for (const secret of JWT_SECRETS) {
    try {
      return jwt.verify(token, secret);
    } catch {}
  }
  throw new UnauthorizedError('Invalid token');
}
```

## 输入校验

### 服务端校验

```typescript
import { z } from 'zod';

const CreateUserSchema = z.object({
  email: z.string().email('邮箱格式无效'),
  password: z.string()
    .min(8, '密码至少 8 位')
    .regex(/[A-Z]/, '需要大写字母')
    .regex(/[0-9]/, '需要数字'),
  name: z.string().min(2).max(50)
});

app.post('/api/users', async (req, res) => {
  const data = CreateUserSchema.parse(req.body);  // 自动校验
  // ...
});
```

### 输出转义

```vue
<!-- ✅ Good - Vue 模板插值自动转义 -->
<div>{{ userInput }}</div>

<!-- ❌ Bad - v-html 直接渲染用户输入 -->
<div v-html="userInput"></div>

<!-- 如果必须使用 v-html，先消毒 -->
<script setup lang="ts">
import DOMPurify from 'dompurify';
import { computed } from 'vue';

const sanitizedHtml = computed(() => DOMPurify.sanitize(userInput.value));
</script>

<template>
  <div v-html="sanitizedHtml"></div>
</template>
```

## 敏感数据处理

### 数据分类

| 级别 | 数据类型 | 处理要求 |
|------|----------|----------|
| 极高 | 密码、密钥 | 加密存储，不记录日志 |
| 高 | 身份证、银行卡 | 加密存储，脱敏显示 |
| 中 | 邮箱、手机号 | 访问控制，部分脱敏 |
| 低 | 用户名、头像 | 基本访问控制 |

### API 响应过滤

```typescript
// ✅ Good - 只返回必要字段
const user = await getUser(id);
return {
  id: user.id,
  name: user.name,
  email: user.email
};

// ❌ Bad - 返回所有字段
return user;  // 可能包含 passwordHash
```

## 检查清单

### 代码审查安全清单

- [ ] 无硬编码凭证
- [ ] 使用参数化查询
- [ ] 输入已校验
- [ ] 输出已转义
- [ ] 权限已验证
- [ ] 敏感数据已脱敏
- [ ] 错误信息不泄露内部细节
- [ ] 日志不包含敏感信息

### 部署前安全清单

- [ ] 依赖无高危漏洞
- [ ] 环境变量已配置
- [ ] HTTPS 已启用
- [ ] 安全 Headers 已配置
- [ ] CORS 已正确配置
- [ ] Rate Limiting 已启用

## 相关资源

- [Security Reviewer Agent](../agents/security-reviewer.md)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Checklist](https://nodejs.org/en/docs/guides/security/)
