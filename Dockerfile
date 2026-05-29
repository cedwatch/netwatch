FROM node:18-alpine AS base
WORKDIR /app

# Install Ookla speedtest CLI - detect arch at build time
RUN ARCH=$(uname -m) && \
    BASE="https://install.speedtest.net/app/cli" && \
    if [ "$ARCH" = "aarch64" ]; then \
      PKG="ookla-speedtest-1.2.0-linux-aarch64.tgz"; \
    elif [ "$ARCH" = "armv7l" ]; then \
      PKG="ookla-speedtest-1.2.0-linux-armhf.tgz"; \
    else \
      PKG="ookla-speedtest-1.2.0-linux-x86_64.tgz"; \
    fi && \
    wget -qO /tmp/speedtest.tgz "$BASE/$PKG" && \
    tar -xzf /tmp/speedtest.tgz -C /tmp && \
    mv /tmp/speedtest /app/bin/speedtest && \
    chmod +x /app/bin/speedtest && \
    rm /tmp/speedtest.tgz

# Copy server
COPY server.js .

# Data directory (mounted as volume in production)
RUN mkdir -p /data

EXPOSE 5217

ENV NETWATCH_PORT=5217
ENV NETWATCH_DATA=/data

CMD ["node", "server.js"]
