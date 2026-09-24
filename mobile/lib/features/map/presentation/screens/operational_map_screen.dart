import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/gps_location_service.dart';
import '../../../../core/theme/resguardo_theme.dart';
import '../../../../core/security/roles_and_permissions.dart';
import '../../../auth/domain/services/auth_service.dart';
import 'evacuation_route_screen.dart';

class OperationalMapScreen extends StatefulWidget {
  const OperationalMapScreen({super.key});

  @override
  State<OperationalMapScreen> createState() => _OperationalMapScreenState();
}

class _OperationalMapScreenState extends State<OperationalMapScreen> {
  final MapController _mapController = MapController();

  bool _isLoading = true;
  List<dynamic> _riskZones = [];
  List<dynamic> _shelters = [];
  List<dynamic> _pois = [];
  List<dynamic> _devices = [];

  // Filtros de capas
  bool _showRiskZones = true;
  bool _showShelters = true;
  bool _showPois = true;
  bool _showDevices = true;

  StreamSubscription<GpsLocationSnapshot>? _gpsSub;
  bool _centeredOnGps = false;

  @override
  void initState() {
    super.initState();
    _loadMapData();
    _initGpsTracker();
  }

  void _initGpsTracker() {
    _gpsSub = GpsLocationService().locationStream.listen((snapshot) {
      if (mounted) {
        setState(() {});
        if (!_centeredOnGps && GpsLocationService().isRealGpsActive) {
          _centeredOnGps = true;
          _mapController.move(snapshot.position, 15.0);
        }
      }
    });
    // Forzar actualización inmediata del hardware GPS
    GpsLocationService().refreshHardwareLocation().then((snapshot) {
      if (mounted && GpsLocationService().isRealGpsActive) {
        _mapController.move(snapshot.position, 15.0);
      }
    });
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.get('/geography/risk-zones').catchError((_) => null),
        ApiClient.instance.get('/shelters').catchError((_) => null),
        ApiClient.instance.get('/geography/pois').catchError((_) => null),
        ApiClient.instance.get('/devices').catchError((_) => null),
      ]);

      final riskZonesData = results[0];
      final sheltersData = results[1];
      final poisData = results[2];
      final devicesData = results[3];

      List<dynamic> parsedZones = [];
      if (riskZonesData is List && riskZonesData.isNotEmpty) {
        parsedZones = riskZonesData.map((raw) {
          final z = Map<String, dynamic>.from(raw as Map);
          double? lat = (z['latitude'] as num?)?.toDouble();
          double? lng = (z['longitude'] as num?)?.toDouble();
          double radius = ((z['radiusMeters'] as num?) ?? 1000).toDouble();

          if (z['geometryGeoJson'] is Map) {
            final geo = Map<String, dynamic>.from(z['geometryGeoJson'] as Map);
            if (geo['properties'] is Map && (geo['properties'] as Map)['center'] is List) {
              final center = (geo['properties'] as Map)['center'] as List;
              lng = (center[0] as num).toDouble();
              lat = (center[1] as num).toDouble();
              if ((geo['properties'] as Map)['radiusMeters'] != null) {
                radius = ((geo['properties'] as Map)['radiusMeters'] as num).toDouble();
              }
            } else if (geo['coordinates'] is List) {
              final coords = geo['coordinates'] as List;
              if (coords.isNotEmpty && coords[0] is num) {
                lng = (coords[0] as num).toDouble();
                lat = (coords[1] as num).toDouble();
              } else if (coords.isNotEmpty && coords[0] is List) {
                final ring = (coords[0][0] is List) ? (coords[0] as List) : coords;
                double sumLat = 0, sumLng = 0;
                int count = 0;
                for (final pt in ring) {
                  if (pt is List && pt.length >= 2) {
                    sumLng += (pt[0] as num).toDouble();
                    sumLat += (pt[1] as num).toDouble();
                    count++;
                  }
                }
                if (count > 0) {
                  lng = sumLng / count;
                  lat = sumLat / count;
                }
              }
            }
          }

          z['latitude'] = lat ?? 19.4326;
          z['longitude'] = lng ?? -99.1332;
          z['radiusMeters'] = radius;
          return z;
        }).toList();
      }

      List<dynamic> parsedShelters = [];
      if (sheltersData is List && sheltersData.isNotEmpty) {
        parsedShelters = sheltersData.map((raw) {
          final s = Map<String, dynamic>.from(raw as Map);
          s['latitude'] = (s['latitude'] as num?)?.toDouble() ?? 19.4385;
          s['longitude'] = (s['longitude'] as num?)?.toDouble() ?? -99.1295;
          s['totalCapacity'] = s['capacity'] ?? s['totalCapacity'] ?? 100;
          s['currentOccupancy'] = s['currentOccupancy'] ?? s['occupancy'] ?? 0;
          return s;
        }).toList();
      }

      List<dynamic> parsedPois = [];
      if (poisData is List && poisData.isNotEmpty) {
        parsedPois = poisData.map((raw) {
          final p = Map<String, dynamic>.from(raw as Map);
          p['latitude'] = (p['latitude'] as num?)?.toDouble() ?? 19.4350;
          p['longitude'] = (p['longitude'] as num?)?.toDouble() ?? -99.1310;
          return p;
        }).toList();
      }

      List<dynamic> parsedDevices = [];
      if (devicesData is List && devicesData.isNotEmpty) {
        parsedDevices = devicesData.where((raw) {
          if (raw is! Map) return false;
          return raw['lastLatitude'] != null || raw['latitude'] != null;
        }).map((raw) {
          final d = Map<String, dynamic>.from(raw as Map);
          d['id'] = d['deviceIdentifier'] ?? d['id'] ?? 'NODO';
          d['latitude'] = ((d['lastLatitude'] ?? d['latitude']) as num?)?.toDouble() ?? 19.4340;
          d['longitude'] = ((d['lastLongitude'] ?? d['longitude']) as num?)?.toDouble() ?? -99.1320;
          d['deviceType'] = d['deviceModel'] ?? d['deviceType'] ?? 'SIREN_COMMUNITY';
          return d;
        }).toList();
      }

      if (mounted) {
        setState(() {
          _riskZones = parsedZones.isNotEmpty ? parsedZones : _getDefaultRiskZones();
          _shelters = parsedShelters.isNotEmpty ? parsedShelters : _getDefaultShelters();
          _pois = parsedPois.isNotEmpty ? parsedPois : _getDefaultPois();
          _devices = parsedDevices.isNotEmpty ? parsedDevices : _getDefaultDevices();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _riskZones = _getDefaultRiskZones();
          _shelters = _getDefaultShelters();
          _pois = _getDefaultPois();
          _devices = _getDefaultDevices();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultRiskZones() => [
        {
          'id': 'RZ-01',
          'name': 'Perímetro de Desborde Río San Javier',
          'hazardType': 'FLOOD',
          'riskLevel': 'CRITICAL',
          'latitude': 19.4326,
          'longitude': -99.1332,
          'radiusMeters': 1200,
          'description': 'Evacuación preventiva obligatoria hacia cota alta (+42m)',
        },
        {
          'id': 'RZ-02',
          'name': 'Zona de Falla Geológica / Sismo Sector Roma Norte',
          'hazardType': 'EARTHQUAKE',
          'riskLevel': 'HIGH',
          'latitude': 19.4200,
          'longitude': -99.1600,
          'radiusMeters': 800,
          'description': 'Inspección de estructuras de mampostería y redes de gas',
        },
      ];

  List<Map<String, dynamic>> _getDefaultShelters() => [
        {
          'id': 'SH-01',
          'name': 'Gimnasio Municipal Benito Juárez',
          'totalCapacity': 450,
          'currentOccupancy': 288,
          'address': 'Calle República de Brasil #42, Centro',
          'services': 'Agua potable, Atención médica 24/7, Energía solar',
          'latitude': 19.4385,
          'longitude': -99.1295,
          'status': 'OPEN',
        },
        {
          'id': 'SH-02',
          'name': 'Estadio Jesús Martínez "Palillo"',
          'totalCapacity': 800,
          'currentOccupancy': 410,
          'address': 'Av. Río Churubusco s/n, Magdalena Mixhuca',
          'services': 'Comedor comunitario, Pabellón pediátrico',
          'latitude': 19.4080,
          'longitude': -99.1020,
          'status': 'OPEN',
        },
      ];

  List<Map<String, dynamic>> _getDefaultPois() => [
        {
          'id': 'POI-01',
          'name': 'Puesto Médico Avanzado C5 San Jerónimo',
          'category': 'MEDICAL',
          'latitude': 19.4350,
          'longitude': -99.1310,
        },
        {
          'id': 'POI-02',
          'name': 'Punto de Abasto de Agua Potable y Víveres',
          'category': 'WATER',
          'latitude': 19.4370,
          'longitude': -99.1340,
        },
      ];

  List<Map<String, dynamic>> _getDefaultDevices() => [
        {
          'id': 'SIRENA-NOVA-01',
          'deviceType': 'SIREN_COMMUNITY',
          'frequency': '915 MHz (CH 01)',
          'lastLatitude': 19.4340,
          'lastLongitude': -99.1320,
          'status': 'ACTIVE',
        },
      ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isOperator = user?.role != UserRole.citizen;
    final gpsPos = GpsLocationService().currentLocation.position;

    return Scaffold(
      backgroundColor: ResguardoTheme.background,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOperator ? 'Mapa Operacional Táctico C5' : 'Mapa General de Auxilio y Albergues',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ResguardoTheme.primary,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ResguardoTheme.safeEmerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'GPS VIVO: ${GpsLocationService().currentLocation.formattedCoords}',
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: ResguardoTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Centrar en mi ubicación',
            icon: const Icon(Icons.my_location, color: ResguardoTheme.primary),
            onPressed: () {
              _mapController.move(gpsPos, 14.5);
            },
          ),
          IconButton(
            tooltip: 'Sincronizar Datos C5',
            icon: const Icon(Icons.refresh, color: ResguardoTheme.primary),
            onPressed: _loadMapData,
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap con OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: gpsPos,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.innovatec.rednova',
              ),
              // 1. ZONAS DE PELIGRO (Polígonos/Círculos)
              if (_showRiskZones)
                CircleLayer(
                  circles: _riskZones.where((z) => z['latitude'] != null).map((z) {
                    final lat = (z['latitude'] as num).toDouble();
                    final lng = (z['longitude'] as num).toDouble();
                    final radius = ((z['radiusMeters'] as num?) ?? 1000).toDouble();
                    final isCritical = z['riskLevel'] == 'CRITICAL';

                    return CircleMarker(
                      point: LatLng(lat, lng),
                      color: (isCritical ? ResguardoTheme.emergencyCrimson : ResguardoTheme.warningAmber)
                          .withValues(alpha: 0.22),
                      borderColor: isCritical ? ResguardoTheme.emergencyCrimson : ResguardoTheme.warningAmber,
                      borderStrokeWidth: 2.5,
                      radius: radius,
                      useRadiusInMeter: true,
                    );
                  }).toList(),
                ),

              // 2. MARCADORES TÁCTICOS
              MarkerLayer(
                markers: [
                  // Marcador de Ubicación Actual del Usuario (GPS Vivo)
                  Marker(
                    point: gpsPos,
                    width: 38,
                    height: 38,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 24),
                      ),
                    ),
                  ),

                  // Zonas de Peligro (Pines)
                  if (_showRiskZones)
                    ..._riskZones.where((z) => z['latitude'] != null).map((z) {
                      final lat = (z['latitude'] as num).toDouble();
                      final lng = (z['longitude'] as num).toDouble();
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showRiskZoneDetails(z),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.emergencyCrimson,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      );
                    }),

                  // Albergues Oficiales
                  if (_showShelters)
                    ..._shelters.where((s) => s['latitude'] != null).map((s) {
                      final lat = (s['latitude'] as num).toDouble();
                      final lng = (s['longitude'] as num).toDouble();
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showShelterDetails(s),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.safeEmerald,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.house_outlined, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      );
                    }),

                  // Puntos de Interés (Salud / Agua / Alimentos)
                  if (_showPois)
                    ..._pois.where((p) => p['latitude'] != null).map((p) {
                      final lat = (p['latitude'] as num).toDouble();
                      final lng = (p['longitude'] as num).toDouble();
                      final cat = (p['category'] as String?) ?? 'MEDICAL';
                      IconData icon = Icons.local_hospital_outlined;
                      Color bg = const Color(0xFF0284C7);
                      if (cat == 'WATER') {
                        icon = Icons.water_drop_outlined;
                        bg = const Color(0xFF0EA5E9);
                      } else if (cat == 'FOOD') {
                        icon = Icons.restaurant_outlined;
                        bg = const Color(0xFFD97706);
                      }

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 32,
                        height: 32,
                        child: GestureDetector(
                          onTap: () => _showPoiDetails(p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
                              ],
                            ),
                            child: Center(
                              child: Icon(icon, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      );
                    }),

                  // Dispositivos & Sirenas
                  if (_showDevices)
                    ..._devices.where((d) => d['lastLatitude'] != null || d['latitude'] != null).map((d) {
                      final lat = ((d['lastLatitude'] ?? d['latitude']) as num).toDouble();
                      final lng = ((d['lastLongitude'] ?? d['longitude']) as num).toDouble();
                      return Marker(
                        point: LatLng(lat, lng),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: ResguardoTheme.emergencyCrimson, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.volume_up, color: Colors.white, size: 16),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ],
          ),

          // Selector de Capas Flotante
          Positioned(
            top: 10,
            right: 10,
            child: Card(
              color: ResguardoTheme.surface.withValues(alpha: 0.96),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLayerToggle(Icons.warning_amber_rounded, 'Zonas de Peligro', _showRiskZones,
                        (v) => setState(() => _showRiskZones = v)),
                    _buildLayerToggle(Icons.house_outlined, 'Albergues Oficiales', _showShelters,
                        (v) => setState(() => _showShelters = v)),
                    _buildLayerToggle(Icons.place_outlined, 'Puntos de Interés', _showPois,
                        (v) => setState(() => _showPois = v)),
                    _buildLayerToggle(Icons.volume_up_outlined, 'Sirenas y Balizas', _showDevices,
                        (v) => setState(() => _showDevices = v)),
                  ],
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayerToggle(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: value ? ResguardoTheme.primary : ResguardoTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
                color: value ? ResguardoTheme.primary : ResguardoTheme.textMuted,
              ),
            ),
            const SizedBox(width: 4),
            Transform.scale(
              scale: 0.7,
              child: Switch(
                value: value,
                activeThumbColor: ResguardoTheme.primary,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRiskZoneDetails(dynamic zone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ResguardoTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: ResguardoTheme.emergencyCrimson, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      zone['name'] ?? 'Zona de Peligro',
                      style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ResguardoTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AMENAZA: ${zone['hazardType'] ?? 'PELIGRO GENERAL'}',
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('NIVEL DE RIESGO: ${zone['riskLevel'] ?? 'ALTO'}',
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, color: ResguardoTheme.emergencyCrimson, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('RADIO DE AFECTACIÓN: ${zone['radiusMeters'] ?? 1000} metros',
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                zone['description'] ?? 'Evacuar preventivamente si se encuentra dentro del radio.',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResguardoTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ENTENDIDO', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShelterDetails(dynamic s) {
    final cap = (s['totalCapacity'] ?? s['capacity'] ?? 300) as num;
    final occ = (s['currentOccupancy'] ?? s['occupancy'] ?? 0) as num;
    final pct = cap > 0 ? ((occ / cap) * 100).round() : 0;
    final lat = (s['latitude'] as num).toDouble();
    final lng = (s['longitude'] as num).toDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: ResguardoTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.house, color: ResguardoTheme.safeEmerald, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s['name'] ?? 'Albergue Oficial',
                      style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ResguardoTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OCUPACIÓN: $occ / $cap camas ($pct%)',
                        style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('DIRECCIÓN: ${s['address'] ?? 'Zona Segura Habilitada'}',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('SERVICIOS: ${s['services'] ?? 'Agua potable, atención médica'}',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: ResguardoTheme.safeEmerald)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResguardoTheme.safeEmerald,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
                icon: const Icon(Icons.navigation_outlined, size: 18),
                label: const Text('TRAZAR RUTA DE EVACUACIÓN SEGURA',
                    style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EvacuationRouteScreen(
                        shelterDestination: LatLng(lat, lng),
                        shelterName: s['name'] ?? 'Albergue Oficial',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPoiDetails(dynamic p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ResguardoTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.place, color: ResguardoTheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p['name'] ?? 'Punto de Interés Táctico',
                      style: const TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('CATEGORÍA: ${p['category'] ?? 'LOGÍSTICA'}',
                  style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResguardoTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 42),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CERRAR', style: TextStyle(fontFamily: 'Space Grotesk', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
