class AuditLog {
  final String id;
  final String userId;
  final String username;
  final String action;
  final String prisonId;
  final DateTime timestamp;
  final String details;
  final String severity;
  final String ipAddress;

  AuditLog({
    required this.id,
    required this.userId,
    required this.username,
    required this.action,
    required this.prisonId,
    required this.timestamp,
    this.details = '',
    this.severity = 'Bajo',
    this.ipAddress = '',
  });

  String get formattedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
