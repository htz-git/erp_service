package com.erplist.product.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.product.dto.CompanyProductDTO;
import com.erplist.product.dto.CompanyProductQueryDTO;
import com.erplist.product.dto.PageResult;
import com.erplist.product.entity.CompanyProduct;
import com.erplist.product.service.CompanyProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 公司商品控制器
 */
@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
public class CompanyProductController {

    private final CompanyProductService companyProductService;

    @PostMapping
    public Result<CompanyProduct> create(@Validated @RequestBody CompanyProductDTO dto) {
        CompanyProduct entity = companyProductService.create(dto);
        return Result.success(entity);
    }

    @GetMapping("/{id}")
    public Result<CompanyProduct> getById(@PathVariable Long id) {
        CompanyProduct entity = companyProductService.getById(id);
        return Result.success(entity);
    }

    @PutMapping("/{id}")
    public Result<CompanyProduct> update(@PathVariable Long id, @Validated @RequestBody CompanyProductDTO dto) {
        CompanyProduct entity = companyProductService.update(id, dto);
        return Result.success(entity);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteById(@PathVariable Long id) {
        companyProductService.deleteById(id);
        return Result.success();
    }

    @GetMapping
    public Result<PageResult<CompanyProduct>> query(CompanyProductQueryDTO queryDTO) {
        Page<CompanyProduct> page = companyProductService.query(queryDTO);
        PageResult<CompanyProduct> result = new PageResult<>(
                page.getRecords(),
                page.getTotal()
        );
        return Result.success(result);
    }
}
