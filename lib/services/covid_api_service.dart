import 'dart:convert';
import 'package:country_code/country_code.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import 'package:statscov/models/country.dart';
import 'package:statscov/models/report.dart';
import 'package:statscov/services/http_response_handler_service.dart';

class CovidApiService {
  final _apiAutority = 'covid-api.com';
  final _regionsUnencodedPath = '/api/regions';
  final _reportsUnencodedPath = '/api/reports';
  final HttpResponseHandlerService _httpResponseHandlerService =
      HttpResponseHandlerService();

  final _dateFormatter = DateFormat('yyyy-MM-dd');

  Future<List<Country>> getCountriesList() async {
    final uri = Uri.https(_apiAutority, _regionsUnencodedPath);
    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final data = json.decode(response.body)['data'];
    final List<Country> countries = [];

    data.forEach((item) {
      countries.add(Country(item['name'], item['iso']));
    });

    countries.sort((c1, c2) => c1.countryName.compareTo(c2.countryName));

    return countries;
  }

  Future<Report> getReportForIsoCode(String iso) async {
    iso = CountryCode.parse(iso).alpha3;
    var date = DateTime.now();
    var data;

    try {
      data = await _getDataForDate(date, iso);
      int i = 0;
      while (data.isEmpty && i <= 10) {
        i++;
        date = date.subtract(Duration(days: 1));
        data = await _getDataForDate(date, iso);
      }
    } catch (e) {
      throw e;
    }

    Report report =
        Report.fromMapListIsoDate(data, iso, _dateFormatter.format(date));
    return report;
  }

  Future<List<Map>> _getDataForDate(DateTime date, String iso) async {
    iso = CountryCode.parse(iso).alpha3;
    final formattedDate = _dateFormatter.format(date);

    final uri = Uri.https(_apiAutority, _reportsUnencodedPath,
        {'date': formattedDate, 'iso': iso});

    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final data =
        (json.decode(response.body)['data'] as List<dynamic>).cast<Map>();

    return data;
  }
}
