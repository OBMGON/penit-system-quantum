#!/bin/bash

# ========================================
# PENITSYSTEM QUANTUM - DEPLOYMENT SCRIPT
# ========================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    error "No se encontró docker-compose.yml. Ejecuta este script desde el directorio backend/"
fi

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    error "Docker no está instalado. Por favor instala Docker primero."
fi

if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose no está instalado. Por favor instala Docker Compose primero."
fi

# Verificar archivo .env
if [ ! -f ".env" ]; then
    warn "No se encontró archivo .env. Copiando desde env.example..."
    cp env.example .env
    warn "Por favor configura las variables de entorno en .env antes de continuar."
    exit 1
fi

# Función para backup
backup_database() {
    log "Creando backup de la base de datos..."
    docker-compose exec -T postgres pg_dump -U postgres penitsystem_quantum > "backup_$(date +%Y%m%d_%H%M%S).sql"
    log "Backup creado exitosamente."
}

# Función para verificar salud de los servicios
check_health() {
    log "Verificando salud de los servicios..."
    
    # Verificar PostgreSQL
    if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
        log "✅ PostgreSQL está funcionando"
    else
        error "❌ PostgreSQL no está funcionando"
    fi
    
    # Verificar Redis
    if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        log "✅ Redis está funcionando"
    else
        error "❌ Redis no está funcionando"
    fi
    
    # Verificar Backend
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        log "✅ Backend está funcionando"
    else
        error "❌ Backend no está funcionando"
    fi
}

# Función para mostrar logs
show_logs() {
    log "Mostrando logs de los servicios..."
    docker-compose logs --tail=50
}

# Función para reiniciar servicios
restart_services() {
    log "Reiniciando servicios..."
    docker-compose restart
    sleep 10
    check_health
}

# Función para actualizar
update() {
    log "Actualizando servicios..."
    
    # Backup antes de actualizar
    backup_database
    
    # Pull de las últimas imágenes
    docker-compose pull
    
    # Rebuild y restart
    docker-compose up -d --build
    
    # Esperar a que los servicios estén listos
    log "Esperando a que los servicios estén listos..."
    sleep 30
    
    # Verificar salud
    check_health
    
    log "✅ Actualización completada exitosamente"
}

# Función para deploy inicial
deploy() {
    log "🚀 Iniciando despliegue de PenitSystem Quantum Backend..."
    
    # Crear directorios necesarios
    mkdir -p logs uploads backups ssl
    
    # Generar certificados SSL auto-firmados (para desarrollo)
    if [ ! -f "ssl/cert.pem" ]; then
        log "Generando certificados SSL auto-firmados..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem -out ssl/cert.pem \
            -subj "/C=GQ/ST=Malabo/L=Malabo/O=PenitSystem/CN=localhost"
    fi
    
    # Construir y levantar servicios
    log "Construyendo y levantando servicios..."
    docker-compose up -d --build
    
    # Esperar a que los servicios estén listos
    log "Esperando a que los servicios estén listos..."
    sleep 45
    
    # Verificar salud
    check_health
    
    # Ejecutar migraciones (si existen)
    if docker-compose exec -T backend npm run migrate > /dev/null 2>&1; then
        log "✅ Migraciones ejecutadas"
    else
        warn "No se encontraron migraciones para ejecutar"
    fi
    
    log "🎉 ¡Despliegue completado exitosamente!"
    log ""
    log "📊 URLs de acceso:"
    log "   Backend API: http://localhost:3000"
    log "   Swagger Docs: http://localhost:3000/docs"
    log "   Health Check: http://localhost:3000/health"
    log "   Prometheus: http://localhost:9090"
    log "   Grafana: http://localhost:3001 (admin/admin123)"
    log ""
    log "🔐 Configuración de seguridad:"
    log "   - Rate limiting habilitado"
    log "   - SSL/TLS configurado"
    log "   - Headers de seguridad activos"
    log "   - Monitoreo con Prometheus/Grafana"
}

# Función para detener servicios
stop() {
    log "Deteniendo servicios..."
    docker-compose down
    log "✅ Servicios detenidos"
}

# Función para mostrar estado
status() {
    log "Estado de los servicios:"
    docker-compose ps
    echo ""
    log "Uso de recursos:"
    docker stats --no-stream
}

# Función para limpiar
cleanup() {
    warn "⚠️  Esto eliminará todos los datos. ¿Estás seguro? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "Limpiando todos los datos..."
        docker-compose down -v
        docker system prune -f
        log "✅ Limpieza completada"
    else
        log "Limpieza cancelada"
    fi
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  deploy     - Desplegar servicios por primera vez"
    echo "  update     - Actualizar servicios existentes"
    echo "  restart    - Reiniciar servicios"
    echo "  stop       - Detener servicios"
    echo "  status     - Mostrar estado de servicios"
    echo "  logs       - Mostrar logs"
    echo "  health     - Verificar salud de servicios"
    echo "  backup     - Crear backup de base de datos"
    echo "  cleanup    - Limpiar todos los datos (¡CUIDADO!)"
    echo "  help       - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 deploy    # Desplegar por primera vez"
    echo "  $0 update    # Actualizar servicios"
    echo "  $0 status    # Ver estado actual"
}

# Manejo de argumentos
case "${1:-help}" in
    deploy)
        deploy
        ;;
    update)
        update
        ;;
    restart)
        restart_services
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    logs)
        show_logs
        ;;
    health)
        check_health
        ;;
    backup)
        backup_database
        ;;
    cleanup)
        cleanup
        ;;
    help|*)
        show_help
        ;;
esac 