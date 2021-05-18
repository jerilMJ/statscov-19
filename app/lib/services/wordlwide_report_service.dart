import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/services/http_response_handler_service.dart';

class WorldwideReportService {
  WorldwideReportService();

  final _authority = 'covid-api.com';
  final _unencodedPath = '/api/reports/total';
  final _httpResponseHandlerService = const HttpResponseHandlerService();

  Future<Report> getWorldwideReport() async {
    var uri = Uri.https(
      _authority,
      _unencodedPath,
    );

    final response = await http.get(uri);

    try {
      _httpResponseHandlerService.handleResponse(response, uri);
    } catch (e) {
      throw e;
    }

    final parsed = await compute(parseWorldwideReport, response.body);

    return Report.fromMap(parsed);
  }

  static Map<String, dynamic> parseWorldwideReport(String responseBody) {
    return Report.worldwide(json.decode(responseBody)['data']).toJson();
  }
}
