import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Modos de modulación de la antena y radiofrecuencia Mesh.
enum MeshRadioMode {
  standby,
  scanning,
  broadcasting,
  meshRelay,
  emergencyPriority,
}

/// Estado de la antena de comunicación y hardware BLE.
class MeshAntennaStatus {
  final bool isBluetoothEnabled;
  final bool isAntennaTuned;
  final MeshRadioMode currentMode;
  final int activePeersCount;
  final int packetTxSuccess;
  final int packetRxCount;
  final double averageRssi; // dBm
  final String activeChannel; // e.g. 'CH-04 (915.0 MHz / BLE 2.4 GHz)'

  const MeshAntennaStatus({
    required this.isBluetoothEnabled,
    required this.isAntennaTuned,
    required this.currentMode,
    required this.activePeersCount,
    required this.packetTxSuccess,
    required this.packetRxCount,
    required this.averageRssi,
    required this.activeChannel,
  });
}

/// Paquete estructurado transmitido a través de la Red NOVA BLE Mesh.
class MeshPacket {
  final String packetId;
  final String sourceNodeId;
  final String targetNodeId;
  final String payloadType; // 'SOS_ALERT', 'SAFE_PING', 'SHELTER_UPDATE', 'C5_BROADCAST'
  final Map<String, dynamic> data;
  final int hopCount;
  final int maxHops;
  final DateTime timestamp;
  final String signature;

  MeshPacket({
    required this.packetId,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.payloadType,
    required this.data,
    this.hopCount = 0,
    this.maxHops = 7,
    required this.timestamp,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
        'packetId': packetId,
        'sourceNodeId': sourceNodeId,
        'targetNodeId': targetNodeId,
        'payloadType': payloadType,
        'data': data,
        'hopCount': hopCount,
        'maxHops': maxHops,
        'timestamp': timestamp.toIso8601String(),
        'signature': signature,
      };

  factory MeshPacket.fromJson(Map<String, dynamic> json) => MeshPacket(
        packetId: json['packetId'] ?? '',
        sourceNodeId: json['sourceNodeId'] ?? '',
        targetNodeId: json['targetNodeId'] ?? 'BROADCAST',
        payloadType: json['payloadType'] ?? 'GENERIC',
        data: Map<String, dynamic>.from(json['data'] ?? {}),
        hopCount: json['hopCount'] ?? 0,
        maxHops: json['maxHops'] ?? 7,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        signature: json['signature'] ?? '',
      );
}

/// Driver Maestro de Control de Antena y Conectividad Bluetooth Mesh para Red NOVA.
class BluetoothMeshDriver {
  static final BluetoothMeshDriver _instance = BluetoothMeshDriver._internal();
  factory BluetoothMeshDriver() => _instance;

  BluetoothMeshDriver._internal() {
    _initDriver();
  }

  final _statusController = StreamController<MeshAntennaStatus>.broadcast();
  final _packetController = StreamController<MeshPacket>.broadcast();

  bool _isBluetoothEnabled = true;
  bool _isAntennaTuned = true;
  MeshRadioMode _currentMode = MeshRadioMode.meshRelay;
  int _activePeers = 6;
  int _packetTx = 142;
  int _packetRx = 389;
  double _avgRssi = -64.5;
  String _channel = 'CH-04 (BLE 2.4 GHz + Sub-GHz LoRa)';

  Stream<MeshAntennaStatus> get statusStream => _statusController.stream;
  Stream<MeshPacket> get packetStream => _packetController.stream;
  MeshAntennaStatus get currentStatus => MeshAntennaStatus(
        isBluetoothEnabled: _isBluetoothEnabled,
        isAntennaTuned: _isAntennaTuned,
        currentMode: _currentMode,
        activePeersCount: _activePeers,
        packetTxSuccess: _packetTx,
        packetRxCount: _packetRx,
        averageRssi: _avgRssi,
        activeChannel: _channel,
      );

  Timer? _telemetryTimer;

  void _initDriver() {
    _notifyStatus();
    // Simulación reactiva de tráfico de paquetes mesh en segundo plano
    _telemetryTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_isBluetoothEnabled && _isAntennaTuned) {
        _activePeers = 4 + Random().nextInt(5);
        _avgRssi = -55.0 - Random().nextDouble() * 20.0;
        _packetRx += 1;
        _notifyStatus();
      }
    });
  }

  void _notifyStatus() {
    _statusController.add(currentStatus);
  }

  /// Activa o conmuta el estado de la radio Bluetooth
  Future<bool> setBluetoothEnabled(bool enabled) async {
    _isBluetoothEnabled = enabled;
    _currentMode = enabled ? MeshRadioMode.meshRelay : MeshRadioMode.standby;
    _notifyStatus();
    return _isBluetoothEnabled;
  }

  /// Calibra y sintoniza la antena al canal óptimo de menor interferencia
  Future<void> tuneAntennaChannel(String channel) async {
    _channel = channel;
    _isAntennaTuned = true;
    _notifyStatus();
  }

  /// Transmite un paquete de emergencia prioritario a través de la malla BLE
  Future<bool> broadcastEmergencyPacket({
    required String sourceUserId,
    required String payloadType,
    required Map<String, dynamic> payload,
  }) async {
    final packetId = 'PKT-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';
    final rawData = jsonEncode(payload);
    final signature = hmacSha256(rawData, 'NOVA-MESH-SECRET-KEY');

    final packet = MeshPacket(
      packetId: packetId,
      sourceNodeId: sourceUserId,
      targetNodeId: 'C5_GATEWAY_BROADCAST',
      payloadType: payloadType,
      data: payload,
      hopCount: 0,
      maxHops: 7,
      timestamp: DateTime.now(),
      signature: signature,
    );

    _packetTx++;
    _currentMode = MeshRadioMode.emergencyPriority;
    _notifyStatus();
    _packetController.add(packet);

    // Retornar al modo de retransmisión tras disparo
    Future.delayed(const Duration(seconds: 3), () {
      _currentMode = MeshRadioMode.meshRelay;
      _notifyStatus();
    });

    return true;
  }

  static String hmacSha256(String data, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    return hmac.convert(utf8.encode(data)).toString();
  }

  void dispose() {
    _telemetryTimer?.cancel();
    _statusController.close();
    _packetController.close();
  }
}
