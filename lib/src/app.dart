import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/register_inmate_screen.dart';
import 'screens/search_inmate_screen.dart';
import 'screens/hospitalizations_screen.dart';
import 'screens/add_hospitalization_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/audit_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/institutional_config_screen.dart';
import 'screens/prison_management_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/user_manual_screen.dart';
import 'screens/criminal_record_screen.dart';
import 'screens/prison_map_screen.dart';
import 'screens/no_access_screen.dart';
import 'screens/cancellation_request_screen.dart';
import 'screens/food_management_screen.dart';
import 'screens/expense_management_screen.dart';
import 'screens/secretary_workspace_screen.dart';
import 'screens/director_workspace_screen.dart';
import 'screens/smart_scanner_screen.dart';
import 'theme/app_theme.dart';
import 'screens/medicine_management_screen.dart' as medicine;
import 'screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'PenitSystem Quantum',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      showSemanticsDebugger: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      home: const SplashScreen(),
      routes: {
        '/main': (context) => auth.isLoggedIn && auth.role != null
            ? (auth.role == 'Director General'
                ? const DirectorWorkspaceScreen()
                : auth.role == 'Secretaría'
                    ? const SecretaryWorkspaceScreen()
                    : auth.role == 'Secretaría Bata'
                        ? const SecretaryWorkspaceScreen()
                        : auth.role == 'Secretaría Mongomo'
                            ? const SecretaryWorkspaceScreen()
                            : auth.role == 'Gestión de Medicamentos'
                                ? const medicine.MedicineManagementScreen()
                                : auth.role == 'Gestión de Alimentos'
                                    ? const FoodManagementScreen()
                                    : const MainNavigationScreen())
            : const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/register': (context) => const RegisterInmateScreen(),
        '/search': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessAdvancedSearch
              ? const SearchInmateScreen()
              : const NoAccessScreen();
        },
        '/hospitalizations': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessHospitalizations
              ? const HospitalizationsScreen()
              : const NoAccessScreen();
        },
        '/reports': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessReports
              ? const ReportsScreen()
              : const NoAccessScreen();
        },
        '/settings': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessSettings
              ? const SettingsScreen()
              : const NoAccessScreen();
        },
        '/audit': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessAudit
              ? const AuditScreen()
              : const NoAccessScreen();
        },
        '/alerts': (context) => const AlertsScreen(),
        '/user-management': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessUserManagement
              ? const UserManagementScreen()
              : const NoAccessScreen();
        },
        '/institutional-config': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessConfiguration
              ? const InstitutionalConfigScreen()
              : const NoAccessScreen();
        },
        '/prison-management': (context) => const PrisonManagementScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/user-manual': (context) => const UserManualScreen(),
        '/criminal-record': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessCertificates
              ? const CriminalRecordScreen()
              : const NoAccessScreen();
        },
        '/prison-map': (context) => const PrisonMapScreen(),
        '/cancellation-request': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.isDirector) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return CancellationRequestScreen(autoFillData: args);
        },
        '/food-management': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessFoodManagement
              ? const FoodManagementScreen()
              : const NoAccessScreen();
        },
        '/expense-management': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessFoodManagement
              ? const ExpenseManagementScreen()
              : const NoAccessScreen();
        },
        '/director-workspace': (context) => const DirectorWorkspaceScreen(),
        '/secretary-workspace': (context) => const SecretaryWorkspaceScreen(),
        '/add-hospitalization': (context) => const AddHospitalizationScreen(),
        '/smart-scanner': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          return auth.canAccessScanner
              ? const SmartScannerScreen()
              : const NoAccessScreen();
        },
        // Rutas para formularios auto-rellenables
        '/certificate-request': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessDocuments) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar CertificateRequestScreen
          return const Scaffold(
            body: Center(
                child: Text('Certificate Request Screen - En desarrollo')),
          );
        },
        '/medical-report': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessHospitalizations) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar MedicalReportScreen
          return const Scaffold(
            body: Center(child: Text('Medical Report Screen - En desarrollo')),
          );
        },
        '/incident-report': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessDocuments) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar IncidentReportScreen
          return const Scaffold(
            body: Center(child: Text('Incident Report Screen - En desarrollo')),
          );
        },
        '/expense-report': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessFoodManagement) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar ExpenseReportScreen
          return const Scaffold(
            body: Center(child: Text('Expense Report Screen - En desarrollo')),
          );
        },
        '/inmate-registration': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessDocuments) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar InmateRegistrationScreen
          return const Scaffold(
            body: Center(
                child: Text('Inmate Registration Screen - En desarrollo')),
          );
        },
        '/visitor-request': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessDocuments) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar VisitorRequestScreen
          return const Scaffold(
            body: Center(child: Text('Visitor Request Screen - En desarrollo')),
          );
        },
        '/transfer-request': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessDocuments) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar TransferRequestScreen
          return const Scaffold(
            body:
                Center(child: Text('Transfer Request Screen - En desarrollo')),
          );
        },
        '/release-request': (context) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          if (!auth.canAccessDocuments) return const NoAccessScreen();

          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          // TODO: Implementar ReleaseRequestScreen
          return const Scaffold(
            body: Center(child: Text('Release Request Screen - En desarrollo')),
          );
        },
      },
    );
  }
}

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final String userName = auth.username ?? 'Usuario';
    final String userRole = auth.role ?? 'Sin rol';

    // Si es Secretaría o Director, redirigir a su workspace y no mostrar menú
    if (auth.isSecretaria) {
      return const SecretaryWorkspaceScreen();
    }
    if (auth.isDirector) {
      return const DirectorWorkspaceScreen();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('PenitSystem Quantum'),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]!
                    : Colors.white,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]!
                    : Colors.grey[100]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(userName,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(userRole,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey[700],
                            fontSize: 15)),
                  ],
                ),
              ),
              _buildMenuItem(
                  context, Icons.dashboard, 'Dashboard', '/dashboard'),
              _buildMenuItem(
                  context, Icons.person_add, 'Registrar Preso', '/register'),
              if (auth.canAccessAdvancedSearch)
                _buildMenuItem(
                    context, Icons.search, 'Buscar/Consultar', '/search'),
              if (auth.canAccessHospitalizations)
                _buildMenuItem(context, Icons.local_hospital,
                    'Hospitalizaciones', '/hospitalizations'),
              if (auth.canAccessReports)
                _buildMenuItem(
                    context, Icons.picture_as_pdf, 'Reportes', '/reports'),
              if (auth.canAccessCertificates)
                _buildMenuItem(context, Icons.gavel, 'Antecedentes Penales',
                    '/criminal-record'),
              _buildMenuItem(
                  context, Icons.map, 'Mapa de Cárceles', '/prison-map'),
              if (auth.canAccessSettings)
                _buildMenuItem(context, Icons.settings,
                    'Configuración Institucional', '/settings'),
              if (auth.canAccessAudit)
                _buildMenuItem(
                    context, Icons.event_note, 'Auditoría', '/audit'),
              if (auth.isDirector)
                _buildMenuItem(
                    context,
                    Icons.assignment_turned_in,
                    'Solicitud Cancelación Antecedentes',
                    '/cancellation-request'),
              const Divider(color: Colors.white24, height: 32),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Cerrar sesión',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  auth.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
      body: const DashboardScreen(),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String label, String? route,
      {bool soon = false}) {
    return ListTile(
      leading: Icon(icon, color: soon ? Colors.grey : const Color(0xFF17643A)),
      title: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  color: soon ? Colors.grey : Colors.black,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (soon)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Pronto',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      onTap: route != null
          ? () {
              Navigator.pushReplacementNamed(context, route);
            }
          : null,
      enabled: !soon,
      hoverColor: Colors.green.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
