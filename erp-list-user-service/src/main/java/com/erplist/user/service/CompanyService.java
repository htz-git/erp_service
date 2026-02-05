package com.erplist.user.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.user.dto.CompanyOnboardRequest;
import com.erplist.user.dto.CompanyOnboardResultVO;
import com.erplist.user.dto.CompanyQueryDTO;
import com.erplist.user.dto.CompanyUpdateDTO;
import com.erplist.user.entity.Company;

/**
 * 公司服务（管理端：开通、列表、详情、编辑、启用禁用）
 */
public interface CompanyService {

    /**
     * 开通公司：生成 zid、插入 company、创建该公司超管用户并绑定权限
     */
    CompanyOnboardResultVO onboard(CompanyOnboardRequest request);

    Page<Company> list(CompanyQueryDTO query);

    Company getById(String zid);

    Company update(String zid, CompanyUpdateDTO dto);

    void updateStatus(String zid, Integer status);
}
