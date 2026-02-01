-- ============================================================
-- ERP微服务架构 - 数据库创建脚本
-- ============================================================

-- 创建用户服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_user` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建店铺服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_seller` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建订单服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_order` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建支付服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_payment` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建促销服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_promotion` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建采购服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_purchase` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建退款服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_refund` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 创建补货服务数据库
CREATE DATABASE IF NOT EXISTS `erp_list_replenishment` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

