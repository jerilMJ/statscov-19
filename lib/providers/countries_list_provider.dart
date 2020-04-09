import 'package:country_code/country_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:statscov/models/country.dart';
import 'package:statscov/services/covid_api_service.dart';

enum CountriesListProviderState { loading, error, ready }

class CountriesListProvider with ChangeNotifier {
  final _covidApiService = CovidApiService();
  List<Country> _countriesList;
  CountriesListProviderState _state;
  TypeError _error;
  List<String> _unkonwnIsos = [
    'GGY-JEY',
    'cruise',
    'NA-SHIP-DP',
    'RKS',
    'Others',
  ];

  void _setState(CountriesListProviderState state) {
    _state = state;
    notifyListeners();
  }

  CountriesListProvider() {
    tryFetching();
  }

  List<Country> get countriesList => _countriesList;
  CountriesListProviderState get state => _state;
  TypeError get error => _error;

  void tryFetching() {
    _countriesList = null;
    _setState(CountriesListProviderState.loading);
    _covidApiService.getCountriesList().then((countries) {
      _countriesList = countries
          .where((country) => !(_unkonwnIsos.contains(country.isoCode)))
          .toList();

      _setState(CountriesListProviderState.ready);
    }).catchError((e) {
      _error = e;
      _setState(CountriesListProviderState.error);
    });
  }
}
