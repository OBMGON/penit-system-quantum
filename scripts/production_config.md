# 🚀 Configuración de Producción - PenitSystem Quantum

## 📋 Checklist Pre-Publicación

### ✅ Android (Google Play Store)
- [ ] Application ID: `com.penitsystem.quantum`
- [ ] Version Code: 1
- [ ] Version Name: 1.0.0
- [ ] Build APK: `flutter build apk --release`
- [ ] Build Bundle: `flutter build appbundle --release`
- [ ] Firmar APK/Bundle con keystore de producción
- [ ] Probar en dispositivos reales
- [ ] Verificar permisos en AndroidManifest.xml

### ✅ iOS (App Store)
- [ ] Bundle ID: `com.penitsystem.quantum`
- [ ] Version: 1.0.0
- [ ] Build: 1
- [ ] Build IPA: `flutter build ios --release`
- [ ] Firmar con certificado de distribución
- [ ] Probar en dispositivos reales
- [ ] Verificar Info.plist

### ✅ General
- [ ] Eliminar código de debug
- [ ] Remover prints/logs
- [ ] Optimizar imágenes
- [ ] Verificar análisis: `flutter analyze`
- [ ] Tests unitarios pasando
- [ ] Documentación actualizada

## 🔧 Comandos de Build

```bash
# Build Android
./scripts/build_release.sh android

# Build iOS  
./scripts/build_release.sh ios

# Build ambos
./scripts/build_release.sh both
```

## 📱 Assets Requeridos

### Android
- Icono: 512x512 PNG
- Screenshots: 16:9 ratio
- Feature graphic: 1024x500

### iOS
- Icono: 1024x1024 PNG
- Screenshots: iPhone 6.7", 6.5", 5.5"
- App Store icon: 1024x1024

## 🛡️ Seguridad
- [ ] Encriptación de datos sensibles
- [ ] Validación de inputs
- [ ] Sanitización de datos
- [ ] HTTPS para APIs
- [ ] Permisos mínimos necesarios 