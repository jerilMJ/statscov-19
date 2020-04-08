import 'package:flutter/cupertino.dart';
import 'package:statscov/models/detailed_report.dart';
import 'package:statscov/services/countries_api_service.dart';
import 'package:statscov/services/covid_api_service.dart';

enum DetailedReportProviderState { loading, ready, error }

class DetailedReportProvider with ChangeNotifier {
  DetailedReportProviderState _state;
  DetailedReport _detailedReport;
  String _iso;
  Exception _exception;
  final _covidApiService = CovidApiService();
  final _countriesApiService = CountriesApiService();

  void _setState(DetailedReportProviderState state) {
    _state = state;
    notifyListeners();
  }

  DetailedReportProvider() {
    _state = DetailedReportProviderState.loading;
  }

  DetailedReport get detailedReport => _detailedReport;
  DetailedReportProviderState get state => _state;
  String get iso => _iso;
  Exception get exception => _exception;

  void setDetailedReport(String iso) async {
    _iso = iso;
    _setState(DetailedReportProviderState.loading);

    try {
      final report = await _covidApiService.getReportForIsoCode(_iso);
      final country = await _countriesApiService.getDetailsForIso(_iso);

      _detailedReport = DetailedReport(report, country);
      _setState(DetailedReportProviderState.ready);
    } catch (e) {
      _exception = e;
      _setState(DetailedReportProviderState.error);
    }
  }
}
