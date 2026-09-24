import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/reports/domain/models/report.dart';

abstract class ReportLocalDataSource {
  Future<List<Report>> getReports({ReportStatus? status, ReportCategory? category, String? emergencyId});
  Future<Report?> getReportById(String id);
  Future<void> saveReport(Report report);
  Future<void> saveReports(List<Report> reports);
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final AppDatabase _database;

  ReportLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<List<Report>> getReports({ReportStatus? status, ReportCategory? category, String? emergencyId}) async {
    final rawList = await _database.reportsDao.getAll(
      status: status?.toBackendString(),
      category: category?.toBackendString(),
      emergencyId: emergencyId,
    );
    return rawList.map((e) => Report.fromJson(e)).toList();
  }

  @override
  Future<Report?> getReportById(String id) async {
    final raw = await _database.reportsDao.getById(id);
    if (raw == null) return null;
    return Report.fromJson(raw);
  }

  @override
  Future<void> saveReport(Report report) async {
    await _database.reportsDao.insertOrUpdate(report.toDatabaseMap());
  }

  @override
  Future<void> saveReports(List<Report> reports) async {
    await _database.reportsDao.insertOrUpdateAll(
      reports.map((r) => r.toDatabaseMap()).toList(),
    );
  }
}
