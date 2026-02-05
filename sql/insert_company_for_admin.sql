-- ============================================================
-- 为已存在的超管账号（user.id=1, zid=1, username=admin）补充 company 表记录
-- 在 erp_list_user 库执行
-- ============================================================

USE `erp_list_user`;

-- 为 zid=1 对应的公司插入一条记录（与 user 表中 id=1、zid=1 的 admin 超管对应）
-- 若 id='1' 已存在则跳过（避免重复执行报错）
INSERT INTO `company` (
  `id`,
  `company_name`,
  `contact_name`,
  `contact_phone`,
  `contact_email`,
  `address`,
  `status`,
  `remark`,
  `create_time`,
  `update_time`,
  `deleted`
)
SELECT
  '1',
  '默认公司',
  '超级管理员',
  '18250099985',
  '2281852840@qq.com',
  NULL,
  1,
  '为已有超管账号 admin(zid=1) 补录的公司记录',
  NOW(),
  NOW(),
  0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM company WHERE id = '1' AND deleted = 0);
