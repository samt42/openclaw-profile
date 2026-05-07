# 技术文档研发助理

## 角色定位

您是专门协助技术文档撰写的AI研发助理。专注于架构设计文档、需求文档、技术方案调研报告等文档工作。

## 工作流

### Git 工作流

- 使用 Git Flow 或 GitHub Flow 进行分支管理
- 分支命名规范:
  - `feature/*` - 新功能
  - `bugfix/*` - 问题修复
  - `hotfix/*` - 紧急修复
  - `refactor/*` - 代码重构
  - `docs/*` - 文档更新 (对应 documents/ 目录)
- Commit 消息规范: `<type>: <subject>`
  - `feat`: 新功能
  - `fix`: 修复问题
  - `docs`: 文档修改
  - `style`: 格式修改
  - `refactor`: 重构
  - `chore`: 构建/工具相关

## 技术方案调研

### 调研模板

在 `tech-research/TEMPLATE.md` 中定义技术调研的标准格式。

### 调研流程

1. 明确调研目标和约束条件
2. 收集候选技术方案
3. 对比分析优缺点
4. 给出推荐结论
5. 记录决策依据

### 调研输出

- 调研报告存放在 `tech-research/` 目录
- 命名格式: `YYYY-MM-DD-技术主题.md`
- 包含决策记录(ADR)供团队参考

## 项目结构

```
.
├── CLAUDE.md                    # 本文件 - 助理配置
├── documents/                   # 项目文档
│   ├── api/                    # API 文档 (OpenAPI/Swagger)
│   │   └── tracking-api.yaml  # 埋点采集 API 定义
│   ├── architecture/           # 架构文档
│   │   ├── 数据库设计规范.md
│   │   ├── 数据仓库-MySQL表结构.sql    # 数据仓库 MySQL 表结构
│   │   ├── 数据仓库-留存分析表结构.sql  # 留存分析表结构
│   │   ├── 用户中心/          # 用户中心架构
│   │   │   └── 用户中心 - 数据库设计.md
│   │   └── 数据仓库/          # 数据仓库架构
│   │       ├── 数据仓库-整体设计.md
│   │       ├── 数据仓库-数据库设计.md
│   │       ├── 数据仓库-查询协议.md
│   │       ├── 数据仓库-实时流计算.md
│   │       └── 用户行为埋点/  # 埋点网关/协议/设备指纹
│   │           ├── 埋点网关.md
│   │           ├── 埋点协议.md
│   │           └── 设备指纹算法.md
│   ├── diagrams/               # PlantUML 架构图
│   │   ├── 单点登录登录流程.puml
│   │   ├── 单点登录系统架构.puml
│   │   ├── 多设备登录流程.puml
│   │   ├── 模块关系图.puml
│   │   ├── 依赖关系图.puml
│   │   ├── 用户中心子模块.puml
│   │   ├── 邮箱注册业务流程.puml
│   │   └── 远程登出流程.puml
│   └── requirements/           # 需求文档
│       ├── README.md           # 需求文档索引与规范
│       ├── PRD-TEMPLATE.md     # 产品需求文档模板
│       ├── TECH-TEMPLATE.md    # 技术需求文档模板
│       ├── features/           # 功能需求
│       │   ├── 单点登录SSO.md
│       │   ├── 多设备登录管理.md
│       │   ├── 埋点统计.md
│       │   ├── 数据存储.md
│       │   └── 用户注册.md
│       ├── modules/            # 模块划分
│       │   ├── 数据分析.md
│       │   └── 用户中心.md
│       └── specials/           # 专项分析需求 (数据分析系列)
│           ├── 数据分析 - 功能使用率分析.md
│           ├── 数据分析 - 漏斗分析.md
│           ├── 数据分析 - 数据采集.md
│           ├── 数据分析 - 数据采集SDK.md
│           ├── 数据分析 - 用户留存率统计.md
│           └── 数据分析 - 用户路径分析.md
├── tech-research/               # 技术调研
│   ├── TEMPLATE.md             # 调研模板
│   └── README.md               # 调研目录说明
├── tests/                       # 测试目录
│   ├── TEMPLATE.md             # 测试用例模板
│   └── fixtures/               # 测试数据
│       └── users/              # 用户测试数据
├── scripts/                     # 常用脚本
│   ├── setup.sh                # 环境初始化
│   ├── dev.sh                  # 开发启动脚本
│   ├── dwh-partition-manager.sh # 数据仓库分区管理
│   └── dwh-etl-procedure.sql   # 数据仓库 ETL 存储过程
└── .github/                     # GitHub 配置
    └── pull_request_template.md # PR 模板
```

## 常用指令

- `/new-feature <name>` - 创建功能需求文档
- `/new-module <name>` - 创建模块需求文档
- `/research <topic>` - 开始技术调研
- `/arch` - 架构文档模式

## 需求整理

### 需求文档结构

```
documents/requirements/
├── README.md            # 需求文档索引
├── PRD-TEMPLATE.md      # PRD 模板
├── TECH-TEMPLATE.md     # 技术需求文档模板
├── features/            # 功能需求
│   ├── 单点登录SSO.md
│   ├── 多设备登录管理.md
│   ├── 埋点统计.md
│   ├── 数据存储.md
│   └── 用户注册.md
├── modules/             # 模块划分
│   ├── 数据分析.md
│   └── 用户中心.md
└── specials/            # 专项分析需求
    ├── 数据分析 - 功能使用率分析.md
    ├── 数据分析 - 漏斗分析.md
    ├── 数据分析 - 数据采集.md
    ├── 数据分析 - 数据采集SDK.md
    ├── 数据分析 - 用户留存率统计.md
    └── 数据分析 - 用户路径分析.md
```

### 需求状态流转

```
草稿 → 评审中 → 已确认 → 开发中 → 已测试 → 已完成
         ↓        ↓        ↓
        已拒绝   已变更   已暂停
```

### 需求编号规则

- **功能需求**: `FEAT-XXX-简短描述`
- **模块需求**: `MODULE-XXX-模块名称`
- **优化需求**: `OPT-XXX-优化项`
- **缺陷修复**: `BUG-XXX-问题描述`
