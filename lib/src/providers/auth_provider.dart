import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _role;
  String? _username;
  String? _authToken;
  DateTime? _loginTime;

  // Mapa de usuarios y contraseñas
  static final Map<String, Map<String, String>> _userCredentials = {
    'Director General': {'username': 'Isacio97', 'password': '1234'},
    'Secretaría': {'username': 'secretaria', 'password': '1234'},
    'Secretaría Bata': {'username': 'bata', 'password': 'bata2024'},
    'Secretaría Mongomo': {'username': 'mongomo', 'password': 'mongomo2024'},
    'Gestión de Medicamentos': {
      'username': 'medicamentos',
      'password': 'med2024'
    },
    'Gestión de Alimentos': {'username': 'alimentos', 'password': 'alim2024'},
    'Jefe de Seguridad': {'username': 'seguridad', 'password': '1234'},
    'Funcionario': {'username': 'funcionario', 'password': '1234'},
    'Auditor': {'username': 'auditor', 'password': '1234'},
  };

  String? get role => _role;
  String? get username => _username;
  String? get authToken => _authToken;
  DateTime? get loginTime => _loginTime;
  bool get isLoggedIn => _role != null && _authToken != null;

  // Getter para obtener las credenciales de todos los usuarios
  static Map<String, Map<String, String>> get userCredentials =>
      _userCredentials;

  // Métodos de control de acceso por rol
  bool get isDirector => _role == 'Director General';
  bool get isSecretaria => _role == 'Secretaría';
  bool get isJefeSeguridad => _role == 'Jefe de Seguridad';
  bool get isFuncionario => _role == 'Funcionario';
  bool get isMedico => _role == 'Médico';
  bool get isAuditor => _role == 'Auditor';

  // NUEVOS ROLES Y PERMISOS
  bool get isGestionMedicamentos => _role == 'Gestión de Medicamentos';
  bool get isGestionAlimentos => _role == 'Gestión de Alimentos';
  bool get isSecretariaBata => _role == 'Secretaría Bata';
  bool get isSecretariaMongomo => _role == 'Secretaría Mongomo';

  // Permisos específicos
  bool get canAccessSecretaryWorkspace => isSecretaria;
  bool get canAccessAdvancedSearch => isDirector || isJefeSeguridad;
  bool get canAccessHospitalizations =>
      isDirector || isJefeSeguridad || isMedico;
  bool get canAccessSettings => isDirector;
  bool get canAccessCertificates => isDirector;
  bool get canAccessReports => isDirector;
  bool get canAccessAudit => isDirector;
  bool get canAccessUserManagement => isDirector;
  bool get canAccessConfiguration => isDirector;
  bool get canExportData => isDirector;
  bool get canViewAdvancedStats => isDirector || isJefeSeguridad;
  bool get canAccessFoodManagement => isDirector || isGestionAlimentos;
  bool get canAccessMedicineManagement => isDirector || isGestionMedicamentos;
  bool get canRegisterInmates =>
      isDirector || isSecretaria || isSecretariaBata || isSecretariaMongomo;
  bool get canAccessPrisonersBata => isDirector || isSecretariaBata;
  bool get canAccessPrisonersMongomo => isDirector || isSecretariaMongomo;
  bool get canAccessScanner => true; // Todos los usuarios pueden escanear
  bool get canAccessDocuments => isDirector || isSecretaria;
  bool get canApproveDocuments => isDirector;

  Future<void> login(String username, String password, String role) async {
    bool isValid = false;

    // Verificar credenciales desde el mapa
    if (_userCredentials.containsKey(role)) {
      final credentials = _userCredentials[role]!;
      isValid = credentials['username'] == username &&
          credentials['password'] == password;
    }

    if (isValid) {
      _role = role;
      _username = username;
      _authToken = _generateAuthToken();
      _loginTime = DateTime.now();
      await _saveSessionData();
      notifyListeners();
    } else {
      throw Exception('Credenciales inválidas');
    }
  }

  // Método para cambiar contraseña de cualquier usuario
  Future<bool> changeUserPassword(
      String role, String currentPassword, String newPassword) async {
    if (!_userCredentials.containsKey(role)) {
      throw Exception('Rol de usuario no encontrado');
    }

    final credentials = _userCredentials[role]!;
    if (credentials['password'] != currentPassword) {
      throw Exception('Contraseña actual incorrecta');
    }

    // Actualizar la contraseña
    _userCredentials[role]!['password'] = newPassword;

    // Guardar en SharedPreferences para persistencia
    await _saveUserCredentials();

    notifyListeners();
    return true;
  }

  // Método para cambiar la contraseña del usuario actual
  Future<bool> changeCurrentUserPassword(
      String currentPassword, String newPassword) async {
    if (_role == null) {
      throw Exception('No hay usuario logueado');
    }

    return await changeUserPassword(_role!, currentPassword, newPassword);
  }

  // Método para obtener credenciales de un usuario específico
  Map<String, String>? getUserCredentials(String role) {
    return _userCredentials[role];
  }

  // Método para obtener todos los roles disponibles
  List<String> getAvailableRoles() {
    return _userCredentials.keys.toList();
  }

  // Guardar credenciales en SharedPreferences
  Future<void> _saveUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = <String, dynamic>{};

    _userCredentials.forEach((role, credentials) {
      credentialsJson[role] = credentials;
    });

    // Convertir a string y guardar
    await prefs.setString('user_credentials', credentialsJson.toString());
  }

  // Cargar credenciales desde SharedPreferences
  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsString = prefs.getString('user_credentials');

    if (credentialsString != null) {
      try {
        // Aquí implementarías la lógica para parsear el string JSON
        // Por ahora mantenemos las credenciales por defecto
      } catch (e) {
        // Si hay error, mantener las credenciales por defecto
      }
    }
  }

  Future<void> logout() async {
    // Limpiar datos de sesión
    await _clearSessionData();

    // Resetear variables
    _role = null;
    _username = null;
    _authToken = null;
    _loginTime = null;

    notifyListeners();
  }

  Future<void> _saveSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', _role ?? '');
    await prefs.setString('username', _username ?? '');
    await prefs.setString('authToken', _authToken ?? '');
    await prefs.setString('loginTime', _loginTime?.toIso8601String() ?? '');
  }

  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    await prefs.remove('username');
    await prefs.remove('authToken');
    await prefs.remove('loginTime');
  }

  Future<void> checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('role');
    final savedUsername = prefs.getString('username');
    final savedAuthToken = prefs.getString('authToken');
    final savedLoginTime = prefs.getString('loginTime');

    if (savedRole != null && savedUsername != null && savedAuthToken != null) {
      _role = savedRole;
      _username = savedUsername;
      _authToken = savedAuthToken;
      _loginTime =
          savedLoginTime != null ? DateTime.parse(savedLoginTime) : null;
      notifyListeners();
    }
  }

  String _generateAuthToken() {
    return 'token_${DateTime.now().millisecondsSinceEpoch}_${_username}_$_role';
  }

  // Método para verificar acceso a una funcionalidad específica
  bool hasPermission(String permission) {
    switch (permission) {
      case 'advanced_search':
        return canAccessAdvancedSearch;
      case 'hospitalizations':
        return canAccessHospitalizations;
      case 'settings':
        return canAccessSettings;
      case 'certificates':
        return canAccessCertificates;
      case 'reports':
        return canAccessReports;
      case 'audit':
        return canAccessAudit;
      case 'user_management':
        return canAccessUserManagement;
      case 'configuration':
        return canAccessConfiguration;
      case 'export_data':
        return canExportData;
      case 'advanced_stats':
        return canViewAdvancedStats;
      case 'scanner':
        return canAccessScanner;
      case 'documents':
        return canAccessDocuments;
      case 'approve_documents':
        return canApproveDocuments;
      default:
        return false;
    }
  }
}
