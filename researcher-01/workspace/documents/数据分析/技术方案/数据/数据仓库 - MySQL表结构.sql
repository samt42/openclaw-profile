-- ============================================================
-- 数据仓库 MySQL 建表脚本（含留存分析专项表）
-- 适用于 DAU 2万 / 日增1GB 规模
-- 版本: v2.0
-- 日期: 2026-03-23
-- ============================================================

-- ============================================================
-- 1. ODS 层 - 原始数据（可选，如果直接用 OSS 存储可跳过）
-- ============================================================

-- 原始埋点数据（详细字段，支持埋点协议 v1.0）
CREATE TABLE IF NOT EXISTS `ods_tracking_event_raw` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `event_type` VARCHAR(32) NOT NULL COMMENT '事件类型: page_view/click/exposure等',
    `event_name` VARCHAR(32) NOT NULL COMMENT '事件名称',
    `event_time` BIGINT UNSIGNED NOT NULL COMMENT '事件发生时间戳(毫秒)',
    `request_id` VARCHAR(64) COMMENT '请求ID(Header.X-Request-Id)',
    `session_id` VARCHAR(64) COMMENT '会话ID(Body)',
    `device_id` VARCHAR(64) COMMENT '设备指纹(服务端生成)',
    `device_model` VARCHAR(64) COMMENT '设备型号(Header.X-Device-Model)',
    `user_id` VARCHAR(32) COMMENT '用户ID(从Authorization解析)',
    `platform` VARCHAR(16) NOT NULL COMMENT '平台: ios/android/web(Header.X-Os-Type)',
    `os_version` VARCHAR(16) COMMENT '系统版本(Header.X-Os-Version)',
    `app_version` VARCHAR(16) COMMENT 'APP版本名称(Header.X-App-Version-Name)',
    `app_version_code` VARCHAR(16) COMMENT 'APP版本号(Header.X-App-Version-Code)',
    `channel` VARCHAR(32) COMMENT '分发渠道(Header.X-Distribution)',
    `network_type` VARCHAR(16) COMMENT '网络类型(Header.X-Network-Type)',
    `carrier` VARCHAR(32) COMMENT '运营商(Body.carrier)',
    `screen_width` INT COMMENT '屏幕宽度(Body)',
    `screen_height` INT COMMENT '屏幕高度(Body)',
    `time_zone` VARCHAR(32) COMMENT '时区(Header.X-Time-Zone)',
    `language` VARCHAR(16) COMMENT '语言(Header.Accept-Language)',
    `device_type` VARCHAR(8) COMMENT '设备类型(Header.X-Device-Type)',
    `protocol_version` VARCHAR(8) COMMENT '协议版本(Body)',
    `context` JSON COMMENT '事件上下文JSON: page/element/exposure等',
    `properties` JSON COMMENT '自定义属性JSON(Body.properties)',
    `receive_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '数据接收时间',
    `dt` DATE NOT NULL COMMENT '日期分区',
    PRIMARY KEY (`id`, `dt`),
    KEY `idx_event_time` (`event_time`),
    KEY `idx_request_id` (`request_id`),
    KEY `idx_session_id` (`session_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_event_type` (`event_type`),
    KEY `idx_event_name` (`event_name`),
    KEY `idx_device_model` (`device_model`),
    KEY `idx_dt` (`dt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='埋点事件原始数据'
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_ods_event_future VALUES LESS THAN MAXVALUE
);

-- 原始系统日志
CREATE TABLE IF NOT EXISTS `ods_system_log_raw` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `service_name` VARCHAR(64) NOT NULL,
    `log_level` VARCHAR(16) NOT NULL,
    `log_content` TEXT,
    `log_time` DATETIME NOT NULL,
    `dt` DATE NOT NULL,
    PRIMARY KEY (`id`, `dt`),
    KEY `idx_service_time` (`service_name`, `log_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_ods_log_future VALUES LESS THAN MAXVALUE
);

-- 用户注册原始数据（来自业务数据库CDC）
CREATE TABLE IF NOT EXISTS `ods_user_register_raw` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `cdc_type` VARCHAR(16) NOT NULL COMMENT 'CDC类型: INSERT/UPDATE',
    `user_id` VARCHAR(32) NOT NULL COMMENT '用户ID',
    `fingerprint` VARCHAR(64) COMMENT '设备指纹',
    `register_time` DATETIME NOT NULL COMMENT '注册时间',
    `first_login_date` DATE NOT NULL COMMENT '首次登录日期',
    `register_channel` VARCHAR(32) COMMENT '注册渠道',
    `platform` VARCHAR(16) COMMENT '注册平台',
    `app_version` VARCHAR(16) COMMENT '注册版本',
    `province` VARCHAR(32) COMMENT '省份',
    `city` VARCHAR(32) COMMENT '城市',
    `receive_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `dt` DATE NOT NULL COMMENT '日期分区',
    PRIMARY KEY (`id`, `dt`),
    UNIQUE KEY `uk_user_id` (`user_id`),
    KEY `idx_first_login_date` (`first_login_date`),
    KEY `idx_fingerprint` (`fingerprint`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户注册原始数据'
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_ods_reg_future VALUES LESS THAN MAXVALUE
);

-- ============================================================
-- 2. DWD 层 - 明细数据（保留90天，分区管理）
-- ============================================================

-- 埋点事件明细表
CREATE TABLE IF NOT EXISTS `dwd_tracking_event` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `event_type` VARCHAR(32) NOT NULL COMMENT '事件类型: page_view/click/exposure',
    `event_name` VARCHAR(64) NOT NULL COMMENT '事件名称',
    `event_time` DATETIME(3) NOT NULL COMMENT '事件发生时间',

    -- 用户/设备信息
    `user_id` BIGINT UNSIGNED COMMENT '用户ID（未登录为空）',
    `device_id` VARCHAR(64) NOT NULL COMMENT '设备ID',
    `session_id` VARCHAR(64) NOT NULL COMMENT '会话ID',

    -- 设备环境（从 HTTP Header 提取）
    `platform` VARCHAR(16) NOT NULL COMMENT '平台: ios/android/web/miniapp',
    `app_version` VARCHAR(16) NOT NULL COMMENT 'App版本',
    `os_version` VARCHAR(32) COMMENT '系统版本',
    `device_model` VARCHAR(64) COMMENT '设备型号',
    `network_type` VARCHAR(16) COMMENT '网络类型: wifi/4g/5g',

    -- 位置信息
    `country` VARCHAR(16) DEFAULT 'CN' COMMENT '国家',
    `province` VARCHAR(32) COMMENT '省份',
    `city` VARCHAR(32) COMMENT '城市',

    -- 页面/元素信息
    `page_name` VARCHAR(64) COMMENT '页面名称',
    `page_path` VARCHAR(255) COMMENT '页面路径',
    `page_title` VARCHAR(128) COMMENT '页面标题',
    `element_id` VARCHAR(64) COMMENT '元素ID',
    `element_name` VARCHAR(64) COMMENT '元素名称',
    `element_type` VARCHAR(16) COMMENT '元素类型: button/image/text',
    `element_position` VARCHAR(32) COMMENT '元素位置（列表索引）',

    -- 扩展属性
    `properties` JSON COMMENT '自定义属性JSON',

    -- 停留时长（page_exit 事件）
    `stay_duration_ms` INT UNSIGNED COMMENT '停留时长(ms)',

    -- 分区字段
    `dt` DATE NOT NULL COMMENT '日期分区',

    PRIMARY KEY (`id`, `dt`),
    KEY `idx_user_time` (`user_id`, `event_time`),
    KEY `idx_device_time` (`device_id`, `event_time`),
    KEY `idx_event_name` (`event_name`, `event_time`),
    KEY `idx_event_type` (`event_type`, `event_time`),
    KEY `idx_page_name` (`page_name`, `event_time`),
    KEY `idx_session` (`session_id`, `event_time`),
    KEY `idx_dt` (`dt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='埋点事件明细表'
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_dwd_20260307 VALUES LESS THAN (TO_DAYS('2026-03-08')),
    PARTITION p_dwd_future VALUES LESS THAN MAXVALUE
);

-- 用户登录明细表
CREATE TABLE IF NOT EXISTS `dwd_user_login` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `login_time` DATETIME NOT NULL COMMENT '登录时间',
    `logout_time` DATETIME COMMENT '登出时间',
    `login_type` TINYINT NOT NULL DEFAULT 1 COMMENT '登录方式: 1密码 2短信 3微信 4Apple',
    `device_type` TINYINT NOT NULL DEFAULT 1 COMMENT '设备类型: 1web 2ios 3android 4desktop',
    `device_id` VARCHAR(64) COMMENT '设备ID',
    `channel` VARCHAR(32) COMMENT '渠道',
    `ip_address` VARCHAR(45) COMMENT 'IP地址（脱敏）',
    `province` VARCHAR(32) COMMENT '省份',
    `city` VARCHAR(32) COMMENT '城市',
    `dt` DATE NOT NULL COMMENT '日期分区',
    PRIMARY KEY (`id`, `dt`),
    KEY `idx_user_time` (`user_id`, `login_time`),
    KEY `idx_login_time` (`login_time`),
    KEY `idx_dt` (`dt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户登录明细表'
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_login_20260307 VALUES LESS THAN (TO_DAYS('2026-03-08')),
    PARTITION p_login_future VALUES LESS THAN MAXVALUE
);

-- 用户注册明细表
CREATE TABLE IF NOT EXISTS `dwd_user_register` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `register_time` DATETIME NOT NULL COMMENT '注册时间',
    `register_channel` VARCHAR(32) COMMENT '注册渠道',
    `device_type` TINYINT DEFAULT 1 COMMENT '设备类型',
    `ip_address` VARCHAR(45) COMMENT 'IP地址（脱敏）',
    `province` VARCHAR(32) COMMENT '省份',
    `city` VARCHAR(32) COMMENT '城市',
    `first_device_id` VARCHAR(64) COMMENT '首登设备ID',
    `dt` DATE NOT NULL COMMENT '日期分区',
    PRIMARY KEY (`id`, `dt`),
    UNIQUE KEY `uk_user_id` (`user_id`, `dt`),
    KEY `idx_register_time` (`register_time`),
    KEY `idx_channel` (`register_channel`, `register_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户注册明细表'
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_reg_20260307 VALUES LESS THAN (TO_DAYS('2026-03-08')),
    PARTITION p_reg_future VALUES LESS THAN MAXVALUE
);

-- 用户每日活跃明细（留存计算基础）
CREATE TABLE IF NOT EXISTS `dwd_user_active_daily` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `user_id` VARCHAR(32) NOT NULL COMMENT '用户ID',
    `active_date` DATE NOT NULL COMMENT '活跃日期',
    `first_login_date` DATE NOT NULL COMMENT '首次登录日期（新用户留存基准）',
    `register_channel` VARCHAR(32) COMMENT '注册渠道',
    `first_platform` VARCHAR(16) COMMENT '注册平台',
    `first_app_version` VARCHAR(16) COMMENT '注册版本',
    `login_count` INT UNSIGNED DEFAULT 0 COMMENT '当日登录次数',
    `user_age_days` INT COMMENT '用户年龄(天)',
    `dt` DATE NOT NULL COMMENT '分区日期',
    PRIMARY KEY (`id`, `dt`),
    UNIQUE KEY `uk_user_active` (`user_id`, `active_date`),
    KEY `idx_active_date` (`active_date`),
    KEY `idx_first_login_date` (`first_login_date`),
    KEY `idx_channel` (`register_channel`, `active_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户每日活跃明细'
PARTITION BY RANGE (TO_DAYS(dt)) (
    PARTITION p_dwd_user_future VALUES LESS THAN MAXVALUE
);

-- ============================================================
-- 3. DWS 层 - 汇总数据（保留1年，预计算）
-- ============================================================

-- 页面访问日汇总表
CREATE TABLE IF NOT EXISTS `dws_page_view_daily` (
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `page_name` VARCHAR(64) NOT NULL COMMENT '页面名称',
    `platform` VARCHAR(16) NOT NULL COMMENT '平台',
    `app_version` VARCHAR(16) COMMENT 'App版本',

    -- 访问指标
    `pv` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '页面浏览量',
    `uv` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '独立访客数',
    `pv_by_new_user` BIGINT UNSIGNED DEFAULT 0 COMMENT '新用户PV',
    `pv_by_old_user` BIGINT UNSIGNED DEFAULT 0 COMMENT '老用户PV',

    -- 停留时长
    `total_stay_ms` BIGINT UNSIGNED DEFAULT 0 COMMENT '总停留时长(ms)',
    `avg_stay_ms` INT UNSIGNED DEFAULT 0 COMMENT '平均停留时长(ms)',
    `stay_user_count` INT UNSIGNED DEFAULT 0 COMMENT '有停留时长用户数',

    -- 跳出相关
    `bounce_count` INT UNSIGNED DEFAULT 0 COMMENT '跳出次数',
    `bounce_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '跳出率(%)',

    -- 来源分析
    `entry_count` INT UNSIGNED DEFAULT 0 COMMENT '作为入口页次数',
    `exit_count` INT UNSIGNED DEFAULT 0 COMMENT '作为退出页次数',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stat_date`, `page_name`, `platform`),
    KEY `idx_page_date` (`page_name`, `stat_date`),
    KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='页面访问日汇总表';

-- 事件统计日汇总表
CREATE TABLE IF NOT EXISTS `dws_event_stat_daily` (
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `event_type` VARCHAR(32) NOT NULL COMMENT '事件类型',
    `event_name` VARCHAR(64) NOT NULL COMMENT '事件名称',
    `platform` VARCHAR(16) NOT NULL COMMENT '平台',

    -- 触发统计
    `trigger_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '触发次数',
    `trigger_user_count` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '触发用户数',

    -- 人均触发
    `avg_trigger_per_user` DECIMAL(8,2) DEFAULT 0.00 COMMENT '人均触发次数',

    -- 首次/末次触发时间
    `first_trigger_time` DATETIME COMMENT '首次触发时间',
    `last_trigger_time` DATETIME COMMENT '末次触发时间',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stat_date`, `event_type`, `event_name`, `platform`),
    KEY `idx_event_date` (`event_name`, `stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='事件统计日汇总表';

-- 用户活跃日汇总表（用户-日粒度）
CREATE TABLE IF NOT EXISTS `dws_user_active_daily` (
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',

    -- 登录统计
    `login_count` INT UNSIGNED DEFAULT 0 COMMENT '当日登录次数',
    `first_login_time` DATETIME COMMENT '首次登录时间',
    `last_login_time` DATETIME COMMENT '末次登录时间',

    -- 活跃标识
    `is_active` TINYINT DEFAULT 1 COMMENT '是否活跃: 0否 1是',
    `is_new_user` TINYINT DEFAULT 0 COMMENT '是否新用户: 0否 1是',
    `is_return_user` TINYINT DEFAULT 0 COMMENT '是否回流用户: 0否 1是',

    -- 访问页面数
    `view_page_count` INT UNSIGNED DEFAULT 0 COMMENT '访问页面数',
    `view_page_list` VARCHAR(500) COMMENT '访问页面列表(逗号分隔)',

    -- 设备信息
    `device_type` TINYINT COMMENT '设备类型',
    `platform` VARCHAR(16) COMMENT '平台',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stat_date`, `user_id`),
    KEY `idx_user_date` (`user_id`, `stat_date`),
    KEY `idx_new_user` (`stat_date`, `is_new_user`),
    KEY `idx_active` (`stat_date`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户活跃日汇总表';

-- 用户活跃月汇总表
CREATE TABLE IF NOT EXISTS `dws_user_active_monthly` (
    `stat_month` VARCHAR(6) NOT NULL COMMENT '统计月份 YYYYMM',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',

    -- 月度统计
    `active_days` INT UNSIGNED DEFAULT 0 COMMENT '活跃天数',
    `total_login_count` INT UNSIGNED DEFAULT 0 COMMENT '总登录次数',
    `first_login_date` DATE COMMENT '首次登录日期',
    `last_login_date` DATE COMMENT '末次登录日期',

    -- 价值分层
    `rfm_recency` INT COMMENT 'R值: 最近一次登录距今天数',
    `rfm_frequency` INT COMMENT 'F值: 月登录次数',
    `user_level` VARCHAR(16) COMMENT '用户分层: 高价值/活跃/沉默/流失',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stat_month`, `user_id`),
    KEY `idx_user_month` (`user_id`, `stat_month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户活跃月汇总表';

-- 新增用户日汇总
CREATE TABLE IF NOT EXISTS `dws_new_user_daily` (
    `stat_date` DATE NOT NULL COMMENT '统计日期(注册日期)',
    `channel` VARCHAR(32) NOT NULL DEFAULT 'ALL' COMMENT '渠道(ALL表示全部)',
    `platform` VARCHAR(16) NOT NULL DEFAULT 'ALL' COMMENT '平台(ALL表示全部)',
    `app_version` VARCHAR(16) NOT NULL DEFAULT 'ALL' COMMENT '版本(ALL表示全部)',
    `new_user_count` BIGINT UNSIGNED DEFAULT 0 COMMENT '新增用户数',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`stat_date`, `channel`, `platform`, `app_version`),
    KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='新增用户日汇总';

-- 用户留存率日汇总（核心留存表，支持 D1/D3/D7/D14/D30 多维度）
CREATE TABLE IF NOT EXISTS `dws_retention_daily` (
    `register_date` DATE NOT NULL COMMENT '注册日期',
    `channel` VARCHAR(32) NOT NULL DEFAULT 'ALL' COMMENT '渠道',
    `platform` VARCHAR(16) NOT NULL DEFAULT 'ALL' COMMENT '平台',
    `app_version` VARCHAR(16) NOT NULL DEFAULT 'ALL' COMMENT '版本',
    `new_users` BIGINT UNSIGNED DEFAULT 0 COMMENT '新增用户数',
    `retained_1d` BIGINT UNSIGNED DEFAULT 0 COMMENT '次日留存数',
    `retained_3d` BIGINT UNSIGNED DEFAULT 0 COMMENT '3日留存数',
    `retained_7d` BIGINT UNSIGNED DEFAULT 0 COMMENT '7日留存数',
    `retained_14d` BIGINT UNSIGNED DEFAULT 0 COMMENT '14日留存数',
    `retained_30d` BIGINT UNSIGNED DEFAULT 0 COMMENT '30日留存数',
    `rate_1d` DECIMAL(5,2) DEFAULT 0.00 COMMENT '次日留存率%',
    `rate_3d` DECIMAL(5,2) DEFAULT 0.00 COMMENT '3日留存率%',
    `rate_7d` DECIMAL(5,2) DEFAULT 0.00 COMMENT '7日留存率%',
    `rate_14d` DECIMAL(5,2) DEFAULT 0.00 COMMENT '14日留存率%',
    `rate_30d` DECIMAL(5,2) DEFAULT 0.00 COMMENT '30日留存率%',
    `calc_time` DATETIME COMMENT '计算完成时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`register_date`, `channel`, `platform`, `app_version`),
    KEY `idx_register_date` (`register_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户留存率日汇总';

-- 渠道效果分析表
CREATE TABLE IF NOT EXISTS `dws_channel_effect_daily` (
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `channel` VARCHAR(32) NOT NULL COMMENT '渠道',

    -- 新增
    `new_user_count` BIGINT UNSIGNED DEFAULT 0 COMMENT '新增用户数',
    `new_device_count` BIGINT UNSIGNED DEFAULT 0 COMMENT '新增设备数',

    -- 活跃
    `active_user_count` BIGINT UNSIGNED DEFAULT 0 COMMENT '活跃用户数',
    `active_device_count` BIGINT UNSIGNED DEFAULT 0 COMMENT '活跃设备数',

    -- 质量
    `next_day_retained` BIGINT UNSIGNED DEFAULT 0 COMMENT '次日留存数',
    `next_day_retention_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '次日留存率(%)',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stat_date`, `channel`),
    KEY `idx_channel_date` (`channel`, `stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='渠道效果分析表';

-- ============================================================
-- 4. ADS 层 - 应用数据（报表/标签，永久保留）
-- ============================================================

-- 用户标签表（最新标签快照）
CREATE TABLE IF NOT EXISTS `ads_user_tags` (
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',

    -- 基础属性
    `tag_gender` TINYINT COMMENT '性别标签: 0未知 1男 2女',
    `tag_age_group` VARCHAR(16) COMMENT '年龄段: 18-24/25-30/31-35...',
    `tag_city_level` VARCHAR(8) COMMENT '城市级别: 一线/二线/三线/其他',
    `tag_province` VARCHAR(32) COMMENT '省份',
    `tag_city` VARCHAR(32) COMMENT '城市',

    -- 行为标签
    `tag_is_active` TINYINT DEFAULT 0 COMMENT '是否活跃: 0否 1是',
    `tag_active_level` VARCHAR(16) COMMENT '活跃等级: 高/中/低',
    `tag_prefer_platform` VARCHAR(16) COMMENT '偏好平台: ios/android/web',

    -- 价值标签
    `tag_user_value` VARCHAR(16) COMMENT '用户价值: 高价值/重要/一般/低价值',
    `tag_lifecycle` VARCHAR(16) COMMENT '生命周期: 新用户/成长/成熟/衰退/流失',
    `tag_churn_risk` VARCHAR(8) COMMENT '流失风险: 高/中/低',

    -- RFM标签
    `tag_rfm_recency` INT COMMENT '最近一次活跃天数',
    `tag_rfm_frequency` INT COMMENT '近30天活跃次数',

    -- 标签更新时间
    `tags_version` VARCHAR(8) COMMENT '标签版本: YYYYMMDD',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`user_id`),
    KEY `idx_gender` (`tag_gender`),
    KEY `idx_city` (`tag_city`),
    KEY `idx_value` (`tag_user_value`),
    KEY `idx_lifecycle` (`tag_lifecycle`),
    KEY `idx_active` (`tag_is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户标签表';

-- 核心指标日报（用于管理驾驶舱）
CREATE TABLE IF NOT EXISTS `ads_core_metrics_daily` (
    `stat_date` DATE NOT NULL COMMENT '统计日期',

    -- 用户规模
    `dau` BIGINT UNSIGNED DEFAULT 0 COMMENT '日活跃用户数',
    `wau` BIGINT UNSIGNED DEFAULT 0 COMMENT '周活跃用户数',
    `mau` BIGINT UNSIGNED DEFAULT 0 COMMENT '月活跃用户数',
    `total_users` BIGINT UNSIGNED DEFAULT 0 COMMENT '累计用户数',

    -- 新增
    `new_users` BIGINT UNSIGNED DEFAULT 0 COMMENT '新增用户数',
    `new_devices` BIGINT UNSIGNED DEFAULT 0 COMMENT '新增设备数',

    -- 留存
    `next_day_retention_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '次日留存率(%)',
    `day7_retention_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '7日留存率(%)',
    `day30_retention_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '30日留存率(%)',

    -- 活跃质量
    `avg_login_per_user` DECIMAL(5,2) DEFAULT 0.00 COMMENT '人均登录次数',
    `avg_online_minutes` DECIMAL(6,2) DEFAULT 0.00 COMMENT '人均在线时长(分钟)',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`stat_date`),
    KEY `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='核心指标日报';

-- 实时指标表（配合 Redis 使用，MySQL 做持久化）
CREATE TABLE IF NOT EXISTS `ads_realtime_metrics` (
    `metric_name` VARCHAR(64) NOT NULL COMMENT '指标名称',
    `metric_date` DATE NOT NULL COMMENT '日期',
    `metric_hour` TINYINT NOT NULL COMMENT '小时 0-23',

    `metric_value` BIGINT UNSIGNED DEFAULT 0 COMMENT '指标值',
    `metric_detail` JSON COMMENT '明细数据',

    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`metric_name`, `metric_date`, `metric_hour`),
    KEY `idx_date_hour` (`metric_date`, `metric_hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实时指标表';

-- 同期群留存分析（包含平均生命周期）
CREATE TABLE IF NOT EXISTS `ads_cohort_analysis` (
    `cohort_date` DATE NOT NULL COMMENT '同期群日期',
    `cohort_type` VARCHAR(16) NOT NULL COMMENT '类型: day/week/month',
    `channel` VARCHAR(32) NOT NULL DEFAULT 'ALL',
    `platform` VARCHAR(16) NOT NULL DEFAULT 'ALL',
    `cohort_size` BIGINT UNSIGNED DEFAULT 0 COMMENT '同期群用户数',
    `retention_matrix` JSON NOT NULL COMMENT '留存矩阵JSON',
    `avg_lifespan_days` DECIMAL(5,2) COMMENT '平均生命周期(天)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`cohort_date`, `cohort_type`, `channel`, `platform`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同期群留存分析';

-- 留存率报表缓存表（预计算常用查询）
CREATE TABLE IF NOT EXISTS `ads_retention_report` (
    `report_id` VARCHAR(64) NOT NULL COMMENT '报表ID(md5)',
    `report_type` VARCHAR(16) NOT NULL COMMENT '留存类型: new_user',
    `retention_period` VARCHAR(8) NOT NULL COMMENT '留存周期: d1/d7/d30',
    `date_from` DATE NOT NULL COMMENT '开始日期',
    `date_to` DATE NOT NULL COMMENT '结束日期',
    `channel` VARCHAR(32) DEFAULT 'ALL',
    `platform` VARCHAR(16) DEFAULT 'ALL',
    `retention_data` JSON NOT NULL COMMENT '[{date, new_count, retained_count, retention_rate}]',
    `avg_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '平均留存率',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `expire_at` DATETIME COMMENT '缓存过期时间',
    PRIMARY KEY (`report_id`),
    KEY `idx_expire` (`expire_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='留存率报表缓存表';

-- 留存率预警表
CREATE TABLE IF NOT EXISTS `ads_retention_alert` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `alert_date` DATE NOT NULL COMMENT '预警日期',
    `retention_type` VARCHAR(16) NOT NULL COMMENT '留存类型: new_user',
    `retention_period` VARCHAR(8) NOT NULL COMMENT '留存周期: d1/d7/d30',
    `channel` VARCHAR(32),
    `platform` VARCHAR(16),
    `current_rate` DECIMAL(5,2) COMMENT '当前留存率',
    `expected_rate` DECIMAL(5,2) COMMENT '预期留存率',
    `drop_percent` DECIMAL(5,2) COMMENT '下降幅度%',
    `alert_level` VARCHAR(8) COMMENT '预警级别: high/medium/low',
    `is_confirmed` TINYINT DEFAULT 0 COMMENT '是否已确认: 0否 1是',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_alert_date` (`alert_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='留存率预警表';

-- ============================================================
-- 5. 配置/辅助表
-- ============================================================

-- 数据质量监控表
CREATE TABLE IF NOT EXISTS `dwh_data_quality_log` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `check_date` DATE NOT NULL COMMENT '检查日期',
    `check_type` VARCHAR(32) NOT NULL COMMENT '检查类型: 完整性/一致性/及时性',
    `table_name` VARCHAR(64) NOT NULL COMMENT '表名',
    `check_result` TINYINT COMMENT '检查结果: 0异常 1正常',
    `error_count` INT UNSIGNED DEFAULT 0 COMMENT '异常数量',
    `error_detail` TEXT COMMENT '异常详情',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_check_date` (`check_date`, `check_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据质量监控日志';

-- 任务执行日志
CREATE TABLE IF NOT EXISTS `dwh_etl_job_log` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT,
    `job_name` VARCHAR(64) NOT NULL COMMENT '任务名称',
    `job_date` DATE NOT NULL COMMENT '数据日期',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME COMMENT '结束时间',
    `status` TINYINT COMMENT '状态: 0失败 1成功 2运行中',
    `error_msg` TEXT COMMENT '错误信息',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_job_date` (`job_name`, `job_date`),
    KEY `idx_job_date` (`job_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ETL任务执行日志';

-- 留存计算配置表
CREATE TABLE IF NOT EXISTS `dwh_retention_config` (
    `config_key` VARCHAR(64) NOT NULL,
    `config_value` VARCHAR(255),
    `description` VARCHAR(255),
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='留存计算配置';

-- 初始化留存计算配置
INSERT INTO `dwh_retention_config` (`config_key`, `config_value`, `description`) VALUES
('retention.periods', 'd1,d3,d7,d14,d30', '支持的留存周期'),
('retention.channels', 'ALL,AppStore,华为应用市场,小米应用市场', '需要计算的渠道'),
('retention.platforms', 'ALL,ios,android', '需要计算的平台'),
('alert.d1.threshold', '30.0', '次日留存预警阈值(%)'),
('alert.d7.threshold', '15.0', '7日留存预警阈值(%)'),
('alert.d30.threshold', '5.0', '30日留存预警阈值(%)'),
('calc.schedule', '0 3 * * *', '每日计算时间(cron)'),
('data.retention.days', '90', 'DWD层数据保留天数');
