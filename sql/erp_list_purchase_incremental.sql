-- ============================================================
-- 增量 SQL：采购记录（按店铺维度）
-- 用途：在已有 init 或建表基础上，增加供应商、采购单及采购明细（sid=1 默认店铺、sid=2 美国分店）
-- 内容：2 家供应商；sid=1 共 4 笔采购单及明细（商品 1-12）；sid=2 共 4 笔采购单及明细（商品 13-17）；每家供应商各 2 条补货
-- 可重复执行：ON DUPLICATE KEY UPDATE / NOT EXISTS 幂等
-- 依赖：erp_list_purchase 库、supplier / purchase_order / purchase_item 表
-- ============================================================

USE `erp_list_purchase`;

-- 1. 供应商（幂等）
INSERT INTO `supplier` (
  `id`, `supplier_name`, `supplier_code`, `contact_name`, `contact_phone`, `contact_email`, `address`, `status`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
(1, '华强北数码供应商', 'SUP-001', '张经理', '13800138001', 'supplier1@example.com', '深圳市福田区华强北路1号', 1, '默认店铺主供应商', NOW(), NOW(), 0),
(2, '深圳跨境供应链', 'SUP-002', '李经理', '13900139001', 'supplier2@example.com', '深圳市南山区前海路2号', 1, '美国分店供应商', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE
  `supplier_name` = VALUES(`supplier_name`),
  `contact_name` = VALUES(`contact_name`),
  `contact_phone` = VALUES(`contact_phone`),
  `address` = VALUES(`address`),
  `update_time` = NOW();

-- 2. 采购单（按店铺）
-- 2.1 sid=1 默认店铺 4 笔（供应商1：首单+补货 + 再两条补货）
INSERT INTO `purchase_order` (
  `purchase_no`, `supplier_id`, `supplier_name`, `zid`, `sid`, `total_amount`, `purchase_status`, `purchaser_id`, `purchaser_name`, `approve_time`, `expected_arrival_time`, `arrival_time`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('PO-Z1-S1-202601001', 1, '华强北数码供应商', '1', 1, 14250.00, 4, 1, '超级管理员', '2026-01-10 10:00:00', '2026-01-18 00:00:00', '2026-01-17 14:00:00', '默认店铺首单采购', '2026-01-08 09:00:00', NOW(), 0),
('PO-Z1-S1-202601002', 1, '华强北数码供应商', '1', 1, 12120.00, 2, 1, '超级管理员', '2026-01-15 11:00:00', '2026-01-25 00:00:00', NULL, '默认店铺补货', '2026-01-13 14:00:00', NOW(), 0),
('PO-Z1-S1-202601003', 1, '华强北数码供应商', '1', 1, 5350.00, 1, 1, '超级管理员', '2026-01-20 10:00:00', '2026-02-05 00:00:00', NULL, '供应商1补货-耳机键盘充电宝', '2026-01-18 14:00:00', NOW(), 0),
('PO-Z1-S1-202601004', 1, '华强北数码供应商', '1', 1, 4975.00, 0, 1, '超级管理员', NULL, '2026-02-10 00:00:00', NULL, '供应商1补货-手环保温杯鼠标', '2026-01-22 09:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE
  `supplier_name` = VALUES(`supplier_name`),
  `total_amount` = VALUES(`total_amount`),
  `purchase_status` = VALUES(`purchase_status`),
  `expected_arrival_time` = VALUES(`expected_arrival_time`),
  `update_time` = NOW();

-- 2.2 sid=2 美国分店 4 笔（供应商2：首单+补货 + 再两条补货）
INSERT INTO `purchase_order` (
  `purchase_no`, `supplier_id`, `supplier_name`, `zid`, `sid`, `total_amount`, `purchase_status`, `purchaser_id`, `purchaser_name`, `approve_time`, `expected_arrival_time`, `arrival_time`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('PO-Z1-S2-202601001', 2, '深圳跨境供应链', '1', 2, 18590.00, 4, 1, '超级管理员', '2026-01-12 09:00:00', '2026-01-22 00:00:00', '2026-01-21 16:00:00', '美国分店首单采购', '2026-01-09 10:00:00', NOW(), 0),
('PO-Z1-S2-202601002', 2, '深圳跨境供应链', '1', 2, 9610.00, 3, 1, '超级管理员', '2026-01-16 14:00:00', '2026-01-28 00:00:00', NULL, '美国分店补货', '2026-01-14 11:00:00', NOW(), 0),
('PO-Z1-S2-202601003', 2, '深圳跨境供应链', '1', 2, 6145.00, 2, 1, '超级管理员', '2026-01-21 11:00:00', '2026-02-08 00:00:00', NULL, '供应商2补货-耳机充电宝手环', '2026-01-19 10:00:00', NOW(), 0),
('PO-Z1-S2-202601004', 2, '深圳跨境供应链', '1', 2, 4000.00, 1, 1, '超级管理员', '2026-01-24 14:00:00', '2026-02-12 00:00:00', NULL, '供应商2补货-数据线收纳盒', '2026-01-23 08:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE
  `supplier_name` = VALUES(`supplier_name`),
  `total_amount` = VALUES(`total_amount`),
  `purchase_status` = VALUES(`purchase_status`),
  `expected_arrival_time` = VALUES(`expected_arrival_time`),
  `update_time` = NOW();

-- 3. 采购明细：sid=1 第一单 PO-Z1-S1-202601001（商品 1-6，已完成）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 1, '无线蓝牙耳机', 1, 'SKU001', 55.00, 80, 80, 4400.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 1) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 2, '机械键盘', 2, 'SKU002', 120.00, 30, 30, 3600.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 2) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 3, '便携充电宝', 3, 'SKU003', 45.00, 40, 40, 1800.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 3) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 4, '运动手环', 4, 'SKU004', 110.00, 15, 15, 1650.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 4) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 5, '保温杯', 5, 'SKU005', 45.00, 20, 20, 900.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 5) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 6, '无线鼠标', 6, 'SKU006', 95.00, 20, 20, 1900.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 6) LIMIT 1;

-- 4. 采购明细：sid=1 第二单 PO-Z1-S1-202601002（商品 7-12，采购中）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 7, 'USB-C 数据线', 7, 'SKU007', 25.00, 100, 0, 2500.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 7) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 8, '手机支架', 8, 'SKU008', 65.00, 40, 0, 2600.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 8) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 9, '桌面收纳盒', 9, 'SKU009', 85.00, 30, 0, 2550.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 9) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 10, '护眼台灯', 10, 'SKU010', 110.00, 12, 0, 1320.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 10) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 11, '静音小风扇', 11, 'SKU011', 35.00, 50, 0, 1750.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 11) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 12, '移动硬盘 1TB', 12, 'SKU012', 280.00, 5, 0, 1400.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 12) LIMIT 1;

-- 5. 采购明细：sid=2 第一单 PO-Z1-S2-202601001（商品 13-17，已完成）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 13, '无线蓝牙耳机', 13, 'SKU-US-001', 45.00, 120, 120, 5400.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 13) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 14, '便携充电宝', 14, 'SKU-US-002', 38.00, 80, 80, 3040.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 14) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 15, '运动手环', 15, 'SKU-US-003', 95.00, 40, 40, 3800.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 15) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 16, 'USB-C 数据线', 16, 'SKU-US-004', 35.00, 100, 100, 3500.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 16) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 17, '桌面收纳盒', 17, 'SKU-US-005', 95.00, 30, 30, 2850.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 17) LIMIT 1;

-- 6. 采购明细：sid=2 第二单 PO-Z1-S2-202601002（商品 13-17 补货，部分到货）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 13, '无线蓝牙耳机', 13, 'SKU-US-001', 45.00, 60, 30, 2700.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 13) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 14, '便携充电宝', 14, 'SKU-US-002', 38.00, 50, 50, 1900.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 14) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 15, '运动手环', 15, 'SKU-US-003', 95.00, 20, 0, 1900.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 15) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 16, 'USB-C 数据线', 16, 'SKU-US-004', 35.00, 40, 0, 1400.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 16) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 17, '桌面收纳盒', 17, 'SKU-US-005', 95.00, 18, 0, 1710.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601002' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 17) LIMIT 1;

-- 7. 采购明细：sid=1 第三单 PO-Z1-S1-202601003（供应商1补货：耳机、键盘、充电宝）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 1, '无线蓝牙耳机', 1, 'SKU001', 55.00, 40, 0, 2200.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601003' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 1) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 2, '机械键盘', 2, 'SKU002', 120.00, 15, 0, 1800.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601003' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 2) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 3, '便携充电宝', 3, 'SKU003', 45.00, 30, 0, 1350.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601003' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 3) LIMIT 1;

-- 8. 采购明细：sid=1 第四单 PO-Z1-S1-202601004（供应商1补货：手环、保温杯、鼠标）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 4, '运动手环', 4, 'SKU004', 110.00, 20, 0, 2200.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 4) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 5, '保温杯', 5, 'SKU005', 45.00, 30, 0, 1350.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 5) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 1, 6, '无线鼠标', 6, 'SKU006', 95.00, 15, 0, 1425.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S1-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 6) LIMIT 1;

-- 9. 采购明细：sid=2 第三单 PO-Z1-S2-202601003（供应商2补货：耳机、充电宝、手环）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 13, '无线蓝牙耳机', 13, 'SKU-US-001', 45.00, 50, 0, 2250.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601003' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 13) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 14, '便携充电宝', 14, 'SKU-US-002', 38.00, 40, 0, 1520.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601003' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 14) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 15, '运动手环', 15, 'SKU-US-003', 95.00, 25, 0, 2375.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601003' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 15) LIMIT 1;

-- 10. 采购明细：sid=2 第四单 PO-Z1-S2-202601004（供应商2补货：数据线、收纳盒）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 16, 'USB-C 数据线', 16, 'SKU-US-004', 35.00, 60, 0, 2100.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 16) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 17, '桌面收纳盒', 17, 'SKU-US-005', 95.00, 20, 0, 1900.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 17) LIMIT 1;
