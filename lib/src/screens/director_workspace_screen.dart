import 'package:flutter/material.dart';

class DirectorWorkspaceScreen extends StatefulWidget {
  const DirectorWorkspaceScreen({super.key});

  @override
  State<DirectorWorkspaceScreen> createState() =>
      _DirectorWorkspaceScreenState();
}

class _DirectorWorkspaceScreenState extends State<DirectorWorkspaceScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _glowAnimation;

  // Estado del sistema
  bool _isEmergencyMode = false;
  bool _isLockdownActive = false;
  final int _activeAlerts = 5;
  int _totalInmates = 0;
  final int _criticalCases = 5;

  // Datos de reclusos por ciudad
  Map<String, int> _inmatesByCity = {
    'Bata': 0,
    'Malabo': 0,
    'Evinayong': 0,
  };

  @override
  void initState() {
    super.initState();

    // Controladores de animación
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Animaciones
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
    _glowController.repeat(reverse: true);

    // Cargar datos
    _loadData();
  }

  void _loadData() {
    // Simular datos de reclusos por ciudad
    _inmatesByCity = {
      'Bata': 45,
      'Malabo': 32,
      'Evinayong': 18,
    };

    _totalInmates = _inmatesByCity.values.reduce((a, b) => a + b);

    setState(() {});
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Efectos de fondo
            _buildBackgroundEffects(),
            // Línea de escaneo
            _buildScanOverlay(),
            // Contenido principal
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header del centro de mando
                      _buildCommandCenterHeader(),
                      const SizedBox(height: 20),
                      // Estado del director
                      _buildStatusOverview(),
                      const SizedBox(height: 20),
                      // Estadísticas por ciudad
                      _buildCityStatistics(),
                      const SizedBox(height: 20),
                      // Funciones principales
                      _buildMainFunctions(),
                      const SizedBox(height: 20),
                      // Búsqueda inteligente
                      _buildSmartSearch(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCenterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.2),
            const Color(0xFF00D4FF).withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Fila superior con logo y título
          Row(
            children: [
              // Logo del sistema
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Título del sistema
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CENTRO DE MANDO NACIONAL',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Sistema Penitenciario - Control Total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Controles de emergencia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildEmergencyButton(
                  Icons.warning_amber_rounded,
                  'EMERGENCIA',
                  Colors.red,
                  () => _toggleEmergencyMode(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEmergencyButton(
                  Icons.lock,
                  'LOCKDOWN',
                  Colors.orange,
                  () => _toggleLockdown(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEmergencyButton(
                  Icons.logout,
                  'SALIR',
                  Colors.purple,
                  () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
      IconData icon, String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.1),
            const Color(0xFF00D4FF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIRECTOR GENERAL',
                      style: TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Control Total del Sistema Penitenciario Nacional',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator('SISTEMA OPERATIVO', Colors.green),
              _buildStatusIndicator('CONECTADO', const Color(0xFF00D4FF)),
              _buildStatusIndicator('SEGURIDAD MÁXIMA', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String text, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCityStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF00D4FF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'POBLACIÓN POR CIUDAD',
              style: TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth > 600 ? 3 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth > 600 ? 1.2 : 2.5,
              children: _inmatesByCity.entries.map((entry) {
                return _buildCityCard(entry.key, entry.value);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCityCard(String city, int inmates) {
    Color color;
    IconData icon;

    switch (city) {
      case 'Bata':
        color = Colors.blue;
        icon = Icons.location_city;
        break;
      case 'Malabo':
        color = Colors.green;
        icon = Icons.location_city;
        break;
      case 'Evinayong':
        color = Colors.orange;
        icon = Icons.location_city;
        break;
      default:
        color = Colors.grey;
        icon = Icons.location_city;
    }

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ciudad: $city - Reclusos: $inmates'),
            backgroundColor: color,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                inmates.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                city,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'Reclusos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFunctions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF00D4FF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'FUNCIONES PRINCIPALES',
              style: TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth > 600 ? 1.1 : 1.3,
              children: [
                _buildFunctionCard(
                  'GESTIÓN DE ALIMENTOS',
                  Icons.restaurant,
                  'Control de raciones y menús',
                  'Administrar suministros',
                  Colors.green,
                  () => Navigator.pushNamed(context, '/food-management'),
                ),
                _buildFunctionCard(
                  'HOSPITAL',
                  Icons.medical_services,
                  'Atención médica',
                  'Control de salud',
                  Colors.red,
                  () => Navigator.pushNamed(context, '/hospital'),
                ),
                _buildFunctionCard(
                  'REGISTROS DE ENTRADA',
                  Icons.person_add,
                  'Nuevos reclusos',
                  'Documentación inicial',
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/register'),
                ),
                _buildFunctionCard(
                  'VER DOCUMENTOS',
                  Icons.folder_open,
                  'Todos los documentos',
                  'Acceso completo',
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/documents'),
                ),
                _buildFunctionCard(
                  'CERTIFICADO ANTECEDENTES',
                  Icons.description,
                  'Solicitud de certificado',
                  'Antecedentes penales',
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/criminal-record'),
                ),
                _buildFunctionCard(
                  'CANCELACIÓN ANTECEDENTES',
                  Icons.cancel,
                  'Solicitud de cancelación',
                  'Limpieza de expediente',
                  Colors.teal,
                  () => Navigator.pushNamed(context, '/cancellation-request'),
                ),
                _buildFunctionCard(
                  'ESCANER INTELIGENTE',
                  Icons.document_scanner,
                  'Escanear documentos',
                  'Guardar en sistema',
                  Colors.indigo,
                  () => Navigator.pushNamed(context, '/smart-scanner'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFunctionCard(String title, IconData icon, String subtitle,
      String description, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.1),
            const Color(0xFF00D4FF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'BÚSQUEDA INTELIGENTE',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar recluso, documento, expediente...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF00D4FF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                Navigator.pushNamed(context, '/search', arguments: {
                  'query': value.trim(),
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSearchFilter('Reclusos', Icons.people),
              _buildSearchFilter('Documentos', Icons.description),
              _buildSearchFilter('Expedientes', Icons.folder),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (label == 'Reclusos') {
          Navigator.pushNamed(context, '/search',
              arguments: {'filter': 'inmates'});
        } else if (label == 'Documentos') {
          Navigator.pushNamed(context, '/documents');
        } else {
          Navigator.pushNamed(context, '/search',
              arguments: {'filter': 'files'});
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return CustomPaint(
      painter: BackgroundPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanLinePainter(_scanAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  void _toggleEmergencyMode() {
    setState(() {
      _isEmergencyMode = !_isEmergencyMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEmergencyMode
            ? 'MODO EMERGENCIA ACTIVADO'
            : 'MODO EMERGENCIA DESACTIVADO'),
        backgroundColor: _isEmergencyMode ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleLockdown() {
    setState(() {
      _isLockdownActive = !_isLockdownActive;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isLockdownActive ? 'LOCKDOWN ACTIVADO' : 'LOCKDOWN DESACTIVADO'),
        backgroundColor: _isLockdownActive ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.1)
      ..strokeWidth = 1;

    // Dibujar líneas de cuadrícula
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.6)
      ..strokeWidth = 2;

    final y = size.height * progress;

    // Línea de escaneo
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );

    // Efecto de brillo
    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.3)
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
