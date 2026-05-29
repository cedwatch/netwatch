FROM node:18-slim
WORKDIR /app

# Install only wget and ca-certificates (minimal)
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy server and init script
COPY server.js .
COPY docker-init.sh .
RUN chmod +x docker-init.sh

# Data and bin directories
RUN mkdir -p /data /app/bin

EXPOSE 5217

ENV NETWATCH_PORT=5217
ENV NETWATCH_DATA=/data

# Init script downloads Ookla at first run, then starts server
CMD ["bash", "docker-init.sh"]
