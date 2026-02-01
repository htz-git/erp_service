package com.erplist.common.utils;

/**
 * 用户上下文工具类
 * 用于在微服务间传递用户信息
 */
public class UserContext {
    private static final ThreadLocal<Long> userId = new ThreadLocal<>();
    private static final ThreadLocal<String> zid = new ThreadLocal<>();
    private static final ThreadLocal<Long> sid = new ThreadLocal<>();

    /**
     * 保存当前登录用户ID
     */
    public static void setUserId(Long id) {
        userId.set(id);
    }

    /**
     * 获取当前登录用户ID
     */
    public static Long getUserId() {
        return userId.get();
    }

    /**
     * 保存当前用户所属公司ID
     */
    public static void setZid(String companyId) {
        zid.set(companyId);
    }

    /**
     * 获取当前用户所属公司ID
     */
    public static String getZid() {
        return zid.get();
    }

    /**
     * 保存当前选择的店铺ID
     */
    public static void setSid(Long sellerId) {
        sid.set(sellerId);
    }

    /**
     * 获取当前选择的店铺ID
     */
    public static Long getSid() {
        return sid.get();
    }

    /**
     * 移除所有用户信息
     */
    public static void remove() {
        userId.remove();
        zid.remove();
        sid.remove();
    }
}

