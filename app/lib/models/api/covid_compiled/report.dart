import 'package:hive/hive.dart';
import 'package:statscov/models/api/coordinates.dart';

part 'report.g.dart';

/// Api Model for api requests made to:
///
/// https://covid-api.com/api/reports/total/?date and
/// https://jerilmj.github.io/covid19-compiled/reports.json.
@HiveType(typeId: 1)
class Report {
  const Report(
    this.countryName,
    this.iso,
    this.countryFlag,
    this.date,
    this.confirmed,
    this.confirmedDiff,
    this.deaths,
    this.deathsDiff,
    this.recovered,
    this.recoveredDiff,
    this.fatalityRate, {
    this.active,
    this.activeDiff,
    this.coordinates,
    this.area,
  });

  @HiveField(0)
  final String countryName;
  @HiveField(1)
  final String iso;
  @HiveField(2)
  final String countryFlag;
  @HiveField(3)
  final String date;
  @HiveField(4)
  final int confirmed;
  @HiveField(5)
  final int confirmedDiff;
  @HiveField(6)
  final int deaths;
  @HiveField(7)
  final int deathsDiff;
  @HiveField(8)
  final int active;
  @HiveField(9)
  final int activeDiff;
  @HiveField(10)
  final int recovered;
  @HiveField(11)
  final int recoveredDiff;
  @HiveField(12)
  final double fatalityRate;
  @HiveField(13)
  final Coordinates coordinates;
  @HiveField(14)
  final num area;

  /// Factory for response from https://covid-api.com/api/reports/total/?date.
  factory Report.worldwide(Map data) {
    return Report(
      'Worldwide',
      null,
      null,
      data['date'],
      data['confirmed'],
      data['confirmed_diff'],
      data['deaths'],
      data['deaths_diff'],
      data['recovered'],
      data['recovered_diff'],
      data['fatality_rate'],
      active: data['active'],
      activeDiff: data['active_diff'],
    );
  }

  factory Report.fromMap(Map data) {
    return Report(
      data['country_name'],
      data['iso'],
      data['country_flag'],
      data['date'],
      data['confirmed'],
      data['confirmed_diff'],
      data['deaths'],
      data['deaths_diff'],
      data['recovered'],
      data['recovered_diff'],
      data['fatality_rate'],
      active: data['active'],
      activeDiff: data['active_diff'],
      coordinates: data['coordinates'] != null
          ? Coordinates.fromMap(data['coordinates'])
          : null,
      area: data['area'],
    );
  }

  @override
  String toString() {
    return '{'
        'iso                 : ${this.iso},'
        'name                : ${this.countryName},'
        'flag                : ${this.countryFlag},'
        'date                : ${this.date},'
        'confirmed           : ${this.confirmed},'
        'confirmed_diff      : ${this.confirmedDiff},'
        'deaths              : ${this.deaths},'
        'deaths_diff         : ${this.deathsDiff},'
        'recovered           : ${this.recovered},'
        'recovered_diff      : ${this.recoveredDiff},'
        'active              : ${this.active},'
        'active_diff         : ${this.activeDiff},'
        'fatality_rate       : ${this.fatalityRate},'
        'coordinates         : ${this.coordinates},'
        'area:               : ${this.area}'
        '}';
  }

  Map<String, dynamic> toJson() {
    return {
      'iso': this.iso,
      'country_name': this.countryName,
      'country_flag': this.countryFlag,
      'date': this.date,
      'confirmed': this.confirmed,
      'confirmed_diff': this.confirmedDiff,
      'deaths': this.deaths,
      'deaths_diff': this.deathsDiff,
      'recovered': this.recovered,
      'recovered_diff': this.recoveredDiff,
      'active': this.active,
      'active_diff': this.activeDiff,
      'fatality_rate': this.fatalityRate,
      'coordinates': this.coordinates?.toJson(),
      'area': this.area,
    };
  }
}
