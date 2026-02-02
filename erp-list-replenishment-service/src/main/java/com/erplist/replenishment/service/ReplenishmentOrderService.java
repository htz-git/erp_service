package com.erplist.replenishment.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.replenishment.dto.ReplenishmentOrderDTO;
import com.erplist.replenishment.dto.ReplenishmentOrderQueryDTO;
import com.erplist.replenishment.entity.ReplenishmentItem;
import com.erplist.replenishment.entity.ReplenishmentOrder;

import java.util.List;

/**
 * 补货单服务接口（支持 zid/sid 多租户）
 */
public interface ReplenishmentOrderService {

    ReplenishmentOrder createReplenishmentOrder(ReplenishmentOrderDTO dto);

    ReplenishmentOrder getReplenishmentOrderById(Long id);

    List<ReplenishmentItem> getItemsByReplenishmentId(Long replenishmentId);

    ReplenishmentOrder updateReplenishmentOrder(Long id, ReplenishmentOrderDTO dto);

    void deleteReplenishmentOrder(Long id);

    Page<ReplenishmentOrder> queryReplenishmentOrders(ReplenishmentOrderQueryDTO queryDTO);
}
