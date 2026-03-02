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

    /**
     * 入库：增加当前库存数量（可选关联采购单ID，用于到货入库）
     */
    Inventory stockIn(Long id, Integer quantity, Long purchaseId);

    /**
     * 出库：减少当前库存数量
     */
    Inventory stockOut(Long id, Integer quantity);
}
