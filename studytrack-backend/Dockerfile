# ---- Build Stage ----
FROM eclipse-temurin:21-jdk as build
WORKDIR /app
COPY . .
ENV DOCKER=true
RUN ./gradlew build --no-daemon
RUN chmod +x ./gradlew



# ---- Package Stage ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"] 
