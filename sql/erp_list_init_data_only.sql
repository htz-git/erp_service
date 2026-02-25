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
) VALUES (
  1, 'S1', 1, '1', '默认店铺', 'amazon', 'seller-z1@example.com', 1, 'zid=1 公司店铺', NOW(), NOW(), 0
) ON DUPLICATE KEY UPDATE `seller_name` = VALUES(`seller_name`);


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
(12, '1', 1, '移动硬盘 1TB', 'P012', 'SKU012', 'AMZ-SKU-012', 'https://ask-fd.zol-img.com.cn/g5/M00/0A/02/ChMkJ1nxC6GIbrTMAABUFO11gckAAhjYAFQsksAAFQs398.jpg', 'zid=1 商品', NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `product_name` = VALUES(`product_name`), `image_url` = VALUES(`image_url`);


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
('ORD-Z1-202602240008', 1, '1', 1, 'CN', 258.00, 0.00, 0.00, 0.00, 258.00, 1, 1, NULL, '廖辰', '13900139054', '秦皇岛市海港区河北大街54号', '补货样本', '2026-02-24 18:00:00', NOW(), 0)
ON DUPLICATE KEY UPDATE `order_no` = VALUES(`order_no`), `create_time` = VALUES(`create_time`), `pay_time` = VALUES(`pay_time`);

-- 4.2 订单明细（依赖上面订单存在，使用子查询幂等插入）
INSERT INTO `order_item` (`order_id`, `order_no`, `zid`, `sid`, `product_id`, `product_name`, `product_image`, `sku_id`, `sku_code`, `company_product_id`, `price`, `quantity`, `total_price`, `create_time`, `update_time`)
SELECT o.`id`, o.`order_no`, '1', 1, 1, '无线蓝牙耳机', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NULL, 'SKU001', 1, 99.00, 1, 99.00, NOW(), NOW()
FROM `order` o WHERE o.`order_no` = 'ORD-Z1-202602050001' AND o.`deleted` = 0
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.`order_id` = o.`id` AND oi.`product_id` = 1) LIMIT 1;

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


-- ============================================================
-- 执行说明：
-- 1. 先执行「建表汇总.sql」完成建库建表。
-- 2. 再执行本文件「erp_list_init_data_only.sql」完成所有初始化数据。
-- 3. 账号：admin / 123456（超管）；root / root（平台管理员，请登录后修改密码）。
-- ============================================================
