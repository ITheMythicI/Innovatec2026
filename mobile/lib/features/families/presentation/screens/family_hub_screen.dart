import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_group.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_member.dart';
import 'package:innovatec_mobile/features/families/domain/services/family_service.dart';

class FamilyHubScreen extends StatelessWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text(
          'Núcleo Familiar & Confianza',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar Integrante',
            icon: const Icon(Icons.group_add_outlined, color: Colors.tealAccent),
            onPressed: () => _showAddMemberDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<FamilyGroup?>(
        stream: FamilyService().familyStream,
        builder: (context, snapshot) {
          final family = FamilyService().currentFamily;
          if (family == null) {
            return const Center(
              child: Text('No hay grupo familiar configurado.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tarjeta Resumen del Grupo Familiar
              _buildFamilyHeader(context, family),
              const SizedBox(height: 16),

              // Punto de Encuentro Preacordado
              _buildMeetingPointCard(context, family),
              const SizedBox(height: 16),

              // Título del Listado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Integrantes (${family.members.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Toca para actualizar estado',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Lista de Miembros
              ...family.members.map((member) => _buildMemberCard(context, member)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFamilyHeader(BuildContext context, FamilyGroup family) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1D2939), const Color(0xFF101828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF344054)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                family.familyName,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${family.id}',
                  style: const TextStyle(color: Colors.tealAccent, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de Estados Rápidos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusPill('A Salvo', '${family.safeCount}', Colors.greenAccent),
              _buildStatusPill('En Refugio', '${family.shelterCount}', Colors.amberAccent),
              _buildStatusPill('Urgente', '${family.urgentCount}', Colors.redAccent),
              _buildStatusPill('Sin Contacto', '${family.unreachableCount}', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
      ],
    );
  }

  Widget _buildMeetingPointCard(BuildContext context, FamilyGroup family) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B222C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade800),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Punto de Reunión Familiar Acordado',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  family.meetingPointLocation,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, FamilyMember member) {
    Color statusColor;
    switch (member.status) {
      case MemberEmergencyStatus.safe:
        statusColor = Colors.greenAccent;
        break;
      case MemberEmergencyStatus.inShelter:
        statusColor = Colors.amberAccent;
        break;
      case MemberEmergencyStatus.injured:
        statusColor = Colors.redAccent;
        break;
      case MemberEmergencyStatus.unreachable:
        statusColor = Colors.grey;
        break;
    }

    return Card(
      color: const Color(0xFF1E242E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.4)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Text(member.status.emoji, style: const TextStyle(fontSize: 18)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.fullName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            if (member.isMinor)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('MENOR', style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${member.relationship} • ${member.age} años',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Estado: ${member.status.label}${member.shelterName != null ? " (${member.shelterName})" : ""}',
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (member.lastKnownLocation != null)
              Text(
                'Ubicación: ${member.lastKnownLocation}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            if (member.notes != null)
              Text(
                'Nota: ${member.notes}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: const Icon(Icons.edit_note, color: Colors.tealAccent),
        onTap: () => _showUpdateStatusDialog(context, member),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, FamilyMember member) {
    MemberEmergencyStatus selectedStatus = member.status;
    final shelterController = TextEditingController(text: member.shelterName ?? '');
    final locationController = TextEditingController(text: member.lastKnownLocation ?? '');
    final notesController = TextEditingController(text: member.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Actualizar Estado: ${member.fullName}',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),

                    // Selector de Estado
                    ...MemberEmergencyStatus.values.map((st) {
                      return RadioListTile<MemberEmergencyStatus>(
                        value: st,
                        groupValue: selectedStatus,
                        activeColor: Colors.tealAccent,
                        title: Text('${st.emoji} ${st.label}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        onChanged: (val) => setModalState(() => selectedStatus = val ?? selectedStatus),
                      );
                    }),
                    const SizedBox(height: 8),

                    if (selectedStatus == MemberEmergencyStatus.inShelter)
                      TextField(
                        controller: shelterController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Nombre del Refugio / Albergue', filled: true, fillColor: Color(0xFF222933)),
                      ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Última Ubicación o Referencia', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Notas médicas o de auxilio', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Guardar Estado y Firmar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        final auth = AuthService().currentUser;
                        await FamilyService().updateMemberStatus(
                          memberId: member.id,
                          newStatus: selectedStatus,
                          shelterName: shelterController.text.trim().isEmpty ? null : shelterController.text.trim(),
                          lastKnownLocation: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          actorUserId: auth?.id ?? 'USR-ANON',
                          actorRole: auth?.role.code ?? 'CITIZEN',
                        );

                        Navigator.pop(bCtx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Estado familiar actualizado y guardado en SQLite/Audit.'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final relationshipController = TextEditingController();
    final ageController = TextEditingController();
    final notesController = TextEditingController();
    bool isMinor = false;
    MemberEmergencyStatus status = MemberEmergencyStatus.safe;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181D24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (mCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Agregar Integrante Familiar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Nombre Completo', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: relationshipController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Parentesco (Hijo, Cónyuge...)', filled: true, fillColor: Color(0xFF222933)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Edad', filled: true, fillColor: Color(0xFF222933)),
                            onChanged: (v) {
                              final age = int.tryParse(v) ?? 0;
                              setModalState(() => isMinor = age > 0 && age < 18);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Notas o Padecimientos', filled: true, fillColor: Color(0xFF222933)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Agregar a Mi Familia', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        final auth = AuthService().currentUser;
                        final age = int.tryParse(ageController.text) ?? 18;

                        await FamilyService().addMember(
                          fullName: nameController.text.trim(),
                          relationship: relationshipController.text.trim().isEmpty ? 'Familiar' : relationshipController.text.trim(),
                          age: age,
                          isMinor: isMinor,
                          status: status,
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          actorUserId: auth?.id ?? 'USR-ANON',
                          actorRole: auth?.role.code ?? 'CITIZEN',
                        );

                        Navigator.pop(mCtx);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
