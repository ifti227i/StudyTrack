# ---- Build Stage ----
FROM openjdk:21-jdk as build
WORKDIR /app
COPY target/studytrack-backend-0.0.1-SNAPSHOT.jar app.jar

# Copy only gradlew and make it executable first
COPY gradlew .
RUN chmod +x gradlew

# Now copy the rest of the files
COPY pubspec.yaml pubspec.yaml
COPY pubspec.lock pubspec.lock
RUN dart pub get
COPY . .

RUN ./gradlew build --no-daemon

# ---- Package Stage ----
FROM openjdk:21-jdk
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"] 
