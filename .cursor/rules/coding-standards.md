---
description: 编码规范
alwaysApply: false
---

# 编码规范

全局编码规范，所有代码变更必须遵守。

## TypeScript/JavaScript

### 文件组织

```typescript
// 1. 导入顺序
import { external } from 'external-lib';     // 外部库
import { internal } from '@/internal';       // 内部模块
import { local } from './local';             // 本地文件
import type { Types } from './types';        // 类型导入（最后）

// 2. 文件大小限制
// - 单文件不超过 400 行
// - 单函数不超过 50 行
// - 嵌套不超过 4 层
```

### 命名规范

```typescript
// ✅ Good
const userProfile = {};           // camelCase 变量
const MAX_RETRY_COUNT = 3;        // UPPER_CASE 常量
interface UserProfile {}          // PascalCase 类型/接口
function getUserById() {}         // camelCase 函数
const handleClick = () => {};     // handle* 事件处理

// ❌ Bad
const user_profile = {};          // 不使用 snake_case
const maxRetryCount = 3;          // 常量应该 UPPER_CASE
function get_user() {}            // 不使用 snake_case
```

### 类型定义

```typescript
// ✅ Good - 显式类型
function getUser(id: string): Promise<User | null> {
  // ...
}

// ✅ Good - 使用 type 或 interface
interface User {
  id: string;
  email: string;
}

// ❌ Bad - 使用 any
function process(data: any) {}

// ❌ Bad - 隐式 any
function getUser(id) {}
```

### 错误处理

```typescript
// ✅ Good - 显式错误处理
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await api.get(`/users/${id}`);
    return response.data;
  } catch (error) {
    if (error instanceof NotFoundError) {
      throw new UserNotFoundError(id);
    }
    logger.error('Failed to fetch user', { id, error });
    throw new InternalError('Failed to fetch user');
  }
}

// ❌ Bad - 忽略错误
async function fetchUser(id: string) {
  const response = await api.get(`/users/${id}`);  // 未处理异常
  return response.data;
}
```

### 不可变性

```typescript
// ✅ Good - 使用 const 和展开运算符
const updatedUser = { ...user, name: 'New Name' };
const newArray = [...array, newItem];

// ❌ Bad - 直接修改
user.name = 'New Name';
array.push(newItem);
```

## Vue 3

### SFC 组件结构

```vue
<script setup lang="ts">
// 1. 导入
import { ref, computed, onMounted } from 'vue';

// 2. 类型定义
interface Props {
  label: string;
  disabled?: boolean;
}

interface Emits {
  (e: 'click'): void;
}

// 3. Props / Emits
const props = withDefaults(defineProps<Props>(), {
  disabled: false,
});

const emit = defineEmits<Emits>();

// 4. 响应式状态
const isLoading = ref(false);

// 5. 计算属性
const isDisabled = computed(() => props.disabled || isLoading.value);

// 6. 事件处理
function handleClick() {
  isLoading.value = true;
  emit('click');
}

// 7. 生命周期
onMounted(() => {
  // ...
});
</script>

<template>
  <button :disabled="isDisabled" @click="handleClick">
    {{ props.label }}
  </button>
</template>

<style scoped>
/* 组件私有样式 */
</style>
```

### 性能优化

```typescript
import { computed, shallowRef, triggerRef } from 'vue';

// ✅ Good - 使用 computed 缓存派生状态
const processedData = computed(() => {
  return expensiveProcess(data.value);
});

// ✅ Good - 使用 shallowRef 避免深层响应式
const largeList = shallowRef<Item[]>([]);

// ✅ Good - 使用 v-once 标记静态内容
// <div v-once>{{ staticContent }}</div>

// ✅ Good - 使用 defineAsyncComponent 懒加载
const HeavyComponent = defineAsyncComponent(
  () => import('./HeavyComponent.vue')
);
```

## API 设计

### 端点命名

```
# ✅ Good - RESTful 风格
GET    /api/users          # 列表
POST   /api/users          # 创建
GET    /api/users/:id      # 详情
PUT    /api/users/:id      # 更新
DELETE /api/users/:id      # 删除

# ❌ Bad
GET    /api/getUsers
POST   /api/createUser
GET    /api/user/get/:id
```

### 响应格式

```typescript
// ✅ Good - 统一响应格式
interface ApiResponse<T> {
  data: T;
  meta?: {
    total?: number;
    page?: number;
  };
}

interface ApiError {
  code: string;      // 机器可读
  message: string;   // 人类可读
  details?: object;  // 详细信息
}

// 成功响应
{ "data": { "id": "1", "name": "John" } }

// 错误响应
{ "code": "VALIDATION_ERROR", "message": "Email is required" }
```

## 数据库

### 查询优化

```typescript
// ✅ Good - 批量查询
const userIds = orders.map(o => o.userId);
const users = await db.query(
  'SELECT * FROM users WHERE id = ANY($1)',
  [userIds]
);

// ❌ Bad - N+1 查询
for (const order of orders) {
  const user = await db.query(
    'SELECT * FROM users WHERE id = $1',
    [order.userId]
  );
}
```

### 参数化查询

```typescript
// ✅ Good - 参数化
const users = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// ❌ Bad - 字符串拼接（SQL 注入风险）
const users = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`
);
```

## 测试

### 测试文件组织

```
src/
├── components/
│   ├── Button.vue
│   └── __tests__/
│       └── Button.test.ts   # 同组件目录下
└── __tests__/
    └── integration/          # 集成测试
```

### 测试命名

```typescript
describe('UserService', () => {
  describe('getUser', () => {
    it('should return user when found', async () => {});
    it('should throw NotFoundError when user not found', async () => {});
    it('should handle database connection error', async () => {});
  });
});
```

## Git

### Commit 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type:**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响逻辑）
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建/工具

**示例:**
```
feat(auth): add password reset flow

- Add forgot password page
- Add reset password API
- Add email notification

Closes #123
```

## 禁止事项

```typescript
// ❌ 禁止 console.log（生产代码）
console.log('debug');  // 使用 logger

// ❌ 禁止硬编码凭证
const apiKey = 'sk-xxx';  // 使用环境变量

// ❌ 禁止 any 类型
function process(data: any) {}  // 使用具体类型

// ❌ 禁止魔法数字
if (status === 1) {}  // 使用常量或枚举

// ❌ 禁止嵌套三元运算符
const x = a ? b ? c : d : e;  // 使用 if/else

// ❌ 禁止 emoji（代码/注释中）
// 🚀 这是一个函数  // 不要这样
```

## 检查工具

```bash
# TypeScript 类型检查
tsc --noEmit

# ESLint
eslint . --ext .ts,.vue

# Prettier
prettier --check .

# 测试 (Vitest)
npx vitest run --coverage
```
