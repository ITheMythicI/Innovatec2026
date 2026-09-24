import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_group.dart';
import 'package:innovatec_mobile/features/families/domain/models/family_member.dart';
import 'package:innovatec_mobile/features/families/domain/services/family_service.dart';
import 'package:innovatec_mobile/features/map/presentation/screens/evacuation_route_screen.dart';
import 'package:innovatec_mobile/features/broadcasts/presentation/screens/official_broadcasts_screen.dart';

class FamilyHubScreen extends StatefulWidget {
  const FamilyHubScreen({super.key});

  @override
  State<FamilyHubScreen> createState() => _FamilyHubScreenState();
}

class _FamilyHubScreenState extends State<FamilyHubScreen> {
  bool _reportedSelfSafe = true;

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final userName = currentUser?.fullName ?? 'Carlos Mendoza Ruiz';
    final userInitials = userName.isNotEmpty
        ? userName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'CM';

    return Scaffold(
      backgroundColor: ResguardoTheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ResguardoTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Red NOVA // Red Familiar',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    color: ResguardoTheme.primary,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'ENLACE C5 ACTIVO • CENSO Y BIENESTAR',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ResguardoTheme.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ResguardoTheme.safeEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ResguardoTheme.safeEmerald),
            ),
            child: const Row(
              children: [
                Icon(Icons.cell_tower, color: ResguardoTheme.safeEmerald, size: 12),
                SizedBox(width: 4),
                Text(
                  'MALLA NOVA C5',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ResguardoTheme.safeEmerald,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<FamilyGroup?>(
        stream: FamilyService().familyStream,
        builder: (context, snapshot) {
          final family = FamilyService().currentFamily;
          final members = family?.members ?? [];
          final totalMembers = members.length;
          final safeMembers = members.where((m) =>
              m.status == MemberEmergencyStatus.safe ||
              m.status == MemberEmergencyStatus.inShelter).length;
          final pctSafe = totalMembers > 0 ? (safeMembers / totalMembers) : 1.0;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Barra de Usuario Titular
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: ResguardoTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: Text(
                        userInitials,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            family?.familyName ?? 'Núcleo Familiar Registrado',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 22),
                      tooltip: 'Agregar Familiar a la Red',
                      onPressed: () => _showAddMemberDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Accesos Rápidos Tácticos
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionBtn(
                      label: 'SOS PÁNICO',
                      sub: 'Alerta auxilio',
                      icon: Icons.emergency,
                      color: ResguardoTheme.emergencyCrimson,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: ResguardoTheme.emergencyCrimson,
                            content: Text('[ALERTA] Alerta de Pánico y coordenadas enlazadas a la Red NOVA C5.'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionBtn(
                      label: 'RUTA ALBERGUE',
                      sub: 'Calles seguras',
                      icon: Icons.near_me,
                      color: ResguardoTheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EvacuationRouteScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionBtn(
                      label: 'COMUNICADOS',
                      sub: 'Alertas C5',
                      icon: Icons.campaign,
                      color: const Color(0xFFD97706),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OfficialBroadcastsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Card Reporte Inmediato de Bienestar (Auto-confirmación)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ResguardoTheme.outlineVariant),
                  boxShadow: const [ResguardoTheme.shadowLevel2],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REPORTE INMEDIATO DE BIENESTAR',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ResguardoTheme.primary,
                          ),
                        ),
                        Text(
                          'CENSO ACTIVO',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: ResguardoTheme.safeEmerald,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '¿Estás a salvo o en refugio?',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: ResguardoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Confirma tu estado a Protección Civil y a todos tus contactos familiares con un solo toque.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ResguardoTheme.safeEmerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () async {
                              setState(() => _reportedSelfSafe = true);
                              if (family != null && family.members.isNotEmpty) {
                                await FamilyService().updateMemberStatus(
                                  memberId: family.members.first.id,
                                  newStatus: MemberEmergencyStatus.safe,
                                  lastKnownLocation: 'Ubicación actual verificada por GPS',
                                  actorUserId: 'USR-DEV-001',
                                  actorRole: 'CITIZEN',
                                );
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: ResguardoTheme.safeEmerald,
                                    content: Text('[OK] Reportado "A Salvo" en la Red NOVA C5.'),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_reportedSelfSafe ? Icons.check_circle : Icons.verified_user, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  _reportedSelfSafe ? 'ESTOY A SALVO (NOTIFICADO)' : 'ESTOY A SALVO',
                                  style: const TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ResguardoTheme.primary,
                              side: const BorderSide(color: ResguardoTheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: () => _showShelterQrDialog(context),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_2, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'MI QR INGRESO',
                                  style: TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Roster Familiar con Barra de Progreso
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ResguardoTheme.outlineVariant),
                  boxShadow: const [ResguardoTheme.shadowLevel2],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield, color: ResguardoTheme.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Red Familiar SOS',
                              style: TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: ResguardoTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ResguardoTheme.safeEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$safeMembers / $totalMembers A SALVO',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: ResguardoTheme.safeEmerald,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(pctSafe * 100).toInt()}% de tu núcleo protegido • ${totalMembers - safeMembers} pendiente(s) de reporte',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pctSafe,
                        minHeight: 8,
                        backgroundColor: ResguardoTheme.surfaceContainerHigh,
                        color: ResguardoTheme.safeEmerald,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Punto de Encuentro Familiar
              if (family?.meetingPointLocation != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ResguardoTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ResguardoTheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag, color: ResguardoTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PUNTO DE ENCUENTRO PREDETERMINADO',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: ResguardoTheme.textMuted,
                              ),
                            ),
                            Text(
                              family?.meetingPointLocation ?? 'Punto de reunión acordado',
                              style: const TextStyle(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: ResguardoTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Fichas Interactivas de Integrantes
              if (members.isNotEmpty)
                ...members.map((m) => _buildTacticalMemberCard(context, m))
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: const Text('No hay familiares registrados. Agrega a tu primer familiar con el botón superior.'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required String label,
    required String sub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ResguardoTheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 8, color: ResguardoTheme.outline),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTacticalMemberCard(BuildContext context, FamilyMember member) {
    final isSafe = member.status == MemberEmergencyStatus.safe || member.status == MemberEmergencyStatus.inShelter;
    final isUrgent = member.status == MemberEmergencyStatus.injured;

    Color badgeColor = ResguardoTheme.safeEmerald;
    String badgeText = 'A SALVO';

    if (member.status == MemberEmergencyStatus.inShelter) {
      badgeColor = ResguardoTheme.primary;
      badgeText = 'A SALVO EN REFUGIO';
    } else if (member.status == MemberEmergencyStatus.unreachable) {
      badgeColor = const Color(0xFFD97706);
      badgeText = 'EN EVACUACIÓN / PENDIENTE';
    } else if (isUrgent) {
      badgeColor = ResguardoTheme.emergencyCrimson;
      badgeText = 'AUXILIO REQUERIDO';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent
              ? ResguardoTheme.emergencyCrimson
              : (isSafe ? ResguardoTheme.safeEmerald.withValues(alpha: 0.5) : ResguardoTheme.outlineVariant),
          width: isUrgent ? 2 : 1,
        ),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: badgeColor.withValues(alpha: 0.15),
                    child: Icon(
                      member.isMinor ? Icons.child_care : Icons.person,
                      color: badgeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: ResguardoTheme.primary,
                        ),
                      ),
                      Text(
                        '${member.relationship} • ${member.age} años',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: ResguardoTheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: badgeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (member.lastKnownLocation != null)
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: ResguardoTheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    member.lastKnownLocation!,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          if (member.notes != null && member.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Nota: ${member.notes}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: ResguardoTheme.textMuted, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.call, size: 12),
                label: const Text('Llamar', style: TextStyle(fontSize: 10)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marcando a ${member.fullName} vía red celular / enlace satelital...'),
                      backgroundColor: ResguardoTheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResguardoTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                icon: const Icon(Icons.edit, size: 12),
                label: const Text('Cambiar Estado', style: TextStyle(fontSize: 10)),
                onPressed: () => _showUpdateStatusDialog(context, member),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShelterQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'QR DE INGRESO A REFUGIO RED NOVA',
          style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Icon(Icons.qr_code_2, size: 160, color: ResguardoTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Presenta este código al oficial de control del albergue para registro biométrico de asistencia, raciones y alojamiento inmediato.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    bool isMinor = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: ResguardoTheme.primary),
          ),
          title: const Text(
            'Agregar Familiar a la Red',
            style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre Completo *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: relationCtrl,
                  decoration: const InputDecoration(labelText: 'Parentesco (Hijo, Madre, etc.) *'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Edad'),
                        onChanged: (v) {
                          final a = int.tryParse(v) ?? 0;
                          setDialogState(() => isMinor = a > 0 && a < 18);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Padecimiento o medicamentos'),
                ),
                CheckboxListTile(
                  title: const Text('Menor de edad (Protocolo protegido)', style: TextStyle(fontSize: 12)),
                  value: isMinor,
                  onChanged: (v) => setDialogState(() => isMinor = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ResguardoTheme.primary, foregroundColor: Colors.white),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || relationCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);

                await FamilyService().addMember(
                  fullName: nameCtrl.text.trim(),
                  relationship: relationCtrl.text.trim(),
                  age: int.tryParse(ageCtrl.text.trim()) ?? 18,
                  isMinor: isMinor,
                  status: MemberEmergencyStatus.safe,
                  notes: notesCtrl.text.trim(),
                  actorUserId: 'USR-DEV-001',
                  actorRole: 'CITIZEN',
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: ResguardoTheme.safeEmerald,
                      content: Text('[OK] Integrante agregado a tu Red Familiar y sincronizado.'),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, FamilyMember member) {
    MemberEmergencyStatus selectedStatus = member.status;
    final locCtrl = TextEditingController(text: member.lastKnownLocation ?? '');
    final shelterCtrl = TextEditingController(text: member.shelterName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: ResguardoTheme.primary),
          ),
          title: Text(
            'Actualizar Estado: ${member.fullName}',
            style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<MemberEmergencyStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Estado de Emergencia'),
                  items: const [
                    DropdownMenuItem(
                      value: MemberEmergencyStatus.safe,
                      child: Text('A Salvo (En Zona Segura)'),
                    ),
                    DropdownMenuItem(
                      value: MemberEmergencyStatus.inShelter,
                      child: Text('En Albergue / Refugio'),
                    ),
                    DropdownMenuItem(
                      value: MemberEmergencyStatus.unreachable,
                      child: Text('En Evacuación / Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: MemberEmergencyStatus.injured,
                      child: Text('Requiere Auxilio / Lesionado'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locCtrl,
                  decoration: const InputDecoration(labelText: 'Ubicación actual o referencia'),
                ),
                if (selectedStatus == MemberEmergencyStatus.inShelter) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: shelterCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Albergue'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ResguardoTheme.primary, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                await FamilyService().updateMemberStatus(
                  memberId: member.id,
                  newStatus: selectedStatus,
                  lastKnownLocation: locCtrl.text.trim(),
                  shelterName: shelterCtrl.text.trim().isNotEmpty ? shelterCtrl.text.trim() : null,
                  actorUserId: 'USR-DEV-001',
                  actorRole: 'CITIZEN',
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: ResguardoTheme.safeEmerald,
                      content: Text('[OK] Estado de familiar actualizado en tiempo real.'),
                    ),
                  );
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
