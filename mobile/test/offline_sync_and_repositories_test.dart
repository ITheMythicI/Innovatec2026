import 'package:flutter_test/flutter_test.dart';
import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/emergencies/domain/models/emergency.dart';
import 'package:innovatec_mobile/features/emergencies/data/repositories/emergency_repository_impl.dart';
import 'package:innovatec_mobile/features/shelters/domain/models/shelter.dart';
import 'package:innovatec_mobile/features/shelters/data/repositories/shelter_repository_impl.dart';
import 'package:innovatec_mobile/features/reports/domain/models/report.dart';
import 'package:innovatec_mobile/features/reports/data/repositories/report_repository_impl.dart';
import 'package:innovatec_mobile/sync/sync_manager.dart';

void main() {
  setUp(() async {
    await AppDatabase.instance.initialize();
  });

  group('1. Emergency Repository & SQLite Persistence Tests', () {
    test('Saves emergency locally in SQLite with pending status and queues sync event', () async {
      final repository = EmergencyRepositoryImpl();
      final emergency = Emergency(
        id: 'emg-test-001',
        title: 'Sismo Magnitud 7.2',
        description: 'Epicentro en Costa de Guerrero',
        type: EmergencyType.earthquake,
        severity: EmergencySeverity.critical,
        status: EmergencyStatus.active,
        latitude: 16.8531,
        longitude: -99.8237,
        startedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      final created = await repository.createEmergency(emergency);
      expect(created.id, equals('emg-test-001'));
      expect(created.syncStatus, equals('pending_create'));

      // Verifica lectura desde caché local
      final localList = await repository.getEmergencies();
      expect(localList.any((e) => e.id == 'emg-test-001'), isTrue);

      // Verifica encolado en SQLite sync_queue
      final pendingEvents = await AppDatabase.instance.syncQueueDao.getPendingEvents();
      expect(pendingEvents.any((e) => e['entity_id'] == 'emg-test-001'), isTrue);
    });
  });

  group('2. Shelter Repository & Occupancy Tests', () {
    test('Persists shelters locally and calculates occupancy correctly', () async {
      final repository = ShelterRepositoryImpl();
      final shelter = Shelter(
        id: 'shl-test-001',
        name: 'Albergue Deportivo Benito Juárez',
        address: 'Av. Cuauhtémoc 123',
        latitude: 19.3800,
        longitude: -99.1600,
        capacity: 100,
        currentOccupancy: 40,
        status: ShelterStatus.open,
        services: ['AGUA', 'MÉDICO', 'ENERGÍA'],
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await repository.createShelter(shelter);

      final retrieved = await repository.getShelterById('shl-test-001');
      expect(retrieved, isNotNull);
      expect(retrieved!.availableBeds, equals(60));
      expect(retrieved.occupancyPercentage, equals(0.4));
      expect(retrieved.services.length, equals(3));
    });
  });

  group('3. Report Repository & Offline-First Incident Pipeline', () {
    test('Creates incident report offline and verifies SQLite persistence', () async {
      final repository = ReportRepositoryImpl();
      final report = Report(
        id: 'rep-test-001',
        title: 'Derrumbe de Barda Perimetral',
        description: 'Bloqueo parcial de vialidad',
        category: ReportCategory.structuralDamage,
        priority: ReportPriority.high,
        status: ReportStatus.pending,
        latitude: 19.4120,
        longitude: -99.1650,
        address: 'Av. Álvaro Obregón 240',
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await repository.createReport(report);

      final list = await repository.getReports(category: ReportCategory.structuralDamage);
      expect(list.any((r) => r.id == 'rep-test-001'), isTrue);
    });
  });

  group('4. SyncManager Idempotency & Queue Tests', () {
    test('Enqueues mutations and generates distinct UUID v4 event IDs', () async {
      final syncManager = SyncManager.instance;
      final event1 = await syncManager.enqueueLocalMutation(
        entityType: 'report',
        entityId: 'rep-uuid-001',
        operation: 'CREATE',
        payload: {'title': 'Incendio forestal'},
      );

      final event2 = await syncManager.enqueueLocalMutation(
        entityType: 'report',
        entityId: 'rep-uuid-002',
        operation: 'CREATE',
        payload: {'title': 'Inundación río'},
      );

      expect(event1.eventId, isNotEmpty);
      expect(event2.eventId, isNotEmpty);
      expect(event1.eventId, isNot(equals(event2.eventId)));
      expect(event1.deviceId, startsWith('dev-mobile-'));
    });
  });
}
