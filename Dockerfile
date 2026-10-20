# Bootstrap the source archive currently stored in the repository.
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY Roommate-Matcher.zip /tmp/roommate-matcher.zip
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && unzip -q /tmp/roommate-matcher.zip -d /workspace \
    && rm -rf /var/lib/apt/lists/* /tmp/roommate-matcher.zip
RUN mvn -q -f /workspace/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /workspace/build/roommate-matcher-for-friends.war ./build/roommate-matcher-for-friends.war
COPY --from=build /workspace/build/classes ./build/classes
COPY --from=build /workspace/src/main/webapp ./src/main/webapp
RUN useradd --system --uid 10001 --create-home appuser \
    && chown -R appuser:appuser /app
USER appuser
ENV PORT=8080
EXPOSE 8080
CMD ["java", "-cp", "build/classes:build/roommate-matcher-for-friends.war", "com.nestmates.EmbeddedServer"]
