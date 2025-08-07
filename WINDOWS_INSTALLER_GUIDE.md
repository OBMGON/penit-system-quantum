# 🖥️ GUÍA PARA CREAR INSTALADOR DE WINDOWS - PENIT SYSTEM QUANTUM

## 📋 Requisitos Previos

### Para compilar desde Windows:
- Windows 10/11
- Flutter SDK 3.32.8 o superior
- Visual Studio 2019/2022 con C++ tools
- Git

### Para compilar desde macOS/Linux:
- Usar GitHub Actions (recomendado)
- O máquina virtual Windows

## 🚀 Métodos de Compilación

### Método 1: GitHub Actions (Recomendado)

1. **Subir código a GitHub**
   ```bash
   git add .
   git commit -m "Preparar para compilación Windows"
   git push origin main
   ```

2. **Verificar el workflow**
   - Ve a tu repositorio en GitHub
   - Pestaña "Actions"
   - El workflow `Build Windows Executable` se ejecutará automáticamente

3. **Descargar el ejecutable**
   - En la pestaña Actions, busca la ejecución más reciente
   - Descarga el artifact `PenitSystem-Quantum-Windows`

### Método 2: Compilación Local en Windows

1. **Clonar el proyecto**
   ```bash
   git clone https://github.com/tu-usuario/penit-system-quantum.git
   cd penit-system-quantum
   ```

2. **Ejecutar el script de compilación**
   ```powershell
   .\scripts\build_windows.ps1
   ```

3. **O compilar manualmente**
   ```bash
   flutter clean
   flutter pub get
   flutter config --enable-windows-desktop
   flutter build windows --release
   ```

### Método 3: Usando NSIS para Instalador Profesional

1. **Instalar NSIS**
   - Descargar desde: https://nsis.sourceforge.io/
   - Instalar en Windows

2. **Compilar el proyecto**
   ```bash
   flutter build windows --release
   ```

3. **Crear el instalador**
   ```bash
   cd windows
   makensis installer.nsi
   ```

## 📦 Estructura del Ejecutable

```
PenitSystem-Quantum-Windows/
├── penit_system_geosecure_quantum_demo.exe    # Ejecutable principal
├── data/                                      # Datos de la aplicación
├── icudtl.dat                                 # Datos de internacionalización
├── README.txt                                 # Instrucciones de instalación
└── [otros archivos DLL y recursos]
```

## 🔧 Configuración del Proyecto

### Archivos importantes:
- `windows/installer.nsi` - Script NSIS para instalador
- `windows/runner/Runner.rc` - Recursos de Windows (icono, versión)
- `scripts/build_windows.ps1` - Script de automatización
- `.github/workflows/build_windows.yml` - GitHub Actions

### Personalización:
- **Icono**: Reemplazar `windows/runner/resources/app_icon.ico`
- **Versión**: Modificar `windows/runner/Runner.rc`
- **Nombre**: Cambiar en `pubspec.yaml` y `windows/installer.nsi`

## 📋 Instrucciones de Instalación para Usuarios

### Instalación Simple:
1. Descargar `PenitSystem-Quantum-Windows-v1.0.0.zip`
2. Extraer en una carpeta
3. Ejecutar `penit_system_geosecure_quantum_demo.exe`

### Instalación con NSIS:
1. Descargar `PenitSystem-Quantum-Setup.exe`
2. Ejecutar como administrador
3. Seguir el asistente de instalación

## 🛠️ Solución de Problemas

### Error: "build windows only supported on Windows hosts"
- **Solución**: Usar GitHub Actions o máquina virtual Windows

### Error: "Visual Studio not found"
- **Solución**: Instalar Visual Studio con C++ tools

### Error: "Missing dependencies"
- **Solución**: Ejecutar `flutter doctor` y instalar componentes faltantes

### Error: "Permission denied"
- **Solución**: Ejecutar PowerShell como administrador

## 📊 Información del Sistema

### Requisitos Mínimos:
- **OS**: Windows 10 (versión 1903) o superior
- **RAM**: 4GB mínimo, 8GB recomendado
- **Espacio**: 500MB libre
- **Procesador**: Intel i3 o AMD equivalente

### Compatibilidad:
- ✅ Windows 10 (1903+)
- ✅ Windows 11
- ❌ Windows 8.1 o anterior
- ❌ Windows Server (no probado)

## 🔄 Actualizaciones

### Para nuevas versiones:
1. Actualizar versión en `pubspec.yaml`
2. Modificar `windows/runner/Runner.rc`
3. Actualizar `windows/installer.nsi`
4. Recompilar usando cualquiera de los métodos anteriores

## 📞 Soporte Técnico

- **Email**: soporte@penitsystem.gq
- **Documentación**: [GitHub Wiki]
- **Issues**: [GitHub Issues]

---

**Nota**: Este proceso crea un ejecutable nativo de Windows que funciona sin necesidad de Flutter instalado en la máquina del usuario. 