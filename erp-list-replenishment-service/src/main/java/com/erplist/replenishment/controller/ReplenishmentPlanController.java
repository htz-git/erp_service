package com.erplist.replenishment.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.replenishment.dto.ReplenishmentPlanDTO;
import com.erplist.replenishment.dto.ReplenishmentPlanQueryDTO;
import com.erplist.replenishment.entity.ReplenishmentPlan;
import com.erplist.replenishment.service.ReplenishmentPlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 补货计划控制器（/replenishment-plans，网关 /api/replenishment-plans 对应）
 */
@RestController
@RequestMapping("/replenishment-plans")
@RequiredArgsConstructor
public class ReplenishmentPlanController {

    private final ReplenishmentPlanService replenishmentPlanService;

    @GetMapping
    public Result<Page<ReplenishmentPlan>> query(ReplenishmentPlanQueryDTO queryDTO) {
        Page<ReplenishmentPlan> page = replenishmentPlanService.query(queryDTO);
        return Result.success(page);
    }

    @GetMapping("/{id}")
    public Result<ReplenishmentPlan> getById(@PathVariable Long id) {
        ReplenishmentPlan entity = replenishmentPlanService.getById(id);
        return Result.success(entity);
    }

    @PostMapping
    public Result<ReplenishmentPlan> create(@Validated @RequestBody ReplenishmentPlanDTO dto) {
        ReplenishmentPlan entity = replenishmentPlanService.create(dto);
        return Result.success(entity);
    }

    @PutMapping("/{id}")
    public Result<ReplenishmentPlan> update(@PathVariable Long id, @Validated @RequestBody ReplenishmentPlanDTO dto) {
        ReplenishmentPlan entity = replenishmentPlanService.update(id, dto);
        return Result.success(entity);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        replenishmentPlanService.deleteById(id);
        return Result.success();
    }
}
