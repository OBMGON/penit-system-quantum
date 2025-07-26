import 'package:flutter/foundation.dart';
import '../models/administrative.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';

class PrisonerProvider with ChangeNotifier {
  List<Inmate> _inmates = [];
  bool _isLoading = false;
  String? _error;
  bool _isOfflineMode = false;

  List<Inmate> get inmates => _inmates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;

  // Inicializar provider
  Future<void> initialize() async {
    await OfflineService.initialize();
    await loadInmates();
  }

  // Cargar presos (online/offline)
  Future<void> loadInmates() async {
    _setLoading(true);
    _error = null;

    try {
      final isConnected = await OfflineService.isConnected();
      _isOfflineMode = !isConnected;

      if (isConnected) {
        // Intentar cargar desde API
        try {
          final apiData = await ApiService.getInmates();
          _inmates = apiData.map((data) => Inmate.fromJson(data)).toList();

          // Guardar en almacenamiento offline
          for (var inmate in _inmates) {
            await OfflineService.saveOfflineData(
              OfflineService.inmatesBox,
              inmate.id,
              inmate.toJson(),
            );
          }
        } catch (e) {
          // Si falla la API, cargar desde offline
          _isOfflineMode = true;
          await _loadFromOffline();
        }
      } else {
        // Cargar solo desde offline
        await _loadFromOffline();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar presos: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Cargar desde almacenamiento offline
  Future<void> _loadFromOffline() async {
    final cachedData =
        await OfflineService.getAllOfflineData(OfflineService.inmatesBox);
    _inmates = cachedData.map((json) => Inmate.fromJson(json)).toList();
  }

  // Agregar preso
  Future<void> addInmate(Inmate inmate) async {
    _setLoading(true);
    _error = null;

    try {
      // Generar ID único si no existe
      if (inmate.id.isEmpty) {
        inmate.id = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // Guardar offline primero
      await OfflineService.saveOfflineData(
        OfflineService.inmatesBox,
        inmate.id,
        inmate.toJson(),
      );

      // Intentar sincronizar con backend si hay conexión
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.createInmate(inmate.toJson());
        } catch (e) {
          // Si falla, los datos ya están guardados offline
          debugPrint('Error sincronizando con backend: $e');
        }
      }

      _inmates.add(inmate);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar preso: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar preso
  Future<void> updateInmate(Inmate inmate) async {
    _setLoading(true);
    _error = null;

    try {
      // Actualizar offline primero
      await OfflineService.saveOfflineData(
        OfflineService.inmatesBox,
        inmate.id,
        inmate.toJson(),
      );

      // Intentar sincronizar con backend si hay conexión
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.updateInmate(inmate.id, inmate.toJson());
        } catch (e) {
          debugPrint('Error sincronizando con backend: $e');
        }
      }

      final index = _inmates.indexWhere((i) => i.id == inmate.id);
      if (index != -1) {
        _inmates[index] = inmate;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar preso: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar preso
  Future<void> deleteInmate(String id) async {
    _setLoading(true);
    _error = null;

    try {
      // Eliminar offline primero
      await OfflineService.deleteOfflineData(OfflineService.inmatesBox, id);

      // Intentar sincronizar con backend si hay conexión
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.deleteInmate(id);
        } catch (e) {
          debugPrint('Error sincronizando con backend: $e');
        }
      }

      _inmates.removeWhere((inmate) => inmate.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar preso: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Buscar preso
  List<Inmate> searchInmates(String query) {
    if (query.isEmpty) return _inmates;

    return _inmates.where((inmate) {
      final searchLower = query.toLowerCase();
      return inmate.fullName.toLowerCase().contains(searchLower) ||
          inmate.inmateNumber.toLowerCase().contains(searchLower) ||
          inmate.prisonName.toLowerCase().contains(searchLower);
    }).toList();
  }

  // Filtrar presos por centro penitenciario
  List<Inmate> filterByPrison(String prison) {
    if (prison == 'Todos') return _inmates;
    return _inmates.where((inmate) => inmate.prisonName == prison).toList();
  }

  // Obtener presos con liberación próxima
  List<Inmate> getInmatesNearRelease() {
    return _inmates.where((inmate) => inmate.isNearRelease).toList();
  }

  // Obtener presos críticos (liberación en menos de 7 días)
  List<Inmate> getCriticalInmates() {
    return _inmates.where((inmate) => inmate.isVeryCriticalRelease).toList();
  }

  // Sincronizar datos pendientes
  Future<void> syncPendingData() async {
    if (!await OfflineService.isConnected()) return;

    try {
      // Recargar datos desde la API si hay conexión
      await loadInmates();
    } catch (e) {
      _error = 'Error en sincronización: $e';
      notifyListeners();
    }
  }

  // Obtener estadísticas
  Map<String, dynamic> getStatistics() {
    final total = _inmates.length;
    final nearRelease = getInmatesNearRelease().length;
    final critical = getCriticalInmates().length;
    final byPrison = <String, int>{};

    for (var inmate in _inmates) {
      byPrison[inmate.prisonName] = (byPrison[inmate.prisonName] ?? 0) + 1;
    }

    return {
      'total': total,
      'nearRelease': nearRelease,
      'critical': critical,
      'byPrison': byPrison,
      'isOfflineMode': _isOfflineMode,
    };
  }

  // Métodos de compatibilidad para dashboard
  Map<String, int> getNationalStatistics() {
    final totalInmates = _inmates.length;
    final activeInmates =
        _inmates.where((i) => i.status == InmateStatus.active).length;
    final nearRelease = getInmatesNearRelease().length;
    final criticalRelease = getCriticalInmates().length;
    const totalCapacity = 500;
    final occupationPercentage =
        totalInmates > 0 ? (totalInmates * 100 / totalCapacity).round() : 0;

    return {
      'totalInmates': totalInmates,
      'activeInmates': activeInmates,
      'nearRelease': nearRelease,
      'criticalRelease': criticalRelease,
      'occupationPercentage': occupationPercentage,
    };
  }

  Map<String, int> getStatisticsByPrison() {
    final Map<String, int> stats = {};
    for (final inmate in _inmates) {
      stats[inmate.prisonName] = (stats[inmate.prisonName] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getInmatesByFixedCities() {
    // Lista fija de ciudades institucionales
    const List<String> fixedCities = ['Malabo', 'Bata', 'Mongomo'];
    final Map<String, int> cityCounts = {};

    // Inicializar todas las ciudades con 0
    for (final city in fixedCities) {
      cityCounts[city] = 0;
    }

    // Contar reclusos por ciudad
    for (final inmate in _inmates) {
      final city = _extractCityFromPrisonName(inmate.prisonName);
      if (city.isNotEmpty && fixedCities.contains(city)) {
        cityCounts[city] = (cityCounts[city] ?? 0) + 1;
      }
    }

    return cityCounts;
  }

  String _extractCityFromPrisonName(String prisonName) {
    // Ejemplo: "Centro Penitenciario de Malabo" => "Malabo"
    final regex = RegExp(r'de ([A-Za-zÁÉÍÓÚáéíóúñÑ ]+)', caseSensitive: false);
    final match = regex.firstMatch(prisonName);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    // Si no coincide, devolver el nombre completo como fallback
    return prisonName.trim();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Establecer estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Forzar modo offline (para testing)
  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    notifyListeners();
  }
}
