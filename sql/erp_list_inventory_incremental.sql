-- ============================================================
-- ERP List 库存数据增量脚本（仅 inventory 表，对应 init 中 12 个商品）
-- 用途：已执行过初始化脚本但尚未插入库存时，可单独执行本文件补齐库存数据
-- 幂等：使用 ON DUPLICATE KEY UPDATE，可重复执行
-- 依赖：需先存在 erp_list_replenishment.inventory 表（含 sid 列，见建表汇总或迁移脚本）及 erp_list_product.company_product 中 id=1..12 商品
-- ============================================================

USE `erp_list_replenishment`;

INSERT INTO `inventory` (
  `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `current_stock`, `min_stock`, `create_time`, `update_time`
) VALUES
('1', 1, 1, '无线蓝牙耳机', 1, 'SKU001', 3, 5, NOW(), NOW()),
('1', 1, 2, '机械键盘', 2, 'SKU002', 2, 5, NOW(), NOW()),
('1', 1, 3, '便携充电宝', 3, 'SKU003', 0, 5, NOW(), NOW()),
('1', 1, 4, '运动手环', 4, 'SKU004', 5, 4, NOW(), NOW()),
('1', 1, 5, '保温杯', 5, 'SKU005', 1, 5, NOW(), NOW()),
('1', 1, 6, '无线鼠标', 6, 'SKU006', 4, 4, NOW(), NOW()),
('1', 1, 7, 'USB-C 数据线', 7, 'SKU007', 0, 6, NOW(), NOW()),
('1', 1, 8, '手机支架', 8, 'SKU008', 2, 5, NOW(), NOW()),
('1', 1, 9, '桌面收纳盒', 9, 'SKU009', 6, 3, NOW(), NOW()),
('1', 1, 10, '护眼台灯', 10, 'SKU010', 1, 5, NOW(), NOW()),
('1', 1, 11, '静音小风扇', 11, 'SKU011', 0, 5, NOW(), NOW()),
('1', 1, 12, '移动硬盘 1TB', 12, 'SKU012', 3, 5, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `product_name` = VALUES(`product_name`),
  `sku_code` = VALUES(`sku_code`),
  `current_stock` = VALUES(`current_stock`),
  `min_stock` = VALUES(`min_stock`),
  `update_time` = NOW();
