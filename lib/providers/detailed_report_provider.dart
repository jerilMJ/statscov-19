import 'package:flutter/cupertino.dart';
import 'package:statscov/models/detailed_report.dart';
import 'package:statscov/services/countries_api_service.dart';
import 'package:statscov/services/covid_api_service.dart';
import 'package:async/async.dart';

enum DetailedReportProviderState { loading, ready, error, empty }

class DetailedReportProvider with ChangeNotifier {
  DetailedReportProviderState _state;
  DetailedReport _detailedReport;
  String _iso;
  Error _error;
  final _covidApiService = CovidApiService();
  final _countriesApiService = CountriesApiService();
  CancelableOperation _getReportOperation;

  void _setState(DetailedReportProviderState state) {
    _state = state;
    notifyListeners();
  }

  DetailedReportProvider(String iso) {
    setDetailedReport(iso);
  }

  DetailedReport get detailedReport => _detailedReport;
  DetailedReportProviderState get state => _state;
  String get iso => _iso;
  Error get error => _error;

  void setDetailedReport(String iso) async {
    if (iso == _iso && !_getReportOperation.isCanceled) return;
    _iso = iso;
    _setState(DetailedReportProviderState.loading);

    _getReportOperation = CancelableOperation.fromFuture(getReport()).then(
      (report) {
        _detailedReport = report;
        _setState(DetailedReportProviderState.ready);
      },
      onCancel: () {
        return null;
      },
      onError: (error, stackTrace) {
        _error = error;
        _detailedReport = null;
        _setState(DetailedReportProviderState.error);
      },
    );
  }

  Future<DetailedReport> getReport() async {
    try {
      final report = await _covidApiService.getReportForIsoCode(_iso);
      final country = await _countriesApiService.getDetailsForIso(_iso);

      return DetailedReport(report, country);
    } catch (e) {
      throw e;
    }
  }

  void stopFetchingReport() {
    if (_getReportOperation != null && !_getReportOperation.isCompleted) {
      _getReportOperation.cancel().then(
        (_) {
          _detailedReport = null;
          _setState(DetailedReportProviderState.empty);
        },
      );
    }
  }
}
