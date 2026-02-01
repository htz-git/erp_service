package com.erplist.seller.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableLogic;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 店铺授权实体类
 * seller表的id字段就是sid（店铺ID），其他表引用时使用seller.id作为sid值
 */
@Data
@TableName("seller")
public class Seller {
    @TableId(type = IdType.AUTO)
    private Long id;  // 这个id就是sid，其他表引用时使用这个id作为sid
    
    /**
     * 店铺标识（Seller ID），与id字段相同，用于业务标识
     */
    private String sid;
    
    /**
     * 用户ID（所属公司）
     */
    private Long userId;
    
    /**
     * 店铺名称
     */
    private String sellerName;
    
    /**
     * 平台类型：amazon-亚马逊，ebay-eBay，aliexpress-速卖通等
     */
    private String platform;
    
    /**
     * 平台账号
     */
    private String platformAccount;
    
    /**
     * 访问令牌
     */
    private String accessToken;
    
    /**
     * 刷新令牌
     */
    private String refreshToken;
    
    /**
     * 令牌过期时间
     */
    private LocalDateTime tokenExpireTime;
    
    /**
     * 状态：0-禁用，1-启用
     */
    private Integer status;
    
    /**
     * 授权时间
     */
    private LocalDateTime authorizeTime;
    
    /**
     * 备注
     */
    private String remark;
    
    private LocalDateTime createTime;
    
    private LocalDateTime updateTime;
    
    @TableLogic
    private Integer deleted;
}

