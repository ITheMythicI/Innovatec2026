import '../models/report.dart';

abstract class ReportRepository {
  Future<List<Report>> getReports({ReportStatus? status, ReportCategory? category, String? emergencyId, bool forceRefresh = false});
  Future<Report?> getReportById(String id);
  Future<Report> createReport(Report report);
  Future<Report> updateReportStatus(String reportId, ReportStatus status);
  Future<void> syncReports();
}
