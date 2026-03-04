package com.erplist.api.client;

import com.erplist.common.result.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 店铺服务 Feign 客户端（供用户服务管理端数据查看按 zid 统计店铺数）
 */
@FeignClient(name = "erp-list-seller-service", contextId = "sellerClient", configuration = com.erplist.api.config.DefaultFeignConfig.class)
public interface SellerClient {

    /**
     * 按公司 zid 统计店铺数量（内部接口，仅由管理端数据查看调用）
     *
     * @param zid 公司ID，不传则返回全平台店铺总数
     * @return 店铺数量
     */
    @GetMapping("/sellers/count")
    Result<Long> countByZid(@RequestParam(value = "zid", required = false) String zid);
}
