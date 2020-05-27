import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/covid_compiled/reports.dart';
import 'package:statscov/services/connectivity_service.dart';
import 'package:statscov/services/wordlwide_report_service.dart';
import 'package:statscov/utils/exceptions.dart';

enum WorldwideReportProviderState { loading, error, ready }

class WorldwideReportProvider with ChangeNotifier {
  WorldwideReportProvider(Reports reports, this._appDocsDirPath) {
    _isAlive = true;
    _isCachedData = false;
    _lastUpdate = reports.reports['USA'].date;
    _countryWiseReports = reports.reports.values.toList();
    _countryWiseReports.sort((reportA, reportB) {
      return reportA.confirmed.compareTo(reportB.confirmed);
    });
    _countryWiseReports = _countryWiseReports.reversed.toList();
    tryFetchingCached().then((_) {
      if (_report.date == _lastUpdate) {
        if (_countryWiseReports != null) fetchBarStacks();
        _setState(WorldwideReportProviderState.ready);
      } else {
        tryFetching();
      }
    }).catchError((_) {
      tryFetching();
    });
    setConnectivitySubscription();
  }

  WorldwideReportProvider.onlyWorldwide(Reports reports, this._appDocsDirPath) {
    _isAlive = true;
    _lastUpdate = reports.reports['USA'].date;
    tryFetchingCached().then((_) {
      if (_report.date == _lastUpdate) {
        _setState(WorldwideReportProviderState.ready);
      } else {
        tryFetching();
      }
    }).catchError((_) {
      tryFetching();
    });
    setConnectivitySubscription();
  }

  final _worldwideReportService = WorldwideReportService();
  // Service for listening to connectivity status.
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  WorldwideReportProviderState _state;
  Report _report;
  List<Report> _countryWiseReports;
  List<BarChartRodStackItem> _barChartStack;
  List<double> _barStackProportions;
  // Top 10 countries based on percentage of cases.
  List<Report> _topCountries;
  dynamic _error;
  bool _isCachedData;
  String _lastUpdate;
  bool _isAlive;
  String _appDocsDirPath;

  void setConnectivitySubscription() {
    _connectivitySubscription = _connectivityService
        .getConnectivitySubscription((ConnectivityResult data) {
      if (data != ConnectivityResult.none &&
          (_state == WorldwideReportProviderState.error || _isCachedData)) {
        tryFetching();
      }
    });
  }

  void _setState(WorldwideReportProviderState state) {
    _state = state;
    // If error, wait for a second so that loading animation plays.
    if (_state == WorldwideReportProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  WorldwideReportProviderState get state => _state;
  dynamic get error => _error;
  Report get report => _report;

  /// Ordered list of countries based on percentage of cases.
  List<Report> get countryWiseReports => _countryWiseReports;
  List<Report> get topCountries => _topCountries;
  List<double> get barStackProportions => _barStackProportions;
  List<BarChartRodStackItem> get barChartStack => _barChartStack;
  bool get isCachedData => _isCachedData;

  void tryFetching() async {
    try {
      _isCachedData = false;
      _report = null;

      _setState(WorldwideReportProviderState.loading);
      _report = await _worldwideReportService.getWorldwideReport();
      if (_countryWiseReports != null) fetchBarStacks();
      _setState(WorldwideReportProviderState.ready);

      await compute(updateCache, {
        'path': _appDocsDirPath,
        'data': _report,
      });
    } catch (e) {
      tryFetchingCached().then((_) {
        _isCachedData = true;
        if (_countryWiseReports != null) fetchBarStacks();
        _setState(WorldwideReportProviderState.ready);
      }).catchError((_) {
        _error = e;
        _isCachedData = false;
        _setState(WorldwideReportProviderState.error);
      });
    }
  }

  Future<void> tryFetchingCached() async {
    final data = await compute(fetchCache, {
      'path': _appDocsDirPath,
    });

    if (data != null) {
      _report = data;
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

    final countriesListBox = await Hive.openBox('worldwideReport');

    countriesListBox.put('data', data);

    Hive.close();
  }

  static dynamic fetchCache(Map<String, dynamic> args) async {
    final path = args['path'];
    Hive
      ..init(path)
      ..registerAdapter(ReportAdapter());

    final countriesListBox = await Hive.openBox('worldwideReport');
    final data = countriesListBox.get('data');

    Hive.close();

    return data;
  }

  /// Helper function for [StackedBar] widget.
  void fetchBarStacks() {
    var barStacks = <BarChartRodStackItem>[];
    var topReports = <Report>[];
    var colors = [
      Colors.blue.shade900,
      Colors.blue.shade800,
      Colors.blue.shade700,
      Colors.blue.shade600,
      Colors.blue.shade500,
      Colors.blue.shade400,
      Colors.blue.shade300,
      Colors.blue.shade200,
      Colors.blue.shade100,
      Colors.blue[50],
    ];

    var proportions = <double>[0];
    double top = 100.0;
    int count = 0;
    for (var country in _countryWiseReports) {
      var percentage = country.confirmed * 100 / _report.confirmed;
      if (percentage < 3 || count == 10) {
        break;
      }
      topReports.add(country);
      proportions.add(proportions.last + percentage / 100);
      proportions.add(proportions.last);

      barStacks.add(BarChartRodStackItem(
        top,
        top - percentage,
        colors[count],
      ));
      count++;
      top -= percentage;
    }
    proportions.add(1);
    _topCountries = topReports;
    _barStackProportions = proportions;

    _barChartStack = barStacks;
  }

  @override
  void dispose() {
    _isAlive = false;
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
