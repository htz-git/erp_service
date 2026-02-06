package com.erplist.replenishment.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.replenishment.dto.InventoryDTO;
import com.erplist.replenishment.dto.InventoryQueryDTO;
import com.erplist.replenishment.entity.Inventory;

/**
 * 库存服务
 */
public interface InventoryService {

    Inventory create(InventoryDTO dto);

    Inventory update(Long id, InventoryDTO dto);

    Inventory getById(Long id);

    Page<Inventory> query(InventoryQueryDTO queryDTO);
}
