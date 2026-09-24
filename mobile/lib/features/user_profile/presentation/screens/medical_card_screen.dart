import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/utils/qr_code_widget.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/services/profile_service.dart';

class MedicalCardScreen extends StatelessWidget {
  const MedicalCardScreen({super.key});

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
              'Credencial Digital & Ficha Médica',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 17,
              ),
            ),
            Text(
              'DATOS VITALES OFFLINE • TRIAJE MÉDICO',
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
            tooltip: 'Código Triage Rápido',
            icon: const Icon(Icons.qr_code_2, color: ResguardoTheme.emergencyCrimson),
            onPressed: () => _showTriageCodeModal(context),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile>(
        stream: ProfileService().profileStream,
        builder: (context, snapshot) {
          final profile = ProfileService().currentProfile;
          final authUser = AuthService().currentUser;
          final uniqueCode = authUser?.uniqueCitizenCode ?? 'NOVA-MX-2026-001';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            children: [
              // Tarjeta Roja de Identificación Médica Rápida
              _buildPrimaryMedicalBadge(context, profile, uniqueCode),
              const SizedBox(height: 14),

              // Alergias y Medicamentos
              _buildMedicalSection(
                title: 'Alergias Críticas',
                icon: Icons.warning_amber_rounded,
                iconColor: ResguardoTheme.emergencyCrimson,
                items: profile.allergies,
                emptyText: 'Sin alergias conocidas registradas.',
              ),
              const SizedBox(height: 12),

              _buildMedicalSection(
                title: 'Medicamentos Vitales',
                icon: Icons.medication_liquid_outlined,
                iconColor: ResguardoTheme.warningAmber,
                items: profile.vitalMedications,
                emptyText: 'No requiere medicamentos continuos.',
              ),
              const SizedBox(height: 12),

              _buildMedicalSection(
                title: 'Padecimientos / Condiciones Crónicas',
                icon: Icons.favorite_border,
                iconColor: const Color(0xFF7C3AED),
                items: profile.chronicConditions,
                emptyText: 'Sin padecimientos crónicos declarados.',
              ),
              const SizedBox(height: 14),

              // Contactos de Emergencia SOS
              _buildEmergencyContactsSection(context, profile),
              const SizedBox(height: 14),

              // Notas médicas adicionales
              if (profile.medicalNotes != null && profile.medicalNotes!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ResguardoTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ResguardoTheme.outline),
                    boxShadow: const [ResguardoTheme.shadowLevel2],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notes, color: ResguardoTheme.primary, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Notas Médicas para Brigadistas:',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              color: ResguardoTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.medicalNotes!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: ResguardoTheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrimaryMedicalBadge(BuildContext context, UserProfile profile, String uniqueCode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ResguardoTheme.emergencyCrimson, Color(0xFF990011)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} años • ${profile.isOrganDonor ? "Donador de Órganos [SÍ]" : "No donador"}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: $uniqueCode',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [ResguardoTheme.shadowLevel2],
                ),
                child: Column(
                  children: [
                    const Text(
                      'SANGRE',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: ResguardoTheme.emergencyCrimson,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile.bloodType,
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        color: ResguardoTheme.emergencyCrimson,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, color: Colors.white70, size: 12),
                SizedBox(width: 4),
                Text(
                  'Disponible en pantalla de bloqueo y triaje de campo',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ResguardoTheme.outline),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  color: ResguardoTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: ResguardoTheme.textMuted,
                fontSize: 12,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      color: iconColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ResguardoTheme.outline),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ResguardoTheme.safeEmerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.phone_in_talk, color: ResguardoTheme.safeEmerald, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Contactos SOS Prioritarios',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  color: ResguardoTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...profile.emergencyContacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: ResguardoTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ResguardoTheme.outline),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: ResguardoTheme.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: ResguardoTheme.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            color: ResguardoTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${contact.relationship} • ${contact.phone}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: ResguardoTheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: ResguardoTheme.primary, size: 18),
                    tooltip: 'Copiar teléfono',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Teléfono copiado: ${contact.phone}'),
                          backgroundColor: ResguardoTheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showTriageCodeModal(BuildContext context) {
    final payload = ProfileService().currentProfile.toCompactTriagePayload();
    final authUser = AuthService().currentUser;
    final uniqueCode = authUser?.uniqueCitizenCode ?? 'NOVA-MX-2026-001';

    showModalBottomSheet(
      context: context,
      backgroundColor: ResguardoTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_2, color: ResguardoTheme.emergencyCrimson, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Credencial & Triaje Offline QR',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        color: ResguardoTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Este código QR se escanea directamente por brigadistas y personal de albergues para censo de sobrevivientes y acceso inmediato sin red.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: ResguardoTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TacticalQrWidget(
                    data: 'RED-NOVA:$uniqueCode|$payload',
                    size: 160,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ResguardoTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ResguardoTheme.outline),
                  ),
                  child: SelectableText(
                    'ID: $uniqueCode\n$payload',
                    style: const TextStyle(
                      color: ResguardoTheme.primary,
                      fontSize: 11,
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResguardoTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
