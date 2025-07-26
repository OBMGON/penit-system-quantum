#!/bin/bash

# Script de Build para Producción - PenitSystem Quantum
# Uso: ./scripts/build_release.sh [android|ios|both]

set -e

echo "🚀 Iniciando build de producción para PenitSystem Quantum..."

# Limpiar proyecto
echo "🧹 Limpiando proyecto..."
flutter clean
flutter pub get

# Verificar análisis
echo "🔍 Verificando análisis de código..."
flutter analyze --no-fatal-infos

# Función para build de Android
build_android() {
    echo "📱 Construyendo APK de Android..."
    flutter build apk --release
    
    echo "📱 Construyendo App Bundle de Android..."
    flutter build appbundle --release
    
    echo "✅ Build de Android completado"
    echo "📁 APK: build/app/outputs/flutter-apk/app-release.apk"
    echo "📁 Bundle: build/app/outputs/bundle/release/app-release.aab"
}

# Función para build de iOS
build_ios() {
    echo "🍎 Construyendo IPA de iOS..."
    flutter build ios --release --no-codesign
    
    echo "✅ Build de iOS completado"
    echo "📁 IPA: build/ios/archive/Runner.xcarchive"
}

# Procesar argumentos
case "${1:-both}" in
    "android")
        build_android
        ;;
    "ios")
        build_ios
        ;;
    "both")
        build_android
        build_ios
        ;;
    *)
        echo "❌ Uso: $0 [android|ios|both]"
        exit 1
        ;;
esac

echo "🎉 Build de producción completado exitosamente!" 