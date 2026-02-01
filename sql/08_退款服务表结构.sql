-- ============================================================
-- 退款服务数据库表结构
-- 数据库：erp_list_refund
-- 说明：包含zid（公司ID）和sid（店铺ID，引用seller.id）字段
-- ============================================================

USE `erp_list_refund`;

-- 1. 退款申请表
CREATE TABLE IF NOT EXISTS `refund_application` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '退款申请ID',
  `refund_no` VARCHAR(50) NOT NULL COMMENT '退款单号',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `payment_id` BIGINT NOT NULL COMMENT '支付ID',
  `payment_no` VARCHAR(50) NOT NULL COMMENT '支付单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `refund_amount` DECIMAL(10,2) NOT NULL COMMENT '退款金额',
  `refund_reason_id` BIGINT DEFAULT NULL COMMENT '退款原因ID',
  `refund_reason` VARCHAR(255) DEFAULT NULL COMMENT '退款原因',
  `refund_status` TINYINT NOT NULL DEFAULT 0 COMMENT '退款状态：0-待审核，1-审核通过，2-审核拒绝，3-退款中，4-退款成功，5-退款失败',
  `apply_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `approver_name` VARCHAR(50) DEFAULT NULL COMMENT '审核人姓名',
  `approve_remark` VARCHAR(255) DEFAULT NULL COMMENT '审核备注',
  `refund_time` DATETIME DEFAULT NULL COMMENT '退款时间',
  `third_party_refund_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方退款单号',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_refund_no` (`refund_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_payment_id` (`payment_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_refund_status` (`refund_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款申请表';

-- 2. 退款记录表
CREATE TABLE IF NOT EXISTS `refund_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `refund_id` BIGINT NOT NULL COMMENT '退款申请ID',
  `refund_no` VARCHAR(50) NOT NULL COMMENT '退款单号',
  `refund_amount` DECIMAL(10,2) NOT NULL COMMENT '退款金额',
  `refund_status` TINYINT NOT NULL COMMENT '退款状态：0-处理中，1-成功，2-失败',
  `third_party_refund_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方退款单号',
  `refund_time` DATETIME DEFAULT NULL COMMENT '退款时间',
  `error_message` VARCHAR(500) DEFAULT NULL COMMENT '错误信息',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_refund_id` (`refund_id`),
  KEY `idx_refund_no` (`refund_no`),
  KEY `idx_refund_status` (`refund_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款记录表';

-- 3. 退款原因表
CREATE TABLE IF NOT EXISTS `refund_reason` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '原因ID',
  `reason_name` VARCHAR(50) NOT NULL COMMENT '原因名称',
  `reason_code` VARCHAR(50) NOT NULL COMMENT '原因编码',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_reason_code` (`reason_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款原因表';

-- 初始化退款原因数据
INSERT INTO `refund_reason` (`reason_name`, `reason_code`, `sort_order`, `status`) VALUES
('商品质量问题', 'QUALITY_ISSUE', 1, 1),
('商品与描述不符', 'DESCRIPTION_MISMATCH', 2, 1),
('不想要了', 'DONT_WANT', 3, 1),
('收到商品损坏', 'DAMAGED', 4, 1),
('发错商品', 'WRONG_ITEM', 5, 1),
('其他原因', 'OTHER', 6, 1);


