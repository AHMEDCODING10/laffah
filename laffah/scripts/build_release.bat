@echo off
echo ==========================================================
echo 🚀 Laffah Mobile App - Production Release Builder
echo ==========================================================
echo.

cd /d "%~dp0\.."

echo [1/4] 🧹 Cleaning project build cache...
call flutter clean

echo [2/4] 📦 Fetching Flutter dependencies...
call flutter pub get

echo [3/4] 📱 Building Optimized Release APKs (Split per ABI for minimal size)...
call flutter build apk --release --split-per-abi --obfuscate --split-debug-info=./build/symbols

echo [4/4] 📦 Building Google Play App Bundle (.aab)...
call flutter build appbundle --release --obfuscate --split-debug-info=./build/symbols

echo.
echo ==========================================================
echo ✅ BUILD COMPLETED SUCCESSFULLY!
echo 📁 APKs Location:      laffah/build/app/outputs/flutter-apk/
echo 📁 AppBundle Location: laffah/build/app/outputs/bundle/release/
echo ==========================================================
pause
