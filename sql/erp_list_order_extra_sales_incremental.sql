-- ============================================================
-- 增量脚本：补充更多已存在商品订单数据（中国分店 sid=1 销量适当高于美国分店 sid=2）
-- 用途：在已有订单库上追加历史销售数据，便于补货建议与预测；可重复执行（幂等）
-- 执行前请先 USE erp_list_order;
-- ============================================================

USE `erp_list_order`;

-- 4.1 补充订单主表（中国分店 25+20 笔 + 美国分店 15+10 笔，订单号唯一避免重复插入）
INSERT INTO `order` (
  `order_no`, `user_id`, `zid`, `sid`, `country_code`, `total_amount`, `discount_amount`, `promotion_discount_amount`, `tax_amount`, `pay_amount`,
  `order_status`, `pay_status`, `pay_time`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `create_time`, `update_time`, `deleted`
) VALUES
-- 中国分店 sid=1（销量分布更高：多件、多品，日期 1 月下旬～2 月下旬）
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
-- 美国分店 sid=2（单量略少、件数 1～2，分布真实）
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
-- 第二批：中国 20 笔 + 美国 10 笔（日期 2 月底～3 月中旬）
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

-- 4.2 补充订单明细（中国分店：多件/多品，美国分店：1～2 件）
-- 中国 sid=1：product_id 1-12, sku SKU001-SKU012, company_product_id=product_id
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
-- 中国分店剩余订单（每单 1～2 个商品，数量 1～3）
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
-- ORD-Z1-EX-CN-023 总金额 528：运动手环x2(316)+充电宝x1(89)+护眼台灯x1(88)+数据线x1(35)
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

-- 美国分店 sid=2：product_id 13-17, company_product_id 13-17
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

-- 4.3 第二批补充订单明细（CN-026~045, US-016~025）
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
