package com.erplist.user.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 公司实体，主键 id 即 zid
 */
@Data
@TableName("company")
public class Company {
    @TableId(type = IdType.INPUT)
    private String id;

    private String companyName;
    private String contactName;
    private String contactPhone;
    private String contactEmail;
    private String address;
    private Integer status;
    private String remark;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    @TableLogic
    private Integer deleted;
}
