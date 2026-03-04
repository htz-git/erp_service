-- ============================================================
-- ERP List 建表后「初始化数据」一次性脚本（仅数据，不含建库建表）
-- 用途：建表（建表汇总.sql）执行完成后，执行本文件即可完成所有初始/演示数据
-- 可重复执行：使用 ON DUPLICATE KEY UPDATE / INSERT IGNORE / NOT EXISTS 保证幂等
-- 来源整合：原多份增量/演示 SQL 已合并为本文件，与建表汇总.sql 配套使用。
-- ============================================================

-- ===================== 1. 用户库 erp_list_user =====================

USE `erp_list_user`;

-- 1.1 权限表初始数据
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `sort_order`, `description`) VALUES
('店铺-新增', 'seller:create', 'api', 10, '创建店铺'),
('店铺-删除', 'seller:delete', 'api', 11, '删除店铺'),
('商品-新增', 'product:create', 'api', 20, '创建/上传商品'),
('商品-修改', 'product:update', 'api', 21, '修改商品'),
('商品-删除', 'product:delete', 'api', 22, '删除商品'),
('用户-新增', 'user:create', 'api', 30, '创建用户'),
('用户-修改', 'user:update', 'api', 31, '修改用户'),
('用户-删除', 'user:delete', 'api', 32, '删除用户'),
('管理员-后台', 'admin:access', 'api', 1, '平台管理员，可访问管理后台')
ON DUPLICATE KEY UPDATE `permission_name` = VALUES(`permission_name`);

-- 1.2 角色
INSERT INTO `role` (`id`, `role_name`, `role_code`, `description`, `status`, `create_time`, `update_time`, `deleted`) VALUES
(1, '超级管理员', 'SUPER_ADMIN', '超管，拥有全部权限', 1, NOW(), NOW(), 0),
(2, '平台管理员', 'PLATFORM_ADMIN', '平台管理员，可访问管理后台', 1, NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `role_name` = VALUES(`role_name`), `description` = VALUES(`description`);

-- 1.3 超管账号（id=1, zid=1, username=admin），密码 123456 的 BCrypt 密文
INSERT INTO `user` (
  `id`, `zid`, `username`, `password`, `real_name`, `phone`, `email`, `avatar`, `status`, `create_time`, `update_time`, `deleted`
) VALUES (
  1, '1', 'admin',
  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi',
  '超级管理员', '18250099985', '2281852840@qq.com', NULL, 1, NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `zid` = VALUES(`zid`), `real_name` = VALUES(`real_name`), `phone` = VALUES(`phone`), `email` = VALUES(`email`);

-- 1.4 平台管理员账号（zid=__platform__, username=root），默认密码 root，请登录后修改
INSERT INTO `user` (`zid`, `username`, `password`, `real_name`, `phone`, `email`, `status`, `create_time`, `update_time`, `deleted`)
VALUES ('__platform__', 'root', 'root', '平台管理员', NULL, NULL, 1, NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `zid` = VALUES(`zid`), `real_name` = VALUES(`real_name`);

-- 1.5 超管绑定角色
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`, `create_time`) VALUES (1, 1, NOW()), (1, 2, NOW());

-- 1.6 超管绑定全部权限（admin 拥有当前 permission 表全部权限）
INSERT INTO `user_permission` (`user_id`, `permission_id`, `create_time`)
SELECT u.id, p.id, NOW()
FROM `user` u
CROSS JOIN `permission` p
WHERE u.username = 'admin' AND (u.deleted = 0 OR u.deleted IS NULL)
  AND (p.deleted = 0 OR p.deleted IS NULL)
  AND NOT EXISTS (SELECT 1 FROM `user_permission` up WHERE up.user_id = u.id AND up.permission_id = p.id);

-- 1.7 平台管理员 root 绑定 admin:access
INSERT IGNORE INTO `user_permission` (`user_id`, `permission_id`, `create_time`)
SELECT u.id, p.id, NOW()
FROM `user` u
INNER JOIN `permission` p ON p.permission_code = 'admin:access' AND p.deleted = 0
WHERE u.username = 'root' AND u.deleted = 0
LIMIT 1;

-- 1.8 公司（zid=1）
INSERT INTO `company` (
  `id`, `company_name`, `contact_name`, `contact_phone`, `contact_email`, `address`, `status`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES (
  '1', 'erp公司', '超级管理员', '18250099985', '2281852840@qq.com', NULL, 1, '', NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `company_name` = VALUES(`company_name`), `contact_name` = VALUES(`contact_name`);


-- ===================== 2. 店铺库 erp_list_seller =====================

USE `erp_list_seller`;

INSERT INTO `seller` (
  `id`, `sid`, `user_id`, `zid`, `seller_name`, `platform`, `platform_account`, `status`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
  (1, 'S1', 1, '1', '默认店铺', 'amazon', 'seller-z1@example.com', 1, 'zid=1 公司店铺', NOW(), NOW(), 0),
  (2, 'S2', 1, '1', '美国分店', 'amazon', 'seller-us@example.com', 1, 'zid=1 美国分店，美国订单', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `seller_name` = VALUES(`seller_name`);


-- ===================== 3. 商品库 erp_list_product =====================

USE `erp_list_product`;

INSERT INTO `company_product` (
  `id`, `zid`, `sid`, `product_name`, `product_code`, `sku_code`, `platform_sku`, `image_url`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
(1, '1', 1, '无线蓝牙耳机', 'P001', 'SKU001', 'AMZ-SKU-001', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'zid=1 示例商品', NOW(), NOW(), 0),
(2, '1', 1, '机械键盘', 'P002', 'SKU002', 'AMZ-SKU-002', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(3, '1', 1, '便携充电宝', 'P003', 'SKU003', 'AMZ-SKU-003', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(4, '1', 1, '运动手环', 'P004', 'SKU004', 'AMZ-SKU-004', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(5, '1', 1, '保温杯', 'P005', 'SKU005', 'AMZ-SKU-005', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 'zid=1 商品', NOW(), NOW(), 0),
(6, '1', 1, '无线鼠标', 'P006', 'SKU006', 'AMZ-SKU-006', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(7, '1', 1, 'USB-C 数据线', 'P007', 'SKU007', 'AMZ-SKU-007', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', 'zid=1 商品', NOW(), NOW(), 0),
(8, '1', 1, '手机支架', 'P008', 'SKU008', 'AMZ-SKU-008', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 'zid=1 商品', NOW(), NOW(), 0),
(9, '1', 1, '桌面收纳盒', 'P009', 'SKU009', 'AMZ-SKU-009', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 'zid=1 商品', NOW(), NOW(), 0),
(10, '1', 1, '护眼台灯', 'P010', 'SKU010', 'AMZ-SKU-010', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 'zid=1 商品', NOW(), NOW(), 0),
(11, '1', 1, '静音小风扇', 'P011', 'SKU011', 'AMZ-SKU-011', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 'zid=1 商品', NOW(), NOW(), 0),
(12, '1', 1, '移动硬盘 1TB', 'P012', 'SKU012', 'AMZ-SKU-012', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 'zid=1 商品', NOW(), NOW(), 0),
(13, '1', 2, '无线蓝牙耳机', 'P-US-001', 'SKU-US-001', 'AMZ-US-001', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', '美国分店商品', NOW(), NOW(), 0),
(14, '1', 2, '便携充电宝', 'P-US-002', 'SKU-US-002', 'AMZ-US-002', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', '美国分店商品', NOW(), NOW(), 0),
(15, '1', 2, '运动手环', 'P-US-003', 'SKU-US-003', 'AMZ-US-003', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', '美国分店商品', NOW(), NOW(), 0),
(16, '1', 2, 'USB-C 数据线', 'P-US-004', 'SKU-US-004', 'AMZ-US-004', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', '美国分店商品', NOW(), NOW(), 0),
(17, '1', 2, '桌面收纳盒', 'P-US-005', 'SKU-US-005', 'AMZ-US-005', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', '美国分店商品', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `product_name` = VALUES(`product_name`), `image_url` = VALUES(`image_url`);


-- ===================== 3.5 补货库 erp_list_replenishment（库存表，对应上述 12 个商品） =====================

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
('1', 1, 12, '移动硬盘 1TB', 12, 'SKU012', 3, 5, NOW(), NOW()),
('1', 2, 13, '无线蓝牙耳机', 13, 'SKU-US-001', 2, 5, NOW(), NOW()),
('1', 2, 14, '便携充电宝', 14, 'SKU-US-002', 0, 5, NOW(), NOW()),
('1', 2, 15, '运动手环', 15, 'SKU-US-003', 4, 4, NOW(), NOW()),
('1', 2, 16, 'USB-C 数据线', 16, 'SKU-US-004', 1, 6, NOW(), NOW()),
('1', 2, 17, '桌面收纳盒', 17, 'SKU-US-005', 3, 4, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `product_name` = VALUES(`product_name`),
  `sku_code` = VALUES(`sku_code`),
  `current_stock` = VALUES(`current_stock`),
  `min_stock` = VALUES(`min_stock`),
  `update_time` = NOW();


-- ===================== 3.6 采购库 erp_list_purchase（供应商 + 按店铺采购单及明细） =====================

USE `erp_list_purchase`;

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

INSERT INTO `purchase_order` (
  `purchase_no`, `supplier_id`, `supplier_name`, `zid`, `sid`, `total_amount`, `purchase_status`, `purchaser_id`, `purchaser_name`, `approve_time`, `expected_arrival_time`, `arrival_time`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('PO-Z1-S1-202601001', 1, '华强北数码供应商', '1', 1, 14250.00, 4, 1, '超级管理员', '2026-01-10 10:00:00', '2026-01-18 00:00:00', '2026-01-17 14:00:00', '默认店铺首单采购', '2026-01-08 09:00:00', NOW(), 0),
('PO-Z1-S1-202601002', 1, '华强北数码供应商', '1', 1, 12120.00, 2, 1, '超级管理员', '2026-01-15 11:00:00', '2026-01-25 00:00:00', NULL, '默认店铺补货', '2026-01-13 14:00:00', NOW(), 0),
('PO-Z1-S1-202601003', 1, '华强北数码供应商', '1', 1, 5350.00, 1, 1, '超级管理员', '2026-01-20 10:00:00', '2026-02-05 00:00:00', NULL, '供应商1补货-耳机键盘充电宝', '2026-01-18 14:00:00', NOW(), 0),
('PO-Z1-S1-202601004', 1, '华强北数码供应商', '1', 1, 4975.00, 0, 1, '超级管理员', NULL, '2026-02-10 00:00:00', NULL, '供应商1补货-手环保温杯鼠标', '2026-01-22 09:00:00', NOW(), 0),
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

-- 采购明细：sid=1 第一单
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

-- 采购明细：sid=1 第二单
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

-- 采购明细：sid=2 第一单
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

-- 采购明细：sid=2 第二单
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

-- 采购明细：sid=1 第三单（供应商1补货）
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

-- 采购明细：sid=1 第四单（供应商1补货）
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

-- 采购明细：sid=2 第三单（供应商2补货）
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

-- 采购明细：sid=2 第四单（供应商2补货）
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 16, 'USB-C 数据线', 16, 'SKU-US-004', 35.00, 60, 0, 2100.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 16) LIMIT 1;
INSERT INTO `purchase_item` (`purchase_id`, `purchase_no`, `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `purchase_price`, `purchase_quantity`, `arrival_quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`purchase_no`, '1', 2, 17, '桌面收纳盒', 17, 'SKU-US-005', 95.00, 20, 0, 1900.00, o.`create_time`, NOW()
FROM `purchase_order` o WHERE o.`purchase_no` = 'PO-Z1-S2-202601004' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `purchase_item` pi WHERE pi.`purchase_id` = o.`id` AND pi.`product_id` = 17) LIMIT 1;


-- ===================== 4. 订单库 erp_list_order =====================

USE `erp_list_order`;

-- 4.1 订单主表（首单 + 2026-02-01～02-10 + 2026-02-18～02-24 补货样本 + 02-18～02-24 更多补货样本）
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('ORD-Z1-202602050001', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, NULL, '张三', '13800138000', '北京市朝阳区建国路1号', 'zid=1 示例订单', NOW(), NOW(), 0),
('ORD-Z1-202602010002', 1, '1', 1, 'CN', 299.00, 0.00, 0.00, 0.00, 299.00, 1, 1, '2026-02-01 14:20:00', '李四', '13900139000', '上海市浦东新区张江路2号', NULL, '2026-02-01 14:15:00', '2026-02-01 14:20:00', 0),
('ORD-Z1-202602020003', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, '2026-02-02 10:30:00', '王五', '13700137000', '广州市天河区体育西路3号', NULL, '2026-02-02 10:25:00', '2026-02-02 10:30:00', 0),
('ORD-Z1-202602030004', 1, '1', 1, 'CN', 696.00, 0.00, 0.00, 0.00, 696.00, 1, 1, '2026-02-03 16:00:00', '赵六', '13600136000', '深圳市南山区科技园4号', NULL, '2026-02-03 15:55:00', '2026-02-03 16:00:00', 0),
('ORD-Z1-202602040005', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 1, 1, '2026-02-04 09:45:00', '钱七', '13500135000', '杭州市西湖区文三路5号', NULL, '2026-02-04 09:40:00', '2026-02-04 09:45:00', 0),
('ORD-Z1-202602050006', 1, '1', 1, 'CN', 357.00, 0.00, 0.00, 0.00, 357.00, 1, 1, '2026-02-05 11:20:00', '孙八', '13400134000', '成都市武侯区天府大道6号', NULL, '2026-02-05 11:15:00', '2026-02-05 11:20:00', 0),
('ORD-Z1-202602060007', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '2026-02-06 08:30:00', '周九', '13300133000', '南京市鼓楼区中山路7号', NULL, '2026-02-06 08:25:00', '2026-02-06 08:30:00', 0),
('ORD-Z1-202602070008', 1, '1', 1, 'CN', 257.00, 0.00, 0.00, 0.00, 257.00, 1, 1, '2026-02-07 13:10:00', '吴十', '13200132000', '武汉市洪山区光谷大道8号', NULL, '2026-02-07 13:05:00', '2026-02-07 13:10:00', 0),
('ORD-Z1-202602080009', 1, '1', 1, 'CN', 412.00, 0.00, 0.00, 0.00, 412.00, 1, 1, '2026-02-08 17:50:00', '郑一', '13100131000', '西安市雁塔区高新路9号', NULL, '2026-02-08 17:45:00', '2026-02-08 17:50:00', 0),
('ORD-Z1-202602090010', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, '2026-02-09 12:00:00', '王二', '13000130000', '重庆市渝北区龙溪路10号', NULL, '2026-02-09 11:55:00', '2026-02-09 12:00:00', 0),
('ORD-Z1-202602100011', 1, '1', 1, 'CN', 534.00, 0.00, 0.00, 0.00, 534.00, 1, 1, '2026-02-10 15:40:00', '张三', '13800138000', '北京市朝阳区建国路1号', NULL, '2026-02-10 15:35:00', '2026-02-10 15:40:00', 0),
('ORD-Z1-202602180001', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '李四', '13900139001', '上海市浦东新区张江路1号', '补货样本', '2026-02-18 09:15:00', NOW(), 0),
('ORD-Z1-202602180002', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, NULL, '王五', '13900139002', '广州市天河区体育西路2号', '补货样本', '2026-02-18 10:30:00', NOW(), 0),
('ORD-Z1-202602190001', 1, '1', 1, 'CN', 356.00, 0.00, 0.00, 0.00, 356.00, 1, 1, NULL, '赵六', '13900139003', '深圳市南山区科技园3号', '补货样本', '2026-02-19 08:00:00', NOW(), 0),
('ORD-Z1-202602190002', 1, '1', 1, 'CN', 88.00, 0.00, 0.00, 0.00, 88.00, 1, 1, NULL, '钱七', '13900139004', '杭州市西湖区文三路4号', '补货样本', '2026-02-19 14:20:00', NOW(), 0),
('ORD-Z1-202602190003', 1, '1', 1, 'CN', 420.00, 10.00, 0.00, 0.00, 410.00, 1, 1, NULL, '孙八', '13900139005', '成都市武侯区天府大道5号', '补货样本', '2026-02-19 16:45:00', NOW(), 0),
('ORD-Z1-202602200001', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, NULL, '周九', '13900139006', '南京市鼓楼区中山路6号', '补货样本', '2026-02-20 09:00:00', NOW(), 0),
('ORD-Z1-202602200002', 1, '1', 1, 'CN', 297.00, 0.00, 0.00, 0.00, 297.00, 1, 1, NULL, '吴十', '13900139007', '武汉市洪山区光谷7号', '补货样本', '2026-02-20 11:30:00', NOW(), 0),
('ORD-Z1-202602200003', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, NULL, '郑一', '13900139008', '西安市雁塔区高新路8号', '补货样本', '2026-02-20 15:00:00', NOW(), 0),
('ORD-Z1-202602210001', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, NULL, '王二', '13900139009', '苏州市工业园区星海街9号', '补货样本', '2026-02-21 10:00:00', NOW(), 0),
('ORD-Z1-202602210002', 1, '1', 1, 'CN', 456.00, 0.00, 0.00, 0.00, 456.00, 1, 1, NULL, '陈三', '13900139010', '天津市滨海新区塘沽10号', '补货样本', '2026-02-21 13:20:00', NOW(), 0),
('ORD-Z1-202602220001', 1, '1', 1, 'CN', 128.00, 0.00, 0.00, 0.00, 128.00, 1, 1, NULL, '林四', '13900139011', '青岛市市南区香港路11号', '补货样本', '2026-02-22 08:30:00', NOW(), 0),
('ORD-Z1-202602220002', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, NULL, '黄五', '13900139012', '大连市中山区人民路12号', '补货样本', '2026-02-22 12:00:00', NOW(), 0),
('ORD-Z1-202602220003', 1, '1', 1, 'CN', 388.00, 0.00, 0.00, 0.00, 388.00, 1, 1, NULL, '刘六', '13900139013', '长沙市岳麓区麓山南路13号', '补货样本', '2026-02-22 17:00:00', NOW(), 0),
('ORD-Z1-202602230001', 1, '1', 1, 'CN', 268.00, 0.00, 0.00, 0.00, 268.00, 1, 1, NULL, '何七', '13900139014', '郑州市金水区花园路14号', '补货样本', '2026-02-23 09:45:00', NOW(), 0),
('ORD-Z1-202602230002', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, NULL, '徐八', '13900139015', '济南市历下区泉城路15号', '补货样本', '2026-02-23 14:10:00', NOW(), 0),
('ORD-Z1-202602240001', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, NULL, '朱九', '13900139016', '哈尔滨市南岗区西大直街16号', '补货样本', '2026-02-24 10:00:00', NOW(), 0),
('ORD-Z1-202602240002', 1, '1', 1, 'CN', 520.00, 20.00, 0.00, 0.00, 500.00, 1, 1, NULL, '马十', '13900139017', '厦门市思明区鹭江道17号', '补货样本', '2026-02-24 15:30:00', NOW(), 0),
-- 4.1 续：2026-02-18～02-24 更多补货样本订单（已存在商品 id 1～12）
('ORD-Z1-202602180003', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, NULL, '冯甲', '13900139018', '宁波市鄞州区中山东路18号', '补货样本', '2026-02-18 14:00:00', NOW(), 0),
('ORD-Z1-202602180004', 1, '1', 1, 'CN', 318.00, 0.00, 0.00, 0.00, 318.00, 1, 1, NULL, '褚乙', '13900139019', '无锡市滨湖区蠡湖大道19号', '补货样本', '2026-02-18 16:20:00', NOW(), 0),
('ORD-Z1-202602190004', 1, '1', 1, 'CN', 128.00, 0.00, 0.00, 0.00, 128.00, 1, 1, NULL, '卫丙', '13900139020', '佛山市南海区桂城20号', '补货样本', '2026-02-19 11:00:00', NOW(), 0),
('ORD-Z1-202602190005', 1, '1', 1, 'CN', 428.00, 0.00, 0.00, 0.00, 428.00, 1, 1, NULL, '蒋丁', '13900139021', '东莞市南城区鸿福路21号', '补货样本', '2026-02-19 18:30:00', NOW(), 0),
('ORD-Z1-202602200004', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '沈戊', '13900139022', '合肥市蜀山区长江西路22号', '补货样本', '2026-02-20 08:45:00', NOW(), 0),
('ORD-Z1-202602200005', 1, '1', 1, 'CN', 89.00, 0.00, 0.00, 0.00, 89.00, 1, 1, NULL, '韩己', '13900139023', '福州市鼓楼区五四路23号', '补货样本', '2026-02-20 14:10:00', NOW(), 0),
('ORD-Z1-202602210003', 1, '1', 1, 'CN', 368.00, 0.00, 0.00, 0.00, 368.00, 1, 1, NULL, '杨庚', '13900139024', '石家庄市裕华区槐安东路24号', '补货样本', '2026-02-21 09:30:00', NOW(), 0),
('ORD-Z1-202602210004', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, NULL, '朱辛', '13900139025', '南昌市红谷滩新区绿茵路25号', '补货样本', '2026-02-21 15:00:00', NOW(), 0),
('ORD-Z1-202602220004', 1, '1', 1, 'CN', 299.00, 0.00, 0.00, 0.00, 299.00, 1, 1, NULL, '秦壬', '13900139026', '昆明市官渡区春城路26号', '补货样本', '2026-02-22 10:20:00', NOW(), 0),
('ORD-Z1-202602220005', 1, '1', 1, 'CN', 69.00, 0.00, 0.00, 0.00, 69.00, 1, 1, NULL, '尤癸', '13900139027', '南宁市青秀区民族大道27号', '补货样本', '2026-02-22 16:45:00', NOW(), 0),
('ORD-Z1-202602230003', 1, '1', 1, 'CN', 219.00, 0.00, 0.00, 0.00, 219.00, 1, 1, NULL, '许子', '13900139028', '贵阳市观山湖区林城东路28号', '补货样本', '2026-02-23 08:00:00', NOW(), 0),
('ORD-Z1-202602230004', 1, '1', 1, 'CN', 339.00, 0.00, 0.00, 0.00, 339.00, 1, 1, NULL, '何丑', '13900139029', '太原市小店区坞城路29号', '补货样本', '2026-02-23 13:25:00', NOW(), 0),
('ORD-Z1-202602240003', 1, '1', 1, 'CN', 149.00, 0.00, 0.00, 0.00, 149.00, 1, 1, NULL, '吕寅', '13900139030', '兰州市城关区庆阳路30号', '补货样本', '2026-02-24 11:15:00', NOW(), 0),
('ORD-Z1-202602240004', 1, '1', 1, 'CN', 279.00, 0.00, 0.00, 0.00, 279.00, 1, 1, NULL, '施卯', '13900139031', '乌鲁木齐市天山区光明路31号', '补货样本', '2026-02-24 17:40:00', NOW(), 0),
-- 4.1 续：补足 2026-02-18～02-24 共 60 条订单（再增 24 条，已存在商品 id 1～12）
('ORD-Z1-202602180005', 1, '1', 1, 'CN', 168.00, 0.00, 0.00, 0.00, 168.00, 1, 1, NULL, '程辰', '13900139032', '珠海市香洲区情侣路32号', '补货样本', '2026-02-18 11:00:00', NOW(), 0),
('ORD-Z1-202602180006', 1, '1', 1, 'CN', 229.00, 0.00, 0.00, 0.00, 229.00, 1, 1, NULL, '曹巳', '13900139033', '中山市石岐区兴中道33号', '补货样本', '2026-02-18 14:30:00', NOW(), 0),
('ORD-Z1-202602180007', 1, '1', 1, 'CN', 89.00, 0.00, 0.00, 0.00, 89.00, 1, 1, NULL, '袁午', '13900139034', '惠州市惠城区江北34号', '补货样本', '2026-02-18 17:00:00', NOW(), 0),
('ORD-Z1-202602180008', 1, '1', 1, 'CN', 358.00, 0.00, 0.00, 0.00, 358.00, 1, 1, NULL, '邓未', '13900139035', '江门市蓬江区建设路35号', '补货样本', '2026-02-18 19:20:00', NOW(), 0),
('ORD-Z1-202602190006', 1, '1', 1, 'CN', 138.00, 0.00, 0.00, 0.00, 138.00, 1, 1, NULL, '彭申', '13900139036', '湛江市赤坎区椹川大道36号', '补货样本', '2026-02-19 09:00:00', NOW(), 0),
('ORD-Z1-202602190007', 1, '1', 1, 'CN', 268.00, 0.00, 0.00, 0.00, 268.00, 1, 1, NULL, '傅酉', '13900139037', '汕头市金平区金砂路37号', '补货样本', '2026-02-19 12:15:00', NOW(), 0),
('ORD-Z1-202602190008', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 1, 1, NULL, '曾戌', '13900139038', '韶关市浈江区解放路38号', '补货样本', '2026-02-19 15:40:00', NOW(), 0),
('ORD-Z1-202602200006', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, NULL, '肖亥', '13900139039', '肇庆市端州区天宁路39号', '补货样本', '2026-02-20 08:20:00', NOW(), 0),
('ORD-Z1-202602200007', 1, '1', 1, 'CN', 319.00, 0.00, 0.00, 0.00, 319.00, 1, 1, NULL, '田甲', '13900139040', '佛山市禅城区祖庙路40号', '补货样本', '2026-02-20 11:45:00', NOW(), 0),
('ORD-Z1-202602200008', 1, '1', 1, 'CN', 179.00, 0.00, 0.00, 0.00, 179.00, 1, 1, NULL, '董乙', '13900139041', '揭阳市榕城区临江北路41号', '补货样本', '2026-02-20 16:00:00', NOW(), 0),
('ORD-Z1-202602210005', 1, '1', 1, 'CN', 248.00, 0.00, 0.00, 0.00, 248.00, 1, 1, NULL, '潘丙', '13900139042', '南通市崇川区青年路42号', '补货样本', '2026-02-21 10:30:00', NOW(), 0),
('ORD-Z1-202602210006', 1, '1', 1, 'CN', 118.00, 0.00, 0.00, 0.00, 118.00, 1, 1, NULL, '戴丁', '13900139043', '常州市武进区延政路43号', '补货样本', '2026-02-21 13:50:00', NOW(), 0),
('ORD-Z1-202602210007', 1, '1', 1, 'CN', 398.00, 0.00, 0.00, 0.00, 398.00, 1, 1, NULL, '夏戊', '13900139044', '温州市鹿城区人民路44号', '补货样本', '2026-02-21 17:10:00', NOW(), 0),
('ORD-Z1-202602220006', 1, '1', 1, 'CN', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, '钟己', '13900139045', '嘉兴市南湖区中山路45号', '补货样本', '2026-02-22 09:20:00', NOW(), 0),
('ORD-Z1-202602220007', 1, '1', 1, 'CN', 279.00, 0.00, 0.00, 0.00, 279.00, 1, 1, NULL, '汪庚', '13900139046', '金华市婺城区双龙街46号', '补货样本', '2026-02-22 12:40:00', NOW(), 0),
('ORD-Z1-202602220008', 1, '1', 1, 'CN', 69.00, 0.00, 0.00, 0.00, 69.00, 1, 1, NULL, '任辛', '13900139047', '湖州市吴兴区苕溪路47号', '补货样本', '2026-02-22 15:50:00', NOW(), 0),
('ORD-Z1-202602230005', 1, '1', 1, 'CN', 189.00, 0.00, 0.00, 0.00, 189.00, 1, 1, NULL, '姜壬', '13900139048', '绍兴市越城区胜利路48号', '补货样本', '2026-02-23 08:30:00', NOW(), 0),
('ORD-Z1-202602230006', 1, '1', 1, 'CN', 329.00, 0.00, 0.00, 0.00, 329.00, 1, 1, NULL, '范癸', '13900139049', '台州市椒江区市府大道49号', '补货样本', '2026-02-23 11:00:00', NOW(), 0),
('ORD-Z1-202602230007', 1, '1', 1, 'CN', 109.00, 0.00, 0.00, 0.00, 109.00, 1, 1, NULL, '方子', '13900139050', '丽水市莲都区中山街50号', '补货样本', '2026-02-23 14:20:00', NOW(), 0),
('ORD-Z1-202602240005', 1, '1', 1, 'CN', 218.00, 0.00, 0.00, 0.00, 218.00, 1, 1, NULL, '石丑', '13900139051', '衢州市柯城区新桥街51号', '补货样本', '2026-02-24 08:45:00', NOW(), 0),
('ORD-Z1-202602240006', 1, '1', 1, 'CN', 148.00, 0.00, 0.00, 0.00, 148.00, 1, 1, NULL, '姚寅', '13900139052', '舟山市定海区解放路52号', '补货样本', '2026-02-24 12:10:00', NOW(), 0),
('ORD-Z1-202602240007', 1, '1', 1, 'CN', 368.00, 0.00, 0.00, 0.00, 368.00, 1, 1, NULL, '谭卯', '13900139053', '唐山市路南区新华道53号', '补货样本', '2026-02-24 14:30:00', NOW(), 0),
('ORD-Z1-202602240008', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '廖辰', '13900139054', '秦皇岛市海港区河北大街54号', '补货样本', '2026-02-24 18:00:00', NOW(), 0),
-- 4.1 续：2026-02-18～02-24 补足至 100 条订单（再增 40 条，含部分大单 10 件/单，买家名更真实含三字名）
('ORD-Z1-202602180009', 1, '1', 1, 'CN', 290.00, 0.00, 0.00, 0.00, 290.00, 1, 1, NULL, '王小明', '13900139055', '南京市玄武区珠江路55号', '补货样本', '2026-02-18 09:50:00', NOW(), 0),
('ORD-Z1-202602180010', 1, '1', 1, 'CN', 358.00, 0.00, 0.00, 0.00, 358.00, 1, 1, NULL, '李强', '13900139056', '苏州市姑苏区观前街56号', '补货样本', '2026-02-18 13:20:00', NOW(), 0),
('ORD-Z1-202602180011', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 1, 1, NULL, '陈大伟', '13900139057', '无锡市梁溪区中山路57号', '补货样本', '2026-02-18 16:40:00', NOW(), 0),
('ORD-Z1-202602180012', 1, '1', 1, 'CN', 418.00, 0.00, 0.00, 0.00, 418.00, 1, 1, NULL, '刘子涵', '13900139058', '常州市天宁区延陵路58号', '补货样本', '2026-02-18 19:10:00', NOW(), 0),
('ORD-Z1-202602190009', 1, '1', 1, 'CN', 990.00, 0.00, 0.00, 0.00, 990.00, 1, 1, NULL, '赵梦琪', '13900139059', '徐州市云龙区淮海路59号', '补货样本', '2026-02-19 08:30:00', NOW(), 0),
('ORD-Z1-202602190010', 1, '1', 1, 'CN', 267.00, 0.00, 0.00, 0.00, 267.00, 1, 1, NULL, '王芳', '13900139060', '南通市崇川区南大街60号', '补货样本', '2026-02-19 11:00:00', NOW(), 0),
('ORD-Z1-202602190011', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, NULL, '周俊杰', '13900139061', '扬州市邗江区文昌路61号', '补货样本', '2026-02-19 14:25:00', NOW(), 0),
('ORD-Z1-202602190012', 1, '1', 1, 'CN', 189.00, 0.00, 0.00, 0.00, 189.00, 1, 1, NULL, '陈静', '13900139062', '盐城市亭湖区解放路62号', '补货样本', '2026-02-19 17:50:00', NOW(), 0),
('ORD-Z1-202602200009', 1, '1', 1, 'CN', 590.00, 0.00, 0.00, 0.00, 590.00, 1, 1, NULL, '吴雨桐', '13900139063', '镇江市京口区中山东路63号', '补货样本', '2026-02-20 09:15:00', NOW(), 0),
('ORD-Z1-202602200010', 1, '1', 1, 'CN', 328.00, 0.00, 0.00, 0.00, 328.00, 1, 1, NULL, '刘洋', '13900139064', '泰州市海陵区青年路64号', '补货样本', '2026-02-20 12:40:00', NOW(), 0),
('ORD-Z1-202602200011', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, NULL, '郑心怡', '13900139065', '宿迁市宿城区洪泽湖路65号', '补货样本', '2026-02-20 15:00:00', NOW(), 0),
('ORD-Z1-202602200012', 1, '1', 1, 'CN', 456.00, 0.00, 0.00, 0.00, 456.00, 1, 1, NULL, '赵敏', '13900139066', '连云港市海州区苍梧路66号', '补货样本', '2026-02-20 18:20:00', NOW(), 0),
('ORD-Z1-202602200013', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, NULL, '孙志强', '13900139067', '淮安市清江浦区淮海西路67号', '补货样本', '2026-02-20 20:45:00', NOW(), 0),
('ORD-Z1-202602210008', 1, '1', 1, 'CN', 790.00, 0.00, 0.00, 0.00, 790.00, 1, 1, NULL, '黄雅婷', '13900139068', '杭州市西湖区文三路68号', '补货样本', '2026-02-21 08:00:00', NOW(), 0),
('ORD-Z1-202602210009', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '周杰', '13900139069', '宁波市鄞州区天童路69号', '补货样本', '2026-02-21 10:30:00', NOW(), 0),
('ORD-Z1-202602210010', 1, '1', 1, 'CN', 139.00, 0.00, 0.00, 0.00, 139.00, 1, 1, NULL, '林晓峰', '13900139070', '温州市鹿城区人民路70号', '补货样本', '2026-02-21 13:15:00', NOW(), 0),
('ORD-Z1-202602210011', 1, '1', 1, 'CN', 398.00, 0.00, 0.00, 0.00, 398.00, 1, 1, NULL, '吴磊', '13900139071', '嘉兴市南湖区中环东路71号', '补货样本', '2026-02-21 16:00:00', NOW(), 0),
('ORD-Z1-202602210012', 1, '1', 1, 'CN', 219.00, 0.00, 0.00, 0.00, 219.00, 1, 1, NULL, '何佳琪', '13900139072', '湖州市吴兴区苕溪路72号', '补货样本', '2026-02-21 18:30:00', NOW(), 0),
('ORD-Z1-202602210013', 1, '1', 1, 'CN', 89.00, 0.00, 0.00, 0.00, 89.00, 1, 1, NULL, '郑丽', '13900139073', '绍兴市越城区胜利路73号', '补货样本', '2026-02-21 20:45:00', NOW(), 0),
('ORD-Z1-202602220009', 1, '1', 1, 'CN', 290.00, 0.00, 0.00, 0.00, 290.00, 1, 1, NULL, '高文博', '13900139074', '金华市婺城区双龙街74号', '补货样本', '2026-02-22 08:20:00', NOW(), 0),
('ORD-Z1-202602220010', 1, '1', 1, 'CN', 168.00, 0.00, 0.00, 0.00, 168.00, 1, 1, NULL, '孙浩', '13900139075', '衢州市柯城区新桥街75号', '补货样本', '2026-02-22 11:00:00', NOW(), 0),
('ORD-Z1-202602220011', 1, '1', 1, 'CN', 299.00, 0.00, 0.00, 0.00, 299.00, 1, 1, NULL, '罗梦瑶', '13900139076', '舟山市定海区解放路76号', '补货样本', '2026-02-22 14:20:00', NOW(), 0),
('ORD-Z1-202602220012', 1, '1', 1, 'CN', 428.00, 0.00, 0.00, 0.00, 428.00, 1, 1, NULL, '黄薇', '13900139077', '台州市椒江区市府大道77号', '补货样本', '2026-02-22 17:40:00', NOW(), 0),
('ORD-Z1-202602220013', 1, '1', 1, 'CN', 109.00, 0.00, 0.00, 0.00, 109.00, 1, 1, NULL, '梁志明', '13900139078', '丽水市莲都区中山街78号', '补货样本', '2026-02-22 19:50:00', NOW(), 0),
('ORD-Z1-202602220014', 1, '1', 1, 'CN', 378.00, 0.00, 0.00, 0.00, 378.00, 1, 1, NULL, '林涛', '13900139079', '合肥市蜀山区长江西路79号', '补货样本', '2026-02-22 21:10:00', NOW(), 0),
('ORD-Z1-202602230008', 1, '1', 1, 'CN', 990.00, 0.00, 0.00, 0.00, 990.00, 1, 1, NULL, '宋雅静', '13900139080', '芜湖市镜湖区北京路80号', '补货样本', '2026-02-23 09:00:00', NOW(), 0),
('ORD-Z1-202602230009', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, NULL, '唐浩然', '13900139081', '蚌埠市蚌山区淮河路81号', '补货样本', '2026-02-23 11:30:00', NOW(), 0),
('ORD-Z1-202602230010', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '何芳', '13900139082', '淮南市田家庵区洞山路82号', '补货样本', '2026-02-23 14:00:00', NOW(), 0),
('ORD-Z1-202602230011', 1, '1', 1, 'CN', 69.00, 0.00, 0.00, 0.00, 69.00, 1, 1, NULL, '韩雪梅', '13900139083', '马鞍山市花山区湖东路83号', '补货样本', '2026-02-23 16:25:00', NOW(), 0),
('ORD-Z1-202602230012', 1, '1', 1, 'CN', 319.00, 0.00, 0.00, 0.00, 319.00, 1, 1, NULL, '高磊', '13900139084', '淮北市相山区孟山路84号', '补货样本', '2026-02-23 18:50:00', NOW(), 0),
('ORD-Z1-202602230013', 1, '1', 1, 'CN', 149.00, 0.00, 0.00, 0.00, 149.00, 1, 1, NULL, '冯建平', '13900139085', '铜陵市铜官区长江路85号', '补货样本', '2026-02-23 21:00:00', NOW(), 0),
('ORD-Z1-202602240009', 1, '1', 1, 'CN', 590.00, 0.00, 0.00, 0.00, 590.00, 1, 1, NULL, '曹明远', '13900139086', '福州市鼓楼区五四路86号', '补货样本', '2026-02-24 08:40:00', NOW(), 0),
('ORD-Z1-202602240010', 1, '1', 1, 'CN', 228.00, 0.00, 0.00, 0.00, 228.00, 1, 1, NULL, '罗敏', '13900139087', '厦门市思明区鹭江道87号', '补货样本', '2026-02-24 11:10:00', NOW(), 0),
('ORD-Z1-202602240011', 1, '1', 1, 'CN', 358.00, 0.00, 0.00, 0.00, 358.00, 1, 1, NULL, '梁静', '13900139088', '泉州市丰泽区田安路88号', '补货样本', '2026-02-24 13:35:00', NOW(), 0),
('ORD-Z1-202602240012', 1, '1', 1, 'CN', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, NULL, '宋伟', '13900139089', '漳州市芗城区胜利路89号', '补货样本', '2026-02-24 16:00:00', NOW(), 0),
('ORD-Z1-202602240013', 1, '1', 1, 'CN', 498.00, 0.00, 0.00, 0.00, 498.00, 1, 1, NULL, '唐丽', '13900139090', '莆田市城厢区荔城路90号', '补货样本', '2026-02-24 18:20:00', NOW(), 0),
('ORD-Z1-202602240014', 1, '1', 1, 'CN', 279.00, 0.00, 0.00, 0.00, 279.00, 1, 1, NULL, '韩刚', '13900139091', '三明市梅列区列东街91号', '补货样本', '2026-02-24 20:45:00', NOW(), 0),
('ORD-Z1-202602240015', 1, '1', 1, 'CN', 790.00, 0.00, 0.00, 0.00, 790.00, 1, 1, NULL, '冯娟', '13900139092', '南平市延平区滨江路92号', '补货样本', '2026-02-24 09:15:00', NOW(), 0),
('ORD-Z1-202602240016', 1, '1', 1, 'CN', 188.00, 0.00, 0.00, 0.00, 188.00, 1, 1, NULL, '曹磊', '13900139093', '龙岩市新罗区九一路93号', '补货样本', '2026-02-24 12:30:00', NOW(), 0),
('ORD-Z1-202602240017', 1, '1', 1, 'CN', 399.00, 0.00, 0.00, 0.00, 399.00, 1, 1, NULL, '李思远', '13900139094', '宁德市蕉城区闽东路94号', '补货样本', '2026-02-24 15:50:00', NOW(), 0),
-- 默认店铺 2 月再增 15 笔 (sid=1)
('ORD-Z1-202602230014', 1, '1', 1, 'CN', 268.00, 0.00, 0.00, 0.00, 268.00, 1, 1, NULL, '邓晓东', '13900139095', '黄山市屯溪区延安路95号', '补货样本', '2026-02-23 10:15:00', NOW(), 0),
('ORD-Z1-202602230015', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, NULL, '彭丽华', '13900139096', '滁州市琅琊区天长路96号', '补货样本', '2026-02-23 12:40:00', NOW(), 0),
('ORD-Z1-202602230016', 1, '1', 1, 'CN', 338.00, 0.00, 0.00, 0.00, 338.00, 1, 1, NULL, '蒋明', '13900139097', '阜阳市颍州区清河路97号', '补货样本', '2026-02-23 15:00:00', NOW(), 0),
('ORD-Z1-202602230017', 1, '1', 1, 'CN', 98.00, 0.00, 0.00, 0.00, 98.00, 1, 1, NULL, '谢芳', '13900139098', '六安市金安区梅山路98号', '补货样本', '2026-02-23 17:25:00', NOW(), 0),
('ORD-Z1-202602230018', 1, '1', 1, 'CN', 418.00, 0.00, 0.00, 0.00, 418.00, 1, 1, NULL, '丁伟', '13900139099', '宣城市宣州区叠嶂路99号', '补货样本', '2026-02-23 19:50:00', NOW(), 0),
('ORD-Z1-202602240018', 1, '1', 1, 'CN', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, '任静', '13900139100', '济南市历下区泉城路100号', '补货样本', '2026-02-24 08:00:00', NOW(), 0),
('ORD-Z1-202602240019', 1, '1', 1, 'CN', 289.00, 0.00, 0.00, 0.00, 289.00, 1, 1, NULL, '魏强', '13900139101', '青岛市市南区香港中路101号', '补货样本', '2026-02-24 10:20:00', NOW(), 0),
('ORD-Z1-202602240020', 1, '1', 1, 'CN', 237.00, 0.00, 0.00, 0.00, 237.00, 1, 1, NULL, '薛敏', '13900139102', '淄博市张店区金晶大道102号', '补货样本', '2026-02-24 12:45:00', NOW(), 0),
('ORD-Z1-202602240021', 1, '1', 1, 'CN', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, NULL, '叶磊', '13900139103', '烟台市芝罘区南大街103号', '补货样本', '2026-02-24 15:10:00', NOW(), 0),
('ORD-Z1-202602240022', 1, '1', 1, 'CN', 449.00, 0.00, 0.00, 0.00, 449.00, 1, 1, NULL, '潘晓燕', '13900139104', '潍坊市奎文区东风街104号', '补货样本', '2026-02-24 17:35:00', NOW(), 0),
('ORD-Z1-202602240023', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, NULL, '戴军', '13900139105', '临沂市兰山区沂蒙路105号', '补货样本', '2026-02-24 19:00:00', NOW(), 0),
('ORD-Z1-202602240024', 1, '1', 1, 'CN', 279.00, 0.00, 0.00, 0.00, 279.00, 1, 1, NULL, '夏丽', '13900139106', '德州市德城区东方红路106号', '补货样本', '2026-02-24 09:30:00', NOW(), 0),
('ORD-Z1-202602240025', 1, '1', 1, 'CN', 89.00, 0.00, 0.00, 0.00, 89.00, 1, 1, NULL, '钟涛', '13900139107', '聊城市东昌府区东昌路107号', '补货样本', '2026-02-24 11:55:00', NOW(), 0),
('ORD-Z1-202602240026', 1, '1', 1, 'CN', 529.00, 0.00, 0.00, 0.00, 529.00, 1, 1, NULL, '汪洋', '13900139108', '滨州市滨城区黄河八路108号', '补货样本', '2026-02-24 14:20:00', NOW(), 0),
('ORD-Z1-202602240027', 1, '1', 1, 'CN', 318.00, 0.00, 0.00, 0.00, 318.00, 1, 1, NULL, '田芳', '13900139109', '菏泽市牡丹区中华路109号', '补货样本', '2026-02-24 16:45:00', NOW(), 0),
-- 美国分店订单 (sid=2, zid=1, country_code=US)
('ORD-Z1-US-202602010001', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-01 15:00:00', 'John Smith', '+1-555-0101', '123 Main St, Los Angeles, CA 90001', 'US store', '2026-02-01 14:55:00', NOW(), 0),
('ORD-Z1-US-202602030001', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, '2026-02-03 11:20:00', 'Emily Johnson', '+1-555-0102', '456 Oak Ave, New York, NY 10001', 'US store', '2026-02-03 11:15:00', NOW(), 0),
('ORD-Z1-US-202602050001', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-05 09:30:00', 'Michael Williams', '+1-555-0103', '789 Pine Rd, Chicago, IL 60601', 'US store', '2026-02-05 09:25:00', NOW(), 0),
('ORD-Z1-US-202602070001', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-07 16:45:00', 'Sarah Brown', '+1-555-0104', '321 Elm St, Houston, TX 77001', 'US store', '2026-02-07 16:40:00', NOW(), 0),
('ORD-Z1-US-202602090001', 1, '1', 2, 'US', 199.00, 10.00, 0.00, 0.00, 189.00, 1, 1, NULL, 'David Davis', '+1-555-0105', '555 Cedar Ln, Phoenix, AZ 85001', 'US store', '2026-02-09 13:00:00', NOW(), 0),
('ORD-Z1-US-202602180001', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, NULL, 'Jessica Miller', '+1-555-0106', '100 Broadway, Seattle, WA 98101', 'US store', '2026-02-18 10:20:00', NOW(), 0),
('ORD-Z1-US-202602200001', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, NULL, 'Robert Wilson', '+1-555-0107', '200 5th Ave, Miami, FL 33101', 'US store', '2026-02-20 14:10:00', NOW(), 0),
('ORD-Z1-US-202602220001', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, 'Jennifer Taylor', '+1-555-0108', '300 Market St, San Francisco, CA 94102', 'US store', '2026-02-22 11:30:00', NOW(), 0),
-- 美国分店更多订单 (sid=2)
('ORD-Z1-US-202602020002', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, '2026-02-02 10:00:00', 'James Anderson', '+1-555-0201', '100 Wall St, New York, NY 10005', 'US store', '2026-02-02 09:55:00', NOW(), 0),
('ORD-Z1-US-202602040002', 1, '1', 2, 'US', 208.99, 0.00, 0.00, 0.00, 208.99, 1, 1, '2026-02-04 14:20:00', 'Mary Thomas', '+1-555-0202', '200 Lake Shore Dr, Chicago, IL 60611', 'US store', '2026-02-04 14:15:00', NOW(), 0),
('ORD-Z1-US-202602060002', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-06 11:30:00', 'Robert Jackson', '+1-555-0203', '500 Commerce St, Dallas, TX 75201', 'US store', '2026-02-06 11:25:00', NOW(), 0),
('ORD-Z1-US-202602080002', 1, '1', 2, 'US', 119.98, 0.00, 0.00, 0.00, 119.98, 1, 1, '2026-02-08 16:45:00', 'Patricia White', '+1-555-0204', '600 Peachtree St, Atlanta, GA 30308', 'US store', '2026-02-08 16:40:00', NOW(), 0),
('ORD-Z1-US-202602100002', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, '2026-02-10 09:15:00', 'Daniel Harris', '+1-555-0205', '700 Boylston St, Boston, MA 02116', 'US store', '2026-02-10 09:10:00', NOW(), 0),
('ORD-Z1-US-202602120002', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, '2026-02-12 13:00:00', 'Linda Martin', '+1-555-0206', '800 Market St, San Francisco, CA 94102', 'US store', '2026-02-12 12:55:00', NOW(), 0),
('ORD-Z1-US-202602140002', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-14 10:30:00', 'Joseph Garcia', '+1-555-0207', '900 Wilshire Blvd, Los Angeles, CA 90017', 'US store', '2026-02-14 10:25:00', NOW(), 0),
('ORD-Z1-US-202602160002', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-16 15:20:00', 'Barbara Martinez', '+1-555-0208', '1000 Pennsylvania Ave, Washington, DC 20004', 'US store', '2026-02-16 15:15:00', NOW(), 0),
('ORD-Z1-US-202602190002', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, NULL, 'Christopher Robinson', '+1-555-0209', '1100 Broadway, Seattle, WA 98122', 'US store', '2026-02-19 08:45:00', NOW(), 0),
('ORD-Z1-US-202602210002', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, NULL, 'Susan Clark', '+1-555-0210', '1200 Lincoln Rd, Miami Beach, FL 33139', 'US store', '2026-02-21 12:10:00', NOW(), 0),
('ORD-Z1-US-202602230002', 1, '1', 2, 'US', 288.99, 0.00, 0.00, 0.00, 288.99, 1, 1, NULL, 'Matthew Lewis', '+1-555-0211', '1300 Nicollet Mall, Minneapolis, MN 55403', 'US store', '2026-02-23 14:35:00', NOW(), 0),
('ORD-Z1-US-202602240002', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, NULL, 'Nancy Lee', '+1-555-0212', '1400 Main St, Denver, CO 80202', 'US store', '2026-02-24 09:00:00', NOW(), 0),
('ORD-Z1-US-202602110002', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, '2026-02-11 11:00:00', 'Mark Walker', '+1-555-0213', '1500 Elm St, Dallas, TX 75201', 'US store', '2026-02-11 10:55:00', NOW(), 0),
('ORD-Z1-US-202602130002', 1, '1', 2, 'US', 99.98, 0.00, 0.00, 0.00, 99.98, 1, 1, '2026-02-13 16:30:00', 'Betty Hall', '+1-555-0214', '1600 Amphitheatre Pkwy, Mountain View, CA 94043', 'US store', '2026-02-13 16:25:00', NOW(), 0),
('ORD-Z1-US-202602150002', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, '2026-02-15 08:20:00', 'Steven Allen', '+1-555-0215', '1700 Broadway, New York, NY 10019', 'US store', '2026-02-15 08:15:00', NOW(), 0),
('ORD-Z1-US-202602170002', 1, '1', 2, 'US', 189.99, 0.00, 0.00, 0.00, 189.99, 1, 1, '2026-02-17 13:45:00', 'Karen Young', '+1-555-0216', '1800 Oak St, Kansas City, MO 64108', 'US store', '2026-02-17 13:40:00', NOW(), 0),
('ORD-Z1-US-202602190003', 1, '1', 2, 'US', 109.98, 0.00, 0.00, 0.00, 109.98, 1, 1, NULL, 'Edward King', '+1-555-0217', '1900 Peachtree St, Atlanta, GA 30309', 'US store', '2026-02-19 17:00:00', NOW(), 0),
('ORD-Z1-US-202602200002', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, NULL, 'Donna Wright', '+1-555-0218', '2000 Canal St, New Orleans, LA 70112', 'US store', '2026-02-20 10:15:00', NOW(), 0),
('ORD-Z1-US-202602220002', 1, '1', 2, 'US', 219.98, 0.00, 0.00, 0.00, 219.98, 1, 1, NULL, 'Paul Scott', '+1-555-0219', '2100 Woodward Ave, Detroit, MI 48201', 'US store', '2026-02-22 15:40:00', NOW(), 0),
('ORD-Z1-US-202602240003', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, NULL, 'Carol Green', '+1-555-0220', '2200 E Camelback Rd, Phoenix, AZ 85016', 'US store', '2026-02-24 11:25:00', NOW(), 0),
-- 美国分店第三批订单 (sid=2, 再增 30 笔)
('ORD-Z1-US-202602010004', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-01 16:00:00', 'Andrew Adams', '+1-555-0301', '2300 S Las Vegas Blvd, Las Vegas, NV 89109', 'US store', '2026-02-01 15:55:00', NOW(), 0),
('ORD-Z1-US-202602020004', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-02 11:30:00', 'Helen Baker', '+1-555-0302', '2400 N Central Ave, Phoenix, AZ 85004', 'US store', '2026-02-02 11:25:00', NOW(), 0),
('ORD-Z1-US-202602030003', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, '2026-02-03 12:00:00', 'Kevin Campbell', '+1-555-0303', '2500 Victory Park Ln, Dallas, TX 75219', 'US store', '2026-02-03 11:55:00', NOW(), 0),
('ORD-Z1-US-202602040004', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, '2026-02-04 15:00:00', 'Laura Evans', '+1-555-0304', '2600 Benjamin Franklin Pkwy, Philadelphia, PA 19130', 'US store', '2026-02-04 14:55:00', NOW(), 0),
('ORD-Z1-US-202602050003', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-05 10:00:00', 'Brian Foster', '+1-555-0305', '2700 S River Rd, Des Plaines, IL 60018', 'US store', '2026-02-05 09:55:00', NOW(), 0),
('ORD-Z1-US-202602060004', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, '2026-02-06 12:30:00', 'Rachel Gordon', '+1-555-0306', '2800 Broadway, Oakland, CA 94612', 'US store', '2026-02-06 12:25:00', NOW(), 0),
('ORD-Z1-US-202602070003', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, '2026-02-07 17:30:00', 'Frank Hayes', '+1-555-0307', '2900 N Halsted St, Chicago, IL 60657', 'US store', '2026-02-07 17:25:00', NOW(), 0),
('ORD-Z1-US-202602080004', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, '2026-02-08 17:30:00', 'Michelle Jenkins', '+1-555-0308', '3000 St Paul St, Baltimore, MD 21218', 'US store', '2026-02-08 17:25:00', NOW(), 0),
('ORD-Z1-US-202602090004', 1, '1', 2, 'US', 168.99, 0.00, 0.00, 0.00, 168.99, 1, 1, NULL, 'Jason Kelly', '+1-555-0309', '3100 Wilson Blvd, Arlington, VA 22201', 'US store', '2026-02-09 14:00:00', NOW(), 0),
('ORD-Z1-US-202602100004', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-10 10:00:00', 'Amanda Lopez', '+1-555-0310', '3200 E 1st St, Los Angeles, CA 90063', 'US store', '2026-02-10 09:55:00', NOW(), 0),
('ORD-Z1-US-202602110004', 1, '1', 2, 'US', 119.98, 0.00, 0.00, 0.00, 119.98, 1, 1, '2026-02-11 12:00:00', 'Ryan Mitchell', '+1-555-0311', '3300 Peachtree Rd NE, Atlanta, GA 30326', 'US store', '2026-02-11 11:55:00', NOW(), 0),
('ORD-Z1-US-202602120004', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-12 14:00:00', 'Stephanie Nelson', '+1-555-0312', '3400 Carlisle St, Dallas, TX 75204', 'US store', '2026-02-12 13:55:00', NOW(), 0),
('ORD-Z1-US-202602130004', 1, '1', 2, 'US', 218.98, 0.00, 0.00, 0.00, 218.98, 1, 1, '2026-02-13 17:00:00', 'Eric Perez', '+1-555-0313', '3500 W Olive Ave, Burbank, CA 91505', 'US store', '2026-02-13 16:55:00', NOW(), 0),
('ORD-Z1-US-202602140004', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-14 11:00:00', 'Angela Roberts', '+1-555-0314', '3600 N Western Ave, Chicago, IL 60618', 'US store', '2026-02-14 10:55:00', NOW(), 0),
('ORD-Z1-US-202602150004', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, '2026-02-15 09:00:00', 'Timothy Turner', '+1-555-0315', '3700 Las Vegas Blvd S, Las Vegas, NV 89109', 'US store', '2026-02-15 08:55:00', NOW(), 0),
('ORD-Z1-US-202602160004', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, '2026-02-16 16:00:00', 'Rebecca Phillips', '+1-555-0316', '3800 Gaston Ave, Dallas, TX 75246', 'US store', '2026-02-16 15:55:00', NOW(), 0),
('ORD-Z1-US-202602170004', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-17 14:30:00', 'Nathan Campbell', '+1-555-0317', '3900 Chain Bridge Rd, Fairfax, VA 22030', 'US store', '2026-02-17 14:25:00', NOW(), 0),
('ORD-Z1-US-202602180004', 1, '1', 2, 'US', 279.98, 0.00, 0.00, 0.00, 279.98, 1, 1, NULL, 'Christina Parker', '+1-555-0318', '4000 5th Ave, Pittsburgh, PA 15213', 'US store', '2026-02-18 11:00:00', NOW(), 0),
('ORD-Z1-US-202602190005', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, NULL, 'Gregory Edwards', '+1-555-0319', '4100 Redwood Rd, Oakland, CA 94619', 'US store', '2026-02-19 09:30:00', NOW(), 0),
('ORD-Z1-US-202602200004', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, NULL, 'Samantha Collins', '+1-555-0320', '4200 N Central Expy, Dallas, TX 75206', 'US store', '2026-02-20 15:00:00', NOW(), 0),
('ORD-Z1-US-202602210004', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, NULL, 'Dennis Stewart', '+1-555-0321', '4300 W Flagler St, Miami, FL 33134', 'US store', '2026-02-21 13:20:00', NOW(), 0),
('ORD-Z1-US-202602220004', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, NULL, 'Katherine Sanchez', '+1-555-0322', '4400 S Broadway, Los Angeles, CA 90037', 'US store', '2026-02-22 12:40:00', NOW(), 0),
('ORD-Z1-US-202602230004', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, 'Jerry Morris', '+1-555-0323', '4500 France Ave S, Minneapolis, MN 55435', 'US store', '2026-02-23 16:00:00', NOW(), 0),
('ORD-Z1-US-202602240005', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, NULL, 'Deborah Rogers', '+1-555-0324', '4600 N 16th St, Phoenix, AZ 85016', 'US store', '2026-02-24 10:00:00', NOW(), 0),
('ORD-Z1-US-202602010005', 1, '1', 2, 'US', 189.99, 0.00, 0.00, 0.00, 189.99, 1, 1, '2026-02-01 18:00:00', 'Raymond Reed', '+1-555-0325', '4700 Millenia Blvd, Orlando, FL 32839', 'US store', '2026-02-01 17:55:00', NOW(), 0),
('ORD-Z1-US-202602030004', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-03 14:30:00', 'Cynthia Cook', '+1-555-0326', '4800 Sand Lake Rd, Orlando, FL 32819', 'US store', '2026-02-03 14:25:00', NOW(), 0),
('ORD-Z1-US-202602050004', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-05 11:00:00', 'Albert Morgan', '+1-555-0327', '4900 E Shea Blvd, Scottsdale, AZ 85254', 'US store', '2026-02-05 10:55:00', NOW(), 0),
('ORD-Z1-US-202602070004', 1, '1', 2, 'US', 99.98, 0.00, 0.00, 0.00, 99.98, 1, 1, '2026-02-07 18:00:00', 'Virginia Bell', '+1-555-0328', '5000 W 95th St, Overland Park, KS 66207', 'US store', '2026-02-07 17:55:00', NOW(), 0),
('ORD-Z1-US-202602090005', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, 'Russell Murphy', '+1-555-0329', '5100 Belt Line Rd, Dallas, TX 75254', 'US store', '2026-02-09 15:30:00', NOW(), 0),
('ORD-Z1-US-202602110005', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-11 13:00:00', 'Brenda Bailey', '+1-555-0330', '5200 E Williams Field Rd, Gilbert, AZ 85295', 'US store', '2026-02-11 12:55:00', NOW(), 0),
-- 美国分店 2 月再增 15 笔 (sid=2)
('ORD-Z1-US-202602120005', 1, '1', 2, 'US', 89.98, 0.00, 0.00, 0.00, 89.98, 1, 1, '2026-02-12 15:00:00', 'Henry Ward', '+1-555-0331', '5300 N Scottsdale Rd, Scottsdale, AZ 85250', 'US store', '2026-02-12 14:55:00', NOW(), 0),
('ORD-Z1-US-202602130005', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, '2026-02-13 11:30:00', 'Irene Fox', '+1-555-0332', '5400 S Lakeshore Dr, Tempe, AZ 85283', 'US store', '2026-02-13 11:25:00', NOW(), 0),
('ORD-Z1-US-202602140005', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-14 16:00:00', 'Jack Hill', '+1-555-0333', '5500 E Broadway Blvd, Tucson, AZ 85711', 'US store', '2026-02-14 15:55:00', NOW(), 0),
('ORD-Z1-US-202602150005', 1, '1', 2, 'US', 228.98, 0.00, 0.00, 0.00, 228.98, 1, 1, '2026-02-15 10:00:00', 'Grace Cole', '+1-555-0334', '5600 W Chandler Blvd, Chandler, AZ 85226', 'US store', '2026-02-15 09:55:00', NOW(), 0),
('ORD-Z1-US-202602160005', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-16 14:30:00', 'Victor Gray', '+1-555-0335', '5700 E Bell Rd, Scottsdale, AZ 85254', 'US store', '2026-02-16 14:25:00', NOW(), 0),
('ORD-Z1-US-202602170005', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-17 17:00:00', 'Nicole James', '+1-555-0336', '5800 N 19th Ave, Phoenix, AZ 85015', 'US store', '2026-02-17 16:55:00', NOW(), 0),
('ORD-Z1-US-202602180005', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, NULL, 'Oscar Watson', '+1-555-0337', '5900 E Thomas Rd, Scottsdale, AZ 85251', 'US store', '2026-02-18 13:20:00', NOW(), 0),
('ORD-Z1-US-202602190006', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, NULL, 'Megan Brooks', '+1-555-0338', '6000 E Shea Blvd, Scottsdale, AZ 85254', 'US store', '2026-02-19 09:45:00', NOW(), 0),
('ORD-Z1-US-202602200005', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, NULL, 'Keith Sanders', '+1-555-0339', '6100 N 27th Ave, Phoenix, AZ 85017', 'US store', '2026-02-20 15:10:00', NOW(), 0),
('ORD-Z1-US-202602210005', 1, '1', 2, 'US', 168.99, 0.00, 0.00, 0.00, 168.99, 1, 1, NULL, 'Rachel Price', '+1-555-0340', '6200 E Main St, Mesa, AZ 85205', 'US store', '2026-02-21 11:00:00', NOW(), 0),
('ORD-Z1-US-202602220005', 1, '1', 2, 'US', 109.98, 0.00, 0.00, 0.00, 109.98, 1, 1, NULL, 'Alan Bennett', '+1-555-0341', '6300 S Priest Dr, Tempe, AZ 85283', 'US store', '2026-02-22 16:30:00', NOW(), 0),
('ORD-Z1-US-202602230005', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, 'Diana Wood', '+1-555-0342', '6400 W Union Hills Dr, Glendale, AZ 85308', 'US store', '2026-02-23 10:15:00', NOW(), 0),
('ORD-Z1-US-202602240006', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, NULL, 'Peter Barnes', '+1-555-0343', '6500 N Pima Rd, Scottsdale, AZ 85252', 'US store', '2026-02-24 08:40:00', NOW(), 0),
('ORD-Z1-US-202602240007', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, NULL, 'Emma Ross', '+1-555-0344', '6600 E Cactus Rd, Scottsdale, AZ 85254', 'US store', '2026-02-24 12:00:00', NOW(), 0),
('ORD-Z1-US-202602240008', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, NULL, 'Bruce Henderson', '+1-555-0345', '6700 W Bell Rd, Glendale, AZ 85308', 'US store', '2026-02-24 15:20:00', NOW(), 0),
-- sid=1 第二批（更真实：部分已支付、备注多样、地址真实）
('ORD-Z1-202602200014', 1, '1', 1, 'CN', 277.00, 0.00, 0.00, 0.00, 277.00, 1, 1, '2026-02-20 22:05:00', '许志远', '13812341101', '郑州市金水区花园路39号', '加急 明天到', '2026-02-20 21:58:00', NOW(), 0),
('ORD-Z1-202602210014', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, NULL, '董晓雯', '13987651202', '武汉市洪山区光谷大道77号', '请发顺丰', '2026-02-21 09:12:00', NOW(), 0),
('ORD-Z1-202602210015', 1, '1', 1, 'CN', 367.00, 0.00, 0.00, 0.00, 367.00, 1, 1, '2026-02-21 11:40:00', '马俊杰', '13765432303', '西安市雁塔区高新路56号', '公司采购 需发票', '2026-02-21 11:35:00', NOW(), 0),
('ORD-Z1-202602220015', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '2026-02-22 14:20:00', '卢晓琳', '13698763404', '成都市武侯区天府大道中段666号', NULL, '2026-02-22 14:15:00', NOW(), 0),
('ORD-Z1-202602220016', 1, '1', 1, 'CN', 218.00, 0.00, 0.00, 0.00, 218.00, 1, 1, NULL, '江海涛', '13543214505', '南京市建邺区江东中路108号', '送礼品 不要放单', '2026-02-22 16:45:00', NOW(), 0),
('ORD-Z1-202602230019', 1, '1', 1, 'CN', 88.00, 0.00, 0.00, 0.00, 88.00, 1, 1, '2026-02-23 08:30:00', '白若兰', '13432105606', '苏州市工业园区星湖街328号', NULL, '2026-02-23 08:25:00', NOW(), 0),
('ORD-Z1-202602230020', 1, '1', 1, 'CN', 396.00, 0.00, 0.00, 0.00, 396.00, 1, 1, NULL, '石建国', '13321096707', '长沙市岳麓区麓山南路2号', '发票抬头：湖南XX科技', '2026-02-23 10:50:00', NOW(), 0),
('ORD-Z1-202602230021', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, '2026-02-23 13:15:00', '贺敏', '13210987808', '沈阳市和平区南京北街112号', NULL, '2026-02-23 13:10:00', NOW(), 0),
('ORD-Z1-202602240028', 1, '1', 1, 'CN', 79.00, 0.00, 0.00, 0.00, 79.00, 1, 1, '2026-02-24 07:45:00', '谭小军', '13109878909', '哈尔滨市南岗区西大直街92号', NULL, '2026-02-24 07:40:00', NOW(), 0),
('ORD-Z1-202602240029', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '邹雨晴', '13098789010', '杭州市余杭区文一西路969号', '放门口即可', '2026-02-24 09:20:00', NOW(), 0),
('ORD-Z1-202602240030', 1, '1', 1, 'CN', 189.00, 0.00, 0.00, 0.00, 189.00, 1, 1, '2026-02-24 11:55:00', '陆明辉', '12987690111', '广州市天河区体育西路103号', NULL, '2026-02-24 11:50:00', NOW(), 0),
('ORD-Z1-202602240031', 1, '1', 1, 'CN', 138.00, 0.00, 0.00, 0.00, 138.00, 1, 1, NULL, '孔雅琪', '12876501212', '深圳市南山区科技园南区R2-A栋', '工作日送', '2026-02-24 14:30:00', NOW(), 0),
('ORD-Z1-202602240032', 1, '1', 1, 'CN', 319.00, 0.00, 0.00, 0.00, 319.00, 1, 1, '2026-02-24 17:00:00', '崔浩然', '12765412313', '天津市河西区友谊路32号', NULL, '2026-02-24 16:55:00', NOW(), 0),
-- sid=2 第二批（更真实：部分已支付、多州地址、备注）
('ORD-Z1-US-202602100006', 1, '1', 2, 'US', 188.99, 0.00, 0.00, 0.00, 188.99, 1, 1, '2026-02-10 18:20:00', 'Laura Simmons', '+1-602-555-1001', '701 E Washington St, Phoenix, AZ 85004', 'Gift wrap please', '2026-02-10 18:15:00', NOW(), 0),
('ORD-Z1-US-202602140006', 1, '1', 2, 'US', 69.98, 0.00, 0.00, 0.00, 69.98, 1, 1, NULL, 'James Ortiz', '+1-303-555-1002', '1600 Broadway, Denver, CO 80202', NULL, '2026-02-14 10:40:00', NOW(), 0),
('ORD-Z1-US-202602160006', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, '2026-02-16 15:55:00', 'Patricia Reed', '+1-512-555-1003', '100 Congress Ave, Austin, TX 78701', 'Office delivery', '2026-02-16 15:50:00', NOW(), 0),
('ORD-Z1-US-202602180006', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, NULL, 'Daniel Cook', '+1-206-555-1004', '400 Broad St, Seattle, WA 98109', NULL, '2026-02-18 11:25:00', NOW(), 0),
('ORD-Z1-US-202602200006', 1, '1', 2, 'US', 119.98, 0.00, 0.00, 0.00, 119.98, 1, 1, '2026-02-20 16:10:00', 'Lisa Morgan', '+1-404-555-1005', '1 CNN Center, Atlanta, GA 30303', NULL, '2026-02-20 16:05:00', NOW(), 0),
('ORD-Z1-US-202602220006', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, 'Steven Cooper', '+1-617-555-1006', '1 Beacon St, Boston, MA 02108', 'Leave at door', '2026-02-22 09:35:00', NOW(), 0),
('ORD-Z1-US-202602230006', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, '2026-02-23 12:50:00', 'Karen Richardson', '+1-312-555-1007', '233 S Wacker Dr, Chicago, IL 60606', NULL, '2026-02-23 12:45:00', NOW(), 0),
('ORD-Z1-US-202602240009', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, NULL, 'Kevin Cox', '+1-305-555-1008', '1200 Ocean Dr, Miami Beach, FL 33139', NULL, '2026-02-24 08:15:00', NOW(), 0),
('ORD-Z1-US-202602240010', 1, '1', 2, 'US', 218.98, 0.00, 0.00, 0.00, 218.98, 1, 1, '2026-02-24 10:40:00', 'Susan Howard', '+1-214-555-1009', '1507 Main St, Dallas, TX 75201', 'Rush order', '2026-02-24 10:35:00', NOW(), 0),
('ORD-Z1-US-202602240011', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, NULL, 'Brian Ward', '+1-702-555-1010', '3708 Las Vegas Blvd S, Las Vegas, NV 89109', NULL, '2026-02-24 13:05:00', NOW(), 0),
('ORD-Z1-US-202602240012', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, '2026-02-24 15:30:00', 'Nancy Torres', '+1-619-555-1011', '600 B St, San Diego, CA 92101', NULL, '2026-02-24 15:25:00', NOW(), 0),
('ORD-Z1-US-202602240013', 1, '1', 2, 'US', 168.99, 0.00, 0.00, 0.00, 168.99, 1, 1, NULL, 'Gary Peterson', '+1-503-555-1012', '921 SW Washington St, Portland, OR 97205', 'Attn: Receiving', '2026-02-24 17:50:00', NOW(), 0),
-- sid=1 第三批（2月25-26日）
('ORD-Z1-202602250001', 1, '1', 1, 'CN', 268.00, 0.00, 0.00, 0.00, 268.00, 1, 1, '2026-02-25 10:20:00', '林志强', '12654321414', '福州市鼓楼区五四路118号', NULL, '2026-02-25 10:15:00', NOW(), 0),
('ORD-Z1-202602250002', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, NULL, '周美玲', '12543212515', '厦门市思明区鹭江道219号', '周末送', '2026-02-25 14:35:00', NOW(), 0),
('ORD-Z1-202602250003', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '2026-02-25 16:50:00', '吴俊峰', '12432103616', '南昌市东湖区中山路320号', NULL, '2026-02-25 16:45:00', NOW(), 0),
('ORD-Z1-202602250004', 1, '1', 1, 'CN', 367.00, 0.00, 0.00, 0.00, 367.00, 1, 1, NULL, '郑晓红', '12321094717', '合肥市蜀山区长江西路421号', '需发票', '2026-02-25 09:10:00', NOW(), 0),
('ORD-Z1-202602250005', 1, '1', 1, 'CN', 218.00, 0.00, 0.00, 0.00, 218.00, 1, 1, '2026-02-25 11:25:00', '王海波', '12210985818', '石家庄市长安区中山东路522号', NULL, '2026-02-25 11:20:00', NOW(), 0),
('ORD-Z1-202602250006', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, NULL, '黄雅琴', '12109876919', '太原市小店区坞城路623号', '送同事', '2026-02-25 15:40:00', NOW(), 0),
('ORD-Z1-202602250007', 1, '1', 1, 'CN', 318.00, 0.00, 0.00, 0.00, 318.00, 1, 1, '2026-02-25 17:55:00', '刘建国', '12098767020', '郑州市二七区大学路724号', NULL, '2026-02-25 17:50:00', NOW(), 0),
('ORD-Z1-202602250008', 1, '1', 1, 'CN', 88.00, 0.00, 0.00, 0.00, 88.00, 1, 1, NULL, '陈思琪', '11987658121', '南宁市青秀区民族大道825号', NULL, '2026-02-25 13:30:00', NOW(), 0),
('ORD-Z1-202602260001', 1, '1', 1, 'CN', 189.00, 0.00, 0.00, 0.00, 189.00, 1, 1, '2026-02-26 08:45:00', '杨明远', '11876549222', '昆明市五华区东风西路926号', '公司采购', '2026-02-26 08:40:00', NOW(), 0),
('ORD-Z1-202602260002', 1, '1', 1, 'CN', 138.00, 0.00, 0.00, 0.00, 138.00, 1, 1, NULL, '赵雪梅', '11765440323', '贵阳市南明区中华南路1027号', NULL, '2026-02-26 12:00:00', NOW(), 0),
-- sid=2 第三批（2月25-26日）
('ORD-Z1-US-202602250001', 1, '1', 2, 'US', 188.99, 0.00, 0.00, 0.00, 188.99, 1, 1, '2026-02-25 09:30:00', 'Rebecca Hayes', '+1-415-555-1013', '100 Market St, San Francisco, CA 94105', NULL, '2026-02-25 09:25:00', NOW(), 0),
('ORD-Z1-US-202602250002', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, NULL, 'Thomas Brooks', '+1-206-555-1014', '1500 4th Ave, Seattle, WA 98101', 'Gift wrap', '2026-02-25 13:45:00', NOW(), 0),
('ORD-Z1-US-202602250003', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-25 16:00:00', 'Margaret Watson', '+1-512-555-1015', '200 Congress Ave, Austin, TX 78701', NULL, '2026-02-25 15:55:00', NOW(), 0),
('ORD-Z1-US-202602250004', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, NULL, 'Christopher Sanders', '+1-303-555-1016', '1700 Broadway, Denver, CO 80290', NULL, '2026-02-25 10:15:00', NOW(), 0),
('ORD-Z1-US-202602250005', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, '2026-02-25 14:30:00', 'Dorothy Price', '+1-404-555-1017', '250 Piedmont Ave NE, Atlanta, GA 30308', 'Office', '2026-02-25 14:25:00', NOW(), 0),
('ORD-Z1-US-202602250006', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, NULL, 'Joseph Bennett', '+1-617-555-1018', '2 Beacon St, Boston, MA 02108', NULL, '2026-02-25 17:45:00', NOW(), 0),
('ORD-Z1-US-202602250007', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, '2026-02-25 11:00:00', 'Lisa Coleman', '+1-312-555-1019', '300 N State St, Chicago, IL 60654', NULL, '2026-02-25 10:55:00', NOW(), 0),
('ORD-Z1-US-202602250008', 1, '1', 2, 'US', 218.98, 0.00, 0.00, 0.00, 218.98, 1, 1, NULL, 'Daniel Stewart', '+1-214-555-1020', '1800 Main St, Dallas, TX 75201', 'Rush', '2026-02-25 15:20:00', NOW(), 0),
('ORD-Z1-US-202602260001', 1, '1', 2, 'US', 168.99, 0.00, 0.00, 0.00, 168.99, 1, 1, '2026-02-26 09:00:00', 'Betty Morris', '+1-702-555-1021', '3600 Las Vegas Blvd S, Las Vegas, NV 89109', NULL, '2026-02-26 08:55:00', NOW(), 0),
('ORD-Z1-US-202602260002', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, NULL, 'Mark Rogers', '+1-619-555-1022', '700 B St, San Diego, CA 92101', NULL, '2026-02-26 12:30:00', NOW(), 0),
-- sid=1 第四批（2月26-27日）
('ORD-Z1-202602260003', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, '2026-02-26 10:15:00', '孙丽娟', '11654331424', '兰州市城关区庆阳路1128号', NULL, '2026-02-26 10:10:00', NOW(), 0),
('ORD-Z1-202602260004', 1, '1', 1, 'CN', 279.00, 0.00, 0.00, 0.00, 279.00, 1, 1, NULL, '何志刚', '11543222525', '西宁市城东区东关大街1229号', '请发顺丰', '2026-02-26 14:30:00', NOW(), 0),
('ORD-Z1-202602260005', 1, '1', 1, 'CN', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-26 16:45:00', '高晓燕', '11432113626', '银川市兴庆区解放东街1330号', NULL, '2026-02-26 16:40:00', NOW(), 0),
('ORD-Z1-202602260006', 1, '1', 1, 'CN', 89.00, 0.00, 0.00, 0.00, 89.00, 1, 1, NULL, '冯建军', '11321004727', '乌鲁木齐市天山区中山路1431号', NULL, '2026-02-26 09:20:00', NOW(), 0),
('ORD-Z1-202602260007', 1, '1', 1, 'CN', 448.00, 0.00, 0.00, 0.00, 448.00, 1, 1, '2026-02-26 11:35:00', '曹敏华', '11210995828', '拉萨市城关区北京中路1532号', '公司采购', '2026-02-26 11:30:00', NOW(), 0),
('ORD-Z1-202602260008', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '袁志伟', '11109886929', '呼和浩特市新城区新华大街1633号', NULL, '2026-02-26 15:50:00', NOW(), 0),
('ORD-Z1-202602270001', 1, '1', 1, 'CN', 318.00, 0.00, 0.00, 0.00, 318.00, 1, 1, '2026-02-27 08:10:00', '邓秀英', '11098777030', '海口市龙华区滨海大道1734号', NULL, '2026-02-27 08:05:00', NOW(), 0),
('ORD-Z1-202602270002', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, NULL, '彭建华', '10987668131', '三亚市吉阳区迎宾路1835号', '周末送', '2026-02-27 12:25:00', NOW(), 0),
-- sid=2 第四批（2月26-27日）
('ORD-Z1-US-202602260003', 1, '1', 2, 'US', 109.98, 0.00, 0.00, 0.00, 109.98, 1, 1, '2026-02-26 10:00:00', 'Steven Reed', '+1-503-555-1023', '1000 SW Broadway, Portland, OR 97205', NULL, '2026-02-26 09:55:00', NOW(), 0),
('ORD-Z1-US-202602260004', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 1, 1, NULL, 'Angela Cook', '+1-415-555-1024', '50 Fremont St, San Francisco, CA 94105', 'Gift wrap', '2026-02-26 14:15:00', NOW(), 0),
('ORD-Z1-US-202602260005', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-26 16:30:00', 'Edward Bell', '+1-305-555-1025', '200 Biscayne Blvd, Miami, FL 33131', NULL, '2026-02-26 16:25:00', NOW(), 0),
('ORD-Z1-US-202602260006', 1, '1', 2, 'US', 168.99, 0.00, 0.00, 0.00, 168.99, 1, 1, NULL, 'Kimberly Bailey', '+1-713-555-1026', '1600 Smith St, Houston, TX 77002', NULL, '2026-02-26 09:45:00', NOW(), 0),
('ORD-Z1-US-202602260007', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, '2026-02-26 11:55:00', 'Donald Rivera', '+1-602-555-1027', '200 W Washington St, Phoenix, AZ 85003', NULL, '2026-02-26 11:50:00', NOW(), 0),
('ORD-Z1-US-202602260008', 1, '1', 2, 'US', 218.98, 0.00, 0.00, 0.00, 218.98, 1, 1, NULL, 'Donna Cooper', '+1-704-555-1028', '400 S Tryon St, Charlotte, NC 28202', 'Office', '2026-02-26 15:10:00', NOW(), 0),
('ORD-Z1-US-202602270001', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-27 08:30:00', 'Ronald Richardson', '+1-615-555-1029', '501 Broadway, Nashville, TN 37203', NULL, '2026-02-27 08:25:00', NOW(), 0),
('ORD-Z1-US-202602270002', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, NULL, 'Sandra Cox', '+1-801-555-1030', '50 S Main St, Salt Lake City, UT 84101', NULL, '2026-02-27 13:00:00', NOW(), 0),
-- 4.1 续：补充更多商品订单（中国 sid=1 销量高于美国 sid=2，与 erp_list_order_extra_sales_incremental.sql 一致）
('ORD-Z1-EX-CN-001', 1, '1', 1, 'CN', 297.00, 0.00, 0.00, 0.00, 297.00, 3, 1, '2026-01-20 14:20:00', '胡志强', '13810011001', '北京市海淀区中关村大街1号', NULL, '2026-01-20 14:15:00', NOW(), 0),
('ORD-Z1-EX-CN-002', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 3, 1, '2026-01-21 10:30:00', '谢美玲', '13810011002', '上海市徐汇区漕溪路2号', NULL, '2026-01-21 10:25:00', NOW(), 0),
('ORD-Z1-EX-CN-003', 1, '1', 1, 'CN', 534.00, 0.00, 0.00, 0.00, 534.00, 3, 1, '2026-01-22 16:45:00', '傅建国', '13810011003', '广州市越秀区中山五路3号', '公司采购', '2026-01-22 16:40:00', NOW(), 0),
('ORD-Z1-EX-CN-004', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 3, 1, '2026-01-23 09:15:00', '余晓芳', '13810011004', '深圳市福田区福华路4号', NULL, '2026-01-23 09:10:00', NOW(), 0),
('ORD-Z1-EX-CN-005', 1, '1', 1, 'CN', 412.00, 10.00, 0.00, 0.00, 402.00, 3, 1, '2026-01-24 11:50:00', '苏明', '13810011005', '杭州市西湖区文三路5号', NULL, '2026-01-24 11:45:00', NOW(), 0),
('ORD-Z1-EX-CN-006', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 3, 1, '2026-01-25 08:30:00', '卢海燕', '13810011006', '成都市武侯区天府大道6号', NULL, '2026-01-25 08:25:00', NOW(), 0),
('ORD-Z1-EX-CN-007', 1, '1', 1, 'CN', 356.00, 0.00, 0.00, 0.00, 356.00, 3, 1, '2026-01-26 13:20:00', '蒋涛', '13810011007', '南京市鼓楼区中山路7号', NULL, '2026-01-26 13:15:00', NOW(), 0),
('ORD-Z1-EX-CN-008', 1, '1', 1, 'CN', 267.00, 0.00, 0.00, 0.00, 267.00, 3, 1, '2026-01-27 15:40:00', '沈丽华', '13810011008', '武汉市江汉区解放大道8号', NULL, '2026-01-27 15:35:00', NOW(), 0),
('ORD-Z1-EX-CN-009', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 3, 1, '2026-01-28 10:00:00', '姚俊杰', '13810011009', '西安市雁塔区高新路9号', NULL, '2026-01-28 09:55:00', NOW(), 0),
('ORD-Z1-EX-CN-010', 1, '1', 1, 'CN', 696.00, 0.00, 0.00, 0.00, 696.00, 3, 1, '2026-01-29 17:10:00', '邵敏', '13810011010', '重庆市渝北区龙溪路10号', '多件送礼品', '2026-01-29 17:05:00', NOW(), 0),
('ORD-Z1-EX-CN-011', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 3, 1, '2026-02-01 14:25:00', '毛晓东', '13810011011', '郑州市金水区花园路11号', NULL, '2026-02-01 14:20:00', NOW(), 0),
('ORD-Z1-EX-CN-012', 1, '1', 1, 'CN', 387.00, 0.00, 0.00, 0.00, 387.00, 3, 1, '2026-02-02 09:40:00', '龚雪梅', '13810011012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-02 09:35:00', NOW(), 0),
('ORD-Z1-EX-CN-013', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 3, 1, '2026-02-03 11:55:00', '段志强', '13810011013', '济南市历下区泉城路13号', NULL, '2026-02-03 11:50:00', NOW(), 0),
('ORD-Z1-EX-CN-014', 1, '1', 1, 'CN', 534.00, 0.00, 0.00, 0.00, 534.00, 3, 1, '2026-02-05 16:30:00', '江雅琴', '13810011014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-05 16:25:00', NOW(), 0),
('ORD-Z1-EX-CN-015', 1, '1', 1, 'CN', 118.00, 0.00, 0.00, 0.00, 118.00, 3, 1, '2026-02-07 08:45:00', '钱浩', '13810011015', '福州市鼓楼区五四路15号', NULL, '2026-02-07 08:40:00', NOW(), 0),
('ORD-Z1-EX-CN-016', 1, '1', 1, 'CN', 277.00, 0.00, 0.00, 0.00, 277.00, 3, 1, '2026-02-10 12:10:00', '田芳', '13810011016', '厦门市思明区鹭江道16号', NULL, '2026-02-10 12:05:00', NOW(), 0),
('ORD-Z1-EX-CN-017', 1, '1', 1, 'CN', 456.00, 0.00, 0.00, 0.00, 456.00, 3, 1, '2026-02-12 15:20:00', '任磊', '13810011017', '合肥市蜀山区长江西路17号', '需发票', '2026-02-12 15:15:00', NOW(), 0),
('ORD-Z1-EX-CN-018', 1, '1', 1, 'CN', 89.00, 0.00, 0.00, 0.00, 89.00, 3, 1, '2026-02-14 10:35:00', '范晓琳', '13810011018', '南昌市红谷滩新区绿茵路18号', NULL, '2026-02-14 10:30:00', NOW(), 0),
('ORD-Z1-EX-CN-019', 1, '1', 1, 'CN', 318.00, 0.00, 0.00, 0.00, 318.00, 3, 1, '2026-02-18 13:50:00', '贺明远', '13810011019', '昆明市官渡区春城路19号', NULL, '2026-02-18 13:45:00', NOW(), 0),
('ORD-Z1-EX-CN-020', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 3, 1, '2026-02-20 09:05:00', '黎静', '13810011020', '南宁市青秀区民族大道20号', NULL, '2026-02-20 09:00:00', NOW(), 0),
('ORD-Z1-EX-CN-021', 1, '1', 1, 'CN', 378.00, 0.00, 0.00, 0.00, 378.00, 3, 1, '2026-02-22 16:15:00', '易涛', '13810011021', '贵阳市观山湖区林城东路21号', NULL, '2026-02-22 16:10:00', NOW(), 0),
('ORD-Z1-EX-CN-022', 1, '1', 1, 'CN', 148.00, 0.00, 0.00, 0.00, 148.00, 3, 1, '2026-02-24 11:40:00', '常丽娟', '13810011022', '兰州市城关区庆阳路22号', NULL, '2026-02-24 11:35:00', NOW(), 0),
('ORD-Z1-EX-CN-023', 1, '1', 1, 'CN', 528.00, 0.00, 0.00, 0.00, 528.00, 3, 1, '2026-02-25 14:00:00', '武建军', '13810011023', '乌鲁木齐市天山区光明路23号', '公司采购', '2026-02-25 13:55:00', NOW(), 0),
('ORD-Z1-EX-CN-024', 1, '1', 1, 'CN', 219.00, 0.00, 0.00, 0.00, 219.00, 3, 1, '2026-02-26 08:20:00', '乔晓燕', '13810011024', '海口市龙华区滨海大道24号', NULL, '2026-02-26 08:15:00', NOW(), 0),
('ORD-Z1-EX-CN-025', 1, '1', 1, 'CN', 339.00, 0.00, 0.00, 0.00, 339.00, 3, 1, '2026-02-26 17:45:00', '贺敏华', '13810011025', '三亚市吉阳区迎宾路25号', '周末送', '2026-02-26 17:40:00', NOW(), 0),
('ORD-Z1-EX-US-001', 1, '1', 2, 'US', 99.98, 0.00, 0.00, 0.00, 99.98, 3, 1, '2026-01-20 15:00:00', 'Brian Cooper', '+1-555-4001', '100 E Washington St, Phoenix, AZ 85004', NULL, '2026-01-20 14:55:00', NOW(), 0),
('ORD-Z1-EX-US-002', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 3, 1, '2026-01-22 11:20:00', 'Karen Richardson', '+1-555-4002', '200 N State St, Chicago, IL 60601', NULL, '2026-01-22 11:15:00', NOW(), 0),
('ORD-Z1-EX-US-003', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 3, 1, '2026-01-24 09:45:00', 'Steven Cox', '+1-555-4003', '300 5th Ave, New York, NY 10001', NULL, '2026-01-24 09:40:00', NOW(), 0),
('ORD-Z1-EX-US-004', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 3, 1, '2026-01-26 14:30:00', 'Betty Howard', '+1-555-4004', '400 Market St, San Francisco, CA 94105', NULL, '2026-01-26 14:25:00', NOW(), 0),
('ORD-Z1-EX-US-005', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 3, 1, '2026-01-28 10:15:00', 'Edward Ward', '+1-555-4005', '500 Peachtree St, Atlanta, GA 30308', NULL, '2026-01-28 10:10:00', NOW(), 0),
('ORD-Z1-EX-US-006', 1, '1', 2, 'US', 188.99, 0.00, 0.00, 0.00, 188.99, 3, 1, '2026-02-02 16:00:00', 'Sharon Torres', '+1-555-4006', '600 Main St, Houston, TX 77002', NULL, '2026-02-02 15:55:00', NOW(), 0),
('ORD-Z1-EX-US-007', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 3, 1, '2026-02-05 08:40:00', 'Jason Peterson', '+1-555-4007', '700 Broadway, Seattle, WA 98102', NULL, '2026-02-05 08:35:00', NOW(), 0),
('ORD-Z1-EX-US-008', 1, '1', 2, 'US', 218.98, 0.00, 0.00, 0.00, 218.98, 3, 1, '2026-02-08 12:25:00', 'Melissa Brooks', '+1-555-4008', '800 Boylston St, Boston, MA 02116', NULL, '2026-02-08 12:20:00', NOW(), 0),
('ORD-Z1-EX-US-009', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 3, 1, '2026-02-12 15:50:00', 'Gary Sanders', '+1-555-4009', '900 N Michigan Ave, Chicago, IL 60611', NULL, '2026-02-12 15:45:00', NOW(), 0),
('ORD-Z1-EX-US-010', 1, '1', 2, 'US', 168.99, 0.00, 0.00, 0.00, 168.99, 3, 1, '2026-02-15 10:10:00', 'Donna Price', '+1-555-4010', '1000 Wilshire Blvd, Los Angeles, CA 90017', NULL, '2026-02-15 10:05:00', NOW(), 0),
('ORD-Z1-EX-US-011', 1, '1', 2, 'US', 109.98, 0.00, 0.00, 0.00, 109.98, 3, 1, '2026-02-18 13:35:00', 'Raymond Bell', '+1-555-4011', '1100 Congress Ave, Austin, TX 78701', NULL, '2026-02-18 13:30:00', NOW(), 0),
('ORD-Z1-EX-US-012', 1, '1', 2, 'US', 199.98, 0.00, 0.00, 0.00, 199.98, 3, 1, '2026-02-21 09:00:00', 'Carol Reed', '+1-555-4012', '1200 Ocean Dr, Miami Beach, FL 33139', NULL, '2026-02-21 08:55:00', NOW(), 0),
('ORD-Z1-EX-US-013', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 3, 1, '2026-02-23 14:20:00', 'Ralph Cook', '+1-555-4013', '1300 Nicollet Mall, Minneapolis, MN 55403', NULL, '2026-02-23 14:15:00', NOW(), 0),
('ORD-Z1-EX-US-014', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 3, 1, '2026-02-25 11:45:00', 'Joyce Morgan', '+1-555-4014', '1400 Main St, Dallas, TX 75201', NULL, '2026-02-25 11:40:00', NOW(), 0),
('ORD-Z1-EX-US-015', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 3, 1, '2026-02-26 16:30:00', 'Eugene Bailey', '+1-555-4015', '1500 Pennsylvania Ave, Washington, DC 20004', NULL, '2026-02-26 16:25:00', NOW(), 0),
('ORD-Z1-EX-CN-026', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 3, 1, '2026-02-27 10:20:00', '林志伟', '13810011026', '石家庄市长安区中山东路26号', NULL, '2026-02-27 10:15:00', NOW(), 0),
('ORD-Z1-EX-CN-027', 1, '1', 1, 'CN', 398.00, 0.00, 0.00, 0.00, 398.00, 3, 1, '2026-02-28 14:35:00', '黄雅琪', '13810011027', '太原市小店区坞城路27号', NULL, '2026-02-28 14:30:00', NOW(), 0),
('ORD-Z1-EX-CN-028', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 3, 1, '2026-03-01 09:10:00', '周建华', '13810011028', '呼和浩特市新城区新华大街28号', NULL, '2026-03-01 09:05:00', NOW(), 0),
('ORD-Z1-EX-CN-029', 1, '1', 1, 'CN', 267.00, 0.00, 0.00, 0.00, 267.00, 3, 1, '2026-03-02 16:45:00', '吴晓红', '13810011029', '沈阳市和平区南京南街29号', NULL, '2026-03-02 16:40:00', NOW(), 0),
('ORD-Z1-EX-CN-030', 1, '1', 1, 'CN', 346.00, 0.00, 0.00, 0.00, 346.00, 3, 1, '2026-03-03 11:30:00', '郑明辉', '13810011030', '大连市中山区人民路30号', '开发票', '2026-03-03 11:25:00', NOW(), 0),
('ORD-Z1-EX-CN-031', 1, '1', 1, 'CN', 534.00, 0.00, 0.00, 0.00, 534.00, 3, 1, '2026-03-05 08:50:00', '王丽娜', '13810011031', '长春市朝阳区重庆路31号', NULL, '2026-03-05 08:45:00', NOW(), 0),
('ORD-Z1-EX-CN-032', 1, '1', 1, 'CN', 217.00, 0.00, 0.00, 0.00, 217.00, 3, 1, '2026-03-06 13:20:00', '刘洋', '13810011032', '青岛市市南区香港中路32号', NULL, '2026-03-06 13:15:00', NOW(), 0),
('ORD-Z1-EX-CN-033', 1, '1', 1, 'CN', 95.00, 0.00, 0.00, 0.00, 95.00, 3, 1, '2026-03-07 15:40:00', '陈静', '13810011033', '苏州市姑苏区观前街33号', NULL, '2026-03-07 15:35:00', NOW(), 0),
('ORD-Z1-EX-CN-034', 1, '1', 1, 'CN', 277.00, 0.00, 0.00, 0.00, 277.00, 3, 1, '2026-03-08 10:05:00', '杨帆', '13810011034', '无锡市梁溪区中山路34号', NULL, '2026-03-08 10:00:00', NOW(), 0),
('ORD-Z1-EX-CN-035', 1, '1', 1, 'CN', 486.00, 0.00, 0.00, 0.00, 486.00, 3, 1, '2026-03-10 12:15:00', '赵敏', '13810011035', '宁波市海曙区药行街35号', NULL, '2026-03-10 12:10:00', NOW(), 0),
('ORD-Z1-EX-CN-036', 1, '1', 1, 'CN', 118.00, 0.00, 0.00, 0.00, 118.00, 3, 1, '2026-03-11 09:30:00', '孙浩', '13810011036', '温州市鹿城区五马街36号', NULL, '2026-03-11 09:25:00', NOW(), 0),
('ORD-Z1-EX-CN-037', 1, '1', 1, 'CN', 357.00, 0.00, 0.00, 0.00, 357.00, 3, 1, '2026-03-12 14:00:00', '朱婷', '13810011037', '佛山市禅城区祖庙路37号', NULL, '2026-03-12 13:55:00', NOW(), 0),
('ORD-Z1-EX-CN-038', 1, '1', 1, 'CN', 78.00, 0.00, 0.00, 0.00, 78.00, 3, 1, '2026-03-13 16:25:00', '马超', '13810011038', '东莞市南城区鸿福路38号', NULL, '2026-03-13 16:20:00', NOW(), 0),
('ORD-Z1-EX-CN-039', 1, '1', 1, 'CN', 447.00, 0.00, 0.00, 0.00, 447.00, 3, 1, '2026-03-14 11:10:00', '许琳', '13810011039', '珠海市香洲区凤凰路39号', NULL, '2026-03-14 11:05:00', NOW(), 0),
('ORD-Z1-EX-CN-040', 1, '1', 1, 'CN', 189.00, 0.00, 0.00, 0.00, 189.00, 3, 1, '2026-03-15 08:40:00', '何志强', '13810011040', '中山市石岐区兴中道40号', NULL, '2026-03-15 08:35:00', NOW(), 0),
('ORD-Z1-EX-CN-041', 1, '1', 1, 'CN', 294.00, 0.00, 0.00, 0.00, 294.00, 3, 1, '2026-03-16 13:55:00', '高晓燕', '13810011041', '惠州市惠城区江北大道41号', NULL, '2026-03-16 13:50:00', NOW(), 0),
('ORD-Z1-EX-CN-042', 1, '1', 1, 'CN', 134.00, 0.00, 0.00, 0.00, 134.00, 3, 1, '2026-03-17 10:20:00', '林峰', '13810011042', '江门市蓬江区建设路42号', NULL, '2026-03-17 10:15:00', NOW(), 0),
('ORD-Z1-EX-CN-043', 1, '1', 1, 'CN', 557.00, 0.00, 0.00, 0.00, 557.00, 3, 1, '2026-03-18 15:30:00', '罗娟', '13810011043', '湛江市赤坎区中山一路43号', '公司', '2026-03-18 15:25:00', NOW(), 0),
('ORD-Z1-EX-CN-044', 1, '1', 1, 'CN', 69.00, 0.00, 0.00, 0.00, 69.00, 3, 1, '2026-03-18 09:00:00', '梁伟', '13810011044', '肇庆市端州区天宁路44号', NULL, '2026-03-18 08:55:00', NOW(), 0),
('ORD-Z1-EX-CN-045', 1, '1', 1, 'CN', 244.00, 0.00, 0.00, 0.00, 244.00, 3, 1, '2026-03-18 17:45:00', '宋敏', '13810011045', '韶关市浈江区解放路45号', NULL, '2026-03-18 17:40:00', NOW(), 0),
('ORD-Z1-EX-US-016', 1, '1', 2, 'US', 89.98, 0.00, 0.00, 0.00, 89.98, 3, 1, '2026-02-27 11:00:00', 'Frank Bennett', '+1-555-4016', '1600 Broadway, Denver, CO 80202', NULL, '2026-02-27 10:55:00', NOW(), 0),
('ORD-Z1-EX-US-017', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 3, 1, '2026-03-01 14:20:00', 'Helen Gray', '+1-555-4017', '1700 Main St, Kansas City, MO 64108', NULL, '2026-03-01 14:15:00', NOW(), 0),
('ORD-Z1-EX-US-018', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 3, 1, '2026-03-03 09:45:00', 'Jack Hayes', '+1-555-4018', '1800 Peachtree Rd, Atlanta, GA 30309', NULL, '2026-03-03 09:40:00', NOW(), 0),
('ORD-Z1-EX-US-019', 1, '1', 2, 'US', 188.99, 0.00, 0.00, 0.00, 188.99, 3, 1, '2026-03-05 16:10:00', 'Irene Foster', '+1-555-4019', '1900 K St NW, Washington, DC 20006', NULL, '2026-03-05 16:05:00', NOW(), 0),
('ORD-Z1-EX-US-020', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 3, 1, '2026-03-07 10:30:00', 'Kevin Long', '+1-555-4020', '2000 Market St, Philadelphia, PA 19103', NULL, '2026-03-07 10:25:00', NOW(), 0),
('ORD-Z1-EX-US-021', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 3, 1, '2026-03-09 13:50:00', 'Laura Powell', '+1-555-4021', '2100 McKinney Ave, Dallas, TX 75201', NULL, '2026-03-09 13:45:00', NOW(), 0),
('ORD-Z1-EX-US-022', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 3, 1, '2026-03-11 08:15:00', 'Michael Simmons', '+1-555-4022', '2200 Stemmons Fwy, Dallas, TX 75207', NULL, '2026-03-11 08:10:00', NOW(), 0),
('ORD-Z1-EX-US-023', 1, '1', 2, 'US', 218.99, 0.00, 0.00, 0.00, 218.99, 3, 1, '2026-03-12 15:40:00', 'Nancy Bryant', '+1-555-4023', '2300 N Central Ave, Phoenix, AZ 85004', NULL, '2026-03-12 15:35:00', NOW(), 0),
('ORD-Z1-EX-US-024', 1, '1', 2, 'US', 99.98, 0.00, 0.00, 0.00, 99.98, 3, 1, '2026-03-14 11:20:00', 'Oliver Alexander', '+1-555-4024', '2400 E Camelback Rd, Phoenix, AZ 85016', NULL, '2026-03-14 11:15:00', NOW(), 0),
('ORD-Z1-EX-US-025', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 3, 1, '2026-03-15 17:00:00', 'Patricia Russell', '+1-555-4025', '2500 W Anderson Ln, Austin, TX 78757', NULL, '2026-03-15 16:55:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`), `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`);

-- 4.2 订单明细（依赖上面订单存在，使用子查询幂等插入）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, NOW(), NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602050001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;

-- 4.2.0 补充订单明细（中国 sid=1 高于美国 sid=2，与 erp_list_order_extra_sales_incremental.sql 一致）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 3, 297.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 2, 176.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 2, 190.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 2, 78.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 4, 356.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 2, 316.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 2, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 9) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 2, 118.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 2, 176.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-009' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-009' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-010' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 2, 316.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-010' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 2, 90.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-010' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 2, 70.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-011' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 2, 316.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-011' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-012' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 2, 190.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-013' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 2, 118.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-015' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 2, 198.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 2, 78.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-017' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-017' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 2, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-018' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 9) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 2, 316.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-019' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-020' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 2, 190.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-021' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 2, 70.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-021' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 2, 176.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-022' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 2, 316.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 2, 198.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-024' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-024' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-024' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-025' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-025' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 2, 119.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 2, 99.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-009' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-010' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 2, 99.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-011' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-012' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 2, 119.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-012' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-013' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-015' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;

-- 4.2.0 续：第二批补充订单明细（CN-026~045, US-016~025）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 2, 198.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-026' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-027' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-028' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 3, 267.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-029' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-030' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-030' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-030' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 6, 534.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-031' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-032' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-032' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-033' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-034' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 2, 78.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-034' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 2, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-035' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-035' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 2, 118.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-036' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-037' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-037' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 2, 78.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-038' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-039' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-039' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 2, 90.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-039' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-040' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 2, 90.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-040' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-041' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-041' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-042' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-042' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-043' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-043' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-044' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 9) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-045' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-CN-045' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-017' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-018' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-019' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-019' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-020' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-021' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-022' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 2, 99.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-024' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-EX-US-025' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;

-- 4.2.1 美国分店订单明细 (sid=2, 美国订单)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602010001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602030001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602050001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602090001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602180001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602180001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602200001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;

-- 4.2.2 美国分店更多订单明细 (20 笔新订单)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602020002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602040002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602040002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602060002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 2, 119.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602080002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602100002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602120002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602120002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602140002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602160002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602210002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602230002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602230002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602110002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602130002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602130002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602150002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602170002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602170002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602200002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;

-- 4.2.3 美国分店第三批订单明细 (30 笔新订单)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602010004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602020004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602030003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602040004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602050003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602060004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602060004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602080004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602090004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602090004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602100004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 2, 119.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602110004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602120004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602130004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602130004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602140004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602150004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 89.97, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602160004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602170004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602170004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602170004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602180004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602180004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602200004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602210004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602210004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602230004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602010005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602010005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602030004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602050004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602090005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602110005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;

-- 4.2.4 默认店铺 2 月再增 15 笔订单明细 (sid=1)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 268.00, 1, 268.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 178.00, 1, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230015' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 338.00, 1, 338.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 98.00, 1, 98.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230017' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 418.00, 1, 418.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230018' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240018' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 289.00, 1, 289.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240019' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240020' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 79.00, 1, 79.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240020' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240021' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 449.00, 1, 449.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240022' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240023' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 279.00, 1, 279.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240024' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240025' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 529.00, 1, 529.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240026' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 318.00, 1, 318.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240027' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;

-- 4.2.5 美国分店 2 月再增 15 笔订单明细 (sid=2)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 89.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602120005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602130005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602140005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602150005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602150005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602150005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602160005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602170005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602180005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602190006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602200005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602210005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602210005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602230005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 89.97, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;

-- 4.2.6 默认店铺 2 月第二批 12 笔订单明细 (sid=1，更真实数据)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 78.00, 1, 78.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210014' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210015' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 168.00, 1, 168.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210015' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220015' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220016' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230019' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 198.00, 2, 396.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230020' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 178.00, 1, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230021' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 1, 79.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240028' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240029' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240029' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 189.00, 1, 189.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240030' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 138.00, 1, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240031' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240032' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 120.00, 1, 120.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240032' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;

-- 4.2.7 美国分店 2 月第二批 12 笔订单明细 (sid=2，更真实数据)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602100006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602100006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 29.99, 1, 29.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602140006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602140006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602160006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 40.98, 1, 40.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602160006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602180006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 2, 119.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602200006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602220006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602230006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.98, 1, 39.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602230006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240009' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240010' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.98, 1, 59.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240010' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240011' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240012' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240013' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602240013' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;

-- 4.2.8 默认店铺 2 月第三批 10 笔订单明细 (sid=1，2月25-26日)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 268.00, 1, 268.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 178.00, 1, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 168.00, 1, 168.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 119.00, 1, 119.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602250008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 189.00, 1, 189.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 138.00, 1, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;

-- 4.2.9 美国分店 2 月第三批 10 笔订单明细 (sid=2，2月25-26日)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 40.98, 1, 40.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.98, 1, 39.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.98, 1, 59.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602250008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;

-- 4.2.10 默认店铺 2 月第四批 8 笔订单明细 (sid=1，2月26-27日)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 120.00, 1, 120.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 120.00, 1, 120.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602260008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602270001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 119.00, 1, 119.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602270001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 178.00, 1, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602270002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;

-- 4.2.11 美国分店 2 月第四批 8 笔订单明细 (sid=2，2月26-27日)
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 40.98, 1, 40.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260005' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260006' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 79.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260007' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 17, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 17, 'SKU-US-005', 17, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 17) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.98, 1, 59.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602260008' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602270001' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602270002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.98, 1, 39.98, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602270002' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602010002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602020003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'SKU001', 1, 99.00, 2, 198.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602030004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602030004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602030004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 'SKU005', 5, 99.00, 2, 198.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602040005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602050006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 'SKU006', 6, 129.00, 2, 258.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602050006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602060007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602070008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602070008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602080009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602080009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 'SKU005', 5, 89.00, 2, 178.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602090010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;

INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'SKU001', 1, 99.00, 2, 198.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602100011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602100011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 'SKU006', 6, 129.00, 1, 129.00, o.`create_time`, o.`update_time`
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602100011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;

-- 2 月 18–24 日订单明细
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 178.00, 1, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 252.00, 1, 252.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 138.00, 1, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 69.00, 1, 69.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 79.00, 1, 79.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 29.00, 2, 58.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 70.00, 1, 70.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 189.00, 1, 189.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 139.00, 1, 139.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', NULL, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;

-- 4.2 续：2026-02-18～02-24 更多补货样本订单明细（已存在商品）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 119.00, 1, 119.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 128.00, 1, 128.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 29.00, 2, 58.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 69.00, 1, 69.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 139.00, 1, 139.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 80.00, 1, 80.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 140.00, 1, 140.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 149.00, 1, 149.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 80.00, 1, 80.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240004' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 12) LIMIT 1;

-- 4.2 续：补足 60 条订单的明细（2026-02-18～02-24 新增 24 条订单对应明细，已存在商品 id 1～12）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 168.00, 1, 168.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 229.00, 1, 229.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', NULL, 'SKU009', 9, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 9) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 138.00, 1, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 268.00, 1, 268.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 198.00, 1, 198.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 319.00, 1, 319.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 29.00, 2, 58.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 103.00, 1, 103.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 248.00, 1, 248.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', NULL, 'SKU011', 11, 118.00, 1, 118.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 398.00, 1, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 279.00, 1, 279.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', NULL, 'SKU011', 11, 69.00, 1, 69.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 189.00, 1, 189.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 329.00, 1, 329.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 109.00, 1, 109.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 218.00, 1, 218.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240005' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 148.00, 1, 148.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240006' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 368.00, 1, 368.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240007' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 258.00, 1, 258.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;

-- 4.2 续：补足 100 条订单的明细（新增 40 条，含部分一单 10 件同商品）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 29.00, 10, 290.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 198.00, 1, 198.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 219.00, 1, 219.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 10, 990.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 267.00, 1, 267.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 189.00, 1, 189.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', NULL, 'SKU011', 11, 59.00, 10, 590.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 328.00, 1, 328.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 259.00, 1, 259.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 10, 790.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 258.00, 1, 258.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 139.00, 1, 139.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 398.00, 1, 398.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 219.00, 1, 219.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', NULL, 'SKU009', 9, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 9) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 29.00, 10, 290.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 168.00, 1, 168.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 299.00, 1, 299.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', NULL, 'SKU008', 8, 229.00, 1, 229.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 109.00, 1, 109.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 279.00, 1, 279.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220014' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', NULL, 'SKU005', 5, 99.00, 10, 990.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230008' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 5) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 129.00, 2, 258.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', NULL, 'SKU011', 11, 69.00, 1, 69.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 319.00, 1, 319.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg?__r__=1664285638581', NULL, 'SKU007', 7, 29.00, 2, 58.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 91.00, 1, 91.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', NULL, 'SKU011', 11, 59.00, 10, 590.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240009' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 228.00, 1, 228.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240010' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 358.00, 1, 358.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240011' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240012' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 498.00, 1, 498.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240013' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 279.00, 1, 279.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240014' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 79.00, 10, 790.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240015' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', NULL, 'SKU010', 10, 188.00, 1, 188.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240016' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', NULL, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240017' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 12) LIMIT 1;

-- 2 月每日补充订单数：前期/末期多补以抬平谷底，中期少补以弱化尖峰；全部为显式插入，无循环重复
-- 02-02~02-17 各 14 单，02-18~02-23 各 4 单，02-24 补 2 单，02-25~02-28 各 12 单；收货人/金额/地址均真实化
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
-- 02-02 (14 单)
('ORD-TR-20260202-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-02 08:10:00', '张明', '13800138001', '北京市朝阳区建国路1号', NULL, '2026-02-02 08:10:00', NOW(), 0),
('ORD-TR-20260202-02', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-02 09:20:00', '李芳', '13800138002', '上海市浦东新区张江路2号', NULL, '2026-02-02 09:20:00', NOW(), 0),
('ORD-TR-20260202-03', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-02 10:35:00', '王强', '13800138003', '广州市天河区体育西路3号', NULL, '2026-02-02 10:35:00', NOW(), 0),
('ORD-TR-20260202-04', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-02 11:00:00', '刘洋', '13800138004', '深圳市南山区科技园4号', NULL, '2026-02-02 11:00:00', NOW(), 0),
('ORD-TR-20260202-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-02 13:15:00', '陈静', '13800138005', '杭州市西湖区文三路5号', NULL, '2026-02-02 13:15:00', NOW(), 0),
('ORD-TR-20260202-06', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-02 14:20:00', '杨帆', '13800138006', '成都市武侯区天府大道6号', NULL, '2026-02-02 14:20:00', NOW(), 0),
('ORD-TR-20260202-07', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-02 15:30:00', '赵敏', '13800138007', '南京市鼓楼区中山路7号', NULL, '2026-02-02 15:30:00', NOW(), 0),
('ORD-TR-20260202-08', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-02 16:00:00', '周杰', '13800138008', '武汉市江汉区解放大道8号', NULL, '2026-02-02 16:00:00', NOW(), 0),
('ORD-TR-20260202-09', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-02 16:45:00', '吴磊', '13800138009', '西安市雁塔区高新路9号', NULL, '2026-02-02 16:45:00', NOW(), 0),
('ORD-TR-20260202-10', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-02 17:10:00', '郑浩', '13800138010', '重庆市渝北区龙溪路10号', NULL, '2026-02-02 17:10:00', NOW(), 0),
('ORD-TR-20260202-11', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-02 18:20:00', '孙丽', '13800138011', '郑州市金水区花园路11号', NULL, '2026-02-02 18:20:00', NOW(), 0),
('ORD-TR-20260202-12', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-02 19:00:00', '朱婷', '13800138012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-02 19:00:00', NOW(), 0),
('ORD-TR-20260202-13', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-02 19:30:00', '林峰', '13800138013', '济南市历下区泉城路13号', NULL, '2026-02-02 19:30:00', NOW(), 0),
('ORD-TR-20260202-14', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-02 20:15:00', '何芳', '13800138014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-02 20:15:00', NOW(), 0),
-- 02-03 (14 单)
('ORD-TR-20260203-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-03 08:05:00', '张明', '13800138001', '北京市朝阳区建国路1号', NULL, '2026-02-03 08:05:00', NOW(), 0),
('ORD-TR-20260203-02', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-03 09:15:00', '李芳', '13800138002', '上海市浦东新区张江路2号', NULL, '2026-02-03 09:15:00', NOW(), 0),
('ORD-TR-20260203-03', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-03 10:40:00', '王强', '13800138003', '广州市天河区体育西路3号', NULL, '2026-02-03 10:40:00', NOW(), 0),
('ORD-TR-20260203-04', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-03 11:20:00', '刘洋', '13800138004', '深圳市南山区科技园4号', NULL, '2026-02-03 11:20:00', NOW(), 0),
('ORD-TR-20260203-05', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-03 13:00:00', '陈静', '13800138005', '杭州市西湖区文三路5号', NULL, '2026-02-03 13:00:00', NOW(), 0),
('ORD-TR-20260203-06', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-03 14:35:00', '杨帆', '13800138006', '成都市武侯区天府大道6号', NULL, '2026-02-03 14:35:00', NOW(), 0),
('ORD-TR-20260203-07', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-03 15:50:00', '赵敏', '13800138007', '南京市鼓楼区中山路7号', NULL, '2026-02-03 15:50:00', NOW(), 0),
('ORD-TR-20260203-08', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-03 16:20:00', '周杰', '13800138008', '武汉市江汉区解放大道8号', NULL, '2026-02-03 16:20:00', NOW(), 0),
('ORD-TR-20260203-09', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-03 17:00:00', '吴磊', '13800138009', '西安市雁塔区高新路9号', NULL, '2026-02-03 17:00:00', NOW(), 0),
('ORD-TR-20260203-10', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-03 17:45:00', '郑浩', '13800138010', '重庆市渝北区龙溪路10号', NULL, '2026-02-03 17:45:00', NOW(), 0),
('ORD-TR-20260203-11', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-03 18:30:00', '孙丽', '13800138011', '郑州市金水区花园路11号', NULL, '2026-02-03 18:30:00', NOW(), 0),
('ORD-TR-20260203-12', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-03 19:10:00', '朱婷', '13800138012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-03 19:10:00', NOW(), 0),
('ORD-TR-20260203-13', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-03 19:50:00', '林峰', '13800138013', '济南市历下区泉城路13号', NULL, '2026-02-03 19:50:00', NOW(), 0),
('ORD-TR-20260203-14', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-03 20:20:00', '何芳', '13800138014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-03 20:20:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-04 每日 14 单（金额均为已存在商品单价）
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('ORD-TR-20260204-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-04 08:00:00', '张明', '13800138001', '北京市朝阳区建国路1号', NULL, '2026-02-04 08:00:00', NOW(), 0),
('ORD-TR-20260204-02', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-04 09:10:00', '李芳', '13800138002', '上海市浦东新区张江路2号', NULL, '2026-02-04 09:10:00', NOW(), 0),
('ORD-TR-20260204-03', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-04 10:25:00', '王强', '13800138003', '广州市天河区体育西路3号', NULL, '2026-02-04 10:25:00', NOW(), 0),
('ORD-TR-20260204-04', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-04 11:05:00', '刘洋', '13800138004', '深圳市南山区科技园4号', NULL, '2026-02-04 11:05:00', NOW(), 0),
('ORD-TR-20260204-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-04 13:20:00', '陈静', '13800138005', '杭州市西湖区文三路5号', NULL, '2026-02-04 13:20:00', NOW(), 0),
('ORD-TR-20260204-06', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-04 14:15:00', '杨帆', '13800138006', '成都市武侯区天府大道6号', NULL, '2026-02-04 14:15:00', NOW(), 0),
('ORD-TR-20260204-07', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-04 15:40:00', '赵敏', '13800138007', '南京市鼓楼区中山路7号', NULL, '2026-02-04 15:40:00', NOW(), 0),
('ORD-TR-20260204-08', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-04 16:10:00', '周杰', '13800138008', '武汉市江汉区解放大道8号', NULL, '2026-02-04 16:10:00', NOW(), 0),
('ORD-TR-20260204-09', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-04 16:50:00', '吴磊', '13800138009', '西安市雁塔区高新路9号', NULL, '2026-02-04 16:50:00', NOW(), 0),
('ORD-TR-20260204-10', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-04 17:25:00', '郑浩', '13800138010', '重庆市渝北区龙溪路10号', NULL, '2026-02-04 17:25:00', NOW(), 0),
('ORD-TR-20260204-11', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-04 18:00:00', '孙丽', '13800138011', '郑州市金水区花园路11号', NULL, '2026-02-04 18:00:00', NOW(), 0),
('ORD-TR-20260204-12', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-04 18:45:00', '朱婷', '13800138012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-04 18:45:00', NOW(), 0),
('ORD-TR-20260204-13', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-04 19:20:00', '林峰', '13800138013', '济南市历下区泉城路13号', NULL, '2026-02-04 19:20:00', NOW(), 0),
('ORD-TR-20260204-14', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-04 20:00:00', '何芳', '13800138014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-04 20:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-05 ~ 02-17：每日 14 单（完整显式插入，共 13 天）
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260205-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-05 08:00:00', '张明', '13800138001', '北京市朝阳区建国路1号', NULL, '2026-02-05 08:00:00', NOW(), 0),
('ORD-TR-20260205-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-05 09:10:00', '李芳', '13800138002', '上海市浦东新区张江路2号', NULL, '2026-02-05 09:10:00', NOW(), 0),
('ORD-TR-20260205-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-05 10:25:00', '王强', '13800138003', '广州市天河区体育西路3号', NULL, '2026-02-05 10:25:00', NOW(), 0),
('ORD-TR-20260205-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-05 11:05:00', '刘洋', '13800138004', '深圳市南山区科技园4号', NULL, '2026-02-05 11:05:00', NOW(), 0),
('ORD-TR-20260205-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-05 13:20:00', '陈静', '13800138005', '杭州市西湖区文三路5号', NULL, '2026-02-05 13:20:00', NOW(), 0),
('ORD-TR-20260205-06', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-05 14:15:00', '杨帆', '13800138006', '成都市武侯区天府大道6号', NULL, '2026-02-05 14:15:00', NOW(), 0),
('ORD-TR-20260205-07', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-05 15:40:00', '赵敏', '13800138007', '南京市鼓楼区中山路7号', NULL, '2026-02-05 15:40:00', NOW(), 0),
('ORD-TR-20260205-08', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-05 16:10:00', '周杰', '13800138008', '武汉市江汉区解放大道8号', NULL, '2026-02-05 16:10:00', NOW(), 0),
('ORD-TR-20260205-09', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-05 16:50:00', '吴磊', '13800138009', '西安市雁塔区高新路9号', NULL, '2026-02-05 16:50:00', NOW(), 0),
('ORD-TR-20260205-10', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-05 17:25:00', '郑浩', '13800138010', '重庆市渝北区龙溪路10号', NULL, '2026-02-05 17:25:00', NOW(), 0),
('ORD-TR-20260205-11', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-05 18:00:00', '孙丽', '13800138011', '郑州市金水区花园路11号', NULL, '2026-02-05 18:00:00', NOW(), 0),
('ORD-TR-20260205-12', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-05 18:45:00', '朱婷', '13800138012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-05 18:45:00', NOW(), 0),
('ORD-TR-20260205-13', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-05 19:20:00', '林峰', '13800138013', '济南市历下区泉城路13号', NULL, '2026-02-05 19:20:00', NOW(), 0),
('ORD-TR-20260205-14', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-05 20:00:00', '何芳', '13800138014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-05 20:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260206-01', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-06 08:00:00', '张明', '13800138001', '北京市朝阳区建国路1号', NULL, '2026-02-06 08:00:00', NOW(), 0),
('ORD-TR-20260206-02', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-06 09:10:00', '李芳', '13800138002', '上海市浦东新区张江路2号', NULL, '2026-02-06 09:10:00', NOW(), 0),
('ORD-TR-20260206-03', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-06 10:25:00', '王强', '13800138003', '广州市天河区体育西路3号', NULL, '2026-02-06 10:25:00', NOW(), 0),
('ORD-TR-20260206-04', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-06 11:05:00', '刘洋', '13800138004', '深圳市南山区科技园4号', NULL, '2026-02-06 11:05:00', NOW(), 0),
('ORD-TR-20260206-05', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-06 13:20:00', '陈静', '13800138005', '杭州市西湖区文三路5号', NULL, '2026-02-06 13:20:00', NOW(), 0),
('ORD-TR-20260206-06', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-06 14:15:00', '杨帆', '13800138006', '成都市武侯区天府大道6号', NULL, '2026-02-06 14:15:00', NOW(), 0),
('ORD-TR-20260206-07', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-06 15:40:00', '赵敏', '13800138007', '南京市鼓楼区中山路7号', NULL, '2026-02-06 15:40:00', NOW(), 0),
('ORD-TR-20260206-08', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-06 16:10:00', '周杰', '13800138008', '武汉市江汉区解放大道8号', NULL, '2026-02-06 16:10:00', NOW(), 0),
('ORD-TR-20260206-09', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-06 16:50:00', '吴磊', '13800138009', '西安市雁塔区高新路9号', NULL, '2026-02-06 16:50:00', NOW(), 0),
('ORD-TR-20260206-10', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-06 17:25:00', '郑浩', '13800138010', '重庆市渝北区龙溪路10号', NULL, '2026-02-06 17:25:00', NOW(), 0),
('ORD-TR-20260206-11', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-06 18:00:00', '孙丽', '13800138011', '郑州市金水区花园路11号', NULL, '2026-02-06 18:00:00', NOW(), 0),
('ORD-TR-20260206-12', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-06 18:45:00', '朱婷', '13800138012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-06 18:45:00', NOW(), 0),
('ORD-TR-20260206-13', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-06 19:20:00', '林峰', '13800138013', '济南市历下区泉城路13号', NULL, '2026-02-06 19:20:00', NOW(), 0),
('ORD-TR-20260206-14', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-06 20:00:00', '何芳', '13800138014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-06 20:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-07 ~ 02-17、02-18 ~ 02-23：显式真实化订单（收货人多样、部分数量 2/3、部分一单多品）
-- 02-07（14 单：部分多件、部分一单多品，收货人姓名不重复）
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260207-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-07 08:00:00', '冯晓燕', '13900139001', '北京市海淀区中关村大街1号', NULL, '2026-02-07 08:00:00', NOW(), 0),
('ORD-TR-20260207-02', 1, '1', 1, 'CN', 288.00, 0, 0, 0, 288.00, 3, 1, '2026-02-07 09:15:00', '韩冬梅', '13900139002', '上海市浦东新区陆家嘴环路2号', NULL, '2026-02-07 09:15:00', NOW(), 0),
('ORD-TR-20260207-03', 1, '1', 1, 'CN', 178.00, 0, 0, 0, 178.00, 3, 1, '2026-02-07 10:30:00', '曹建平', '13900139003', '广州市天河区体育西路3号', NULL, '2026-02-07 10:30:00', NOW(), 0),
('ORD-TR-20260207-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-07 11:00:00', '邓丽华', '13900139004', '深圳市南山区科技园南路4号', NULL, '2026-02-07 11:00:00', NOW(), 0),
('ORD-TR-20260207-05', 1, '1', 1, 'CN', 143.00, 0, 0, 0, 143.00, 3, 1, '2026-02-07 13:20:00', '彭志强', '13900139005', '杭州市西湖区文三路5号', NULL, '2026-02-07 13:20:00', NOW(), 0),
('ORD-TR-20260207-06', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-07 14:10:00', '蒋敏', '13900139006', '成都市武侯区天府大道6号', NULL, '2026-02-07 14:10:00', NOW(), 0),
('ORD-TR-20260207-07', 1, '1', 1, 'CN', 190.00, 0, 0, 0, 190.00, 3, 1, '2026-02-07 15:25:00', '薛海涛', '13900139007', '南京市鼓楼区中山路7号', NULL, '2026-02-07 15:25:00', NOW(), 0),
('ORD-TR-20260207-08', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-07 16:00:00', '叶芳', '13900139008', '武汉市江汉区解放大道8号', NULL, '2026-02-07 16:00:00', NOW(), 0),
('ORD-TR-20260207-09', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-07 16:45:00', '董磊', '13900139009', '西安市雁塔区高新路9号', NULL, '2026-02-07 16:45:00', NOW(), 0),
('ORD-TR-20260207-10', 1, '1', 1, 'CN', 135.00, 0, 0, 0, 135.00, 3, 1, '2026-02-07 17:30:00', '程晓红', '13900139010', '重庆市渝北区龙溪路10号', NULL, '2026-02-07 17:30:00', NOW(), 0),
('ORD-TR-20260207-11', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-07 18:15:00', '曾明', '13900139011', '郑州市金水区花园路11号', NULL, '2026-02-07 18:15:00', NOW(), 0),
('ORD-TR-20260207-12', 1, '1', 1, 'CN', 138.00, 0, 0, 0, 138.00, 3, 1, '2026-02-07 19:00:00', '苏静', '13900139012', '长沙市岳麓区麓山南路12号', NULL, '2026-02-07 19:00:00', NOW(), 0),
('ORD-TR-20260207-13', 1, '1', 1, 'CN', 246.00, 0, 0, 0, 246.00, 3, 1, '2026-02-07 19:40:00', '潘建华', '13900139013', '济南市历下区泉城路13号', NULL, '2026-02-07 19:40:00', NOW(), 0),
('ORD-TR-20260207-14', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-07 20:20:00', '戴丽娟', '13900139014', '哈尔滨市南岗区西大直街14号', NULL, '2026-02-07 20:20:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-07 订单明细（01 单品1件；02 两品各1件；03 单品2件；04~08 单品1件；09 两品各1件；10 单品3件；11~14 单品）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-01' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-02' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-02' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-03' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-04' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-05' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-05' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-05' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 9) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-06' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 2, 190.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-07' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-08' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-09' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-09' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 3, 135.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-10' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-11' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 2, 138.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-12' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-13' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-13' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260207-14' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`) LIMIT 1;

-- 02-08 ~ 02-17 每日 14 单（显式插入，收货人/金额/地址均不循环重复）
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260208-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-08 08:00:00', '冯晓燕', '13900139040', '北京市海淀区中关村大街40号', NULL, '2026-02-08 08:00:00', NOW(), 0),
('ORD-TR-20260208-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-08 09:15:00', '韩冬梅', '13900139041', '上海市徐汇区淮海中路41号', NULL, '2026-02-08 09:15:00', NOW(), 0),
('ORD-TR-20260208-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-08 10:30:00', '曹建平', '13900139042', '广州市番禺区市桥路42号', NULL, '2026-02-08 10:30:00', NOW(), 0),
('ORD-TR-20260208-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-08 11:45:00', '邓丽华', '13900139043', '深圳市宝安区新安路43号', NULL, '2026-02-08 11:45:00', NOW(), 0),
('ORD-TR-20260208-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-08 13:00:00', '彭志强', '13900139044', '杭州市余杭区文一西路44号', NULL, '2026-02-08 13:00:00', NOW(), 0),
('ORD-TR-20260208-06', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-08 14:15:00', '蒋敏', '13900139045', '成都市双流区华阳大道45号', NULL, '2026-02-08 14:15:00', NOW(), 0),
('ORD-TR-20260208-07', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-08 15:30:00', '薛海涛', '13900139046', '南京市建邺区江东中路46号', NULL, '2026-02-08 15:30:00', NOW(), 0),
('ORD-TR-20260208-08', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-08 16:45:00', '叶芳', '13900139047', '武汉市武昌区中南路47号', NULL, '2026-02-08 16:45:00', NOW(), 0),
('ORD-TR-20260208-09', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-08 17:00:00', '董磊', '13900139048', '西安市碑林区南大街48号', NULL, '2026-02-08 17:00:00', NOW(), 0),
('ORD-TR-20260208-10', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-08 18:15:00', '程晓红', '13900139049', '重庆市南岸区南坪西路49号', NULL, '2026-02-08 18:15:00', NOW(), 0),
('ORD-TR-20260208-11', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-08 19:30:00', '曾明', '13900139050', '郑州市中原区桐柏路50号', NULL, '2026-02-08 19:30:00', NOW(), 0),
('ORD-TR-20260208-12', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-08 20:00:00', '苏静', '13900139051', '长沙市雨花区韶山路51号', NULL, '2026-02-08 20:00:00', NOW(), 0),
('ORD-TR-20260208-13', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-08 20:30:00', '潘建华', '13900139052', '济南市市中区经十路52号', NULL, '2026-02-08 20:30:00', NOW(), 0),
('ORD-TR-20260208-14', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-08 21:00:00', '戴丽娟', '13900139053', '哈尔滨市道外区靖宇街53号', NULL, '2026-02-08 21:00:00', NOW(), 0),
('ORD-TR-20260209-01', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-09 08:05:00', '范伟', '13900139054', '福州市台江区五一南路54号', NULL, '2026-02-09 08:05:00', NOW(), 0),
('ORD-TR-20260209-02', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-09 09:20:00', '邹敏', '13900139055', '厦门市湖里区 SM 商圈55号', NULL, '2026-02-09 09:20:00', NOW(), 0),
('ORD-TR-20260209-03', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-09 10:35:00', '陆涛', '13900139056', '合肥市包河区马鞍山路56号', NULL, '2026-02-09 10:35:00', NOW(), 0),
('ORD-TR-20260209-04', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-09 11:50:00', '江丽', '13900139057', '南昌市红谷滩新区57号', NULL, '2026-02-09 11:50:00', NOW(), 0),
('ORD-TR-20260209-05', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-09 13:05:00', '孔杰', '13900139058', '昆明市官渡区关上路58号', NULL, '2026-02-09 13:05:00', NOW(), 0),
('ORD-TR-20260209-06', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-09 14:20:00', '谢芳', '13900139059', '南宁市西乡塘区大学路59号', NULL, '2026-02-09 14:20:00', NOW(), 0),
('ORD-TR-20260209-07', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-09 15:35:00', '严明', '13900139060', '贵阳市云岩区中华北路60号', NULL, '2026-02-09 15:35:00', NOW(), 0),
('ORD-TR-20260209-08', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-09 16:50:00', '余静', '13900139061', '兰州市七里河区西站路61号', NULL, '2026-02-09 16:50:00', NOW(), 0),
('ORD-TR-20260209-09', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-09 18:05:00', '石磊', '13900139062', '乌鲁木齐市沙依巴克区62号', NULL, '2026-02-09 18:05:00', NOW(), 0),
('ORD-TR-20260209-10', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-09 19:20:00', '白芳', '13900139063', '海口市美兰区海秀路63号', NULL, '2026-02-09 19:20:00', NOW(), 0),
('ORD-TR-20260209-11', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-09 20:00:00', '贺强', '13900139064', '石家庄市长安区中山东路64号', NULL, '2026-02-09 20:00:00', NOW(), 0),
('ORD-TR-20260209-12', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-09 20:40:00', '冯晓燕', '13900139065', '太原市小店区坞城路65号', NULL, '2026-02-09 20:40:00', NOW(), 0),
('ORD-TR-20260209-13', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-09 21:10:00', '韩冬梅', '13900139066', '沈阳市和平区中华路66号', NULL, '2026-02-09 21:10:00', NOW(), 0),
('ORD-TR-20260209-14', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-09 21:40:00', '曹建平', '13900139067', '大连市中山区人民路67号', NULL, '2026-02-09 21:40:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260210-01', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-10 08:10:00', '邓丽华', '13900139068', '青岛市市南区香港中路68号', NULL, '2026-02-10 08:10:00', NOW(), 0),
('ORD-TR-20260210-02', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-10 09:25:00', '彭志强', '13900139069', '宁波市鄞州区天童北路69号', NULL, '2026-02-10 09:25:00', NOW(), 0),
('ORD-TR-20260210-03', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-10 10:40:00', '蒋敏', '13900139070', '无锡市滨湖区蠡湖大道70号', NULL, '2026-02-10 10:40:00', NOW(), 0),
('ORD-TR-20260210-04', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-10 11:55:00', '薛海涛', '13900139071', '佛山市南海区桂澜路71号', NULL, '2026-02-10 11:55:00', NOW(), 0),
('ORD-TR-20260210-05', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-10 13:10:00', '叶芳', '13900139072', '东莞市南城区鸿福路72号', NULL, '2026-02-10 13:10:00', NOW(), 0),
('ORD-TR-20260210-06', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-10 14:25:00', '董磊', '13900139073', '苏州市工业园区现代大道73号', NULL, '2026-02-10 14:25:00', NOW(), 0),
('ORD-TR-20260210-07', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-10 15:40:00', '程晓红', '13900139074', '珠海市香洲区情侣路74号', NULL, '2026-02-10 15:40:00', NOW(), 0),
('ORD-TR-20260210-08', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-10 16:55:00', '曾明', '13900139075', '温州市鹿城区车站大道75号', NULL, '2026-02-10 16:55:00', NOW(), 0),
('ORD-TR-20260210-09', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-10 18:10:00', '苏静', '13900139076', '烟台市芝罘区南大街76号', NULL, '2026-02-10 18:10:00', NOW(), 0),
('ORD-TR-20260210-10', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-10 19:25:00', '潘建华', '13900139077', '唐山市路南区新华道77号', NULL, '2026-02-10 19:25:00', NOW(), 0),
('ORD-TR-20260210-11', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-10 20:40:00', '戴丽娟', '13900139078', '洛阳市涧西区南昌路78号', NULL, '2026-02-10 20:40:00', NOW(), 0),
('ORD-TR-20260210-12', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-10 21:00:00', '范伟', '13900139079', '徐州市云龙区淮海路79号', NULL, '2026-02-10 21:00:00', NOW(), 0),
('ORD-TR-20260210-13', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-10 21:30:00', '邹敏', '13900139080', '南通市崇川区工农路80号', NULL, '2026-02-10 21:30:00', NOW(), 0),
('ORD-TR-20260210-14', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-10 22:00:00', '陆涛', '13900139081', '扬州市邗江区文昌中路81号', NULL, '2026-02-10 22:00:00', NOW(), 0),
('ORD-TR-20260211-01', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-11 08:15:00', '江丽', '13900139082', '绍兴市越城区解放路82号', NULL, '2026-02-11 08:15:00', NOW(), 0),
('ORD-TR-20260211-02', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-11 09:30:00', '孔杰', '13900139083', '嘉兴市南湖区中山路83号', NULL, '2026-02-11 09:30:00', NOW(), 0),
('ORD-TR-20260211-03', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-11 10:45:00', '谢芳', '13900139084', '金华市婺城区八一北街84号', NULL, '2026-02-11 10:45:00', NOW(), 0),
('ORD-TR-20260211-04', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-11 12:00:00', '严明', '13900139085', '常州市武进区延政大道85号', NULL, '2026-02-11 12:00:00', NOW(), 0),
('ORD-TR-20260211-05', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-11 13:15:00', '余静', '13900139086', '泉州市丰泽区津淮街86号', NULL, '2026-02-11 13:15:00', NOW(), 0),
('ORD-TR-20260211-06', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-11 14:30:00', '石磊', '13900139087', '漳州市芗城区胜利路87号', NULL, '2026-02-11 14:30:00', NOW(), 0),
('ORD-TR-20260211-07', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-11 15:45:00', '白芳', '13900139088', '临沂市兰山区沂蒙路88号', NULL, '2026-02-11 15:45:00', NOW(), 0),
('ORD-TR-20260211-08', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-11 17:00:00', '贺强', '13900139089', '潍坊市奎文区东风东街89号', NULL, '2026-02-11 17:00:00', NOW(), 0),
('ORD-TR-20260211-09', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-11 18:15:00', '冯晓燕', '13900139090', '淄博市张店区金晶大道90号', NULL, '2026-02-11 18:15:00', NOW(), 0),
('ORD-TR-20260211-10', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-11 19:30:00', '韩冬梅', '13900139091', '济宁市任城区太白楼路91号', NULL, '2026-02-11 19:30:00', NOW(), 0),
('ORD-TR-20260211-11', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-11 20:45:00', '曹建平', '13900139092', '泰安市泰山区东岳大街92号', NULL, '2026-02-11 20:45:00', NOW(), 0),
('ORD-TR-20260211-12', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-11 21:00:00', '邓丽华', '13900139093', '威海市环翠区新威路93号', NULL, '2026-02-11 21:00:00', NOW(), 0),
('ORD-TR-20260211-13', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-11 21:30:00', '彭志强', '13900139094', '日照市东港区黄海一路94号', NULL, '2026-02-11 21:30:00', NOW(), 0),
('ORD-TR-20260211-14', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-11 22:00:00', '蒋敏', '13900139095', '东营市东营区府前大街95号', NULL, '2026-02-11 22:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260212-01', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-12 08:20:00', '薛海涛', '13900139096', '太原市迎泽区柳巷96号', NULL, '2026-02-12 08:20:00', NOW(), 0),
('ORD-TR-20260212-02', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-12 09:35:00', '叶芳', '13900139097', '呼和浩特市新城区中山东路97号', NULL, '2026-02-12 09:35:00', NOW(), 0),
('ORD-TR-20260212-03', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-12 10:50:00', '董磊', '13900139098', '长春市朝阳区重庆路98号', NULL, '2026-02-12 10:50:00', NOW(), 0),
('ORD-TR-20260212-04', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-12 12:05:00', '程晓红', '13900139099', '吉林市船营区北京路99号', NULL, '2026-02-12 12:05:00', NOW(), 0),
('ORD-TR-20260212-05', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-12 13:20:00', '曾明', '13900139100', '大庆市萨尔图区东风路100号', NULL, '2026-02-12 13:20:00', NOW(), 0),
('ORD-TR-20260212-06', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-12 14:35:00', '苏静', '13900139101', '包头市昆都仑区钢铁大街101号', NULL, '2026-02-12 14:35:00', NOW(), 0),
('ORD-TR-20260212-07', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-12 15:50:00', '潘建华', '13900139102', '银川市兴庆区解放街102号', NULL, '2026-02-12 15:50:00', NOW(), 0),
('ORD-TR-20260212-08', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-12 17:05:00', '戴丽娟', '13900139103', '西宁市城东区东关大街103号', NULL, '2026-02-12 17:05:00', NOW(), 0),
('ORD-TR-20260212-09', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-12 18:20:00', '范伟', '13900139104', '拉萨市城关区北京中路104号', NULL, '2026-02-12 18:20:00', NOW(), 0),
('ORD-TR-20260212-10', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-12 19:35:00', '邹敏', '13900139105', '三亚市吉阳区迎宾路105号', NULL, '2026-02-12 19:35:00', NOW(), 0),
('ORD-TR-20260212-11', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-12 20:50:00', '陆涛', '13900139106', '桂林市秀峰区中山中路106号', NULL, '2026-02-12 20:50:00', NOW(), 0),
('ORD-TR-20260212-12', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-12 21:00:00', '江丽', '13900139107', '柳州市城中区龙城路107号', NULL, '2026-02-12 21:00:00', NOW(), 0),
('ORD-TR-20260212-13', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-12 21:30:00', '孔杰', '13900139108', '北海市海城区北部湾路108号', NULL, '2026-02-12 21:30:00', NOW(), 0),
('ORD-TR-20260212-14', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-12 22:00:00', '谢芳', '13900139109', '韶关市浈江区风采楼109号', NULL, '2026-02-12 22:00:00', NOW(), 0),
('ORD-TR-20260213-01', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-13 08:25:00', '严明', '13900139110', '湛江市赤坎区中山路110号', NULL, '2026-02-13 08:25:00', NOW(), 0),
('ORD-TR-20260213-02', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-13 09:40:00', '余静', '13900139111', '江门市蓬江区建设路111号', NULL, '2026-02-13 09:40:00', NOW(), 0),
('ORD-TR-20260213-03', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-13 10:55:00', '石磊', '13900139112', '茂名市茂南区油城路112号', NULL, '2026-02-13 10:55:00', NOW(), 0),
('ORD-TR-20260213-04', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-13 12:10:00', '白芳', '13900139113', '肇庆市端州区天宁北路113号', NULL, '2026-02-13 12:10:00', NOW(), 0),
('ORD-TR-20260213-05', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-13 13:25:00', '贺强', '13900139114', '惠州市惠城区麦地路114号', NULL, '2026-02-13 13:25:00', NOW(), 0),
('ORD-TR-20260213-06', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-13 14:40:00', '冯晓燕', '13900139115', '中山市石岐区兴中道115号', NULL, '2026-02-13 14:40:00', NOW(), 0),
('ORD-TR-20260213-07', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-13 15:55:00', '韩冬梅', '13900139116', '汕头市金平区金砂路116号', NULL, '2026-02-13 15:55:00', NOW(), 0),
('ORD-TR-20260213-08', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-13 17:10:00', '曹建平', '13900139117', '潮州市湘桥区潮州大道117号', NULL, '2026-02-13 17:10:00', NOW(), 0),
('ORD-TR-20260213-09', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-13 18:25:00', '邓丽华', '13900139118', '揭阳市榕城区进贤门118号', NULL, '2026-02-13 18:25:00', NOW(), 0),
('ORD-TR-20260213-10', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-13 19:40:00', '彭志强', '13900139119', '株洲市天元区长江北路119号', NULL, '2026-02-13 19:40:00', NOW(), 0),
('ORD-TR-20260213-11', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-13 20:55:00', '蒋敏', '13900139120', '湘潭市雨湖区建设北路120号', NULL, '2026-02-13 20:55:00', NOW(), 0),
('ORD-TR-20260213-12', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-13 21:30:00', '薛海涛', '13900139121', '衡阳市蒸湘区解放大道121号', NULL, '2026-02-13 21:30:00', NOW(), 0),
('ORD-TR-20260213-13', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-13 22:00:00', '叶芳', '13900139122', '岳阳市岳阳楼区巴陵中路122号', NULL, '2026-02-13 22:00:00', NOW(), 0),
('ORD-TR-20260213-14', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-13 22:30:00', '董磊', '13900139123', '常德市武陵区朗州路123号', NULL, '2026-02-13 22:30:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260214-01', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-14 08:30:00', '程晓红', '13900139124', '张家界市永定区子午路124号', NULL, '2026-02-14 08:30:00', NOW(), 0),
('ORD-TR-20260214-02', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-14 09:45:00', '曾明', '13900139125', '益阳市赫山区康富路125号', NULL, '2026-02-14 09:45:00', NOW(), 0),
('ORD-TR-20260214-03', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-14 11:00:00', '苏静', '13900139126', '郴州市北湖区国庆北路126号', NULL, '2026-02-14 11:00:00', NOW(), 0),
('ORD-TR-20260214-04', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-14 12:15:00', '潘建华', '13900139127', '怀化市鹤城区迎丰路127号', NULL, '2026-02-14 12:15:00', NOW(), 0),
('ORD-TR-20260214-05', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-14 13:30:00', '戴丽娟', '13900139128', '娄底市娄星区氐星路128号', NULL, '2026-02-14 13:30:00', NOW(), 0),
('ORD-TR-20260214-06', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-14 14:45:00', '范伟', '13900139129', '赣州市章贡区红旗大道129号', NULL, '2026-02-14 14:45:00', NOW(), 0),
('ORD-TR-20260214-07', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-14 16:00:00', '邹敏', '13900139130', '九江市浔阳区浔阳路130号', NULL, '2026-02-14 16:00:00', NOW(), 0),
('ORD-TR-20260214-08', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-14 17:15:00', '陆涛', '13900139131', '上饶市信州区赣东北大道131号', NULL, '2026-02-14 17:15:00', NOW(), 0),
('ORD-TR-20260214-09', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-14 18:30:00', '江丽', '13900139132', '宜春市袁州区中山路132号', NULL, '2026-02-14 18:30:00', NOW(), 0),
('ORD-TR-20260214-10', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-14 19:45:00', '孔杰', '13900139133', '新余市渝水区北湖路133号', NULL, '2026-02-14 19:45:00', NOW(), 0),
('ORD-TR-20260214-11', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-14 21:00:00', '谢芳', '13900139134', '景德镇市珠山区珠山中路134号', NULL, '2026-02-14 21:00:00', NOW(), 0),
('ORD-TR-20260214-12', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-14 21:30:00', '严明', '13900139135', '萍乡市安源区跃进路135号', NULL, '2026-02-14 21:30:00', NOW(), 0),
('ORD-TR-20260214-13', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-14 22:00:00', '余静', '13900139136', '鹰潭市月湖区林荫路136号', NULL, '2026-02-14 22:00:00', NOW(), 0),
('ORD-TR-20260214-14', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-14 22:30:00', '石磊', '13900139137', '抚州市临川区赣东大道137号', NULL, '2026-02-14 22:30:00', NOW(), 0),
('ORD-TR-20260215-01', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-15 08:35:00', '白芳', '13900139138', '宜宾市翠屏区南岸路138号', NULL, '2026-02-15 08:35:00', NOW(), 0),
('ORD-TR-20260215-02', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-15 09:50:00', '贺强', '13900139139', '绵阳市涪城区临园路139号', NULL, '2026-02-15 09:50:00', NOW(), 0),
('ORD-TR-20260215-03', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-15 11:05:00', '冯晓燕', '13900139140', '南充市顺庆区西河路140号', NULL, '2026-02-15 11:05:00', NOW(), 0),
('ORD-TR-20260215-04', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-15 12:20:00', '韩冬梅', '13900139141', '达州市通川区朝阳路141号', NULL, '2026-02-15 12:20:00', NOW(), 0),
('ORD-TR-20260215-05', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-15 13:35:00', '曹建平', '13900139142', '乐山市市中区柏杨路142号', NULL, '2026-02-15 13:35:00', NOW(), 0),
('ORD-TR-20260215-06', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-15 14:50:00', '邓丽华', '13900139143', '泸州市江阳区江阳南路143号', NULL, '2026-02-15 14:50:00', NOW(), 0),
('ORD-TR-20260215-07', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-15 16:05:00', '彭志强', '13900139144', '德阳市旌阳区长江东路144号', NULL, '2026-02-15 16:05:00', NOW(), 0),
('ORD-TR-20260215-08', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-15 17:20:00', '蒋敏', '13900139145', '内江市市中区街心花园145号', NULL, '2026-02-15 17:20:00', NOW(), 0),
('ORD-TR-20260215-09', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-15 18:35:00', '薛海涛', '13900139146', '遂宁市船山区遂州路146号', NULL, '2026-02-15 18:35:00', NOW(), 0),
('ORD-TR-20260215-10', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-15 19:50:00', '叶芳', '13900139147', '攀枝花市东区炳草岗147号', NULL, '2026-02-15 19:50:00', NOW(), 0),
('ORD-TR-20260215-11', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-15 21:05:00', '董磊', '13900139148', '自贡市自流井区五星街148号', NULL, '2026-02-15 21:05:00', NOW(), 0),
('ORD-TR-20260215-12', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-15 21:40:00', '程晓红', '13900139149', '眉山市东坡区东坡大道149号', NULL, '2026-02-15 21:40:00', NOW(), 0),
('ORD-TR-20260215-13', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-15 22:10:00', '曾明', '13900139150', '广元市利州区东坝街道150号', NULL, '2026-02-15 22:10:00', NOW(), 0),
('ORD-TR-20260215-14', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-15 22:40:00', '苏静', '13900139151', '广安市广安区思源大道151号', NULL, '2026-02-15 22:40:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260216-01', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-16 08:40:00', '潘建华', '13900139152', '巴中市巴州区江北大道152号', NULL, '2026-02-16 08:40:00', NOW(), 0),
('ORD-TR-20260216-02', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-16 09:55:00', '戴丽娟', '13900139153', '资阳市雁江区车城大道153号', NULL, '2026-02-16 09:55:00', NOW(), 0),
('ORD-TR-20260216-03', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-16 11:10:00', '范伟', '13900139154', '凉山州西昌市航天大道154号', NULL, '2026-02-16 11:10:00', NOW(), 0),
('ORD-TR-20260216-04', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-16 12:25:00', '邹敏', '13900139155', '遵义市汇川区珠海路155号', NULL, '2026-02-16 12:25:00', NOW(), 0),
('ORD-TR-20260216-05', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-16 13:40:00', '陆涛', '13900139156', '六盘水市钟山区钟山大道156号', NULL, '2026-02-16 13:40:00', NOW(), 0),
('ORD-TR-20260216-06', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-16 14:55:00', '江丽', '13900139157', '曲靖市麒麟区麒麟东路157号', NULL, '2026-02-16 14:55:00', NOW(), 0),
('ORD-TR-20260216-07', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-16 16:10:00', '孔杰', '13900139158', '玉溪市红塔区凤凰路158号', NULL, '2026-02-16 16:10:00', NOW(), 0),
('ORD-TR-20260216-08', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-16 17:25:00', '谢芳', '13900139159', '大理市下关镇建设路159号', NULL, '2026-02-16 17:25:00', NOW(), 0),
('ORD-TR-20260216-09', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-16 18:40:00', '严明', '13900139160', '丽江市古城区福慧路160号', NULL, '2026-02-16 18:40:00', NOW(), 0),
('ORD-TR-20260216-10', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-16 19:55:00', '余静', '13900139161', '红河州蒙自市天马路161号', NULL, '2026-02-16 19:55:00', NOW(), 0),
('ORD-TR-20260216-11', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-16 21:10:00', '石磊', '13900139162', '楚雄州楚雄市鹿城北路162号', NULL, '2026-02-16 21:10:00', NOW(), 0),
('ORD-TR-20260216-12', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-16 21:45:00', '白芳', '13900139163', '文山州文山市开化中路163号', NULL, '2026-02-16 21:45:00', NOW(), 0),
('ORD-TR-20260216-13', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-16 22:15:00', '贺强', '13900139164', '西双版纳州景洪市宣慰大道164号', NULL, '2026-02-16 22:15:00', NOW(), 0),
('ORD-TR-20260216-14', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-16 22:45:00', '冯晓燕', '13900139165', '德宏州芒市勐焕路165号', NULL, '2026-02-16 22:45:00', NOW(), 0),
('ORD-TR-20260217-01', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-17 08:45:00', '韩冬梅', '13900139166', '延安市宝塔区南大街166号', NULL, '2026-02-17 08:45:00', NOW(), 0),
('ORD-TR-20260217-02', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-17 10:00:00', '曹建平', '13900139167', '宝鸡市渭滨区经二路167号', NULL, '2026-02-17 10:00:00', NOW(), 0),
('ORD-TR-20260217-03', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-17 11:15:00', '邓丽华', '13900139168', '咸阳市秦都区渭阳中路168号', NULL, '2026-02-17 11:15:00', NOW(), 0),
('ORD-TR-20260217-04', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-17 12:30:00', '彭志强', '13900139169', '汉中市汉台区天汉大道169号', NULL, '2026-02-17 12:30:00', NOW(), 0),
('ORD-TR-20260217-05', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-17 13:45:00', '蒋敏', '13900139170', '榆林市榆阳区长城路170号', NULL, '2026-02-17 13:45:00', NOW(), 0),
('ORD-TR-20260217-06', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-17 15:00:00', '薛海涛', '13900139171', '渭南市临渭区东风大街171号', NULL, '2026-02-17 15:00:00', NOW(), 0),
('ORD-TR-20260217-07', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-17 16:15:00', '叶芳', '13900139172', '铜川市耀州区正阳路172号', NULL, '2026-02-17 16:15:00', NOW(), 0),
('ORD-TR-20260217-08', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-17 17:30:00', '董磊', '13900139173', '安康市汉滨区大桥路173号', NULL, '2026-02-17 17:30:00', NOW(), 0),
('ORD-TR-20260217-09', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-17 18:45:00', '程晓红', '13900139174', '商洛市商州区江滨大道174号', NULL, '2026-02-17 18:45:00', NOW(), 0),
('ORD-TR-20260217-10', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-17 20:00:00', '曾明', '13900139175', '开封市龙亭区宋都御街175号', NULL, '2026-02-17 20:00:00', NOW(), 0),
('ORD-TR-20260217-11', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-17 21:15:00', '苏静', '13900139176', '洛阳市洛龙区开元大道176号', NULL, '2026-02-17 21:15:00', NOW(), 0),
('ORD-TR-20260217-12', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-17 21:50:00', '潘建华', '13900139177', '南阳市卧龙区中州路177号', NULL, '2026-02-17 21:50:00', NOW(), 0),
('ORD-TR-20260217-13', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-17 22:20:00', '戴丽娟', '13900139178', '新乡市红旗区平原路178号', NULL, '2026-02-17 22:20:00', NOW(), 0),
('ORD-TR-20260217-14', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-17 22:50:00', '范伟', '13900139179', '许昌市魏都区莲城大道179号', NULL, '2026-02-17 22:50:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-08~02-17 的 order_item 在下方按 order_no 显式逐条插入（与初始化脚本一致）
-- 02-18 ~ 02-23 每日 4 单（显式真实化：不同收货人、金额为已存在商品单价）
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260218-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-18 09:00:00', '范伟', '13900139015', '北京市西城区金融街18号', NULL, '2026-02-18 09:00:00', NOW(), 0),
('ORD-TR-20260218-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-18 10:30:00', '邹敏', '13900139016', '上海市虹口区四川北路19号', NULL, '2026-02-18 10:30:00', NOW(), 0),
('ORD-TR-20260218-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-18 14:00:00', '陆涛', '13900139017', '广州市越秀区中山五路20号', NULL, '2026-02-18 14:00:00', NOW(), 0),
('ORD-TR-20260218-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-18 16:30:00', '江丽', '13900139018', '深圳市福田区福华路21号', NULL, '2026-02-18 16:30:00', NOW(), 0),
('ORD-TR-20260219-01', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-19 08:45:00', '孔杰', '13900139019', '杭州市滨江区网商路22号', NULL, '2026-02-19 08:45:00', NOW(), 0),
('ORD-TR-20260219-02', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-19 11:00:00', '谢芳', '13900139020', '成都市锦江区春熙路23号', NULL, '2026-02-19 11:00:00', NOW(), 0),
('ORD-TR-20260219-03', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-19 15:20:00', '严明', '13900139021', '南京市玄武区珠江路24号', NULL, '2026-02-19 15:20:00', NOW(), 0),
('ORD-TR-20260219-04', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-19 17:45:00', '余静', '13900139022', '武汉市洪山区珞喻路25号', NULL, '2026-02-19 17:45:00', NOW(), 0),
('ORD-TR-20260220-01', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-20 09:15:00', '石磊', '13900139023', '西安市未央区凤城路26号', NULL, '2026-02-20 09:15:00', NOW(), 0),
('ORD-TR-20260220-02', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-20 12:30:00', '白芳', '13900139024', '重庆市江北区观音桥27号', NULL, '2026-02-20 12:30:00', NOW(), 0),
('ORD-TR-20260220-03', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-20 14:50:00', '贺强', '13900139025', '郑州市二七区德化街28号', NULL, '2026-02-20 14:50:00', NOW(), 0),
('ORD-TR-20260220-04', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-20 18:00:00', '冯晓燕', '13900139026', '长沙市开福区五一路29号', NULL, '2026-02-20 18:00:00', NOW(), 0),
('ORD-TR-20260221-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-21 08:30:00', '韩冬梅', '13900139027', '济南市历下区泺源大街30号', NULL, '2026-02-21 08:30:00', NOW(), 0),
('ORD-TR-20260221-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-21 11:45:00', '曹建平', '13900139028', '哈尔滨市道里区中央大街31号', NULL, '2026-02-21 11:45:00', NOW(), 0),
('ORD-TR-20260221-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-21 16:00:00', '邓丽华', '13900139029', '福州市鼓楼区五四路32号', NULL, '2026-02-21 16:00:00', NOW(), 0),
('ORD-TR-20260221-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-21 19:20:00', '彭志强', '13900139030', '厦门市思明区鹭江道33号', NULL, '2026-02-21 19:20:00', NOW(), 0),
('ORD-TR-20260222-01', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-22 09:00:00', '蒋敏', '13900139031', '合肥市蜀山区长江西路34号', NULL, '2026-02-22 09:00:00', NOW(), 0),
('ORD-TR-20260222-02', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-22 13:15:00', '薛海涛', '13900139032', '南昌市东湖区中山路35号', NULL, '2026-02-22 13:15:00', NOW(), 0),
('ORD-TR-20260222-03', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-22 15:40:00', '叶芳', '13900139033', '昆明市五华区东风东路36号', NULL, '2026-02-22 15:40:00', NOW(), 0),
('ORD-TR-20260222-04', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-22 17:55:00', '董磊', '13900139034', '南宁市青秀区民族大道37号', NULL, '2026-02-22 17:55:00', NOW(), 0),
('ORD-TR-20260223-01', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-23 08:20:00', '程晓红', '13900139035', '贵阳市南明区中华南路38号', NULL, '2026-02-23 08:20:00', NOW(), 0),
('ORD-TR-20260223-02', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-23 10:50:00', '曾明', '13900139036', '兰州市城关区庆阳路39号', NULL, '2026-02-23 10:50:00', NOW(), 0),
('ORD-TR-20260223-03', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-23 14:10:00', '苏静', '13900139037', '乌鲁木齐市天山区解放路40号', NULL, '2026-02-23 14:10:00', NOW(), 0),
('ORD-TR-20260223-04', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-23 16:35:00', '潘建华', '13900139038', '海口市龙华区滨海大道41号', NULL, '2026-02-23 16:35:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-18 ~ 02-23 订单明细（与初始化脚本一致：每单一条 INSERT，显式 WHERE order_no = '...'）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260218-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260218-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260218-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260218-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260219-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260219-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260219-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260219-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260220-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260220-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260220-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260220-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260221-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260221-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260221-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260221-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260222-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260222-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260222-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260222-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260223-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260223-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260223-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260223-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-24 补 2 单
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('ORD-TR-20260224-01', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-24 10:00:00', '张明', '13800138001', '北京市朝阳区建国路1号', NULL, '2026-02-24 10:00:00', NOW(), 0),
('ORD-TR-20260224-02', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-24 14:00:00', '李芳', '13800138002', '上海市浦东新区张江路2号', NULL, '2026-02-24 14:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-25 ~ 02-28 每日 12 单（显式插入，收货人/金额/地址均不循环重复）
INSERT INTO `order` (`order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`, `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`) VALUES
('ORD-TR-20260225-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-25 08:00:00', '冯晓燕', '13900139180', '北京市朝阳区望京街180号', NULL, '2026-02-25 08:00:00', NOW(), 0),
('ORD-TR-20260225-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-25 09:15:00', '韩冬梅', '13900139181', '上海市长宁区愚园路181号', NULL, '2026-02-25 09:15:00', NOW(), 0),
('ORD-TR-20260225-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-25 10:30:00', '曹建平', '13900139182', '广州市海珠区江南大道182号', NULL, '2026-02-25 10:30:00', NOW(), 0),
('ORD-TR-20260225-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-25 11:45:00', '邓丽华', '13900139183', '深圳市龙岗区龙城大道183号', NULL, '2026-02-25 11:45:00', NOW(), 0),
('ORD-TR-20260225-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-25 13:00:00', '彭志强', '13900139184', '杭州市萧山区市心路184号', NULL, '2026-02-25 13:00:00', NOW(), 0),
('ORD-TR-20260225-06', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-25 14:15:00', '蒋敏', '13900139185', '成都市青羊区金沙路185号', NULL, '2026-02-25 14:15:00', NOW(), 0),
('ORD-TR-20260225-07', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-25 15:30:00', '薛海涛', '13900139186', '南京市栖霞区仙林大道186号', NULL, '2026-02-25 15:30:00', NOW(), 0),
('ORD-TR-20260225-08', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-25 16:45:00', '叶芳', '13900139187', '武汉市硚口区解放大道187号', NULL, '2026-02-25 16:45:00', NOW(), 0),
('ORD-TR-20260225-09', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-25 18:00:00', '董磊', '13900139188', '西安市灞桥区纺渭路188号', NULL, '2026-02-25 18:00:00', NOW(), 0),
('ORD-TR-20260225-10', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-25 19:15:00', '程晓红', '13900139189', '重庆市九龙坡区杨家坪189号', NULL, '2026-02-25 19:15:00', NOW(), 0),
('ORD-TR-20260225-11', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-25 20:30:00', '曾明', '13900139190', '郑州市管城区商城路190号', NULL, '2026-02-25 20:30:00', NOW(), 0),
('ORD-TR-20260225-12', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-25 21:45:00', '苏静', '13900139191', '长沙市芙蓉区五一大道191号', NULL, '2026-02-25 21:45:00', NOW(), 0),
('ORD-TR-20260226-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-26 08:05:00', '潘建华', '13900139192', '济南市槐荫区经十路192号', NULL, '2026-02-26 08:05:00', NOW(), 0),
('ORD-TR-20260226-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-26 09:20:00', '戴丽娟', '13900139193', '哈尔滨市香坊区中山路193号', NULL, '2026-02-26 09:20:00', NOW(), 0),
('ORD-TR-20260226-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-26 10:35:00', '范伟', '13900139194', '福州市仓山区金山大道194号', NULL, '2026-02-26 10:35:00', NOW(), 0),
('ORD-TR-20260226-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-26 11:50:00', '邹敏', '13900139195', '厦门市集美区杏林湾195号', NULL, '2026-02-26 11:50:00', NOW(), 0),
('ORD-TR-20260226-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-26 13:05:00', '陆涛', '13900139196', '合肥市庐阳区长江路196号', NULL, '2026-02-26 13:05:00', NOW(), 0),
('ORD-TR-20260226-06', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-26 14:20:00', '江丽', '13900139197', '南昌市西湖区孺子路197号', NULL, '2026-02-26 14:20:00', NOW(), 0),
('ORD-TR-20260226-07', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-26 15:35:00', '孔杰', '13900139198', '昆明市盘龙区北京路198号', NULL, '2026-02-26 15:35:00', NOW(), 0),
('ORD-TR-20260226-08', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-26 16:50:00', '谢芳', '13900139199', '南宁市兴宁区朝阳路199号', NULL, '2026-02-26 16:50:00', NOW(), 0),
('ORD-TR-20260226-09', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-26 18:05:00', '严明', '13900139200', '贵阳市观山湖区林城路200号', NULL, '2026-02-26 18:05:00', NOW(), 0),
('ORD-TR-20260226-10', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-26 19:20:00', '余静', '13900139201', '兰州市西固区福利路201号', NULL, '2026-02-26 19:20:00', NOW(), 0),
('ORD-TR-20260226-11', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-26 20:35:00', '石磊', '13900139202', '乌鲁木齐市水磨沟区南湖路202号', NULL, '2026-02-26 20:35:00', NOW(), 0),
('ORD-TR-20260226-12', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-26 21:50:00', '白芳', '13900139203', '海口市秀英区海秀路203号', NULL, '2026-02-26 21:50:00', NOW(), 0),
('ORD-TR-20260227-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-27 08:10:00', '贺强', '13900139204', '石家庄市裕华区槐安东路204号', NULL, '2026-02-27 08:10:00', NOW(), 0),
('ORD-TR-20260227-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-27 09:25:00', '冯晓燕', '13900139205', '太原市晋源区新晋祠路205号', NULL, '2026-02-27 09:25:00', NOW(), 0),
('ORD-TR-20260227-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-27 10:40:00', '韩冬梅', '13900139206', '沈阳市大东区津桥路206号', NULL, '2026-02-27 10:40:00', NOW(), 0),
('ORD-TR-20260227-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-27 11:55:00', '曹建平', '13900139207', '大连市西岗区黄河路207号', NULL, '2026-02-27 11:55:00', NOW(), 0),
('ORD-TR-20260227-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-27 13:10:00', '邓丽华', '13900139208', '青岛市李沧区夏庄路208号', NULL, '2026-02-27 13:10:00', NOW(), 0),
('ORD-TR-20260227-06', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-27 14:25:00', '彭志强', '13900139209', '宁波市北仑区明州路209号', NULL, '2026-02-27 14:25:00', NOW(), 0),
('ORD-TR-20260227-07', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-27 15:40:00', '蒋敏', '13900139210', '无锡市梁溪区中山路210号', NULL, '2026-02-27 15:40:00', NOW(), 0),
('ORD-TR-20260227-08', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-27 16:55:00', '薛海涛', '13900139211', '佛山市顺德区大良街道211号', NULL, '2026-02-27 16:55:00', NOW(), 0),
('ORD-TR-20260227-09', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-27 18:10:00', '叶芳', '13900139212', '东莞市东城区东城路212号', NULL, '2026-02-27 18:10:00', NOW(), 0),
('ORD-TR-20260227-10', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-27 19:25:00', '董磊', '13900139213', '苏州市姑苏区观前街213号', NULL, '2026-02-27 19:25:00', NOW(), 0),
('ORD-TR-20260227-11', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-27 20:40:00', '程晓红', '13900139214', '珠海市金湾区三灶镇214号', NULL, '2026-02-27 20:40:00', NOW(), 0),
('ORD-TR-20260227-12', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-27 21:55:00', '曾明', '13900139215', '温州市瓯海区娄桥街道215号', NULL, '2026-02-27 21:55:00', NOW(), 0),
('ORD-TR-20260228-01', 1, '1', 1, 'CN', 99.00, 0, 0, 0, 99.00, 3, 1, '2026-02-28 08:15:00', '苏静', '13900139216', '烟台市莱山区观海路216号', NULL, '2026-02-28 08:15:00', NOW(), 0),
('ORD-TR-20260228-02', 1, '1', 1, 'CN', 199.00, 0, 0, 0, 199.00, 3, 1, '2026-02-28 09:30:00', '潘建华', '13900139217', '唐山市路北区建设路217号', NULL, '2026-02-28 09:30:00', NOW(), 0),
('ORD-TR-20260228-03', 1, '1', 1, 'CN', 89.00, 0, 0, 0, 89.00, 3, 1, '2026-02-28 10:45:00', '戴丽娟', '13900139218', '洛阳市西工区中州路218号', NULL, '2026-02-28 10:45:00', NOW(), 0),
('ORD-TR-20260228-04', 1, '1', 1, 'CN', 158.00, 0, 0, 0, 158.00, 3, 1, '2026-02-28 12:00:00', '范伟', '13900139219', '徐州市泉山区淮海西路219号', NULL, '2026-02-28 12:00:00', NOW(), 0),
('ORD-TR-20260228-05', 1, '1', 1, 'CN', 45.00, 0, 0, 0, 45.00, 3, 1, '2026-02-28 13:15:00', '邹敏', '13900139220', '南通市港闸区城港路220号', NULL, '2026-02-28 13:15:00', NOW(), 0),
('ORD-TR-20260228-06', 1, '1', 1, 'CN', 95.00, 0, 0, 0, 95.00, 3, 1, '2026-02-28 14:30:00', '陆涛', '13900139221', '扬州市广陵区文昌中路221号', NULL, '2026-02-28 14:30:00', NOW(), 0),
('ORD-TR-20260228-07', 1, '1', 1, 'CN', 35.00, 0, 0, 0, 35.00, 3, 1, '2026-02-28 15:45:00', '江丽', '13900139222', '绍兴市柯桥区金柯桥大道222号', NULL, '2026-02-28 15:45:00', NOW(), 0),
('ORD-TR-20260228-08', 1, '1', 1, 'CN', 39.00, 0, 0, 0, 39.00, 3, 1, '2026-02-28 17:00:00', '孔杰', '13900139223', '嘉兴市秀洲区洪兴路223号', NULL, '2026-02-28 17:00:00', NOW(), 0),
('ORD-TR-20260228-09', 1, '1', 1, 'CN', 69.00, 0, 0, 0, 69.00, 3, 1, '2026-02-28 18:15:00', '谢芳', '13900139224', '金华市金东区光南路224号', NULL, '2026-02-28 18:15:00', NOW(), 0),
('ORD-TR-20260228-10', 1, '1', 1, 'CN', 88.00, 0, 0, 0, 88.00, 3, 1, '2026-02-28 19:30:00', '严明', '13900139225', '常州市新北区通江路225号', NULL, '2026-02-28 19:30:00', NOW(), 0),
('ORD-TR-20260228-11', 1, '1', 1, 'CN', 59.00, 0, 0, 0, 59.00, 3, 1, '2026-02-28 20:45:00', '余静', '13900139226', '泉州市鲤城区温陵路226号', NULL, '2026-02-28 20:45:00', NOW(), 0),
('ORD-TR-20260228-12', 1, '1', 1, 'CN', 399.00, 0, 0, 0, 399.00, 3, 1, '2026-02-28 22:00:00', '石磊', '13900139227', '漳州市龙文区水仙大街227号', NULL, '2026-02-28 22:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`), `update_time` = NOW();

-- 02-02~02-06、02-08~02-17、02-24、02-25~02-28 订单明细：与初始化脚本一致，按 order_no 显式逐条插入（每单一条 INSERT ... SELECT ... WHERE order_no = '...'）
-- 以下按日期分段，每单对应商品 1~12 单价（99,199,89,158,45,95,35,39,69,88,59,399），无则插入
-- 02-02（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260202-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-03（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260203-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-04（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260204-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-05（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260205-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-06（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260206-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-08～02-17、02-24、02-25～02-28 订单明细：按 order_no 显式逐条插入（与初始化脚本一致）
-- 02-08（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260208-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-09（14 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260209-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-10～02-17：每日 14 单，按 order_no 显式插入
-- 02-10（14 单）金额序: 95,35,39,69,88,59,399,99,199,89,158,45,95,35
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260210-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-11（14 单）金额序: 39,69,88,59,399,99,199,89,158,45,95,35,39,69
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260211-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-12～02-17、02-24、02-25～02-28：按 order_no 显式补 order_item（与初始化一致：每单一条 INSERT ... WHERE order_no = '...'）
-- 02-12（14 单）88,59,399,99,199,89,158,45,95,35,39,69,88,59
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260212-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-13（14 单）399,99,199,89,158,45,95,35,39,69,88,59,399,99
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260213-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-14（14 单）199,89,158,45,95,35,39,69,88,59,399,99,199,89
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260214-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-15（14 单）158,45,95,35,39,69,88,59,399,99,199,89,158,45
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260215-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-16（14 单）95,35,39,69,88,59,399,99,199,89,158,45,95,35
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260216-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-17（14 单）39,69,88,59,399,99,199,89,158,45,95,35,39,69
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-13' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260217-14' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-24（2 单）199,158
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260224-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260224-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-25～02-28（各 12 单）99,199,89,158,45,95,35,39,69,88,59,399
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260225-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-26（12 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260226-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-27（12 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260227-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 02-28（12 单）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 1, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-01' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 2, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-02' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 3, 'SKU003', 3, 89.00, 1, 89.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-03' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 4, 'SKU004', 4, 158.00, 1, 158.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-04' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://x0.ifengimg.com/ucms/2023_51/0C4C11DA93BDA320ED53EDEAF1C08F8A95BB705F_size63_w800_h800.jpg', 5, 'SKU005', 5, 45.00, 1, 45.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-05' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 6, 'SKU006', 6, 95.00, 1, 95.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-06' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 7, 'SKU007', 7, 35.00, 1, 35.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-07' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://imgservice.suning.cn/uimg1/b2c/image/_bZYN2t8D1lEzVLtbUrLtg.jpg', 8, 'SKU008', 8, 39.00, 1, 39.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-08' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 9, '桌面收纳盒', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', 9, 'SKU009', 9, 69.00, 1, 69.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-09' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://pic2.zhimg.com/v2-a99a14f6d96d4b2fbe91226bdd58aae9_r.jpg', 10, 'SKU010', 10, 88.00, 1, 88.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-10' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://img.alicdn.com/bao/uploaded/O1CN01AVX2hI1s1rBQOJrAO_!!6000000005707-0-yinhe.jpg', 11, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-11' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 12, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW() FROM `order` o WHERE o.`order_no` = 'ORD-TR-20260228-12' AND (o.`deleted` = 0 OR o.`deleted` IS NULL) AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id`);

-- 将订单主表金额与明细一致（按 order_id 汇总 SUM(total_price)，支持一单多品）
UPDATE `order` o
INNER JOIN (
  SELECT oi.`order_id`, SUM(oi.`total_price`) AS `total_price`
  FROM `order_item` oi
  INNER JOIN `order` o2 ON o2.`id` = oi.`order_id` AND o2.`order_no` LIKE 'ORD-TR-2026%' AND (o2.`deleted` = 0 OR o2.`deleted` IS NULL)
  WHERE oi.`order_no` LIKE 'ORD-TR-2026%'
  GROUP BY oi.`order_id`
) t ON t.`order_id` = o.`id`
SET o.`total_amount` = t.`total_price`, o.`pay_amount` = t.`total_price`, o.`update_time` = NOW()
WHERE o.`order_no` LIKE 'ORD-TR-2026%';

-- ===================== 5. 退款库 erp_list_refund =====================

USE `erp_list_refund`;

INSERT INTO `refund_reason` (`reason_name`, `reason_code`, `sort_order`, `status`) VALUES
('商品质量问题', 'QUALITY_ISSUE', 1, 1),
('商品与描述不符', 'DESCRIPTION_MISMATCH', 2, 1),
('不想要了', 'DONT_WANT', 3, 1),
('收到商品损坏', 'DAMAGED', 4, 1),
('发错商品', 'WRONG_ITEM', 5, 1),
('其他原因', 'OTHER', 6, 1)
ON DUPLICATE KEY UPDATE `reason_name` = VALUES(`reason_name`), `sort_order` = VALUES(`sort_order`), `status` = VALUES(`status`);

-- 退款申请（关联真实订单 + 首条订单明细 order_item_id，模拟真实退款、可展示商品图）
INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602150001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 99.00, 2, '商品与描述不符',
  4, '2026-02-15 10:00:00', '2026-02-15 14:00:00', 1, '超级管理员', NULL, '2026-02-15 16:00:00', 'TP-REF-202602150001', '客户反馈颜色与页面不符', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602050006' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602150001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602160001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 257.00, 3, '不想要了',
  1, '2026-02-16 09:30:00', '2026-02-16 11:00:00', 1, '超级管理员', '已同意退款', NULL, NULL, '客户取消订单', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602070008' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602160001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602170001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 200.00, 4, '收到商品损坏',
  0, '2026-02-17 14:20:00', NULL, NULL, NULL, NULL, NULL, NULL, '快递压坏外盒，申请部分退款', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602080009' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602170001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602180001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 178.00, 5, '发错商品',
  4, '2026-02-18 08:15:00', '2026-02-18 10:00:00', 1, '超级管理员', NULL, '2026-02-18 15:30:00', 'TP-REF-202602180001', '发成另一款型号，客户要求全额退', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602090010' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602180001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602210001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 199.00, 6, '其他原因',
  3, '2026-02-21 16:00:00', '2026-02-21 17:00:00', 1, '超级管理员', NULL, NULL, NULL, '重复下单，申请退其中一单部分金额', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602100011' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602210001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-US-202602190001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 2, 49.99, 1, '商品质量问题',
  4, '2026-02-19 11:00:00', '2026-02-19 14:00:00', 1, '超级管理员', NULL, '2026-02-19 18:00:00', 'TP-REF-US-202602190001', 'Headphone left channel no sound', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-US-202602010001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602190001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-US-202602200001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 2, 59.99, 3, '不想要了',
  2, '2026-02-20 09:00:00', '2026-02-20 10:30:00', 1, '超级管理员', '已发货不可退', NULL, NULL, 'Customer changed mind after ship', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602200001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `order_item_id`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-US-202602220001', o.`id`, o.`order_no`, (SELECT MIN(oi.`id`) FROM `erp_list_order`.`order_item` oi WHERE oi.`order_id` = o.`id`), 1, 0, CONCAT('PAY-', o.`order_no`), '1', 2, 129.00, 4, '收到商品损坏',
  4, '2026-02-22 13:00:00', '2026-02-22 15:00:00', 1, '超级管理员', NULL, '2026-02-22 20:00:00', 'TP-REF-US-202602220001', 'Package arrived damaged', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-US-202602050001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602220001' AND ra.`deleted` = 0) LIMIT 1;

-- 退款记录（仅对 refund_status=4 退款成功的申请写入）
INSERT INTO `refund_record` (`refund_id`, `refund_no`, `refund_amount`, `refund_status`, `third_party_refund_no`, `refund_time`, `create_time`)
SELECT ra.`id`, ra.`refund_no`, ra.`refund_amount`, 1, ra.`third_party_refund_no`, ra.`refund_time`, NOW()
FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602150001' AND ra.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_record` rr WHERE rr.`refund_no` = ra.`refund_no`) LIMIT 1;

INSERT INTO `refund_record` (`refund_id`, `refund_no`, `refund_amount`, `refund_status`, `third_party_refund_no`, `refund_time`, `create_time`)
SELECT ra.`id`, ra.`refund_no`, ra.`refund_amount`, 1, ra.`third_party_refund_no`, ra.`refund_time`, NOW()
FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602180001' AND ra.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_record` rr WHERE rr.`refund_no` = ra.`refund_no`) LIMIT 1;

INSERT INTO `refund_record` (`refund_id`, `refund_no`, `refund_amount`, `refund_status`, `third_party_refund_no`, `refund_time`, `create_time`)
SELECT ra.`id`, ra.`refund_no`, ra.`refund_amount`, 1, ra.`third_party_refund_no`, ra.`refund_time`, NOW()
FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602190001' AND ra.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_record` rr WHERE rr.`refund_no` = ra.`refund_no`) LIMIT 1;

INSERT INTO `refund_record` (`refund_id`, `refund_no`, `refund_amount`, `refund_status`, `third_party_refund_no`, `refund_time`, `create_time`)
SELECT ra.`id`, ra.`refund_no`, ra.`refund_amount`, 1, ra.`third_party_refund_no`, ra.`refund_time`, NOW()
FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602220001' AND ra.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_record` rr WHERE rr.`refund_no` = ra.`refund_no`) LIMIT 1;


-- ============================================================
-- 执行说明：
-- 1. 先执行「建表汇总.sql」完成建库建表。
-- 2. 再执行本文件「erp_list_init_data_only.sql」完成所有初始化数据。
-- 3. 账号：admin / 123456（超管）；root / root（平台管理员，请登录后修改密码）。
-- ============================================================
