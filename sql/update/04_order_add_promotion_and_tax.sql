-- ============================================================
-- 订单服务增量：order 表增加促销折扣金额、税费
-- 数据库：erp_list_order
-- 执行方式：在虚拟机中通过 Docker 执行，见 sql/update/README.md
-- ============================================================

USE `erp_list_order`;

-- order 表：促销折扣金额、税费（仅记录展示，不参与支付/促销计算）
ALTER TABLE `order` ADD COLUMN `promotion_discount_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '促销折扣金额';
ALTER TABLE `order` ADD COLUMN `tax_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '税费';
