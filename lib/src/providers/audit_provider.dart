import 'package:flutter/foundation.dart';
import '../models/audit.dart';

class AuditProvider extends ChangeNotifier {
  final List<AuditLog> _logs = [];

  List<AuditLog> get logs => _logs;

  // Agregar log de auditoría
  void addLog(String action, String details, String userId) {
    final log = AuditLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      username: userId, // Usar userId como username por ahora
      action: action,
      prisonId: 'prison-1', // Valor por defecto
      timestamp: DateTime.now(),
    );

    _logs.insert(0, log);
    notifyListeners();
  }

  // Obtener logs por usuario
  List<AuditLog> getLogsByUser(String userId) {
    return _logs.where((log) => log.userId == userId).toList();
  }

  // Obtener logs por acción
  List<AuditLog> getLogsByAction(String action) {
    return _logs.where((log) => log.action == action).toList();
  }

  // Obtener logs por fecha
  List<AuditLog> getLogsByDate(DateTime date) {
    return _logs
        .where((log) =>
            log.timestamp.year == date.year &&
            log.timestamp.month == date.month &&
            log.timestamp.day == date.day)
        .toList();
  }

  // Exportar logs
  List<Map<String, dynamic>> exportLogs() {
    return _logs
        .map((log) => {
              'id': log.id,
              'userId': log.userId,
              'username': log.username,
              'action': log.action,
              'prisonId': log.prisonId,
              'timestamp': log.timestamp.toIso8601String(),
            })
        .toList();
  }

  // Limpiar logs antiguos
  void cleanupOldLogs({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoffDate));
    notifyListeners();
  }
}
