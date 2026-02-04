-- ============================================================
-- ERP 建表汇总（当前实际各表建表语句）
-- 单文件整合，按段执行或整段执行均可
-- ============================================================


-- ===================== 第1段：创建所有数据库 =====================

CREATE DATABASE IF NOT EXISTS `erp_list_user`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `erp_list_seller`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `erp_list_order`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `erp_list_product`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `erp_list_purchase`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `erp_list_refund`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS `erp_list_replenishment`
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


-- ===================== 第2段：用户服务 erp_list_user =====================

USE `erp_list_user`;

CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（加密）',
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_zid` (`zid`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

CREATE TABLE IF NOT EXISTS `role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
  `role_code` VARCHAR(50) NOT NULL COMMENT '角色编码',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '角色描述',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色表';

CREATE TABLE IF NOT EXISTS `permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `permission_name` VARCHAR(50) NOT NULL COMMENT '权限名称',
  `permission_code` VARCHAR(100) NOT NULL COMMENT '权限编码',
  `resource_type` VARCHAR(20) DEFAULT NULL COMMENT '资源类型：menu-菜单，button-按钮，api-接口',
  `resource_path` VARCHAR(255) DEFAULT NULL COMMENT '资源路径',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父权限ID',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '权限描述',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_permission_code` (`permission_code`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='权限表';

CREATE TABLE IF NOT EXISTS `user_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户角色关联表';

CREATE TABLE IF NOT EXISTS `role_permission` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `permission_id` BIGINT NOT NULL COMMENT '权限ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
  KEY `idx_role_id` (`role_id`),
  KEY `idx_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';

-- 用户-权限关联表（一账号多权限，本方案使用）
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

-- 权限初始数据（店铺增删、商品增删改、用户管理）
INSERT INTO `permission` (`permission_name`, `permission_code`, `resource_type`, `sort_order`, `description`) VALUES
('店铺-新增', 'seller:create', 'api', 10, '创建店铺'),
('店铺-删除', 'seller:delete', 'api', 11, '删除店铺'),
('商品-新增', 'product:create', 'api', 20, '创建/上传商品'),
('商品-修改', 'product:update', 'api', 21, '修改商品'),
('商品-删除', 'product:delete', 'api', 22, '删除商品'),
('用户-新增', 'user:create', 'api', 30, '创建用户'),
('用户-修改', 'user:update', 'api', 31, '修改用户'),
('用户-删除', 'user:delete', 'api', 32, '删除用户')
ON DUPLICATE KEY UPDATE `permission_name` = VALUES(`permission_name`);


-- ===================== 第3段：店铺服务 erp_list_seller =====================

USE `erp_list_seller`;

CREATE TABLE IF NOT EXISTS `seller` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '店铺ID（即 sid，其他表引用 seller.id）',
  `sid` VARCHAR(50) NOT NULL COMMENT '店铺标识（Seller ID）',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（所属公司）',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `seller_name` VARCHAR(100) NOT NULL COMMENT '店铺名称',
  `platform` VARCHAR(50) DEFAULT NULL COMMENT '平台类型：amazon-亚马逊，ebay-eBay，aliexpress-速卖通等',
  `platform_account` VARCHAR(100) DEFAULT NULL COMMENT '平台账号',
  `access_token` VARCHAR(500) DEFAULT NULL COMMENT '访问令牌',
  `refresh_token` VARCHAR(500) DEFAULT NULL COMMENT '刷新令牌',
  `token_expire_time` DATETIME DEFAULT NULL COMMENT '令牌过期时间',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `authorize_time` DATETIME DEFAULT NULL COMMENT '授权时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sid` (`sid`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_platform` (`platform`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='店铺授权表';


-- ===================== 第4段：订单服务 erp_list_order =====================

USE `erp_list_order`;

CREATE TABLE IF NOT EXISTS `order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `country_code` VARCHAR(10) DEFAULT NULL COMMENT '配送国家/地区代码（如 ISO 3166-1 alpha-2）',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
  `discount_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '优惠金额',
  `promotion_discount_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '促销折扣金额',
  `tax_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT '税费',
  `pay_amount` DECIMAL(10,2) NOT NULL COMMENT '实付金额',
  `order_status` TINYINT NOT NULL DEFAULT 0 COMMENT '订单状态：0-待支付，1-已支付，2-已发货，3-已完成，4-已取消，5-已退款',
  `pay_status` TINYINT DEFAULT 0 COMMENT '支付状态：0-未支付，1-已支付，2-已退款',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `delivery_time` DATETIME DEFAULT NULL COMMENT '发货时间',
  `complete_time` DATETIME DEFAULT NULL COMMENT '完成时间',
  `receiver_name` VARCHAR(50) NOT NULL COMMENT '收货人姓名',
  `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
  `receiver_address` VARCHAR(255) NOT NULL COMMENT '收货地址',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '订单备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_country_code` (`country_code`),
  KEY `idx_order_status` (`order_status`),
  KEY `idx_pay_status` (`pay_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

CREATE TABLE IF NOT EXISTS `order_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `product_image` VARCHAR(255) DEFAULT NULL COMMENT '商品图片',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `company_product_id` BIGINT DEFAULT NULL COMMENT '关联公司商品ID（company_product.id），用于与平台商品配对',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity` INT NOT NULL COMMENT '数量',
  `total_price` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_company_product_id` (`company_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单明细表';

CREATE TABLE IF NOT EXISTS `order_status_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
  `old_status` TINYINT DEFAULT NULL COMMENT '原状态',
  `new_status` TINYINT NOT NULL COMMENT '新状态',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人姓名',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单状态变更记录表';


-- ===================== 第6段：商品服务 erp_list_product =====================

USE `erp_list_product`;

CREATE TABLE IF NOT EXISTS `company_product` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，可选）',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `product_code` VARCHAR(80) DEFAULT NULL COMMENT '商品编码',
  `sku_code` VARCHAR(80) DEFAULT NULL COMMENT 'SKU编码',
  `platform_sku` VARCHAR(80) DEFAULT NULL COMMENT '平台SKU（用于配对平台商品）',
  `image_url` VARCHAR(255) DEFAULT NULL COMMENT '商品图片URL',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_product_code` (`product_code`),
  KEY `idx_platform_sku` (`platform_sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='公司商品表（用于与平台订单配对）';


-- ===================== 第7段：采购服务 erp_list_purchase =====================

USE `erp_list_purchase`;

CREATE TABLE IF NOT EXISTS `supplier` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `supplier_name` VARCHAR(100) NOT NULL COMMENT '供应商名称',
  `supplier_code` VARCHAR(50) NOT NULL COMMENT '供应商编码',
  `contact_name` VARCHAR(50) DEFAULT NULL COMMENT '联系人姓名',
  `contact_phone` VARCHAR(20) DEFAULT NULL COMMENT '联系人电话',
  `contact_email` VARCHAR(100) DEFAULT NULL COMMENT '联系人邮箱',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '地址',
  `bank_name` VARCHAR(100) DEFAULT NULL COMMENT '开户银行',
  `bank_account` VARCHAR(50) DEFAULT NULL COMMENT '银行账号',
  `tax_number` VARCHAR(50) DEFAULT NULL COMMENT '税号',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_supplier_code` (`supplier_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商表';

CREATE TABLE IF NOT EXISTS `purchase_order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '采购单ID',
  `purchase_no` VARCHAR(50) NOT NULL COMMENT '采购单号',
  `supplier_id` BIGINT NOT NULL COMMENT '供应商ID',
  `supplier_name` VARCHAR(100) NOT NULL COMMENT '供应商名称',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '采购总金额',
  `purchase_status` TINYINT NOT NULL DEFAULT 0 COMMENT '采购状态：0-待审核，1-已审核，2-采购中，3-部分到货，4-已完成，5-已取消',
  `purchaser_id` BIGINT DEFAULT NULL COMMENT '采购员ID',
  `purchaser_name` VARCHAR(50) DEFAULT NULL COMMENT '采购员姓名',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `approver_name` VARCHAR(50) DEFAULT NULL COMMENT '审核人姓名',
  `expected_arrival_time` DATETIME DEFAULT NULL COMMENT '预计到货时间',
  `arrival_time` DATETIME DEFAULT NULL COMMENT '实际到货时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_purchase_no` (`purchase_no`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_purchase_status` (`purchase_status`),
  KEY `idx_purchaser_id` (`purchaser_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购单表';

CREATE TABLE IF NOT EXISTS `purchase_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` BIGINT NOT NULL COMMENT '采购单ID',
  `purchase_no` VARCHAR(50) NOT NULL COMMENT '采购单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `purchase_price` DECIMAL(10,2) NOT NULL COMMENT '采购单价',
  `purchase_quantity` INT NOT NULL COMMENT '采购数量',
  `arrival_quantity` INT DEFAULT 0 COMMENT '到货数量',
  `total_price` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_purchase_id` (`purchase_id`),
  KEY `idx_purchase_no` (`purchase_no`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购明细表';

CREATE TABLE IF NOT EXISTS `purchase_status_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `purchase_id` BIGINT NOT NULL COMMENT '采购单ID',
  `purchase_no` VARCHAR(50) NOT NULL COMMENT '采购单号',
  `old_status` TINYINT DEFAULT NULL COMMENT '原状态',
  `new_status` TINYINT NOT NULL COMMENT '新状态',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人姓名',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_purchase_id` (`purchase_id`),
  KEY `idx_purchase_no` (`purchase_no`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购状态记录表';


-- ===================== 第8段：退款服务 erp_list_refund =====================

USE `erp_list_refund`;

CREATE TABLE IF NOT EXISTS `refund_application` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '退款申请ID',
  `refund_no` VARCHAR(50) NOT NULL COMMENT '退款单号',
  `order_id` BIGINT NOT NULL COMMENT '订单ID',
  `order_no` VARCHAR(50) NOT NULL COMMENT '订单号',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `payment_id` BIGINT NOT NULL COMMENT '支付ID',
  `payment_no` VARCHAR(50) NOT NULL COMMENT '支付单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `refund_amount` DECIMAL(10,2) NOT NULL COMMENT '退款金额',
  `refund_reason_id` BIGINT DEFAULT NULL COMMENT '退款原因ID',
  `refund_reason` VARCHAR(255) DEFAULT NULL COMMENT '退款原因',
  `refund_status` TINYINT NOT NULL DEFAULT 0 COMMENT '退款状态：0-待审核，1-审核通过，2-审核拒绝，3-退款中，4-退款成功，5-退款失败',
  `apply_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `approver_name` VARCHAR(50) DEFAULT NULL COMMENT '审核人姓名',
  `approve_remark` VARCHAR(255) DEFAULT NULL COMMENT '审核备注',
  `refund_time` DATETIME DEFAULT NULL COMMENT '退款时间',
  `third_party_refund_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方退款单号',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_refund_no` (`refund_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_payment_id` (`payment_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_refund_status` (`refund_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款申请表';

CREATE TABLE IF NOT EXISTS `refund_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `refund_id` BIGINT NOT NULL COMMENT '退款申请ID',
  `refund_no` VARCHAR(50) NOT NULL COMMENT '退款单号',
  `refund_amount` DECIMAL(10,2) NOT NULL COMMENT '退款金额',
  `refund_status` TINYINT NOT NULL COMMENT '退款状态：0-处理中，1-成功，2-失败',
  `third_party_refund_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方退款单号',
  `refund_time` DATETIME DEFAULT NULL COMMENT '退款时间',
  `error_message` VARCHAR(500) DEFAULT NULL COMMENT '错误信息',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_refund_id` (`refund_id`),
  KEY `idx_refund_no` (`refund_no`),
  KEY `idx_refund_status` (`refund_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款记录表';

CREATE TABLE IF NOT EXISTS `refund_reason` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '原因ID',
  `reason_name` VARCHAR(50) NOT NULL COMMENT '原因名称',
  `reason_code` VARCHAR(50) NOT NULL COMMENT '原因编码',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_reason_code` (`reason_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='退款原因表';

INSERT INTO `refund_reason` (`reason_name`, `reason_code`, `sort_order`, `status`) VALUES
('商品质量问题', 'QUALITY_ISSUE', 1, 1),
('商品与描述不符', 'DESCRIPTION_MISMATCH', 2, 1),
('不想要了', 'DONT_WANT', 3, 1),
('收到商品损坏', 'DAMAGED', 4, 1),
('发错商品', 'WRONG_ITEM', 5, 1),
('其他原因', 'OTHER', 6, 1);


-- ===================== 第9段：补货服务 erp_list_replenishment =====================

USE `erp_list_replenishment`;

CREATE TABLE IF NOT EXISTS `replenishment_order` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '补货单ID',
  `replenishment_no` VARCHAR(50) NOT NULL COMMENT '补货单号',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` VARCHAR(100) DEFAULT NULL COMMENT '仓库名称',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `total_amount` DECIMAL(10,2) NOT NULL COMMENT '补货总金额',
  `replenishment_status` TINYINT NOT NULL DEFAULT 0 COMMENT '补货状态：0-待审核，1-已审核，2-补货中，3-部分到货，4-已完成，5-已取消',
  `operator_id` BIGINT DEFAULT NULL COMMENT '操作人ID',
  `operator_name` VARCHAR(50) DEFAULT NULL COMMENT '操作人姓名',
  `approve_time` DATETIME DEFAULT NULL COMMENT '审核时间',
  `approver_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
  `approver_name` VARCHAR(50) DEFAULT NULL COMMENT '审核人姓名',
  `expected_arrival_time` DATETIME DEFAULT NULL COMMENT '预计到货时间',
  `arrival_time` DATETIME DEFAULT NULL COMMENT '实际到货时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_replenishment_no` (`replenishment_no`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_zid_sid` (`zid`, `sid`),
  KEY `idx_replenishment_status` (`replenishment_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='补货单表';

CREATE TABLE IF NOT EXISTS `replenishment_item` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `replenishment_id` BIGINT NOT NULL COMMENT '补货单ID',
  `replenishment_no` VARCHAR(50) NOT NULL COMMENT '补货单号',
  `zid` VARCHAR(50) DEFAULT NULL COMMENT '公司ID（Zone ID）',
  `sid` BIGINT DEFAULT NULL COMMENT '店铺ID（Seller ID，引用seller.id）',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `current_stock` INT DEFAULT 0 COMMENT '当前库存',
  `min_stock` INT DEFAULT 0 COMMENT '最低库存',
  `replenishment_quantity` INT NOT NULL COMMENT '补货数量',
  `arrival_quantity` INT DEFAULT 0 COMMENT '到货数量',
  `unit_price` DECIMAL(10,2) DEFAULT NULL COMMENT '单价',
  `total_price` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_replenishment_id` (`replenishment_id`),
  KEY `idx_replenishment_no` (`replenishment_no`),
  KEY `idx_zid` (`zid`),
  KEY `idx_sid` (`sid`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='补货明细表';

CREATE TABLE IF NOT EXISTS `inventory_alert` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `sku_code` VARCHAR(50) DEFAULT NULL COMMENT 'SKU编码',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `warehouse_name` VARCHAR(100) DEFAULT NULL COMMENT '仓库名称',
  `current_stock` INT NOT NULL COMMENT '当前库存',
  `min_stock` INT NOT NULL COMMENT '最低库存',
  `alert_level` TINYINT NOT NULL COMMENT '预警级别：1-低库存，2-缺货',
  `alert_status` TINYINT DEFAULT 0 COMMENT '处理状态：0-未处理，1-已处理',
  `handler_id` BIGINT DEFAULT NULL COMMENT '处理人ID',
  `handler_name` VARCHAR(50) DEFAULT NULL COMMENT '处理人姓名',
  `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_alert_level` (`alert_level`),
  KEY `idx_alert_status` (`alert_status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存预警表';

CREATE TABLE IF NOT EXISTS `replenishment_plan` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '计划ID',
  `plan_name` VARCHAR(100) NOT NULL COMMENT '计划名称',
  `product_id` BIGINT NOT NULL COMMENT '商品ID',
  `product_name` VARCHAR(200) NOT NULL COMMENT '商品名称',
  `sku_id` BIGINT DEFAULT NULL COMMENT 'SKU ID',
  `warehouse_id` BIGINT DEFAULT NULL COMMENT '仓库ID',
  `min_stock` INT NOT NULL COMMENT '最低库存',
  `max_stock` INT NOT NULL COMMENT '最高库存',
  `reorder_point` INT NOT NULL COMMENT '补货点',
  `reorder_quantity` INT NOT NULL COMMENT '补货数量',
  `plan_status` TINYINT DEFAULT 1 COMMENT '计划状态：0-禁用，1-启用',
  `next_replenishment_time` DATETIME DEFAULT NULL COMMENT '下次补货时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_sku_id` (`sku_id`),
  KEY `idx_warehouse_id` (`warehouse_id`),
  KEY `idx_plan_status` (`plan_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='补货计划表';
