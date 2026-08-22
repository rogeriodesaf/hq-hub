FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn package -DskipTests

FROM eclipse-temurin:21-jre

WORKDIR /app

# O limite padrao da JVM usa apenas uma fracao pequena da memoria do conteiner.
# Mantemos folga para memoria nativa do Quarkus/Vert.x e encerramos de forma
# limpa se o heap se esgotar, permitindo que a plataforma reinicie a instancia.
ENV JAVA_TOOL_OPTIONS="-XX:InitialRAMPercentage=20 -XX:MaxRAMPercentage=65 -XX:+ExitOnOutOfMemoryError"

COPY --from=build /app/target/quarkus-app/ ./quarkus-app/

EXPOSE 8080

CMD ["java", "-jar", "quarkus-app/quarkus-run.jar"]
