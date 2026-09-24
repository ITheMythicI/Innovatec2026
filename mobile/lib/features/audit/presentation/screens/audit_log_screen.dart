import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
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
      backgroundColor: ResguardoTheme.background,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auditoría Inmutable',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 18,
              ),
            ),
            Text(
              'HASH CHAIN CRIPTOGRÁFICA & REGISTRO FORENSE',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: ResguardoTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Verificar Cadena Criptográfica',
            icon: const Icon(Icons.security, color: ResguardoTheme.primary),
            onPressed: _verifyChain,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastVerification != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _lastVerification!.isValid
                    ? ResguardoTheme.safeEmerald.withValues(alpha: 0.12)
                    : ResguardoTheme.emergencyCrimson.withValues(alpha: 0.12),
                border: Border(
                  bottom: BorderSide(
                    color: _lastVerification!.isValid
                        ? ResguardoTheme.safeEmerald.withValues(alpha: 0.3)
                        : ResguardoTheme.emergencyCrimson.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _lastVerification!.isValid ? Icons.verified : Icons.error_outline,
                    color: _lastVerification!.isValid ? ResguardoTheme.safeEmerald : ResguardoTheme.emergencyCrimson,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastVerification!.isValid
                              ? 'CADENA DE AUDITORÍA ÍNTEGRA'
                              : 'ALERTA: INTEGRIDAD DE CADENA COMPROMETIDA',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            color: _lastVerification!.isValid ? const Color(0xFF065F46) : ResguardoTheme.emergencyCrimson,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _lastVerification!.message,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: _lastVerification!.isValid ? const Color(0xFF047857) : ResguardoTheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ResguardoTheme.primary,
                      side: const BorderSide(color: ResguardoTheme.outline),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    onPressed: _verifyChain,
                    child: const Text('Revalidar', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11)),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 48, color: ResguardoTheme.textMuted),
                        SizedBox(height: 10),
                        Text(
                          'No hay eventos de auditoría registrados.',
                          style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ResguardoTheme.outline),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: ResguardoTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '#${event.sequence}',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                color: ResguardoTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            _formatEventType(event.eventType),
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              color: ResguardoTheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Actor: ${event.actorUserId} [${event.actorRole}] • ${_formatDate(event.timestamp)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: ResguardoTheme.textMuted,
              fontSize: 11,
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: const BoxDecoration(
                color: ResguardoTheme.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHashRow('PREVIOUS BLOCK HASH:', event.prevHash),
                  const SizedBox(height: 8),
                  _buildHashRow('CURRENT BLOCK HASH (SHA-256):', event.currentHash),
                  const SizedBox(height: 8),
                  _buildHashRow('DIGITAL SIGNATURE (HMAC-SHA256):', event.signature),
                  const Divider(color: ResguardoTheme.outlineVariant, height: 20),
                  const Text(
                    'METADATOS DEL EVENTO (PAYLOAD INMUTABLE):',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: ResguardoTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ResguardoTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ResguardoTheme.outlineVariant),
                    ),
                    child: SelectableText(
                      event.metadata.toString(),
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: ResguardoTheme.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashRow(String label, String hash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            color: ResguardoTheme.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ResguardoTheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: ResguardoTheme.outlineVariant),
          ),
          child: SelectableText(
            hash,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              color: ResguardoTheme.primary,
              fontSize: 10,
            ),
          ),
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
