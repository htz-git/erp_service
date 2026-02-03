-- ============================================================
-- 店铺服务增量：seller 表增加 zid（公司ID）
-- 数据库：erp_list_seller
-- 执行方式：在虚拟机中通过 Docker 执行，见 sql/update/README.md
-- ============================================================

USE `erp_list_seller`;

-- 增加公司ID字段（若已存在可跳过或改为 ADD COLUMN IF NOT EXISTS，MySQL 8.0.12+ 支持）
ALTER TABLE `seller` ADD COLUMN `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（与 user.zid 一致）' AFTER `user_id`;
ALTER TABLE `seller` ADD INDEX `idx_zid` (`zid`);
