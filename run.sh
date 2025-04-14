#!/bin/bash

set -e

# Check if platform.txt exists
if [ ! -f /project/platform.txt ]; then
  echo "❌ platform.txt not found in /project"
  exit 1
fi

# Override platform.txt
cp /project/platform.txt "/root/.arduino15/packages/esp32/hardware/esp32/${ESP32_VERSION}/platform.txt"

# Build info
FQBN="esp32:esp32:$ESP32_CHIP"
echo "📦 FQBN: $FQBN"
echo "⚙️  Compiling for board: $MARAUDER_BOARD"

# Compile
arduino-cli compile \
  --fqbn "$FQBN" \
  --output-dir /project/output \
  /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino

# Extract version
VERSION=$(grep '#define MARAUDER_VERSION' /project/ESP32Marauder/esp32_marauder/configs.h | cut -d'"' -f2)
DATE=$(date +%Y%m%d)
BOARD_TAG=$(echo "$MARAUDER_BOARD" | tr '[:upper:]' '[:lower:]')

# Output file
FINAL_BIN="esp32_marauder_${VERSION}_${DATE}_${BOARD_TAG}.bin"

# Copy final binary
cp /project/output/esp32_marauder.ino.bin "/project/output/$FINAL_BIN"
echo "✅ Firmware output: output/$FINAL_BIN"

# Optional: report if app0 is missing (non-fatal)
if [ ! -f /project/output/boot_app0.bin ]; then
  echo "ℹ️  boot_app0.bin not found (possibly not required for this board)"
fi
