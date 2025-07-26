# PenitSystem GeoSecure Quantum

Sistema integral de gestión penitenciaria para Guinea Ecuatorial.

## Funcionalidades principales
- Panel de control nacional con estadísticas en tiempo real
- Registro y búsqueda avanzada de reclusos
- Gestión de hospitalizaciones y alertas
- Generación de certificados y reportes oficiales en PDF
- Acceso seguro por roles (incluyendo Director General)
- Formularios oficiales digitalizados (antecedentes penales, cancelación, etc.)
- Exportación a PDF y Excel
- Mapa de centros penitenciarios
- Auditoría y logs de acciones
- Soporte multiplataforma: Web, Android, iOS, macOS, Linux, Windows

## Build y despliegue para producción

### 1. Requisitos previos
- Flutter 3.x instalado y configurado
- Xcode (para iOS/macOS), Android Studio (para Android)
- Acceso a Google Play Console y App Store Connect (para publicación)

### 2. Compilación automática
Ejecuta el script de build de producción:

```bash
./scripts/build_production.sh
```

Esto generará builds optimizados para Android (.apk, .aab), iOS, Web, macOS, Linux y Windows en la carpeta `builds/production/`.

### 3. Despliegue
- **Google Play Store:** Sube el archivo `.aab` generado a Google Play Console, completa la información y envía para revisión.
- **App Store:** Abre el proyecto en Xcode, firma el código y sube a App Store Connect.
- **Web:** Sube el contenido de la carpeta `web/` a tu servidor web.
- **Desktop:** Usa los ejecutables generados para macOS, Linux o Windows.

### 4. Presentación y pruebas
- Ejecuta la app en simulador/emulador o dispositivo real para mostrar todas las funcionalidades.
- Prueba la generación de PDFs oficiales y la navegación por menús y acciones rápidas.

## Contacto de soporte
- Email: soporte@penitsystem.ge
- Teléfono: +240 555 012345
- Web: https://penitsystem.ge

## Notas finales
- El sistema está optimizado para producción y cumple con los estándares de seguridad y privacidad requeridos.
- Para personalizaciones, contacta al equipo de soporte.

---

© 2025 PenitSystem GeoSecure Quantum. Todos los derechos reservados. 