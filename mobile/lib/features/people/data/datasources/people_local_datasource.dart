import 'package:innovatec_mobile/database/app_database.dart';
import 'package:innovatec_mobile/features/people/domain/models/person_report.dart';

abstract class PeopleLocalDataSource {
  Future<List<PersonReport>> getPersonReports({String? query, PersonReportType? type, bool? minorsOnly});
  Future<PersonReport?> getReportById(String id);
  Future<void> saveReport(PersonReport report);
  Future<void> saveReports(List<PersonReport> reports);
}

class PeopleLocalDataSourceImpl implements PeopleLocalDataSource {
  final AppDatabase _database;

  PeopleLocalDataSourceImpl({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  @override
  Future<List<PersonReport>> getPersonReports({String? query, PersonReportType? type, bool? minorsOnly}) async {
    final rawList = await _database.peopleDao.getAll(
      query: query,
      type: type?.name,
      minorsOnly: minorsOnly,
    );
    return rawList.map((p) => PersonReport.fromJson(p)).toList();
  }

  @override
  Future<PersonReport?> getReportById(String id) async {
    final raw = await _database.peopleDao.getById(id);
    if (raw == null) return null;
    return PersonReport.fromJson(raw);
  }

  @override
  Future<void> saveReport(PersonReport report) async {
    await _database.peopleDao.insertOrUpdate(report.toJson());
  }

  @override
  Future<void> saveReports(List<PersonReport> reports) async {
    await _database.peopleDao.insertOrUpdateAll(
      reports.map((r) => r.toJson()).toList(),
    );
  }
}
