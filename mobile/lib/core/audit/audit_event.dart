import '../security/crypto_service.dart';

/// Tipo de evento para el registro de auditoría en desastres.
enum AuditEventType {
  authLogin,
  authLogout,
  emergencyProfileCreated,
  emergencyProfileUpdated,
  familyCreated,
  familyMemberStatusChanged,
  missingPersonReported,
  foundPersonReported,
  sensitiveMinorViewed,
  personStatusVerified,
  minorReunificationAuthorized,
  shelterStatusUpdated,
}

/// Representa una entrada inmutable dentro de la cadena de auditoría (Hash Chain).
class AuditEvent {
  final int sequence;
  final String id;
  final AuditEventType eventType;
  final String actorUserId;
  final String actorRole;
  final String entityId;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String prevHash;
  final String currentHash;
  final String signature;

  AuditEvent({
    required this.sequence,
    required this.id,
    required this.eventType,
    required this.actorUserId,
    required this.actorRole,
    required this.entityId,
    required this.metadata,
    required this.timestamp,
    required this.prevHash,
    required this.currentHash,
    required this.signature,
  });

  /// Crea un nuevo evento calculando su hash encadenado con el anterior.
  factory AuditEvent.create({
    required int sequence,
    required AuditEventType eventType,
    required String actorUserId,
    required String actorRole,
    required String entityId,
    required Map<String, dynamic> metadata,
    required String prevHash,
    required String signingSecret,
  }) {
    final id = CryptoService.generateId();
    final timestamp = DateTime.now().toUtc();

    final payloadToHash = {
      'sequence': sequence,
      'id': id,
      'eventType': eventType.name,
      'actorUserId': actorUserId,
      'actorRole': actorRole,
      'entityId': entityId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'prevHash': prevHash,
    };

    final currentHash = CryptoService.hashData(payloadToHash);
    final signature = CryptoService.signPayload(currentHash, signingSecret);

    return AuditEvent(
      sequence: sequence,
      id: id,
      eventType: eventType,
      actorUserId: actorUserId,
      actorRole: actorRole,
      entityId: entityId,
      metadata: metadata,
      timestamp: timestamp,
      prevHash: prevHash,
      currentHash: currentHash,
      signature: signature,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sequence': sequence,
      'id': id,
      'eventType': eventType.name,
      'actorUserId': actorUserId,
      'actorRole': actorRole,
      'entityId': entityId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'prevHash': prevHash,
      'currentHash': currentHash,
      'signature': signature,
    };
  }

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      sequence: json['sequence'] as int,
      id: json['id'] as String,
      eventType: AuditEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => AuditEventType.emergencyProfileUpdated,
      ),
      actorUserId: json['actorUserId'] as String,
      actorRole: json['actorRole'] as String,
      entityId: json['entityId'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      prevHash: json['prevHash'] as String,
      currentHash: json['currentHash'] as String,
      signature: json['signature'] as String,
    );
  }
}
