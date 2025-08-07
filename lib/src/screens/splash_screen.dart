import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _progressValue;
  late Animation<Color?> _backgroundGradient;

  double _progress = 0.0;
  int _currentStep = 0;
  final List<String> _loadingSteps = [
    'Inicializando sistema...',
    'Cargando módulos de seguridad...',
    'Conectando con base de datos...',
    'Verificando permisos...',
    'Sistema listo',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Controlador para el logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Controlador para el texto
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Controlador para el progreso
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Controlador para el fondo
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Animaciones del logo
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Animaciones del texto
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Animación del progreso
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Animación del fondo
    _backgroundGradient = ColorTween(
      begin: const Color(0xFF0A2342),
      end: const Color(0xFF2CA6A4),
    ).animate(CurvedAnimation(
        parent: _backgroundController, curve: Curves.easeInOut));
  }

  void _startLoadingSequence() async {
    // Iniciar animaciones
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    _backgroundController.repeat(reverse: true);

    // Simular carga progresiva
    _progressController.addListener(() {
      setState(() {
        _progress = _progressValue.value;
        _currentStep = (_progress * (_loadingSteps.length - 1)).round();
      });
    });

    // Navegar después de completar
    await Future.delayed(const Duration(milliseconds: 2500));
    _navigateNext();
  }

  void _navigateNext() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // TEMPORAL: Forzar login como Director General para testing
    if (!auth.isLoggedIn) {
      try {
        // Simular login como Director General
        await auth.login('Isacio97', '1234', 'Director General');
      } catch (e) {
        // Si falla el login, ir a la pantalla de login
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
    }

    if (auth.isLoggedIn && auth.role != null) {
      // Navegar directamente a la gestión de alimentos para testing
      Navigator.of(context).pushReplacementNamed('/food-management');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundGradient.value ?? const Color(0xFF0A2342),
                  const Color(0xFF2CA6A4),
                  const Color(0xFF0A2342),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Partículas animadas de fondo
                _buildParticles(),

                // Contenido principal
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Transform.rotate(
                              angle: _logoRotation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    'assets/icons/camouflage_pn.PNG',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Texto animado
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Opacity(
                              opacity: _fadeIn.value,
                              child: const Column(
                                children: [
                                  Text(
                                    'PenitSystem Quantum',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sistema Penitenciario Nacional 2025',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Barra de progreso
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            width: 300,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // Texto de estado
                                Text(
                                  _loadingSteps[_currentStep],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 20),

                                // Barra de progreso
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _progress,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.blueAccent
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blueAccent
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Porcentaje
                                Text(
                                  '${(_progress * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticles() {
    return CustomPaint(
      painter: ParticlePainter(),
      size: Size.infinite,
    );
  }
}

class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 20; i++) {
      final x = (random + i * 123) % size.width;
      final y = (random + i * 456) % size.height;
      final radius = 1.0 + (i % 3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
