package com.erplist.purchase.dto;

import lombok.Data;

import javax.validation.Valid;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * 根据补货建议生成采购单请求
 */
@Data
public class CreatePurchaseFromSuggestionsRequest {
    @NotNull(message = "供应商ID不能为空")
    private Long supplierId;

    @NotEmpty(message = "补货建议列表不能为空")
    @Valid
    private List<SuggestionItemDTO> suggestions;
}
