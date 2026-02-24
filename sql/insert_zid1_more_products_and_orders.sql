-- ============================================================
-- zid=1 追加数据：更多商品 + 集中日期的订单（用于生成补货建议）
-- 依赖：insert_zid1_admin_and_demo_data.sql 已执行（用户/店铺/商品 1-6 已存在）
-- 订单日期集中在 2026-02-18 ~ 2026-02-24，便于补货建议统计近期销量
-- 可重复执行：订单使用 ON DUPLICATE KEY UPDATE，订单明细用 NOT EXISTS 防重复
-- ============================================================

-- ------------------------------ 1. 追加商品 erp_list_product（id 7-12） ------------------------------
USE `erp_list_product`;

INSERT INTO `company_product` (
  `id`, `zid`, `sid`, `product_name`, `product_code`, `sku_code`, `platform_sku`, `image_url`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
(7,  '1', 1, 'USB-C 数据线',           'P007', 'SKU007', 'AMZ-SKU-007', 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(8,  '1', 1, '手机支架',               'P008', 'SKU008', 'AMZ-SKU-008', 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(9,  '1', 1, '桌面收纳盒',             'P009', 'SKU009', 'AMZ-SKU-009', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(10, '1', 1, '护眼台灯',               'P010', 'SKU010', 'AMZ-SKU-010', 'https://images.unsplash.com/photo-1507473885765-e6e407f36cbf?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(11, '1', 1, '静音小风扇',             'P011', 'SKU011', 'AMZ-SKU-011', 'https://images.unsplash.com/photo-1585771724684-38269d4a029e?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(12, '1', 1, '移动硬盘 1TB',           'P012', 'SKU012', 'AMZ-SKU-012', 'https://images.unsplash.com/photo-1597872200969-2b65d56bd3b6?w=400', 'zid=1 商品', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `product_name` = VALUES(`product_name`), `image_url` = VALUES(`image_url`);


-- ------------------------------ 2. 订单 + 订单明细 erp_list_order（日期集中 2026-02-18 ~ 2026-02-24） ------------------------------
USE `erp_list_order`;

-- 订单主表：一批订单，create_time 集中在 2 月 18-24 日
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('ORD-Z1-202602180001', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, '李四', '13900139001', '上海市浦东新区张江路1号', '补货样本', '2026-02-18 09:15:00', NOW(), 0),
('ORD-Z1-202602180002', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, '王五', '13900139002', '广州市天河区体育西路2号', '补货样本', '2026-02-18 10:30:00', NOW(), 0),
('ORD-Z1-202602190001', 1, '1', 1, 'CN', 356.00, 0.00, 0.00, 0.00, 356.00, 1, 1, '赵六', '13900139003', '深圳市南山区科技园3号', '补货样本', '2026-02-19 08:00:00', NOW(), 0),
('ORD-Z1-202602190002', 1, '1', 1, 'CN', 88.00, 0.00, 0.00, 0.00, 88.00, 1, 1, '钱七', '13900139004', '杭州市西湖区文三路4号', '补货样本', '2026-02-19 14:20:00', NOW(), 0),
('ORD-Z1-202602190003', 1, '1', 1, 'CN', 420.00, 10.00, 0.00, 0.00, 410.00, 1, 1, '孙八', '13900139005', '成都市武侯区天府大道5号', '补货样本', '2026-02-19 16:45:00', NOW(), 0),
('ORD-Z1-202602200001', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '周九', '13900139006', '南京市鼓楼区中山路6号', '补货样本', '2026-02-20 09:00:00', NOW(), 0),
('ORD-Z1-202602200002', 1, '1', 1, 'CN', 297.00, 0.00, 0.00, 0.00, 297.00, 1, 1, '吴十', '13900139007', '武汉市洪山区光谷7号', '补货样本', '2026-02-20 11:30:00', NOW(), 0),
('ORD-Z1-202602200003', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, '郑一', '13900139008', '西安市雁塔区高新路8号', '补货样本', '2026-02-20 15:00:00', NOW(), 0),
('ORD-Z1-202602210001', 1, '1', 1, 'CN', 199.00, 0.00, 0.00, 0.00, 199.00, 1, 1, '王二', '13900139009', '苏州市工业园区星海街9号', '补货样本', '2026-02-21 10:00:00', NOW(), 0),
('ORD-Z1-202602210002', 1, '1', 1, 'CN', 456.00, 0.00, 0.00, 0.00, 456.00, 1, 1, '陈三', '13900139010', '天津市滨海新区塘沽10号', '补货样本', '2026-02-21 13:20:00', NOW(), 0),
('ORD-Z1-202602220001', 1, '1', 1, 'CN', 128.00, 0.00, 0.00, 0.00, 128.00, 1, 1, '林四', '13900139011', '青岛市市南区香港路11号', '补货样本', '2026-02-22 08:30:00', NOW(), 0),
('ORD-Z1-202602220002', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '黄五', '13900139012', '大连市中山区人民路12号', '补货样本', '2026-02-22 12:00:00', NOW(), 0),
('ORD-Z1-202602220003', 1, '1', 1, 'CN', 388.00, 0.00, 0.00, 0.00, 388.00, 1, 1, '刘六', '13900139013', '长沙市岳麓区麓山南路13号', '补货样本', '2026-02-22 17:00:00', NOW(), 0),
('ORD-Z1-202602230001', 1, '1', 1, 'CN', 268.00, 0.00, 0.00, 0.00, 268.00, 1, 1, '何七', '13900139014', '郑州市金水区花园路14号', '补货样本', '2026-02-23 09:45:00', NOW(), 0),
('ORD-Z1-202602230002', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, '徐八', '13900139015', '济南市历下区泉城路15号', '补货样本', '2026-02-23 14:10:00', NOW(), 0),
('ORD-Z1-202602240001', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '朱九', '13900139016', '哈尔滨市南岗区西大直街16号', '补货样本', '2026-02-24 10:00:00', NOW(), 0),
('ORD-Z1-202602240002', 1, '1', 1, 'CN', 520.00, 20.00, 0.00, 0.00, 500.00, 1, 1, '马十', '13900139017', '厦门市思明区鹭江道17号', '补货样本', '2026-02-24 15:30:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`), `create_time` = VALUES(`create_time`);


-- 订单明细：每个订单对应商品（product_id/company_product_id 1-12），与上面订单一一对应
-- 使用子查询插入，避免重复：仅当该 order_id + product_id 不存在时插入

-- ORD-Z1-202602180001: 蓝牙耳机x1 + 机械键盘x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;

-- ORD-Z1-202602180002: 机械键盘x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602180002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;

-- ORD-Z1-202602190001: 充电宝x2 + 运动手环x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 178.00, 1, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;

-- ORD-Z1-202602190002: 保温杯x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://images.unsplash.com/photo-1602143407151-7111542de693?w=400', NULL, 'SKU005', 5, 88.00, 1, 88.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;

-- ORD-Z1-202602190003: 无线鼠标x2 + 机械键盘x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 6, '无线鼠标', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', NULL, 'SKU006', 6, 79.00, 2, 158.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 6) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 252.00, 1, 252.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602190003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;

-- ORD-Z1-202602200001: 无线蓝牙耳机x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;

-- ORD-Z1-202602200002: 机械键盘x1 + 无线蓝牙耳机x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 159.00, 1, 159.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 138.00, 1, 138.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;

-- ORD-Z1-202602200003: 运动手环x1 + 保温杯x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 89.00, 1, 89.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://images.unsplash.com/photo-1602143407151-7111542de693?w=400', NULL, 'SKU005', 5, 69.00, 1, 69.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602200003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;

-- ORD-Z1-202602210001: 机械键盘x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602210001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;

-- ORD-Z1-202602210002: 便携充电宝x2 + 无线鼠标x1 + 运动手环x1（新品 7 数据线）
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

-- ORD-Z1-202602220001: USB-C 数据线x2（商品7）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 7, 'USB-C 数据线', 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400', NULL, 'SKU007', 7, 29.00, 2, 58.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 7) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://images.unsplash.com/photo-1602143407151-7111542de693?w=400', NULL, 'SKU005', 5, 70.00, 1, 70.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 5) LIMIT 1;

-- ORD-Z1-202602220002: 无线蓝牙耳机x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;

-- ORD-Z1-202602220003: 机械键盘x1 + 护眼台灯x1（商品10）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 10, '护眼台灯', 'https://images.unsplash.com/photo-1507473885765-e6e407f36cbf?w=400', NULL, 'SKU010', 10, 189.00, 1, 189.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602220003' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 10) LIMIT 1;

-- ORD-Z1-202602230001: 运动手环x1 + 手机支架x1（商品8）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 4, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', NULL, 'SKU004', 4, 139.00, 1, 139.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 4) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 8, '手机支架', 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400', NULL, 'SKU008', 8, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 8) LIMIT 1;

-- ORD-Z1-202602230002: 便携充电宝x2
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 3, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', NULL, 'SKU003', 3, 89.00, 2, 178.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602230002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 3) LIMIT 1;

-- ORD-Z1-202602240001: 无线蓝牙耳机x1
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;

-- ORD-Z1-202602240002: 移动硬盘x1 + 机械键盘x1 + 静音小风扇x1（商品11、12）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 12, '移动硬盘 1TB', 'https://images.unsplash.com/photo-1597872200969-2b65d56bd3b6?w=400', NULL, 'SKU012', 12, 399.00, 1, 399.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 12) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 2, '机械键盘', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', NULL, 'SKU002', 2, 199.00, 1, 199.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 2) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 11, '静音小风扇', 'https://images.unsplash.com/photo-1585771724684-38269d4a029e?w=400', NULL, 'SKU011', 11, 59.00, 1, 59.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602240002' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 11) LIMIT 1;

-- ============================================================
-- 说明：执行后近期销量（按 create_time 2026-02-18~24 统计）示例：
-- 无线蓝牙耳机 4 单、机械键盘 6 单、便携充电宝 4 单、运动手环 4 单、保温杯 3 单、无线鼠标 2 单，
-- 以及新品 USB-C 数据线、手机支架、护眼台灯、静音小风扇、移动硬盘 等，便于生成补货建议。
-- ============================================================
