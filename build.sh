#!/bin/bash

# Build script for Darood Tracker

set -e

echo "Building Darood Tracker..."

# Build the app
swift build -c release

# Create app bundle
APP_NAME="DaroodTracker"
APP_DIR="build/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Clean previous build
rm -rf build
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp .build/release/${APP_NAME} "${MACOS_DIR}/${APP_NAME}"

# Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/"

# Create PkgInfo
echo -n "APPL????" > "${CONTENTS_DIR}/PkgInfo"

# Copy resources if they exist
if [ -d "Resources" ]; then
    cp -R Resources/* "${RESOURCES_DIR}/"
fi

# Copy Assets.xcassets if it exists
if [ -d "Sources/Assets.xcassets" ]; then
    cp -R Sources/Assets.xcassets "${RESOURCES_DIR}/"
fi

# Make executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "Build complete!"
echo "App location: ${APP_DIR}"
echo ""
echo "To run the app:"
echo "  open ${APP_DIR}"
echo ""
echo "To install:"
echo "  cp -R ${APP_DIR} /Applications/"
