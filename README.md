# ESP32Marauder Docker Builder

This project provides a fully automated and reproducible Docker-based build environment for compiling the ESP32Marauder firmware with support for board selection, custom overrides, and versioned output binaries.

---

## 🚀 Features

- Interactive board selection with optional `CUSTOM_MANUAL` override
- Automatic chip family detection based on board
- Support for both platform libraries and Git-based libraries
- Custom platform.txt overrides
- Clean `output/` before build using `./build.sh clean`
- Versioned output firmware based on `configs.h`
- Docker Compose-based build with optional full cleanup

---

## 📦 Prerequisites

- Docker (tested with version **28.0.4**)
- Git
- Bash (Linux/macOS or WSL)

---

## 🔧 Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/youruser/esp32marauder_builder.git
   cd esp32marauder_builder
   ```

2. Start the build:
   ```bash
   ./build.sh
   ```

3. Firmware files will be saved in the `output/` folder.

---

## 🧹 Cleaning

To clean up previous build artifacts:
```bash
./build.sh clean
```

To fully reset Docker build cache:
```bash
docker-compose down
docker builder prune --all
```

---

## ❗ Troubleshooting – Network Issues

If you see errors like:
```
Error installing LinkedList: dial tcp: lookup downloads.arduino.cc: i/o timeout
```

It's likely due to networking/DNS issues inside the Docker container. To resolve:

```bash
docker-compose down
docker builder prune --all
./build.sh
```

---

## ✅ Tested

- ✅ Board: `MARAUDER_FLIPPER`
- ✅ Docker: `version 28.0.4`
- ✅ Chip family: `esp32s2`

---

## 🧪 Sample Build Output

```
./build.sh
📥 Downloading board list...
🎯 Available boards:
...
🔧 Select target board: 10
✅ Selected: MARAUDER_FLIPPER
🔧 Chip family: esp32s2
🧱 Core version: 2.0.10
Building marauder-builder
...
esp32marauder_builder | 📦 FQBN: esp32:esp32:esp32s2
esp32marauder_builder | ⚙️ Compiling for board: MARAUDER_FLIPPER
esp32marauder_builder | Sketch uses 988742 bytes (75%) of program storage space.
esp32marauder_builder | Global variables use 63312 bytes (19%) of dynamic memory.
esp32marauder_builder | ℹ️  boot_app0.bin not found (possibly not required for this board)
```

---

## 📋 TODO

- [ ] Add ESP32 SPIFFS upload tool integration
- [ ] Full support/test of `CUSTOM_MANUAL` mode
