#!/bin/bash
set -e

echo "=========================================================="
echo "🚀 Laffah Mobile App - Production Release Builder"
echo "=========================================================="

cd "$(dirname "$0")/.."

echo "[1/4] 🧹 Cleaning project build cache..."
flutter clean

echo "[2/4] 📦 Fetching Flutter dependencies..."
flutter pub get

echo "[3/4] 📱 Building Optimized Release APKs (Split per ABI)..."
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./build/symbols

echo "[4/4] 📦 Building Google Play App Bundle (.aab)..."
flutter build appbundle --release --obfuscate --split-debug-info=./build/symbols

echo "=========================================================="
echo "✅ BUILD COMPLETED SUCCESSFULLY!"
echo "📁 APKs:      laffah/build/app/outputs/flutter-apk/"
echo "📁 AppBundle: laffah/build/app/outputs/bundle/release/"
echo "=========================================================="
