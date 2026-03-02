-- ============================================================
-- 库存预警与补货计划表示例数据（可选执行）
-- 依赖：建表汇总.sql 已执行，erp_list_replenishment.inventory 表已有数据
-- 用途：演示 inventory_alert、replenishment_plan 数据；正式环境可由任务/业务生成
-- ============================================================

USE `erp_list_replenishment`;

-- 从当前库存中，将 current_stock < min_stock 的生成几条库存预警（低库存=1，缺货=2）
INSERT INTO `inventory_alert` (
  `product_id`, `product_name`, `sku_id`, `sku_code`, `current_stock`, `min_stock`,
  `alert_level`, `alert_status`, `create_time`, `update_time`
)
SELECT
  i.`product_id`, i.`product_name`, i.`sku_id`, i.`sku_code`,
  i.`current_stock`, i.`min_stock`,
  IF(i.`current_stock` <= 0, 2, 1),
  0,
  NOW(), NOW()
FROM `inventory` i
WHERE (i.`current_stock` < i.`min_stock` OR (i.`current_stock` IS NULL AND i.`min_stock` > 0))
  AND NOT EXISTS (
    SELECT 1 FROM `inventory_alert` a
    WHERE a.`product_id` = i.`product_id` AND a.`sku_id` <=> i.`sku_id`
      AND a.`alert_status` = 0
    LIMIT 1
  )
LIMIT 20;

-- 补货计划示例：为部分商品插入启用状态的补货计划
INSERT INTO `replenishment_plan` (
  `plan_name`, `product_id`, `product_name`, `sku_id`, `min_stock`, `max_stock`,
  `reorder_point`, `reorder_quantity`, `plan_status`, `create_time`, `update_time`, `deleted`
)
SELECT
  CONCAT('补货计划-', i.`product_name`),
  i.`product_id`, i.`product_name`, i.`sku_id`,
  IFNULL(i.`min_stock`, 5), IFNULL(i.`min_stock`, 5) + 20,
  IFNULL(i.`min_stock`, 5), 10,
  1, NOW(), NOW(), 0
FROM `inventory` i
WHERE NOT EXISTS (
  SELECT 1 FROM `replenishment_plan` p
  WHERE p.`product_id` = i.`product_id` AND p.`sku_id` <=> i.`sku_id` AND p.`deleted` = 0
)
LIMIT 10;
