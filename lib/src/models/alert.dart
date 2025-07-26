import 'package:flutter/material.dart';

enum AlertType {
  seguridad('Seguridad', Icons.security, Colors.red),
  medico('Médico', Icons.medical_services, Colors.orange),
  administrativo('Administrativo', Icons.admin_panel_settings, Colors.blue),
  mantenimiento('Mantenimiento', Icons.build, Colors.yellow),
  visita('Visita', Icons.people, Colors.green),
  traslado('Traslado', Icons.transfer_within_a_station, Colors.purple),
  emergencia('Emergencia', Icons.emergency, Colors.red),
  recordatorio('Recordatorio', Icons.notification_important, Colors.cyan);

  const AlertType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

enum AlertPriority {
  critico('Crítico', Colors.red, Icons.priority_high),
  alto('Alto', Colors.orange, Icons.warning),
  medio('Medio', Colors.yellow, Icons.info),
  bajo('Bajo', Colors.green, Icons.check_circle);

  const AlertPriority(this.displayName, this.color, this.icon);
  final String displayName;
  final Color color;
  final IconData icon;
}

enum AlertStatus {
  activa('Activa', Colors.red, Icons.radio_button_checked),
  enProceso('En Proceso', Colors.orange, Icons.pending),
  resuelta('Resuelta', Colors.green, Icons.check_circle),
  cerrada('Cerrada', Colors.grey, Icons.cancel);

  const AlertStatus(this.displayName, this.color, this.icon);
  final String displayName;
  final Color color;
  final IconData icon;
}

class Alert {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final AlertPriority priority;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String createdBy;
  final String? assignedTo;
  final String? prisonName;
  final String? inmateId;
  final String? inmateName;
  final Map<String, dynamic>? metadata;
  final List<String> tags;
  final bool isRead;
  final bool requiresAction;
  final String? notes;
  final List<String> attachments;

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    required this.createdBy,
    this.assignedTo,
    this.prisonName,
    this.inmateId,
    this.inmateName,
    this.metadata,
    this.tags = const [],
    this.isRead = false,
    this.requiresAction = true,
    this.notes,
    this.attachments = const [],
  });

  Alert copyWith({
    String? id,
    String? title,
    String? description,
    AlertType? type,
    AlertPriority? priority,
    AlertStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? createdBy,
    String? assignedTo,
    String? prisonName,
    String? inmateId,
    String? inmateName,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isRead,
    bool? requiresAction,
    String? notes,
    List<String>? attachments,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      prisonName: prisonName ?? this.prisonName,
      inmateId: inmateId ?? this.inmateId,
      inmateName: inmateName ?? this.inmateName,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      isRead: isRead ?? this.isRead,
      requiresAction: requiresAction ?? this.requiresAction,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'prisonName': prisonName,
      'inmateId': inmateId,
      'inmateName': inmateName,
      'metadata': metadata,
      'tags': tags,
      'isRead': isRead,
      'requiresAction': requiresAction,
      'notes': notes,
      'attachments': attachments,
    };
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AlertType.values.firstWhere((e) => e.name == json['type']),
      priority:
          AlertPriority.values.firstWhere((e) => e.name == json['priority']),
      status: AlertStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      createdBy: json['createdBy'],
      assignedTo: json['assignedTo'],
      prisonName: json['prisonName'],
      inmateId: json['inmateId'],
      inmateName: json['inmateName'],
      metadata: json['metadata'],
      tags: List<String>.from(json['tags'] ?? []),
      isRead: json['isRead'] ?? false,
      requiresAction: json['requiresAction'] ?? true,
      notes: json['notes'],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  // Métodos de utilidad
  bool get isCritical => priority == AlertPriority.critico;
  bool get isActive =>
      status == AlertStatus.activa || status == AlertStatus.enProceso;
  bool get isResolved =>
      status == AlertStatus.resuelta || status == AlertStatus.cerrada;
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
}
