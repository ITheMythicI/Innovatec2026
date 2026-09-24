import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';

class EvacuationRouteScreen extends StatefulWidget {
  const EvacuationRouteScreen({super.key});

  @override
  State<EvacuationRouteScreen> createState() => _EvacuationRouteScreenState();
}

class _EvacuationRouteScreenState extends State<EvacuationRouteScreen> {
  final MapController _mapController = MapController();

  // Coordenadas tácticas (San Jerónimo / Gimnasio Benito Juárez)
  static const LatLng _userPos = LatLng(19.4326, -99.1332);
  static const LatLng _waypoint1 = LatLng(19.4340, -99.1320);
  static const LatLng _waypoint2 = LatLng(19.4365, -99.1305);
  static const LatLng _shelterPos = LatLng(19.4380, -99.1290);

  bool _isWalkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResguardoTheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RUTA SEGURA // ALBERGUE',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'COTA ALTA (+42M) • GIMNASIO BENITO JUÁREZ',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              children: [
                Icon(Icons.offline_pin, color: ResguardoTheme.safeEmerald, size: 12),
                SizedBox(width: 4),
                Text(
                  'MAPA OFFLINE (94 KB)',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de Alerta Cota Alta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0F264A),
            child: const Row(
              children: [
                Icon(Icons.trending_up, color: ResguardoTheme.safeEmerald, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '+42m Elevación Segura • Camino verificado por Protección Civil hace 4 min',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mapa Interactivo con Flutter Map & OpenStreetMap
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(19.4350, -99.1310),
                    initialZoom: 15.0,
                    minZoom: 11.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'mx.gob.resguardo.mobile',
                    ),
                    // Línea de ruta de evacuación hacia cota alta
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [_userPos, _waypoint1, _waypoint2, _shelterPos],
                          strokeWidth: 5.0,
                          color: ResguardoTheme.safeEmerald,
                        ),
                      ],
                    ),
                    // Marcadores tácticos
                    MarkerLayer(
                      markers: [
                        // Marcador Usuario
                        Marker(
                          point: _userPos,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.emergencyCrimson,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.person_pin, color: Colors.white, size: 24),
                          ),
                        ),
                        // Marcador Refugio Benito Juárez
                        Marker(
                          point: _shelterPos,
                          width: 48,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: ResguardoTheme.safeEmerald, width: 3),
                              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                            ),
                            child: const Icon(Icons.night_shelter, color: Colors.white, size: 26),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Controles flotantes sobre el mapa
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ResguardoTheme.emergencyCrimson,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'ZONA INUNDADA (+1.4M)',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.directions_walk,
                              color: _isWalkMode ? ResguardoTheme.primary : ResguardoTheme.outline),
                          onPressed: () => setState(() => _isWalkMode = true),
                          tooltip: 'A pie (Paso rápido)',
                        ),
                        IconButton(
                          icon: Icon(Icons.directions_car,
                              color: !_isWalkMode ? ResguardoTheme.primary : ResguardoTheme.outline),
                          onPressed: () => setState(() => _isWalkMode = false),
                          tooltip: 'En vehículo alto',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detalles de Ruta y Turn-by-Turn
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Albergue Principal Oficial
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
                                Icon(Icons.apartment, color: ResguardoTheme.primary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Gimnasio Benito Juárez',
                                  style: TextStyle(
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                              child: const Text(
                                'CAPACIDAD: 64%',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  color: ResguardoTheme.safeEmerald,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Av. Universidad #402, Col. San Jerónimo (Cota Alta: 2,240 msnm)',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
                        ),
                        const SizedBox(height: 12),

                        // Métricas clave (Distancia, Tiempo, Condición)
                        Row(
                          children: [
                            _buildMetricBox('Distancia', '650 m', 'Cuesta arriba', Icons.straighten),
                            const SizedBox(width: 8),
                            _buildMetricBox('Tiempo Estimado', '8 - 10 min', 'Paso rápido', Icons.timer),
                            const SizedBox(width: 8),
                            _buildMetricBox('Condición', 'SECA', 'Sin obstáculos', Icons.check_circle_outline),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Servicios Activos
                        const Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _ServiceBadge(label: 'Médico 24/7', icon: Icons.medical_services),
                            _ServiceBadge(label: 'Agua Potable & Raciones', icon: Icons.water_drop),
                            _ServiceBadge(label: 'Planta Eléctrica', icon: Icons.bolt),
                            _ServiceBadge(label: 'Comedor Caliente', icon: Icons.restaurant),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Paso Turn-by-Turn Guía de Evacuación
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.turn_slight_right, color: Color(0xFFD97706), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PASO 1 DE 3 • EN 80 METROS',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Gira a la derecha en Callejón Las Lajas hacia la Loma.',
                                style: TextStyle(
                                  fontFamily: 'Space Grotesk',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: ResguardoTheme.primary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Evita cruzar la Calzada del Río que presenta encharcamiento moderado.',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF78350F)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón Emergencia: Bloqueado en Ruta
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ResguardoTheme.emergencyCrimson,
                      side: const BorderSide(color: ResguardoTheme.emergencyCrimson),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('🚨 BRIGADA DE DESPACHO SOS'),
                          content: const Text(
                            '¿Quedaste bloqueado por el agua o escombros?\nSe enviará tu posición exacta (19.4326° N, 99.1332° W) a las unidades Unimog del Plan DN-III-E.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: ResguardoTheme.emergencyCrimson),
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: ResguardoTheme.emergencyCrimson,
                                    content: Text('Unidad de rescate notificada con tus coordenadas.'),
                                  ),
                                );
                              },
                              child: const Text('CONFIRMAR DESPACHO', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.emergency, size: 18),
                    label: const Text(
                      '¿QUEDASTE BLOQUEADO EN RUTA? DESPACHO SOS',
                      style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Albergues de Respaldo Cercanos
                  const Text(
                    'ALBERGUES DE RESPALDO ALTERNOS',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ResguardoTheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildBackupShelter(
                    name: 'Escuela Primaria Morelos',
                    distance: '1.1 km • Cota Media-Alta',
                    occupancy: 'Capacidad: 42%',
                  ),
                  const SizedBox(height: 6),
                  _buildBackupShelter(
                    name: 'Centro Parroquial Guadalupe',
                    distance: '1.4 km • Cota Alta',
                    occupancy: 'Capacidad: 25%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String label, String value, String sub, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: ResguardoTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ResguardoTheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: ResguardoTheme.outline),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: ResguardoTheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              sub,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: ResguardoTheme.safeEmerald),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupShelter({required String name, required String distance, required String occupancy}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ResguardoTheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                '$distance • $occupancy',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: ResguardoTheme.textMuted),
              ),
            ],
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {},
            child: const Text('Ver Ruta', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ServiceBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: ResguardoTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: ResguardoTheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ResguardoTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ResguardoTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
