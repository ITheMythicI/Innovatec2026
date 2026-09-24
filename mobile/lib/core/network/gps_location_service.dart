import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Estado del enlace satelital GPS
enum GpsFixStatus {
  searching,
  fix2D,
  fix3D,
  highPrecision,
  simulated,
  permissionDenied,
}

/// Instantánea de posición satelital georreferenciada.
class GpsLocationSnapshot {
  final LatLng position;
  final double altitude; // metros sobre el nivel del mar
  final double accuracy; // metros de precisión
  final double speed; // km/h
  final GpsFixStatus status;
  final int satellitesConnected;
  final DateTime timestamp;

  const GpsLocationSnapshot({
    required this.position,
    this.altitude = 0.0,
    this.accuracy = 5.0,
    this.speed = 0.0,
    this.status = GpsFixStatus.searching,
    this.satellitesConnected = 8,
    required this.timestamp,
  });

  double get latitude => position.latitude;
  double get longitude => position.longitude;

  String get formattedCoords =>
      '${latitude >= 0 ? latitude.toStringAsFixed(5) : (-latitude).toStringAsFixed(5)}° ${latitude >= 0 ? "N" : "S"}, ${longitude >= 0 ? longitude.toStringAsFixed(5) : (-longitude).toStringAsFixed(5)}° ${longitude >= 0 ? "E" : "W"}';
}

/// Servicio Gestor de Posicionamiento GPS en Tiempo Real para Red NOVA.
class GpsLocationService {
  static final GpsLocationService _instance = GpsLocationService._internal();
  factory GpsLocationService() => _instance;

  GpsLocationService._internal() {
    _initService();
  }

  final _locationController = StreamController<GpsLocationSnapshot>.broadcast();
  StreamSubscription<Position>? _positionStreamSub;

  GpsLocationSnapshot _currentLocation = GpsLocationSnapshot(
    position: const LatLng(19.4326, -99.1332), // Fallback inicial
    altitude: 2240.5,
    accuracy: 5.0,
    speed: 0.0,
    status: GpsFixStatus.searching,
    satellitesConnected: 8,
    timestamp: DateTime.now(),
  );

  bool _isRealGpsActive = false;

  Stream<GpsLocationSnapshot> get locationStream => _locationController.stream;
  GpsLocationSnapshot get currentLocation => _currentLocation;
  bool get isRealGpsActive => _isRealGpsActive;

  Future<void> _initService() async {
    _locationController.add(_currentLocation);
    await refreshHardwareLocation();
  }

  /// Solicita permisos de ubicación y obtiene la posición real del dispositivo
  Future<GpsLocationSnapshot> refreshHardwareLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Servicio desactivado en el SO
        _currentLocation = GpsLocationSnapshot(
          position: _currentLocation.position,
          status: GpsFixStatus.permissionDenied,
          timestamp: DateTime.now(),
        );
        _locationController.add(_currentLocation);
        return _currentLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentLocation = GpsLocationSnapshot(
            position: _currentLocation.position,
            status: GpsFixStatus.permissionDenied,
            timestamp: DateTime.now(),
          );
          _locationController.add(_currentLocation);
          return _currentLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _currentLocation = GpsLocationSnapshot(
          position: _currentLocation.position,
          status: GpsFixStatus.permissionDenied,
          timestamp: DateTime.now(),
        );
        _locationController.add(_currentLocation);
        return _currentLocation;
      }

      // Obtener posición instantánea de alta precisión del hardware
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _isRealGpsActive = true;
      _currentLocation = _convertPositionToSnapshot(position);
      _locationController.add(_currentLocation);

      // Iniciar stream continuo de movimiento
      _listenToPositionUpdates();

      return _currentLocation;
    } catch (e) {
      // Fallback a última posición registrada
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          _isRealGpsActive = true;
          _currentLocation = _convertPositionToSnapshot(lastPos);
          _locationController.add(_currentLocation);
          _listenToPositionUpdates();
          return _currentLocation;
        }
      } catch (_) {}

      return _currentLocation;
    }
  }

  void _listenToPositionUpdates() {
    _positionStreamSub?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // Actualiza cada 3 metros de desplazamiento
    );

    _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _isRealGpsActive = true;
        _currentLocation = _convertPositionToSnapshot(position);
        _locationController.add(_currentLocation);
      },
      onError: (err) {
        // En caso de pérdida momentánea de satélites
      },
    );
  }

  GpsLocationSnapshot _convertPositionToSnapshot(Position p) {
    return GpsLocationSnapshot(
      position: LatLng(p.latitude, p.longitude),
      altitude: p.altitude,
      accuracy: p.accuracy,
      speed: p.speed * 3.6, // m/s a km/h
      status: p.accuracy <= 5.0 ? GpsFixStatus.highPrecision : GpsFixStatus.fix3D,
      satellitesConnected: p.accuracy <= 5.0 ? 14 : 9,
      timestamp: p.timestamp,
    );
  }

  /// Permite establecer o fijar coordenadas manuales si el usuario lo requiere
  void setManualPosition(LatLng newPos) {
    _currentLocation = GpsLocationSnapshot(
      position: newPos,
      altitude: _currentLocation.altitude,
      accuracy: 1.5,
      speed: 0.0,
      status: GpsFixStatus.simulated,
      satellitesConnected: 12,
      timestamp: DateTime.now(),
    );
    _locationController.add(_currentLocation);
  }

  /// Calcula la distancia en metros entre dos puntos geográficos (Haversine)
  static double calculateDistanceMeters(LatLng p1, LatLng p2) {
    const earthRadius = 6371000.0; // metros
    final dLat = _deg2rad(p2.latitude - p1.latitude);
    final dLon = _deg2rad(p2.longitude - p1.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(p1.latitude)) *
            cos(_deg2rad(p2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180.0);

  /// Formatea la distancia de manera legible (e.g. "450 m" o "2.4 km")
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  void dispose() {
    _positionStreamSub?.cancel();
    _locationController.close();
  }
}
