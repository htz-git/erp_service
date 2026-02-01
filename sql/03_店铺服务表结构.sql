-- ============================================================
-- 店铺服务数据库表结构
-- 数据库：erp_list_seller
-- 说明：seller表的id字段就是sid（店铺ID），其他表引用时使用seller.id作为sid值
-- ============================================================

USE `erp_list_seller`;

-- 1. 店铺授权表
CREATE TABLE IF NOT EXISTS `seller` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '店铺ID（这个id就是sid，其他表引用时使用这个id作为sid）',
  `sid` VARCHAR(50) NOT NULL COMMENT '店铺标识（Seller ID），与id字段相同，用于业务标识',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（所属公司）',
  `seller_name` VARCHAR(100) NOT NULL COMMENT '店铺名称',
  `platform` VARCHAR(50) DEFAULT NULL COMMENT '平台类型：amazon-亚马逊，ebay-eBay，aliexpress-速卖通等',
  `platform_account` VARCHAR(100) DEFAULT NULL COMMENT '平台账号',
  `access_token` VARCHAR(500) DEFAULT NULL COMMENT '访问令牌',
  `refresh_token` VARCHAR(500) DEFAULT NULL COMMENT '刷新令牌',
  `token_expire_time` DATETIME DEFAULT NULL COMMENT '令牌过期时间',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `authorize_time` DATETIME DEFAULT NULL COMMENT '授权时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sid` (`sid`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='店铺授权表';


