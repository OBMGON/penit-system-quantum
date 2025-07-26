#!/bin/bash

# Script para generar iconos de diferentes tamaños para PenitSystem Quantum
# Requiere ImageMagick instalado: brew install imagemagick

echo "🎨 Generando iconos para PenitSystem Quantum..."

# Crear directorio temporal
mkdir -p temp_icons

# Tamaños requeridos para diferentes plataformas
declare -a sizes=(
    "16x16"
    "32x32"
    "48x48"
    "64x64"
    "72x72"
    "96x96"
    "128x128"
    "144x144"
    "152x152"
    "192x192"
    "384x384"
    "512x512"
    "1024x1024"
)

# Crear un icono base simple (puedes reemplazar esto con tu logo real)
convert -size 1024x1024 xc:transparent \
    -fill "#17643A" \
    -draw "circle 512,512 512,100" \
    -fill white \
    -font Arial-Bold \
    -pointsize 200 \
    -gravity center \
    -draw "text 0,0 'PS'" \
    temp_icons/base_icon.png

# Generar iconos en diferentes tamaños
for size in "${sizes[@]}"; do
    echo "Generando icono ${size}..."
    convert temp_icons/base_icon.png -resize $size "temp_icons/icon_${size}.png"
done

# Copiar iconos a las ubicaciones correctas
echo "📁 Copiando iconos a las ubicaciones correctas..."

# Android
cp temp_icons/icon_48x48.png android/app/src/main/res/mipmap-mdpi/ic_launcher.png
cp temp_icons/icon_72x72.png android/app/src/main/res/mipmap-hdpi/ic_launcher.png
cp temp_icons/icon_96x96.png android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp temp_icons/icon_144x144.png android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp temp_icons/icon_192x192.png android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Web
cp temp_icons/icon_192x192.png web/icons/Icon-192.png
cp temp_icons/icon_512x512.png web/icons/Icon-512.png
cp temp_icons/icon_192x192.png web/icons/Icon-maskable-192.png
cp temp_icons/icon_512x512.png web/icons/Icon-maskable-512.png
cp temp_icons/icon_32x32.png web/favicon.png

# iOS (copiar a Assets.xcassets)
cp temp_icons/icon_1024x1024.png ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

# macOS
cp temp_icons/icon_1024x1024.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
cp temp_icons/icon_512x512.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
cp temp_icons/icon_256x256.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
cp temp_icons/icon_128x128.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
cp temp_icons/icon_64x64.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
cp temp_icons/icon_32x32.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
cp temp_icons/icon_16x16.png macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png

# Limpiar archivos temporales
rm -rf temp_icons

echo "✅ Iconos generados exitosamente!"
echo "📱 Iconos copiados a:"
echo "   - Android: android/app/src/main/res/mipmap-*/"
echo "   - Web: web/icons/"
echo "   - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "   - macOS: macos/Runner/Assets.xcassets/AppIcon.appiconset/" 