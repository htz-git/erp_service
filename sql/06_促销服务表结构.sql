-- ============================================================
-- 促销服务数据库表结构
-- 数据库：erp_list_promotion
-- ============================================================

USE `erp_list_promotion`;

-- 1. 促销活动表
CREATE TABLE IF NOT EXISTS `promotion` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '促销活动ID',
  `promotion_name` VARCHAR(100) NOT NULL COMMENT '促销活动名称',
  `promotion_type` VARCHAR(20) NOT NULL COMMENT '促销类型：discount-折扣，full_reduction-满减，gift-赠品',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME NOT NULL COMMENT '结束时间',
  `discount_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '折扣率（0-100）',
  `full_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '满减金额（满）',
  `reduction_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '满减金额（减）',
  `gift_product_id` BIGINT DEFAULT NULL COMMENT '赠品商品ID',
  `gift_quantity` INT DEFAULT NULL COMMENT '赠品数量',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '活动描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_promotion_type` (`promotion_type`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='促销活动表';

-- 2. 优惠券表
CREATE TABLE IF NOT EXISTS `coupon` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '优惠券ID',
  `coupon_name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
  `coupon_type` VARCHAR(20) NOT NULL COMMENT '优惠券类型：discount-折扣券，cash-现金券',
  `discount_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '折扣率（0-100）',
  `discount_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '优惠金额',
  `min_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '最低使用金额',
  `total_count` INT DEFAULT 0 COMMENT '发放总数（0表示不限制）',
  `used_count` INT DEFAULT 0 COMMENT '已使用数量',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME NOT NULL COMMENT '结束时间',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `description` VARCHAR(500) DEFAULT NULL COMMENT '优惠券描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_coupon_type` (`coupon_type`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券表';

-- 3. 用户优惠券表
CREATE TABLE IF NOT EXISTS `user_coupon` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `coupon_id` BIGINT NOT NULL COMMENT '优惠券ID',
  `coupon_code` VARCHAR(50) NOT NULL COMMENT '优惠券码',
  `status` TINYINT DEFAULT 0 COMMENT '状态：0-未使用，1-已使用，2-已过期',
  `order_id` BIGINT DEFAULT NULL COMMENT '使用订单ID',
  `use_time` DATETIME DEFAULT NULL COMMENT '使用时间',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_coupon_code` (`coupon_code`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券表';

-- 4. 促销规则表
CREATE TABLE IF NOT EXISTS `promotion_rule` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `promotion_id` BIGINT NOT NULL COMMENT '促销活动ID',
  `rule_type` VARCHAR(20) NOT NULL COMMENT '规则类型：product-商品，category-分类，brand-品牌',
  `rule_value` VARCHAR(255) NOT NULL COMMENT '规则值',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_promotion_id` (`promotion_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='促销规则表';


