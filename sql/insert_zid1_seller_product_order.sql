-- ============================================================
-- zid=1 公司数据：店铺 -> 商品 -> 订单（含订单明细）
-- 执行顺序：先 erp_list_seller，再 erp_list_product，再 erp_list_order
-- 依赖：erp_list_user.user 中已有 id=1、zid=1 的用户（如 admin）
-- ============================================================

-- ------------------------------ 1. 店铺（erp_list_seller） ------------------------------
USE `erp_list_seller`;

-- 插入一条店铺，zid=1，归属用户 user_id=1；id 固定为 1 便于后续订单/商品引用
INSERT INTO `seller` (
  `id`,
  `sid`,
  `user_id`,
  `zid`,
  `seller_name`,
  `platform`,
  `platform_account`,
  `status`,
  `remark`,
  `create_time`,
  `update_time`,
  `deleted`
) VALUES (
  1,
  'S1',
  1,
  '1',
  '默认店铺',
  'amazon',
  'seller-z1@example.com',
  1,
  'zid=1 公司店铺',
  NOW(),
  NOW(),
  0
) ON DUPLICATE KEY UPDATE `seller_name` = VALUES(`seller_name`);


-- ------------------------------ 2. 商品（erp_list_product） ------------------------------
USE `erp_list_product`;

-- 插入一条公司商品，zid=1，归属店铺 sid=1（即 seller.id）
INSERT INTO `company_product` (
  `id`,
  `zid`,
  `sid`,
  `product_name`,
  `product_code`,
  `sku_code`,
  `platform_sku`,
  `image_url`,
  `remark`,
  `create_time`,
  `update_time`,
  `deleted`
) VALUES (
  1,
  '1',
  1,
  '男士腕表',
  'P001',
  'SKU001',
  'AMZ-SKU-001',
  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
  'zid=1 商品',
  NOW(),
  NOW(),
  0
) ON DUPLICATE KEY UPDATE `product_name` = VALUES(`product_name`);


-- ------------------------------ 3. 订单 + 订单明细（erp_list_order） ------------------------------
USE `erp_list_order`;

-- 订单主表：zid=1，user_id=1，sid=1（店铺 id）
INSERT INTO `order` (
  `order_no`,
  `user_id`,
  `zid`,
  `sid`,
  `country_code`,
  `total_amount`,
  `discount_amount`,
  `promotion_discount_amount`,
  `tax_amount`,
  `pay_amount`,
  `order_status`,
  `pay_status`,
  `receiver_name`,
  `receiver_phone`,
  `receiver_address`,
  `remark`,
  `create_time`,
  `update_time`,
  `deleted`
) VALUES (
  'ORD-Z1-202602050001',
  1,
  '1',
  1,
  'CN',
  99.00,
  0.00,
  0.00,
  0.00,
  99.00,
  1,
  1,
  '张三',
  '13800138000',
  '北京市朝阳区建国路1号',
  'zid=1 订单',
  NOW(),
  NOW(),
  0
) ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`);

-- 订单明细：关联该订单与商品 company_product.id=1（仅当该订单尚无此商品明细时插入）
INSERT INTO `order_item` (
  `order_id`,
  `order_no`,
  `zid`,
  `sid`,
  `product_id`,
  `product_name`,
  `product_image`,
  `sku_id`,
  `sku_code`,
  `company_product_id`,
  `price`,
  `quantity`,
  `total_price`,
  `create_time`,
  `update_time`
)
SELECT
  o.`id`,
  o.`order_no`,
  '1',
  1,
  1,
  '男士腕表',
  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
  NULL,
  'SKU001',
  1,
  99.00,
  1,
  99.00,
  NOW(),
  NOW()
FROM `order` o
WHERE o.`order_no` = 'ORD-Z1-202602050001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1)
LIMIT 1;
