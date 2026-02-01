-- ============================================================
-- 补货服务数据库表结构
-- 数据库：erp_list_replenishment
-- 说明：包含zid（公司ID）和sid（店铺ID，引用seller.id）字段
-- ============================================================

USE `erp_list_replenishment`;

-- 1. 补货单表
CREATE TABLE IF NOT EXISTS `replenishment_order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '补货单ID',
  `replenishment_no` VARCHAR(50) NOT NULL COMMENT '补货单号',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` VARCHAR(100) DEFAULT NULL COMMENT '仓库名称',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '补货总金额',
  `replenishment_status` TINYINT NOT NULL DEFAULT 0 COMMENT '补货状态：0-待审核，1-已审核，2-补货中，3-部分到货，4-已完成，5-已取消',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人姓名',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `approver_name` VARCHAR(50) DEFAULT NULL COMMENT '审核人姓名',
  `expected_arrival_time` DATETIME DEFAULT NULL COMMENT '预计到货时间',
  `arrival_time` DATETIME DEFAULT NULL COMMENT '实际到货时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_replenishment_no` (`replenishment_no`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_replenishment_status` (`replenishment_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='补货单表';

-- 2. 补货明细表
CREATE TABLE IF NOT EXISTS `replenishment_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `replenishment_id` BIGINT NOT NULL COMMENT '补货单ID',
  `replenishment_no` VARCHAR(50) NOT NULL COMMENT '补货单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `current_stock` INT DEFAULT 0 COMMENT '当前库存',
  `min_stock` INT DEFAULT 0 COMMENT '最低库存',
  `replenishment_quantity` INT NOT NULL COMMENT '补货数量',
  `arrival_quantity` INT DEFAULT 0 COMMENT '到货数量',
  `unit_price` DECIMAL(10,2) DEFAULT NULL COMMENT '单价',
  `total_price` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_replenishment_id` (`replenishment_id`),
  KEY `idx_replenishment_no` (`replenishment_no`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='补货明细表';

-- 3. 库存预警表
CREATE TABLE IF NOT EXISTS `inventory_alert` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` VARCHAR(100) DEFAULT NULL COMMENT '仓库名称',
  `current_stock` INT NOT NULL COMMENT '当前库存',
  `min_stock` INT NOT NULL COMMENT '最低库存',
  `alert_level` TINYINT NOT NULL COMMENT '预警级别：1-低库存，2-缺货',
  `alert_status` TINYINT DEFAULT 0 COMMENT '处理状态：0-未处理，1-已处理',
  `handler_id` BIGINT DEFAULT NULL COMMENT '处理人ID',
  `handler_name` VARCHAR(50) DEFAULT NULL COMMENT '处理人姓名',
  `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_alert_level` (`alert_level`),
  KEY `idx_alert_status` (`alert_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存预警表';

-- 4. 补货计划表
CREATE TABLE IF NOT EXISTS `replenishment_plan` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `plan_name` VARCHAR(100) NOT NULL COMMENT '计划名称',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `min_stock` INT NOT NULL COMMENT '最低库存',
  `max_stock` INT NOT NULL COMMENT '最高库存',
  `reorder_point` INT NOT NULL COMMENT '补货点',
  `reorder_quantity` INT NOT NULL COMMENT '补货数量',
  `plan_status` TINYINT DEFAULT 1 COMMENT '计划状态：0-禁用，1-启用',
  `next_replenishment_time` DATETIME DEFAULT NULL COMMENT '下次补货时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_plan_status` (`plan_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='补货计划表';


