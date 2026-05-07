# 用户中心 - API 协议

## 1. 概述

本文档描述用户中心核心功能的API接口规范，包括注册、登录、用户信息管理、密码管理等。

**基础信息**：
- Base URL: `https://api.example.com/v1`
- 协议: HTTPS
- 数据格式: JSON
- 字符编码: UTF-8

**相关文档**：
- [用户中心 - 注册登录技术方案](../用户中心%20-%20注册登录技术方案.md)
- [用户中心 - SSO技术方案](../用户中心%20-%20SSO技术方案.md)
- [用户中心 - 数据库设计](../数据/用户中心%20-%20数据库设计.md)


## 2. 通用规范

### 2.1 请求格式

**Header**：
```
Content-Type: application/json
Authorization: Bearer {access_token}  (需要认证的接口)
X-Request-ID: {uuid}                 (请求追踪ID)
X-Device-ID: {device_id}             (设备标识)
```

### 2.2 响应格式

**成功响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": { ... },
  "request_id": "req_xxx"
}
```

**错误响应**：
```json
{
  "code": 10001,
  "message": "参数错误",
  "data": null,
  "request_id": "req_xxx"
}
```

### 2.3 HTTP 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（Token无效或过期）|
| 403 | 禁止访问（权限不足）|
| 404 | 资源不存在 |
| 409 | 资源冲突（如重复注册）|
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |


## 3. 注册接口

### 3.1 发送验证码

**POST** `/auth/sms/send`

**请求体**：
```json
{
  "phone": "13800138000",
  "captcha": "",           // 可选，触发图形验证码时需要
  "captcha_id": ""         // 可选
}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "expire_seconds": 300
  }
}
```

**错误码**：
- 10015: 发送频率过快
- 10016: 手机号格式错误


### 3.2 手机号注册

**POST** `/auth/register/phone`

**请求体**：
```json
{
  "phone": "13800138000",
  "sms_code": "123456",
  "password": "",          // 可选，不填则使用验证码登录
  "device_info": {
    "device_id": "fp_xxx",
    "device_name": "iPhone 15 Pro",
    "device_type": "ios"
  }
}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "jwt_token",
    "refresh_token": "rt_xxx",
    "expires_in": 7200,
    "user": {
      "id": "user_xxx",
      "phone": "138****8000",
      "nickname": "用户xxx",
      "avatar": "",
      "status": 1
    }
  }
}
```

**错误码**：
- 10002: 验证码错误
- 10003: 验证码过期
- 10004: 手机号已注册


### 3.3 邮箱注册

**POST** `/auth/register/email`

**请求体**：
```json
{
  "email": "user@example.com",
  "password": "Password123",
  "nickname": "张三"
}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "user_id": "user_xxx",
    "status": "inactive",
    "message": "请查收邮件激活账户"
  }
}
```


### 3.4 验证邮箱

**GET** `/auth/email/verify?token={token}`

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "jwt_token",
    "refresh_token": "rt_xxx",
    "user": { ... }
  }
}
```


## 4. 登录接口

### 4.1 密码登录

**POST** `/auth/login/password`

**请求体**：
```json
{
  "account": "13800138000",  // 支持手机号/邮箱/用户名
  "password": "Password123",
  "device_info": {
    "device_id": "fp_xxx",
    "device_name": "iPhone 15 Pro",
    "device_type": "ios"
  }
}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "jwt_token",
    "refresh_token": "rt_xxx",
    "expires_in": 7200,
    "user": { ... }
  }
}
```

**错误码**：
- 10007: 用户不存在
- 10008: 密码错误
- 10009: 账户已锁定（需告知锁定时间）


### 4.2 验证码登录

**POST** `/auth/login/sms`

**请求体**：
```json
{
  "phone": "13800138000",
  "sms_code": "123456",
  "device_info": { ... }
}
```

**响应**：同密码登录


### 4.3 刷新 Token

**POST** `/auth/token/refresh`

**请求体**：
```json
{
  "refresh_token": "rt_xxx"
}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "new_jwt_token",
    "refresh_token": "new_rt_xxx",
    "expires_in": 7200
  }
}
```


### 4.4 登出

**POST** `/auth/logout`

**Header**：
```
Authorization: Bearer {access_token}
```

**请求体**：
```json
{
  "all_devices": false  // 是否登出所有设备
}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```


## 5. 用户信息接口

### 5.1 获取当前用户信息

**GET** `/user/profile`

**Header**：
```
Authorization: Bearer {access_token}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "user_xxx",
    "username": "zhangsan",
    "nickname": "张三",
    "avatar": "https://...",
    "phone": "138****8000",
    "email": "us***@example.com",
    "gender": 1,
    "birthday": "1990-01-01",
    "bio": "个人简介",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```


### 5.2 更新用户信息

**PUT** `/user/profile`

**Header**：
```
Authorization: Bearer {access_token}
```

**请求体**：
```json
{
  "nickname": "新昵称",
  "gender": 1,
  "birthday": "1990-01-01",
  "bio": "新的简介"
}
```

**响应**：返回更新后的用户信息


### 5.3 上传头像

**POST** `/user/avatar`

**Header**：
```
Authorization: Bearer {access_token}
Content-Type: multipart/form-data
```

**请求体**：
```
file: [图片文件]
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "avatar_url": "https://..."
  }
}
```


## 6. 密码管理接口

### 6.1 修改密码

**PUT** `/user/password`

**Header**：
```
Authorization: Bearer {access_token}
```

**请求体**：
```json
{
  "old_password": "OldPass123",
  "new_password": "NewPass123"
}
```

**错误码**：
- 10008: 原密码错误


### 6.2 忘记密码 - 发送验证码

**POST** `/auth/password/reset/send`

**请求体**：
```json
{
  "phone": "13800138000"
}
```


### 6.3 忘记密码 - 重置

**POST** `/auth/password/reset`

**请求体**：
```json
{
  "phone": "13800138000",
  "sms_code": "123456",
  "new_password": "NewPass123"
}
```


## 7. 设备管理接口

### 7.1 获取设备列表

**GET** `/user/devices`

**Header**：
```
Authorization: Bearer {access_token}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "current_device": {
      "session_id": "sess_xxx",
      "device_name": "iPhone 15 Pro",
      "device_type": "ios",
      "login_at": "2024-03-23T10:00:00Z",
      "location": "北京"
    },
    "other_devices": [
      {
        "session_id": "sess_yyy",
        "device_name": "MacBook Pro",
        "device_type": "desktop",
        "login_at": "2024-03-22T08:00:00Z",
        "location": "上海"
      }
    ]
  }
}
```


### 7.2 踢出指定设备

**DELETE** `/user/devices/{session_id}`

**Header**：
```
Authorization: Bearer {access_token}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```


### 7.3 踢出所有其他设备

**DELETE** `/user/devices/others`

**Header**：
```
Authorization: Bearer {access_token}
```


## 8. 第三方账号接口

### 8.1 获取绑定列表

**GET** `/user/oauth/bindings`

**Header**：
```
Authorization: Bearer {access_token}
```

**响应**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "bindings": [
      {
        "provider": "wechat",
        "provider_nickname": "微信用户",
        "provider_avatar": "https://...",
        "bound_at": "2024-03-01T00:00:00Z"
      }
    ]
  }
}
```


### 8.2 解绑第三方账号

**DELETE** `/user/oauth/bindings/{provider}`

**Header**：
```
Authorization: Bearer {access_token}
```

**请求体**：
```json
{
  "password": "Password123"  // 验证身份
}
```


## 9. 错误码汇总

| 错误码 | 说明 | HTTP状态码 |
|--------|------|-----------|
| 0 | 成功 | 200 |
| 10001 | 参数错误 | 400 |
| 10002 | 验证码错误 | 400 |
| 10003 | 验证码过期 | 400 |
| 10004 | 手机号已注册 | 409 |
| 10005 | 邮箱已注册 | 409 |
| 10006 | 用户名已存在 | 409 |
| 10007 | 用户不存在 | 404 |
| 10008 | 密码错误 | 401 |
| 10009 | 账户已锁定 | 403 |
| 10010 | 账户未激活 | 403 |
| 10011 | Token无效 | 401 |
| 10012 | Token已过期 | 401 |
| 10013 | Refresh Token无效 | 401 |
| 10014 | 设备数已达上限 | 403 |
| 10015 | 发送频率过快 | 429 |
| 10016 | IP被限制 | 403 |
| 10017 | 密码强度不足 | 400 |
| 10018 | 图形验证码错误 | 400 |
| 20001 | 第三方授权失败 | 400 |
| 20002 | 第三方授权取消 | 400 |
| 20003 | 该第三方账号已绑定其他用户 | 409 |
| 99999 | 系统错误 | 500 |


## 10. 变更记录

| 日期 | 版本 | 变更内容 |
|------|------|----------|
| 2026-03-23 | v1.0 | 创建用户中心API协议文档 |
