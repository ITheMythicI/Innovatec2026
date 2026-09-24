import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/network/api_client.dart';
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
  final LatLng _initialCenter = const LatLng(19.4326, -99.1332); // CDMX

  bool _isLoading = true;
  List<dynamic> _emergencies = [];
  List<dynamic> _shelters = [];
  List<dynamic> _pois = [];
  List<dynamic> _devices = [];

  // Filtros de capas
  bool _showEmergencies = true;
  bool _showShelters = true;
  bool _showPois = true;
  bool _showDevices = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    try {
      final emergenciesData = await ApiClient.instance.get('/emergencies');
      final sheltersData = await ApiClient.instance.get('/shelters');
      final poisData = await ApiClient.instance.get('/geography/pois');

      final user = AuthService().currentUser;
      final isOperator = user?.role == UserRole.authority ||
          user?.role == UserRole.shelterAdmin ||
          user?.role == UserRole.volunteer ||
          user?.role == UserRole.systemAdmin;

      List<dynamic> devicesData = [];
      if (isOperator) {
        try {
          final res = await ApiClient.instance.get('/devices');
          if (res is List) devicesData = res;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _emergencies = emergenciesData is List ? emergenciesData : [];
          _shelters = sheltersData is List ? sheltersData : [];
          _pois = poisData is List ? poisData : [];
          _devices = devicesData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar mapa: $e'),
            backgroundColor: ResguardoTheme.emergencyCrimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final isOperator = user?.role != UserRole.citizen;

    return Scaffold(
      backgroundColor: ResguardoTheme.background,
      appBar: AppBar(
        backgroundColor: ResguardoTheme.surface,
        title: Row(
          children: [
            const Icon(Icons.radar, color: ResguardoTheme.emergencyCrimson, size: 22),
            const SizedBox(width: 8),
            Text(
              isOperator ? 'MAPA OPERACIONAL TÁCTICO' : 'MAPA DE AUXILIO & REFUGIOS',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: ResguardoTheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
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
              initialCenter: _initialCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.innovatec.resguardo',
              ),
              // Capa de círculos de impacto de emergencias
              if (_showEmergencies)
                CircleLayer(
                  circles: _emergencies.where((e) => e['latitude'] != null && e['radiusMeters'] != null).map((e) {
                    return CircleMarker(
                      point: LatLng((e['latitude'] as num).toDouble(), (e['longitude'] as num).toDouble()),
                      color: ResguardoTheme.emergencyCrimson.withOpacity(0.18),
                      borderColor: ResguardoTheme.emergencyCrimson,
                      borderStrokeWidth: 2,
                      radius: ((e['radiusMeters'] as num?) ?? 1000).toDouble(),
                      useRadiusInMeter: true,
                    );
                  }).toList(),
                ),
              // Capa de marcadores
              MarkerLayer(
                markers: [
                  // Marcador de Ubicación Actual simulada
                  Marker(
                    point: _initialCenter,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.my_location, color: Colors.blueAccent, size: 24),
                      ),
                    ),
                  ),
                  // Emergencias Activas
                  if (_showEmergencies)
                    ..._emergencies.where((e) => e['latitude'] != null).map((e) {
                      final lat = (e['latitude'] as num).toDouble();
                      final lon = (e['longitude'] as num).toDouble();
                      return Marker(
                        point: LatLng(lat, lon),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showEmergencyDetails(e),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.emergencyCrimson,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Center(
                              child: Text('🚨', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ),
                      );
                    }),
                  // Albergues
                  if (_showShelters)
                    ..._shelters.where((s) => s['latitude'] != null).map((s) {
                      final lat = (s['latitude'] as num).toDouble();
                      final lon = (s['longitude'] as num).toDouble();
                      return Marker(
                        point: LatLng(lat, lon),
                        width: 34,
                        height: 34,
                        child: GestureDetector(
                          onTap: () => _showShelterDetails(s),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.safeEmerald,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Center(
                              child: Text('🏠', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      );
                    }),
                  // Puntos de Interés / Hospitales
                  if (_showPois)
                    ..._pois.where((p) => p['latitude'] != null).map((p) {
                      final lat = (p['latitude'] as num).toDouble();
                      final lon = (p['longitude'] as num).toDouble();
                      final isHospital = p['category'] == 'HOSPITAL' || p['category'] == 'CLINIC';
                      return Marker(
                        point: LatLng(lat, lon),
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () => _showPoiDetails(p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ResguardoTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                            ),
                            child: Center(
                              child: Text(isHospital ? '🏥' : '💧', style: const TextStyle(fontSize: 14)),
                            ),
                          ),
                        ),
                      );
                    }),
                  // Dispositivos (Solo Operativos)
                  if (_showDevices && isOperator)
                    ..._devices.where((d) => d['lastLatitude'] != null).map((d) {
                      final lat = (d['lastLatitude'] as num).toDouble();
                      final lon = (d['lastLongitude'] as num).toDouble();
                      return Marker(
                        point: LatLng(lat, lon),
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Center(
                            child: Text('📱', style: TextStyle(fontSize: 12)),
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
            top: 12,
            right: 12,
            child: Card(
              color: ResguardoTheme.surface.withOpacity(0.95),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLayerToggle('🚨 Emergencias', _showEmergencies, (v) => setState(() => _showEmergencies = v)),
                    _buildLayerToggle('🏠 Albergues', _showShelters, (v) => setState(() => _showShelters = v)),
                    _buildLayerToggle('🏥 Hospitales', _showPois, (v) => setState(() => _showPois = v)),
                    if (isOperator)
                      _buildLayerToggle('📱 Terminales', _showDevices, (v) => setState(() => _showDevices = v)),
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

  Widget _buildLayerToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: ResguardoTheme.primary,
            onChanged: (v) => onChanged(v ?? false),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showEmergencyDetails(dynamic e) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e['title'] ?? 'Emergencia Activa',
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: ResguardoTheme.emergencyCrimson,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('Tipo: ${e['type']} | Severidad: ${e['severity']}'),
              const SizedBox(height: 6),
              Text('Descripción: ${e['description'] ?? 'Sin descripción adicional'}'),
              const SizedBox(height: 6),
              Text('Radio de Afectación: ${e['radiusMeters'] ?? 0} metros'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResguardoTheme.emergencyCrimson,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EvacuationRouteScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.warning),
                  label: const Text('Ruta de Evacuación Segura'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShelterDetails(dynamic s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final cap = s['capacity'] ?? 0;
        final occ = s['currentOccupancy'] ?? 0;
        final pct = cap > 0 ? (occ / cap * 100).round() : 0;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏠', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s['name'] ?? 'Albergue Oficial',
                      style: const TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: ResguardoTheme.safeEmerald,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('Ocupación: $occ / $cap plazas ($pct%)'),
              const SizedBox(height: 6),
              Text('Dirección: ${s['address'] ?? 'No especificada'}'),
              const SizedBox(height: 6),
              Text('Teléfono de Contacto: ${s['contactPhone'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResguardoTheme.safeEmerald,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EvacuationRouteScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('Cómo Llegar al Albergue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPoiDetails(dynamic p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p['name'] ?? 'Punto de Interés',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(height: 20),
              Text('Categoría: ${p['category']} | Estado: ${p['status']}'),
              const SizedBox(height: 6),
              Text('Contacto: ${p['contactPhone'] ?? 'N/A'}'),
            ],
          ),
        );
      },
    );
  }
}
