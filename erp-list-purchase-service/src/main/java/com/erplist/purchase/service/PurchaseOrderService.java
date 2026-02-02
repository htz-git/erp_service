package com.erplist.purchase.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.purchase.dto.PurchaseOrderDTO;
import com.erplist.purchase.dto.PurchaseOrderQueryDTO;
import com.erplist.purchase.entity.PurchaseOrder;

import java.util.List;

/**
 * 采购单服务接口（支持 zid/sid 多租户）
 */
public interface PurchaseOrderService {

    PurchaseOrder createPurchaseOrder(PurchaseOrderDTO dto);

    PurchaseOrder getPurchaseOrderById(Long id);

    List<com.erplist.purchase.entity.PurchaseItem> getItemsByPurchaseId(Long purchaseId);

    PurchaseOrder updatePurchaseOrder(Long id, PurchaseOrderDTO dto);

    void deletePurchaseOrder(Long id);

    Page<PurchaseOrder> queryPurchaseOrders(PurchaseOrderQueryDTO queryDTO);
}
