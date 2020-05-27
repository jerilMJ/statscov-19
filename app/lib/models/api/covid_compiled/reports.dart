import 'package:country_code/country_code.dart';
import 'package:hive/hive.dart';
import 'package:statscov/models/api/coordinates.dart';
import 'package:statscov/models/api/covid_compiled/report.dart';

part 'reports.g.dart';

/// Api Model for api requests made to:
///
/// https://jerilmj.github.io/covid19-compiled/reports.json.
@HiveType(typeId: 6)
class Reports {
  const Reports(this._reports);

  @HiveField(0)
  final Map<String, Report> _reports;

  Map<String, Report> get reports => _reports;

  factory Reports.fromMap(Map data) {
    return Reports(
      data.map(
        (iso, report) {
          return MapEntry(
            iso,
            Report(
              report['name'],
              iso,
              CountryCode.parse(iso).symbol,
              report['date'],
              report['confirmed'],
              report['confirmed_diff'],
              report['deaths'],
              report['deaths_diff'],
              report['recovered'],
              report['recovered_diff'],
              report['fatality_rate'] * 1.0,
              coordinates: Coordinates(
                report['coordinates']['lat'],
                report['coordinates']['long'],
              ),
              area: report['area'],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return _reports.map((iso, report) => MapEntry(iso, report.toJson()));
  }

  factory Reports.fromJson(Map json) {
    return Reports(json.map((iso, report) {
      return MapEntry(
        iso,
        Report.fromMap(report),
      );
    }));
  }

  /// Getter function
  Report getReportForIso(String iso) {
    try {
      return _reports[iso];
    } catch (e) {
      throw e;
    }
  }
}
