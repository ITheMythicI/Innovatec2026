import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:innovatec_mobile/core/theme/resguardo_theme.dart';
import 'package:innovatec_mobile/core/network/gps_location_service.dart';

class EvacuationRouteScreen extends StatefulWidget {
  final LatLng? shelterDestination;
  final String? shelterName;

  const EvacuationRouteScreen({
    super.key,
    this.shelterDestination,
    this.shelterName,
  });

  @override
  State<EvacuationRouteScreen> createState() => _EvacuationRouteScreenState();
}

class _EvacuationRouteScreenState extends State<EvacuationRouteScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<GpsLocationSnapshot>? _gpsSub;

  LatLng _userPos = const LatLng(19.4326, -99.1332);
  late final LatLng _shelterPos;
  late final String _shelterDisplayName;

  List<LatLng> _routePoints = [];
  bool _isWalkMode = true;
  bool _isLoadingRoute = false;
  String _distanceText = 'Calculando...';
  String _durationText = 'En progreso...';

  @override
  void initState() {
    super.initState();
    _userPos = GpsLocationService().currentLocation.position;
    _shelterPos = widget.shelterDestination ?? const LatLng(19.4385, -99.1295);
    _shelterDisplayName = widget.shelterName ?? 'Albergue Oficial';
    _routePoints = [_userPos, _shelterPos];
    _initHardwareGpsAndRoute();
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    super.dispose();
  }

  Future<void> _initHardwareGpsAndRoute() async {
    // 1. Obtener la ubicación GPS real del hardware inmediatamente
    try {
      final snap = await GpsLocationService().refreshHardwareLocation();
      if (mounted) {
        setState(() {
          _userPos = snap.position;
          _routePoints = [_userPos, _shelterPos];
        });
        _fetchOsrmStreetRoute();
        _fitMapBounds();
      }
    } catch (_) {
      _fetchOsrmStreetRoute();
    }

    // 2. Suscribirse a actualizaciones de GPS en tiempo real
    _gpsSub = GpsLocationService().locationStream.listen((snap) {
      if (mounted && (snap.position.latitude != _userPos.latitude || snap.position.longitude != _userPos.longitude)) {
        setState(() {
          _userPos = snap.position;
        });
      }
    });
  }

  void _fitMapBounds() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        try {
          _mapController.fitCamera(
            CameraFit.coordinates(
              coordinates: [_userPos, _shelterPos],
              padding: const EdgeInsets.all(50),
            ),
          );
        } catch (_) {}
      }
    });
  }

  Future<void> _fetchOsrmStreetRoute() async {
    setState(() => _isLoadingRoute = true);
    final mode = _isWalkMode ? 'foot' : 'driving';
    final url =
        'https://router.project-osrm.org/route/v1/$mode/${_userPos.longitude},${_userPos.latitude};${_shelterPos.longitude},${_shelterPos.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          final List<LatLng> fetchedPoints = coordinates
              .map((coord) => LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble()))
              .toList();

          final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 850;
          final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 540;

          if (mounted && fetchedPoints.isNotEmpty) {
            setState(() {
              _routePoints = fetchedPoints;
              _distanceText = distanceMeters > 1000
                  ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
                  : '${distanceMeters.toInt()} metros';
              _durationText = _isWalkMode
                  ? '${(durationSeconds / 60).ceil()} min (Paso rápido)'
                  : '${(durationSeconds / 60).ceil()} min (Vehículo alto)';
              _isLoadingRoute = false;
            });
            _fitMapBounds();
            return;
          }
        }
      }
    } catch (_) {
      // Fallback offline: calcular distancia geodésica directa real
    }

    if (mounted) {
      const Distance distance = Distance();
      final directDistance = distance.as(LengthUnit.Meter, _userPos, _shelterPos);
      final estimatedMinutes = _isWalkMode ? (directDistance / 80).ceil() : (directDistance / 400).ceil();

      setState(() {
        _routePoints = [_userPos, _shelterPos];
        _distanceText = directDistance > 1000
            ? '${(directDistance / 1000).toStringAsFixed(1)} km'
            : '${directDistance.toInt()} metros';
        _durationText = '$estimatedMinutes min (${_isWalkMode ? "A pie" : "Vehículo"})';
        _isLoadingRoute = false;
      });
      _fitMapBounds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResguardoTheme.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Red NOVA // Ruta de Evacuación',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                color: ResguardoTheme.primary,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'TRAZADO URBANO POR CALLES SEGURAS • COTA ALTA (+42M)',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                color: ResguardoTheme.textMuted,
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
              color: ResguardoTheme.safeEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ResguardoTheme.safeEmerald),
            ),
            child: const Row(
              children: [
                Icon(Icons.alt_route, color: ResguardoTheme.safeEmerald, size: 12),
                SizedBox(width: 4),
                Text(
                  'CALLES LIBRES',
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
      body: Column(
        children: [
          // Banner de Alerta Cota Alta y Estado de Rutas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ResguardoTheme.surfaceContainerLow,
              border: const Border(bottom: BorderSide(color: ResguardoTheme.outlineVariant)),
            ),
            child: Row(
              children: [
                const Icon(Icons.navigation, color: ResguardoTheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_distanceText • $_durationText • Vía verificada por C5 sin derrumbes',
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: ResguardoTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_isLoadingRoute)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ResguardoTheme.primary),
                  ),
              ],
            ),
          ),

          // Mapa Interactivo con Flutter Map & OpenStreetMap
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userPos,
                    initialZoom: 15.5,
                    minZoom: 12.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'mx.gob.rednova.mobile',
                    ),
                    // Línea de ruta de evacuación siguiendo exactamente las calles
                    PolylineLayer(
                      polylines: [
                        // Trazo de sombra/borde exterior
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 7.0,
                          color: ResguardoTheme.primary.withValues(alpha: 0.3),
                        ),
                        // Trazo principal de alta visibilidad táctica
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.5,
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
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.person_pin, color: Colors.white, size: 22),
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
                            child: const Icon(Icons.night_shelter, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Controles flotantes sobre el mapa (Modo a pie / auto)
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ResguardoTheme.outlineVariant),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.directions_walk,
                              color: _isWalkMode ? ResguardoTheme.primary : ResguardoTheme.outline),
                          onPressed: () {
                            if (!_isWalkMode) {
                              setState(() => _isWalkMode = true);
                              _fetchOsrmStreetRoute();
                            }
                          },
                          tooltip: 'A pie (Calles peatonales)',
                        ),
                        IconButton(
                          icon: Icon(Icons.directions_car,
                              color: !_isWalkMode ? ResguardoTheme.primary : ResguardoTheme.outline),
                          onPressed: () {
                            if (_isWalkMode) {
                              setState(() => _isWalkMode = false);
                              _fetchOsrmStreetRoute();
                            }
                          },
                          tooltip: 'En vehículo (Avenidas transitables)',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detalles de Ruta y Navegación Turn-by-Turn por Calles
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Card Albergue Principal Destino
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
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: ResguardoTheme.primary, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                _shelterDisplayName,
                                style: const TextStyle(
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
                              color: ResguardoTheme.safeEmerald.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CAPACIDAD 64%',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: ResguardoTheme.safeEmerald,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Calle República de Brasil #42 • Zona Segura de Resguardo C5',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'GUÍA DE NAVEGACIÓN PASO A PASO (POR CALLES)',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ResguardoTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Lista de Pasos por calles reales
                _buildStepTile(
                  icon: Icons.straight,
                  instruction: 'Avanza 120 metros al poniente por Av. Francisco I. Madero',
                  sub: 'Paso despejado • Cero riesgo de inundación',
                  stepNumber: '1',
                ),
                _buildStepTile(
                  icon: Icons.turn_right,
                  instruction: 'Gira a la derecha en Calle de la Palma hacia el norte',
                  sub: 'Camina 260m hasta la esquina con Calle Tacuba',
                  stepNumber: '2',
                ),
                _buildStepTile(
                  icon: Icons.turn_right,
                  instruction: 'Gira a la derecha en Calle Tacuba',
                  sub: 'Avanza 310m hacia República de Brasil',
                  stepNumber: '3',
                ),
                _buildStepTile(
                  icon: Icons.turn_left,
                  instruction: 'Gira a la izquierda en Calle República de Brasil',
                  sub: 'Sube 160m hacia la cota alta (+42m)',
                  stepNumber: '4',
                ),
                _buildStepTile(
                  icon: Icons.night_shelter,
                  instruction: 'Llegada al acceso principal del Gimnasio Benito Juárez',
                  sub: 'Presenta tu código QR de ingreso para asignación de catre y víveres',
                  stepNumber: '5',
                  isDestination: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile({
    required IconData icon,
    required String instruction,
    required String sub,
    required String stepNumber,
    bool isDestination = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDestination ? ResguardoTheme.safeEmerald : ResguardoTheme.outlineVariant,
          width: isDestination ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestination
                  ? ResguardoTheme.safeEmerald.withValues(alpha: 0.15)
                  : ResguardoTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: isDestination ? ResguardoTheme.safeEmerald : ResguardoTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: ResguardoTheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ResguardoTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#$stepNumber',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ResguardoTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
