package com.erplist.replenishment.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.replenishment.dto.ReplenishmentPlanDTO;
import com.erplist.replenishment.dto.ReplenishmentPlanQueryDTO;
import com.erplist.replenishment.entity.ReplenishmentPlan;

public interface ReplenishmentPlanService {
    Page<ReplenishmentPlan> query(ReplenishmentPlanQueryDTO queryDTO);
    ReplenishmentPlan getById(Long id);
    ReplenishmentPlan create(ReplenishmentPlanDTO dto);
    ReplenishmentPlan update(Long id, ReplenishmentPlanDTO dto);
    void deleteById(Long id);
}
