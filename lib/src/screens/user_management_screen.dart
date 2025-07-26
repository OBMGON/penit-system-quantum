import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import 'change_password_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final availableRoles = authProvider.getAvailableRoles();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuarios del Sistema',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestión de credenciales y permisos de acceso',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: availableRoles.length,
                itemBuilder: (context, index) {
                  final role = availableRoles[index];
                  final credentials = authProvider.getUserCredentials(role);

                  return ModernCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getRoleIcon(role),
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      role,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _getRoleDescription(role),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Credenciales:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      'Usuario: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(credentials?['username'] ?? 'N/A'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text(
                                      'Contraseña: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Text('••••••••'),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${credentials?['password'] ?? 'N/A'})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _changePassword(role),
                                  icon: const Icon(Icons.lock_reset),
                                  label: const Text('Cambiar Contraseña'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showPermissions(role),
                                  icon: const Icon(Icons.security),
                                  label: const Text('Ver Permisos'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Director General':
        return Icons.admin_panel_settings;
      case 'Secretaría':
      case 'Secretaría Bata':
      case 'Secretaría Mongomo':
        return Icons.people;
      case 'Gestión de Medicamentos':
        return Icons.medication;
      case 'Gestión de Alimentos':
        return Icons.restaurant;
      case 'Jefe de Seguridad':
        return Icons.security;
      case 'Funcionario':
        return Icons.person;
      case 'Auditor':
        return Icons.assessment;
      default:
        return Icons.person;
    }
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'Director General':
        return 'Control total del sistema y supervisión institucional';
      case 'Secretaría':
        return 'Gestión administrativa y documental general';
      case 'Secretaría Bata':
        return 'Gestión administrativa específica de Bata';
      case 'Secretaría Mongomo':
        return 'Gestión administrativa específica de Mongomo';
      case 'Gestión de Medicamentos':
        return 'Control de inventario y distribución de medicamentos';
      case 'Gestión de Alimentos':
        return 'Control de inventario y distribución de alimentos';
      case 'Jefe de Seguridad':
        return 'Control de seguridad y acceso';
      case 'Funcionario':
        return 'Acceso básico al sistema';
      case 'Auditor':
        return 'Revisión y auditoría del sistema';
      default:
        return 'Rol del sistema';
    }
  }

  void _changePassword(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(targetRole: role),
      ),
    );
  }

  void _showPermissions(String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permisos de $role'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _getPermissionsList(role),
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

  List<Widget> _getPermissionsList(String role) {
    final authProvider = context.read<AuthProvider>();
    final permissions = <Widget>[];

    // Simular permisos basados en el rol
    switch (role) {
      case 'Director General':
        permissions.addAll([
          _buildPermissionItem('Control total del sistema', true),
          _buildPermissionItem('Gestión de usuarios', true),
          _buildPermissionItem('Acceso a todos los módulos', true),
          _buildPermissionItem('Aprobación de documentos', true),
          _buildPermissionItem('Generación de reportes', true),
          _buildPermissionItem('Auditoría del sistema', true),
        ]);
        break;
      case 'Secretaría':
      case 'Secretaría Bata':
      case 'Secretaría Mongomo':
        permissions.addAll([
          _buildPermissionItem('Gestión de reclusos', true),
          _buildPermissionItem('Escáner de documentos', true),
          _buildPermissionItem('Envío de documentos', true),
          _buildPermissionItem('Acceso limitado a reportes', true),
          _buildPermissionItem('Gestión de documentos', false),
        ]);
        break;
      case 'Gestión de Medicamentos':
        permissions.addAll([
          _buildPermissionItem('Gestión de medicamentos', true),
          _buildPermissionItem('Control de inventario', true),
          _buildPermissionItem('Escáner de documentos', true),
          _buildPermissionItem('Reportes de medicamentos', true),
        ]);
        break;
      case 'Gestión de Alimentos':
        permissions.addAll([
          _buildPermissionItem('Gestión de alimentos', true),
          _buildPermissionItem('Control de inventario', true),
          _buildPermissionItem('Escáner de documentos', true),
          _buildPermissionItem('Reportes de alimentos', true),
        ]);
        break;
      default:
        permissions.add(_buildPermissionItem('Acceso básico', true));
    }

    return permissions;
  }

  Widget _buildPermissionItem(String permission, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            color: hasPermission ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              permission,
              style: TextStyle(
                color: hasPermission ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
