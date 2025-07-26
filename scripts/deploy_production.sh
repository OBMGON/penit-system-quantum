#!/bin/bash

# PenitSystem Quantum - Production Deployment Script
# This script handles production deployment for all platforms

set -e

echo "🚀 PenitSystem Quantum - Production Deployment"
echo "=============================================="

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

# Configuration
PROJECT_NAME="penitsystem-quantum"
VERSION="1.0.0"
BUILD_DATE=$(date +%Y%m%d_%H%M%S)

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Function to deploy web
deploy_web() {
    print_status "Deploying Web Version..."
    
    # Check if Firebase CLI is installed
    if command -v firebase &> /dev/null; then
        print_status "Using Firebase Hosting..."
        firebase deploy --only hosting
        print_success "Web deployed to Firebase Hosting"
    elif command -v netlify &> /dev/null; then
        print_status "Using Netlify..."
        netlify deploy --prod --dir=build/web
        print_success "Web deployed to Netlify"
    elif command -v vercel &> /dev/null; then
        print_status "Using Vercel..."
        vercel --prod
        print_success "Web deployed to Vercel"
    else
        print_warning "No deployment platform detected. Manual deployment required."
        print_status "Web build available at: build/web"
    fi
}

# Function to prepare Android for Play Store
prepare_android() {
    print_status "Preparing Android for Play Store..."
    
    # Build release APK
    flutter build apk --release
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_success "Android APK built successfully"
        print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
        print_warning "Remember to sign the APK for Play Store submission"
    else
        print_error "Android build failed"
        return 1
    fi
}

# Function to prepare iOS for App Store
prepare_ios() {
    print_status "Preparing iOS for App Store..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Build iOS app
        flutter build ios --release --no-codesign
        
        print_success "iOS app built successfully"
        print_warning "iOS app requires code signing and App Store Connect setup"
        print_status "Use Xcode to sign and upload to App Store Connect"
    else
        print_warning "iOS build skipped (not on macOS)"
    fi
}

# Function to prepare desktop builds
prepare_desktop() {
    print_status "Preparing Desktop Builds..."
    
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        flutter build macos --release
        print_success "macOS build completed"
    fi
    
    # Linux
    flutter build linux --release
    print_success "Linux build completed"
    
    # Windows (if possible)
    flutter build windows --release
    print_success "Windows build completed"
}

# Function to create deployment package
create_deployment_package() {
    print_status "Creating Deployment Package..."
    
    DEPLOY_DIR="deployments/${BUILD_DATE}"
    mkdir -p "$DEPLOY_DIR"
    
    # Copy builds
    if [ -d "build/web" ]; then
        cp -r build/web "$DEPLOY_DIR/"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        cp build/app/outputs/flutter-apk/app-release.apk "$DEPLOY_DIR/penitsystem-quantum-android.apk"
    fi
    
    if [ -d "build/macos/Build/Products/Release" ]; then
        cp -r build/macos/Build/Products/Release/* "$DEPLOY_DIR/"
    fi
    
    if [ -d "build/linux/x64/release/bundle" ]; then
        cp -r build/linux/x64/release/bundle "$DEPLOY_DIR/linux"
    fi
    
    if [ -d "build/windows/runner/Release" ]; then
        cp -r build/windows/runner/Release "$DEPLOY_DIR/windows"
    fi
    
    # Create deployment manifest
    cat > "$DEPLOY_DIR/deployment-manifest.json" << EOF
{
  "project": "PenitSystem Quantum",
  "version": "$VERSION",
  "buildDate": "$BUILD_DATE",
  "deploymentDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "platforms": {
    "web": $(if [ -d "$DEPLOY_DIR/web" ]; then echo "true"; else echo "false"; fi),
    "android": $(if [ -f "$DEPLOY_DIR/penitsystem-quantum-android.apk" ]; then echo "true"; else echo "false"; fi),
    "ios": $(if [ -d "$DEPLOY_DIR/penit_system_geosecure_quantum_demo.app" ]; then echo "true"; else echo "false"; fi),
    "macos": $(if [ -d "$DEPLOY_DIR/penit_system_geosecure_quantum_demo.app" ]; then echo "true"; else echo "false"; fi),
    "linux": $(if [ -d "$DEPLOY_DIR/linux" ]; then echo "true"; else echo "false"; fi),
    "windows": $(if [ -d "$DEPLOY_DIR/windows" ]; then echo "true"; else echo "false"; fi)
  },
  "nextSteps": [
    "Test all builds on target platforms",
    "Sign Android APK for Play Store submission",
    "Sign iOS app for App Store submission",
    "Deploy web version to production hosting",
    "Package desktop versions for distribution"
  ]
}
EOF
    
    print_success "Deployment package created at: $DEPLOY_DIR"
}

# Function to generate deployment report
generate_deployment_report() {
    print_status "Generating Deployment Report..."
    
    REPORT_FILE="deployments/${BUILD_DATE}/deployment-report.md"
    
    cat > "$REPORT_FILE" << EOF
# PenitSystem Quantum - Deployment Report

**Deployment Date:** $(date)  
**Version:** $VERSION  
**Build ID:** $BUILD_DATE  

## Build Status

| Platform | Status | Location |
|----------|--------|----------|
| Web | $(if [ -d "deployments/${BUILD_DATE}/web" ]; then echo "✅ Ready"; else echo "❌ Failed"; fi) | $(if [ -d "deployments/${BUILD_DATE}/web" ]; then echo "deployments/${BUILD_DATE}/web"; else echo "N/A"; fi) |
| Android | $(if [ -f "deployments/${BUILD_DATE}/penitsystem-quantum-android.apk" ]; then echo "✅ Ready"; else echo "❌ Failed"; fi) | $(if [ -f "deployments/${BUILD_DATE}/penitsystem-quantum-android.apk" ]; then echo "deployments/${BUILD_DATE}/penitsystem-quantum-android.apk"; else echo "N/A"; fi) |
| iOS | $(if [ -d "deployments/${BUILD_DATE}/penit_system_geosecure_quantum_demo.app" ]; then echo "✅ Ready"; else echo "❌ Failed"; fi) | $(if [ -d "deployments/${BUILD_DATE}/penit_system_geosecure_quantum_demo.app" ]; then echo "deployments/${BUILD_DATE}/penit_system_geosecure_quantum_demo.app"; else echo "N/A"; fi) |
| macOS | $(if [ -d "deployments/${BUILD_DATE}/penit_system_geosecure_quantum_demo.app" ]; then echo "✅ Ready"; else echo "❌ Failed"; fi) | $(if [ -d "deployments/${BUILD_DATE}/penit_system_geosecure_quantum_demo.app" ]; then echo "deployments/${BUILD_DATE}/penit_system_geosecure_quantum_demo.app"; else echo "N/A"; fi) |
| Linux | $(if [ -d "deployments/${BUILD_DATE}/linux" ]; then echo "✅ Ready"; else echo "❌ Failed"; fi) | $(if [ -d "deployments/${BUILD_DATE}/linux" ]; then echo "deployments/${BUILD_DATE}/linux"; else echo "N/A"; fi) |
| Windows | $(if [ -d "deployments/${BUILD_DATE}/windows" ]; then echo "✅ Ready"; else echo "❌ Failed"; fi) | $(if [ -d "deployments/${BUILD_DATE}/windows" ]; then echo "deployments/${BUILD_DATE}/windows"; else echo "N/A"; fi) |

## Next Steps

### Web Deployment
1. Deploy to Firebase Hosting: \`firebase deploy --only hosting\`
2. Deploy to Netlify: \`netlify deploy --prod --dir=build/web\`
3. Deploy to Vercel: \`vercel --prod\`

### Android (Play Store)
1. Sign the APK: \`jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore your-keystore.jks app-release.apk alias_name\`
2. Optimize APK: \`zipalign -v 4 app-release.apk app-release-optimized.apk\`
3. Upload to Google Play Console

### iOS (App Store)
1. Open project in Xcode
2. Configure code signing
3. Archive and upload to App Store Connect

### Desktop Distribution
1. Package macOS app for distribution
2. Create Linux packages (.deb, .rpm)
3. Create Windows installer

## Testing Checklist

- [ ] Web app loads correctly
- [ ] All features work on mobile browsers
- [ ] Android app installs and runs
- [ ] iOS app installs and runs
- [ ] Desktop apps launch properly
- [ ] All user flows work correctly
- [ ] Performance is acceptable
- [ ] No critical errors in logs

## Security Checklist

- [ ] API keys are properly configured
- [ ] Database connections are secure
- [ ] User authentication works
- [ ] Data encryption is enabled
- [ ] Privacy policy is updated
- [ ] Terms of service are updated

EOF
    
    print_success "Deployment report generated: $REPORT_FILE"
}

# Main deployment process
main() {
    print_status "Starting production deployment..."
    
    # Clean and prepare
    flutter clean
    flutter pub get
    
    # Run analysis
    flutter analyze --no-fatal-infos
    
    # Build for all platforms
    print_status "Building for all platforms..."
    
    # Web
    flutter build web --release
    
    # Android
    prepare_android
    
    # iOS
    prepare_ios
    
    # Desktop
    prepare_desktop
    
    # Create deployment package
    create_deployment_package
    
    # Generate report
    generate_deployment_report
    
    # Deploy web (if possible)
    deploy_web
    
    print_success "Production deployment completed!"
    print_status "Check deployments/${BUILD_DATE}/ for all build artifacts"
    print_status "Review deployment-report.md for next steps"
}

# Run main function
main "$@" 