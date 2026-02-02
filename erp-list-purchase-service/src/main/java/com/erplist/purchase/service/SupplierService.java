package com.erplist.purchase.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.purchase.dto.SupplierDTO;
import com.erplist.purchase.dto.SupplierQueryDTO;
import com.erplist.purchase.entity.Supplier;

/**
 * 供应商服务接口
 */
public interface SupplierService {

    Supplier createSupplier(SupplierDTO dto);

    Supplier getSupplierById(Long id);

    Supplier updateSupplier(Long id, SupplierDTO dto);

    void deleteSupplier(Long id);

    Page<Supplier> querySuppliers(SupplierQueryDTO queryDTO);

    void updateStatus(Long id, Integer status);
}
