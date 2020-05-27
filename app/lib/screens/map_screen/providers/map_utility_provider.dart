import 'dart:async';

import 'package:flutter/cupertino.dart';

enum MapUtilityProviderState { error, ready }

class MapUtilityProvider with ChangeNotifier {
  MapUtilityProvider(this._lastDate) {
    _isAlive = true;
    _date = _firstDate;
    _prevPercentage = 0.0;
    _totalDays = _lastDate.difference(_firstDate).inDays;
  }

  final DateTime _firstDate = DateTime.parse("2020-01-22");
  MapUtilityProviderState _state;
  DateTime _date;
  DateTime _lastDate;
  Timer _dateIncrementer;
  ValueNotifier<double> _percentageNotifier = ValueNotifier<double>(0.0);
  double _prevPercentage;
  int _totalDays;
  bool _isAlive;

  MapUtilityProviderState get state => _state;
  DateTime get date => _date;
  DateTime get firstDate => _firstDate;
  DateTime get lastDate => _lastDate;
  bool get isIncrementerActive =>
      _dateIncrementer != null ? _dateIncrementer.isActive : false;
  double get percentage => _percentageNotifier.value;
  double get prevPercentage => _prevPercentage;
  int get totalCountries => 182;
  DateTime get allListedCountriesInfectedOn => DateTime.parse("2020-04-10");
  ValueNotifier<double> get percentageNotifier => _percentageNotifier;

  void _setState(MapUtilityProviderState state) {
    _state = state;
    if (_isAlive) notifyListeners();
  }

  void setDate(DateTime date) {
    if (date.compareTo(_lastDate) > 0) {
      stopDateIncrementer();
      return;
    }

    if (date.compareTo(_firstDate) < 0) {
      return;
    }

    _date = date;
    var totalDays = _lastDate.difference(_date).inDays;
    _prevPercentage = _percentageNotifier.value;
    _percentageNotifier.value = (_totalDays - totalDays) / _totalDays;
    _setState(MapUtilityProviderState.ready);
  }

  void runDateIncrementer() {
    _dateIncrementer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      setDate(_date.add(const Duration(days: 1)));
    });
    _setState(MapUtilityProviderState.ready);
  }

  void stopDateIncrementer() {
    _dateIncrementer?.cancel();
    _setState(MapUtilityProviderState.ready);
  }

  void toggleDateIncrementer() {
    if (_dateIncrementer != null) {
      if (_dateIncrementer.isActive) {
        stopDateIncrementer();
      } else {
        runDateIncrementer();
      }
    } else {
      runDateIncrementer();
    }
  }

  void goToLastEntry() {
    if (_dateIncrementer != null) {
      if (_dateIncrementer.isActive) {
        _dateIncrementer.cancel();
      }
    }
    setDate(_lastDate);
  }

  void resetDate() {
    if (_dateIncrementer != null) {
      if (_dateIncrementer.isActive) {
        _dateIncrementer.cancel();
      }
    }
    setDate(DateTime.parse('2020-01-22'));
  }

  void nextDate() {
    setDate(_date.add(const Duration(days: 1)));
  }

  void prevDate() {
    setDate(_date.subtract(const Duration(days: 1)));
  }

  @override
  void dispose() {
    _isAlive = false;
    super.dispose();
  }
}
