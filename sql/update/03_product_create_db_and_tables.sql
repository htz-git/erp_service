-- ============================================================
-- 商品服务：新建库 erp_list_product 及表 company_product
-- 执行方式：在虚拟机中通过 Docker 执行，见 sql/update/README.md
-- ============================================================

CREATE DATABASE IF NOT EXISTS `erp_list_product`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `erp_list_product`;

-- 公司商品表（公司上传的商品，用于与平台订单配对）
CREATE TABLE IF NOT EXISTS `company_product` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，可选）',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `product_code` VARCHAR(80) DEFAULT NULL COMMENT '商品编码',
  `sku_code` VARCHAR(80) DEFAULT NULL COMMENT 'SKU编码',
  `platform_sku` VARCHAR(80) DEFAULT NULL COMMENT '平台SKU（用于配对平台商品）',
  `image_url` VARCHAR(255) DEFAULT NULL COMMENT '商品图片URL',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_product_code` (`product_code`),
  KEY `idx_platform_sku` (`platform_sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公司商品表（用于与平台订单配对）';
