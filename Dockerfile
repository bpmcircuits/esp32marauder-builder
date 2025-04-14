FROM ubuntu:22.04

ARG ESP32_VERSION
ARG ESP32_CHIP
ARG MARAUDER_BOARD

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils python3 python3-pip \
    gcc make jq sed && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
ENV PATH="/root/bin:$PATH"
ARG ESP32_VERSION
ARG ESP32_CHIP
ARG MARAUDER_BOARD

RUN arduino-cli config init && \
    arduino-cli core update-index && \
    arduino-cli core install esp32:esp32@${ESP32_VERSION}

COPY libs.txt /tmp/libs.txt
RUN grep -v '^#' /tmp/libs.txt | grep -v '^\s*$' | while read lib; do \
      echo "📦 Installing $lib..."; \
      until arduino-cli lib install "$lib"; do \
        echo "🔁 Retrying $lib in 5s..."; sleep 5; \
      done; \
    done

COPY libs_git.txt /tmp/libs_git.txt
RUN mkdir -p /root/Arduino/libraries && cd /root/Arduino/libraries && \
    while IFS=@ read -r REPO VERSION; do \
        DIR=$(basename "$REPO" .git); \
        echo "⬇️ Cloning $DIR@$VERSION..."; \
        git clone "$REPO" "$DIR" || exit 1 && \
        cd "$DIR" && git checkout "$VERSION" || exit 1 && cd ..; \
    done < /tmp/libs_git.txt

RUN pip3 install pyserial

RUN rm -rf /project/ESP32Marauder && \
    git clone --depth=1 https://github.com/justcallmekoko/ESP32Marauder.git /project/ESP32Marauder && \
    if [ "$MARAUDER_BOARD" != "CUSTOM_MANUAL" ]; then \
      sed -i "s|//#define ${MARAUDER_BOARD}|#define ${MARAUDER_BOARD}|" /project/ESP32Marauder/esp32_marauder/configs.h; \
    else \
      echo "Copying custom/ overrides..." && \
      cp -r /project/custom/* /project/ESP32Marauder/esp32_marauder/; \
    fi

WORKDIR /project
COPY platform.txt /root/.arduino15/packages/esp32/hardware/esp32/${ESP32_VERSION}/platform.txt
RUN chmod +r /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino
