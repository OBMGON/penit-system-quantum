import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/encryption_service.dart';

class SyncService {
  static const String _offlineDataKey = 'offline_data';
  static const String _pendingChangesKey = 'pending_changes';
  static const String _lastSyncKey = 'last_sync';
  static const String _syncStatusKey = 'sync_status';

  static late SharedPreferences _prefs;
  static bool _isInitialized = false;
  static Timer? _syncTimer;
  static final Map<String, dynamic> _pendingChanges = {};
  static bool _isConnected = false;

  // Inicializar el servicio de sincronización
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔄 Inicializando servicio de sincronización...');

    _prefs = await SharedPreferences.getInstance();
    EncryptionService.initialize();

    // Verificar conectividad inicial
    await _checkConnectivity();

    // Configurar listener de conectividad
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isConnected = result != ConnectivityResult.none;
      print(
          '📡 Estado de conectividad: ${_isConnected ? 'Conectado' : 'Desconectado'}');

      if (_isConnected) {
        _syncPendingChanges();
      }
    });

    // Configurar timer para sincronización periódica
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_isConnected) {
        _syncPendingChanges();
      }
    });

    _isInitialized = true;
    print('✅ Servicio de sincronización inicializado');
  }

  // Verificar conectividad
  static Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      _isConnected = connectivityResult != ConnectivityResult.none;
      print(
          '📡 Conectividad inicial: ${_isConnected ? 'Conectado' : 'Desconectado'}');
    } catch (e) {
      print('❌ Error al verificar conectividad: $e');
      _isConnected = false;
    }
  }

  // Guardar datos offline
  static Future<void> saveOfflineData(
      String key, Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      // Cifrar datos sensibles antes de guardar
      final encryptedData = EncryptionService.encryptInmateData(data);
      final jsonData = json.encode(encryptedData);

      await _prefs.setString('${_offlineDataKey}_$key', jsonData);
      print('Datos guardados offline: $key');
    } catch (e) {
      print('Error al guardar datos offline: $e');
      rethrow;
    }
  }

  // Cargar datos offline
  static Future<Map<String, dynamic>?> loadOfflineData(String key) async {
    await _ensureInitialized();

    try {
      final jsonData = _prefs.getString('${_offlineDataKey}_$key');
      if (jsonData == null) return null;

      final encryptedData = json.decode(jsonData) as Map<String, dynamic>;
      final decryptedData = EncryptionService.decryptInmateData(encryptedData);

      return decryptedData;
    } catch (e) {
      print('Error al cargar datos offline: $e');
      return null;
    }
  }

  // Agregar cambio pendiente
  static Future<void> addPendingChange(
      String type, Map<String, dynamic> data) async {
    final changeId = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingChanges[changeId] = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    };

    // Guardar en almacenamiento local
    await _savePendingChanges();
    print('📝 Cambio pendiente agregado: $type');
  }

  // Guardar cambios pendientes en almacenamiento local
  static Future<void> _savePendingChanges() async {
    try {
      await _prefs.setString(_pendingChangesKey, json.encode(_pendingChanges));
    } catch (e) {
      print('❌ Error al guardar cambios pendientes: $e');
    }
  }

  // Cargar cambios pendientes desde almacenamiento local
  static Future<void> _loadPendingChanges() async {
    try {
      final changesJson = _prefs.getString(_pendingChangesKey);
      if (changesJson != null) {
        final changes = json.decode(changesJson) as Map<String, dynamic>;
        _pendingChanges.clear();
        _pendingChanges.addAll(changes);
        print('📥 Cambios pendientes cargados: ${_pendingChanges.length}');
      }
    } catch (e) {
      print('❌ Error al cargar cambios pendientes: $e');
    }
  }

  // Sincronizar cambios pendientes
  static Future<void> _syncPendingChanges() async {
    if (!_isConnected || _pendingChanges.isEmpty) return;

    print(
        '🔄 Iniciando sincronización de ${_pendingChanges.length} cambios...');

    try {
      // Simular envío de datos al servidor
      await Future.delayed(const Duration(seconds: 2));

      // Marcar cambios como sincronizados
      for (final entry in _pendingChanges.entries) {
        _pendingChanges[entry.key] = {
          ...entry.value,
          'synced': true,
          'syncedAt': DateTime.now().toIso8601String(),
        };
      }

      // Guardar estado actualizado
      await _savePendingChanges();

      print('✅ Sincronización completada exitosamente');
    } catch (e) {
      print('❌ Error durante la sincronización: $e');
    }
  }

  // Sincronizar cambios pendientes manualmente
  static Future<bool> syncPendingChanges() async {
    if (!_isConnected) {
      print('❌ No hay conexión a internet');
      return false;
    }

    try {
      await _syncPendingChanges();
      return true;
    } catch (e) {
      print('❌ Error en sincronización manual: $e');
      return false;
    }
  }

  // Obtener estado de sincronización
  static Future<Map<String, dynamic>> getSyncStatus() async {
    await _loadPendingChanges();

    final pendingCount = _pendingChanges.values
        .where((change) => change['synced'] == false)
        .length;

    return {
      'isConnected': _isConnected,
      'pendingChanges': pendingCount,
      'canSync': _isConnected && pendingCount > 0,
      'lastSync': _getLastSyncTime(),
    };
  }

  // Obtener tiempo de última sincronización
  static String? _getLastSyncTime() {
    final syncedChanges = _pendingChanges.values
        .where((change) => change['synced'] == true)
        .toList();

    if (syncedChanges.isEmpty) return null;

    // Obtener el cambio más reciente sincronizado
    syncedChanges.sort((a, b) => DateTime.parse(a['syncedAt']!)
        .compareTo(DateTime.parse(b['syncedAt']!)));

    return syncedChanges.last['syncedAt']!;
  }

  // Exportar backup de datos
  static Future<Map<String, dynamic>> exportBackup() async {
    try {
      await _loadPendingChanges();

      final backup = {
        'timestamp': DateTime.now().toIso8601String(),
        'pendingChanges': _pendingChanges,
        'syncStatus': await getSyncStatus(),
      };

      print('💾 Backup exportado: ${backup.length} elementos');
      return backup;
    } catch (e) {
      print('❌ Error al exportar backup: $e');
      rethrow;
    }
  }

  // Verificar integridad de datos
  static Future<bool> verifyDataIntegrity() async {
    try {
      await _loadPendingChanges();

      // Verificar que todos los cambios tengan la estructura correcta
      for (final entry in _pendingChanges.entries) {
        final change = entry.value;
        if (change['type'] == null ||
            change['data'] == null ||
            change['timestamp'] == null) {
          print('⚠️ Cambio corrupto encontrado: ${entry.key}');
          return false;
        }
      }

      print('✅ Integridad de datos verificada');
      return true;
    } catch (e) {
      print('❌ Error al verificar integridad: $e');
      return false;
    }
  }

  // Limpiar cambios sincronizados antiguos
  static Future<void> cleanupOldChanges() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

      _pendingChanges.removeWhere((key, value) {
        if (value['synced'] == true) {
          final syncedAt = DateTime.parse(value['syncedAt']!);
          return syncedAt.isBefore(cutoffDate);
        }
        return false;
      });

      await _savePendingChanges();
      print('🧹 Limpieza de cambios antiguos completada');
    } catch (e) {
      print('❌ Error durante la limpieza: $e');
    }
  }

  // Obtener estadísticas de sincronización
  static Map<String, dynamic> getSyncStatistics() {
    final totalChanges = _pendingChanges.length;
    final syncedChanges = _pendingChanges.values
        .where((change) => change['synced'] == true)
        .length;
    final pendingChanges = totalChanges - syncedChanges;

    return {
      'totalChanges': totalChanges,
      'syncedChanges': syncedChanges,
      'pendingChanges': pendingChanges,
      'syncRate':
          totalChanges > 0 ? (syncedChanges / totalChanges * 100).round() : 0,
      'isConnected': _isConnected,
    };
  }

  // Limpiar recursos
  static void dispose() {
    _syncTimer?.cancel();
    _isInitialized = false;
    print('🔄 Servicio de sincronización detenido');
  }

  // Asegurar que el servicio esté inicializado
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Limpiar todos los datos
  static Future<void> clearAllData() async {
    await _ensureInitialized();

    try {
      final keys = _prefs.getKeys();
      final syncKeys = keys
          .where((key) =>
              key.startsWith(_offlineDataKey) ||
              key.startsWith(_pendingChangesKey) ||
              key == _lastSyncKey ||
              key == _syncStatusKey)
          .toList();

      for (final key in syncKeys) {
        await _prefs.remove(key);
      }

      print('Todos los datos de sincronización eliminados');
    } catch (e) {
      print('Error al limpiar datos: $e');
    }
  }
}
