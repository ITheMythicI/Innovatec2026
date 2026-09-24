import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
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
    final userName = currentUser?.fullName ?? 'Carlos Mendoza';
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
                  'RESGUARDO // RED CIVIL',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.w700,
                    color: ResguardoTheme.primary,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'GNSS/C5 ACTIVO • CENSO FAMILIAR',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: ResguardoTheme.outline,
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
                  'RED MALLA C5',
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
          final totalMembers = family?.members.length ?? 4;
          final safeMembers = family?.safeCount ?? 3;
          final pctSafe = totalMembers > 0 ? (safeMembers / totalMembers) : 0.75;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Barra de Usuario Táctico
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: ResguardoTheme.primary,
                  borderRadius: BorderRadius.circular(6),
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
                          const Text(
                            'ENLACE SATELITAL • ZONA SEGURA (COTA ALTA)',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                      tooltip: 'Agregar Familiar',
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
                      sub: 'Activar auxilio',
                      icon: Icons.emergency,
                      color: ResguardoTheme.emergencyCrimson,
                      onTap: () {
                        // Navegar o hacer trigger
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: ResguardoTheme.emergencyCrimson,
                            content: Text('Alerta de Pánico enlazada al C5'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionBtn(
                      label: 'RUTA ALBERGUE',
                      sub: 'Turn-by-turn',
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
                      sub: 'Noticias oficiales',
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

              // Card Reporte Inmediato de Bienestar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ResguardoTheme.outlineVariant),
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
                      '¿Llegaste a salvo o estás en refugio?',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: ResguardoTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Confirma tu bienestar a Protección Civil y a tus contactos con un toque instantáneo.',
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () {
                              setState(() => _reportedSelfSafe = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: ResguardoTheme.safeEmerald,
                                  content: Text('✅ Reportado a salvo ante C5 y tu red familiar.'),
                                ),
                              );
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ResguardoTheme.outlineVariant),
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
                              'Red Familiar de Apoyo SOS',
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
                      '${(pctSafe * 100).toInt()}% de la red protegida • ${totalMembers - safeMembers} pendiente(s) de reporte',
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

              // Fichas de Familiares
              if (family != null && family.members.isNotEmpty)
                ...family.members.map((m) => _buildTacticalMemberCard(context, m))
              else
                ..._buildDemoMembers(context),
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
      badgeText = 'EN EVACUACIÓN';
    } else if (isUrgent) {
      badgeColor = ResguardoTheme.emergencyCrimson;
      badgeText = 'AUXILIO REQUERIDO';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isUrgent
              ? ResguardoTheme.emergencyCrimson
              : (isSafe ? ResguardoTheme.safeEmerald.withValues(alpha: 0.5) : ResguardoTheme.outlineVariant),
          width: isUrgent ? 2 : 1,
        ),
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
                        member.relationship,
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
                    SnackBar(content: Text('Llamando a ${member.fullName}...')),
                  );
                },
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.update, size: 12),
                label: const Text('Actualizar Estado', style: TextStyle(fontSize: 10)),
                onPressed: () => _showUpdateStatusDialog(context, member),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDemoMembers(BuildContext context) {
    return [
      _buildStaticCard(
        name: 'Carmen Domínguez',
        relation: 'Mamá',
        status: 'A SALVO EN REFUGIO',
        statusColor: ResguardoTheme.primary,
        location: 'Gimnasio Municipal Benito Juárez • Cama/Zona B-14',
        sub: 'Validado PC (hace 12m)',
        icon: Icons.elderly,
      ),
      _buildStaticCard(
        name: 'Alejandro Morales',
        relation: 'Hermano',
        status: 'EN EVACUACIÓN',
        statusColor: const Color(0xFFD97706),
        location: 'En ruta a: Refugio Cota Alta Escuela Morelos',
        sub: 'Batería 42% • GPS ping hace 3m',
        icon: Icons.person,
      ),
      _buildStaticCard(
        name: 'Sofía Morales',
        relation: 'Hija (11 años)',
        status: 'A SALVO',
        statusColor: ResguardoTheme.safeEmerald,
        location: 'Escuela Primaria Morelos (Punto Seguro)',
        sub: 'Acompañada de docente responsable',
        icon: Icons.child_care,
      ),
      _buildStaticCard(
        name: 'Roberto Gómez',
        relation: 'Tío',
        status: 'PENDIENTE DE REPORTE',
        statusColor: ResguardoTheme.emergencyCrimson,
        location: 'Sector Norte (Zona Baja Inundada)',
        sub: 'Último contacto hace 45m',
        icon: Icons.warning_amber_rounded,
      ),
    ];
  }

  Widget _buildStaticCard({
    required String name,
    required String relation,
    required String status,
    required Color statusColor,
    required String location,
    required String sub,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ResguardoTheme.outlineVariant),
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
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    child: Icon(icon, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: ResguardoTheme.primary,
                        ),
                      ),
                      Text(
                        relation,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: ResguardoTheme.outline),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: ResguardoTheme.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, color: ResguardoTheme.outline),
          ),
        ],
      ),
    );
  }

  void _showShelterQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CÓDIGO QR DE INGRESO A REFUGIO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Icon(Icons.qr_code_2, size: 160, color: ResguardoTheme.primary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Presenta este código al personal de recepción en el Gimnasio Benito Juárez para asignación automática de cama y registro de raciones.',
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
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final phoneController = TextEditingController();
    bool isMinor = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Integrante a la Red SOS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              TextField(
                controller: relationController,
                decoration: const InputDecoration(labelText: 'Parentesco (Mamá, Hijo, etc.)'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono Móvil (Opcional)'),
                keyboardType: TextInputType.phone,
              ),
              CheckboxListTile(
                title: const Text('Es menor de edad (Protocolo Amber)'),
                value: isMinor,
                onChanged: (v) => setDialogState(() => isMinor = v ?? false),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ResguardoTheme.primary),
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final user = AuthService().currentUser;
                  await FamilyService().addMember(
                    fullName: nameController.text.trim(),
                    relationship: relationController.text.trim().isEmpty ? 'Familiar' : relationController.text.trim(),
                    age: isMinor ? 10 : 35,
                    isMinor: isMinor,
                    status: MemberEmergencyStatus.safe,
                    notes: phoneController.text.trim().isEmpty ? null : 'Tel: ${phoneController.text.trim()}',
                    actorUserId: user?.id ?? 'USR-DEV-001',
                    actorRole: user?.role.code ?? 'CITIZEN',
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Estado de ${member.fullName}'),
        children: MemberEmergencyStatus.values.map((status) {
          return SimpleDialogOption(
            onPressed: () async {
              final user = AuthService().currentUser;
              await FamilyService().updateMemberStatus(
                memberId: member.id,
                newStatus: status,
                shelterName: status == MemberEmergencyStatus.inShelter ? 'Gimnasio Benito Juárez' : null,
                actorUserId: user?.id ?? 'USR-DEV-001',
                actorRole: user?.role.code ?? 'CITIZEN',
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Text(status.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(status.displayName),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
