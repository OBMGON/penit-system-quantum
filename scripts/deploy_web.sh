#!/bin/bash

# PenitSystem Quantum - Web Deployment Script
# This script deploys the web version to various hosting platforms

set -e

echo "🚀 Iniciando deploy web de PenitSystem Quantum..."
echo "================================================"

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
    print_error "Flutter no está instalado. Por favor instala Flutter primero."
    exit 1
fi

print_status "Verificando Flutter..."
flutter --version

print_status "Limpiando proyecto..."
flutter clean
flutter pub get

print_status "Construyendo para web..."
if flutter build web --release; then
    print_success "Build web completado exitosamente"
else
    print_error "Error en build web"
    exit 1
fi

# Check if build was successful
if [ ! -d "build/web" ]; then
    print_error "No se encontró el directorio build/web"
    exit 1
fi

print_status "Build web completado en: build/web"

# Deployment options
echo ""
echo "🌐 Opciones de despliegue:"
echo "1. Firebase Hosting (recomendado)"
echo "2. Netlify"
echo "3. Vercel"
echo "4. Servidor local"
echo "5. Solo preparar build (sin deploy)"

read -p "Selecciona una opción (1-5): " choice

case $choice in
    1)
        print_status "Desplegando a Firebase Hosting..."
        if command -v firebase &> /dev/null; then
            firebase deploy --only hosting
            print_success "Desplegado exitosamente a Firebase Hosting"
        else
            print_error "Firebase CLI no está instalado"
            print_status "Instala Firebase CLI: npm install -g firebase-tools"
        fi
        ;;
    2)
        print_status "Desplegando a Netlify..."
        if command -v netlify &> /dev/null; then
            netlify deploy --prod --dir=build/web
            print_success "Desplegado exitosamente a Netlify"
        else
            print_error "Netlify CLI no está instalado"
            print_status "Instala Netlify CLI: npm install -g netlify-cli"
        fi
        ;;
    3)
        print_status "Desplegando a Vercel..."
        if command -v vercel &> /dev/null; then
            vercel --prod
            print_success "Desplegado exitosamente a Vercel"
        else
            print_error "Vercel CLI no está instalado"
            print_status "Instala Vercel CLI: npm install -g vercel"
        fi
        ;;
    4)
        print_status "Iniciando servidor local..."
        cd build/web
        python3 -m http.server 8080 &
        SERVER_PID=$!
        print_success "Servidor iniciado en http://localhost:8080"
        print_status "Presiona Ctrl+C para detener el servidor"
        wait $SERVER_PID
        ;;
    5)
        print_success "Build preparado en build/web"
        print_status "Puedes desplegar manualmente el contenido de build/web"
        ;;
    *)
        print_error "Opción inválida"
        exit 1
        ;;
esac

print_success "Proceso completado!" 