# 数据仓库 - 埋点SDK实现规范

## 1. 概述

本文档描述多端埋点 SDK 的技术实现规范，包括上报策略、性能参数、采样配置、本地校验规则及各端实现要点。

**相关需求文档**：
- [数据采集 SDK](../../../项目文档/数据仓库/专项/数据仓库%20-%20数据采集SDK.md)

**相关技术文档**：
- [数据仓库 - 埋点协议](../协议/数据仓库%20-%20埋点协议.md)（事件格式、字段规范、上报接口）
- [数据仓库 - 埋点网关](数据仓库%20-%20埋点网关.md)（网关配置、限流策略）


## 2. 上报策略

### 2.1 上报时机

| 事件类型 | 上报时机 | 说明 |
|---------|---------|------|
| 实时上报 | click、page_view | 立即触发上报 |
| 延迟上报 | page_exit | 页面离开时上报 |
| 批量上报 | exposure、swipe | 本地聚合后批量上报 |
| 离线上报 | 所有事件 | 网络异常时存储本地，恢复后补发 |

### 2.2 上报触发条件

| 场景 | 行为 |
|------|------|
| 网络正常 | 按策略上报（实时/缓冲） |
| 网络异常 | 本地存储，下次启动时补发 |
| 缓存满10条 | 强制批量上报 |
| 缓存满50条 | 丢弃最旧数据 |
| APP 进入后台 | 立即上报所有缓存数据 |
| APP 被杀 | 下次启动时补发未上报数据 |


## 3. 性能参数

| 配置项 | 值 | 说明 |
|-------|-----|------|
| 本地队列容量 | 1000 条 | 超出时丢弃最旧数据 |
| 上报批次大小 | 10 条或 5 秒 | 先到先触发 |
| 压缩方式 | Gzip | 压缩率约 70% |
| 重试策略 | 指数退避 | 1s → 2s → 4s → 8s → 16s |


## 4. 采样策略

| 场景 | 采样率 | 说明 |
|------|--------|------|
| 正常事件 | 100% | 全量采集 |
| swipe 滑动 | 10% | 高频事件采样 |
| 崩溃日志 | 100% | 全量采集 |
| debug 模式 | 100% | 开发测试全量 |


## 5. 本地校验规则

| 校验项 | 规则 | 处理方式 |
|--------|------|---------|
| 必填字段缺失 | event_type 等 | 记录错误，丢弃事件 |
| 时间戳异常 | 超过当前时间1小时或早于7天 | 校正或丢弃 |
| 请求ID重复 | 本地去重（24小时窗口） | 幂等处理 |


## 6. 版本兼容规范

### 向后兼容原则

- 新增字段：不影响旧版本解析
- 废弃字段：保留字段，标记 deprecated
- 类型变更：大版本升级（v1.0 → v2.0）


## 7. iOS 端实现要点

### 7.1 SDK 封装建议

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

### 7.2 关键触发点对照

| 触发点 | iOS 生命周期 / 位置 | 调用方式 |
|--------|-------------------|---------|
| 冷启动 | `application(_:didFinishLaunchingWithOptions:)` | `EventTracker.shared.batchTrack("app_start", ["start_type": "cold"])` |
| 热启动 | `applicationWillEnterForeground` + 30s 间隔判断 | `EventTracker.shared.batchTrack("app_start", ["start_type": "hot"])` |
| 退后台 | `applicationDidEnterBackground` | `EventTracker.shared.batchTrack("app_session", ["session_duration_ms": duration])` |
| 注册完成 | 注册接口成功回调 | `EventTracker.shared.track("user_register", ["register_channel": channel])` |
| 登录成功 | 登录接口成功回调 / 自动登录成功 | `EventTracker.shared.track("user_login", ["login_type": type])` |
| 进入核心功能 | 对应 ViewController 的 `viewDidAppear` | `EventTracker.shared.batchTrack("feature_enter", ["feature_name": name])` |


## 8. 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2026-03-23 | v1.0 | 从项目文档提取技术实现内容，创建本文档 |
