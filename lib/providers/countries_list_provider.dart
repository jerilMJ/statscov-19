import 'package:flutter/cupertino.dart';
import 'package:statscov/models/country.dart';
import 'package:statscov/services/covid_api_service.dart';

enum CountriesListProviderState { loading, error, ready }

class CountriesListProvider with ChangeNotifier {
  final _covidApiService = CovidApiService();
  List<Country> _countriesList;
  CountriesListProviderState _state;
  Exception _exception;

  void _setState(CountriesListProviderState state) {
    _state = state;
    notifyListeners();
  }

  CountriesListProvider() {
    tryFetching();
  }

  List<Country> get countriesList => _countriesList;
  CountriesListProviderState get state => _state;
  Exception get exception => _exception;

  void tryFetching() {
    _countriesList = null;
    _setState(CountriesListProviderState.loading);
    _covidApiService.getCountriesList().then((countries) {
      _countriesList = countries;
      _setState(CountriesListProviderState.ready);
    }).catchError((e) {
      _exception = e;
      _setState(CountriesListProviderState.error);
    });
  }
}
