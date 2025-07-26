import 'package:flutter/material.dart';

enum ReportType {
  nacional('Reporte Nacional', Icons.flag, Colors.blue),
  porCarcel('Por Cárcel', Icons.business, Colors.green),
  demografico('Demográfico', Icons.people, Colors.orange),
  medico('Médico', Icons.medical_services, Colors.red),
  seguridad('Seguridad', Icons.security, Colors.purple),
  financiero('Financiero', Icons.account_balance_wallet, Colors.teal),
  auditoria('Auditoría', Icons.assessment, Colors.indigo),
  liberaciones('Liberaciones', Icons.exit_to_app, Colors.amber);

  const ReportType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

enum ReportFormat {
  pdf('PDF', Icons.picture_as_pdf, Colors.red),
  excel('Excel', Icons.table_chart, Colors.green),
  csv('CSV', Icons.table_view, Colors.blue),
  json('JSON', Icons.code, Colors.orange);

  const ReportFormat(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

enum ReportStatus {
  pendiente('Pendiente', Icons.pending, Colors.orange),
  generando('Generando', Icons.hourglass_empty, Colors.blue),
  completado('Completado', Icons.check_circle, Colors.green),
  error('Error', Icons.error, Colors.red),
  cancelado('Cancelado', Icons.cancel, Colors.grey);

  const ReportStatus(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

class Report {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportFormat format;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String createdBy;
  final String? assignedTo;
  final Map<String, dynamic> parameters;
  final String? filePath;
  final int? fileSize;
  final String? errorMessage;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final bool isScheduled;
  final String? scheduleCron;
  final DateTime? nextRun;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.format,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.assignedTo,
    this.parameters = const {},
    this.filePath,
    this.fileSize,
    this.errorMessage,
    this.metadata = const {},
    this.tags = const [],
    this.isScheduled = false,
    this.scheduleCron,
    this.nextRun,
  });

  Report copyWith({
    String? id,
    String? title,
    String? description,
    ReportType? type,
    ReportFormat? format,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? createdBy,
    String? assignedTo,
    Map<String, dynamic>? parameters,
    String? filePath,
    int? fileSize,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isScheduled,
    String? scheduleCron,
    DateTime? nextRun,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      format: format ?? this.format,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      parameters: parameters ?? this.parameters,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduleCron: scheduleCron ?? this.scheduleCron,
      nextRun: nextRun ?? this.nextRun,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'format': format.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'parameters': parameters,
      'filePath': filePath,
      'fileSize': fileSize,
      'errorMessage': errorMessage,
      'metadata': metadata,
      'tags': tags,
      'isScheduled': isScheduled,
      'scheduleCron': scheduleCron,
      'nextRun': nextRun?.toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      format: ReportFormat.values.firstWhere((e) => e.name == json['format']),
      status: ReportStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdBy: json['createdBy'],
      assignedTo: json['assignedTo'],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      errorMessage: json['errorMessage'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      isScheduled: json['isScheduled'] ?? false,
      scheduleCron: json['scheduleCron'],
      nextRun: json['nextRun'] != null ? DateTime.parse(json['nextRun']) : null,
    );
  }

  // Métodos de utilidad
  bool get isCompleted => status == ReportStatus.completado;
  bool get isPending => status == ReportStatus.pendiente;
  bool get isGenerating => status == ReportStatus.generando;
  bool get hasError => status == ReportStatus.error;
  bool get isCancelled => status == ReportStatus.cancelado;

  Duration get age => DateTime.now().difference(createdAt);
  String get ageText {
    final days = age.inDays;
    final hours = age.inHours;
    final minutes = age.inMinutes;

    if (days > 0) return '$days día${days > 1 ? 's' : ''}';
    if (hours > 0) return '$hours hora${hours > 1 ? 's' : ''}';
    if (minutes > 0) return '$minutes minuto${minutes > 1 ? 's' : ''}';
    return 'Ahora mismo';
  }

  String get fileSizeText {
    if (fileSize == null) return 'N/A';
    if (fileSize! < 1024) return '${fileSize} B';
    if (fileSize! < 1024 * 1024)
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// Modelo para estadísticas de reportes
class ReportStatistics {
  final int totalReports;
  final int completedReports;
  final int pendingReports;
  final int errorReports;
  final Map<ReportType, int> reportsByType;
  final Map<ReportFormat, int> reportsByFormat;
  final Map<ReportStatus, int> reportsByStatus;
  final double averageGenerationTime;
  final int totalFileSize;
  final List<String> topTags;

  ReportStatistics({
    required this.totalReports,
    required this.completedReports,
    required this.pendingReports,
    required this.errorReports,
    required this.reportsByType,
    required this.reportsByFormat,
    required this.reportsByStatus,
    required this.averageGenerationTime,
    required this.totalFileSize,
    required this.topTags,
  });

  double get completionRate =>
      totalReports > 0 ? completedReports / totalReports : 0.0;
  double get errorRate => totalReports > 0 ? errorReports / totalReports : 0.0;
  String get totalFileSizeText {
    if (totalFileSize < 1024) return '${totalFileSize} B';
    if (totalFileSize < 1024 * 1024)
      return '${(totalFileSize / 1024).toStringAsFixed(1)} KB';
    return '${(totalFileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
