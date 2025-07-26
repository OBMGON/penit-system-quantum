class Hospitalization {
  final String id;
  final String inmateNumber;
  final String reason;
  final String hospital;
  final String doctor;
  final DateTime admissionDate;
  final DateTime estimatedDischargeDate;
  final String status;
  final String priority;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dischargeDate;

  Hospitalization({
    required this.id,
    required this.inmateNumber,
    required this.reason,
    required this.hospital,
    required this.doctor,
    required this.admissionDate,
    required this.estimatedDischargeDate,
    required this.status,
    required this.priority,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.dischargeDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inmateNumber': inmateNumber,
      'reason': reason,
      'hospital': hospital,
      'doctor': doctor,
      'admissionDate': admissionDate.toIso8601String(),
      'estimatedDischargeDate': estimatedDischargeDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dischargeDate': dischargeDate?.toIso8601String(),
    };
  }

  factory Hospitalization.fromJson(Map<String, dynamic> json) {
    return Hospitalization(
      id: json['id'],
      inmateNumber: json['inmateNumber'],
      reason: json['reason'],
      hospital: json['hospital'],
      doctor: json['doctor'],
      admissionDate: DateTime.parse(json['admissionDate']),
      estimatedDischargeDate: DateTime.parse(json['estimatedDischargeDate']),
      status: json['status'],
      priority: json['priority'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      dischargeDate: json['dischargeDate'] != null
          ? DateTime.parse(json['dischargeDate'])
          : null,
    );
  }
}
