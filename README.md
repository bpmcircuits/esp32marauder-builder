
# 🛠 ESP32Marauder Docker Builder

This project provides a convenient Docker-based build system for compiling firmware from the [ESP32Marauder](https://github.com/justcallmekoko/ESP32Marauder) repository.

It allows for fast selection of a supported board or using your own `CUSTOM_MANUAL` configuration.

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

## 🧩 Board selection

The `build.sh` script automatically downloads the latest `configs.h` file from the upstream ESP32Marauder repository. It extracts supported board options from this file and lets you select one from an interactive list.

You can also choose `CUSTOM_MANUAL` which:
- Does not modify `configs.h`
- Requires you to manually adjust the config and board definitions
- Automatically applies overrides from the local `custom/` directory (if it exists)
- Asks you to manually pick the ESP32 chip family (`esp32`, `esp32s2`, etc.)

---

## ⚙️ Configuration Files

- `libs.txt`: Arduino libraries to install via `arduino-cli`
- `libs_git.txt`: External libraries in the format `GIT_URL@VERSION`
- `platform.txt`: Overrides the ESP32 platform settings during build

---

## 🧹 Cleaning

To clean the output directory before a new build, run:
```bash
./build.sh clean
```

To clean Docker cache completely:
```bash
docker-compose down
docker builder prune --all
```

---

## 🐛 Troubleshooting

If the build fails due to internet/DNS errors when installing libraries (e.g. `i/o timeout`):
```
Error installing LinkedList: dial tcp: lookup downloads.arduino.cc: i/o timeout
```
try cleaning and rebuilding
```bash
./build.sh clean
docker builder prune --all
./build.sh
```

---

## ✅ Tested On

- Docker version: `28.0.4`
- Confirmed working board: `MARAUDER_FLIPPER` (ESP32-S2)

---

## 📄 TODO

- Add ESP32 SPIFFS tool support
- Test `CUSTOM_MANUAL` configuration in full

---

## 📋 Sample successful build log

```
./build.sh
📥 Downloading board list...
🎯 Available boards:
1) MARAUDER_M5STICKC         4) MARAUDER_V4              7) MARAUDER_V7             10) MARAUDER_FLIPPER        13) XIAO_ESP32_S3
2) MARAUDER_M5STICKCP2       5) MARAUDER_V6              8) MARAUDER_KIT            11) ESP32_LDDB              14) MARAUDER_REV_FEATHER
3) MARAUDER_MINI             6) MARAUDER_V6_1            9) GENERIC_ESP32           12) MARAUDER_DEV_BOARD_PRO  15) CUSTOM_MANUAL
🔧 Select target board: 10
✅ Selected: MARAUDER_FLIPPER
🔧 Chip family: esp32s2
🧱 Core version: 2.0.10
Building marauder-builder
[+] Building 112.4s (18/18) FINISHED                                                                                                             docker:default
 => [internal] load build definition from Dockerfile                                                                                                       0.0s
 => => transferring dockerfile: 1.71kB                                                                                                                     0.0s
 => [internal] load metadata for docker.io/library/ubuntu:22.04                                                                                            1.1s
 => [internal] load .dockerignore                                                                                                                          0.0s
 => => transferring context: 2B                                                                                                                            0.0s
 => [ 1/13] FROM docker.io/library/ubuntu:22.04@sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3                                    0.1s
 => => resolve docker.io/library/ubuntu:22.04@sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3                                      0.0s
 => => sha256:a76d0e9d99f0e91640e35824a6259c93156f0f07b7778ba05808c750e7fa6e68 424B / 424B                                                                 0.0s
 => => sha256:cc934a90cd99a939f3922f858ac8f055427300ee3ee4dfcd303c53e571d0aeab 2.30kB / 2.30kB                                                             0.0s
 => => sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3 6.69kB / 6.69kB                                                             0.0s
 => [internal] load build context                                                                                                                          0.1s
 => => transferring context: 92.89kB                                                                                                                       0.0s
 => [ 2/13] RUN apt-get update && apt-get install -y     curl unzip git xz-utils python3 python3-pip     gcc make jq sed && rm -rf /var/lib/apt/lists/*   37.6s
 => [ 3/13] RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh                                                    2.2s
 => [ 4/13] RUN arduino-cli config init &&     arduino-cli core update-index &&     arduino-cli core install esp32:esp32@2.0.10                           35.3s
 => [ 5/13] COPY libs.txt /tmp/libs.txt                                                                                                                    0.1s
 => [ 6/13] RUN cat /tmp/libs.txt | xargs -I{} arduino-cli lib install "{}"                                                                                8.2s
 => [ 7/13] COPY libs_git.txt /tmp/libs_git.txt                                                                                                            0.1s
 => [ 8/13] RUN mkdir -p /root/Arduino/libraries && cd /root/Arduino/libraries &&     while IFS=@ read -r REPO VERSION; do         DIR=$(basename "$REPO"  2.4s
 => [ 9/13] RUN pip3 install pyserial                                                                                                                      1.0s
 => [10/13] RUN rm -rf /project/ESP32Marauder &&     git clone --depth=1 https://github.com/justcallmekoko/ESP32Marauder.git /project/ESP32Marauder &&    16.8s
 => [11/13] WORKDIR /project                                                                                                                               0.0s
 => [12/13] COPY platform.txt /root/.arduino15/packages/esp32/hardware/esp32/2.0.10/platform.txt                                                           0.1s
 => [13/13] RUN chmod +r /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino                                                                          0.3s
 => exporting to image                                                                                                                                     6.9s
 => => exporting layers                                                                                                                                    6.9s
 => => writing image sha256:bcda92a7cbf881152e3e461d287552edb1a87997b89b489df0110692f4007798                                                               0.0s
 => => naming to docker.io/library/esp32marauder_builder_marauder-builder                                                                                  0.0s
Creating network "esp32marauder_builder_default" with the default driver
Creating esp32marauder_builder ... done
Attaching to esp32marauder_builder
esp32marauder_builder | 📦 FQBN: esp32:esp32:esp32s2
esp32marauder_builder | ⚙️ Compiling for board: MARAUDER_FLIPPER
esp32marauder_builder | Sketch uses 988742 bytes (75%) of program storage space. Maximum is 1310720 bytes.
esp32marauder_builder | Global variables use 63312 bytes (19%) of dynamic memory, leaving 264368 bytes for local variables. Maximum is 327680 bytes.
esp32marauder_builder | ℹ️  boot_app0.bin not found (possibly not required for this board)
esp32marauder_builder exited with code 0
```

---
