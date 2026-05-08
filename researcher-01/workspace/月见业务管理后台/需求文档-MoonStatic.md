# Moon Static - 静态资源仓库需求文档

## 1. 项目概述

### 1.1 基本信息
- **项目名称**: Moon Static（月见静态资源仓库）
- **项目类型**: 静态HTML页面集合
- **用途**: 月见App/塔罗产品的运营活动页面、协议文档、数据展示等
- **托管平台**: GitHub Pages / 静态服务器
- **项目规模**: 98个文件，6.2MB

### 1.2 系统定位
这是一个纯前端静态资源仓库，包含多个独立的HTML页面，用于：
- 用户协议与隐私政策展示
- 运营活动落地页
- 内部数据分析后台
- 塔罗牌图鉴展示
- 星盘SVG渲染
- Banner管理工具
- 消息推送系统

---

## 2. 目录结构

```
moon-static/
├── .github/                    # GitHub配置
├── agreement/                  # 用户协议与政策文档
│   ├── userAgreement.html      # 用户服务协议
│   ├── privacyAgreement.html   # 隐私政策
│   ├── membershipAgreementApple.html  # 苹果会员协议
│   ├── automaticRenewalAgreementApple.html  # 自动续费协议
│   ├── userAgreementApple.html # 苹果用户协议
│   ├── privacyAgreementApple.html  # 苹果隐私协议
│   ├── YJderegistrationAgreement.html  # 注销协议
│   ├── MA_APP.html             # 会员协议（App版）
│   ├── PlPA_APP.html           # 隐私政策（App版）
│   ├── rechargeAgreement.html  # 充值协议
│   └── YJARAA.html             # 自动续费协议
├── YJTLactives/                # 月见塔罗运营活动
│   ├── YJTLactivities.html     # 会员活动主页面
│   ├── moonGrassPlanting.html  # 种草活动页面
│   ├── moonPosting.html        # 发帖活动页面
│   ├── simple_grass_activity.html  # 简化版种草活动
│   ├── addMOoncoin.html        # 月见币活动
│   ├── activitySteps.html      # 活动步骤说明
│   ├── download.html           # App下载页
│   └── styles/                 # 活动样式文件
├── tarot-illustrations/        # 塔罗牌图鉴
│   ├── index.html              # 图鉴首页
│   ├── card.html               # 单张牌详情页
│   ├── cards-data.json         # 塔罗牌数据（78张）
│   └── assets/                 # 静态资源
├── astrolabe-svg/              # 星盘SVG渲染
│   ├── index.html              # 星盘展示页
│   ├── css/index.css           # 星盘样式
│   └── js/                     # 星盘交互脚本
├── backstage/                  # 数据分析后台
│   ├── index.html              # 数据分析主页面
│   ├── yuejian.html            # 月见数据页
│   ├── yuejianup.html          # 数据上报页
│   ├── switchService.html      # 服务切换页
│   ├── sumStatistics.html      # 汇总统计页
│   └── js/css/                 # 脚本和样式
├── compensate/                 # 批量补偿工具
│   └── index.html              # 补偿操作页面
├── navigation/                 # 内部导航页
│   └── index.html              # 工具导航首页
├── notifications/              # 消息推送系统
│   └── index.html              # 消息发送页面
└── banner/                     # Banner管理系统
    ├── index.html              # Banner管理页
    └── styles.css              # 样式文件
```

---

## 3. 功能模块详解

### 3.1 协议文档模块 (agreement/)

#### 3.1.1 功能描述
提供完整的用户协议和法律文档，支持App内嵌展示。

#### 3.1.2 文档列表
| 文件名 | 用途 | 适用平台 |
|--------|------|----------|
| userAgreement.html | 用户服务协议 | 通用 |
| privacyAgreement.html | 隐私政策 | 通用 |
| userAgreementApple.html | 用户协议 | iOS |
| privacyAgreementApple.html | 隐私政策 | iOS |
| membershipAgreementApple.html | 会员服务协议 | iOS |
| automaticRenewalAgreementApple.html | 自动续费协议 | iOS |
| YJderegistrationAgreement.html | 账号注销协议 | 通用 |
| MA_APP.html | 会员协议App版 | App内嵌 |
| PlPA_APP.html | 隐私政策App版 | App内嵌 |
| rechargeAgreement.html | 充值服务协议 | 通用 |
| YJARAA.html | 自动续费补充协议 | 通用 |

#### 3.1.3 技术特点
- 纯HTML+CSS，无JavaScript依赖
- 响应式设计，适配移动端
- 清晰的层级结构和标题样式
- 联系方式和客服信息展示

---

### 3.2 运营活动模块 (YJTLactives/)

#### 3.2.1 功能描述
月见塔罗社交媒体推广活动的落地页面，包含种草活动、会员活动等。

#### 3.2.2 页面列表
| 页面 | 功能 | 核心内容 |
|------|------|----------|
| YJTLactivities.html | 会员活动主页面 | 抖音/小红书/快手种草活动规则 |
| moonGrassPlanting.html | 种草活动详细页 | 详细参与步骤、奖励说明 |
| moonPosting.html | 发帖活动页 | 发帖奖励规则 |
| simple_grass_activity.html | 简化版种草活动 | 快速参与入口 |
| addMOoncoin.html | 月见币活动页 | 月见币获取活动 |
| activitySteps.html | 活动步骤说明 | 图文教程 |
| download.html | App下载页 | 各渠道下载引导 |

#### 3.2.3 会员活动规则（YJTLactivities.html）

**活动范围：**
- 在抖音、小红书、快手发布月见塔罗录屏或截图
- 添加话题标签 `#爱是天时地利的迷信`

**奖励机制：**
| 发布次数 | 奖励 |
|----------|------|
| 5次 | 月会员 |
| 12次 | 永久会员 |
| 每次发布 | 100月见币 |

**点赞奖励：**
| 点赞数 | 奖励 |
|--------|------|
| 10赞 | 100月见币 |
| 88赞 | 一个月会员 |
| 388赞 | 一年会员 |
| 688赞 | 永久会员 |
| 作品爆火 | 现金红包 |

#### 3.2.4 技术特点
- 百度统计代码集成（hm.js）
- 动画效果（CSS动画+GSAP）
- 响应式设计，适配移动端
- 视觉特效：渐变背景、浮动球体、模糊层

---

### 3.3 塔罗牌图鉴模块 (tarot-illustrations/)

#### 3.3.1 功能描述
完整的78张塔罗牌图鉴展示系统，支持分类浏览和详情查看。

#### 3.3.2 页面结构
| 文件 | 功能 |
|------|------|
| index.html | 图鉴首页，分类导航 |
| card.html | 单张牌详情页 |
| cards-data.json | 78张牌完整数据 |
| assets/site.css | 站点样式 |
| assets/site.js | 站点脚本 |
| assets/card.js | 牌详情脚本 |
| assets/icons.js | 图标库 |

#### 3.3.3 数据模型
```json
{
  "cards": [
    {
      "id": "fool",
      "name_cn": "愚人",
      "name_en": "The Fool",
      "number": 0,
      "category": "大阿尔卡纳",
      "element": "风",
      "planet": "天王星",
      "crystal": "透明石英、蓝色玛瑙、紫水晶",
      "energy": "变动",
      "img_url": "https://moonvision.oss-cn-beijing.aliyuncs.com/tarot/Fool.png",
      "content": {
        "overview": "...",
        "numerology": "...",
        "upright": {
          "quote": "...",
          "keywords": ["..."],
          "interpretation": "..."
        },
        "reversed": {
          "quote": "...",
          "keywords": ["..."],
          "interpretation": "..."
        }
      }
    }
  ]
}
```

#### 3.3.4 牌面分类
- **大阿尔卡纳**: 22张（愚人、魔术师、女祭司...）
- **小阿尔卡纳**: 56张
  - 权杖组（Wands）
  - 圣杯组（Cups）
  - 宝剑组（Swords）
  - 星币组（Pentacles）

#### 3.3.5 技术特点
- 动态渲染牌组网格
- 分类筛选导航
- 正位/逆位解读
- 关键词、水晶、行星关联
- 深色模式适配（color-scheme: dark）
- 百度统计集成

---

### 3.4 星盘渲染模块 (astrolabe-svg/)

#### 3.4.1 功能描述
用于App内嵌的星盘SVG渲染页面，支持与原生App通信。

#### 3.4.2 核心功能
- 从原生App获取SVG数据
- 计算星盘旋转角度
- 动态设置星盘样式
- 支持合盘对比

#### 3.4.3 技术实现
```javascript
// 与原生App通信的Bridge
WebViewBridge.invokeNativeMethod('getSVGData', null)
WebViewBridge.registerGlobalCallback('receiveSVGData', renderComplete)
WebViewBridge.registerGlobalCallback('turnTheAstrolabe', turnTheAstrolabe)
WebViewBridge.registerGlobalCallback('setDynamicAstrolabe', setDynamicAstrolabe)
```

#### 3.4.4 行星映射
```javascript
const planets = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "H", "m"]
const virtual = ["10", "11", "21"]
```

#### 3.4.5 技术特点
- GSAP动画库
- WebView Bridge通信
- 外部SVG服务集成（xingpan.vip）
- 响应式SVG渲染

---

### 3.5 数据分析后台模块 (backstage/)

#### 3.5.1 功能描述
内部数据分析和运营后台，用于查看App运营数据。

#### 3.5.2 页面列表
| 页面 | 功能 |
|------|------|
| index.html | 塔罗牌数据分析主页面 |
| yuejian.html | 月见数据展示 |
| yuejianup.html | 数据上报页面 |
| switchService.html | 服务切换配置 |
| sumStatistics.html | 汇总统计数据 |

#### 3.5.3 核心指标
| 指标 | 说明 |
|------|------|
| 新增用户 | 周期内新增用户数 |
| DAU | 日活跃用户数 |
| 新用户解读占比 | 新用户占卜比例 |
| 总收入 | 周期内收入金额 |
| ARPU | 活跃用户平均收入 |

#### 3.5.4 数据维度
- **实时数据**: 当前最新数据
- **历史数据**: 按周查询历史数据
- **收入渠道**: 分析各支付渠道贡献
- **新增渠道**: 分析各获客渠道效果

#### 3.5.5 图表类型
- 收入趋势图（Chart.js）
- 渠道分析柱状图
- 用户指标对比
- 转化指标分析

#### 3.5.6 技术栈
- Flatpickr 日期选择器
- SweetAlert2 弹窗
- Chart.js 图表
- Material UI 组件

---

### 3.6 批量补偿模块 (compensate/)

#### 3.6.1 功能描述
运营人员使用的批量补偿工具，用于特定时间段内的用户权益补偿。

#### 3.6.2 功能流程
1. 选择起始时间
2. 选择结束时间
3. 点击"执行补偿"
4. 查看补偿结果

#### 3.6.3 技术特点
- Bootstrap 5 UI
- 时间选择器（datetime-local）
- 表单验证
- 结果反馈展示

---

### 3.7 内部导航模块 (navigation/)

#### 3.7.1 功能描述
内部工具和系统导航页，方便团队快速访问各个系统。

#### 3.7.2 导航分类
- **数据系统**: 数据分析后台
- **管理系统**: Banner管理、消息系统
- **工具**: 补偿工具、版本控制
- **文档**: 协议文档、图鉴

#### 3.7.3 技术特点
- 移动端优先设计
- 卡片式布局
- 分组展示
- 箭头指示器

---

### 3.8 消息推送模块 (notifications/)

#### 3.8.1 功能描述
站内信和推送消息的发送系统。

#### 3.8.2 功能特性
- 消息类型选择
- 目标用户指定
- 消息内容编辑
- 链接配置
- 定时发送（预留）

#### 3.8.3 表单字段
| 字段 | 说明 |
|------|------|
| 消息标题 | 消息标题 |
| 消息内容 | 正文内容 |
| 消息类型 | 系统/活动/个人 |
| 目标用户 | 全部/指定用户 |
| 跳转链接 | H5链接或App内页 |

---

### 3.9 Banner管理模块 (banner/)

#### 3.9.1 功能描述
App内Banner位的内容管理系统。

#### 3.9.2 功能特性
- 密码验证访问
- Banner增删改查
- 排序和展示控制
- 链接配置
- 生效时间管理

#### 3.9.3 安全特性
- 访问密码验证
- 本地存储Token
- 会话管理

---

## 4. 技术架构

### 4.1 技术栈汇总
| 类别 | 技术/库 | 使用场景 |
|------|---------|----------|
| 基础 | HTML5 | 所有页面 |
| 样式 | CSS3 / SCSS | 样式定义 |
| 样式 | Bootstrap 5 | 补偿工具、后台 |
| 样式 | Tailwind CSS | 部分页面 |
| 脚本 | Vanilla JavaScript | 交互逻辑 |
| 动画 | GSAP | 星盘、活动页 |
| 图表 | Chart.js | 数据分析 |
| 日期 | Flatpickr | 日期选择 |
| 弹窗 | SweetAlert2 | 提示确认 |
| 图标 | Font Awesome | 图标 |
| 字体 | Google Fonts |  typography |

### 4.2 第三方服务
| 服务 | 用途 |
|------|------|
| 百度统计 (hm.baidu.com) | 页面访问统计 |
| OSS存储 | 图片资源托管 |
| xingpan.vip | 星盘SVG服务 |

### 4.3 响应式断点
| 断点 | 宽度 | 适配 |
|------|------|------|
| Mobile | < 576px | 手机 |
| Tablet | 576px - 992px | 平板 |
| Desktop | > 992px | 桌面 |

---

## 5. 接口说明

### 5.1 数据分析接口
```javascript
// 获取数据
GET /api/statistics

// 请求参数
{
  startTime: "2024-01-01 00:00:00",
  endTime: "2024-01-07 23:59:59",
  type: "real-time" | "historical"
}

// 响应数据
{
  newUsers: 1000,
  dau: 5000,
  interpretationOfTheProportion: 0.35,
  totalRevenue: 50000,
  arpu: 10,
  // ...
}
```

### 5.2 补偿接口
```javascript
// 批量补偿
POST /api/compensate

// 请求参数
{
  startTime: "2024-01-01T00:00",
  endTime: "2024-01-07T23:59"
}

// 响应
{
  success: true,
  message: "补偿成功",
  count: 100
}
```

### 5.3 Banner管理接口
```javascript
// 获取Banner列表
GET /api/banners

// 创建Banner
POST /api/banners

// 更新Banner
PUT /api/banners/:id

// 删除Banner
DELETE /api/banners/:id
```

---

## 6. 部署说明

### 6.1 部署方式
- **GitHub Pages**: 自动部署
- **静态服务器**: Nginx/Apache
- **CDN**: 阿里云OSS + CDN

### 6.2 访问地址
```
https://moonvision-ai.github.io/moon-static/
├── /agreement/          # 协议文档
├── /YJTLactives/        # 活动页面
├── /tarot-illustrations/ # 塔罗图鉴
├── /backstage/          # 数据后台
├── /compensate/         # 补偿工具
├── /navigation/         # 内部导航
├── /notifications/      # 消息系统
└── /banner/             # Banner管理
```

### 6.3 环境配置
- 生产环境：GitHub Pages
- 预发布：分支预览
- 开发：本地Live Server

---

## 7. 安全规范

### 7.1 访问控制
- Banner管理：密码验证
- 数据分析：内部网络/IP限制
- 补偿工具：运营人员权限

### 7.2 数据安全
- 敏感数据不存储在静态文件
- API调用需要Token验证
- HTTPS强制

---

## 8. 维护说明

### 8.1 更新流程
1. 本地修改测试
2. 提交到GitHub
3. 自动部署到GitHub Pages
4. CDN刷新（如使用）

### 8.2 注意事项
- 协议文档更新需法务审核
- 活动页面更新需运营确认
- API接口变更需同步更新

---

## 9. 相关项目关联

| 项目 | 关联 | 说明 |
|------|------|------|
| moon-qianduan | 后台管理系统 | 与本仓库互补，管理后台走管理系统，运营活动走静态页 |
| 月见App | 客户端 | 内嵌协议页、活动页 |
| 月见塔罗 | 小程序/H5 | 塔罗图鉴、活动页 |

---

*文档生成时间: 2026-03-23*
*基于代码仓库: moonvision-ai/moon-static*
