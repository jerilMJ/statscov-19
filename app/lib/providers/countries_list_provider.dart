import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:statscov/models/api/coordinates.dart';
import 'package:statscov/models/api/country.dart';
import 'package:statscov/services/connectivity_service.dart';
import 'package:statscov/services/covid_api_service.dart';
import 'package:statscov/utils/exceptions.dart';

enum CountriesListProviderState { loading, error, ready }

/// Provider for providing list of all countries available.
class CountriesListProvider with ChangeNotifier {
  CountriesListProvider(this._appDocsDirPath) {
    _isAlive = true;
    tryFetching();
    _connectivitySubscription = _connectivityService
        .getConnectivitySubscription((ConnectivityResult data) {
      if (data != ConnectivityResult.none &&
          _state == CountriesListProviderState.error) {
        tryFetching();
      }
    });
  }

  final _covidApiService = const CovidApiService();
  // Service for listening to connectivity status.
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  List<Country> _countriesList;
  CountriesListProviderState _state;
  dynamic _error;
  bool _isAlive;
  String _appDocsDirPath;

  /// List of all countries
  List<Country> get countriesList => _countriesList;
  CountriesListProviderState get state => _state;
  dynamic get error => _error;

  void _setState(CountriesListProviderState state) {
    _state = state;
    // If error, wait for a second so that loading animation plays.
    if (_state == CountriesListProviderState.error) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isAlive) notifyListeners();
      });
    } else {
      if (_isAlive) notifyListeners();
    }
  }

  Future<void> tryFetching() async {
    _setState(CountriesListProviderState.loading);
    tryFetchingCached().then((_) {
      _setState(CountriesListProviderState.ready);
    }).catchError((_) async {
      try {
        _countriesList = null;
        _countriesList = await _covidApiService.getCountriesList();

        await compute(updateCache, {
          'path': _appDocsDirPath,
          'data': _countriesList,
        });

        _setState(CountriesListProviderState.ready);
      } catch (e) {
        _error = e;
        _setState(CountriesListProviderState.error);
      }
    });
  }

  Future<void> tryFetchingCached() async {
    final data = await compute(fetchCache, {
      'path': _appDocsDirPath,
    });

    if (data != null) {
      _countriesList = List<Country>.from(data);
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
      ..registerAdapter(CountryAdapter());

    final countriesListBox = await Hive.openBox('countriesList');

    countriesListBox.put('data', data);

    Hive.close();
  }

  static dynamic fetchCache(Map<String, dynamic> args) async {
    final path = args['path'];
    Hive
      ..init(path)
      ..registerAdapter(CoordinatesAdapter())
      ..registerAdapter(CountryAdapter());

    final countriesListBox = await Hive.openBox('countriesList');
    final data = countriesListBox.get('data');

    Hive.close();

    return data;
  }

  @override
  void dispose() {
    _isAlive = false;
    super.dispose();
    _connectivitySubscription.cancel();
  }
}
