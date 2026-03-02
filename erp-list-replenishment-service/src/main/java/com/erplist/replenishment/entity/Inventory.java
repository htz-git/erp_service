package com.erplist.replenishment.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 库存实体（按公司+店铺+SKU 维度）
 */
@Data
@TableName("inventory")
public class Inventory {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String zid;
    private Long sid;
    private Long productId;
    private String productName;
    private Long skuId;
    private String skuCode;
    private Integer currentStock;
    private Integer minStock;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    /** 商品图（由列表查询时通过订单服务填充，非表字段） */
    @TableField(exist = false)
    private String productImageUrl;
}
