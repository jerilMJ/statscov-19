import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statscov/models/api/covid_compiled/reports.dart';
import 'package:statscov/models/api/detailed_report.dart';
import 'package:statscov/models/api/iso_name.dart';
import 'package:statscov/services/countries_api_service.dart';
import 'package:async/async.dart';

enum DetailedReportProviderState { loading, ready, error, empty }

class DetailedReportProvider with ChangeNotifier {
  DetailedReportProvider(this._reports) {
    _isAlive = true;
    _setState(DetailedReportProviderState.loading);
    _initFields();
  }

  void _initFields() async {
    _prefs = await SharedPreferences.getInstance();
    final pinnedIso = _prefs.getString('pinnedCountry');

    if (pinnedIso != null) {
      setDetailedReport(pinnedIso);
    } else {
      _setState(DetailedReportProviderState.empty);
    }
  }

  final _countriesApiService = const CountriesApiService();
  DetailedReportProviderState _state;
  DetailedReport _detailedReport;
  Reports _reports;
  String _iso;
  dynamic _error;
  CancelableOperation _getReportOperation;
  String _currentlySearchingFor;
  String _isoOnError;
  ValueNotifier<double> _rapNotifier = ValueNotifier<double>(3.0);
  SharedPreferences _prefs;
  bool _isAlive;

  DetailedReport get detailedReport => _detailedReport;
  DetailedReportProviderState get state => _state;
  String get iso => _iso;
  String get currentlySearchingFor => _currentlySearchingFor;
  dynamic get error => _error;
  String get isoOnError => _isoOnError;
  ValueNotifier<double> get rapNotifier => _rapNotifier;
  double get rollingAveragePeriod => _rapNotifier.value;

  void _setState(DetailedReportProviderState state) {
    _state = state;
    _handleState();
    if (_state == DetailedReportProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  void _handleState() {
    switch (_state) {
      case DetailedReportProviderState.empty:
        _detailedReport = null;
        _error = null;
        _getReportOperation = null;
        _currentlySearchingFor = null;
        _isoOnError = null;
        break;
      case DetailedReportProviderState.ready:
        _error = null;
        _getReportOperation = null;
        _isoOnError = null;
        break;
      case DetailedReportProviderState.loading:
        _error = null;
        _isoOnError = null;
        break;
      case DetailedReportProviderState.error:
        _detailedReport = null;
        _getReportOperation = null;
        _currentlySearchingFor = null;
        _isoOnError = _iso;
        break;
    }
  }

  void setDetailedReport(String iso) async {
    if (iso == _iso && _getReportOperation != null
        ? !_getReportOperation.isCanceled
        : false) return;

    if (checkCache(iso) != null) {
      setCachedDetailedReport(iso);
      return;
    }

    _iso = iso;
    _currentlySearchingFor = IsoName().iso3ToCountry(iso);
    _setState(DetailedReportProviderState.loading);

    _getReportOperation = CancelableOperation.fromFuture(getReport()).then(
      (report) {
        _detailedReport = report;
        cacheReport(_detailedReport);
        _setState(DetailedReportProviderState.ready);
      },
      onCancel: () {
        return null;
      },
      onError: (error, stackTrace) {
        _error = error;
        _setState(DetailedReportProviderState.error);
      },
    );
  }

  Future<DetailedReport> getReport() async {
    try {
      final report = _reports.getReportForIso(_iso);
      final country = await _countriesApiService.getDetailsForIso(_iso);

      return DetailedReport(report, country);
    } catch (e) {
      throw e;
    }
  }

  void stopFetchingReport() {
    if (_getReportOperation != null && !_getReportOperation.isCompleted) {
      _getReportOperation.cancel().then(
            (_) => _setState(DetailedReportProviderState.empty),
          );
    }
  }

  void cacheReport(DetailedReport detailedReport) {
    final detailedReportsBox = Hive.box('detailedReports');
    detailedReportsBox.put(detailedReport.report.iso, detailedReport);
  }

  DetailedReport checkCache(String iso) {
    final detailedReportsBox = Hive.box('detailedReports');
    return detailedReportsBox.get(iso);
  }

  void setCachedDetailedReport(String iso) {
    final detailedReportsBox = Hive.box('detailedReports');
    _detailedReport = detailedReportsBox.get(iso);
    _currentlySearchingFor = _detailedReport.report.countryName;
    _setState(DetailedReportProviderState.ready);
  }

  void setRollingAveragePeriod(double val) {
    _rapNotifier.value = val;
  }

  void pinCountry() {
    _prefs.setString('pinnedCountry', _detailedReport?.report?.iso);
  }

  bool isPinned(String iso) {
    return _prefs.getString('pinnedCountry') == iso;
  }

  @override
  void dispose() {
    _isAlive = false;
    super.dispose();
  }
}
