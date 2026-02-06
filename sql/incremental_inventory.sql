-- ============================================================
-- 增量脚本：补货服务新增库存表 inventory（按公司+SKU 维度）
-- 执行前请确认已存在数据库 erp_list_replenishment
-- ============================================================

USE `erp_list_replenishment`;

CREATE TABLE IF NOT EXISTS `inventory` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `zid` VARCHAR(50) NOT NULL COMMENT '公司ID（Zone ID）',
  `product_id` BIGINT DEFAULT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) DEFAULT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID（与商品一一对应时可与 product_id 一致）',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `current_stock` INT NOT NULL DEFAULT 0 COMMENT '当前库存',
  `min_stock` INT NOT NULL DEFAULT 0 COMMENT '最低库存',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_zid_sku_id` (`zid`, `sku_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存表（按公司+SKU）';
