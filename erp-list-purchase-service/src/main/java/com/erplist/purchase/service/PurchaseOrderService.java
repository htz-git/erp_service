package com.erplist.purchase.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.purchase.dto.CreatePurchaseFromSuggestionsRequest;
import com.erplist.purchase.dto.PurchaseOrderDTO;
import com.erplist.purchase.dto.PurchaseOrderQueryDTO;
import com.erplist.purchase.entity.PurchaseItem;
import com.erplist.purchase.entity.PurchaseOrder;

import java.util.List;

/**
 * 采购单服务接口（支持 zid/sid 多租户）
 */
public interface PurchaseOrderService {

    PurchaseOrder createPurchaseOrder(PurchaseOrderDTO dto);

    PurchaseOrder createPurchaseOrderFromSuggestions(CreatePurchaseFromSuggestionsRequest request);

    void approvePurchaseOrder(Long id);

    PurchaseOrder getPurchaseOrderById(Long id);

    List<PurchaseItem> getItemsByPurchaseId(Long purchaseId);

    /**
     * 为采购明细列表填充商品图（调用订单服务按 productId 拉取）
     */
    void fillProductImageForItems(List<PurchaseItem> items);

    PurchaseOrder updatePurchaseOrder(Long id, PurchaseOrderDTO dto);

    void deletePurchaseOrder(Long id);

    Page<PurchaseOrder> queryPurchaseOrders(PurchaseOrderQueryDTO queryDTO);
}
