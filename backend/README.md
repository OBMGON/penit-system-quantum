# PenitSystem Quantum Backend

Backend seguro para Sistema Penitenciario Nacional de Guinea Ecuatorial - Versión Quantum 2025

## 🚀 Características

- **Seguridad Avanzada**: JWT, rate limiting, CORS, Helmet, validación
- **Autenticación MFA**: 2FA con QR codes y SMS
- **Base de Datos**: PostgreSQL con TypeORM
- **API REST**: Documentación con Swagger
- **Logging**: Winston con rotación de archivos
- **Monitoreo**: Health checks y métricas
- **Colas**: Redis + Bull para tareas asíncronas
- **Notificaciones**: Email y SMS
- **Auditoría**: Logs completos de todas las acciones
- **Backup**: Automático y manual

## 📋 Requisitos

- Node.js 18+
- PostgreSQL 14+
- Redis 6+
- npm o yarn

## 🛠️ Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd backend
```

2. **Instalar dependencias**
```bash
npm install
```

3. **Configurar variables de entorno**
```bash
cp .env.example .env
```

4. **Configurar base de datos**
```bash
# Crear base de datos PostgreSQL
createdb penitsystem_quantum

# Ejecutar migraciones
npm run migrate

# Ejecutar seeds (datos iniciales)
npm run seed
```

5. **Iniciar Redis**
```bash
redis-server
```

6. **Iniciar el servidor**
```bash
# Desarrollo
npm run start:dev

# Producción
npm run build
npm run start:prod
```

## 🔧 Configuración

### Variables de Entorno (.env)

```env
# Servidor
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Base de Datos
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_DATABASE=penitsystem_quantum

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your_refresh_secret_key
JWT_REFRESH_EXPIRES_IN=7d

# CORS
ALLOWED_ORIGINS=https://obmgonplus-ia-central.web.app,http://localhost:3000

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# SMS (Twilio)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1234567890

# MFA
MFA_SECRET=your_mfa_secret_key

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=info
LOG_FILE_PATH=./logs

# Backup
BACKUP_PATH=./backups
BACKUP_RETENTION_DAYS=30
```

## 📚 API Endpoints

### Autenticación
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/refresh` - Refrescar token
- `POST /api/v1/auth/logout` - Cerrar sesión
- `POST /api/v1/auth/mfa/enable` - Habilitar 2FA
- `POST /api/v1/auth/mfa/verify` - Verificar código 2FA

### Presos
- `GET /api/v1/inmates` - Listar presos
- `POST /api/v1/inmates` - Crear preso
- `GET /api/v1/inmates/:id` - Obtener preso
- `PUT /api/v1/inmates/:id` - Actualizar preso
- `DELETE /api/v1/inmates/:id` - Eliminar preso

### Hospitalizaciones
- `GET /api/v1/hospitalizations` - Listar hospitalizaciones
- `POST /api/v1/hospitalizations` - Crear hospitalización
- `PUT /api/v1/hospitalizations/:id` - Actualizar hospitalización

### Gastos
- `GET /api/v1/expenses` - Listar gastos
- `POST /api/v1/expenses` - Crear gasto
- `PUT /api/v1/expenses/:id` - Actualizar gasto

### Documentos
- `GET /api/v1/documents` - Listar documentos
- `POST /api/v1/documents/upload` - Subir documento
- `GET /api/v1/documents/:id` - Descargar documento

### Reportes
- `GET /api/v1/reports` - Listar reportes
- `POST /api/v1/reports/generate` - Generar reporte
- `GET /api/v1/reports/:id` - Descargar reporte

### Alertas
- `GET /api/v1/alerts` - Listar alertas
- `POST /api/v1/alerts` - Crear alerta
- `PUT /api/v1/alerts/:id` - Actualizar alerta

### Auditoría
- `GET /api/v1/audit/logs` - Obtener logs de auditoría
- `GET /api/v1/audit/export` - Exportar logs

## 🔐 Seguridad

### Autenticación JWT
- Tokens de acceso con expiración de 15 minutos
- Tokens de refresh con expiración de 7 días
- Rotación automática de tokens

### Rate Limiting
- 100 requests por 15 minutos por IP
- Slow down después de 50 requests
- Bloqueo temporal por IP maliciosa

### Validación
- Validación de entrada con class-validator
- Sanitización de datos
- Prevención de inyección SQL

### CORS
- Configuración estricta de orígenes permitidos
- Headers de seguridad
- Credenciales habilitadas

### Helmet
- Headers de seguridad HTTP
- Content Security Policy
- Prevención de ataques XSS

## 📊 Monitoreo

### Health Checks
- `GET /health` - Estado del servidor
- `GET /api/v1/health` - Estado de la API
- `GET /api/v1/health/database` - Estado de la base de datos
- `GET /api/v1/health/redis` - Estado de Redis

### Logging
- Logs estructurados con Winston
- Rotación diaria de archivos
- Niveles: error, warn, info, debug
- Logs de auditoría separados

### Métricas
- Requests por minuto
- Tiempo de respuesta
- Errores por endpoint
- Uso de recursos

## 🚀 Despliegue

### Docker

```bash
# Construir imagen
docker build -t penitsystem-quantum-backend .

# Ejecutar contenedor
docker run -d \
  --name penitsystem-backend \
  -p 3000:3000 \
  --env-file .env \
  penitsystem-quantum-backend
```

### Docker Compose

```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - postgres
      - redis
    volumes:
      - ./logs:/app/logs
      - ./backups:/app/backups

  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: penitsystem_quantum
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: your_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6-alpine
    command: redis-server --requirepass your_redis_password

volumes:
  postgres_data:
```

### Producción

1. **Configurar servidor**
```bash
# Instalar Node.js y PM2
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# Instalar PostgreSQL y Redis
sudo apt-get install postgresql postgresql-contrib redis-server
```

2. **Configurar firewall**
```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3000
sudo ufw enable
```

3. **Configurar Nginx (opcional)**
```nginx
server {
    listen 80;
    server_name api.penitsystem-quantum.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

4. **Iniciar con PM2**
```bash
pm2 start dist/main.js --name "penitsystem-backend"
pm2 startup
pm2 save
```

## 🔧 Comandos Útiles

```bash
# Desarrollo
npm run start:dev          # Iniciar en modo desarrollo
npm run start:debug        # Iniciar con debug

# Producción
npm run build             # Construir para producción
npm run start:prod        # Iniciar en producción

# Base de datos
npm run migrate           # Ejecutar migraciones
npm run migrate:generate  # Generar nueva migración
npm run migrate:revert    # Revertir última migración
npm run seed              # Ejecutar seeds

# Testing
npm run test              # Ejecutar tests
npm run test:watch        # Tests en modo watch
npm run test:cov          # Tests con cobertura
npm run test:e2e          # Tests end-to-end

# Linting y formateo
npm run lint              # Linting
npm run format            # Formatear código

# Logs
pm2 logs penitsystem-backend    # Ver logs de PM2
tail -f logs/app.log           # Ver logs de aplicación
```

## 📝 Logs

Los logs se guardan en el directorio `./logs/`:

- `app.log` - Logs generales de la aplicación
- `error.log` - Solo errores
- `audit.log` - Logs de auditoría
- `access.log` - Logs de acceso HTTP

## 🔄 Backup

### Automático
- Backup diario a las 2:00 AM
- Retención de 30 días
- Compresión automática

### Manual
```bash
npm run backup:create     # Crear backup manual
npm run backup:restore    # Restaurar backup
```

## 🆘 Troubleshooting

### Problemas Comunes

1. **Error de conexión a base de datos**
   - Verificar que PostgreSQL esté ejecutándose
   - Verificar credenciales en .env
   - Verificar que la base de datos exista

2. **Error de Redis**
   - Verificar que Redis esté ejecutándose
   - Verificar configuración en .env

3. **Error de JWT**
   - Verificar JWT_SECRET en .env
   - Verificar que el token no haya expirado

4. **Rate limiting**
   - Verificar límites en configuración
   - Verificar logs de rate limiting

### Logs de Debug

```bash
# Habilitar logs de debug
export LOG_LEVEL=debug
npm run start:dev
```

## 📞 Soporte

Para soporte técnico:
- Email: support@penitsystem-quantum.com
- Documentación: https://docs.penitsystem-quantum.com
- Issues: https://github.com/penitsystem-quantum/backend/issues

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para más detalles. 