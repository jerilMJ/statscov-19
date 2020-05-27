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
import 'package:statscov/utils/temp_cache.dart';

enum OrderedReportsProviderState { loading, error, ready }

class OrderedReportsProvider with ChangeNotifier {
  OrderedReportsProvider(
    this._firstDate,
    this._lastDate,
    this._cache,
  ) {
    _isAlive = true;
    _currentDateNotifier = ValueNotifier<String>(dateFormat.format(_firstDate));
    _totalDays = _lastDate.difference(_firstDate).inDays;

    tryFetching();

    setConnectivitySubscription();
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  Map<String, List<Report>> _orderedReports;
  final ConnectivityService _connectivityService = ConnectivityService();
  final CovidApiService _covidApiService = const CovidApiService();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  OrderedReportsProviderState _state;
  dynamic _error;
  bool _isAlive;
  String _appDocsDirPath;
  DateTime _firstDate;
  DateTime _lastDate;
  ValueNotifier<String> _currentDateNotifier;
  Timer _timer;
  double _prevPercentage;
  ValueNotifier<double> _percentageNotifier = ValueNotifier<double>(0.0);
  TempCache _cache;
  int _totalDays;

  void setConnectivitySubscription() {
    _connectivitySubscription = _connectivityService
        .getConnectivitySubscription((ConnectivityResult data) {
      if (data != ConnectivityResult.none &&
          (_state == OrderedReportsProviderState.error)) {
        tryFetching();
      }
    });
  }

  void _setState(OrderedReportsProviderState state) {
    _state = state;
    // If error, wait for a second so that loading animation plays.
    if (_state == OrderedReportsProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  void calcPercentage() {
    var totalDays =
        _lastDate.difference(DateTime.parse(_currentDateNotifier.value)).inDays;
    _prevPercentage = _percentageNotifier.value;
    _percentageNotifier.value = (_totalDays - totalDays) / _totalDays;
  }

  OrderedReportsProviderState get state => _state;
  dynamic get error => _error;

  /// Ordered list of countries based on percentage of cases.
  Map<String, List<Report>> get orderedReports => _orderedReports;
  String get firstDate => dateFormat.format(_firstDate);
  String get lastDate => dateFormat.format(_lastDate);
  bool get isTimerActive => _timer != null ? _timer.isActive : false;
  double get prevPercentage => _prevPercentage;
  double get percentage => _percentageNotifier.value;
  String get currentDate => _currentDateNotifier.value;
  ValueNotifier<double> get percentageNotifier => _percentageNotifier;
  ValueNotifier<String> get currentDateNotifier => _currentDateNotifier;

  void tryFetching() async {
    try {
      _setState(OrderedReportsProviderState.loading);

      final cachedObject = _cache.getFromCache('orderedReports');
      if (cachedObject != null) {
        _orderedReports = cachedObject;
        _setState(OrderedReportsProviderState.ready);
        return;
      }

      _orderedReports = await _covidApiService.getOrderedReports();
      _cache.cacheObject('orderedReports', _orderedReports);
      _setState(OrderedReportsProviderState.ready);
    } catch (e) {
      _error = e;
      _setState(OrderedReportsProviderState.error);
    }
  }

  void nextDate() {
    if (DateTime.parse(_currentDateNotifier.value).compareTo(_lastDate) < 0) {
      _currentDateNotifier.value = dateFormat.format(
          DateTime.parse(_currentDateNotifier.value)
              .add(const Duration(days: 1)));
      calcPercentage();
    } else if (_timer.isActive) {
      stopTimer();
    }
  }

  void prevDate() {
    if (DateTime.parse(_currentDateNotifier.value).compareTo(_firstDate) > 0) {
      _currentDateNotifier.value = dateFormat.format(
          DateTime.parse(_currentDateNotifier.value)
              .subtract(const Duration(days: 1)));
      calcPercentage();
    }
  }

  void resetDate() {
    _currentDateNotifier.value = dateFormat.format(_firstDate);
    calcPercentage();

    if (_timer.isActive) stopTimer();
  }

  void fastForwardDate() {
    _currentDateNotifier.value = dateFormat.format(_lastDate);
    calcPercentage();
  }

  void setDate(DateTime date) {
    _currentDateNotifier.value = dateFormat.format(date);
    calcPercentage();
  }

  void stopTimer() {
    _timer?.cancel();
    _setState(OrderedReportsProviderState.ready);
  }

  void startTimer() {
    _timer = new Timer.periodic(
        const Duration(milliseconds: 1000), (_) => nextDate());
    _setState(OrderedReportsProviderState.ready);
  }

  void toggleTimer() {
    if (isTimerActive) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  @override
  void dispose() {
    _isAlive = false;
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
