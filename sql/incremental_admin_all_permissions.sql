-- ============================================================
-- 增量脚本：为 admin 用户赋予全部权限（管理员）
-- 说明：user 表中已存在 admin 用户，本脚本为其在 user_permission 中插入全部权限，可重复执行（幂等）
-- ============================================================

USE `erp_list_user`;

-- 为用户名 = 'admin' 的用户赋予当前 permission 表中的全部权限（已存在则不重复插入）
INSERT INTO `user_permission` (`user_id`, `permission_id`)
SELECT u.id, p.id
FROM `user` u
CROSS JOIN `permission` p
WHERE u.username = 'admin'
  AND (u.deleted = 0 OR u.deleted IS NULL)
  AND (p.deleted = 0 OR p.deleted IS NULL)
  AND NOT EXISTS (
    SELECT 1 FROM `user_permission` up
    WHERE up.user_id = u.id AND up.permission_id = p.id
  );
