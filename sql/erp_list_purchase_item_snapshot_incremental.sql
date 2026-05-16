-- 采购明细仅 INSERT 权限场景：用快照指针标记当前有效明细批次
USE erp_list_purchase;

ALTER TABLE `purchase_order`
    ADD COLUMN `item_snapshot_min_id` BIGINT DEFAULT NULL COMMENT '当前有效采购明细最小ID（含）' AFTER `remark`;

-- 历史数据：NULL 表示从首条明细起均有效
UPDATE `purchase_order` SET `item_snapshot_min_id` = NULL WHERE `item_snapshot_min_id` IS NULL;
