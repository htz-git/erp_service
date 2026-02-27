-- ============================================================
-- 增量 SQL：退款记录（模拟真实场景，按店铺维度）
-- 用途：在已有 init 或建表基础上，增加退款申请及退款记录（关联真实订单）
-- 内容：8 笔退款申请（sid=1 默认店铺 5 笔、sid=2 美国分店 3 笔），状态/原因/金额多样；部分带 refund_record
-- 可重复执行：NOT EXISTS 幂等
-- 依赖：erp_list_refund、erp_list_order 库；refund_reason 已初始化；order 表有对应 order_no
-- ============================================================

USE `erp_list_refund`;

-- 1. 退款申请（从订单表取 order_id，支付信息模拟）
INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602150001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 99.00, 2, '商品与描述不符',
  4, '2026-02-15 10:00:00', '2026-02-15 14:00:00', 1, '超级管理员', NULL, '2026-02-15 16:00:00', 'TP-REF-202602150001', '客户反馈颜色与页面不符', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602050006' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602150001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602160001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 257.00, 3, '不想要了',
  1, '2026-02-16 09:30:00', '2026-02-16 11:00:00', 1, '超级管理员', '已同意退款', NULL, NULL, '客户取消订单', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602070008' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602160001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602170001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 200.00, 4, '收到商品损坏',
  0, '2026-02-17 14:20:00', NULL, NULL, NULL, NULL, NULL, NULL, '快递压坏外盒，申请部分退款', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602080009' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602170001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602180001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 178.00, 5, '发错商品',
  4, '2026-02-18 08:15:00', '2026-02-18 10:00:00', 1, '超级管理员', NULL, '2026-02-18 15:30:00', 'TP-REF-202602180001', '发成另一款型号，客户要求全额退', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602090010' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602180001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-202602210001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 1, 199.00, 6, '其他原因',
  3, '2026-02-21 16:00:00', '2026-02-21 17:00:00', 1, '超级管理员', NULL, NULL, NULL, '重复下单，申请退其中一单部分金额', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-202602100011' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-202602210001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-US-202602190001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 2, 49.99, 1, '商品质量问题',
  4, '2026-02-19 11:00:00', '2026-02-19 14:00:00', 1, '超级管理员', NULL, '2026-02-19 18:00:00', 'TP-REF-US-202602190001', 'Headphone left channel no sound', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-US-202602010001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602190001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-US-202602200001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 2, 59.99, 3, '不想要了',
  2, '2026-02-20 09:00:00', '2026-02-20 10:30:00', 1, '超级管理员', '已发货不可退', NULL, NULL, 'Customer changed mind after ship', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-US-202602070001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602200001' AND ra.`deleted` = 0) LIMIT 1;

INSERT INTO `refund_application` (
  `refund_no`, `order_id`, `order_no`, `user_id`, `payment_id`, `payment_no`, `zid`, `sid`, `refund_amount`, `refund_reason_id`, `refund_reason`,
  `refund_status`, `apply_time`, `approve_time`, `approver_id`, `approver_name`, `approve_remark`, `refund_time`, `third_party_refund_no`, `remark`, `create_time`, `update_time`, `deleted`
)
SELECT 'RF-Z1-US-202602220001', o.`id`, o.`order_no`, 1, 0, CONCAT('PAY-', o.`order_no`), '1', 2, 129.00, 4, '收到商品损坏',
  4, '2026-02-22 13:00:00', '2026-02-22 15:00:00', 1, '超级管理员', NULL, '2026-02-22 20:00:00', 'TP-REF-US-202602220001', 'Package arrived damaged', NOW(), NOW(), 0
FROM `erp_list_order`.`order` o WHERE o.`order_no` = 'ORD-Z1-US-202602050001' AND o.`deleted` = 0
AND NOT EXISTS (SELECT 1 FROM `refund_application` ra WHERE ra.`refund_no` = 'RF-Z1-US-202602220001' AND ra.`deleted` = 0) LIMIT 1;

-- 2. 退款记录（仅对 refund_status=4 退款成功的申请写入一条 record）
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
