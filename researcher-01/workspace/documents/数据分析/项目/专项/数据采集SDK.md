# 数据采集 SDK

| 属性 | 值 |
|------|------|
| 需求编号 | FEAT-SDK-数据采集SDK |
| 状态 | 草稿 |
| 所属模块 | 数据仓库 |


## 1. 需求描述

开发多端 SDK 实现统一的埋点采集能力，遵循 [数据仓库 - 埋点协议](../../../技术文档/数据仓库/协议/数据仓库%20-%20埋点协议.md) 规范。


## 2. 支持平台

| 平台 | 技术方案 | 说明 |
|------|---------|------|
| iOS | Swift SDK | 支持 iOS 12+ |
| Android | Kotlin SDK | 支持 API 21+ |
| Web | JavaScript SDK | 支持现代浏览器 |
| 小程序 | 各平台 SDK | 微信/支付宝/抖音 |


## 3. 上报策略

### 3.1 上报时机

| 事件类型 | 上报时机 | 说明 |
|---------|---------|------|
| 实时上报 | click、page_view | 立即触发上报 |
| 延迟上报 | page_exit | 页面离开时上报 |
| 批量上报 | exposure、swipe | 本地聚合后批量上报 |
| 离线上报 | 所有事件 | 网络异常时存储本地，恢复后补发 |

### 3.2 上报触发条件

| 场景 | 行为 |
|------|------|
| 网络正常 | 按策略上报（实时/缓冲） |
| 网络异常 | 本地存储，下次启动时补发 |
| 缓存满10条 | 强制批量上报 |
| 缓存满50条 | 丢弃最旧数据 |
| APP 进入后台 | 立即上报所有缓存数据 |
| APP 被杀 | 下次启动时补发未上报数据 |


## 4. 性能优化

| 配置项 | 值 | 说明 |
|-------|-----|------|
| 本地队列容量 | 1000 条 | 超出时丢弃最旧数据 |
| 上报批次大小 | 10 条或 5 秒 | 先到先触发 |
| 压缩方式 | Gzip | 压缩率约 70% |
| 重试策略 | 指数退避 | 1s → 2s → 4s → 8s → 16s |


## 5. 采样策略

| 场景 | 采样率 | 说明 |
|------|--------|------|
| 正常事件 | 100% | 全量采集 |
| swipe 滑动 | 10% | 高频事件采样 |
| 崩溃日志 | 100% | 全量采集 |
| debug 模式 | 100% | 开发测试全量 |


## 6. 本地校验

| 校验项 | 规则 | 处理方式 |
|--------|------|---------|
| 必填字段缺失 | event_type 等 | 记录错误，丢弃事件 |
| 时间戳异常 | 超过当前时间1小时或早于7天 | 校正或丢弃 |
| 请求ID重复 | 本地去重（24小时窗口） | 幂等处理 |


## 7. 版本升级说明

### 向后兼容原则

- 新增字段：不影响旧版本解析
- 废弃字段：保留字段，标记 deprecated
- 类型变更：大版本升级（v1.0 → v2.0）


## 8. iOS 端实现要点

### 8.1 SDK 封装建议

```
EventTracker（单例）
├── track(event, properties)        // 单条上报
├── batchTrack(event, properties)   // 加入批量队列
├── flush()                         // 立即发送队列中的事件
├── setUserId(userId)               // 登录后设置 user_id
├── clearUserId()                   // 登出时清除
└── 内部模块
    ├── EventQueue          // 内存队列 + 持久化
    ├── NetworkUploader     // 网络上报 + 重试
    └── DeviceInfo          // device_id, platform, versions
```

### 8.2 关键触发点对照

| 触发点 | iOS 生命周期 / 位置 | 调用方式 |
|--------|-------------------|---------|
| 冷启动 | `application(_:didFinishLaunchingWithOptions:)` | `EventTracker.shared.batchTrack("app_start", ["start_type": "cold"])` |
| 热启动 | `applicationWillEnterForeground` + 30s 间隔判断 | `EventTracker.shared.batchTrack("app_start", ["start_type": "hot"])` |
| 退后台 | `applicationDidEnterBackground` | `EventTracker.shared.batchTrack("app_session", ["session_duration_ms": duration])` |
| 注册完成 | 注册接口成功回调 | `EventTracker.shared.track("user_register", ["register_channel": channel])` |
| 登录成功 | 登录接口成功回调 / 自动登录成功 | `EventTracker.shared.track("user_login", ["login_type": type])` |
| 进入核心功能 | 对应 ViewController 的 `viewDidAppear` | `EventTracker.shared.batchTrack("feature_enter", ["feature_name": name])` |


## 附录

### 相关文档

**技术文档**：
- [数据仓库 - 埋点协议](../../../技术文档/数据仓库/协议/数据仓库%20-%20埋点协议.md)（事件格式、字段规范、批量上报格式）
- [数据仓库 - 埋点网关](../../../技术文档/数据仓库/技术方案/数据仓库%20-%20埋点网关.md)（上报接口、网关配置）

**项目文档**：
- [数据采集](../功能特性/数据采集.md)
- [数据仓库 - 数据采集](数据仓库%20-%20数据采集.md)

### 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2024-03-06 | v1.0 | 初始版本 |
| 2026-03-23 | v1.1 | 修复文档结构和链接，事件格式示例改为引用埋点协议技术文档 |
