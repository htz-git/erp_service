package com.erplist.replenishment.client;

import com.erplist.replenishment.config.LstmForecastProperties;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

/**
 * 调用 LSTM 预测服务（Python）的 HTTP 客户端
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LstmForecastClient {

    private final RestTemplate restTemplate;
    private final LstmForecastProperties lstmProps;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final String PREDICT_PATH = "/predict";

    /**
     * 调用 LSTM 服务预测未来需求量
     *
     * @param series      每个 SKU 的历史销量序列，见 LSTM 服务 /predict 文档
     * @param forecastDays 预测天数
     * @return predictions 列表，每项含 skuId, skuCode, productName, productId, forecastTotal, forecastDaily
     */
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> predict(List<Map<String, Object>> series, int forecastDays) {
        String url = lstmProps.getServiceUrl().replaceAll("/$", "") + PREDICT_PATH;
        Map<String, Object> body = Map.of(
                "series", series,
                "forecastDays", forecastDays
        );
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        try {
            String response = restTemplate.postForObject(url, entity, String.class);
            if (response == null) {
                return List.of();
            }
            Map<String, Object> parsed = objectMapper.readValue(response, new TypeReference<Map<String, Object>>() {});
            Object predictions = parsed.get("predictions");
            if (predictions instanceof List) {
                return (List<Map<String, Object>>) predictions;
            }
            return List.of();
        } catch (Exception e) {
            log.warn("LSTM 预测服务调用失败: {} - {}", url, e.getMessage());
            return List.of();
        }
    }
}
