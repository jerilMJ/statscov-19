import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:statscov/models/api/covid_minified/country_case.dart';

part 'minified_report.g.dart';

/// Api sub-model for api requests made to:
///
/// https://pomber.github.io/covid19/timeseries.json.
/// This is used in tandem with CountryCase model.
@HiveType(typeId: 5)
class MinifiedReport {
  MinifiedReport(this.cases);

  @HiveField(0)
  Map<String, List<CountryCase>> cases;

  factory MinifiedReport.fromJson(Map data) {
    DateFormat df = DateFormat('yyyy-MM-dd');

    try {
      Map<String, List<CountryCase>> cases = {};

      data.forEach((name, infos) {
        cases[name] = [];
        infos.forEach((info) {
          String formattedDate;
          List<int> contents = [];
          info['date'].split('-').forEach((content) {
            contents.add(int.parse(content));
          });
          formattedDate =
              df.format(DateTime(contents[0], contents[1], contents[2]));

          cases[name].add(CountryCase(formattedDate, info['confirmed'],
              info['recovered'], info['deaths']));
        });
      });

      return MinifiedReport(cases);
    } catch (e) {
      throw e;
    }
  }

  /// Getter function
  List<CountryCase> getCases(String country) {
    try {
      return List<CountryCase>.from(cases[country]);
    } catch (e) {
      throw e;
    }
  }

  @override
  String toString() {
    List<String> lines = [];
    cases.forEach((country, info) {
      lines.add('$country: [');
      info.forEach((i) {
        lines.add('---------------------------------');
        lines.add('\tdate: ${i.date}');
        lines.add('\tconfirmed: ${i.confirmed}');
        lines.add('\trecovered: ${i.recovered}');
        lines.add('\tdeaths: ${i.deaths}');
        lines.add('---------------------------------');
      });
      lines.add(']');
    });

    return lines.join('\n');
  }

  factory MinifiedReport.fromMap(Map data) {
    var result = data.map((name, cCases) {
      final list = cCases.toList();

      return MapEntry(
        name,
        List<CountryCase>.from(list
            .asMap()
            .map((i, cCase) {
              return MapEntry(i, CountryCase.fromMap(cCase));
            })
            .values
            .toList()),
      );
    });
    result = Map<String, List<CountryCase>>.from(result);

    return MinifiedReport(result);
  }

  Map<String, dynamic> toJson() {
    final json = cases.map(
      (name, cCase) => MapEntry(
        name,
        cCase
            .map(
              (c) => c.toJson(),
            )
            .toList(),
      ),
    );

    // json.forEach((k, v) {
    //   print('$k: ${v.sublist(0, 5)}');
    //   print('\n\n\n\n');
    // });

    return json;
  }
}
