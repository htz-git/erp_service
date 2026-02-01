-- ============================================================
-- 采购服务数据库表结构
-- 数据库：erp_list_purchase
-- 说明：包含zid（公司ID）和sid（店铺ID，引用seller.id）字段
-- ============================================================

USE `erp_list_purchase`;

-- 1. 供应商表
CREATE TABLE IF NOT EXISTS `supplier` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `supplier_name` VARCHAR(100) NOT NULL COMMENT '供应商名称',
  `supplier_code` VARCHAR(50) NOT NULL COMMENT '供应商编码',
  `contact_name` VARCHAR(50) DEFAULT NULL COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系人电话',
  `contact_email` VARCHAR(100) DEFAULT NULL COMMENT '联系人邮箱',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '地址',
  `bank_name` VARCHAR(100) DEFAULT NULL COMMENT '开户银行',
  `bank_account` VARCHAR(50) DEFAULT NULL COMMENT '银行账号',
  `tax_number` VARCHAR(50) DEFAULT NULL COMMENT '税号',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_supplier_code` (`supplier_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商表';

-- 2. 采购单表
CREATE TABLE IF NOT EXISTS `purchase_order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '采购单ID',
  `purchase_no` VARCHAR(50) NOT NULL COMMENT '采购单号',
  `supplier_id` BIGINT NOT NULL COMMENT '供应商ID',
  `supplier_name` VARCHAR(100) NOT NULL COMMENT '供应商名称',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '采购总金额',
  `purchase_status` TINYINT NOT NULL DEFAULT 0 COMMENT '采购状态：0-待审核，1-已审核，2-采购中，3-部分到货，4-已完成，5-已取消',
  `purchaser_id` BIGINT DEFAULT NULL COMMENT '采购员ID',
  `purchaser_name` VARCHAR(50) DEFAULT NULL COMMENT '采购员姓名',
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
  UNIQUE KEY `uk_purchase_no` (`purchase_no`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_purchase_status` (`purchase_status`),
  KEY `idx_purchaser_id` (`purchaser_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购单表';

-- 3. 采购明细表
CREATE TABLE IF NOT EXISTS `purchase_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` BIGINT NOT NULL COMMENT '采购单ID',
  `purchase_no` VARCHAR(50) NOT NULL COMMENT '采购单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `purchase_price` DECIMAL(10,2) NOT NULL COMMENT '采购单价',
  `purchase_quantity` INT NOT NULL COMMENT '采购数量',
  `arrival_quantity` INT DEFAULT 0 COMMENT '到货数量',
  `total_price` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_purchase_id` (`purchase_id`),
  KEY `idx_purchase_no` (`purchase_no`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购明细表';

-- 4. 采购状态记录表
CREATE TABLE IF NOT EXISTS `purchase_status_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` BIGINT NOT NULL COMMENT '采购单ID',
  `purchase_no` VARCHAR(50) NOT NULL COMMENT '采购单号',
  `old_status` TINYINT DEFAULT NULL COMMENT '原状态',
  `new_status` TINYINT NOT NULL COMMENT '新状态',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人姓名',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_purchase_id` (`purchase_id`),
  KEY `idx_purchase_no` (`purchase_no`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购状态记录表';


