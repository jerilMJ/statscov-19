import 'dart:convert';
import 'package:country_code/country_code.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import 'package:statscov/models/country.dart';
import 'package:statscov/models/report.dart';
import 'package:statscov/services/http_response_handler.dart';

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

    _httpResponseHandlerService.handleResponse(response, uri);

    final respBody = json.decode(response.body);

    List<Country> countries;
    final data = respBody['data'];
    countries = [];
    data.forEach((item) {
      countries.add(Country(item['name'], item['iso']));
    });

    countries.sort((c1, c2) => c1.countryName.compareTo(c2.countryName));

    return countries;
  }

  Future<Report> getReportForIsoCode(String iso) async {
    iso = CountryCode.parse(iso).alpha3;
    var date = DateTime.now();

    var data = await getDataForDate(date, iso);

    if (data.length == 0) {
      date = date.subtract(Duration(days: 1));
      data = await getDataForDate(date, iso);
    }

    Report report =
        Report.fromMapListIsoDate(data, iso, _dateFormatter.format(date));

    return report;
  }

  Future<dynamic> getDataForDate(DateTime date, String iso) async {
    iso = CountryCode.parse(iso).alpha3;
    final formattedDate = _dateFormatter.format(date);

    final uri = Uri.https(_apiAutority, _reportsUnencodedPath,
        {'date': formattedDate, 'iso': iso});
    final response = await http.get(uri).catchError((error) => null);

    _httpResponseHandlerService.handleResponse(response, uri);

    var data = json.decode(response.body)['data'];
    return data;
  }
}
