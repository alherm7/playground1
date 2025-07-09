#!/usr/bin/env bash
set -e

# ============================================================
# Flutter + Android SDK Setup Script for Codex Workspaces
# ============================================================

# 1) Install system dependencies
sudo apt update
sudo apt install -y \
  git curl xz-utils zip libglu1-mesa libgtk-3-dev mesa-utils wget unzip

# 2) Clone Flutter SDK if not already present
FLUTTER_DIR="$HOME/flutter"
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

# 3) Add Flutter to PATH for this session
export PATH="$FLUTTER_DIR/bin:$PATH"
# Persist to ~/.bashrc
if ! grep -q 'flutter/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
fi

# 4) Initial Flutter doctor
flutter doctor

# 5) Install Android SDK command-line tools
ANDROID_SDK_ROOT="$HOME/Android/Sdk"
if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
  mkdir -p "$ANDROID_SDK_ROOT"
  cd "$ANDROID_SDK_ROOT"
  wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
  # Extract to a temp folder to avoid nested cmdline-tools directory
  mkdir -p temp-tools
  unzip -q cmdline-tools.zip -d temp-tools
  mkdir -p cmdline-tools/latest
  mv temp-tools/cmdline-tools/* cmdline-tools/latest/
  rm -rf temp-tools cmdline-tools.zip
fi

# 6) Add Android tools to PATH
export ANDROID_SDK_ROOT
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
# Persist to ~/.bashrc
if ! grep -q 'ANDROID_SDK_ROOT' ~/.bashrc; then
  echo 'export ANDROID_SDK_ROOT="$HOME/Android/Sdk"' >> ~/.bashrc
  echo 'export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' >> ~/.bashrc
fi

# 7) Install Android SDK components
yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" \
  "platform-tools" \
  "platforms;android-33" \
  "build-tools;33.0.2"

# 8) Configure Flutter to use Android SDK
flutter config --android-sdk "$ANDROID_SDK_ROOT"

# 9) Accept Android licenses
yes | flutter doctor --android-licenses

# 10) (Optional) Install Chromium for Flutter web support
if ! command -v chromium-browser &> /dev/null; then
  sudo apt install -y chromium-browser
fi
export CHROME_EXECUTABLE=$(which chromium-browser)
if ! grep -q 'CHROME_EXECUTABLE' ~/.bashrc; then
  echo 'export CHROME_EXECUTABLE=$(which chromium-browser)' >> ~/.bashrc
fi

# 11) Final health check
flutter doctor -v
