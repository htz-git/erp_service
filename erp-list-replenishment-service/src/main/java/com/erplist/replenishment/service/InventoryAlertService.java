package com.erplist.replenishment.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.replenishment.dto.InventoryAlertHandleDTO;
import com.erplist.replenishment.dto.InventoryAlertQueryDTO;
import com.erplist.replenishment.entity.InventoryAlert;

public interface InventoryAlertService {
    Page<InventoryAlert> query(InventoryAlertQueryDTO queryDTO);
    InventoryAlert getById(Long id);
    void markHandled(Long id, InventoryAlertHandleDTO dto);
}
