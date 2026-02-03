package com.erplist.product.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.product.dto.CompanyProductDTO;
import com.erplist.product.dto.CompanyProductQueryDTO;
import com.erplist.product.entity.CompanyProduct;

/**
 * 公司商品服务接口
 */
public interface CompanyProductService {

    CompanyProduct create(CompanyProductDTO dto);

    CompanyProduct getById(Long id);

    CompanyProduct update(Long id, CompanyProductDTO dto);

    void deleteById(Long id);

    Page<CompanyProduct> query(CompanyProductQueryDTO queryDTO);
}
