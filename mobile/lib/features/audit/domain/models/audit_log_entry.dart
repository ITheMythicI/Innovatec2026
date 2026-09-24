class AuditLogEntry {
  final String id;
  final String action;
  final String role;
  final String resourceType;
  final String? resourceId;
  final String details;
  final DateTime timestamp;
  final String syncStatus;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.role,
    required this.resourceType,
    this.resourceId,
    required this.details,
    required this.timestamp,
    this.syncStatus = 'synced',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'role': role,
    'resourceType': resourceType,
    'resourceId': resourceId,
    'details': details,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'syncStatus': syncStatus,
  };

  Map<String, dynamic> toDatabaseMap() => {
    'id': id,
    'action': action,
    'role': role,
    'resource_type': resourceType,
    'resource_id': resourceId,
    'details': details,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
    id: json['id'] as String,
    action: json['action'] as String,
    role: json['role'] as String,
    resourceType: (json['resourceType'] ?? json['resource_type']) as String,
    resourceId: (json['resourceId'] ?? json['resource_id']) as String?,
    details: json['details'] as String? ?? '',
    timestamp: DateTime.parse((json['timestamp'] ?? json['created_at']) as String),
    syncStatus: (json['syncStatus'] ?? json['sync_status']) as String? ?? 'synced',
  );
}
