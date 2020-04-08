import 'package:country_code/country_code.dart';

class Report {
  final String countryName;
  final String countryFlag;
  final String date;
  final int confirmed;
  final int deaths;
  final int recovered;
  final int confirmedDiff;
  final int deathsDiff;
  final int recoveredDiff;
  final int active;
  final int activeDiff;
  final double fatalityRate;

  Report(
    this.countryName,
    this.countryFlag,
    this.date,
    this.confirmed,
    this.recovered,
    this.deaths,
    this.confirmedDiff,
    this.recoveredDiff,
    this.deathsDiff,
    this.active,
    this.activeDiff,
    this.fatalityRate,
  );

  factory Report.fromMapListIsoDate(List<Map> data, String iso, String date) {
    int confirmed = 0,
        deaths = 0,
        recovered = 0,
        confirmedDiff = 0,
        deathsDiff = 0,
        recoveredDiff = 0,
        active = 0,
        activeDiff = 0;

    double fatalityRate = 0.0;

    data.forEach((entry) {
      confirmed += entry['confirmed'];
      deaths += entry['deaths'];
      recovered += entry['recovered'];
      confirmedDiff += entry['confirmed_diff'];
      deathsDiff += entry['deaths_diff'];
      recoveredDiff += entry['recovered_diff'];
      active += entry['active'];
      activeDiff += entry['active_diff'];
      fatalityRate += entry['fatality_rate'];
    });

    return Report(
        data[0]['region']['name'],
        CountryCode.ofAlpha(data[0]['region']['iso']).symbol,
        date,
        confirmed,
        recovered,
        deaths,
        confirmedDiff,
        recoveredDiff,
        deathsDiff,
        active,
        activeDiff,
        fatalityRate);
  }

  @override
  String toString() {
    return 'Report for ${this.date}\n'
        '--------------------------------------------\n'
        'Confirmed           : ${this.confirmed}\n'
        'Deaths              : ${this.deaths}\n'
        'Recovered           : ${this.recovered}\n'
        'Confirmed Difference: ${this.confirmedDiff}\n'
        'Deaths Difference   : ${this.deathsDiff}\n'
        'Recovered Difference: ${this.recoveredDiff}\n'
        'Active              : ${this.active}\n'
        'Active Difference   : ${this.activeDiff}\n'
        'Fatality Rate       : ${this.fatalityRate}\n';
  }
}
