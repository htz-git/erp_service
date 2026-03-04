package com.erplist.seller.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.erplist.seller.dto.SellerDTO;
import com.erplist.seller.dto.SellerQueryDTO;
import com.erplist.seller.entity.Seller;

/**
 * 店铺服务接口
 */
public interface SellerService {

    Seller createSeller(SellerDTO dto);

    Seller getSellerById(Long id);

    Seller updateSeller(Long id, SellerDTO dto);

    void deleteSeller(Long id);

    Page<Seller> querySellers(SellerQueryDTO queryDTO);

    void updateStatus(Long id, Integer status);

    /**
     * 按公司 zid 统计店铺数量（供管理端数据查看等内部调用，不校验当前用户 zid）
     *
     * @param zid 公司ID，为空时返回全平台店铺总数
     * @return 店铺数量
     */
    long countByZid(String zid);
}
