# ---- Build Stage ----
FROM eclipse-temurin:21-jdk as build
WORKDIR /app

# Copy only gradlew and make it executable first
COPY gradlew .
RUN chmod +x gradlew

# Now copy the rest of the files
COPY . .

RUN ./gradlew build --no-daemon

# ---- Package Stage ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"] 
