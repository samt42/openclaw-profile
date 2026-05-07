# 用户中心 - SSO API 协议

## 1. 概述

本文档定义单点登录（SSO）服务的 API 接口规范，包括登录、Token 校验、Token 刷新、登出、Ticket 换取等接口的请求/响应格式。

**相关文档**：
- [用户中心 - SSO技术方案](../技术方案/用户中心%20-%20SSO技术方案.md)
- [用户中心 - SSO API Swagger](用户中心%20-%20SSO%20API.swagger.yaml)（OpenAPI 规范）
- [单点登录](单点登录.md)


## 2. 接口列表

| 接口        | 方法   | 路径                | 说明                |
| --------- | ---- | ----------------- | ----------------- |
| 登录页       | GET  | /login            | 统一登录页面（HTML）      |
| 登录提交      | POST | /login    | 账号密码登录            |
| Token 校验  | POST | /verify   | 验证 Token 有效性      |
| Token 刷新  | POST | /refresh  | 刷新 AccessToken    |
| 登出        | POST | /logout   | 单点登出              |
| Ticket 换取 | POST | /exchange | 用 ticket 换取 Token |
| 用户信息      | GET  | /userinfo | 获取当前登录用户信息        |


## 3. 接口详情

### 3.1 登录接口：
https://app.apifox.com/link/project/4347867/apis/api-432226026
### 3.2 Token 校验接口
https://app.apifox.com/link/project/4347867/apis/api-432226029
### 3.3 Token 刷新接口
https://app.apifox.com/link/project/4347867/apis/api-432226030

## 4. 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2026-03-23 | v1.1 | 创建 OpenAPI/Swagger 规范文档 |
| 2026-03-23 | v1.0 | 从 SSO 技术方案拆分，创建独立 API 协议文档 |
