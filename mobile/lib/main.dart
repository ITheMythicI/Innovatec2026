import 'package:flutter/material.dart';
import 'core/theme/resguardo_theme.dart';
import 'core/security/roles_and_permissions.dart';
import 'database/app_database.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/emergencies/presentation/screens/emergencies_screen.dart';
import 'features/shelters/presentation/screens/shelters_screen.dart';
import 'features/map/presentation/screens/operational_map_screen.dart';
import 'features/broadcasts/presentation/screens/official_broadcasts_screen.dart';
import 'features/hub/presentation/screens/tactical_hub_screen.dart';
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

  final List<Widget> _screens = const [
    EmergenciesScreen(),
    OperationalMapScreen(),
    OfficialBroadcastsScreen(),
    SheltersScreen(),
    TacticalHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().currentUserStream,
      builder: (context, _) {
        final authUser = AuthService().currentUser;
        final currentRole = authUser?.role ?? UserRole.citizen;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: ResguardoTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador de Conectividad / Malla Offline
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

                              return InkWell(
                                onTap: () => SyncManager.instance.synchronizePendingEvents(),
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
                                    const SizedBox(width: 6),
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

                    const SizedBox(width: 8),

                    // Selector Rápido de Rol y Botón de Usuario
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<UserRole>(
                          color: ResguardoTheme.surface,
                          tooltip: 'Cambiar Rol Táctico',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF182942),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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

                        const SizedBox(width: 6),

                        IconButton(
                          icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 20),
                          tooltip: 'Iniciar Sesión / Registro',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: ResguardoTheme.outline, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: ResguardoTheme.surface,
              selectedItemColor: ResguardoTheme.emergencyCrimson,
              unselectedItemColor: ResguardoTheme.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.warning_amber_rounded),
                  activeIcon: Icon(Icons.warning, color: ResguardoTheme.emergencyCrimson),
                  label: 'SOS / Pánico',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.campaign_outlined),
                  activeIcon: Icon(Icons.campaign),
                  label: 'Boletines',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.night_shelter_outlined),
                  activeIcon: Icon(Icons.night_shelter),
                  label: 'Albergues',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  activeIcon: Icon(Icons.grid_view_rounded),
                  label: 'Módulos',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
