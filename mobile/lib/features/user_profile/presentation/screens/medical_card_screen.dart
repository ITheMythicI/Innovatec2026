import 'package:flutter/material.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/services/profile_service.dart';

class MedicalCardScreen extends StatelessWidget {
  const MedicalCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text(
          'Ficha Médica de Emergencia',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Código Triage Rápido',
            icon: const Icon(Icons.qr_code_2, color: Colors.redAccent),
            onPressed: () => _showTriageCodeModal(context),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile>(
        stream: ProfileService().profileStream,
        builder: (context, snapshot) {
          final profile = ProfileService().currentProfile;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tarjeta Roja de Identificación Médica Rápida
              _buildPrimaryMedicalBadge(context, profile),
              const SizedBox(height: 16),

              // Alergias y Medicamentos
              _buildMedicalSection(
                title: 'Alergias Críticas',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.redAccent,
                items: profile.allergies,
                emptyText: 'Sin alergias conocidas registradas.',
              ),
              const SizedBox(height: 12),

              _buildMedicalSection(
                title: 'Medicamentos Vitales',
                icon: Icons.medication_liquid_outlined,
                iconColor: Colors.amberAccent,
                items: profile.vitalMedications,
                emptyText: 'No requiere medicamentos continuos.',
              ),
              const SizedBox(height: 12),

              _buildMedicalSection(
                title: 'Padecimientos / Condiciones Crónicas',
                icon: Icons.favorite_border,
                iconColor: Colors.purpleAccent,
                items: profile.chronicConditions,
                emptyText: 'Sin padecimientos crónicos declarados.',
              ),
              const SizedBox(height: 16),

              // Contactos de Emergencia SOS
              _buildEmergencyContactsSection(context, profile),
              const SizedBox(height: 16),

              // Notas médicas adicionales
              if (profile.medicalNotes != null && profile.medicalNotes!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A212C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E3846)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notas Médicas para Brigadistas:',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(profile.medicalNotes!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrimaryMedicalBadge(BuildContext context, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B0000), Color(0xFF4A0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
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
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.age} años • ${profile.isOrganDonor ? "Donador de Órganos ✅" : "No donador"}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('SANGRE', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(
                      profile.bloodType,
                      style: const TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Disponible en pantalla de bloqueo / Triaje de emergencia',
            style: TextStyle(color: Colors.white60, fontSize: 10),
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
        color: const Color(0xFF1B2028),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28313E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(emptyText, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: iconColor.withOpacity(0.3)),
                  ),
                  child: Text(item, style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.w600)),
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
        color: const Color(0xFF1B2028),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28313E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_in_talk, color: Colors.greenAccent, size: 18),
              SizedBox(width: 8),
              Text('Contactos SOS Prioritarios', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...profile.emergencyContacts.map((contact) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF243040),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${contact.relationship} • ${contact.phone}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.tealAccent, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Teléfono copiado: ${contact.phone}')),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showTriageCodeModal(BuildContext context) {
    final payload = ProfileService().currentProfile.toCompactTriagePayload();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Payload Médico para Triaje Offline',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Este payload binario/JSON estructurado se comparte por BLE Mesh o escáner QR con brigadistas sin necesidad de conexión a internet.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11141A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: SelectableText(
                    payload,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                  child: const Text('Cerrar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
