FROM eclipse-temurin:17-jre
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8888
RUN apt-get update && apt-get install -y curl
ENTRYPOINT ["java", "-jar", "app.jar"]
