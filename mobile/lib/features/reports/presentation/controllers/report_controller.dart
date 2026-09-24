import 'package:flutter/foundation.dart';
import '../../domain/models/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/repositories/report_repository_impl.dart';

enum ReportStateStatus { initial, loading, success, error, empty }

class ReportController extends ChangeNotifier {
  final ReportRepository _repository;

  ReportController({ReportRepository? repository})
      : _repository = repository ?? ReportRepositoryImpl();

  ReportStateStatus _status = ReportStateStatus.initial;
  List<Report> _reports = [];
  String? _errorMessage;
  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;

  ReportStateStatus get status => _status;
  List<Report> get reports => _reports;
  String? get errorMessage => _errorMessage;
  ReportCategory? get selectedCategory => _selectedCategory;
  ReportStatus? get selectedStatus => _selectedStatus;

  Future<void> loadReports({bool forceRefresh = false}) async {
    _status = ReportStateStatus.loading;
    notifyListeners();

    try {
      _reports = await _repository.getReports(
        status: _selectedStatus,
        category: _selectedCategory,
        forceRefresh: forceRefresh,
      );
      _status = _reports.isEmpty ? ReportStateStatus.empty : ReportStateStatus.success;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ReportStateStatus.error;
    }
    notifyListeners();
  }

  void filterByCategory(ReportCategory? category) {
    _selectedCategory = category;
    loadReports();
  }

  void filterByStatus(ReportStatus? status) {
    _selectedStatus = status;
    loadReports();
  }

  Future<void> createReport(Report report) async {
    try {
      final created = await _repository.createReport(report);
      _reports.insert(0, created);
      _status = ReportStateStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStatus(String reportId, ReportStatus status) async {
    try {
      final updated = await _repository.updateReportStatus(reportId, status);
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> sync() async {
    await _repository.syncReports();
    await loadReports(forceRefresh: true);
  }
}
