package com.erplist.purchase.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.purchase.dto.PurchaseItemDTO;
import com.erplist.purchase.dto.PurchaseOrderDTO;
import com.erplist.purchase.dto.PurchaseOrderQueryDTO;
import com.erplist.purchase.entity.PurchaseItem;
import com.erplist.purchase.entity.PurchaseOrder;
import com.erplist.purchase.entity.Supplier;
import com.erplist.purchase.mapper.PurchaseItemMapper;
import com.erplist.purchase.mapper.PurchaseOrderMapper;
import com.erplist.purchase.mapper.SupplierMapper;
import com.erplist.purchase.service.PurchaseOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * 采购单服务实现（支持 zid/sid 多租户）
 */
@Service
@RequiredArgsConstructor
public class PurchaseOrderServiceImpl implements PurchaseOrderService {

    private final PurchaseOrderMapper purchaseOrderMapper;
    private final PurchaseItemMapper purchaseItemMapper;
    private final SupplierMapper supplierMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PurchaseOrder createPurchaseOrder(PurchaseOrderDTO dto) {
        PurchaseOrder order = new PurchaseOrder();
        BeanUtils.copyProperties(dto, order, "id", "items");
        String zid = dto.getZid() != null ? dto.getZid() : UserContext.getZid();
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        order.setZid(zid);
        order.setSid(sid);
        if (!StringUtils.hasText(order.getPurchaseNo())) {
            order.setPurchaseNo("PO" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        }
        if (order.getSupplierName() == null && order.getSupplierId() != null) {
            Supplier supplier = supplierMapper.selectById(order.getSupplierId());
            if (supplier != null) {
                order.setSupplierName(supplier.getSupplierName());
            }
        }
        order.setPurchaseStatus(order.getPurchaseStatus() != null ? order.getPurchaseStatus() : 0);
        purchaseOrderMapper.insert(order);

        if (dto.getItems() != null && !dto.getItems().isEmpty()) {
            for (PurchaseItemDTO itemDto : dto.getItems()) {
                PurchaseItem item = new PurchaseItem();
                BeanUtils.copyProperties(itemDto, item);
                item.setPurchaseId(order.getId());
                item.setPurchaseNo(order.getPurchaseNo());
                item.setZid(zid);
                item.setSid(sid);
                item.setArrivalQuantity(item.getArrivalQuantity() != null ? item.getArrivalQuantity() : 0);
                if (item.getTotalPrice() == null && item.getPurchasePrice() != null && item.getPurchaseQuantity() != null) {
                    item.setTotalPrice(item.getPurchasePrice().multiply(BigDecimal.valueOf(item.getPurchaseQuantity())));
                }
                purchaseItemMapper.insert(item);
            }
        }
        return order;
    }

    @Override
    public PurchaseOrder getPurchaseOrderById(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("采购单不存在");
        }
        return order;
    }

    @Override
    public List<PurchaseItem> getItemsByPurchaseId(Long purchaseId) {
        LambdaQueryWrapper<PurchaseItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PurchaseItem::getPurchaseId, purchaseId).orderByAsc(PurchaseItem::getId);
        return purchaseItemMapper.selectList(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PurchaseOrder updatePurchaseOrder(Long id, PurchaseOrderDTO dto) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("采购单不存在");
        }
        BeanUtils.copyProperties(dto, order, "id", "purchaseNo", "createTime");
        if (order.getSupplierName() == null && order.getSupplierId() != null) {
            Supplier supplier = supplierMapper.selectById(order.getSupplierId());
            if (supplier != null) {
                order.setSupplierName(supplier.getSupplierName());
            }
        }
        purchaseOrderMapper.updateById(order);
        return order;
    }

    @Override
    public void deletePurchaseOrder(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("采购单不存在");
        }
        purchaseOrderMapper.deleteById(id);
    }

    @Override
    public Page<PurchaseOrder> queryPurchaseOrders(PurchaseOrderQueryDTO queryDTO) {
        Page<PurchaseOrder> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<PurchaseOrder> wrapper = new LambdaQueryWrapper<>();
        String zid = queryDTO.getZid() != null ? queryDTO.getZid() : UserContext.getZid();
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        if (StringUtils.hasText(zid)) {
            wrapper.eq(PurchaseOrder::getZid, zid);
        }
        if (sid != null) {
            wrapper.eq(PurchaseOrder::getSid, sid);
        }
        if (StringUtils.hasText(queryDTO.getPurchaseNo())) {
            wrapper.eq(PurchaseOrder::getPurchaseNo, queryDTO.getPurchaseNo());
        }
        if (queryDTO.getSupplierId() != null) {
            wrapper.eq(PurchaseOrder::getSupplierId, queryDTO.getSupplierId());
        }
        if (queryDTO.getPurchaseStatus() != null) {
            wrapper.eq(PurchaseOrder::getPurchaseStatus, queryDTO.getPurchaseStatus());
        }
        if (queryDTO.getPurchaserId() != null) {
            wrapper.eq(PurchaseOrder::getPurchaserId, queryDTO.getPurchaserId());
        }
        wrapper.orderByDesc(PurchaseOrder::getCreateTime);
        return purchaseOrderMapper.selectPage(page, wrapper);
    }
}
