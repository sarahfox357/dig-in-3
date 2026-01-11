#!/bin/bash
set -e

echo "Installing Flutter..."

# Install dependencies
sudo apt update
sudo apt install -y git curl unzip xz-utils zip libglu1-mesa

# Download Flutter stable
FLUTTER_VERSION="3.13.6"
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Extract Flutter inside the repo
tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz

# Add Flutter to PATH for current session and future sessions
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web
flutter config --enable-web

# Run doctor
flutter doctor

chmod +x .devcontainer/install-flutter.sh

