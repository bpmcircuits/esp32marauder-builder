<p align="center">
  <a href="https://github.com/Nigdzie/esp32marauder-builder/actions">
    <img alt="Build Status" src="https://github.com/Nigdzie/esp32marauder-builder/actions/workflows/build.yml/badge.svg">
  </a>
  <a href="https://hits.sh/github.com/Nigdzie/esp32marauder-builder/">
    <img alt="Hits" src="https://hits.sh/github.com/Nigdzie/esp32marauder-builder.svg">
  </a>
  <a href="https://github.com/Nigdzie/esp32marauder-builder/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/Nigdzie/esp32marauder-builder">
  </a>
  <a href="https://github.com/Nigdzie/esp32marauder-builder/pulls">
    <img alt="Pull Requests" src="https://img.shields.io/github/issues-pr/Nigdzie/esp32marauder-builder">
  </a>
  <a href="https://github.com/Nigdzie/esp32marauder-builder/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/Nigdzie/esp32marauder-builder">
  </a>
  <a href="https://github.com/Nigdzie/esp32marauder-builder">
    <img alt="Repo Size" src="https://img.shields.io/github/repo-size/Nigdzie/esp32marauder-builder">
  </a>
  <a href="https://github.com/Nigdzie/esp32marauder-builder/commits/main">
    <img alt="Last Commit" src="https://img.shields.io/github/last-commit/Nigdzie/esp32marauder-builder">
  </a>
</p>

---
# 🛠 ESP32Marauder Docker Builder

This project provides a convenient Docker-based build system for compiling firmware from the [ESP32Marauder](https://github.com/justcallmekoko/ESP32Marauder) repository.

It supports building only custom boards defined locally.

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

   Or build specific board directly:
   ```bash
   ./build.sh board=BPMCIRCUITS_FEBERIS
   ```

3. Firmware files will be saved in the `output/` folder.

---

## 📁 Adding a New Custom Board

To add support for your custom board, create a new folder in the `custom_boards/` directory. For example:
```
custom_boards/BPMCIRCUITS_MYBOARD/
```

Your board folder should contain:

| File              | Description |
|-------------------|-------------|
| `chip.txt`        | One line file with your chip: `esp32`, `esp32s2`, `esp32s3`, or `esp32c3` |
| `platform.txt`    | Platform overrides (copied into Arduino platform path) |
| `libs.txt`        | List of Arduino library names (one per line) |
| `libs_git.txt`    | List of external Git libraries in `URL@VERSION` format |
| `inject.py`       | Python script to inject `configs.h` and `WiFiScan.cpp` patches |
| `info.txt`        | Optional metadata file shown for documentation purposes |

### 📘 Example info.txt

```
Info: BPMCIRCUITS_FEBERIS_PRO
Project URL: https://github.com/bpmcircuits/ESP32Marauder_FEBERIS
Description: Supporting as well https://github.com/bpmcircuits/ESP32Marauder_NetNinja
```

### 🧩 About inject.py

`inject.py` must support:
- `--patch`: patch source files
- `--validate`: validate applied changes
- `--all`: patch and validate (combined)

The script is executed automatically during the build process.

### 📦 About Library Files

- `libs.txt`:
  - Add standard Arduino libraries like:
    ```
    LinkedList
    ArduinoJson
    ```

- `libs_git.txt`:
  - External Git repositories (auto-cloned and checked out to given version):
    ```
    https://github.com/me-no-dev/AsyncTCP.git@master
    https://github.com/me-no-dev/ESPAsyncWebServer.git@master
    ```

---

## 📦 Firmware Output

Firmware will be saved as:
```
ESP32_Marauder_<BOARD>_<VERSION>.bin
```

Auxiliary files like `bootloader.bin`, `partitions.bin`, and `boot_app0.bin` will also be exported if found.

---

## 🧹 Cleaning

To clean build files:
```bash
./build.sh clean
```

---

## ✅ Tested On

- Docker 28.0.4+
- Compose v2 and `docker-compose`
- Works with ESP32-WROOM, ESP32-S3, and ESP32-S2

---


## 📋 Sample successful build log

```
./build.sh board=BPMCIRCUITS_FEBERIS
🔍 Checking Docker Compose compatibility...
✅ Docker Compose is available
📦 Available custom boards:
✅ Board from argument: BPMCIRCUITS_FEBERIS
🔎 Detected chip from chip.txt: esp32
📦 Board: BPMCIRCUITS_FEBERIS
🔧 Chip family: esp32
🪡 Core version: 2.0.10
🔹 Custom auto mode: true
📝 Board Info:
Info: BPMCIRCUITS_FEBERIS
Project URL: https://github.com/bpmcircuits/ESP32Marauder_FEBERIS
Description:
Compose can now delegate builds to bake for better performance.
 To do so, set COMPOSE_BAKE=true.
[+] Building 140.6s (25/25) FINISHED                                                                                                             docker:default
 => [marauder-builder internal] load build definition from Dockerfile                                                                                      0.0s
 => => transferring dockerfile: 3.44kB                                                                                                                     0.0s
 => [marauder-builder internal] load metadata for docker.io/library/ubuntu:22.04                                                                           1.4s
 => [marauder-builder internal] load .dockerignore                                                                                                         0.0s
 => => transferring context: 2B                                                                                                                            0.0s
 => [marauder-builder  1/19] FROM docker.io/library/ubuntu:22.04@sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3                   0.1s
 => => resolve docker.io/library/ubuntu:22.04@sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3                                      0.0s
 => => sha256:d80997daaa3811b175119350d84305e1ec9129e1799bba0bd1e3120da3ff52c3 6.69kB / 6.69kB                                                             0.0s
 => => sha256:a76d0e9d99f0e91640e35824a6259c93156f0f07b7778ba05808c750e7fa6e68 424B / 424B                                                                 0.0s
 => => sha256:cc934a90cd99a939f3922f858ac8f055427300ee3ee4dfcd303c53e571d0aeab 2.30kB / 2.30kB                                                             0.0s
 => [marauder-builder internal] load build context                                                                                                         0.1s
 => => transferring context: 290.65kB                                                                                                                      0.0s
 => [marauder-builder  2/19] RUN apt-get update && apt-get install -y     curl unzip git xz-utils python3 python3-pip     gcc make jq sed && rm -rf /var  43.8s
 => [marauder-builder  3/19] RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh                                   2.9s
 => [marauder-builder  4/19] RUN arduino-cli config init &&     arduino-cli core update-index &&     arduino-cli core install esp32:esp32@2.0.10          37.0s
 => [marauder-builder  5/19] COPY libs.txt /tmp/default_libs.txt                                                                                           0.1s
 => [marauder-builder  6/19] COPY libs_git.txt /tmp/default_libs_git.txt                                                                                   0.1s
 => [marauder-builder  7/19] COPY custom_boards/ /tmp/custom_boards/                                                                                       0.1s
 => [marauder-builder  8/19] RUN if [[ "true" == "true" ]]; then       echo "📥 Using custom libs.txt for BPMCIRCUITS_FEBERIS";       cp /tmp/custom_bo     0.3s
 => [marauder-builder  9/19] RUN grep -v '^#' /tmp/libs.txt | grep -v '^\s*$' | while read lib; do       echo "📦 Installing $lib...";       until ard     24.4s
 => [marauder-builder 10/19] RUN if [[ "true" == "true" ]]; then       echo "📥 Using custom libs_git.txt for BPMCIRCUITS_FEBERIS";       cp /tmp/custo     0.4s
 => [marauder-builder 11/19] RUN mkdir -p /root/Arduino/libraries && cd /root/Arduino/libraries &&     while IFS=@ read -r REPO VERSION; do         DIR=$  2.1s
 => [marauder-builder 12/19] RUN pip3 install pyserial                                                                                                     1.0s
 => [marauder-builder 13/19] RUN rm -rf /project/ESP32Marauder &&     git clone --depth=1 https://github.com/justcallmekoko/ESP32Marauder.git /project/E  17.1s
 => [marauder-builder 14/19] RUN if [[ "true" == "true" ]]; then       echo "🚀 Running inject.py for BPMCIRCUITS_FEBERIS";       mkdir -p /project/out     0.3s
 => [marauder-builder 15/19] RUN if [[ -f /project/output/inject.log ]]; then       echo "🪵 Injection log:" && cat /project/output/inject.log;     els     0.3s
 => [marauder-builder 16/19] RUN mkdir -p /root/.arduino15/packages/esp32/hardware/esp32/2.0.10                                                            0.3s
 => [marauder-builder 17/19] COPY platform.txt /root/.arduino15/packages/esp32/hardware/esp32/2.0.10/platform.txt                                          0.1s
 => [marauder-builder 18/19] WORKDIR /project                                                                                                              0.0s
 => [marauder-builder 19/19] RUN if [[ -f /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino ]]; then       chmod +r /project/ESP32Marauder/esp32_m  0.2s
 => [marauder-builder] exporting to image                                                                                                                  8.5s
 => => exporting layers                                                                                                                                    8.5s
 => => writing image sha256:4457bce1a67965d7adeb56d250b53980bcc57be8578747cfeea0eef3c3ba7f43                                                               0.0s
 => => naming to docker.io/library/esp32marauder-builder-marauder-builder                                                                                  0.0s
 => [marauder-builder] resolving provenance for metadata file                                                                                              0.0s
[+] Building 1/1
 ✔ marauder-builder  Built                                                                                                                                 0.0s
[+] Running 2/2
 ✔ Network esp32marauder-builder_default  Created                                                                                                          0.2s
 ✔ Container esp32marauder_builder        Created                                                                                                          0.1s
Attaching to esp32marauder_builder
esp32marauder_builder  | 🔧 Running injection patch and validation...
esp32marauder_builder  | 🚀 Running injection for custom auto board: BPMCIRCUITS_FEBERIS
esp32marauder_builder  | 📦 FQBN: esp32:esp32:esp32
esp32marauder_builder  | 📁 Sketch: /project/ESP32Marauder/esp32_marauder/esp32_marauder.ino
esp32marauder_builder  | ⚙️  Compiling for board: BPMCIRCUITS_FEBERIS
esp32marauder_builder  | ✅ Sketch file found
esp32marauder_builder  | Sketch uses 1238569 bytes (94%) of program storage space. Maximum is 1310720 bytes.
esp32marauder_builder  | Global variables use 77700 bytes (23%) of dynamic memory, leaving 249980 bytes for local variables. Maximum is 327680 bytes.
esp32marauder_builder  | ✅ Firmware output:
esp32marauder_builder  | /project/output/ESP32_Marauder_BPMCIRCUITS_FEBERIS_v1.4.3.bin
esp32marauder_builder  | ✅ boot_app0.bin copied as: boot_app0.bin
esp32marauder_builder  | 🔍 Validating injected source files...
esp32marauder_builder  | 🔍 Validating configs.h...
esp32marauder_builder  | ✅ Injection validation passed.
esp32marauder_builder  | 🪵 Injection log:
esp32marauder_builder  | ⚙️ Patching configs.h...
esp32marauder_builder  | ✅ configs.h patched successfully.
esp32marauder_builder  | ✅ configs.h: inserted targets = True , features = True , mem_limit = True , html_limit = True
esp32marauder_builder  | ⚙️ Patching WiFiScan.cpp...
esp32marauder_builder  | ✅ Patched: sd_obj.removeFile("/Airtags_0.log");
esp32marauder_builder  | ✅ Patched: sd_obj.removeFile("/APs_0.log");
esp32marauder_builder  | ✅ Patched: sd_obj.removeFile("/SSIDs_0.log");
esp32marauder_builder  | ✅ WiFiScan.cpp patched successfully.
esp32marauder_builder  | 🔍 Validating configs.h...
esp32marauder_builder  | ✅ Injection validation passed.
esp32marauder_builder  | 🧹 Cleaning up extra files...
esp32marauder_builder exited with code 0
...
```

---

## ⚠️ Typical Errors

### 🔌 Network Timeout or Docker Registry Issues

If you encounter errors like this during image build:

  ```
  [+] Building 20.2s (2/2) FINISHED                                                                                                                docker:default
 => [marauder-builder internal] load build definition from Dockerfile                                                                                      0.0s
 => => transferring dockerfile: 3.44kB                                                                                                                     0.0s
 => ERROR [marauder-builder internal] load metadata for docker.io/library/ubuntu:22.04                                                                    20.0s
------
 > [marauder-builder internal] load metadata for docker.io/library/ubuntu:22.04:
------
failed to solve: ubuntu:22.04: failed to resolve source metadata for docker.io/library/ubuntu:22.04: failed to do request: Head "https://registry-1.docker.io/v2/library/ubuntu/manifests/22.04": dial tcp: lookup registry-1.docker.io: no such host

  ```
This usually means your system cannot resolve Docker Hub domains (DNS issue) or has no internet access from Docker.

#### ✅ Suggested Fixes:
- Ensure your machine has working DNS (e.g., try using `1.1.1.1` or `8.8.8.8`)
- Restart Docker: `sudo systemctl restart docker`
- Clean up Docker cache and retry:
  ```bash
  ./build.sh clean
  docker builder prune --all
  ./build.sh
  ```
