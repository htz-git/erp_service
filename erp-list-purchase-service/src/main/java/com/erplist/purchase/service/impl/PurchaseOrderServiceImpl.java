package com.erplist.purchase.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.purchase.dto.CreatePurchaseFromSuggestionsRequest;
import com.erplist.purchase.dto.PurchaseItemDTO;
import com.erplist.purchase.dto.PurchaseOrderDTO;
import com.erplist.purchase.dto.PurchaseOrderQueryDTO;
import com.erplist.purchase.dto.SuggestionItemDTO;
import com.erplist.api.client.OrderClient;
import com.erplist.api.dto.ProductImageDTO;
import com.erplist.common.result.Result;
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
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 采购单服务实现（支持 zid/sid 多租户）
 */
@Service
@RequiredArgsConstructor
public class PurchaseOrderServiceImpl implements PurchaseOrderService {

    private final PurchaseOrderMapper purchaseOrderMapper;
    private final PurchaseItemMapper purchaseItemMapper;
    private final SupplierMapper supplierMapper;
    private final OrderClient orderClient;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PurchaseOrder createPurchaseOrder(PurchaseOrderDTO dto) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的采购单");
        }
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        PurchaseOrder order = new PurchaseOrder();
        BeanUtils.copyProperties(dto, order, "id", "items");
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
        ensureSameZid(order.getZid());
        return order;
    }

    @Override
    public List<PurchaseItem> getItemsByPurchaseId(Long purchaseId) {
        PurchaseOrder order = purchaseOrderMapper.selectById(purchaseId);
        if (order != null) {
            ensureSameZid(order.getZid());
        }
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
        ensureSameZid(order.getZid());
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
        ensureSameZid(order.getZid());
        purchaseOrderMapper.deleteById(id);
    }

    @Override
    public Page<PurchaseOrder> queryPurchaseOrders(PurchaseOrderQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的采购单");
        }
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        Page<PurchaseOrder> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<PurchaseOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PurchaseOrder::getZid, zid);
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
        Page<PurchaseOrder> result = purchaseOrderMapper.selectPage(page, wrapper);
        if (result.getRecords() != null && !result.getRecords().isEmpty()) {
            List<Long> purchaseIds = result.getRecords().stream().map(PurchaseOrder::getId).collect(Collectors.toList());
            LambdaQueryWrapper<PurchaseItem> itemWrapper = new LambdaQueryWrapper<>();
            itemWrapper.in(PurchaseItem::getPurchaseId, purchaseIds).orderByAsc(PurchaseItem::getPurchaseId).orderByAsc(PurchaseItem::getId);
            List<PurchaseItem> allItems = purchaseItemMapper.selectList(itemWrapper);
            Map<Long, Long> purchaseIdToProductId = new LinkedHashMap<>();
            if (allItems != null) {
                for (PurchaseItem i : allItems) {
                    purchaseIdToProductId.putIfAbsent(i.getPurchaseId(), i.getProductId());
                }
            }
            List<Long> productIds = purchaseIdToProductId.values().stream().filter(Objects::nonNull).distinct().collect(Collectors.toList());
            if (!productIds.isEmpty()) {
                Result<List<ProductImageDTO>> res = orderClient.getProductImagesByProductIds(productIds);
                Map<Long, String> productIdToImage = new LinkedHashMap<>();
                if (res != null && res.getData() != null) {
                    for (ProductImageDTO dto : res.getData()) {
                        if (dto.getProductId() != null && dto.getProductImage() != null) {
                            productIdToImage.put(dto.getProductId(), dto.getProductImage());
                        }
                    }
                }
                for (PurchaseOrder o : result.getRecords()) {
                    Long pid = purchaseIdToProductId.get(o.getId());
                    if (pid != null) {
                        o.setFirstItemImageUrl(productIdToImage.get(pid));
                    }
                }
            }
        }
        return result;
    }

    @Override
    public void fillProductImageForItems(List<PurchaseItem> items) {
        if (items == null || items.isEmpty()) {
            return;
        }
        List<Long> productIds = items.stream().map(PurchaseItem::getProductId).filter(Objects::nonNull).distinct().collect(Collectors.toList());
        if (productIds.isEmpty()) {
            return;
        }
        Result<List<ProductImageDTO>> res = orderClient.getProductImagesByProductIds(productIds);
        Map<Long, String> productIdToImage = new LinkedHashMap<>();
        if (res != null && res.getData() != null) {
            for (ProductImageDTO dto : res.getData()) {
                if (dto.getProductId() != null && dto.getProductImage() != null) {
                    productIdToImage.put(dto.getProductId(), dto.getProductImage());
                }
            }
        }
        for (PurchaseItem item : items) {
            if (item.getProductId() != null) {
                item.setProductImageUrl(productIdToImage.get(item.getProductId()));
            }
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public PurchaseOrder createPurchaseOrderFromSuggestions(CreatePurchaseFromSuggestionsRequest request) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的采购单");
        }
        List<SuggestionItemDTO> valid = request.getSuggestions().stream()
                .filter(s -> s.getSuggestedQuantity() != null && s.getSuggestedQuantity() > 0)
                .collect(Collectors.toList());
        if (valid.isEmpty()) {
            throw new BusinessException("没有有效的补货建议（建议补货量需大于0）");
        }
        Long sid = valid.get(0).getSid() != null ? valid.get(0).getSid() : UserContext.getSid();
        Supplier supplier = supplierMapper.selectById(request.getSupplierId());
        if (supplier == null) {
            throw new BusinessException("供应商不存在");
        }
        PurchaseOrderDTO dto = new PurchaseOrderDTO();
        dto.setSupplierId(request.getSupplierId());
        dto.setSupplierName(supplier.getSupplierName());
        dto.setSid(sid);
        dto.setTotalAmount(BigDecimal.ZERO);
        dto.setPurchaseStatus(0);
        List<PurchaseItemDTO> items = new ArrayList<>();
        for (SuggestionItemDTO s : valid) {
            PurchaseItemDTO item = new PurchaseItemDTO();
            item.setProductId(s.getProductId());
            item.setProductName(s.getProductName() != null ? s.getProductName() : "");
            item.setSkuId(s.getSkuId());
            item.setSkuCode(s.getSkuCode());
            item.setPurchasePrice(BigDecimal.ZERO);
            item.setPurchaseQuantity(s.getSuggestedQuantity());
            item.setTotalPrice(BigDecimal.ZERO);
            items.add(item);
        }
        dto.setItems(items);
        return createPurchaseOrder(dto);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void approvePurchaseOrder(Long id) {
        PurchaseOrder order = purchaseOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("采购单不存在");
        }
        ensureSameZid(order.getZid());
        if (order.getPurchaseStatus() == null || order.getPurchaseStatus() != 0) {
            throw new BusinessException("仅待审核状态的采购单可审核通过");
        }
        order.setPurchaseStatus(1);
        order.setApproveTime(LocalDateTime.now());
        order.setApproverId(UserContext.getUserId());
        order.setApproverName(null);
        purchaseOrderMapper.updateById(order);
    }

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该采购单");
        }
    }
}
