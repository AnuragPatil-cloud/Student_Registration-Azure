# ============================================
# Stage 1: Build
# ============================================
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# ============================================
# Stage 2: Runtime
# ============================================
FROM eclipse-temurin:17-jre-alpine-3.24

WORKDIR /app

# Update Alpine security packages
RUN apk update && \
    apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

COPY --from=builder /app/target/*.jar app.jar

# Run as non-root user
RUN addgroup -S spring && \
    adduser -S spring -G spring

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
