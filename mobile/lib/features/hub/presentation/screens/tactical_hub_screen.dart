import 'package:flutter/material.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/security/roles_and_permissions.dart';
import 'package:innovatec_mobile/features/auth/domain/services/auth_service.dart';
import 'package:innovatec_mobile/features/families/presentation/screens/family_hub_screen.dart';
import 'package:innovatec_mobile/features/reports/presentation/screens/reports_screen.dart';
import 'package:innovatec_mobile/features/people/presentation/screens/missing_persons_screen.dart';
import 'package:innovatec_mobile/features/user_profile/presentation/screens/medical_card_screen.dart';
import 'package:innovatec_mobile/features/audit/presentation/screens/audit_log_screen.dart';
import 'package:innovatec_mobile/sync/sync_manager.dart';

class TacticalHubScreen extends StatelessWidget {
  const TacticalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = AuthService().currentUser;
    final currentRole = authUser?.role ?? UserRole.citizen;
    final canViewAudit = RbacService.hasPermission(currentRole, AppPermission.viewAuditLog);

    return Scaffold(
      backgroundColor: ResguardoTheme.background,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Centro de Operaciones Táctico',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 18,
              ),
            ),
            Text(
              'MÓDULOS DE GESTIÓN Y APOYO CIUDADANO',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: ResguardoTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de Enlace / Batería / GPS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ResguardoTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ResguardoTheme.outline),
                boxShadow: const [ResguardoTheme.shadowLevel2],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ResguardoTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub, color: ResguardoTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ResguardoTheme.safeEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ENLACE MALLA ACTIVO',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ResguardoTheme.safeEmerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Usuario: ${authUser?.fullName ?? "Ciudadano Registrado"}',
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ResguardoTheme.primary,
                          ),
                        ),
                        Text(
                          'Rol Táctico: ${currentRole.displayName} • Cifrado Local OK',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: ResguardoTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'HERRAMIENTAS Y MÓDULOS ACTIVOS',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ResguardoTheme.textMuted,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            // Grid de Módulos
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: [
                _buildModuleCard(
                  context,
                  title: 'Mi Red Familiar',
                  subtitle: 'Reunificación y estado',
                  icon: Icons.family_restroom,
                  iconColor: const Color(0xFF2563EB),
                  badge: 'Censo OK',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyHubScreen()),
                  ),
                ),
                _buildModuleCard(
                  context,
                  title: 'Reportes Ciudadanos',
                  subtitle: 'Incidencias e infraestructura',
                  icon: Icons.assignment_late_outlined,
                  iconColor: ResguardoTheme.warningAmber,
                  badge: 'Geo-reporte',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  ),
                ),
                _buildModuleCard(
                  context,
                  title: 'Personas Extraviadas',
                  subtitle: 'Búsqueda y reconocimiento',
                  icon: Icons.person_search,
                  iconColor: const Color(0xFF7C3AED),
                  badge: 'Filtro IA',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MissingPersonsScreen()),
                  ),
                ),
                _buildModuleCard(
                  context,
                  title: 'Ficha Médica SOS',
                  subtitle: 'Alergias, sangre y contactos',
                  icon: Icons.medical_services_outlined,
                  iconColor: ResguardoTheme.emergencyCrimson,
                  badge: 'Offline QR',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicalCardScreen()),
                  ),
                ),
                if (canViewAudit)
                  _buildModuleCard(
                    context,
                    title: 'Auditoría C5',
                    subtitle: 'Registro de firmas y pings',
                    icon: Icons.shield_outlined,
                    iconColor: ResguardoTheme.primary,
                    badge: 'Mando',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuditLogScreen()),
                    ),
                  ),
                _buildModuleCard(
                  context,
                  title: 'Forzar Sincronización',
                  subtitle: 'Subir eventos en cola',
                  icon: Icons.sync,
                  iconColor: ResguardoTheme.safeEmerald,
                  badge: 'Malla LoRa',
                  onTap: () {
                    SyncManager.instance.synchronizePendingEvents();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔄 Sincronizando eventos y telemetría con el servidor central...'),
                        backgroundColor: ResguardoTheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ResguardoTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ResguardoTheme.outline),
          boxShadow: const [ResguardoTheme.shadowLevel2],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ResguardoTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: ResguardoTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: ResguardoTheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: ResguardoTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
