-- ============================================================
-- 增量脚本：用户权限（user_permission 表 + permission 初始数据）
-- 说明：建表汇总已执行过，本脚本单独执行，可重复执行（幂等）
-- ============================================================

USE `erp_list_user`;

-- 1. 新增用户-权限关联表（一账号对应多权限，无角色）
CREATE TABLE IF NOT EXISTS `user_permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `permission_id` BIGINT NOT NULL COMMENT '权限ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_permission` (`user_id`, `permission_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户权限关联表';

-- 2. 权限表初始数据（按 permission_code 幂等，已存在则不插入；permission 表无 status 列）
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `description`, `sort_order`, `deleted`)
SELECT '店铺-新增', 'seller:create', 'api', '创建店铺', 10, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `permission` WHERE `permission_code` = 'seller:create' AND (deleted = 0 OR deleted IS NULL));
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `description`, `sort_order`, `deleted`)
SELECT '店铺-删除', 'seller:delete', 'api', '删除店铺', 11, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `permission` WHERE `permission_code` = 'seller:delete' AND (deleted = 0 OR deleted IS NULL));
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `description`, `sort_order`, `deleted`)
SELECT '商品-新增/上传', 'product:create', 'api', '创建/上传商品', 20, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `permission` WHERE `permission_code` = 'product:create' AND (deleted = 0 OR deleted IS NULL));
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `description`, `sort_order`, `deleted`)
SELECT '用户-新增', 'user:create', 'api', '创建用户', 30, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `permission` WHERE `permission_code` = 'user:create' AND (deleted = 0 OR deleted IS NULL));
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `description`, `sort_order`, `deleted`)
SELECT '用户-编辑', 'user:update', 'api', '编辑用户', 31, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `permission` WHERE `permission_code` = 'user:update' AND (deleted = 0 OR deleted IS NULL));
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `description`, `sort_order`, `deleted`)
SELECT '用户-删除', 'user:delete', 'api', '删除用户', 32, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `permission` WHERE `permission_code` = 'user:delete' AND (deleted = 0 OR deleted IS NULL));
