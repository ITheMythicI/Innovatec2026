enum ShelterStatus {
  open,
  full,
  closed,
  evacuating,
}

extension ShelterStatusExtension on ShelterStatus {
  String get displayName {
    switch (this) {
      case ShelterStatus.open:
        return 'Abierto / Disponible';
      case ShelterStatus.full:
        return 'Capacidad Completa';
      case ShelterStatus.closed:
        return 'Cerrado';
      case ShelterStatus.evacuating:
        return 'En Evacuación';
    }
  }

  String toBackendString() => name.toUpperCase();

  static ShelterStatus fromString(String? val) {
    if (val == null) return ShelterStatus.open;
    final norm = val.toUpperCase();
    for (final s in ShelterStatus.values) {
      if (s.name.toUpperCase() == norm) return s;
    }
    return ShelterStatus.open;
  }
}

class Shelter {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final int capacity;
  final int currentOccupancy;
  final ShelterStatus status;
  final String? contactName;
  final String? contactPhone;
  final String? managedBy;
  final List<String> services;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const Shelter({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    this.currentOccupancy = 0,
    this.status = ShelterStatus.open,
    this.contactName,
    this.contactPhone,
    this.managedBy,
    this.services = const [],
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  int get availableBeds => (capacity - currentOccupancy).clamp(0, capacity);
  double get occupancyPercentage => capacity > 0 ? (currentOccupancy / capacity).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'capacity': capacity,
    'currentOccupancy': currentOccupancy,
    'status': status.toBackendString(),
    'contactName': contactName,
    'contactPhone': contactPhone,
    'managedBy': managedBy,
    'services': services,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'syncStatus': syncStatus,
  };

  Map<String, dynamic> toDatabaseMap() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'capacity': capacity,
    'current_occupancy': currentOccupancy,
    'status': status.toBackendString(),
    'contact_name': contactName,
    'contact_phone': contactPhone,
    'managed_by': managedBy,
    'services_json': services.join(','),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'sync_status': syncStatus,
  };

  factory Shelter.fromJson(Map<String, dynamic> json) {
    List<String> parsedServices = [];
    if (json['services'] is List) {
      parsedServices = (json['services'] as List).map((e) {
        if (e is Map) {
          return (e['serviceType'] ?? e['name'] ?? '').toString();
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    } else if (json['services_json'] is String && (json['services_json'] as String).isNotEmpty) {
      parsedServices = (json['services_json'] as String).split(',');
    }

    return Shelter(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: (json['capacity'] as num).toInt(),
      currentOccupancy: (json['currentOccupancy'] ?? json['current_occupancy'] as num?)?.toInt() ?? 0,
      status: ShelterStatusExtension.fromString(json['status'] as String?),
      contactName: json['contactName'] ?? json['contact_name'] as String?,
      contactPhone: json['contactPhone'] ?? json['contact_phone'] as String?,
      managedBy: json['managedBy'] ?? json['managed_by'] as String?,
      services: parsedServices,
      createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
      updatedAt: DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String),
      syncStatus: json['syncStatus'] ?? json['sync_status'] ?? 'synced',
    );
  }
}
