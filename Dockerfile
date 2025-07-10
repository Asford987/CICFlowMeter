# Use an official OpenJDK image
FROM openjdk:8-jdk-slim

# Set working directory
WORKDIR /app

# Install git and Gradle dependencies
RUN apt-get update && apt-get install -y git unzip curl && rm -rf /var/lib/apt/lists/*


# Copy the local code into the image
COPY CICFlowMeter/ .

COPY send_to_rabbitmq.py .

RUN chmod +x /app/watchdog.sh


# Download Gradle wrapper if missing
RUN chmod +x gradlew

# Build the project
RUN ./gradlew build

# Expose volume for input and output
VOLUME ["/pcaps", "/flows"]

ENV PCAPS_DIR=/pcaps
ENV FLOWS_DIR=/flows
ENV DELAY=5

# Default command to run (can be overridden)
CMD ["/app/watchdog.sh"]
