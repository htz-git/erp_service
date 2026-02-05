package com.erplist.user.constant;

/**
 * 平台管理员常量
 */
public final class AdminConstant {

    /**
     * 管理员账号使用的固定虚拟 zid，与普通客户的公司 zid 区分
     */
    public static final String ADMIN_ZID = "__platform__";

    /**
     * 管理员后台访问权限编码
     */
    public static final String ADMIN_ACCESS = "admin:access";

    private AdminConstant() {
    }
}
