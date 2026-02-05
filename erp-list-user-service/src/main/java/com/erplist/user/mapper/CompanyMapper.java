package com.erplist.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.erplist.user.entity.Company;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/**
 * 公司 Mapper
 */
@Mapper
public interface CompanyMapper extends BaseMapper<Company> {

    /**
     * 所有已创建过的公司数量（含已逻辑删除），用于生成新公司 zid。
     * 规则：新 zid = countAll() + 1，保证 zid 单调递增且不重复。
     */
    @Select("SELECT COUNT(*) FROM company")
    int countAll();
}
