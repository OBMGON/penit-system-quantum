import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as helmet from 'helmet';
import * as compression from 'compression';
import * as rateLimit from 'express-rate-limit';
import * as slowDown from 'express-slow-down';
import { AppModule } from './app.module';
import { LoggerService } from './common/services/logger.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: new LoggerService(),
  });

  const configService = app.get(ConfigService);

  // Configuración de seguridad con Helmet
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
        connectSrc: ["'self'"],
        fontSrc: ["'self'"],
        objectSrc: ["'none'"],
        mediaSrc: ["'self'"],
        frameSrc: ["'none'"],
      },
    },
    crossOriginEmbedderPolicy: false,
  }));

  // Compresión
  app.use(compression());

  // Rate limiting
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 100, // máximo 100 requests por ventana
    message: {
      error: 'Demasiadas solicitudes desde esta IP, intente nuevamente en 15 minutos.',
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  // Slow down para prevenir ataques de fuerza bruta
  const speedLimiter = slowDown({
    windowMs: 15 * 60 * 1000, // 15 minutos
    delayAfter: 50, // permitir 50 requests sin delay
    delayMs: 500, // agregar 500ms de delay por request después del límite
  });

  app.use('/api/', limiter);
  app.use('/api/', speedLimiter);

  // CORS
  app.enableCors({
    origin: configService.get('ALLOWED_ORIGINS', 'https://obmgonplus-ia-central.web.app').split(','),
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
    maxAge: 86400, // 24 horas
  });

  // Prefijo global para API
  app.setGlobalPrefix('api/v1');

  // Validación global
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Configuración de Swagger
  const config = new DocumentBuilder()
    .setTitle('PenitSystem Quantum API')
    .setDescription('API segura para Sistema Penitenciario Nacional de Guinea Ecuatorial - Versión Quantum 2025')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('auth', 'Autenticación y autorización')
    .addTag('inmates', 'Gestión de presos')
    .addTag('hospitalizations', 'Gestión de hospitalizaciones')
    .addTag('expenses', 'Gestión de gastos')
    .addTag('documents', 'Gestión de documentos')
    .addTag('reports', 'Generación de reportes')
    .addTag('alerts', 'Sistema de alertas')
    .addTag('audit', 'Auditoría del sistema')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  // Health check endpoint
  app.get('/health', (req, res) => {
    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      environment: configService.get('NODE_ENV', 'development'),
    });
  });

  const port = configService.get('PORT', 3000);
  await app.listen(port);

  console.log(`🚀 PenitSystem Quantum Backend iniciado en puerto ${port}`);
  console.log(`📚 Documentación API disponible en: http://localhost:${port}/api/docs`);
  console.log(`🏥 Health check disponible en: http://localhost:${port}/health`);
}

bootstrap().catch((error) => {
  console.error('Error iniciando la aplicación:', error);
  process.exit(1);
}); 