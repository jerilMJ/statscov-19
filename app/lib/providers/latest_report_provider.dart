import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:statscov/models/api/coordinates.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/covid_compiled/reports.dart';
import 'package:statscov/services/connectivity_service.dart';
import 'package:statscov/services/covid_api_service.dart';
import 'package:statscov/utils/exceptions.dart';

enum LatestReportsProviderState { loading, ready, error }

class LatestReportsProvider with ChangeNotifier {
  LatestReportsProvider(this._appDocsDirPath) {
    _isAlive = true;
    _isCachedData = false;
    tryFetching();
    _connectivitySubscription = _connectivityService
        .getConnectivitySubscription((ConnectivityResult data) {
      if (data != ConnectivityResult.none &&
          (_state == LatestReportsProviderState.error || _isCachedData)) {
        tryFetching();
      }
    });
  }

  final _covidApiService = const CovidApiService();
  // Service for listening to connectivity status.
  final ConnectivityService _connectivityService = ConnectivityService();
  LatestReportsProviderState _state;
  Reports _reports;
  String _iso;
  dynamic _error;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isCachedData;
  bool _isAlive;
  String _appDocsDirPath;

  Reports get reports => _reports;
  LatestReportsProviderState get state => _state;
  String get iso => _iso;
  dynamic get error => _error;
  String get lastUpdate => _reports?.getReportForIso('USA')?.date;
  bool get isCachedData => _isCachedData;
  String get appDocsDirPath => _appDocsDirPath;
  DateTime get firstDate => DateTime.parse("2020-01-22");
  DateTime get lastDate => DateTime.parse(lastUpdate);
  int get totalCountries => 182;

  void _setState(LatestReportsProviderState state) {
    _state = state;
    // If error, wait for a second so that loading animation plays.
    if (_state == LatestReportsProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  Future<void> tryFetching() async {
    try {
      _isCachedData = false;
      _setState(LatestReportsProviderState.loading);
      _reports = await _covidApiService.getAllLatestReports();
      _setState(LatestReportsProviderState.ready);

      await compute(updateCache, {
        'path': _appDocsDirPath,
        'data': _reports,
      });
    } catch (e) {
      tryFetchingCached().then((_) {
        _isCachedData = true;
        _setState(LatestReportsProviderState.ready);
      }).catchError((_) {
        _error = e;
        _isCachedData = false;
        _setState(LatestReportsProviderState.error);
      });
    }
  }

  Future<void> tryFetchingCached() async {
    final data = await compute(fetchCache, {
      'path': _appDocsDirPath,
    });

    if (data != null) {
      _reports = data;
    } else {
      throw const NoCachedDataException();
    }
  }

  static dynamic updateCache(Map<String, dynamic> args) async {
    final path = args['path'];
    final data = args['data'];
    Hive
      ..init(path)
      ..registerAdapter(CoordinatesAdapter())
      ..registerAdapter(ReportAdapter())
      ..registerAdapter(ReportsAdapter());

    final countriesListBox = await Hive.openBox('latestReports');

    countriesListBox.put('data', data);

    Hive.close();
  }

  static dynamic fetchCache(Map<String, dynamic> args) async {
    final path = args['path'];

    Hive
      ..init(path)
      ..registerAdapter(CoordinatesAdapter())
      ..registerAdapter(ReportAdapter())
      ..registerAdapter(ReportsAdapter());

    final countriesListBox = await Hive.openBox('latestReports');
    final data = countriesListBox.get('data');

    Hive.close();

    return data;
  }

  @override
  void dispose() {
    _isAlive = false;
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
