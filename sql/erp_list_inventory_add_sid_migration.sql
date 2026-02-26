-- ============================================================
-- ERP List 库存表按店铺维度迁移脚本（为已存在的 inventory 表增加 sid）
-- 用途：已建过旧版 inventory 表（无 sid）且已插入数据的环境，执行本文件完成结构迁移与数据归属
-- 执行后：库存唯一键为 (zid, sid, sku_id)，已有数据统一归属默认店铺 sid=1
-- 执行顺序：本脚本执行完成后，若需补/修库存数据可再执行 erp_list_inventory_incremental.sql
-- ============================================================

USE `erp_list_replenishment`;

-- 1. 增加 sid 列（先允许 NULL，便于对已有数据赋值）
ALTER TABLE `inventory` ADD COLUMN `sid` BIGINT NULL COMMENT '店铺ID（Seller ID，引用 seller.id）' AFTER `zid`;

-- 2. 已有数据归属到默认店铺 1
UPDATE `inventory` SET `sid` = 1 WHERE `sid` IS NULL;

-- 3. 改为 NOT NULL
ALTER TABLE `inventory` MODIFY COLUMN `sid` BIGINT NOT NULL COMMENT '店铺ID（Seller ID，引用 seller.id）';

-- 4. 删除旧唯一键，添加新唯一键及索引
ALTER TABLE `inventory` DROP INDEX `uk_zid_sku_id`;
ALTER TABLE `inventory` ADD UNIQUE KEY `uk_zid_sid_sku_id` (`zid`, `sid`, `sku_id`);
ALTER TABLE `inventory` ADD KEY `idx_sid` (`sid`);
ALTER TABLE `inventory` ADD KEY `idx_zid_sid` (`zid`, `sid`);

-- 5. 表注释更新（可选）
ALTER TABLE `inventory` COMMENT = '库存表（按公司+店铺+SKU）';
