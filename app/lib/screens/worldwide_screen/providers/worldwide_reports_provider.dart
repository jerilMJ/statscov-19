import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/services/connectivity_service.dart';
import 'package:statscov/services/covid_api_service.dart';
import 'package:statscov/utils/exceptions.dart';

enum WorldwideReportsProviderState { loading, error, ready }

class WorldwideReportsProvider with ChangeNotifier {
  WorldwideReportsProvider(
    this._appDocsDirPath,
  ) {
    _isAlive = true;
    _isCachedData = false;

    tryFetching();

    setConnectivitySubscription();
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  final ConnectivityService _connectivityService = ConnectivityService();
  final CovidApiService _covidApiService = const CovidApiService();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Map<String, Report> _worldwideReports;
  WorldwideReportsProviderState _state;
  dynamic _error;
  bool _isCachedData;
  bool _isAlive;
  String _appDocsDirPath;
  ValueNotifier<double> _rapNotifier = ValueNotifier<double>(3.0);

  void setConnectivitySubscription() {
    _connectivitySubscription = _connectivityService
        .getConnectivitySubscription((ConnectivityResult data) {
      if (data != ConnectivityResult.none &&
          (_state == WorldwideReportsProviderState.error || _isCachedData)) {
        tryFetching();
      }
    });
  }

  void _setState(WorldwideReportsProviderState state) {
    _state = state;
    // If error, wait for a second so that loading animation plays.
    if (_state == WorldwideReportsProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  WorldwideReportsProviderState get state => _state;
  dynamic get error => _error;

  /// Ordered list of countries based on percentage of cases.
  bool get isCachedData => _isCachedData;
  Map<String, Report> get worldwideReports => _worldwideReports;
  ValueNotifier<double> get rapNotifier => _rapNotifier;

  void tryFetching() async {
    try {
      _isCachedData = false;
      _setState(WorldwideReportsProviderState.loading);

      _worldwideReports = await _covidApiService.getWorldwideReports();

      await compute(updateCache, {
        'path': _appDocsDirPath,
        'data': _worldwideReports,
      });
      _setState(WorldwideReportsProviderState.ready);
    } catch (e) {
      tryFetchingCached().then((_) {
        _isCachedData = true;
        _setState(WorldwideReportsProviderState.ready);
      }).catchError((_) {
        _error = e;
        _isCachedData = false;
        _setState(WorldwideReportsProviderState.error);
      });
    }
  }

  Future<void> tryFetchingCached() async {
    final data = await compute(fetchCache, {
      'path': _appDocsDirPath,
    });

    if (data != null) {
      _worldwideReports = data;
    } else {
      throw const NoCachedDataException();
    }
  }

  static dynamic updateCache(Map<String, dynamic> args) async {
    final path = args['path'];
    final data = args['data'];
    Hive
      ..init(path)
      ..registerAdapter(ReportAdapter());

    final orderedReportsBox = await Hive.openBox('orderedReports');

    orderedReportsBox.put('data', data);

    Hive.close();
  }

  static dynamic fetchCache(Map<String, dynamic> args) async {
    final path = args['path'];
    Hive
      ..init(path)
      ..registerAdapter(ReportAdapter());

    final orderedReportsBox = await Hive.openBox('orderedReports');
    final data = orderedReportsBox.get('data');

    Hive.close();

    return Map<String, Report>.from(data);
  }

  void setRollingAveragePeriod(double val) {
    _rapNotifier.value = val;
  }

  @override
  void dispose() {
    _isAlive = false;
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
