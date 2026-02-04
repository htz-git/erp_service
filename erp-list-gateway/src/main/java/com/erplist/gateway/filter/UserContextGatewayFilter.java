package com.erplist.gateway.filter;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

/**
 * 确保下游请求带 user-id、user-zid：
 * 1) 若请求头已有（前端传入），则显式写入转发请求，保证下游能收到；
 * 2) 否则通过 Nacos lb 调用户服务 /users/current 解析并写入。
 * 断点需打在「网关进程」(端口 8080)，请求必须经网关转发才会进入此过滤器。
 */
@Component
public class UserContextGatewayFilter implements GlobalFilter, Ordered {

    private static final String LOGIN_PATH = "/api/users/login";
    private static final String BEARER_PREFIX = "Bearer ";
    private static final String USER_SERVICE_URI = "lb://erp-list-user-service/users/current";

    private final WebClient webClient;

    public UserContextGatewayFilter(WebClient loadBalancedWebClient) {
        this.webClient = loadBalancedWebClient;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        if (isLoginRequest(exchange)) {
            return chain.filter(exchange);
        }
        // 仅当请求头同时带有 user-id 和 user-zid 时直接转发，避免缺 zid 导致下游“未登录或缺少租户信息”
        String fromHeaderUserId = exchange.getRequest().getHeaders().getFirst("user-id");
        String fromHeaderZid = exchange.getRequest().getHeaders().getFirst("user-zid");
        if (fromHeaderUserId != null && fromHeaderZid != null
                && !fromHeaderUserId.trim().isEmpty() && !fromHeaderZid.trim().isEmpty()) {
            ServerHttpRequest mutated = exchange.getRequest().mutate()
                    .headers(h -> {
                        h.set("user-id", fromHeaderUserId);
                        h.set("user-zid", fromHeaderZid);
                    })
                    .build();
            return chain.filter(exchange.mutate().request(mutated).build());
        }
        // 否则通过 token 调用户服务解析，保证下游一定有 user-id、user-zid
        String auth = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (auth == null || !auth.startsWith(BEARER_PREFIX)) {
            return chain.filter(exchange);
        }
        return webClient.get()
                .uri(USER_SERVICE_URI)
                .header(HttpHeaders.AUTHORIZATION, auth)
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .bodyToMono(JsonNode.class)
                .flatMap(body -> applyUserHeadersAndContinue(exchange, chain, body))
                .onErrorResume(e -> chain.filter(exchange));
    }

    private Mono<Void> applyUserHeadersAndContinue(ServerWebExchange exchange, GatewayFilterChain chain, JsonNode body) {
        if (body == null || body.get("code") == null || body.get("code").asInt() != 200) {
            return chain.filter(exchange);
        }
        JsonNode data = body.get("data");
        if (data == null || data.isNull()) {
            return chain.filter(exchange);
        }
        String userId = textFromNode(data.get("id"));
        String zid = textFromNode(data.get("zid"));
        if (userId == null && zid == null) {
            return chain.filter(exchange);
        }
        ServerHttpRequest mutatedRequest = exchange.getRequest().mutate()
                .headers(headers -> {
                    if (userId != null) headers.set("user-id", userId);
                    if (zid != null) headers.set("user-zid", zid);
                })
                .build();
        return chain.filter(exchange.mutate().request(mutatedRequest).build());
    }

    private static String textFromNode(JsonNode node) {
        if (node == null || node.isNull()) {
            return null;
        }
        if (node.isNumber()) {
            return String.valueOf(node.asLong());
        }
        return node.asText();
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE + 100;
    }

    private boolean isLoginRequest(ServerWebExchange exchange) {
        var method = exchange.getRequest().getMethod();
        var path = exchange.getRequest().getPath().value();
        return method != null && "POST".equalsIgnoreCase(method.name())
                && LOGIN_PATH.equals(path);
    }
}
