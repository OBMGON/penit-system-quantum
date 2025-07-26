import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual de Usuario'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '🎯 Introducción',
              'El Sistema Penitenciario Nacional es una plataforma integral para la gestión de centros penitenciarios en Guinea Ecuatorial.',
            ),
            _buildSection(
              '🔐 Acceso al Sistema',
              '1. Selecciona tu rol en el dropdown\n2. Ingresa tu usuario y contraseña\n3. Presiona "Entrar"',
            ),
            _buildSection(
              '📊 Dashboard',
              'El dashboard muestra estadísticas nacionales en tiempo real, incluyendo:\n• Total de reclusos\n• Capacidad de centros\n• Alertas activas\n• Gráficos interactivos',
            ),
            _buildSection(
              '👥 Gestión de Reclusos',
              '• Registrar nuevos reclusos con OCR automático\n• Buscar y consultar información\n• Gestionar hospitalizaciones\n• Generar certificados',
            ),
            _buildSection(
              '🏥 Hospitalizaciones',
              '• Registrar hospitalizaciones\n• Seguimiento médico\n• Historial clínico\n• Alertas médicas',
            ),
            _buildSection(
              '📋 Reportes',
              '• Generar reportes automáticos\n• Exportar en PDF/Excel\n• Estadísticas detalladas\n• Históricos',
            ),
            _buildSection(
              '⚠️ Alertas',
              '• Sistema de alertas inteligente\n• Notificaciones automáticas\n• Gestión de incidentes\n• Seguimiento de eventos',
            ),
            _buildSection(
              '🔍 Auditoría',
              '• Logs de todas las acciones\n• Trazabilidad completa\n• Exportación de registros\n• Cumplimiento normativo',
            ),
            _buildSection(
              '⚙️ Configuración',
              '• Gestión de usuarios y roles\n• Configuración institucional\n• Sincronización de datos\n• Seguridad y encriptación',
            ),
            _buildSection(
              '🔄 Sincronización',
              '• Sincronización automática\n• Modo offline/online\n• Resolución de conflictos\n• Backup automático',
            ),
            _buildSection(
              '🔒 Seguridad',
              '• Encriptación AES-256\n• Autenticación por roles\n• Logs de auditoría\n• Protección de datos sensibles',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17643A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
