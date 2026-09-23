import 'dart:async';
import 'audit_event.dart';
import '../security/crypto_service.dart';

/// Resultado de la verificación de integridad de la cadena de auditoría.
class ChainVerificationResult {
  final bool isValid;
  final int totalEvents;
  final int? corruptedSequence;
  final String message;

  const ChainVerificationResult({
    required this.isValid,
    required this.totalEvents,
    this.corruptedSequence,
    required this.message,
  });
}

/// Servicio central de auditoría inmutable (Audit Trail con Hash Chain).
class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal() {
    _initGenesisBlock();
  }

  static const String genesisHash = '0000000000000000000000000000000000000000000000000000000000000000';
  final List<AuditEvent> _events = [];
  final _eventStreamController = StreamController<List<AuditEvent>>.broadcast();

  Stream<List<AuditEvent>> get eventsStream => _eventStreamController.stream;
  List<AuditEvent> get events => List.unmodifiable(_events);

  void _initGenesisBlock() {
    if (_events.isEmpty) {
      final genesis = AuditEvent.create(
        sequence: 1,
        eventType: AuditEventType.authLogin,
        actorUserId: 'SYSTEM_BOOT',
        actorRole: 'SYSTEM',
        entityId: 'GENESIS_BLOCK',
        metadata: {'info': 'Cadena de auditoría inicializada para respuesta ante desastres'},
        prevHash: genesisHash,
        signingSecret: 'INNOVATEC_GENESIS_SECRET',
      );
      _events.add(genesis);
      _eventStreamController.add(_events);
    }
  }

  /// Registra un evento de auditoría encadenado.
  Future<AuditEvent> logEvent({
    required AuditEventType eventType,
    required String actorUserId,
    required String actorRole,
    required String entityId,
    required Map<String, dynamic> metadata,
    String signingSecret = 'USER_OFFLINE_SECRET_KEY',
  }) async {
    final nextSequence = _events.length + 1;
    final lastHash = _events.isNotEmpty ? _events.last.currentHash : genesisHash;

    final event = AuditEvent.create(
      sequence: nextSequence,
      eventType: eventType,
      actorUserId: actorUserId,
      actorRole: actorRole,
      entityId: entityId,
      metadata: metadata,
      prevHash: lastHash,
      signingSecret: signingSecret,
    );

    _events.add(event);
    _eventStreamController.add(_events);
    return event;
  }

  /// Verifica la integridad criptográfica de toda la cadena de auditoría.
  ChainVerificationResult verifyChainIntegrity() {
    if (_events.isEmpty) {
      return const ChainVerificationResult(
        isValid: true,
        totalEvents: 0,
        message: 'No hay eventos en la cadena.',
      );
    }

    String expectedPrevHash = genesisHash;

    for (int i = 0; i < _events.length; i++) {
      final event = _events[i];

      // 1. Verificar prevHash
      if (event.prevHash != expectedPrevHash) {
        return ChainVerificationResult(
          isValid: false,
          totalEvents: _events.length,
          corruptedSequence: event.sequence,
          message: 'Fallo de enlace en secuencia #${event.sequence}: el prevHash no coincide.',
        );
      }

      // 2. Recalcular currentHash
      final payloadToHash = {
        'sequence': event.sequence,
        'id': event.id,
        'eventType': event.eventType.name,
        'actorUserId': event.actorUserId,
        'actorRole': event.actorRole,
        'entityId': event.entityId,
        'metadata': event.metadata,
        'timestamp': event.timestamp.toIso8601String(),
        'prevHash': event.prevHash,
      };
      final recalculatedHash = CryptoService.hashData(payloadToHash);

      if (recalculatedHash != event.currentHash) {
        return ChainVerificationResult(
          isValid: false,
          totalEvents: _events.length,
          corruptedSequence: event.sequence,
          message: 'Fallo de integridad en secuencia #${event.sequence}: los datos fueron alterados.',
        );
      }

      expectedPrevHash = event.currentHash;
    }

    return ChainVerificationResult(
      isValid: true,
      totalEvents: _events.length,
      message: 'Cadena de auditoría 100% íntegra. Todos los ${_events.length} bloques son válidos.',
    );
  }
}
