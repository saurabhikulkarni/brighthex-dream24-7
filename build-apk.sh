#!/bin/bash
set -e

echo "Building Flutter APK using Docker..."
echo "Note: This requires Docker to be installed and running."
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker from https://docs.docker.com/get-docker/"
    exit 1
fi

# Pull Flutter Docker image if not already present
echo "Pulling Flutter Docker image..."
docker pull ghcr.io/cirruslabs/flutter:stable

echo ""
echo "Running Flutter build..."

# Build the APK using Docker
# Mount project directory and run Flutter build commands
docker run --rm \
  -v "$(pwd):/app" \
  -w /app \
  ghcr.io/cirruslabs/flutter:stable \
  bash -c "flutter pub get && flutter build apk --debug"

echo ""
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "✓ Build complete!"
    echo "APK location: build/app/outputs/flutter-apk/app-debug.apk"
    ls -lh build/app/outputs/flutter-apk/app-debug.apk
else
    echo "✗ Build failed - APK not found at expected location"
    exit 1
fi
