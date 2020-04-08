import 'dart:convert';

import 'package:country_code/country_code.dart';
import 'package:http/http.dart' as http;
import 'package:statscov/models/rest_country.dart';
import 'package:statscov/services/http_response_handler.dart';

class CountriesApiService {
  final _apiAuthority = 'restcountries.eu';
  final _countriesUnencodedPath = '/rest/v2/alpha/';
  final HttpResponseHandlerService _httpResponseHandlerService =
      HttpResponseHandlerService();

  Future<RestCountry> getCountryPopulationByIso(String iso) async {
    iso = CountryCode.parse(iso).alpha3.toUpperCase();
    final uri = Uri.https(_apiAuthority, _countriesUnencodedPath + iso);
    final response = await http.get(uri);

    _httpResponseHandlerService.handleResponse(response, uri);

    final data = json.decode(response.body);

    RestCountry restCountry = RestCountry.fromMap(data);

    return restCountry;
  }
}
