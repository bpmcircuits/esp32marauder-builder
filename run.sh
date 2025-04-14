#!/bin/bash

if [ ! -f /project/platform.txt ]; then
  echo "❌ platform.txt not found in /project"
  exit 1
fi

cp /project/platform.txt /root/.arduino15/packages/esp32/hardware/esp32/$ESP32_VERSION/platform.txt

FQBN="esp32:esp32:$ESP32_CHIP"
echo "📦 FQBN: $FQBN"
echo "⚙️ Compiling for board: $MARAUDER_BOARD"

arduino-cli compile \
  --fqbn "$FQBN" \
  --output-dir /project/output \
  /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino || exit 1

VERSION=$(grep '#define MARAUDER_VERSION' /project/ESP32Marauder/esp32_marauder/configs.h | cut -d'"' -f2)

cp /project/output/esp32_marauder.ino.bin /project/output/firmware_${MARAUDER_BOARD}_${VERSION}.bin
cp /project/output/esp32_marauder.ino.bootloader.bin /project/output/bootloader_${MARAUDER_BOARD}_${VERSION}.bin
cp /project/output/esp32_marauder.ino.partitions.bin /project/output/partitions_${MARAUDER_BOARD}_${VERSION}.bin
if [ -f /project/output/boot_app0.bin ]; then
  cp /project/output/boot_app0.bin /project/output/boot_app0_${MARAUDER_BOARD}_${VERSION}.bin
else
  echo "ℹ️  boot_app0.bin not found (possibly not required for this board)"
fi
