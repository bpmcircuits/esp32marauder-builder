#!/bin/bash

ESP32_VERSION="${ESP32_VERSION:-2.0.10}"
CONFIG_URL="https://raw.githubusercontent.com/justcallmekoko/ESP32Marauder/master/esp32_marauder/configs.h"
TMP_CONFIG="/tmp/configs_temp.h"

if [[ "$1" == "clean" ]]; then
  echo "🧹 Cleaning output/ folder and removing Docker build cache..."
  rm -rf output/*
  docker-compose down
  docker builder prune --all -f
  exit 0
fi

echo "📥 Downloading board list..."
curl -s "$CONFIG_URL" > "$TMP_CONFIG"

boards=$(awk '/\/\/\/ BOARD TARGETS/,/\/\/\/ END BOARD TARGETS/' "$TMP_CONFIG" \
  | grep '^[[:space:]]*//#define' \
  | sed 's|^[[:space:]]*//#define ||')

options_array=($boards "CUSTOM_MANUAL")

echo "🎯 Available boards:"
PS3="🔧 Select target board: "
select opt in "${options_array[@]}"; do
    if [[ -n "$opt" ]]; then
        echo "✅ Selected: $opt"
        MARAUDER_BOARD="$opt"
        break
    else
        echo "❌ Invalid choice"
    fi
done

# Chip mappings
declare -A BOARD_CHIP_MAP=(
  [MARAUDER_FLIPPER]="esp32s2"
  [XIAO_ESP32_S3]="esp32s3"
  [MARAUDER_REV_FEATHER]="esp32s3"
)

if [[ "$MARAUDER_BOARD" == "CUSTOM_MANUAL" ]]; then
  echo "🛠️ CUSTOM_MANUAL selected. You must override configs manually."

  echo "🔢 Select chip family:"
  chips=("esp32" "esp32s2" "esp32s3" "esp32c3")
  select chip in "${chips[@]}"; do
      if [[ -n "$chip" ]]; then
          ESP32_CHIP="$chip"
          break
      else
          echo "❌ Invalid chip"
      fi
  done
else
  ESP32_CHIP="${BOARD_CHIP_MAP[$MARAUDER_BOARD]:-esp32}"
fi

echo "🔧 Chip family: $ESP32_CHIP"
echo "🧱 Core version: $ESP32_VERSION"

# Run build
ESP32_VERSION="$ESP32_VERSION" \
ESP32_CHIP="$ESP32_CHIP" \
MARAUDER_BOARD="$MARAUDER_BOARD" \
docker-compose build \
  --build-arg ESP32_VERSION="$ESP32_VERSION" \
  --build-arg ESP32_CHIP="$ESP32_CHIP" \
  --build-arg MARAUDER_BOARD="$MARAUDER_BOARD"

# Run container
ESP32_VERSION="$ESP32_VERSION" \
ESP32_CHIP="$ESP32_CHIP" \
MARAUDER_BOARD="$MARAUDER_BOARD" \
docker-compose up
