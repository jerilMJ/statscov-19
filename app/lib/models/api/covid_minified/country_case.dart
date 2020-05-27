import 'package:hive/hive.dart';

part 'country_case.g.dart';

/// Api sub-model for api requests made to:
///
/// https://pomber.github.io/covid19/timeseries.json.
/// This is used in tandem with MinifiedReport model.
@HiveType(typeId: 4)
class CountryCase {
  const CountryCase(this.date, this.confirmed, this.recovered, this.deaths);

  @HiveField(0)
  final String date;
  @HiveField(1)
  final int confirmed;
  @HiveField(2)
  final int recovered;
  @HiveField(3)
  final int deaths;

  Map<String, dynamic> toJson() {
    return {
      'date': this.date,
      'confirmed': this.confirmed,
      'recovered': this.recovered,
      'deaths': this.deaths,
    };
  }

  factory CountryCase.fromMap(Map data) {
    return CountryCase(
      data['date'],
      data['confirmed'],
      data['recovered'],
      data['deaths'],
    );
  }
}
