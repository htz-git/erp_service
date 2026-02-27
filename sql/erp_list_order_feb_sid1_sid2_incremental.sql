-- ============================================================
-- 增量 SQL：2 月份默认店铺(sid=1)与美国分店(sid=2)新增订单
-- 用途：在已有 init 或前期增量基础上，增加 2 月 sid=1 / sid=2 订单数
-- 内容：sid=1 新增 45 笔、sid=2 新增 45 笔，共 90 笔订单及对应 order_item（含第二、三、四批）
-- 可重复执行：ON DUPLICATE KEY UPDATE / NOT EXISTS 幂等
-- 依赖：erp_list_order 库、order / order_item 表
-- ============================================================

USE `erp_list_order`;

-- 1. 订单主表：sid=1 默认店铺 15 笔 + sid=2 美国分店 15 笔
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
-- sid=1 默认店铺 2 月新增 15 笔
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
-- sid=2 美国分店 2 月新增 15 笔
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
('ORD-Z1-US-202602270002', 1, '1', 2, 'US', 89.97, 0.00, 0.00, 0.00, 89.97, 1, 1, NULL, 'Sandra Cox', '+1-801-555-1030', '50 S Main St, Salt Lake City, UT 84101', NULL, '2026-02-27 13:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`), `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`);

-- 2. 订单明细：sid=1 默认店铺 15 笔对应 order_item（NOT EXISTS 幂等）
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

-- 3. 订单明细：sid=2 美国分店 15 笔对应 order_item（NOT EXISTS 幂等）
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

-- 4. 订单明细：sid=1 第二批 12 笔（NOT EXISTS 幂等）
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

-- 5. 订单明细：sid=2 第二批 12 笔（NOT EXISTS 幂等）
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

-- 6. 订单明细：sid=1 第三批 10 笔（2月25-26日，NOT EXISTS 幂等）
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

-- 7. 订单明细：sid=2 第三批 10 笔（2月25-26日，NOT EXISTS 幂等）
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

-- 8. 订单明细：sid=1 第四批 8 笔（2月26-27日，NOT EXISTS 幂等）
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

-- 9. 订单明细：sid=2 第四批 8 笔（2月26-27日，NOT EXISTS 幂等）
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
