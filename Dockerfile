FROM ubuntu:22.04

ARG ESP32_VERSION
ARG ESP32_CHIP
ARG MARAUDER_BOARD
ARG IS_CUSTOM_AUTO

ENV PATH="/root/bin:$PATH"

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils python3 python3-pip \
    gcc make jq sed && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

RUN arduino-cli config init && \
    arduino-cli core update-index && \
    arduino-cli core install esp32:esp32@${ESP32_VERSION}

COPY libs.txt /tmp/default_libs.txt
COPY libs_git.txt /tmp/default_libs_git.txt
COPY custom_boards/ /tmp/custom_boards/

RUN if [[ "$IS_CUSTOM_AUTO" == "true" ]]; then \
      echo "📥 Using custom libs.txt for $MARAUDER_BOARD"; \
      cp /tmp/custom_boards/$MARAUDER_BOARD/libs.txt /tmp/libs.txt || cp /tmp/default_libs.txt /tmp/libs.txt; \
    else \
      echo "📥 Using default libs.txt"; \
      cp /tmp/default_libs.txt /tmp/libs.txt; \
    fi

RUN grep -v '^#' /tmp/libs.txt | grep -v '^\s*$' | while read lib; do \
      echo "📦 Installing $lib..."; \
      until arduino-cli lib install "$lib"; do \
        echo "🔁 Retrying $lib in 5s..."; sleep 5; \
      done; \
    done

RUN if [[ "$IS_CUSTOM_AUTO" == "true" ]]; then \
      echo "📥 Using custom libs_git.txt for $MARAUDER_BOARD"; \
      cp /tmp/custom_boards/$MARAUDER_BOARD/libs_git.txt /tmp/libs_git.txt || cp /tmp/default_libs_git.txt /tmp/libs_git.txt; \
    else \
      echo "📥 Using default libs_git.txt"; \
      cp /tmp/default_libs_git.txt /tmp/libs_git.txt; \
    fi

RUN mkdir -p /root/Arduino/libraries && cd /root/Arduino/libraries && \
    while IFS=@ read -r REPO VERSION; do \
        DIR=$(basename "$REPO" .git); \
        echo "⬇️ Cloning $DIR@$VERSION..."; \
        git clone "$REPO" "$DIR" || exit 1 && \
        cd "$DIR" && git checkout "$VERSION" || exit 1 && cd ..; \
    done < /tmp/libs_git.txt

RUN pip3 install pyserial

RUN set -ex && \
    rm -rf /project/ESP32Marauder && \
    mkdir -p /project && \
    echo "Cloning ESP32Marauder repository..." && \
    git clone --depth=1 https://github.com/justcallmekoko/ESP32Marauder.git /project/ESP32Marauder || { echo "Git clone failed!"; exit 1; } && \
    if [[ "$MARAUDER_BOARD" != "CUSTOM_MANUAL" ]]; then \
      echo "🧠 Enabling board macro: $MARAUDER_BOARD"; \
      ls -la /project/ESP32Marauder/esp32_marauder/ || { echo "Directory listing failed!"; exit 1; } && \
      sed -i "s|//#define ${MARAUDER_BOARD}|#define ${MARAUDER_BOARD}|" /project/ESP32Marauder/esp32_marauder/configs.h || { echo "Sed command failed!"; exit 1; }; \
    else \
      echo "📂 Copying manual overrides..."; \
      cp -r /project/custom/* /project/ESP32Marauder/esp32_marauder/; \
    fi

RUN set -ex && \
    if [[ "$IS_CUSTOM_AUTO" == "true" ]]; then \
      echo "🚀 Running inject.py for $MARAUDER_BOARD" && \
      mkdir -p /project/output && \
      echo "📂 Checking directory structure:" && \
      ls -la /project/ && \
      echo "📂 Checking ESP32Marauder directory:" && \
      ls -la /project/ESP32Marauder/ && \
      echo "📂 Checking esp32_marauder directory:" && \
      ls -la /project/ESP32Marauder/esp32_marauder/ && \
      echo "📂 Checking custom boards directory:" && \
      ls -la /tmp/custom_boards/$MARAUDER_BOARD/ && \
      echo "📄 Checking inject.py:" && \
      cat /tmp/custom_boards/$MARAUDER_BOARD/inject.py | head -n 50 && \
      echo "📄 Checking configs.h exists:" && \
      ls -la /project/ESP32Marauder/esp32_marauder/configs.h || echo "⚠️ configs.h not found!" && \
      echo "📄 Checking WiFiScan.cpp exists:" && \
      ls -la /project/ESP32Marauder/esp32_marauder/WiFiScan.cpp || echo "⚠️ WiFiScan.cpp not found!" && \
      echo "🚀 Executing inject.py:" && \
      python3 /tmp/custom_boards/$MARAUDER_BOARD/inject.py --all > /project/output/inject.log 2>&1 || { \
        echo "❌ inject.py failed. Showing error log:" && \
        cat /project/output/inject.log && \
        exit 1; \
      } && \
      echo "✅ Injection completed successfully"; \
    else \
      echo "🧘 Skipping inject.py – IS_CUSTOM_AUTO != true"; \
    fi

RUN if [[ -f /project/output/inject.log ]]; then \
      echo "🪵 Injection log:" && cat /project/output/inject.log; \
    else \
      echo "📭 No inject log found."; \
    fi

RUN mkdir -p /root/.arduino15/packages/esp32/hardware/esp32/${ESP32_VERSION}
COPY platform.txt /root/.arduino15/packages/esp32/hardware/esp32/${ESP32_VERSION}/platform.txt

WORKDIR /project

RUN if [[ -f /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino ]]; then \
      chmod +r /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino; \
    fi
