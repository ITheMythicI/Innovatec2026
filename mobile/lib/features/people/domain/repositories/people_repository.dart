import '../models/person_report.dart';

abstract class PeopleRepository {
  Future<List<PersonReport>> getPersonReports({String? query, PersonReportType? type, bool? minorsOnly, bool forceRefresh = false});
  Future<PersonReport?> getReportById(String id);
  Future<PersonReport> createPersonReport(PersonReport report);
  Future<PersonReport> updateReportVerification(PersonReport report);
  Future<void> syncReports();
}
