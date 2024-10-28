FROM maven:latest as build

WORKDIR /app

COPY . . 

RUN mvn clean install

FROM eclipse-temurin:23-jre-ubi9-minimal

WORKDIR /app

COPY --from=build /app/target/demoapp.jar /app

EXPOSE 8080

CMD [ "java", "-jar", "demoapp.jar" ]
