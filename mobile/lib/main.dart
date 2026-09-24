import 'package:flutter/material.dart';
import 'core/theme/resguardo_theme.dart';
import 'core/security/roles_and_permissions.dart';
import 'database/app_database.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/emergencies/presentation/screens/emergencies_screen.dart';
import 'features/shelters/presentation/screens/shelters_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/people/presentation/screens/missing_persons_screen.dart';
import 'features/families/presentation/screens/family_hub_screen.dart';
import 'features/user_profile/presentation/screens/medical_card_screen.dart';
import 'features/audit/presentation/screens/audit_log_screen.dart';
import 'features/map/presentation/screens/operational_map_screen.dart';
import 'features/broadcasts/presentation/screens/official_broadcasts_screen.dart';
import 'sync/sync_event.dart';
import 'sync/sync_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.initialize();
  runApp(const InnovatecApp());
}

class InnovatecApp extends StatelessWidget {
  const InnovatecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resguardo - Innovatec 2026',
      debugShowCheckedModeBanner: false,
      theme: ResguardoTheme.lightTheme,
      home: const MainNavigationHub(),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().currentUserStream,
      builder: (context, _) {
        final authUser = AuthService().currentUser;
        final currentRole = authUser?.role ?? UserRole.citizen;
        final canViewAudit = RbacService.hasPermission(currentRole, AppPermission.viewAuditLog);

        // Definición de pestañas dinámicas filtradas por RBAC
        // El usuario común (citizen) NO debe ver la pestaña de auditoría.
        final List<_NavigationTabItem> activeTabs = [
          const _NavigationTabItem(
            screen: EmergenciesScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              activeIcon: Icon(Icons.warning),
              label: 'SOS / Pánico',
            ),
          ),
          const _NavigationTabItem(
            screen: OperationalMapScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
          ),
          const _NavigationTabItem(
            screen: OfficialBroadcastsScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Boletines',
            ),
          ),
          const _NavigationTabItem(
            screen: SheltersScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.night_shelter_outlined),
              activeIcon: Icon(Icons.night_shelter),
              label: 'Albergues',
            ),
          ),
          const _NavigationTabItem(
            screen: FamilyHubScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom_outlined),
              activeIcon: Icon(Icons.family_restroom),
              label: 'Mi Familia',
            ),
          ),
          const _NavigationTabItem(
            screen: ReportsScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Reportes',
            ),
          ),
          const _NavigationTabItem(
            screen: MissingPersonsScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.person_search_outlined),
              activeIcon: Icon(Icons.person_search),
              label: 'Personas',
            ),
          ),
          const _NavigationTabItem(
            screen: MedicalCardScreen(),
            item: BottomNavigationBarItem(
              icon: Icon(Icons.medical_information_outlined),
              activeIcon: Icon(Icons.medical_information),
              label: 'Ficha Médica',
            ),
          ),
          if (canViewAudit)
            const _NavigationTabItem(
              screen: AuditLogScreen(),
              item: BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                activeIcon: Icon(Icons.shield),
                label: 'Auditoría',
              ),
            ),
        ];

        // Prevenir desborde de índice si el rol cambia y se reduce la cantidad de tabs
        if (_currentIndex >= activeTabs.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: ResguardoTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador de Conectividad y Cola Offline-First (Design.md)
                    Flexible(
                      child: StreamBuilder<SyncStatus>(
                        stream: SyncManager.instance.syncStatusStream,
                        initialData: SyncStatus.synced,
                        builder: (context, syncSnap) {
                          return StreamBuilder<int>(
                            stream: SyncManager.instance.pendingCountStream,
                            initialData: 0,
                            builder: (context, countSnap) {
                              final pending = countSnap.data ?? 0;
                              final status = syncSnap.data ?? SyncStatus.synced;
                              final isSyncing = status == SyncStatus.syncing;

                              Color statusColor = ResguardoTheme.safeEmerald;
                              String statusText = 'MALLA ACTIVA';

                              if (isSyncing) {
                                statusColor = Colors.lightBlueAccent;
                                statusText = 'SINCRONIZANDO...';
                              } else if (pending > 0) {
                                statusColor = ResguardoTheme.warningAmber;
                                statusText = 'OFFLINE ($pending)';
                              }

                              return GestureDetector(
                                onTap: () {
                                  SyncManager.instance.synchronizePendingEvents();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        statusText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        // Selector Rápido de Rol para Pruebas y Despacho
                        PopupMenuButton<UserRole>(
                          color: ResguardoTheme.surface,
                          tooltip: 'Cambiar Rol de Usuario',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF182942),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.security, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  currentRole.displayName,
                                  style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down, size: 14, color: Colors.white),
                              ],
                            ),
                          ),
                          onSelected: (role) async {
                            await AuthService().switchUserRole(role);
                            setState(() {});
                          },
                          itemBuilder: (ctx) {
                            return UserRole.values.map((r) {
                              return PopupMenuItem(
                                value: r,
                                child: Row(
                                  children: [
                                    Icon(
                                      r == currentRole ? Icons.check_circle : Icons.circle_outlined,
                                      size: 16,
                                      color: r == currentRole ? ResguardoTheme.primary : ResguardoTheme.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      r.displayName,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: r == currentRole ? ResguardoTheme.primary : ResguardoTheme.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: r == currentRole ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                        ),

                        const SizedBox(width: 8),

                        // Botón de Acceso / Login / Registro
                        IconButton(
                          icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 20),
                          tooltip: 'Iniciar Sesión / Registro Táctico',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AuthScreen(
                                  onAuthSuccess: () => setState(() {}),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: activeTabs[_currentIndex].screen,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ResguardoTheme.outline, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: ResguardoTheme.surface,
              selectedItemColor: ResguardoTheme.primary,
              unselectedItemColor: ResguardoTheme.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Inter'),
              items: activeTabs.map((t) => t.item).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationTabItem {
  final Widget screen;
  final BottomNavigationBarItem item;

  const _NavigationTabItem({
    required this.screen,
    required this.item,
  });
}
