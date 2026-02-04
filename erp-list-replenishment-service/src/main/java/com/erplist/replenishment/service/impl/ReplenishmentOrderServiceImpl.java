package com.erplist.replenishment.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.replenishment.dto.ReplenishmentOrderDTO;
import com.erplist.replenishment.dto.ReplenishmentOrderQueryDTO;
import com.erplist.replenishment.entity.ReplenishmentItem;
import com.erplist.replenishment.entity.ReplenishmentOrder;
import com.erplist.replenishment.mapper.ReplenishmentItemMapper;
import com.erplist.replenishment.mapper.ReplenishmentOrderMapper;
import com.erplist.replenishment.service.ReplenishmentOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * 补货单服务实现（zid/sid 多租户）
 */
@Service
@RequiredArgsConstructor
public class ReplenishmentOrderServiceImpl implements ReplenishmentOrderService {

    private final ReplenishmentOrderMapper replenishmentOrderMapper;
    private final ReplenishmentItemMapper replenishmentItemMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ReplenishmentOrder createReplenishmentOrder(ReplenishmentOrderDTO dto) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能创建当前公司下的补货单");
        }
        Long sid = dto.getSid() != null ? dto.getSid() : UserContext.getSid();
        ReplenishmentOrder order = new ReplenishmentOrder();
        BeanUtils.copyProperties(dto, order, "id", "items");
        order.setId(null);
        order.setZid(zid);
        order.setSid(sid);
        if (!StringUtils.hasText(order.getReplenishmentNo())) {
            order.setReplenishmentNo(generateReplenishmentNo());
        }
        order.setReplenishmentStatus(order.getReplenishmentStatus() != null ? order.getReplenishmentStatus() : 0);
        replenishmentOrderMapper.insert(order);

        if (!CollectionUtils.isEmpty(dto.getItems())) {
            for (com.erplist.replenishment.dto.ReplenishmentItemDTO itemDto : dto.getItems()) {
                ReplenishmentItem item = new ReplenishmentItem();
                BeanUtils.copyProperties(itemDto, item, "id");
                item.setId(null);
                item.setReplenishmentId(order.getId());
                item.setReplenishmentNo(order.getReplenishmentNo());
                item.setZid(zid);
                item.setSid(sid);
                item.setArrivalQuantity(item.getArrivalQuantity() != null ? item.getArrivalQuantity() : 0);
                if (item.getTotalPrice() == null && item.getUnitPrice() != null && item.getReplenishmentQuantity() != null) {
                    item.setTotalPrice(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getReplenishmentQuantity())));
                }
                replenishmentItemMapper.insert(item);
            }
        }
        return order;
    }

    @Override
    public ReplenishmentOrder getReplenishmentOrderById(Long id) {
        ReplenishmentOrder order = replenishmentOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("补货单不存在");
        }
        ensureSameZid(order.getZid());
        return order;
    }

    @Override
    public List<ReplenishmentItem> getItemsByReplenishmentId(Long replenishmentId) {
        ReplenishmentOrder order = replenishmentOrderMapper.selectById(replenishmentId);
        if (order != null) {
            ensureSameZid(order.getZid());
        }
        LambdaQueryWrapper<ReplenishmentItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ReplenishmentItem::getReplenishmentId, replenishmentId);
        return replenishmentItemMapper.selectList(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ReplenishmentOrder updateReplenishmentOrder(Long id, ReplenishmentOrderDTO dto) {
        ReplenishmentOrder order = replenishmentOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("补货单不存在");
        }
        ensureSameZid(order.getZid());
        BeanUtils.copyProperties(dto, order, "id", "replenishmentNo", "createTime", "deleted", "items");
        replenishmentOrderMapper.updateById(order);

        if (dto.getItems() != null) {
            LambdaQueryWrapper<ReplenishmentItem> delWrapper = new LambdaQueryWrapper<>();
            delWrapper.eq(ReplenishmentItem::getReplenishmentId, id);
            replenishmentItemMapper.delete(delWrapper);
            String zid = order.getZid();
            Long sid = order.getSid();
            for (com.erplist.replenishment.dto.ReplenishmentItemDTO itemDto : dto.getItems()) {
                ReplenishmentItem item = new ReplenishmentItem();
                BeanUtils.copyProperties(itemDto, item, "id");
                item.setId(null);
                item.setReplenishmentId(id);
                item.setReplenishmentNo(order.getReplenishmentNo());
                item.setZid(zid);
                item.setSid(sid);
                item.setArrivalQuantity(item.getArrivalQuantity() != null ? item.getArrivalQuantity() : 0);
                if (item.getTotalPrice() == null && item.getUnitPrice() != null && item.getReplenishmentQuantity() != null) {
                    item.setTotalPrice(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getReplenishmentQuantity())));
                }
                replenishmentItemMapper.insert(item);
            }
        }
        return replenishmentOrderMapper.selectById(id);
    }

    @Override
    public void deleteReplenishmentOrder(Long id) {
        ReplenishmentOrder order = replenishmentOrderMapper.selectById(id);
        if (order == null) {
            throw new BusinessException("补货单不存在");
        }
        ensureSameZid(order.getZid());
        replenishmentOrderMapper.deleteById(id);
    }

    @Override
    public Page<ReplenishmentOrder> queryReplenishmentOrders(ReplenishmentOrderQueryDTO queryDTO) {
        String zid = UserContext.getZid();
        if (!StringUtils.hasText(zid)) {
            throw new BusinessException("未登录或缺少租户信息，仅能查看当前公司下的补货单");
        }
        Long sid = queryDTO.getSid() != null ? queryDTO.getSid() : UserContext.getSid();
        Page<ReplenishmentOrder> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        LambdaQueryWrapper<ReplenishmentOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ReplenishmentOrder::getZid, zid);
        if (sid != null) {
            wrapper.eq(ReplenishmentOrder::getSid, sid);
        }
        if (StringUtils.hasText(queryDTO.getReplenishmentNo())) {
            wrapper.like(ReplenishmentOrder::getReplenishmentNo, queryDTO.getReplenishmentNo());
        }
        if (queryDTO.getWarehouseId() != null) {
            wrapper.eq(ReplenishmentOrder::getWarehouseId, queryDTO.getWarehouseId());
        }
        if (queryDTO.getReplenishmentStatus() != null) {
            wrapper.eq(ReplenishmentOrder::getReplenishmentStatus, queryDTO.getReplenishmentStatus());
        }
        if (queryDTO.getOperatorId() != null) {
            wrapper.eq(ReplenishmentOrder::getOperatorId, queryDTO.getOperatorId());
        }
        wrapper.orderByDesc(ReplenishmentOrder::getCreateTime);
        return replenishmentOrderMapper.selectPage(page, wrapper);
    }

    private String generateReplenishmentNo() {
        return "RO" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + (int) (Math.random() * 1000);
    }

    private void ensureSameZid(String entityZid) {
        String currentZid = UserContext.getZid();
        if (!StringUtils.hasText(currentZid) || !currentZid.equals(entityZid)) {
            throw new BusinessException("无权限操作该补货单");
        }
    }
}
