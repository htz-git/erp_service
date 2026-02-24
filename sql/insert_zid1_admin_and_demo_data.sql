-- ============================================================
-- zid=1 初始数据汇总：超管 + 平台管理员 + 公司 + 多商品 + 多订单（日期集中，便于补货建议）
-- 依赖：建表汇总已执行（user/role/permission/company/seller/company_product/order/order_item 表存在）
-- 可重复执行（存在则更新或跳过）
-- ============================================================

-- ------------------------------ 1. 用户库 erp_list_user ------------------------------
USE `erp_list_user`;

-- 1.1 角色（超级管理员、平台管理员）
INSERT INTO `role` (`id`, `role_name`, `role_code`, `description`, `status`, `create_time`, `update_time`, `deleted`) VALUES
(1, '超级管理员', 'SUPER_ADMIN', '超管，拥有全部权限', 1, NOW(), NOW(), 0),
(2, '平台管理员', 'PLATFORM_ADMIN', '平台管理员，可访问管理后台', 1, NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `role_name` = VALUES(`role_name`), `description` = VALUES(`description`);

-- 1.2 超管账号（id=1, zid=1, username=admin），密码为 123456 的 BCrypt 密文
INSERT INTO `user` (
  `id`, `zid`, `username`, `password`, `real_name`, `phone`, `email`, `avatar`, `status`, `create_time`, `update_time`, `deleted`
) VALUES (
  1, '1', 'admin',
  '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi',
  '超级管理员', '18250099985', '2281852840@qq.com', NULL, 1, NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `zid` = VALUES(`zid`), `real_name` = VALUES(`real_name`), `phone` = VALUES(`phone`), `email` = VALUES(`email`);

-- 1.3 超管绑定角色（超级管理员 + 平台管理员）
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`, `create_time`) VALUES (1, 1, NOW()), (1, 2, NOW());

-- 1.4 超管绑定「管理员-后台」权限（admin:access）
INSERT IGNORE INTO `user_permission` (`user_id`, `permission_id`, `create_time`)
SELECT 1, p.`id`, NOW() FROM `permission` p WHERE p.`permission_code` = 'admin:access' AND p.`deleted` = 0 LIMIT 1;

-- 1.5 公司（zid=1 对应公司）
INSERT INTO `company` (
  `id`, `company_name`, `contact_name`, `contact_phone`, `contact_email`, `address`, `status`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES (
  '1', 'erp公司', '超级管理员', '18250099985', '2281852840@qq.com', NULL, 1, '', NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `company_name` = VALUES(`company_name`), `contact_name` = VALUES(`contact_name`);


-- ------------------------------ 2. 店铺 erp_list_seller ------------------------------
USE `erp_list_seller`;

INSERT INTO `seller` (
  `id`, `sid`, `user_id`, `zid`, `seller_name`, `platform`, `platform_account`, `status`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES (
  1, 'S1', 1, '1', '默认店铺', 'amazon', 'seller-z1@example.com', 1, 'zid=1 公司店铺', NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `seller_name` = VALUES(`seller_name`);


-- ------------------------------ 3. 商品 erp_list_product（图片使用公网示例图） ------------------------------
USE `erp_list_product`;

INSERT INTO `company_product` (
  `id`, `zid`, `sid`, `product_name`, `product_code`, `sku_code`, `platform_sku`, `image_url`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
(1, '1', 1, '无线蓝牙耳机', 'P001', 'SKU001', 'AMZ-SKU-001', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'zid=1 示例商品', NOW(), NOW(), 0),
(2, '1', 1, '机械键盘', 'P002', 'SKU002', 'AMZ-SKU-002', 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(3, '1', 1, '便携充电宝', 'P003', 'SKU003', 'AMZ-SKU-003', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(4, '1', 1, '运动手环', 'P004', 'SKU004', 'AMZ-SKU-004', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(5, '1', 1, '保温杯', 'P005', 'SKU005', 'AMZ-SKU-005', 'https://images.unsplash.com/photo-1602143407151-7111542de693?w=400', 'zid=1 商品', NOW(), NOW(), 0),
(6, '1', 1, '无线鼠标', 'P006', 'SKU006', 'AMZ-SKU-006', 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 'zid=1 商品', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `product_name` = VALUES(`product_name`), `image_url` = VALUES(`image_url`);


-- ------------------------------ 4. 订单 + 订单明细 erp_list_order ------------------------------
USE `erp_list_order`;

INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES (
  'ORD-Z1-202602050001', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00,
  1, 1, '张三', '13800138000', '北京市朝阳区建国路1号', 'zid=1 示例订单', NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`);

-- 订单明细（依赖上面订单存在）
INSERT INTO `order_item` (
  `order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`
)
SELECT
  o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机',
  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
  NULL, 'SKU001', 1, 99.00, 1, 99.00, NOW(), NOW()
FROM `order` o
WHERE o.`order_no` = 'ORD-Z1-202602050001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1)
LIMIT 1;

-- ------------------------------ 5. 更多订单（日期集中 2026-02-01～02-10，便于生成补货建议） ------------------------------
USE `erp_list_order`;

INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('ORD-Z1-202602010002', 1, '1', 1, 'CN', 299.00, 0.00, 0.00, 0.00, 299.00, 1, 1, '2026-02-01 14:20:00', '李四', '13900139000', '上海市浦东新区张江路2号', NULL, '2026-02-01 14:15:00', '2026-02-01 14:20:00', 0),
('ORD-Z1-202602020003', 1, '1', 1, 'CN', 158.00, 0.00, 0.00, 0.00, 158.00, 1, 1, '2026-02-02 10:30:00', '王五', '13700137000', '广州市天河区体育西路3号', NULL, '2026-02-02 10:25:00', '2026-02-02 10:30:00', 0),
('ORD-Z1-202602030004', 1, '1', 1, 'CN', 696.00, 0.00, 0.00, 0.00, 696.00, 1, 1, '2026-02-03 16:00:00', '赵六', '13600136000', '深圳市南山区科技园4号', NULL, '2026-02-03 15:55:00', '2026-02-03 16:00:00', 0),
('ORD-Z1-202602040005', 1, '1', 1, 'CN', 198.00, 0.00, 0.00, 0.00, 198.00, 1, 1, '2026-02-04 09:45:00', '钱七', '13500135000', '杭州市西湖区文三路5号', NULL, '2026-02-04 09:40:00', '2026-02-04 09:45:00', 0),
('ORD-Z1-202602050006', 1, '1', 1, 'CN', 357.00, 0.00, 0.00, 0.00, 357.00, 1, 1, '2026-02-05 11:20:00', '孙八', '13400134000', '成都市武侯区天府大道6号', NULL, '2026-02-05 11:15:00', '2026-02-05 11:20:00', 0),
('ORD-Z1-202602060007', 1, '1', 1, 'CN', 99.00, 0.00, 0.00, 0.00, 99.00, 1, 1, '2026-02-06 08:30:00', '周九', '13300133000', '南京市鼓楼区中山路7号', NULL, '2026-02-06 08:25:00', '2026-02-06 08:30:00', 0),
('ORD-Z1-202602070008', 1, '1', 1, 'CN', 257.00, 0.00, 0.00, 0.00, 257.00, 1, 1, '2026-02-07 13:10:00', '吴十', '13200132000', '武汉市洪山区光谷大道8号', NULL, '2026-02-07 13:05:00', '2026-02-07 13:10:00', 0),
('ORD-Z1-202602080009', 1, '1', 1, 'CN', 412.00, 0.00, 0.00, 0.00, 412.00, 1, 1, '2026-02-08 17:50:00', '郑一', '13100131000', '西安市雁塔区高新路9号', NULL, '2026-02-08 17:45:00', '2026-02-08 17:50:00', 0),
('ORD-Z1-202602090010', 1, '1', 1, 'CN', 178.00, 0.00, 0.00, 0.00, 178.00, 1, 1, '2026-02-09 12:00:00', '王二', '13000130000', '重庆市渝北区龙溪路10号', NULL, '2026-02-09 11:55:00', '2026-02-09 12:00:00', 0),
('ORD-Z1-202602100011', 1, '1', 1, 'CN', 534.00, 0.00, 0.00, 0.00, 534.00, 1, 1, '2026-02-10 15:40:00', '张三', '13800138000', '北京市朝阳区建国路1号', NULL, '2026-02-10 15:35:00', '2026-02-10 15:40:00', 0)
ON DUPLICATE KEY UPDATE `pay_time` = VALUES(`pay_time`), `create_time` = VALUES(`create_time`);

-- 订单明细：每单 1～2 个商品，便于各 SKU 有销量用于补货建议
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
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://images.unsplash.com/photo-1602143407151-7111542de693?w=400', 'SKU005', 5, 99.00, 2, 198.00, o.`create_time`, o.`update_time`
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
SELECT o.`id`, o.`order_no`, '1', 1, 5, '保温杯', 'https://images.unsplash.com/photo-1602143407151-7111542de693?w=400', 'SKU005', 5, 89.00, 2, 178.00, o.`create_time`, o.`update_time`
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
