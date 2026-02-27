-- ============================================================
-- 增量 SQL：美国分店（sid=2, zid=1）
-- 用途：在已有 init 数据（仅默认店铺 sid=1）基础上，新增美国分店及该店铺商品、库存、美国订单
-- 内容：1 个店铺、5 个公司商品、5 条库存、58 笔美国订单（8+20+30）及对应 order_item
-- 可重复执行：ON DUPLICATE KEY UPDATE / NOT EXISTS 幂等
-- 依赖：erp_list_seller、erp_list_product、erp_list_replenishment、erp_list_order 库及对应表
-- ============================================================

-- 1. 店铺：美国分店 (id=2, sid=S2, zid=1)
USE `erp_list_seller`;

INSERT INTO `seller` (
  `id`, `sid`, `user_id`, `zid`, `seller_name`, `platform`, `platform_account`, `status`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
  (2, '2', 1, '1', '美国分店', 'amazon', 'seller-us@example.com', 1, 'zid=1 美国分店，美国订单', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `seller_name` = VALUES(`seller_name`), `remark` = VALUES(`remark`);


-- 2. 商品：美国分店 5 个商品 (company_product id 13~17，中文名称)
USE `erp_list_product`;

INSERT INTO `company_product` (
  `id`, `zid`, `sid`, `product_name`, `product_code`, `sku_code`, `platform_sku`, `image_url`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
(13, '1', 2, '无线蓝牙耳机', 'P-US-001', 'SKU-US-001', 'AMZ-US-001', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', '美国分店商品', NOW(), NOW(), 0),
(14, '1', 2, '便携充电宝', 'P-US-002', 'SKU-US-002', 'AMZ-US-002', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', '美国分店商品', NOW(), NOW(), 0),
(15, '1', 2, '运动手环', 'P-US-003', 'SKU-US-003', 'AMZ-US-003', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', '美国分店商品', NOW(), NOW(), 0),
(16, '1', 2, 'USB-C 数据线', 'P-US-004', 'SKU-US-004', 'AMZ-US-004', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', '美国分店商品', NOW(), NOW(), 0),
(17, '1', 2, '桌面收纳盒', 'P-US-005', 'SKU-US-005', 'AMZ-US-005', 'https://img.alicdn.com/bao/uploaded/i4/847499689/O1CN01HfBgjP2LRc9GpPsY0_!!847499689.jpg', '美国分店商品', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `product_name` = VALUES(`product_name`), `image_url` = VALUES(`image_url`);


-- 3. 库存：美国分店 5 个 SKU
USE `erp_list_replenishment`;

INSERT INTO `inventory` (
  `zid`, `sid`, `product_id`, `product_name`, `sku_id`, `sku_code`, `current_stock`, `min_stock`, `create_time`, `update_time`
) VALUES
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


-- 4. 订单：美国分店 8 笔美国订单 (sid=2, country_code=US)
USE `erp_list_order`;

INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
('ORD-Z1-US-202602010001', 1, '1', 2, 'US', 49.99, 0.00, 0.00, 0.00, 49.99, 1, 1, '2026-02-01 15:00:00', 'John Smith', '+1-555-0101', '123 Main St, Los Angeles, CA 90001', 'US store', '2026-02-01 14:55:00', NOW(), 0),
('ORD-Z1-US-202602030001', 1, '1', 2, 'US', 79.98, 0.00, 0.00, 0.00, 79.98, 1, 1, '2026-02-03 11:20:00', 'Emily Johnson', '+1-555-0102', '456 Oak Ave, New York, NY 10001', 'US store', '2026-02-03 11:15:00', NOW(), 0),
('ORD-Z1-US-202602050001', 1, '1', 2, 'US', 129.00, 0.00, 0.00, 0.00, 129.00, 1, 1, '2026-02-05 09:30:00', 'Michael Williams', '+1-555-0103', '789 Pine Rd, Chicago, IL 60601', 'US store', '2026-02-05 09:25:00', NOW(), 0),
('ORD-Z1-US-202602070001', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-07 16:45:00', 'Sarah Brown', '+1-555-0104', '321 Elm St, Houston, TX 77001', 'US store', '2026-02-07 16:40:00', NOW(), 0),
('ORD-Z1-US-202602090001', 1, '1', 2, 'US', 199.00, 10.00, 0.00, 0.00, 189.00, 1, 1, NULL, 'David Davis', '+1-555-0105', '555 Cedar Ln, Phoenix, AZ 85001', 'US store', '2026-02-09 13:00:00', NOW(), 0),
('ORD-Z1-US-202602180001', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, NULL, 'Jessica Miller', '+1-555-0106', '100 Broadway, Seattle, WA 98101', 'US store', '2026-02-18 10:20:00', NOW(), 0),
('ORD-Z1-US-202602200001', 1, '1', 2, 'US', 39.99, 0.00, 0.00, 0.00, 39.99, 1, 1, NULL, 'Robert Wilson', '+1-555-0107', '200 5th Ave, Miami, FL 33101', 'US store', '2026-02-20 14:10:00', NOW(), 0),
('ORD-Z1-US-202602220001', 1, '1', 2, 'US', 159.00, 0.00, 0.00, 0.00, 159.00, 1, 1, NULL, 'Jennifer Taylor', '+1-555-0108', '300 Market St, San Francisco, CA 94102', 'US store', '2026-02-22 11:30:00', NOW(), 0),
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
-- 美国分店第三批订单 (30 笔)
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
('ORD-Z1-US-202602110005', 1, '1', 2, 'US', 59.99, 0.00, 0.00, 0.00, 59.99, 1, 1, '2026-02-11 13:00:00', 'Brenda Bailey', '+1-555-0330', '5200 E Williams Field Rd, Gilbert, AZ 85295', 'US store', '2026-02-11 12:55:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`), `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`);


-- 5. 订单明细：美国分店订单对应的 order_item（NOT EXISTS 幂等）
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

-- 5.1 美国分店更多订单明细 (20 笔)
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

-- 5.2 美国分店第三批订单明细 (30 笔)
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
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 1, 129.00, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602060004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 15) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 16, 'USB-C 数据线', 'https://cbu01.alicdn.com/img/ibank/O1CN01HrqKMs1lEUkL1fxWl_!!2643414787-0-cib.jpg', 16, 'SKU-US-004', 16, 59.99, 1, 59.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602060004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 16) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 1, 39.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602060004' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 14, '便携充电宝', 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 14, 'SKU-US-002', 14, 39.99, 2, 89.97, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 14) LIMIT 1;
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 2, 13, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 13, 'SKU-US-001', 13, 49.99, 1, 49.99, o.`create_time`, NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070003' AND o.`deleted` = 0 AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`company_product_id` = 13) LIMIT 1;
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
SELECT o.`id`, o.`order_no`, '1', 2, 15, '运动手环', 'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=400', 15, 'SKU-US-003', 15, 129.00, 2, 279.98, o.`create_time`, NOW()
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
