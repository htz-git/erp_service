package com.erplist.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.common.exception.BusinessException;
import com.erplist.common.utils.UserContext;
import com.erplist.user.dto.CompanyOnboardRequest;
import com.erplist.user.dto.CompanyOnboardResultVO;
import com.erplist.user.dto.CompanyQueryDTO;
import com.erplist.user.dto.CompanyUpdateDTO;
import com.erplist.user.entity.Company;
import com.erplist.user.entity.Permission;
import com.erplist.user.entity.User;
import com.erplist.user.entity.UserPermission;
import com.erplist.user.mapper.CompanyMapper;
import com.erplist.user.mapper.PermissionMapper;
import com.erplist.user.mapper.UserMapper;
import com.erplist.user.mapper.UserPermissionMapper;
import com.erplist.user.service.AuditLogService;
import com.erplist.user.service.CompanyService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 公司服务实现（管理端）
 */
@Service
@RequiredArgsConstructor
public class CompanyServiceImpl implements CompanyService {

    /** 开通公司时为本公司超管绑定的权限编码（不含 admin:access） */
    private static final List<String> COMPANY_ADMIN_PERMISSION_CODES = Arrays.asList(
            "user:create", "user:update", "user:delete",
            "seller:create", "seller:delete",
            "product:create", "product:update", "product:delete"
    );

    private final CompanyMapper companyMapper;
    private final UserMapper userMapper;
    private final PermissionMapper permissionMapper;
    private final UserPermissionMapper userPermissionMapper;
    private final AuditLogService auditLogService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CompanyOnboardResultVO onboard(CompanyOnboardRequest request) {
        // 1. 生成 zid = 所有已创建公司数量 + 1
        int count = companyMapper.countAll();
        String zid = String.valueOf(count + 1);

        // 2. 插入 company
        Company company = new Company();
        company.setId(zid);
        company.setCompanyName(request.getCompanyName());
        company.setContactName(request.getContactName());
        company.setContactPhone(request.getContactPhone());
        company.setContactEmail(request.getContactEmail());
        company.setAddress(request.getAddress());
        company.setRemark(request.getRemark());
        company.setStatus(1);
        companyMapper.insert(company);

        // 3. 检查超管用户名是否已存在
        User existUser = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, request.getAdminUsername()));
        if (existUser != null) {
            throw new BusinessException("超管用户名已存在");
        }

        // 4. 创建该公司超管用户
        User adminUser = new User();
        adminUser.setZid(zid);
        adminUser.setUsername(request.getAdminUsername());
        adminUser.setPassword(request.getAdminPassword()); // TODO: 加密
        adminUser.setRealName(request.getAdminRealName());
        adminUser.setPhone(request.getAdminPhone());
        adminUser.setEmail(request.getAdminEmail());
        adminUser.setStatus(1);
        userMapper.insert(adminUser);

        // 5. 为本公司超管绑定权限（user/seller/product 等，不含 admin:access）
        for (String code : COMPANY_ADMIN_PERMISSION_CODES) {
            Permission p = permissionMapper.selectOne(
                    new LambdaQueryWrapper<Permission>().eq(Permission::getPermissionCode, code));
            if (p != null) {
                UserPermission up = new UserPermission();
                up.setUserId(adminUser.getId());
                up.setPermissionId(p.getId());
                userPermissionMapper.insert(up);
            }
        }

        // 6. 审计日志
        Long operatorId = UserContext.getUserId();
        String operatorName = null;
        if (operatorId != null) {
            User operator = userMapper.selectById(operatorId);
            if (operator != null) operatorName = operator.getUsername();
        }
        auditLogService.save(operatorId, operatorName, "company_onboard", "company", zid,
                "开通公司: " + request.getCompanyName() + ", 超管: " + request.getAdminUsername());

        // 7. 返回结果（初始密码仅此处返回）
        CompanyOnboardResultVO vo = new CompanyOnboardResultVO();
        vo.setCompany(company);
        adminUser.setPassword(null);
        vo.setAdminUser(adminUser);
        vo.setInitialPassword(request.getAdminPassword());
        return vo;
    }

    @Override
    public Page<Company> list(CompanyQueryDTO query) {
        Page<Company> page = new Page<>(query.getPageNum(), query.getPageSize());
        LambdaQueryWrapper<Company> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(query.getZid())) {
            wrapper.eq(Company::getId, query.getZid());
        }
        if (StringUtils.hasText(query.getCompanyName())) {
            wrapper.like(Company::getCompanyName, query.getCompanyName());
        }
        if (query.getStatus() != null) {
            wrapper.eq(Company::getStatus, query.getStatus());
        }
        wrapper.orderByDesc(Company::getCreateTime);
        return companyMapper.selectPage(page, wrapper);
    }

    @Override
    public Company getById(String zid) {
        Company company = companyMapper.selectById(zid);
        if (company == null) {
            throw new BusinessException("公司不存在");
        }
        return company;
    }

    @Override
    public Company update(String zid, CompanyUpdateDTO dto) {
        Company company = companyMapper.selectById(zid);
        if (company == null) {
            throw new BusinessException("公司不存在");
        }
        if (StringUtils.hasText(dto.getCompanyName())) company.setCompanyName(dto.getCompanyName());
        if (dto.getContactName() != null) company.setContactName(dto.getContactName());
        if (dto.getContactPhone() != null) company.setContactPhone(dto.getContactPhone());
        if (dto.getContactEmail() != null) company.setContactEmail(dto.getContactEmail());
        if (dto.getAddress() != null) company.setAddress(dto.getAddress());
        if (dto.getStatus() != null) company.setStatus(dto.getStatus());
        if (dto.getRemark() != null) company.setRemark(dto.getRemark());
        companyMapper.updateById(company);
        return company;
    }

    @Override
    public void updateStatus(String zid, Integer status) {
        Company company = companyMapper.selectById(zid);
        if (company == null) {
            throw new BusinessException("公司不存在");
        }
        if (status != 0 && status != 1) {
            throw new BusinessException("状态值不合法");
        }
        company.setStatus(status);
        companyMapper.updateById(company);
        Long operatorId = UserContext.getUserId();
        String operatorName = null;
        if (operatorId != null) {
            User operator = userMapper.selectById(operatorId);
            if (operator != null) operatorName = operator.getUsername();
        }
        auditLogService.save(operatorId, operatorName,
                status == 1 ? "company_enable" : "company_disable", "company", zid, "公司 " + zid);
    }
}
