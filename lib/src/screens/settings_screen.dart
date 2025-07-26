import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF17643A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '👥 Gestión de Usuarios',
              [
                _buildSettingTile(
                  icon: Icons.people,
                  title: 'Administrar usuarios y roles',
                  subtitle: 'Agregar, editar o eliminar usuarios del sistema',
                  onTap: () => Navigator.pushNamed(context, '/user-management'),
                ),
                _buildSettingTile(
                  icon: Icons.security,
                  title: 'Control de acceso',
                  subtitle: 'Configurar permisos y roles de seguridad',
                  onTap: () => _showComingSoon('Control de acceso'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '⚙️ Parámetros Institucionales',
              [
                _buildSettingTile(
                  icon: Icons.business,
                  title: 'Configurar institución',
                  subtitle: 'Nombre, logo y datos de la institución',
                  onTap: () =>
                      Navigator.pushNamed(context, '/institutional-config'),
                ),
                _buildSettingTile(
                  icon: Icons.location_city,
                  title: 'Gestionar cárceles',
                  subtitle: 'Agregar o modificar centros penitenciarios',
                  onTap: () =>
                      Navigator.pushNamed(context, '/prison-management'),
                ),
                _buildSettingTile(
                  icon: Icons.language,
                  title: 'Idioma del sistema',
                  subtitle: 'Español (predeterminado)',
                  onTap: () => _showComingSoon('Configuración de idioma'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '🌙 Apariencia',
              [
                SwitchListTile(
                  title: const Text('Modo oscuro'),
                  subtitle: const Text('Cambiar entre tema claro y oscuro'),
                  value: isDark,
                  onChanged: (value) {
                    themeProvider
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                  secondary: const Icon(Icons.nightlight_round),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              '🛠️ Soporte y Ayuda',
              [
                _buildSettingTile(
                  icon: Icons.menu_book,
                  title: 'Manual de usuario',
                  subtitle: 'Guía de uso del sistema',
                  onTap: () => Navigator.pushNamed(context, '/user-manual'),
                ),
                _buildSettingTile(
                  icon: Icons.support_agent,
                  title: 'Soporte técnico',
                  subtitle: 'Contactar al equipo de soporte',
                  onTap: () => _showComingSoon('Soporte técnico'),
                ),
                _buildSettingTile(
                  icon: Icons.info,
                  title: 'Acerca del sistema',
                  subtitle: 'Información y créditos',
                  onTap: () => _showComingSoon('Acerca del sistema'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF17643A)),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    // Puedes implementar un dialogo o snackbar si lo deseas
  }
}
