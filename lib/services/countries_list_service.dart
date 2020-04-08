import 'package:statscov/models/country.dart';
import 'package:statscov/services/covid_api_service.dart';

class CountriesListService {
  final _covidApiService = CovidApiService();

  Future<List<Country>> getAvailableCountries() {
    return _covidApiService.getCountriesList();
  }
}
