-- ============================================================
-- 支付服务数据库表结构
-- 数据库：erp_list_payment
-- 说明：包含zid（公司ID）和sid（店铺ID，引用seller.id）字段
-- ============================================================

USE `erp_list_payment`;

-- 1. 支付记录表
CREATE TABLE IF NOT EXISTS `payment` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '支付ID',
  `payment_no` VARCHAR(50) NOT NULL COMMENT '支付单号',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `payment_method_id` BIGINT NOT NULL COMMENT '支付方式ID',
  `payment_method_name` VARCHAR(50) NOT NULL COMMENT '支付方式名称',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '支付金额',
  `payment_status` TINYINT NOT NULL DEFAULT 0 COMMENT '支付状态：0-待支付，1-支付成功，2-支付失败，3-已退款',
  `third_party_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方支付单号',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `refund_time` DATETIME DEFAULT NULL COMMENT '退款时间',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_payment_no` (`payment_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';

-- 2. 支付方式表
CREATE TABLE IF NOT EXISTS `payment_method` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '支付方式ID',
  `method_name` VARCHAR(50) NOT NULL COMMENT '支付方式名称',
  `method_code` VARCHAR(50) NOT NULL COMMENT '支付方式编码',
  `method_type` VARCHAR(20) NOT NULL COMMENT '支付类型：alipay-支付宝，wechat-微信，bank-银行卡',
  `icon` VARCHAR(255) DEFAULT NULL COMMENT '图标URL',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `config` TEXT DEFAULT NULL COMMENT '配置信息（JSON格式）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_method_code` (`method_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付方式表';

-- 3. 支付流水表
CREATE TABLE IF NOT EXISTS `payment_flow` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `payment_id` BIGINT NOT NULL COMMENT '支付ID',
  `payment_no` VARCHAR(50) NOT NULL COMMENT '支付单号',
  `flow_type` VARCHAR(20) NOT NULL COMMENT '流水类型：pay-支付，refund-退款',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '金额',
  `flow_status` TINYINT NOT NULL COMMENT '流水状态：0-处理中，1-成功，2-失败',
  `third_party_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方流水号',
  `request_data` TEXT DEFAULT NULL COMMENT '请求数据',
  `response_data` TEXT DEFAULT NULL COMMENT '响应数据',
  `error_message` VARCHAR(500) DEFAULT NULL COMMENT '错误信息',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_payment_id` (`payment_id`),
  KEY `idx_payment_no` (`payment_no`),
  KEY `idx_flow_type` (`flow_type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付流水表';

-- 初始化支付方式数据
INSERT INTO `payment_method` (`method_name`, `method_code`, `method_type`, `sort_order`, `status`) VALUES
('支付宝', 'ALIPAY', 'alipay', 1, 1),
('微信支付', 'WECHAT', 'wechat', 2, 1),
('银行卡', 'BANK', 'bank', 3, 1);


