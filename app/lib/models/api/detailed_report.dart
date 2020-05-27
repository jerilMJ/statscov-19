import 'package:hive/hive.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';
import 'package:statscov/models/api/rest_country.dart';

part 'detailed_report.g.dart';

/// Helper class for the Stats Screen
///
/// Combines Report class and Country class together
/// for ease of use.
@HiveType(typeId: 0)
class DetailedReport {
  const DetailedReport(this.report, this.country);

  @HiveField(0)
  final Report report;

  @HiveField(1)
  final RestCountry country;
}
