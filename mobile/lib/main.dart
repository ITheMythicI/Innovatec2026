import 'package:flutter/material.dart';
import 'core/security/roles_and_permissions.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/people/presentation/screens/missing_persons_screen.dart';
import 'features/families/presentation/screens/family_hub_screen.dart';
import 'features/user_profile/presentation/screens/medical_card_screen.dart';
import 'features/audit/presentation/screens/audit_log_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InnovatecApp());
}

class InnovatecApp extends StatelessWidget {
  const InnovatecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innovatec 2026 - Respuesta ante Desastres',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF10141A),
        primaryColor: Colors.redAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.tealAccent,
          surface: Color(0xFF181E27),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF151A22),
          elevation: 0,
        ),
      ),
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
    MissingPersonsScreen(),
    FamilyHubScreen(),
    MedicalCardScreen(),
    AuditLogScreen(),
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
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: const Color(0xFF0D1117),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador de Conectividad Offline-First
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'OFFLINE-FIRST (Malla Activa)',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    // Selector Rápido de Rol para Pruebas y Despacho
                    PopupMenuButton<UserRole>(
                      color: const Color(0xFF1E2632),
                      tooltip: 'Cambiar Rol de Usuario',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222C3A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.security, size: 12, color: Colors.tealAccent),
                            const SizedBox(width: 4),
                            Text(
                              'Rol: ${currentRole.displayName}',
                              style: const TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 14, color: Colors.tealAccent),
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
                                  color: r == currentRole ? Colors.tealAccent : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  r.displayName,
                                  style: TextStyle(
                                    color: r == currentRole ? Colors.tealAccent : Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF222A36), width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: const Color(0xFF13171F),
              selectedItemColor: Colors.tealAccent,
              unselectedItemColor: Colors.grey.shade600,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_search_outlined),
                  activeIcon: Icon(Icons.person_search),
                  label: 'Personas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.family_restroom_outlined),
                  activeIcon: Icon(Icons.family_restroom),
                  label: 'Mi Familia',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.medical_information_outlined),
                  activeIcon: Icon(Icons.medical_information),
                  label: 'Ficha Médica',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shield_outlined),
                  activeIcon: Icon(Icons.shield),
                  label: 'Auditoría',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
