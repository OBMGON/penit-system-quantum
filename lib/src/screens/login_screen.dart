import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;
  String? _selectedRole;
  bool _loading = false;

  final List<String> _roles = [
    'Director General',
    'Secretaría',
    'Secretaría Bata',
    'Secretaría Mongomo',
    'Gestión de Medicamentos',
    'Gestión de Alimentos',
    'Jefe de Seguridad',
    'Funcionario',
    'Auditor',
  ];

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
        _error = null;
      });

      try {
        final user = _userController.text.trim();
        final pass = _passController.text.trim();
        final role = _selectedRole;

        if (role != null && _roles.contains(role)) {
          // Usar el AuthProvider para hacer login
          await Provider.of<AuthProvider>(context, listen: false)
              .login(user, pass, role);

          setState(() {
            _loading = false;
          });

          Navigator.pushReplacementNamed(context, '/main');
        } else {
          setState(() {
            _loading = false;
            _error = 'Por favor selecciona un rol válido';
          });
        }
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Usuario, contraseña o rol incorrectos';
        });
      }
    }
  }

  void _showCredentials() {
    final credentials = AuthProvider.userCredentials;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credenciales del Sistema'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: credentials.entries.map((entry) {
              final role = entry.key;
              final userCreds = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usuario: ${userCreds['username']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Contraseña: ${userCreds['password']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Sombra suave detrás de la tarjeta
          Center(
            child: Container(
              width: isWide ? 440 : 340,
              height: 420,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
            ),
          ),
          // Login glassmorphism
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 36),
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 420 : double.infinity,
                      minWidth: 320,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo institucional (temporal: icono policía)
                          const Icon(Icons.local_police_rounded,
                              size: 56, color: Color(0xFF17643A)),
                          const SizedBox(height: 8),
                          const Text(
                            'Acceso Institucional',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF17643A),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                            items: _roles
                                .map((role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role),
                                    ))
                                .toList(),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Seleccione un rol institucional'
                                : null,
                            onChanged: (v) => setState(() => _selectedRole = v),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _userController,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Ingrese usuario'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Ingrese contraseña'
                                : null,
                            onFieldSubmitted: (_) => _login(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF17643A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                elevation: 2,
                              ),
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 26,
                                          height: 26,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                            strokeWidth: 3.2,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Text('Verificando...'),
                                      ],
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _showCredentials,
                            child: const Text(
                              'Ver Credenciales del Sistema',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
