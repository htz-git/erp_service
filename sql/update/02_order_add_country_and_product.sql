-- ============================================================
-- 订单服务增量：order 表增加 country_code，order_item 表增加 company_product_id
-- 数据库：erp_list_order
-- 执行方式：在虚拟机中通过 Docker 执行，见 sql/update/README.md
-- ============================================================

USE `erp_list_order`;

-- order 表：配送国家/地区代码
ALTER TABLE `order` ADD COLUMN `country_code` VARCHAR(10) DEFAULT NULL COMMENT '配送国家/地区代码（如 ISO 3166-1 alpha-2）';
ALTER TABLE `order` ADD INDEX `idx_country_code` (`country_code`);

-- order_item 表：关联公司商品ID（用于与平台商品配对）
ALTER TABLE `order_item` ADD COLUMN `company_product_id` BIGINT DEFAULT NULL COMMENT '关联公司商品ID（company_product.id），用于与平台商品配对';
ALTER TABLE `order_item` ADD INDEX `idx_company_product_id` (`company_product_id`);

