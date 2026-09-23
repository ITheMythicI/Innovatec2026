import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/audit/audit_service.dart';
import 'package:innovatec_mobile/core/audit/audit_event.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  ChainVerificationResult? _lastVerification;

  @override
  void initState() {
    super.initState();
    _verifyChain();
  }

  void _verifyChain() {
    setState(() {
      _lastVerification = AuditService().verifyChainIntegrity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text(
          'Auditoría Inmutable (Hash Chain)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Verificar Cadena Criptográfica',
            icon: const Icon(Icons.security, color: Colors.tealAccent),
            onPressed: _verifyChain,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastVerification != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _lastVerification!.isValid
                  ? Colors.teal.shade900.withValues(alpha: 0.4)
                  : Colors.red.shade900.withValues(alpha: 0.6),
              child: Row(
                children: [
                  Icon(
                    _lastVerification!.isValid ? Icons.verified : Icons.error_outline,
                    color: _lastVerification!.isValid ? Colors.tealAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastVerification!.isValid
                              ? 'Cadena de Auditoría Íntegra'
                              : 'Alerta de Seguridad: Cadena Corrompida',
                          style: TextStyle(
                            color: _lastVerification!.isValid ? Colors.tealAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lastVerification!.message,
                          style: TextStyle(color: Colors.grey.shade300, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _verifyChain,
                    child: const Text('Revalidar', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<AuditEvent>>(
              stream: AuditService().eventsStream,
              builder: (context, snapshot) {
                final events = AuditService().events.reversed.toList();

                if (events.isEmpty) {
                  return const Center(
                    child: Text('No hay eventos de auditoría registrados.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventTile(context, event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(BuildContext context, AuditEvent event) {
    return Card(
      color: const Color(0xFF1B2028),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF283240)),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF243040),
          child: Text(
            '#${event.sequence}',
            style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          _formatEventType(event.eventType),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Actor: ${event.actorUserId} [${event.actorRole}] • ${_formatDate(event.timestamp)}',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHashRow('Prev Hash:', event.prevHash),
                const SizedBox(height: 6),
                _buildHashRow('Current Hash:', event.currentHash),
                const SizedBox(height: 6),
                _buildHashRow('Firma Digital (HMAC):', event.signature),
                const Divider(color: Color(0xFF2A3442), height: 16),
                const Text('Metadatos del Evento:', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF11141A), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    event.metadata.toString(),
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashRow(String label, String hash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        SelectableText(
          hash,
          style: const TextStyle(color: Colors.tealAccent, fontSize: 10, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  String _formatEventType(AuditEventType type) {
    switch (type) {
      case AuditEventType.authLogin:
        return 'Inicio de Sesión / Cambio de Rol';
      case AuditEventType.authLogout:
        return 'Cierre de Sesión';
      case AuditEventType.emergencyProfileCreated:
        return 'Perfil de Emergencia Creado';
      case AuditEventType.emergencyProfileUpdated:
        return 'Ficha Médica Actualizada';
      case AuditEventType.familyCreated:
        return 'Núcleo Familiar Creado';
      case AuditEventType.familyMemberStatusChanged:
        return 'Estado Familiar Actualizado';
      case AuditEventType.missingPersonReported:
        return 'Reporte de Persona Desaparecida';
      case AuditEventType.foundPersonReported:
        return 'Reporte de Persona en Albergue';
      case AuditEventType.sensitiveMinorViewed:
        return 'Consulta de Datos Sensibles de Menor';
      case AuditEventType.personStatusVerified:
        return 'Verificación Oficial de Persona';
      case AuditEventType.minorReunificationAuthorized:
        return 'Reunificación Oficial de Menor Autorizada';
      case AuditEventType.shelterStatusUpdated:
        return 'Actualización de Capacidad de Albergue';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} UTC';
  }
}
