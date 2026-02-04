package com.erplist.gateway.filter;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

/**
 * 从 Authorization Bearer 解析当前用户，调用用户服务 /users/current，
 * 将 user-id、user-zid 写入请求头再转发，供下游 UserInfoInterceptor 设置 UserContext。
 */
public class UserContextGatewayFilter implements GlobalFilter, Ordered {

    private static final String LOGIN_PATH = "/api/users/login";
    private static final String BEARER_PREFIX = "Bearer ";
    private static final String USER_SERVICE_ID = "erp-list-user-service";

    private final WebClient webClient;
    private final DiscoveryClient discoveryClient;

    public UserContextGatewayFilter(WebClient webClient, DiscoveryClient discoveryClient) {
        this.webClient = webClient;
        this.discoveryClient = discoveryClient;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        if (isLoginRequest(exchange)) {
            return chain.filter(exchange);
        }
        String auth = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (auth == null || !auth.startsWith(BEARER_PREFIX)) {
            return chain.filter(exchange);
        }
        return Mono.fromCallable(() -> discoveryClient.getInstances(USER_SERVICE_ID))
                .subscribeOn(Schedulers.boundedElastic())
                .filter(instances -> instances != null && !instances.isEmpty())
                .flatMap(instances -> {
                    ServiceInstance instance = instances.get(0);
                    String userServiceUrl = (instance.isSecure() ? "https" : "http") + "://" + instance.getHost() + ":" + instance.getPort() + "/users/current";
                    return webClient.get()
                .uri(userServiceUrl)
                .header(HttpHeaders.AUTHORIZATION, auth)
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .bodyToMono(JsonNode.class)
                .flatMap(body -> {
                    if (body == null || body.get("code") == null || body.get("code").asInt() != 200) {
                        return chain.filter(exchange);
                    }
                    JsonNode data = body.get("data");
                    if (data == null || data.isNull()) {
                        return chain.filter(exchange);
                    }
                    JsonNode idNode = data.get("id");
                    JsonNode zidNode = data.get("zid");
                    String userId = (idNode != null && !idNode.isNull()) ? idNode.asText() : null;
                    String zid = (zidNode != null && !zidNode.isNull()) ? zidNode.asText() : null;
                    if (userId == null && zid == null) {
                        return chain.filter(exchange);
                    }
                    ServerWebExchange newExchange = exchange.mutate()
                            .request(builder -> {
                                if (userId != null) {
                                    builder.header("user-id", userId);
                                }
                                if (zid != null) {
                                    builder.header("user-zid", zid);
                                }
                            })
                            .build();
                    return chain.filter(newExchange);
                })
                .onErrorResume(e -> chain.filter(exchange));
                })
                .switchIfEmpty(Mono.defer(() -> chain.filter(exchange)))
                .onErrorResume(e -> chain.filter(exchange));
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
