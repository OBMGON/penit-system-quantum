import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;
  bool _isOfflineMode = false;

  // Filtros
  ReportType? _selectedType;
  ReportFormat? _selectedFormat;
  ReportStatus? _selectedStatus;
  String _searchQuery = '';
  bool _showOnlyScheduled = false;
  bool _showOnlyCompleted = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOfflineMode => _isOfflineMode;

  // Getters para filtros
  ReportType? get selectedType => _selectedType;
  ReportFormat? get selectedFormat => _selectedFormat;
  ReportStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get showOnlyScheduled => _showOnlyScheduled;
  bool get showOnlyCompleted => _showOnlyCompleted;

  // Lista filtrada de reportes
  List<Report> get filteredReports {
    List<Report> filtered = _reports;

    if (_selectedType != null) {
      filtered =
          filtered.where((report) => report.type == _selectedType).toList();
    }

    if (_selectedFormat != null) {
      filtered =
          filtered.where((report) => report.format == _selectedFormat).toList();
    }

    if (_selectedStatus != null) {
      filtered =
          filtered.where((report) => report.status == _selectedStatus).toList();
    }

    if (_showOnlyScheduled) {
      filtered = filtered.where((report) => report.isScheduled).toList();
    }

    if (_showOnlyCompleted) {
      filtered = filtered.where((report) => report.isCompleted).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((report) =>
              report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              report.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              report.tags.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())) ||
              (report.createdBy
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())))
          .toList();
    }

    return filtered;
  }

  // Reportes completados
  List<Report> get completedReports {
    return _reports.where((report) => report.isCompleted).toList();
  }

  // Reportes pendientes
  List<Report> get pendingReports {
    return _reports.where((report) => report.isPending).toList();
  }

  // Reportes programados
  List<Report> get scheduledReports {
    return _reports.where((report) => report.isScheduled).toList();
  }

  // Reportes con error
  List<Report> get errorReports {
    return _reports.where((report) => report.hasError).toList();
  }

  // Estadísticas
  ReportStatistics get statistics {
    final reportsByType = <ReportType, int>{};
    final reportsByFormat = <ReportFormat, int>{};
    final reportsByStatus = <ReportStatus, int>{};
    final tagCounts = <String, int>{};
    int totalFileSize = 0;
    double totalGenerationTime = 0;
    int completedCount = 0;

    for (final report in _reports) {
      // Contar por tipo
      reportsByType[report.type] = (reportsByType[report.type] ?? 0) + 1;

      // Contar por formato
      reportsByFormat[report.format] =
          (reportsByFormat[report.format] ?? 0) + 1;

      // Contar por estado
      reportsByStatus[report.status] =
          (reportsByStatus[report.status] ?? 0) + 1;

      // Contar tags
      for (final tag in report.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }

      // Calcular tamaño total de archivos
      if (report.fileSize != null) {
        totalFileSize += report.fileSize!;
      }

      // Calcular tiempo promedio de generación
      if (report.isCompleted && report.completedAt != null) {
        final generationTime =
            report.completedAt!.difference(report.createdAt).inSeconds;
        totalGenerationTime += generationTime;
        completedCount++;
      }
    }

    // Obtener top tags
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).map((e) => e.key).toList();

    return ReportStatistics(
      totalReports: _reports.length,
      completedReports: _reports.where((r) => r.isCompleted).length,
      pendingReports: _reports.where((r) => r.isPending).length,
      errorReports: _reports.where((r) => r.hasError).length,
      reportsByType: reportsByType,
      reportsByFormat: reportsByFormat,
      reportsByStatus: reportsByStatus,
      averageGenerationTime:
          completedCount > 0 ? totalGenerationTime / completedCount : 0,
      totalFileSize: totalFileSize,
      topTags: topTags,
    );
  }

  // Cargar reportes
  Future<void> loadReports() async {
    _setLoading(true);
    try {
      List<Report> loadedReports = [];

      // Intentar cargar desde API si está conectado
      if (await OfflineService.isConnected()) {
        try {
          final apiReports = await ApiService.getReports();
          loadedReports =
              apiReports.map((json) => Report.fromJson(json)).toList();
          _isOfflineMode = false;
        } catch (e) {
          _isOfflineMode = true;
        }
      } else {
        _isOfflineMode = true;
      }

      // Si no hay datos de API, cargar desde almacenamiento local
      if (loadedReports.isEmpty) {
        final offlineData = await OfflineService.getAllOfflineData('reports');
        loadedReports =
            offlineData.map((json) => Report.fromJson(json)).toList();
      }

      // Si no hay datos, crear reportes de ejemplo
      if (loadedReports.isEmpty) {
        loadedReports = _createSampleReports();
      }

      _reports = loadedReports;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar reportes: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Crear nuevo reporte
  Future<void> createReport({
    required String title,
    required String description,
    required ReportType type,
    required ReportFormat format,
    Map<String, dynamic> parameters = const {},
    List<String> tags = const [],
    bool isScheduled = false,
    String? scheduleCron,
  }) async {
    _setLoading(true);
    try {
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        type: type,
        format: format,
        status: ReportStatus.pendiente,
        createdAt: DateTime.now(),
        createdBy: 'Usuario Actual',
        parameters: parameters,
        tags: tags,
        isScheduled: isScheduled,
        scheduleCron: scheduleCron,
        nextRun: isScheduled ? _calculateNextRun(scheduleCron!) : null,
      );

      _reports.insert(0, report);

      // Guardar en almacenamiento local
      await OfflineService.saveOfflineData(
          'reports', report.id, report.toJson());

      // Intentar sincronizar con API
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.createReport(report.toJson());
        } catch (e) {
          _isOfflineMode = true;
        }
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al crear reporte: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Generar reporte
  Future<void> generateReport(String reportId) async {
    _setLoading(true);
    try {
      final index = _reports.indexWhere((report) => report.id == reportId);
      if (index != -1) {
        final report = _reports[index];

        // Simular generación de reporte
        final updatedReport = report.copyWith(
          status: ReportStatus.generando,
        );
        _reports[index] = updatedReport;
        notifyListeners();

        // Simular tiempo de generación
        await Future.delayed(const Duration(seconds: 3));

        // Completar reporte
        final completedReport = updatedReport.copyWith(
          status: ReportStatus.completado,
          completedAt: DateTime.now(),
          filePath: 'reports/${report.id}.${report.format.name.toLowerCase()}',
          fileSize: _generateFileSize(report.format),
        );

        _reports[index] = completedReport;

        // Guardar en almacenamiento local
        await OfflineService.saveOfflineData(
            'reports', completedReport.id, completedReport.toJson());

        // Intentar sincronizar con API
        if (await OfflineService.isConnected()) {
          try {
            await ApiService.updateReport(reportId, completedReport.toJson());
          } catch (e) {
            _isOfflineMode = true;
          }
        }

        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al generar reporte: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cancelar reporte
  Future<void> cancelReport(String reportId) async {
    _setLoading(true);
    try {
      final index = _reports.indexWhere((report) => report.id == reportId);
      if (index != -1) {
        final report = _reports[index];
        final updatedReport = report.copyWith(
          status: ReportStatus.cancelado,
        );

        _reports[index] = updatedReport;

        // Guardar en almacenamiento local
        await OfflineService.saveOfflineData(
            'reports', updatedReport.id, updatedReport.toJson());

        // Intentar sincronizar con API
        if (await OfflineService.isConnected()) {
          try {
            await ApiService.updateReport(reportId, updatedReport.toJson());
          } catch (e) {
            _isOfflineMode = true;
          }
        }

        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al cancelar reporte: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar reporte
  Future<void> deleteReport(String reportId) async {
    _setLoading(true);
    try {
      _reports.removeWhere((report) => report.id == reportId);

      // Eliminar de almacenamiento local
      await OfflineService.deleteOfflineData('reports', reportId);

      // Intentar sincronizar con API
      if (await OfflineService.isConnected()) {
        try {
          await ApiService.deleteReport(reportId);
        } catch (e) {
          _isOfflineMode = true;
        }
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar reporte: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar filtros
  void updateFilters({
    ReportType? type,
    ReportFormat? format,
    ReportStatus? status,
    String? searchQuery,
    bool? showOnlyScheduled,
    bool? showOnlyCompleted,
  }) {
    _selectedType = type;
    _selectedFormat = format;
    _selectedStatus = status;
    _searchQuery = searchQuery ?? '';
    _showOnlyScheduled = showOnlyScheduled ?? false;
    _showOnlyCompleted = showOnlyCompleted ?? false;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _selectedType = null;
    _selectedFormat = null;
    _selectedStatus = null;
    _searchQuery = '';
    _showOnlyScheduled = false;
    _showOnlyCompleted = false;
    notifyListeners();
  }

  // Crear reportes de ejemplo
  List<Report> _createSampleReports() {
    return [
      Report(
        id: '1',
        title: 'Reporte Nacional de Reclusos - Julio 2025',
        description:
            'Reporte completo de la población penitenciaria nacional con estadísticas detalladas.',
        type: ReportType.nacional,
        format: ReportFormat.pdf,
        status: ReportStatus.completado,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt:
            DateTime.now().subtract(const Duration(days: 2, hours: -1)),
        createdBy: 'Director General',
        filePath: 'reports/nacional_julio_2025.pdf',
        fileSize: 2048576,
        tags: ['nacional', 'mensual', 'estadísticas'],
      ),
      Report(
        id: '2',
        title: 'Análisis Demográfico por Centro',
        description:
            'Análisis demográfico detallado de reclusos por centro penitenciario.',
        type: ReportType.demografico,
        format: ReportFormat.excel,
        status: ReportStatus.completado,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt:
            DateTime.now().subtract(const Duration(days: 5, hours: -2)),
        createdBy: 'Secretaría',
        filePath: 'reports/demografico_centros.xlsx',
        fileSize: 1536000,
        tags: ['demográfico', 'centros', 'análisis'],
      ),
      Report(
        id: '3',
        title: 'Reporte Médico Mensual',
        description: 'Reporte de atención médica y hospitalizaciones del mes.',
        type: ReportType.medico,
        format: ReportFormat.pdf,
        status: ReportStatus.pendiente,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        createdBy: 'Enfermería',
        tags: ['médico', 'mensual', 'hospitalizaciones'],
      ),
      Report(
        id: '4',
        title: 'Auditoría de Seguridad - Q2 2025',
        description:
            'Auditoría completa de seguridad y protocolos del segundo trimestre.',
        type: ReportType.auditoria,
        format: ReportFormat.pdf,
        status: ReportStatus.generando,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        createdBy: 'Auditoría',
        tags: ['auditoría', 'seguridad', 'trimestral'],
      ),
      Report(
        id: '5',
        title: 'Liberaciones Programadas - Agosto 2025',
        description: 'Lista de reclusos programados para liberación en agosto.',
        type: ReportType.liberaciones,
        format: ReportFormat.excel,
        status: ReportStatus.completado,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt:
            DateTime.now().subtract(const Duration(days: 1, hours: -30)),
        createdBy: 'Administración',
        filePath: 'reports/liberaciones_agosto.xlsx',
        fileSize: 512000,
        tags: ['liberaciones', 'agosto', 'programadas'],
      ),
    ];
  }

  // Calcular próxima ejecución para reportes programados
  DateTime _calculateNextRun(String cronExpression) {
    // Implementación simplificada - en producción usar una librería de cron
    return DateTime.now().add(const Duration(days: 1));
  }

  // Generar tamaño de archivo simulado
  int _generateFileSize(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 1024 * 1024 + (DateTime.now().millisecond * 100); // ~1MB
      case ReportFormat.excel:
        return 512 * 1024 + (DateTime.now().millisecond * 50); // ~512KB
      case ReportFormat.csv:
        return 256 * 1024 + (DateTime.now().millisecond * 25); // ~256KB
      case ReportFormat.json:
        return 128 * 1024 + (DateTime.now().millisecond * 10); // ~128KB
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
