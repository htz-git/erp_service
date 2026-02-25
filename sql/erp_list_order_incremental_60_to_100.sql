-- ============================================================
-- 增量 SQL：2026-02-18～02-24 从 60 条增至 100 条订单（新增 40 条）
-- 用途：在已执行「补足至 60 条」增量（或 init 已含 60 条）基础上执行，将当期订单数增至 100 条
-- 内容：40 条订单（含部分一单 10 件同商品）+ 对应 order_item，买家名含三字名
-- 可重复执行：订单 ON DUPLICATE KEY UPDATE，明细 NOT EXISTS，幂等
-- 依赖：erp_list_order 库、order / order_item 表
-- ============================================================

USE `erp_list_order`;

-- 1. 订单主表：新增 40 条（ORD-Z1-202602180009～240017）
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
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
('ORD-Z1-202602240017', 1, '1', 1, 'CN', 399.00, 0.00, 0.00, 0.00, 399.00, 1, 1, NULL, '李思远', '13900139094', '宁德市蕉城区闽东路94号', '补货样本', '2026-02-24 15:50:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`), `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`);

-- 2. 订单明细：上述 40 条订单对应 order_item（NOT EXISTS 幂等，含 8 笔一单 10 件）
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

-- ============================================================
-- 执行说明：在 2026-02-18～02-24 已有 60 条订单的前提下执行本文件，可新增 40 条订单及明细，使当期订单总数为 100 条。可重复执行（幂等）。
-- ============================================================
