#!/bin/bash

# Exit on error
set -e

echo "Installing Flutter..."

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter doctor to verify install
flutter doctor -v

# Enable web support
flutter config --enable-web

# Build the web application
echo "Building Flutter Web App..."
flutter build web --release --no-tree-shake-icons

echo "Build complete!"
