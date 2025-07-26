#!/bin/bash

# PenitSystem Quantum - Build All Platforms Script
# This script builds the app for all supported platforms

set -e

echo "🚀 PenitSystem Quantum - Building for All Platforms"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check Flutter version
print_status "Checking Flutter version..."
flutter --version

# Clean and get dependencies
print_status "Cleaning project and getting dependencies..."
flutter clean
flutter pub get

# Run analysis
print_status "Running Flutter analysis..."
flutter analyze --no-fatal-infos

# Create build directory
BUILD_DIR="builds/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BUILD_DIR"

print_status "Build directory: $BUILD_DIR"

# Build for Web
print_status "Building for Web..."
flutter build web --release
if [ $? -eq 0 ]; then
    print_success "Web build completed successfully"
    cp -r build/web "$BUILD_DIR/web"
else
    print_error "Web build failed"
    exit 1
fi

# Build for Android (if possible)
print_status "Building for Android..."
if flutter build apk --release; then
    print_success "Android build completed successfully"
    cp build/app/outputs/flutter-apk/app-release.apk "$BUILD_DIR/penitsystem-quantum-android.apk"
else
    print_warning "Android build failed (network issues or missing dependencies)"
fi

# Build for iOS (if on macOS)
print_status "Building for iOS..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if flutter build ios --release --no-codesign; then
        print_success "iOS build completed successfully"
        print_warning "iOS build requires code signing for App Store distribution"
    else
        print_warning "iOS build failed"
    fi
else
    print_warning "iOS build skipped (not on macOS)"
fi

# Build for macOS (if on macOS)
print_status "Building for macOS..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if flutter build macos --release; then
        print_success "macOS build completed successfully"
        cp -r build/macos/Build/Products/Release/penit_system_geosecure_quantum_demo.app "$BUILD_DIR/"
    else
        print_warning "macOS build failed"
    fi
else
    print_warning "macOS build skipped (not on macOS)"
fi

# Build for Linux
print_status "Building for Linux..."
if flutter build linux --release; then
    print_success "Linux build completed successfully"
    cp -r build/linux/x64/release/bundle "$BUILD_DIR/linux"
else
    print_warning "Linux build failed"
fi

# Build for Windows (if on Windows or with cross-compilation)
print_status "Building for Windows..."
if flutter build windows --release; then
    print_success "Windows build completed successfully"
    cp -r build/windows/runner/Release "$BUILD_DIR/windows"
else
    print_warning "Windows build failed"
fi

# Create deployment package
print_status "Creating deployment package..."
cd "$BUILD_DIR"
tar -czf "../penitsystem-quantum-builds-$(date +%Y%m%d_%H%M%S).tar.gz" .
cd - > /dev/null

# Generate build report
print_status "Generating build report..."
cat > "$BUILD_DIR/build-report.txt" << EOF
PenitSystem Quantum - Build Report
=================================
Build Date: $(date)
Build Directory: $BUILD_DIR

Platforms Built:
$(ls -la "$BUILD_DIR" | grep -E "(web|android|ios|macos|linux|windows)" || echo "No platform builds found")

Build Status:
- Web: $(if [ -d "$BUILD_DIR/web" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- Android: $(if [ -f "$BUILD_DIR/penitsystem-quantum-android.apk" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- iOS: $(if [ -d "$BUILD_DIR/penit_system_geosecure_quantum_demo.app" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- macOS: $(if [ -d "$BUILD_DIR/penit_system_geosecure_quantum_demo.app" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- Linux: $(if [ -d "$BUILD_DIR/linux" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- Windows: $(if [ -d "$BUILD_DIR/windows" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)

Next Steps:
1. Test each build on target platforms
2. Sign Android APK for Play Store
3. Sign iOS app for App Store
4. Deploy web version to hosting service
5. Package desktop versions for distribution

EOF

print_success "Build process completed!"
print_status "Build directory: $BUILD_DIR"
print_status "Build report: $BUILD_DIR/build-report.txt"

echo ""
echo "🎉 All builds completed! Check the build directory for outputs."
echo "📋 Review the build report for detailed information." 