#!/bin/bash

# Script de Build para Producción - PenitSystem GeoSecure Quantum
# Versión: 1.0.0
# Fecha: $(date)

set -e

echo "🚀 Iniciando build de producción para PenitSystem GeoSecure Quantum"
echo "================================================================"

# Configuración de colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
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

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    print_error "No se encontró pubspec.yaml. Ejecuta este script desde el directorio raíz del proyecto."
    exit 1
fi

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    print_error "Flutter no está instalado o no está en el PATH."
    exit 1
fi

# Verificar versión de Flutter
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter [0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
print_status "Usando $FLUTTER_VERSION"

# Limpiar builds anteriores
print_status "Limpiando builds anteriores..."
flutter clean
flutter pub get

# Verificar dependencias
print_status "Verificando dependencias..."
flutter doctor

# Crear directorio de builds
BUILD_DIR="builds/production/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BUILD_DIR"

print_status "Directorio de builds: $BUILD_DIR"

# Función para build de Android
build_android() {
    print_status "🔨 Compilando para Android..."
    
    # Verificar que Android SDK esté configurado
    if [ ! -d "$ANDROID_HOME" ]; then
        print_warning "ANDROID_HOME no está configurado. Intentando detectar automáticamente..."
    fi
    
    # Build APK de release
    flutter build apk --release --target-platform android-arm64
    
    # Build App Bundle para Play Store
    flutter build appbundle --release --target-platform android-arm64
    
    # Copiar archivos generados
    cp build/app/outputs/flutter-apk/app-release.apk "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_v1.0.0.apk"
    cp build/app/outputs/bundle/release/app-release.aab "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_v1.0.0.aab"
    
    print_success "✅ Build de Android completado"
}

# Función para build de iOS
build_ios() {
    print_status "🍎 Compilando para iOS..."
    
    # Verificar que Xcode esté instalado
    if ! command -v xcodebuild &> /dev/null; then
        print_warning "Xcode no está instalado. Saltando build de iOS..."
        return
    fi
    
    # Build para iOS
    flutter build ios --release --no-codesign
    
    print_success "✅ Build de iOS completado"
    print_warning "⚠️  Para distribuir en App Store, necesitas firmar el código con Xcode"
}

# Función para build de Web
build_web() {
    print_status "🌐 Compilando para Web..."
    
    # Build optimizado para web
    flutter build web --release --web-renderer canvaskit
    
    # Copiar archivos generados
    cp -r build/web "$BUILD_DIR/web"
    
    print_success "✅ Build de Web completado"
}

# Función para build de Desktop
build_desktop() {
    print_status "🖥️  Compilando para Desktop..."
    
    # Build para macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        flutter build macos --release
        cp -r build/macos/Build/Products/Release/penit_system_geosecure_quantum_demo.app "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_macOS.app"
        print_success "✅ Build de macOS completado"
    fi
    
    # Build para Linux
    if command -v gcc &> /dev/null; then
        flutter build linux --release
        cp -r build/linux/x64/release/bundle "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_Linux"
        print_success "✅ Build de Linux completado"
    else
        print_warning "⚠️  GCC no está instalado. Saltando build de Linux..."
    fi
    
    # Build para Windows (solo en Windows)
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        flutter build windows --release
        cp -r build/windows/runner/Release "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_Windows"
        print_success "✅ Build de Windows completado"
    fi
}

# Función para generar reporte de build
generate_build_report() {
    print_status "📊 Generando reporte de build..."
    
    REPORT_FILE="$BUILD_DIR/build_report.txt"
    
    cat > "$REPORT_FILE" << EOF
REPORTE DE BUILD - PENITSYSTEM GEOSECURE QUANTUM
===============================================

Fecha y hora: $(date)
Versión de Flutter: $FLUTTER_VERSION
Versión de la app: 1.0.0
Build Number: 1

ARCHIVOS GENERADOS:
==================

EOF

    # Listar archivos generados
    if [ -f "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_v1.0.0.apk" ]; then
        echo "✅ Android APK: PenitSystem_GeoSecure_Quantum_v1.0.0.apk" >> "$REPORT_FILE"
    fi
    
    if [ -f "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_v1.0.0.aab" ]; then
        echo "✅ Android App Bundle: PenitSystem_GeoSecure_Quantum_v1.0.0.aab" >> "$REPORT_FILE"
    fi
    
    if [ -d "$BUILD_DIR/web" ]; then
        echo "✅ Web: Carpeta web/" >> "$REPORT_FILE"
    fi
    
    if [ -d "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_macOS.app" ]; then
        echo "✅ macOS: PenitSystem_GeoSecure_Quantum_macOS.app" >> "$REPORT_FILE"
    fi
    
    if [ -d "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_Linux" ]; then
        echo "✅ Linux: Carpeta PenitSystem_GeoSecure_Quantum_Linux/" >> "$REPORT_FILE"
    fi
    
    if [ -d "$BUILD_DIR/PenitSystem_GeoSecure_Quantum_Windows" ]; then
        echo "✅ Windows: Carpeta PenitSystem_GeoSecure_Quantum_Windows/" >> "$REPORT_FILE"
    fi
    
    cat >> "$REPORT_FILE" << EOF

INSTRUCCIONES DE DESPLIEGUE:
===========================

1. GOOGLE PLAY STORE:
   - Subir archivo .aab a Google Play Console
   - Completar información de la app
   - Configurar precios y disponibilidad
   - Enviar para revisión

2. APP STORE:
   - Abrir proyecto en Xcode
   - Firmar con certificado de distribución
   - Subir a App Store Connect
   - Completar información y enviar para revisión

3. WEB:
   - Subir contenido de la carpeta web/ a un servidor web
   - Configurar HTTPS
   - Configurar dominio personalizado

4. DESKTOP:
   - macOS: Crear DMG con el .app
   - Linux: Crear paquete .deb o .rpm
   - Windows: Crear instalador .msi

CONFIGURACIÓN DE PRODUCCIÓN:
===========================

- Modo de producción activado
- Optimizaciones de rendimiento habilitadas
- Logs de debug deshabilitados
- Cifrado de datos habilitado
- Auditoría habilitada

CONTACTO DE SOPORTE:
===================

Email: soporte@penitsystem.ge
Teléfono: +240 555 012345
Website: https://penitsystem.ge

EOF

    print_success "✅ Reporte de build generado: $REPORT_FILE"
}

# Función para crear checksums
create_checksums() {
    print_status "🔐 Generando checksums de seguridad..."
    
    CHECKSUM_FILE="$BUILD_DIR/checksums.txt"
    
    echo "CHECKSUMS DE SEGURIDAD - PENITSYSTEM GEOSECURE QUANTUM" > "$CHECKSUM_FILE"
    echo "=====================================================" >> "$CHECKSUM_FILE"
    echo "Fecha: $(date)" >> "$CHECKSUM_FILE"
    echo "" >> "$CHECKSUM_FILE"
    
    # Generar checksums para todos los archivos
    find "$BUILD_DIR" -type f -name "*.apk" -o -name "*.aab" -o -name "*.app" | while read file; do
        if command -v sha256sum &> /dev/null; then
            checksum=$(sha256sum "$file" | cut -d' ' -f1)
        elif command -v shasum &> /dev/null; then
            checksum=$(shasum -a 256 "$file" | cut -d' ' -f1)
        else
            checksum="SHA256 no disponible"
        fi
        echo "$(basename "$file"): $checksum" >> "$CHECKSUM_FILE"
    done
    
    print_success "✅ Checksums generados: $CHECKSUM_FILE"
}

# Función principal
main() {
    print_status "Iniciando proceso de build completo..."
    
    # Ejecutar builds
    build_android
    build_ios
    build_web
    build_desktop
    
    # Generar reportes
    generate_build_report
    create_checksums
    
    print_success "🎉 ¡Build de producción completado exitosamente!"
    print_status "📁 Archivos generados en: $BUILD_DIR"
    print_status "📋 Revisa el reporte de build para instrucciones de despliegue"
    
    # Mostrar resumen
    echo ""
    echo "📊 RESUMEN DEL BUILD:"
    echo "===================="
    ls -la "$BUILD_DIR"
}

# Ejecutar función principal
main "$@" 