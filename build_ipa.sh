#!/bin/bash

# Build and package iOS app for SideStore
# Usage: ./build_ipa.sh

set -e

echo "🔨 Building iOS release..."
flutter build ios --release --no-codesign

echo "📦 Packaging IPA..."
cd build/ios/iphoneos
rm -rf Payload Easy.ipa 2>/dev/null || true
mkdir -p Payload
cp -r Runner.app Payload/
zip -r Easy.ipa Payload
rm -rf Payload

echo ""
echo "✅ Done! IPA file is ready:"
echo "   $(pwd)/Easy.ipa"
echo ""
echo "📱 Next steps:"
echo "   1. AirDrop Easy.ipa to your iPhone"
echo "   2. Open in SideStore to install"
