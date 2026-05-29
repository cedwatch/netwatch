FROM node:18-slim
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ookla speedtest CLI from official Debian package
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get install -y speedtest && \
    mkdir -p /app/bin && \
    cp $(which speedtest) /app/bin/speedtest && \
    rm -rf /var/lib/apt/lists/*

# Copy server
COPY server.js .

# Data directory (mounted as volume in production)
RUN mkdir -p /data

EXPOSE 5217

ENV NETWATCH_PORT=5217
ENV NETWATCH_DATA=/data

CMD ["node", "server.js"]

