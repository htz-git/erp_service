# 通用 Java 服务镜像：构建时需在对应模块目录下，且已执行 mvn package
# 用法示例：在项目根目录执行
#   docker build -f docker/Dockerfile.java -t erp-list-user-service --build-arg JAR_PATH=erp-list-user-service/target/erp-list-user-service.jar .
FROM eclipse-temurin:11-jre-alpine
ARG JAR_PATH
COPY ${JAR_PATH} app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
