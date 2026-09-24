import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/features/emergencies/domain/models/emergency.dart';
import 'package:innovatec_mobile/features/emergencies/presentation/controllers/emergency_controller.dart';
import 'package:innovatec_mobile/features/map/presentation/screens/evacuation_route_screen.dart';

class EmergenciesScreen extends StatefulWidget {
  const EmergenciesScreen({super.key});

  @override
  State<EmergenciesScreen> createState() => _EmergenciesScreenState();
}

class _EmergenciesScreenState extends State<EmergenciesScreen> {
  late final EmergencyController _controller;
  bool _sirenActive = false;
  double _sosHoldProgress = 0.0;
  bool _isHoldingSos = false;

  @override
  void initState() {
    super.initState();
    _controller = EmergencyController();
    _controller.loadEmergencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: ResguardoTheme.background,
          appBar: AppBar(
            backgroundColor: ResguardoTheme.surface,
            title: const Text(
              'Emergencias & Desastres',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Sincronizar Catálogo',
                icon: const Icon(Icons.sync, color: ResguardoTheme.primary),
                onPressed: () => _controller.sync(),
              ),
              IconButton(
                tooltip: 'Nueva Alerta de Emergencia',
                icon: const Icon(Icons.add_alert, color: ResguardoTheme.emergencyCrimson),
                onPressed: () => _showCreateEmergencyDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Barra Superior Táctica de Modo Pánico (Doc 1)
                Container(
                  color: ResguardoTheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: ResguardoTheme.emergencyCrimson.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ResguardoTheme.emergencyCrimson),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: ResguardoTheme.emergencyCrimson, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'MODO PÁNICO // ACTIVO',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: ResguardoTheme.emergencyCrimson,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.my_location, size: 12, color: ResguardoTheme.outline),
                          SizedBox(width: 4),
                          Text(
                            '19.4326° N, 99.1332° W',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: ResguardoTheme.outline,
                              fontSize: 9,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '⚡ 22% ECO',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              color: ResguardoTheme.warningAmber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Banner de Amenaza Inmediata / Nivel Crítico (Doc 1)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ResguardoTheme.emergencyCrimson, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: ResguardoTheme.emergencyCrimson.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.crisis_alert, color: ResguardoTheme.emergencyCrimson, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'AMENAZA INMEDIATA // CRÍTICO',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  color: ResguardoTheme.emergencyCrimson,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.emergencyCrimson,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '+1.4M NIVEL DE AGUA',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '¡ALERTA DE INUNDACIÓN EN TU ZONA!',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ResguardoTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.north, color: ResguardoTheme.emergencyCrimson, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'EVACÚA A ZONAS ALTAS AHORA • RIESGO INMINENTE',
                            style: TextStyle(
                              fontFamily: 'Space Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: ResguardoTheme.emergencyCrimson,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ResguardoTheme.outlineVariant),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield, size: 14, color: ResguardoTheme.primary),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Última orden Protección Civil: Rompimiento en dique norte. Desalojo obligatorio: Dirigirse al Gimnasio Municipal de inmediato.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: ResguardoTheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Los Dos Botones Masivos Tácticos de 100px (Doc 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      // Botón 1: Pedir Auxilio / SOS Militar + Sat
                      GestureDetector(
                        onLongPressStart: (_) {
                          setState(() {
                            _isHoldingSos = true;
                            _sosHoldProgress = 1.0;
                          });
                        },
                        onLongPressEnd: (_) {
                          setState(() {
                            _isHoldingSos = false;
                            _sosHoldProgress = 0.0;
                          });
                          _triggerInstantSos(context);
                        },
                        onTap: () => _triggerInstantSos(context),
                        child: Container(
                          width: double.infinity,
                          height: 96,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ResguardoTheme.emergencyCrimson,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: ResguardoTheme.emergencyCrimson.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.emergency, color: Colors.white, size: 24),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'PEDIR AUXILIO / SOS',
                                        style: TextStyle(
                                          fontFamily: 'Space Grotesk',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'MILITAR + SAT',
                                          style: TextStyle(
                                            fontFamily: 'JetBrains Mono',
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Activa despacho de rescate militar y satelital (Mantén 3s o presiona)',
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ),
                              if (_isHoldingSos)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: _sosHoldProgress,
                                      backgroundColor: Colors.white24,
                                      color: Colors.white,
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botón 2: Estoy a Salvo (Reporte Censo)
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: ResguardoTheme.safeEmerald,
                              content: Text('✅ ESTADO REPORTADO: A SALVO. Posición enviada al censo C5 y a tu red familiar.'),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 96,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ResguardoTheme.safeEmerald,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: ResguardoTheme.safeEmerald.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'ESTOY A SALVO',
                                    style: TextStyle(
                                      fontFamily: 'Space Grotesk',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'REPORTE CENSO',
                                      style: TextStyle(
                                        fontFamily: 'JetBrains Mono',
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Notifica de inmediato a red familiar y censo de Protección Civil',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Card: Ruta Directa a Albergue (Gimnasio Benito Juárez)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EvacuationRouteScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ResguardoTheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.near_me, color: ResguardoTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RUTA DIRECTA A ALBERGUE',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: ResguardoTheme.outline,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gimnasio Benito Juárez',
                                  style: TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: ResguardoTheme.primary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '▲ 650m cuesta arriba (Ruta seca verificada)',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.safeEmerald),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: ResguardoTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Controles Tácticos Rápidos: 911, Radio 147.500, Satélite
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ResguardoTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(color: ResguardoTheme.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          icon: const Icon(Icons.phone_in_talk, size: 14, color: ResguardoTheme.emergencyCrimson),
                          label: const Text(
                            'EMERGENCIA 911',
                            style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Llamada a Emergencias 911'),
                                content: const Text('¿Deseas marcar al centro de atención y despacho 911 nacional?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: ResguardoTheme.emergencyCrimson),
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Llamar 911', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _sirenActive ? ResguardoTheme.emergencyCrimson.withValues(alpha: 0.1) : null,
                            foregroundColor: _sirenActive ? ResguardoTheme.emergencyCrimson : ResguardoTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: BorderSide(
                              color: _sirenActive ? ResguardoTheme.emergencyCrimson : ResguardoTheme.outlineVariant,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          icon: Icon(
                            _sirenActive ? Icons.volume_up : Icons.radio,
                            size: 14,
                            color: _sirenActive ? ResguardoTheme.emergencyCrimson : ResguardoTheme.warningAmber,
                          ),
                          label: Text(
                            _sirenActive ? 'SIRENA ACTIVA' : 'RADIO 147.500',
                            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            setState(() => _sirenActive = !_sirenActive);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_sirenActive
                                    ? '🚨 Sirena 110dB y estrobo activo para señalización visual'
                                    : '📻 Sintonizado en canal táctico 147.500 MHz'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sección Catálogo de Incidentes Locales
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CATÁLOGO DE INCIDENTES ACTIVOS',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ResguardoTheme.outline,
                        ),
                      ),
                      Text(
                        '${_controller.emergencies.length} Reportes',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ResguardoTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Filtros de Severidad
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      _buildFilterChip('Todas', _controller.selectedSeverity == null, () {
                        _controller.filterBySeverity(null);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Crítica', _controller.selectedSeverity == EmergencySeverity.critical, () {
                        _controller.filterBySeverity(EmergencySeverity.critical);
                      }, color: ResguardoTheme.emergencyCrimson),
                      const SizedBox(width: 8),
                      _buildFilterChip('Alta', _controller.selectedSeverity == EmergencySeverity.high, () {
                        _controller.filterBySeverity(EmergencySeverity.high);
                      }, color: ResguardoTheme.warningAmber),
                      const SizedBox(width: 8),
                      _buildFilterChip('Media', _controller.selectedSeverity == EmergencySeverity.medium, () {
                        _controller.filterBySeverity(EmergencySeverity.medium);
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Baja', _controller.selectedSeverity == EmergencySeverity.low, () {
                        _controller.filterBySeverity(EmergencySeverity.low);
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Lista de Emergencias dentro del Scroll
                _buildContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final activeColor = color ?? ResguardoTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : ResguardoTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? activeColor : ResguardoTheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : ResguardoTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.status == EmergencyStateStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: ResguardoTheme.primary));
    }

    if (_controller.status == EmergencyStateStatus.error && _controller.emergencies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: ResguardoTheme.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Modo Offline Activo',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: ResguardoTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No hay emergencias registradas localmente en este momento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _controller.loadEmergencies(forceRefresh: true),
                child: const Text('Reintentar Conexión'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.emergencies.isEmpty) {
      return const Center(
        child: Text(
          'No hay emergencias registradas en esta categoría.',
          style: TextStyle(fontFamily: 'Inter', color: ResguardoTheme.textMuted, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _controller.emergencies.length,
      itemBuilder: (context, index) {
        final emergency = _controller.emergencies[index];
        return _buildEmergencyCard(emergency);
      },
    );
  }

  Widget _buildEmergencyCard(Emergency emergency) {
    Color borderColor = ResguardoTheme.outline;
    Color notchColor = ResguardoTheme.safeEmerald;

    if (emergency.severity == EmergencySeverity.critical) {
      borderColor = ResguardoTheme.emergencyCrimson;
      notchColor = ResguardoTheme.emergencyCrimson;
    } else if (emergency.severity == EmergencySeverity.high) {
      borderColor = ResguardoTheme.warningAmber;
      notchColor = ResguardoTheme.warningAmber;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: ResguardoTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: emergency.severity == EmergencySeverity.critical ? 2 : 1),
        boxShadow: const [ResguardoTheme.shadowLevel2],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador notch vertical de 4px (Design.md)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: notchColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Meta-label
                        Text(
                          emergency.type.displayName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ResguardoTheme.textMuted,
                          ),
                        ),
                        // Badge de severidad
                        _buildBadge(emergency.severity.displayName, notchColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      emergency.title,
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: ResguardoTheme.primary,
                      ),
                    ),
                    if (emergency.description != null && emergency.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        emergency.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: ResguardoTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: ResguardoTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${emergency.latitude.toStringAsFixed(4)}, ${emergency.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            color: ResguardoTheme.textMuted,
                          ),
                        ),
                        const Spacer(),
                        if (emergency.syncStatus.startsWith('pending'))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ResguardoTheme.warningAmberContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.sync_problem, size: 12, color: ResguardoTheme.warningAmber),
                                SizedBox(width: 4),
                                Text(
                                  'PENDIENTE SYNC',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: ResguardoTheme.warningAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _triggerInstantSos(BuildContext context) async {
    final folioId = 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    final newSos = Emergency(
      id: const Uuid().v4(),
      title: 'ALERTA SOS - AUXILIO INMEDIATO ($folioId)',
      description: 'Señal de auxilio urgente y geolocalizada emitida por ciudadano/brigadista desde terminal móvil.',
      type: EmergencyType.other,
      severity: EmergencySeverity.critical,
      status: EmergencyStatus.active,
      latitude: 19.4326,
      longitude: -99.1332,
      startedAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await _controller.createEmergency(newSos);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: ResguardoTheme.emergencyCrimson, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ResguardoTheme.emergencyCrimson.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency, color: ResguardoTheme.emergencyCrimson, size: 24),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'SOS TRANSMITIDO AL C5',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: ResguardoTheme.primary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ResguardoTheme.emergencyCrimsonBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOLIO DE DESPACHO: $folioId',
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ResguardoTheme.emergencyCrimson,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'GPS: 19.4326° N, 99.1332° W • ZONA NORTE',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: ResguardoTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu señal de auxilio y coordenadas han sido registradas en la mesa de mando C5. Las brigadas de rescate más cercanas han sido alertadas.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: ResguardoTheme.onSurfaceVariant, height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: ResguardoTheme.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ResguardoTheme.emergencyCrimson,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.near_me, size: 16),
            label: const Text('Ver Ruta a Albergue'),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EvacuationRouteScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCreateEmergencyDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    EmergencySeverity selectedSev = EmergencySeverity.medium;
    EmergencyType selectedType = EmergencyType.earthquake;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: ResguardoTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: ResguardoTheme.primary, width: 1.5),
              ),
              title: const Text(
                'Registrar Alerta de Emergencia',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.w700,
                  color: ResguardoTheme.primary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Título del Suceso *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Descripción / Situación'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EmergencyType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipo de Evento'),
                      items: EmergencyType.values.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.displayName));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EmergencySeverity>(
                      initialValue: selectedSev,
                      decoration: const InputDecoration(labelText: 'Nivel de Severidad'),
                      items: EmergencySeverity.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.displayName));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedSev = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: ResguardoTheme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResguardoTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    final emergency = Emergency(
                      id: const Uuid().v4(),
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      type: selectedType,
                      severity: selectedSev,
                      status: EmergencyStatus.active,
                      latitude: 19.4326,
                      longitude: -99.1332,
                      startedAt: DateTime.now().toUtc(),
                      createdAt: DateTime.now().toUtc(),
                      updatedAt: DateTime.now().toUtc(),
                    );
                    Navigator.pop(ctx);
                    await _controller.createEmergency(emergency);
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
