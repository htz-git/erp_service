package com.erplist.replenishment.service;

import com.erplist.replenishment.dto.ReplenishmentSuggestionDTO;
import com.erplist.replenishment.dto.ReplenishmentSuggestionQueryDTO;

import java.util.List;

/**
 * 补货建议服务（基于 LSTM 对订单销售时序的预测）
 */
public interface ReplenishmentSuggestionService {

    /**
     * 根据当前用户（zid/sid）的历史订单销售数据，通过 LSTM 预测未来需求量并给出补货建议
     *
     * @param queryDTO 查询参数（历史日期范围、预测天数等），可为 null 使用默认
     * @return 每个 SKU 的补货建议列表
     */
    List<ReplenishmentSuggestionDTO> getSuggestions(ReplenishmentSuggestionQueryDTO queryDTO);
}
