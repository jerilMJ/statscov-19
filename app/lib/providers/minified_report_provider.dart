import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:statscov/models/api/covid_minified/country_case.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:statscov/services/connectivity_service.dart';
import 'package:statscov/services/covid_api_service.dart';
import 'package:statscov/utils/exceptions.dart';

enum MinifiedReportProviderState { loading, ready, error }

class MinifiedReportProvider with ChangeNotifier {
  MinifiedReportProvider() {
    _isAlive = true;
    tryFetching();
    _connectivitySubscription = _connectivityService
        .getConnectivitySubscription((ConnectivityResult data) {
      if (data != ConnectivityResult.none &&
          (_state == MinifiedReportProviderState.error)) {
        tryFetching();
      }
    });
  }

  final _covidApiService = const CovidApiService();
  // Service for listening to connectivity status.
  final ConnectivityService _connectivityService = ConnectivityService();
  MinifiedReportProviderState _state;
  MinifiedReport _report;
  String _iso;
  dynamic _error;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isAlive;

  MinifiedReport get report => _report;
  MinifiedReportProviderState get state => _state;
  String get iso => _iso;
  dynamic get error => _error;

  void _setState(MinifiedReportProviderState state) {
    _state = state;
    // If error, wait for a second so that loading animation plays.
    if (_state == MinifiedReportProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  Future<void> tryFetching() async {
    try {
      _setState(MinifiedReportProviderState.loading);
      _report = await _covidApiService.getAllReports();
      _setState(MinifiedReportProviderState.ready);
    } catch (e) {
      _error = e;
      _setState(MinifiedReportProviderState.error);
    }
  }

  @override
  void dispose() {
    _isAlive = false;
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
