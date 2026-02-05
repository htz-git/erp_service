package com.erplist.user.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.result.Result;
import com.erplist.common.utils.UserContext;
import com.erplist.user.dto.*;
import com.erplist.user.entity.AuditLog;
import com.erplist.user.entity.Company;
import com.erplist.user.entity.User;
import com.erplist.user.service.AuditLogService;
import com.erplist.user.service.CompanyService;
import com.erplist.user.service.UserService;
import com.erplist.user.util.AdminHelper;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

/**
 * 管理后台接口（仅平台管理员可访问，需虚拟 zid + admin:access）
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminHelper adminHelper;
    private final CompanyService companyService;
    private final UserService userService;
    private final AuditLogService auditLogService;

    /** 公司管理 */

    @PostMapping("/companies/onboard")
    public Result<CompanyOnboardResultVO> onboardCompany(@Validated @RequestBody CompanyOnboardRequest request) {
        adminHelper.ensureAdmin();
        return Result.success(companyService.onboard(request));
    }

    @GetMapping("/companies")
    public Result<Page<Company>> listCompanies(CompanyQueryDTO query) {
        adminHelper.ensureAdmin();
        return Result.success(companyService.list(query));
    }

    @GetMapping("/companies/{zid}")
    public Result<Company> getCompany(@PathVariable String zid) {
        adminHelper.ensureAdmin();
        return Result.success(companyService.getById(zid));
    }

    @PutMapping("/companies/{zid}")
    public Result<Company> updateCompany(@PathVariable String zid, @RequestBody CompanyUpdateDTO dto) {
        adminHelper.ensureAdmin();
        return Result.success(companyService.update(zid, dto));
    }

    @PutMapping("/companies/{zid}/status")
    public Result<Void> updateCompanyStatus(@PathVariable String zid, @RequestParam Integer status) {
        adminHelper.ensureAdmin();
        companyService.updateStatus(zid, status);
        return Result.success();
    }

    /** 用户管理（全平台） */

    @GetMapping("/users")
    public Result<Page<User>> listAllUsers(AdminUserQueryDTO query) {
        adminHelper.ensureAdmin();
        return Result.success(userService.listAllUsers(query));
    }

    @PutMapping("/users/{id}/status")
    public Result<Void> updateUserStatus(@PathVariable Long id, @RequestParam Integer status) {
        adminHelper.ensureAdmin();
        userService.updateStatus(id, status);
        Long operatorId = UserContext.getUserId();
        User operator = operatorId != null ? userService.getUserById(operatorId) : null;
        auditLogService.save(operatorId, operator != null ? operator.getUsername() : null,
                status == 1 ? "user_enable" : "user_disable", "user", String.valueOf(id), "用户ID: " + id);
        return Result.success();
    }

    @PostMapping("/users/{id}/reset-password")
    public Result<Void> resetUserPassword(@PathVariable Long id, @Validated @RequestBody ResetPasswordRequest request) {
        adminHelper.ensureAdmin();
        userService.resetPassword(id, request.getNewPassword());
        Long operatorId = UserContext.getUserId();
        User operator = operatorId != null ? userService.getUserById(operatorId) : null;
        auditLogService.save(operatorId, operator != null ? operator.getUsername() : null,
                "user_reset_password", "user", String.valueOf(id), "用户ID: " + id);
        return Result.success();
    }

    /** 数据查看：按公司展示用户数、店铺数 */

    @GetMapping("/data/view")
    public Result<List<DataViewVO>> dataView(@RequestParam(required = false) String zid) {
        adminHelper.ensureAdmin();
        List<DataViewVO> list = new ArrayList<>();
        CompanyQueryDTO query = new CompanyQueryDTO();
        if (zid != null && !zid.isEmpty()) {
            query.setZid(zid);
        }
        query.setPageSize(1000);
        Page<Company> page = companyService.list(query);
        for (Company c : page.getRecords()) {
            DataViewVO vo = new DataViewVO();
            vo.setZid(c.getId());
            vo.setCompanyName(c.getCompanyName());
            vo.setUserCount(userService.countUsersByZid(c.getId()));
            vo.setSellerCount(0L); // 需调 seller 服务按 zid 统计店铺数时可在此处 Feign 调用
            list.add(vo);
        }
        return Result.success(list);
    }

    /** 审计日志 */

    @GetMapping("/audit-logs")
    public Result<Page<AuditLog>> listAuditLogs(AuditLogQueryDTO query) {
        adminHelper.ensureAdmin();
        return Result.success(auditLogService.list(query));
    }
}
