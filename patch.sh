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

# Push patch
shorebird patch ios --release-version="$VERSION" --no-confirm

echo ""
echo "✅ Patch pushed successfully!"
echo "📱 Users will receive the update on next app launch."
