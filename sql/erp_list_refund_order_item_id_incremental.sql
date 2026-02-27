-- ============================================================
-- 增量脚本：refund_application 表增加 order_item_id 列及索引
-- 用途：已有 erp_list_refund.refund_application 表的环境升级
-- 依赖：库 erp_list_refund、表 refund_application 已存在
-- 幂等：可重复执行，列/索引已存在则跳过
-- 执行顺序：已有库先执行本脚本，再部署新版本后端/前端
-- ============================================================

USE `erp_list_refund`;

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_add_order_item_id`$$

CREATE PROCEDURE `proc_add_order_item_id`()
BEGIN
  -- 若列 order_item_id 不存在则添加
  IF (SELECT COUNT(*) FROM information_schema.COLUMNS
      WHERE table_schema = 'erp_list_refund'
        AND table_name = 'refund_application'
        AND column_name = 'order_item_id') = 0 THEN
    ALTER TABLE `refund_application`
    ADD COLUMN `order_item_id` BIGINT DEFAULT NULL COMMENT '订单明细ID，为空表示整单退款' AFTER `order_no`;
  END IF;

  -- 若索引 idx_order_id_order_item_id 不存在则添加
  IF (SELECT COUNT(*) FROM information_schema.STATISTICS
      WHERE table_schema = 'erp_list_refund'
        AND table_name = 'refund_application'
        AND index_name = 'idx_order_id_order_item_id') = 0 THEN
    ALTER TABLE `refund_application`
    ADD INDEX `idx_order_id_order_item_id` (`order_id`, `order_item_id`);
  END IF;
END$$

DELIMITER ;

CALL `proc_add_order_item_id`();
DROP PROCEDURE IF EXISTS `proc_add_order_item_id`;
