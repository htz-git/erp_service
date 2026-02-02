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
}
