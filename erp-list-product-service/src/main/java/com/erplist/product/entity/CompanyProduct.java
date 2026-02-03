package com.erplist.product.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 公司商品实体（对应 company_product 表）
 */
@Data
@TableName("company_product")
public class CompanyProduct {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String zid;
    private Long sid;
    private String productName;
    private String productCode;
    private String skuCode;
    private String platformSku;
    private String imageUrl;
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @TableLogic
    private Integer deleted;
}
