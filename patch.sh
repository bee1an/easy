#!/bin/bash

# Push Shorebird Patch for iOS
# Usage: ./patch.sh

set -e

# Enable proxy
export https_proxy=http://127.0.0.1:7897
export http_proxy=http://127.0.0.1:7897
export all_proxy=socks5://127.0.0.1:7897

# Add shorebird to PATH
export PATH="$HOME/.shorebird/bin:$PATH"

echo "🚀 Pushing patch to Shorebird..."

# Get current version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')

echo "📦 Release Version: $VERSION"

# Update build time
BUILD_TIME=$(date "+%Y-%m-%d %H:%M")
BUILD_INFO_FILE="lib/core/constants/build_info.dart"
cat > "$BUILD_INFO_FILE" << EOF
/// Auto-generated build info.
/// DO NOT EDIT MANUALLY. This file is updated by patch.sh.

const String kBuildTime = '$BUILD_TIME';
EOF
echo "🕐 Build Time: $BUILD_TIME"

# Push patch
shorebird patch ios --release-version="$VERSION" --no-confirm

echo ""
echo "✅ Patch pushed successfully!"
echo "📱 Users will receive the update on next app launch."
