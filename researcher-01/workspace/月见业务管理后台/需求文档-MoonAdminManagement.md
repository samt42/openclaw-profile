# Moon Admin Management - 需求文档

## 1. 项目概述

### 1.1 基本信息
- **项目名称**: Moon Admin Management（月见管理后台）
- **技术栈**: Vue 3 + TypeScript + Vite + Element Plus + Tailwind CSS
- **项目类型**: 后台管理系统（B端）
- **目标用户**: 运营人员、管理员

### 1.2 系统定位
为"月见"系列App（塔罗/星座类应用）提供运营管理支持的后台系统，涵盖用户管理、权益配置、内容发布、数据统计等核心功能。

---

## 2. 系统架构

### 2.1 前端技术架构
| 技术/库 | 版本 | 用途 |
|---------|------|------|
| Vue | 3.4.15 | 核心框架 |
| TypeScript | 5.3.3 | 类型系统 |
| Vite | 5.0.12 | 构建工具 |
| Element Plus | 2.13.0 | UI组件库 |
| Pinia | 3.0.4 | 状态管理 |
| Vue Router | 4.2.5 | 路由管理 |
| Axios | 1.13.2 | HTTP请求 |
| Tailwind CSS | 3.4.1 | 原子CSS |
| Lucide Vue | 0.511.0 | 图标库 |

### 2.2 项目结构
```
src/
├── api/              # API接口封装
├── components/       # 公共组件
├── composables/      # 组合式函数
├── config/           # 配置文件
├── layout/           # 布局组件
├── lib/              # 工具函数
├── router/           # 路由配置
├── store/            # Pinia状态管理
├── utils/            # 工具函数
└── views/            # 页面视图
    ├── benefit/      # 权益管理
    ├── dashboard/    # 首页仪表盘
    ├── login/        # 登录页
    ├── message/      # 站内信管理
    ├── role/         # 角色管理
    ├── scene/        # 场景探索
    ├── statistics/   # 数据统计
    ├── system/       # 系统管理
    └── user/         # 用户管理
```

---

## 3. 功能模块详解

### 3.1 登录认证模块

#### 3.1.1 功能描述
- 管理员账号密码登录
- Token认证机制
- 用户信息本地缓存

#### 3.1.2 接口定义
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 登录 | POST | `/admin/auth/login` | 账号密码登录 |
| 获取用户信息 | GET | `/admin/info` | 获取当前登录用户信息 |
| 登出 | - | 本地清除 | 清除localStorage中的用户缓存 |

#### 3.1.3 数据模型
```typescript
interface LoginPayload {
  username: string;
  password: string;
}

interface LoginData {
  token: string;
  user?: {
    id: number;
    username: string;
  };
}
```

---

### 3.2 首页仪表盘 (Dashboard)

#### 3.2.1 功能描述
- 欢迎语（根据时间段动态显示）
- 当前日期时间实时显示
- 快捷功能入口导航
- 用户角色展示

#### 3.2.2 核心功能入口
| 入口名称 | 路径 | 描述 |
|----------|------|------|
| 权益配置 | /benefit/assign | 用户权益分配与调整 |
| Dify切换 | /system/dify | 切换系统AI引擎配置 |
| 站内信管理 | /system/messages | 发布与管理系统通知 |
| 新版-收入统计 | /statistics/new-income | 多维度收入数据分析 |

---

### 3.3 用户管理模块

#### 3.3.1 功能描述
- 用户列表查询（预留功能，当前使用Mock数据）
- 用户创建
- 用户编辑
- 用户详情查看
- 用户状态管理（启用/禁用）

#### 3.3.2 页面列表
| 页面 | 路径 | 说明 |
|------|------|------|
| 用户列表 | /user/list | 展示用户列表 |
| 创建用户 | /user/create | 新增用户 |
| 编辑用户 | /user/edit/:id | 编辑用户信息 |
| 用户详情 | /user/detail/:id | 查看用户详情 |

#### 3.3.3 数据模型
```typescript
interface UserItem {
  id: number;
  username: string;
  email: string;
  mobile: string;
  status: number; // 0: 禁用, 1: 启用
  createTime: string;
}
```

---

### 3.4 角色管理模块

#### 3.4.1 功能描述
- 角色列表查询（预留功能，当前使用Mock数据）
- 角色创建
- 角色编辑
- 角色删除
- 权限分配

#### 3.4.2 页面列表
| 页面 | 路径 | 说明 |
|------|------|------|
| 角色列表 | /role/list | 展示角色列表 |
| 权限分配 | /role/assign | 为角色分配权限 |

#### 3.4.3 数据模型
```typescript
interface RoleItem {
  id: number;
  name: string;
  description: string;
  createTime: string;
}
```

---

### 3.5 权益管理模块

#### 3.5.1 功能描述
**权益配置**（核心功能）
- 通过手机号/邀请码/用户ID查询用户权益信息
- 查看用户详细信息（基础资料、星座信息、权益库存）
- 为用户增加"解惑之钥"（使用次数）
- 为用户开通VIP会员（周度/月度/年度）

**权益列表**（预留功能）
- VIP/SVIP会员卡管理
- 次数包管理

**补偿机制**
- 批量补偿功能

#### 3.5.2 页面列表
| 页面 | 路径 | 说明 |
|------|------|------|
| 权益列表 | /benefit/list | 权益套餐列表（预留） |
| 权益配置 | /benefit/assign | 用户权益配置（核心） |
| 补偿机制 | /benefit/compensate | 批量补偿功能 |

#### 3.5.3 接口定义
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 查询用户权益 | GET | `/user/stock/getUserStockInfo` | 查询用户权益信息 |
| 增加解惑之钥 | GET | `/user/stock/add` | 增加用户解惑之钥数量 |
| 开通会员 | GET | `/user/stock/open` | 开通VIP/SVIP会员 |
| 批量补偿 | POST | `/admin/compensate/number` | 批量补偿用户权益 |

#### 3.5.4 数据模型
```typescript
interface UserDTO {
  userId: number;
  appleUserId: string | null;
  openId: string | null;
  unionId: string | null;
  phone: string | null;
  userPicture: string | null;
  userName: string | null;
  sex: number | null; // 1:男, 2:女
  age: number | null;
  birthDay: string | null;
  birthTime: string | null;
  timezone: string | null;
  birthProvince: string | null;
  birthCity: string | null;
  birthCounty: string | null;
  longitude: string | null;
  latitude: string | null;
  constellation: string | null;
  newConstellation: string | null;
  constellationNum: number | null;
  job: string | null;
  mbti: string | null;
  createTime: string | null;
  channel: string | null; // 手机品牌
  calendarType: number | null; // 0:阳历, 1:阴历
  relationshipStatus: string | null;
  residenceProvince: string | null;
  residenceCity: string | null;
  residenceCounty: string | null;
  residenceLongitude: string | null;
  residenceLatitude: string | null;
  residenceTimezone: string | null;
  inviteCode: string | null;
}

interface UserStockInfo {
  freeTimes: number; // 剩余免费次数
  totalNumber: number; // 剩余解惑之钥
  isVip: number; // 0:非VIP, 1:月度VIP, 2:年度VIP, 5:周度VIP
  vipExpireTime: string | null;
  svipExpireTime: string | null;
  createTime: string | null;
  chartNumber: number | null;
  friendChartNumber: number | null;
  userId: number;
  astrolabeNumber: number; // 剩余星盘卡
  userDTO?: UserDTO | null;
}
```

---

### 3.6 场景探索模块

#### 3.6.1 功能描述
- 场景探索列表查询
- 场景详情查看
- 场景创建
- 场景编辑
- 场景状态管理（上线/下线/删除）
- 支持搜索和状态筛选

#### 3.6.2 页面列表
| 页面 | 路径 | 说明 |
|------|------|------|
| 场景列表 | /system/scene | 场景探索列表 |
| 新建场景 | /system/scene/create | 创建/编辑场景 |

#### 3.6.3 接口定义
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 查询场景列表 | GET | `/scenarios/list` | 获取所有场景 |
| 查询场景详情 | GET | `/scenarios/{id}` | 获取单个场景详情 |
| 创建场景 | POST | `/scenarios` | 新建场景 |
| 更新场景 | PUT | `/scenarios/{id}` | 更新场景信息 |

#### 3.6.4 数据模型
```typescript
interface SceneDetail {
  id: string;
  title: string;
  summary: string;
  content: string;
  background: string;
  status: number; // 0:下线, 1:上线, -1:已删除
  privilege: string; // 0:所有用户, 1:vip, 2:svip
  recommendQueries: (string | { query: string })[];
  recommendTools: Array<{
    id: string;
    type: string;
    name: string;
  }>;
}

interface SceneListItem {
  id: string;
  title: string;
  summary: string;
  background: string;
  status: number;
  privilege?: string;
  toolType?: string;
  name?: string;
  toolName?: string;
  recommendTools?: Array<{ name: string }>;
}
```

---

### 3.7 站内信管理模块

#### 3.7.1 功能描述
- 站内信列表查询
- 站内信详情查看
- 新建站内信
- 支持多种发送类型：群发/单发/特殊发送
- 支持多种交互类型：无交互/跳转详情/跳转H5
- 支持消息类型：系统通知/活动消息/个人消息
- 站内信过期状态管理

#### 3.7.2 页面列表
| 页面 | 路径 | 说明 |
|------|------|------|
| 站内信列表 | /system/messages | 站内信管理列表 |
| 新建站内信 | /system/messages/create | 创建站内信 |

#### 3.7.3 接口定义
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取站内信列表 | GET | `/messages` | 获取所有站内信 |
| 获取站内信详情 | GET | `/message/details` | 获取单条站内信详情 |
| 添加站内信 | POST | `/add/message` | 创建新站内信 |
| 更新站内信 | POST | `/update/message` | 更新站内信 |

#### 3.7.4 数据模型
```typescript
interface MessageDetailItem {
  title: string;
  content: string[];
  images: string[];
}

interface MessageItem {
  messageId: number;
  interactType: number; // 0:无交互, 1:跳转详情页, 2:跳转H5
  messageType: string; // "0":系统通知, "1":活动消息, "2":个人消息
  sendType: number; // 0:群发, 1:单发, 2:特殊发送
  messageContent: string;
  hurl: string | null; // H5链接
  imageUrl: string | null;
  detailDTOList: MessageDetailItem[];
  expireStatus: number; // 0:未过期, 1:过期
  createTime: string;
  channel: string | null; // 手机品牌
  userIdList?: string[]; // 单发模式用户ID列表
}
```

---

### 3.8 数据统计模块

#### 3.8.1 功能描述
**收入统计（旧版）**
- 实时数据统计
- 渠道数据统计（按手机品牌）
- 新用户数、总收入、新用户收入、ARPU等指标

**新版收入统计**
- 多维度数据分析
- 支持按小时/天/周/月/年粒度统计
- 支持多维度筛选
- 支持多指标聚合

#### 3.8.2 页面列表
| 页面 | 路径 | 说明 |
|------|------|------|
| 收入统计 | /statistics/income | 旧版收入统计 |
| 新版-收入统计 | /statistics/new-income | 新版多维度统计 |

#### 3.8.3 接口定义
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取实时数据 | POST | `/queryRealTimeData` | 获取实时统计数据 |
| 统计接口 | POST | `/statistic` | 新版多维度统计 |

#### 3.8.4 数据模型
```typescript
// 旧版统计
interface BrandData {
  newUserCount: number;
  totalIncome: number;
  newUserIncome: number;
  newUserArpu: number;
  brand: string;
}

interface StatisticsData {
  newUserCount: number;
  totalIncome: number;
  newUserIncome: number;
  newUserArpu: number;
  brandRealTimeDataVos: BrandData[];
  totalIncomeThisMonth: number;
}

// 新版统计
interface StatisticQueryParams {
  business: string;
  timeRange: {
    startTime: string;
    endTime: string;
  };
  granularity: "hour" | "day" | "week" | "month" | "year";
  dimensions: string[];
  metrics: {
    field: string;
    aggregation: string;
    alias: string;
  }[];
  filters: {
    field: string;
    operator: string;
    value: string;
  }[];
}

interface SummaryData {
  payment_count: number;
  payment_sum: number;
}
```

---

### 3.9 系统管理模块

#### 3.9.1 菜单管理
- 菜单列表展示
- 菜单权限配置（预留功能）

#### 3.9.2 Dify切换（AI引擎配置）
- 查看不同应用/环境的Dify服务地址
- 支持6个端点：
  - 月见App-线上/测试
  - 月见塔罗-线上/测试
  - 百度H5-线上/测试
- 支持普通用户和VIP用户的不同配置
- 切换服务地址（saasDify/aliDifyOne/aliDifyTwo）

**接口定义**
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 查询Dify地址 | GET | `/admin/find/dify/url` | 获取当前Dify配置 |
| 更新Dify地址 | GET | `/admin/update/dify/url` | 切换Dify服务 |

**数据模型**
```typescript
interface DifyUrlData {
  vipStatus: number; // 0:普通, 1:VIP
  url: string;
}
```

#### 3.9.3 版本控制
- iOS/Android版本管理
- 版本阈值设置
- 强制更新区间配置
- 更新日志管理
- 下载地址配置

**接口定义**
| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取版本列表 | GET | `/find/app/version` | 获取所有版本信息 |
| 更新版本 | PUT | `/app/version` | 更新版本配置 |

**数据模型**
```typescript
interface VersionInfo {
  isUpdate?: number | null;
  newForceUpdate?: number | null;
  newVersionName: string; // 版本阈值
  newVersionDownloadUrl: string;
  newVersionUpdateContent: string;
  forceMinVersion: string;
  forceMaxVersion: string;
  terminalType: number; // 1:iOS, 2:安卓
}
```

---

## 4. 路由结构

```typescript
const routes = [
  { path: "/login", component: Login },
  {
    path: "/",
    component: Layout,
    redirect: "/dashboard",
    children: [
      { path: "dashboard", name: "Dashboard", meta: { title: "首页" } },
      {
        path: "user",
        meta: { title: "用户管理(预留)" },
        children: [
          { path: "list", name: "UserList", meta: { title: "用户列表" } },
          { path: "create", name: "CreateUser", meta: { title: "创建用户" } },
          { path: "edit/:id", name: "EditUser", meta: { title: "编辑用户", hidden: true } },
          { path: "detail/:id", name: "UserDetail", meta: { title: "用户详情", hidden: true } },
        ],
      },
      {
        path: "role",
        meta: { title: "角色管理(预留)" },
        children: [
          { path: "list", name: "RoleList", meta: { title: "角色列表" } },
          { path: "assign", name: "RoleAssign", meta: { title: "权限分配" } },
        ],
      },
      {
        path: "benefit",
        meta: { title: "权益管理" },
        children: [
          { path: "list", name: "BenefitList", meta: { title: "权益列表(预留)" } },
          { path: "assign", name: "BenefitAssign", meta: { title: "权益配置" } },
          { path: "compensate", name: "BenefitCompensate", meta: { title: "补偿机制" } },
        ],
      },
      {
        path: "statistics",
        meta: { title: "数据统计" },
        children: [
          { path: "income", name: "IncomeStatistics", meta: { title: "收入统计" } },
          { path: "new-income", name: "NewIncomeStatistics", meta: { title: "新版-收入统计" } },
        ],
      },
      {
        path: "system",
        meta: { title: "系统管理" },
        children: [
          { path: "menu", name: "MenuManagement", meta: { title: "菜单管理" } },
          { path: "scene", name: "SceneList", meta: { title: "场景探索" } },
          { path: "messages", name: "MessageList", meta: { title: "站内信管理" } },
          { path: "messages/create", name: "MessageCreate", meta: { title: "新建站内信", hidden: true } },
          { path: "dify", name: "SwitchDify", meta: { title: "切换dify" } },
          { path: "version", name: "VersionControl", meta: { title: "版本控制" } },
          { path: "scene/create", name: "SceneCreate", meta: { title: "新建场景", hidden: true } },
        ],
      },
    ],
  },
];
```

---

## 5. 状态管理

### 5.1 用户状态 (User Store)
```typescript
interface UserState {
  id: number;
  name: string;
  roles: string[];
  avatar: string;
}

// Actions
- login(username, password): Promise<void>
- getInfo(): Promise<void>
- logout(): Promise<void>
```

---

## 6. 通用组件

### 6.1 Layout 布局
- **Header**: 顶部导航栏，包含用户信息、退出登录
- **Sidebar**: 左侧菜单栏，根据路由配置自动生成

### 6.2 公共组件
| 组件名 | 用途 |
|--------|------|
| Empty.vue | 空状态展示 |
| ParentView/index.vue | 父级路由容器 |

---

## 7. 工具函数

### 7.1 请求封装 (request.ts)
- Axios实例封装
- 请求/响应拦截器
- 统一错误处理
- Token自动附加

### 7.2 认证工具 (auth.ts)
- Token获取/设置/清除
- 登录状态检查

### 7.3 主题管理 (useTheme.ts)
- 主题切换

### 7.4 通用工具 (utils.ts)
- Class名合并

---

## 8. 权限控制

### 8.1 路由权限
- 基于角色的菜单显示控制
- 路由守卫检查登录状态

### 8.2 按钮权限
- 预留权限控制机制

---

## 9. 环境配置

| 环境 | 文件 | 说明 |
|------|------|------|
| 开发环境 | .env.development | 本地开发配置 |
| 测试环境 | .env.test | 测试环境配置 |
| 生产环境 | .env.production | 生产环境配置 |

---

## 10. 待完善功能

### 10.1 预留功能（Mock数据）
- 用户管理（用户列表、创建、编辑、状态管理）
- 角色管理（角色列表、创建、编辑、删除）
- 权益列表管理

### 10.2 待对接接口
- 用户管理相关真实接口
- 角色管理相关真实接口
- 权益套餐列表接口

---

## 11. 部署说明

### 11.1 构建命令
```bash
# 开发
npm run dev

# 测试环境构建
npm run build:test

# 生产环境构建
npm run build:pro

# 类型检查
npm run check

# 代码检查
npm run lint
npm run lint:fix
```

### 11.2 部署平台
- 支持 Vercel 部署（已配置 vercel.json）

---

## 12. 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2024 | 0.0.0 | 项目初始化 |

---

*文档生成时间: 2026-03-23*
*基于代码仓库: moon-vision/dashboard/moon-qianduan*
