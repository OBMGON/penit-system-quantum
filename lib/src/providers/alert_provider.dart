import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';

class AlertProvider extends ChangeNotifier {
  List<Alert> _alerts = [];
  bool _isLoading = false;
  String? _error;
  bool _isOfflineMode = false;

  // Filtros
  AlertType? _selectedType;
  AlertPriority? _selectedPriority;
  AlertStatus? _selectedStatus;
  String _searchQuery = '';
  bool _showOnlyUnread = false;
  bool _showOnlyActive = false;

  List<Alert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;

  // Getters para filtros
  AlertType? get selectedType => _selectedType;
  AlertPriority? get selectedPriority => _selectedPriority;
  AlertStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get showOnlyUnread => _showOnlyUnread;
  bool get showOnlyActive => _showOnlyActive;

  // Lista filtrada de alertas
  List<Alert> get filteredAlerts {
    List<Alert> filtered = _alerts;

    if (_selectedType != null) {
      filtered =
          filtered.where((alert) => alert.type == _selectedType).toList();
    }

    if (_selectedPriority != null) {
      filtered = filtered
          .where((alert) => alert.priority == _selectedPriority)
          .toList();
    }

    if (_selectedStatus != null) {
      filtered =
          filtered.where((alert) => alert.status == _selectedStatus).toList();
    }

    if (_showOnlyUnread) {
      filtered = filtered.where((alert) => !alert.isRead).toList();
    }

    if (_showOnlyActive) {
      filtered = filtered.where((alert) => alert.isActive).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((alert) =>
              alert.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              alert.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (alert.inmateName
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (alert.prisonName
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              alert.tags.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    return filtered;
  }

  // Alertas críticas
  List<Alert> get criticalAlerts {
    return _alerts
        .where((alert) => alert.isCritical && alert.isActive)
        .toList();
  }

  // Alertas activas
  List<Alert> get activeAlerts {
    return _alerts.where((alert) => alert.isActive).toList();
  }

  // Alertas no leídas
  List<Alert> get unreadAlerts {
    return _alerts.where((alert) => !alert.isRead).toList();
  }

  // Estadísticas
  Map<String, int> get statistics {
    return {
      'total': _alerts.length,
      'activas': activeAlerts.length,
      'criticas': criticalAlerts.length,
      'noLeidas': unreadAlerts.length,
      'resueltas': _alerts.where((alert) => alert.isResolved).length,
    };
  }

  // Estadísticas por tipo
  Map<AlertType, int> get statisticsByType {
    final Map<AlertType, int> stats = {};
    for (final type in AlertType.values) {
      stats[type] = _alerts.where((alert) => alert.type == type).length;
    }
    return stats;
  }

  // Estadísticas por prioridad
  Map<AlertPriority, int> get statisticsByPriority {
    final Map<AlertPriority, int> stats = {};
    for (final priority in AlertPriority.values) {
      stats[priority] =
          _alerts.where((alert) => alert.priority == priority).length;
    }
    return stats;
  }

  // Cargar alertas
  Future<void> loadAlerts() async {
    _setLoading(true);
    try {
      List<Alert> loadedAlerts = [];

      // Intentar cargar desde API si está conectado
      if (await OfflineService.isConnected()) {
        try {
          final apiAlerts = await ApiService.getAlerts();
          loadedAlerts = apiAlerts.map((json) => Alert.fromJson(json)).toList();
          _isOfflineMode = false;
        } catch (e) {
          _isOfflineMode = true;
        }
      } else {
        _isOfflineMode = true;
      }

      // Si no hay datos de API, cargar desde almacenamiento local
      if (loadedAlerts.isEmpty) {
        final offlineData = await OfflineService.getAllOfflineData('alerts');
        loadedAlerts = offlineData.map((json) => Alert.fromJson(json)).toList();
      }

      // Si no hay datos, crear alertas de ejemplo
      if (loadedAlerts.isEmpty) {
        loadedAlerts = _createSampleAlerts();
      }

      _alerts = loadedAlerts;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar alertas: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Crear nueva alerta
  Future<void> createAlert({
    required String title,
    required String description,
    required AlertType type,
    required AlertPriority priority,
    String? assignedTo,
    String? prisonName,
    String? inmateId,
    String? inmateName,
    Map<String, dynamic>? metadata,
    List<String> tags = const [],
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final alert = Alert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        type: type,
        priority: priority,
        status: AlertStatus.activa,
        createdAt: DateTime.now(),
        createdBy: 'Usuario Actual',
        assignedTo: assignedTo,
        prisonName: prisonName,
        inmateId: inmateId,
        inmateName: inmateName,
        metadata: metadata,
        tags: tags,
        notes: notes,
      );

      _alerts.insert(0, alert);

      // Guardar en almacenamiento local
      await OfflineService.saveOfflineData('alerts', alert.id, alert.toJson());

      // Intentar sincronizar con API
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.createAlert(alert.toJson());
        } catch (e) {
          _isOfflineMode = true;
        }
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al crear alerta: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar alerta
  Future<void> updateAlert(
    String alertId, {
    String? title,
    String? description,
    AlertType? type,
    AlertPriority? priority,
    AlertStatus? status,
    String? assignedTo,
    String? notes,
    bool? isRead,
  }) async {
    _setLoading(true);
    try {
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        final alert = _alerts[index];
        final updatedAlert = alert.copyWith(
          title: title,
          description: description,
          type: type,
          priority: priority,
          status: status,
          assignedTo: assignedTo,
          notes: notes,
          isRead: isRead,
          resolvedAt:
              status == AlertStatus.resuelta || status == AlertStatus.cerrada
                  ? DateTime.now()
                  : alert.resolvedAt,
        );

        _alerts[index] = updatedAlert;

        // Guardar en almacenamiento local
        await OfflineService.saveOfflineData(
            'alerts', updatedAlert.id, updatedAlert.toJson());

        // Intentar sincronizar con API
        if (await OfflineService.isConnected()) {
          try {
            await ApiService.updateAlert(alertId, updatedAlert.toJson());
          } catch (e) {
            _isOfflineMode = true;
          }
        }

        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar alerta: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Marcar como leída
  Future<void> markAsRead(String alertId) async {
    await updateAlert(alertId, isRead: true);
  }

  // Marcar como resuelta
  Future<void> markAsResolved(String alertId, {String? notes}) async {
    await updateAlert(alertId, status: AlertStatus.resuelta, notes: notes);
  }

  // Eliminar alerta
  Future<void> deleteAlert(String alertId) async {
    _setLoading(true);
    try {
      _alerts.removeWhere((alert) => alert.id == alertId);

      // Eliminar de almacenamiento local
      await OfflineService.deleteOfflineData('alerts', alertId);

      // Intentar sincronizar con API
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.deleteAlert(alertId);
        } catch (e) {
          _isOfflineMode = true;
        }
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar alerta: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar filtros
  void updateFilters({
    AlertType? type,
    AlertPriority? priority,
    AlertStatus? status,
    String? searchQuery,
    bool? showOnlyUnread,
    bool? showOnlyActive,
  }) {
    _selectedType = type;
    _selectedPriority = priority;
    _selectedStatus = status;
    _searchQuery = searchQuery ?? '';
    _showOnlyUnread = showOnlyUnread ?? false;
    _showOnlyActive = showOnlyActive ?? false;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedType = null;
    _selectedPriority = null;
    _selectedStatus = null;
    _searchQuery = '';
    _showOnlyUnread = false;
    _showOnlyActive = false;
    notifyListeners();
  }

  // Crear alertas de ejemplo
  List<Alert> _createSampleAlerts() {
    return [
      Alert(
        id: '1',
        title: 'Incidente de Seguridad - Bloque A',
        description:
            'Se detectó un intento de fuga en el bloque A. Se requiere refuerzo de seguridad inmediato.',
        type: AlertType.seguridad,
        priority: AlertPriority.critico,
        status: AlertStatus.activa,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdBy: 'Sistema de Seguridad',
        prisonName: 'Centro Penitenciario Nacional',
        tags: ['fuga', 'seguridad', 'bloque-a'],
        requiresAction: true,
      ),
      Alert(
        id: '2',
        title: 'Recluso Requiere Atención Médica Urgente',
        description:
            'El recluso Juan Pérez (ID: 12345) presenta síntomas de apendicitis. Requiere traslado médico inmediato.',
        type: AlertType.medico,
        priority: AlertPriority.critico,
        status: AlertStatus.enProceso,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdBy: 'Enfermería',
        assignedTo: 'Dr. García',
        prisonName: 'Centro Penitenciario Nacional',
        inmateId: '12345',
        inmateName: 'Juan Pérez',
        tags: ['medico', 'urgente', 'apendicitis'],
        requiresAction: true,
      ),
      Alert(
        id: '3',
        title: 'Mantenimiento - Sistema Eléctrico',
        description:
            'Falla en el sistema eléctrico del bloque C. Se requiere técnico de mantenimiento.',
        type: AlertType.mantenimiento,
        priority: AlertPriority.alto,
        status: AlertStatus.activa,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        createdBy: 'Sistema de Mantenimiento',
        prisonName: 'Centro Penitenciario Nacional',
        tags: ['mantenimiento', 'electricidad', 'bloque-c'],
        requiresAction: true,
      ),
      Alert(
        id: '4',
        title: 'Visita Familiar Programada',
        description:
            'Visita familiar para el recluso María López (ID: 67890) programada para mañana a las 10:00 AM.',
        type: AlertType.visita,
        priority: AlertPriority.medio,
        status: AlertStatus.activa,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'Secretaría',
        prisonName: 'Centro Penitenciario Nacional',
        inmateId: '67890',
        inmateName: 'María López',
        tags: ['visita', 'familiar', 'programada'],
        requiresAction: false,
      ),
      Alert(
        id: '5',
        title: 'Traslado de Recluso',
        description:
            'Traslado programado del recluso Carlos Rodríguez (ID: 11111) al Centro Penitenciario de Bata.',
        type: AlertType.traslado,
        priority: AlertPriority.medio,
        status: AlertStatus.enProceso,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'Administración',
        assignedTo: 'Oficial de Traslados',
        prisonName: 'Centro Penitenciario Nacional',
        inmateId: '11111',
        inmateName: 'Carlos Rodríguez',
        tags: ['traslado', 'bata', 'programado'],
        requiresAction: true,
      ),
    ];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
