import 'dart:isolate';

import 'package:statscov/models/api/coordinates.dart';
import 'package:statscov/models/api/covid_compiled/reports.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/utils/date_utils.dart';

enum NonZeroCoordsProviderState { loading, error, ready }

/// Stores details(coordinates, rest of data is wrong) of countries with
/// atleast 1 case for each date until all 182 countries were infected.
class NonZeroCoordsProvider with ChangeNotifier {
  NonZeroCoordsProvider(
    this._latestReports,
    this._minifiedReport,
    this._firstDate,
    this._lastDate,
    this._totalCountries,
  ) {
    _isAlive = true;
    _totalDays = allListedCountriesInfectedOn.difference(_firstDate).inDays;

    _setState(NonZeroCoordsProviderState.loading);

    createNonZeroReports()
        .then((_) => _setState(NonZeroCoordsProviderState.ready))
        .catchError((e) {
      _error = e;
      _setState(NonZeroCoordsProviderState.error);
    });
  }

  NonZeroCoordsProviderState _state;
  dynamic _error;
  Map<String, Map<String, Coordinates>> _nonZeroCoords = {};

  Reports _latestReports;
  MinifiedReport _minifiedReport;
  DateTime _firstDate;
  DateTime _lastDate;
  int _totalCountries;
  int _totalDays;
  double _prevPercentage;
  ValueNotifier<double> _percentageNotifier = ValueNotifier<double>(0.0);
  bool _isAlive;

  void _setState(NonZeroCoordsProviderState state) {
    _state = state;
    if (_isAlive) notifyListeners();
  }

  NonZeroCoordsProviderState get state => _state;
  dynamic get error => _error;
  Map<String, Map<String, Coordinates>> get nonZeroCoords => _nonZeroCoords;
  double get prevPercentage => _prevPercentage;
  double get percentage => _percentageNotifier.value;
  DateTime get allListedCountriesInfectedOn => DateTime.parse("2020-04-10");
  ValueNotifier<double> get percentageNotifier => _percentageNotifier;

  Future createNonZeroReports() async {
    final nonZeroCoordsBox = await Hive.openBox('nonZeroCoords');

    if (nonZeroCoordsBox.get('data') != null) {
      Map<dynamic, dynamic> dps = nonZeroCoordsBox.get('data');
      _nonZeroCoords = dps.map((k, v) {
        return MapEntry(k, Map<String, Coordinates>.from(v));
      });
    } else {
      _percentageNotifier.value = 0.0;
      _prevPercentage = 0.0;

      final lrJson = _latestReports.toJson();
      final mrJson = _minifiedReport.toJson();

      final receivePort = ReceivePort();

      final subscription = receivePort.listen((date) {
        /// For showing the loading indicator
        var totalDays = allListedCountriesInfectedOn.difference(date).inDays;
        _prevPercentage = _percentageNotifier.value;
        _percentageNotifier.value = (_totalDays - totalDays) / _totalDays;
      });

      _nonZeroCoords = await compute(getAllNonZeroCoords, {
        'lr_json': lrJson,
        'mr_json': mrJson,
        'first_date': _firstDate,
        'last_date': _lastDate,
        'total_countries': _totalCountries,
        'port': receivePort.sendPort,
      });

      /// Communication over
      subscription.cancel();
      receivePort.close();

      nonZeroCoordsBox.put('data', _nonZeroCoords);
    }
  }

  static Future<Map<String, Map<String, Coordinates>>> getAllNonZeroCoords(
      Map<String, dynamic> args) async {
    Map<String, Map<String, Coordinates>> nzCoords = {};
    final lrJson = args['lr_json'];
    final mrJson = args['mr_json'];
    final firstDate = args['first_date'];
    final lastDate = args['last_date'];
    final totalCountries = args['total_countries'];
    final SendPort sendPort = args['port'];

    DateTime date = firstDate;
    final dateUtils = DateUtils();
    while (date != lastDate) {
      final dateString = dateUtils.toDateOnlyString(date);
      nzCoords[dateString] = await getNonZeroCoordsForDate({
        'latest_reports': lrJson,
        'minified_report': mrJson,
        'date': date,
      });

      if (nzCoords[dateString].length == totalCountries) {
        break;
      }

      sendPort.send(date);
      date = date.add(const Duration(days: 1));
    }

    return nzCoords;
  }

  static Future<Map<String, Coordinates>> getNonZeroCoordsForDate(
      Map<String, dynamic> args) async {
    final latestReportsJson = args['latest_reports'];
    final minifiedReportJson = args['minified_report'];
    final date = args['date'];

    final latestReports = Reports((latestReportsJson.map((String iso, report) {
      return MapEntry(
        iso,
        Report.fromMap(report),
      );
    }) as Map)
        .cast<String, Report>());

    final minifiedReport = MinifiedReport.fromMap(minifiedReportJson);

    Map<String, Report> reports = Map.from(latestReports.reports);

    reports.removeWhere((iso, report) {
      var cases = minifiedReport.getCases(report.countryName);

      return cases
              .firstWhere(
                  (countryCase) => DateTime.parse(countryCase.date) == date)
              .confirmed ==
          0;
    });

    return reports.map((_, r) => MapEntry(_, r.coordinates));
  }

  @override
  void dispose() {
    _isAlive = false;
    super.dispose();
  }
}
