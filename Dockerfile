FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      unzip \
      p7zip-full \
      libc6-i386 \
      libdbus-1-3:i386 \
      libunwind8:i386 \
      libatomic1:i386 \
      libfreetype6:i386 \
      libsdl2-2.0-0:i386 \
      libsdl2-ttf-2.0-0:i386 \
      libstdc++6:i386 \
      libgl1:i386 \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh

RUN chmod +x /start.sh

WORKDIR /server

CMD ["/start.sh"]
