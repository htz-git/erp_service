-- ============================================================
-- 本次修改增量 SQL（公司表、审计表、管理员权限 + 创建平台管理员账号）
-- 在 erp_list_user 库执行
-- ============================================================

USE `erp_list_user`;

-- ------------------------------ 1. 公司表 ------------------------------
CREATE TABLE IF NOT EXISTS `company` (
  `id` VARCHAR(50) NOT NULL COMMENT '公司ID（即 zid）',
  `company_name` VARCHAR(100) NOT NULL COMMENT '公司名称',
  `contact_name` VARCHAR(50) DEFAULT NULL COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系人电话',
  `contact_email` VARCHAR(100) DEFAULT NULL COMMENT '联系人邮箱',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '公司地址（选填）',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公司表';

-- ------------------------------ 2. 操作日志表（审计） ------------------------------
CREATE TABLE IF NOT EXISTS `audit_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人用户ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人用户名',
  `action_type` VARCHAR(50) NOT NULL COMMENT '操作类型：company_onboard, company_disable, company_enable, user_disable, user_enable, user_reset_password 等',
  `target_type` VARCHAR(30) DEFAULT NULL COMMENT '对象类型：company, user',
  `target_id` VARCHAR(50) DEFAULT NULL COMMENT '对象ID（如 zid、user_id）',
  `detail` VARCHAR(500) DEFAULT NULL COMMENT '详情描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_operator_id` (`operator_id`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_target_id` (`target_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表';

-- ------------------------------ 3. 确保管理员权限存在 ------------------------------
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `sort_order`, `description`) VALUES
('管理员-后台', 'admin:access', 'api', 1, '平台管理员，可访问管理后台')
ON DUPLICATE KEY UPDATE `permission_name` = VALUES(`permission_name`);


-- ============================================================
-- 创建平台管理员账号（虚拟 zid = __platform__，具备 admin:access）
-- 首次部署执行下面一段；若已存在管理员可跳过或修改用户名
-- ============================================================

-- 4. 插入平台管理员用户（zid 固定为 __platform__，与普通公司 zid 区分）
--    默认用户名 root，默认密码 root（仅用于首次登录，请登录后尽快修改）
INSERT INTO `user` (`zid`, `username`, `password`, `real_name`, `phone`, `email`, `status`, `create_time`, `update_time`, `deleted`)
VALUES ('__platform__', 'root', 'root', '平台管理员', NULL, NULL, 1, NOW(), NOW(), 0)
ON DUPLICATE KEY UPDATE `zid` = VALUES(`zid`);

-- 5. 为该管理员绑定 admin:access 权限（若已绑定则忽略）
INSERT IGNORE INTO `user_permission` (`user_id`, `permission_id`)
SELECT u.id, p.id
FROM `user` u
INNER JOIN `permission` p ON p.permission_code = 'admin:access' AND p.deleted = 0
WHERE u.username = 'root' AND u.deleted = 0
LIMIT 1;
