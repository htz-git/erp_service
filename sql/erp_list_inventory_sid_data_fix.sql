-- ============================================================
-- 库存表已有数据补全 sid（仅数据修复，不改表结构）
-- 用途：表已有 sid 列，但历史数据 sid 为 NULL，本脚本将其统一设为默认店铺 1
-- 若表还没有 sid 列，请先执行 erp_list_inventory_add_sid_migration.sql
-- ============================================================

USE `erp_list_replenishment`;

UPDATE `inventory` SET `sid` = 1 WHERE `sid` IS NULL;
