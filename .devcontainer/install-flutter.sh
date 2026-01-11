#!/bin/bash
set -e

echo "Installing Flutter..."

# Install dependencies
sudo apt update
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa

# Download Flutter SDK (stable)
FLUTTER_VERSION="3.13.6"
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Extract Flutter
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Move to /usr/local/flutter
sudo mv flutter /usr/local/flutter

# Add Flutter to PATH for all future shells
echo 'export PATH="$PATH:/usr/local/flutter/bin"' >> ~/.bashrc
export PATH="$PATH:/usr/local/flutter/bin"

# Enable web support
flutter config --enable-web

# Check Flutter install
flutter doctor
