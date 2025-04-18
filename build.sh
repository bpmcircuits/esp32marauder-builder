#!/usr/bin/env bash

set -e

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

# Extract boards from configs.h
boards=$(awk '/\/\/\/ BOARD TARGETS/,/\/\/\/ END BOARD TARGETS/' "$TMP_CONFIG" \
  | grep '^[[:space:]]*//#define' \
  | sed 's|^[[:space:]]*//#define ||')

IFS=$'\n' read -r -d '' -a options_array < <(printf "%s\n" $boards "CUSTOM_MANUAL" "CUSTOM_AUTO" && printf '\0')

echo "🎯 Available boards:"
PS3="🔧 Select target board: "
select opt in "${options_array[@]}"; do
    if [[ -n "$opt" ]]; then
        echo "✅ Selected: $opt"
        SELECTED_TYPE="$opt"
        break
    else
        echo "❌ Invalid choice"
    fi
done

# --- Default board type ---
IS_CUSTOM_AUTO="false"

# Define chip mappings
declare -A BOARD_CHIP_MAP=(
  [MARAUDER_FLIPPER]="esp32s2"
  [XIAO_ESP32_S3]="esp32s3"
  [MARAUDER_REV_FEATHER]="esp32s3"
)

# --- Handle CUSTOM_MANUAL ---
if [[ "$SELECTED_TYPE" == "CUSTOM_MANUAL" ]]; then
  echo "🛠️ CUSTOM_MANUAL selected. Manual override expected."

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

  MARAUDER_BOARD="$SELECTED_TYPE"

# --- Handle CUSTOM_AUTO ---
elif [[ "$SELECTED_TYPE" == "CUSTOM_AUTO" ]]; then
  IS_CUSTOM_AUTO="true"
  CUSTOM_DIR="./custom_boards"
  custom_boards=()

  echo "🔍 Searching for custom boards in $CUSTOM_DIR"
  if [[ ! -d "$CUSTOM_DIR" ]]; then
    echo "❌ Directory $CUSTOM_DIR not found!"
    exit 1
  fi

  while IFS= read -r -d '' dir; do
    custom_boards+=("$(basename "$dir")")
  done < <(find "$CUSTOM_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

  if [[ ${#custom_boards[@]} -eq 0 ]]; then
    echo "❌ No custom boards found in $CUSTOM_DIR"
    exit 1
  fi

  echo "📦 Available custom boards:"
  select selected_custom in "${custom_boards[@]}"; do
    if [[ -n "$selected_custom" ]]; then
      MARAUDER_BOARD="$selected_custom"
      echo "✅ Selected: $MARAUDER_BOARD"
      break
    else
      echo "❌ Invalid choice"
    fi
  done

  CHIP_FILE="$CUSTOM_DIR/$MARAUDER_BOARD/chip.txt"
  manual_select=false

  if [[ -f "$CHIP_FILE" ]]; then
    chip_value=$(<"$CHIP_FILE")
    chip_value="${chip_value,,}"
    if [[ "$chip_value" =~ ^esp32(s2|s3|c3)?$ ]]; then
      ESP32_CHIP="$chip_value"
      echo "🔎 Detected chip from chip.txt: $ESP32_CHIP"
    else
      echo "⚠️ Invalid chip value in chip.txt: '$chip_value'"
      manual_select=true
    fi
  else
    echo "📭 chip.txt not found in $CHIP_FILE"
    manual_select=true
  fi

  if [[ "$manual_select" == true ]]; then
    echo "🔢 Select chip family manually:"
    chips=("esp32" "esp32s2" "esp32s3" "esp32c3")
    select chip in "${chips[@]}"; do
        if [[ -n "$chip" ]]; then
            ESP32_CHIP="$chip"
            break
        else
            echo "❌ Invalid chip"
        fi
    done
  fi

# --- Handle standard boards ---
else
  MARAUDER_BOARD="$SELECTED_TYPE"
  ESP32_CHIP="${BOARD_CHIP_MAP[$MARAUDER_BOARD]:-esp32}"
fi

# 🧾 Final summary
echo "📦 Board: $MARAUDER_BOARD"
echo "🔧 Chip family: $ESP32_CHIP"
echo "🧱 Core version: $ESP32_VERSION"
echo "🧩 Custom auto mode: $IS_CUSTOM_AUTO"

# 🐳 Docker Compose build
ESP32_VERSION="$ESP32_VERSION" \
ESP32_CHIP="$ESP32_CHIP" \
MARAUDER_BOARD="$MARAUDER_BOARD" \
IS_CUSTOM_AUTO="$IS_CUSTOM_AUTO" \
docker-compose build \
  --build-arg ESP32_VERSION="$ESP32_VERSION" \
  --build-arg ESP32_CHIP="$ESP32_CHIP" \
  --build-arg MARAUDER_BOARD="$MARAUDER_BOARD" \
  --build-arg IS_CUSTOM_AUTO="$IS_CUSTOM_AUTO"

# ▶️ Run container
ESP32_VERSION="$ESP32_VERSION" \
ESP32_CHIP="$ESP32_CHIP" \
MARAUDER_BOARD="$MARAUDER_BOARD" \
IS_CUSTOM_AUTO="$IS_CUSTOM_AUTO" \
docker-compose up
