import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:statscov/models/api/coordinates.dart';

import 'package:statscov/models/api/country.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/covid_compiled/reports.dart';
import 'package:statscov/models/api/covid_minified/minified_report.dart';
import 'package:statscov/services/http_response_handler_service.dart';

class CovidApiService {
  const CovidApiService();

  final _reportsApiAuthority = 'jerilmj.github.io';
  final _reportsApiUnencodedPath = '/covid19-compiled/reports.json';

  final _countriesApiUrl = 'jerilmj.github.io';
  final _countriesApiUnencodedPath = '/covid19-compiled/countries.json';

  final _orderedReportsAuthority = 'jerilmj.github.io';
  final _orderedReportsUnencodedPath = '/covid19-compiled/ordered.json';

  final _worldwideReportsAuthority = 'jerilmj.github.io';
  final _worldwideReportsUnencodedPath = '/covid19-compiled/worldwide.json';

  final _minifiedReportAuthority = 'pomber.github.io';
  final _minifiedReportUnencodedPath = '/covid19/timeseries.json';

  final _httpResponseHandlerService = const HttpResponseHandlerService();

  Future<List<Country>> getCountriesList() async {
    final uri = Uri.https(_countriesApiUrl, _countriesApiUnencodedPath);

    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final parsed = await compute(parseCountries, response.body);

    return parsed.map((p) => Country.fromJson(p)).toList();
  }

  static List<Map> parseCountries(String responseBody) {
    final data = json.decode(responseBody);

    final List<Country> countries = [];

    data.forEach((name, details) {
      countries.add(
        Country(
          name,
          details['iso3'],
          Coordinates(
            details['coordinates']['lat'] * 1.0,
            details['coordinates']['long'] * 1.0,
          ),
        ),
      );
    });

    countries.sort((c1, c2) => c1.countryName.compareTo(c2.countryName));
    return countries.map((c) => c.toJson()).toList();
  }

  Future<Reports> getAllLatestReports() async {
    final uri = Uri.https(_reportsApiAuthority, _reportsApiUnencodedPath);

    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final parsed = await compute(parseLatestReports, response.body);

    return Reports.fromJson(parsed);
  }

  static Map<String, dynamic> parseLatestReports(String responseBody) {
    final data = json.decode(responseBody);

    return Reports.fromMap(data).toJson();
  }

  Future<MinifiedReport> getAllReports() async {
    final uri =
        Uri.https(_minifiedReportAuthority, _minifiedReportUnencodedPath);
    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final parsed = await compute(parseMinifiedReport, response.body);

    return MinifiedReport.fromJson(parsed);
  }

  static Map<String, dynamic> parseMinifiedReport(String responseBody) {
    final data = json.decode(responseBody);
    MinifiedReport report = MinifiedReport.fromJson(data);

    return report.toJson();
  }

  Future<Map<String, List<Report>>> getOrderedReports() async {
    final uri =
        Uri.https(_orderedReportsAuthority, _orderedReportsUnencodedPath);
    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final parsed = json.decode(response.body);

    return Map<String, List<Report>>.from(parsed.map((date, reports) =>
        MapEntry(
            date,
            List<Report>.from(
                reports.map((report) => Report.fromMap(report)).toList()))));
  }

  Future<Map<String, Report>> getWorldwideReports() async {
    final uri =
        Uri.https(_worldwideReportsAuthority, _worldwideReportsUnencodedPath);
    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final parsed = json.decode(response.body);
    print(parsed);

    return Map<String, Report>.from(
        parsed.map((date, report) => MapEntry(date, Report.fromMap(report))));
  }
}
