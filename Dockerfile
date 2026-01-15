# Stage 1: Builder - Compile and package WAR file
FROM maven:3.8-openjdk-8 AS builder

WORKDIR /app

# Copy pom.xml first for better layer caching
COPY pom.xml .

# Copy source code
COPY src ./src

# Build the WAR file
RUN mvn clean package -DskipTests

# Stage 2: Runtime - Tomcat server
FROM tomcat:9-jre8

# Create non-root user for security
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file from builder stage
COPY --from=builder /app/target/docker-java-sample-webapp-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Change ownership to non-root user
RUN chown -R tomcat:tomcat /usr/local/tomcat

# Switch to non-root user
USER tomcat

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

