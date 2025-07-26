import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  // Box names for different data types
  static const String inmatesBox = 'inmates';
  static const String hospitalizationsBox = 'hospitalizations';
  static const String expensesBox = 'expenses';
  static const String foodBox = 'food';
  static const String documentsBox = 'documents';
  static const String reportsBox = 'reports';
  static const String alertsBox = 'alerts';
  static const String auditBox = 'audit';
  static const String pendingSyncBox = 'pending_sync';
  static const String settingsBox = 'settings';
  static const String usersBox = 'users';

  static bool _isInitialized = false;
  static SharedPreferences? _prefs;

  // Initialize service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing OfflineService: $e');
    }
  }

  // Check connectivity
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Verify actual internet connection
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Save data offline
  static Future<bool> saveOfflineData<T>(
      String boxName, String key, T data) async {
    try {
      await initialize();

      final storageKey = '${boxName}_$key';
      final jsonData = jsonEncode(data);
      final success = await _prefs?.setString(storageKey, jsonData) ?? false;

      return success;
    } catch (e) {
      debugPrint('Error saving offline data: $e');
      return false;
    }
  }

  // Get offline data
  static Future<T?> getOfflineData<T>(String boxName, String key) async {
    try {
      await initialize();

      final storageKey = '${boxName}_$key';
      final data = _prefs?.getString(storageKey);

      if (data != null) {
        return jsonDecode(data) as T;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting offline data: $e');
      return null;
    }
  }

  // Get all data from a box
  static Future<List<Map<String, dynamic>>> getAllOfflineData(
      String boxName) async {
    try {
      await initialize();

      final List<Map<String, dynamic>> results = [];
      final keys = _prefs?.getKeys() ?? {};

      for (final key in keys) {
        if (key.startsWith('${boxName}_')) {
          try {
            final data = _prefs?.getString(key);
            if (data != null) {
              final decoded = jsonDecode(data);
              if (decoded is Map<String, dynamic>) {
                results.add(decoded);
              }
            }
          } catch (e) {
            debugPrint('Error parsing offline data for key $key: $e');
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error getting all offline data: $e');
      return [];
    }
  }

  // Delete offline data
  static Future<bool> deleteOfflineData(String boxName, String key) async {
    try {
      await initialize();

      final storageKey = '${boxName}_$key';
      final success = await _prefs?.remove(storageKey) ?? false;

      return success;
    } catch (e) {
      debugPrint('Error deleting offline data: $e');
      return false;
    }
  }

  // Clear all data from a box
  static Future<bool> clearBox(String boxName) async {
    try {
      await initialize();

      final keys = _prefs?.getKeys() ?? {};
      final keysToRemove =
          keys.where((key) => key.startsWith('${boxName}_')).toList();

      for (final key in keysToRemove) {
        await _prefs?.remove(key);
      }

      return true;
    } catch (e) {
      debugPrint('Error clearing box: $e');
      return false;
    }
  }

  // Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      await initialize();

      final stats = <String, dynamic>{};
      final keys = _prefs?.getKeys() ?? {};

      for (final boxName in [
        inmatesBox,
        hospitalizationsBox,
        expensesBox,
        foodBox,
        documentsBox,
        reportsBox,
        alertsBox,
        auditBox,
        usersBox
      ]) {
        int count = 0;
        int totalSize = 0;

        for (final key in keys) {
          if (key.startsWith('${boxName}_')) {
            count++;
            final data = _prefs?.getString(key);
            if (data != null) {
              totalSize += data.length;
            }
          }
        }

        stats[boxName] = {
          'count': count,
          'size': totalSize,
        };
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {};
    }
  }

  // Check if data exists
  static Future<bool> hasData(String boxName, String key) async {
    try {
      await initialize();

      final storageKey = '${boxName}_$key';
      return _prefs?.containsKey(storageKey) ?? false;
    } catch (e) {
      debugPrint('Error checking data existence: $e');
      return false;
    }
  }

  // Get all keys for a box
  static Future<List<String>> getBoxKeys(String boxName) async {
    try {
      await initialize();

      final keys = _prefs?.getKeys() ?? {};
      return keys.where((key) => key.startsWith('${boxName}_')).toList();
    } catch (e) {
      debugPrint('Error getting box keys: $e');
      return [];
    }
  }

  // Backup all data
  static Future<Map<String, dynamic>> backupAllData() async {
    try {
      await initialize();

      final backup = <String, dynamic>{};
      final keys = _prefs?.getKeys() ?? {};

      for (final key in keys) {
        final data = _prefs?.getString(key);
        if (data != null) {
          backup[key] = data;
        }
      }

      return backup;
    } catch (e) {
      debugPrint('Error backing up data: $e');
      return {};
    }
  }

  // Restore data from backup
  static Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      await initialize();

      for (final entry in backup.entries) {
        if (entry.value is String) {
          await _prefs?.setString(entry.key, entry.value as String);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error restoring from backup: $e');
      return false;
    }
  }
}
