# Script para compilar PenitSystem Quantum para Windows
# Ejecutar desde la raíz del proyecto

Write-Host "🚀 Iniciando compilación de PenitSystem Quantum para Windows..." -ForegroundColor Green

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto." -ForegroundColor Red
    exit 1
}

# Limpiar builds anteriores
Write-Host "🧹 Limpiando builds anteriores..." -ForegroundColor Yellow
flutter clean

# Obtener dependencias
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# Verificar configuración de Windows
Write-Host "⚙️ Configurando soporte para Windows..." -ForegroundColor Yellow
flutter config --enable-windows-desktop

# Compilar para Windows
Write-Host "🔨 Compilando para Windows..." -ForegroundColor Yellow
flutter build windows --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilación exitosa!" -ForegroundColor Green
    
    # Crear carpeta de distribución
    $distFolder = "dist\PenitSystem-Quantum-Windows"
    if (Test-Path $distFolder) {
        Remove-Item $distFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $distFolder -Force | Out-Null
    
    # Copiar archivos necesarios
    Write-Host "📁 Copiando archivos..." -ForegroundColor Yellow
    Copy-Item "build\windows\runner\Release\*" $distFolder -Recurse -Force
    
    # Crear archivo de información
    $infoContent = @"
PenitSystem Quantum - Windows Executable
========================================

Versión: 1.0.0
Fecha de compilación: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Sistema: Windows x64

Instrucciones de instalación:
1. Extraer todos los archivos a una carpeta
2. Ejecutar penit_system_geosecure_quantum_demo.exe
3. El programa se instalará automáticamente

Requisitos del sistema:
- Windows 10 o superior
- 4GB RAM mínimo
- 500MB espacio libre

Soporte técnico: soporte@penitsystem.gq
"@
    
    $infoContent | Out-File "$distFolder\README.txt" -Encoding UTF8
    
    # Crear ZIP
    $zipName = "PenitSystem-Quantum-Windows-v1.0.0.zip"
    if (Test-Path $zipName) {
        Remove-Item $zipName -Force
    }
    
    Write-Host "📦 Creando archivo ZIP..." -ForegroundColor Yellow
    Compress-Archive -Path $distFolder -DestinationPath $zipName
    
    Write-Host "🎉 ¡Compilación completada!" -ForegroundColor Green
    Write-Host "📁 Archivo creado: $zipName" -ForegroundColor Cyan
    Write-Host "📍 Ubicación: $(Get-Location)\$zipName" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Error en la compilación. Revisa los errores arriba." -ForegroundColor Red
    exit 1
} 