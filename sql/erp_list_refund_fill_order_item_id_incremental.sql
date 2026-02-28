-- ============================================================
-- 增量 SQL：将 1-8 号退款记录的订单号改为实际已存在的订单号，并补全 order_item_id（模拟真实退款数据、展示商品图）
-- 用途：之前手动创建的 1-8 号退款没有对应订单/图片；本脚本将其关联到 init 中真实存在的订单
-- 依赖：erp_list_refund、erp_list_order 已初始化；order 与 order_item 有对应数据
-- 幂等：可重复执行
-- ============================================================

USE `erp_list_refund`;

-- 1）按 id 将每条退款绑定到实际存在的订单（order_id + order_no）
UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-202602050001' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 1 AND ra.`deleted` = 0;

UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-202602010002' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 2 AND ra.`deleted` = 0;

UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-202602020003' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 3 AND ra.`deleted` = 0;

UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-202602030004' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 4 AND ra.`deleted` = 0;

UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-202602040005' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 5 AND ra.`deleted` = 0;

-- 6～8 号对应美国分店(sid=2)，关联实际存在的美国订单
UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-US-202602010001' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 6 AND ra.`deleted` = 0;

UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-US-202602030001' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 7 AND ra.`deleted` = 0;

UPDATE `refund_application` ra
INNER JOIN `erp_list_order`.`order` o ON o.`order_no` = 'ORD-Z1-US-202602050001' AND o.`deleted` = 0
SET ra.`order_id` = o.`id`, ra.`order_no` = o.`order_no`
WHERE ra.`id` = 8 AND ra.`deleted` = 0;

-- 2）为上述退款补全 order_item_id（取对应订单下第一条订单明细，用于展示商品图）
UPDATE `refund_application` ra
INNER JOIN (
  SELECT oi.`order_id`, MIN(oi.`id`) AS first_item_id
  FROM `erp_list_order`.`order_item` oi
  GROUP BY oi.`order_id`
) t ON t.`order_id` = ra.`order_id`
SET ra.`order_item_id` = t.`first_item_id`
WHERE ra.`id` BETWEEN 1 AND 8 AND ra.`deleted` = 0;
