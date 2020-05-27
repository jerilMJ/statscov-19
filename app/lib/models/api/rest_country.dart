import 'package:hive/hive.dart';

part 'rest_country.g.dart';

/// Api model for api request made to:
///
/// https://restcountries.eu/rest/v2/alpha/[iso]
@HiveType(typeId: 2)
class RestCountry {
  const RestCountry(this.name, this.alpha2Code, this.alpha3Code, this.region,
      this.subRegion, this.population, this.latLong, this.flagUrl);

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String alpha2Code;
  @HiveField(2)
  final String alpha3Code;
  @HiveField(3)
  final String region;
  @HiveField(4)
  final String subRegion;
  @HiveField(5)
  final int population;
  @HiveField(6)
  final List<double> latLong;
  @HiveField(7)
  final String flagUrl;

  factory RestCountry.fromMap(Map data) {
    return RestCountry(
      data['name'],
      data['alpha2Code'],
      data['alpha3Code'],
      data['region'],
      data['subRegion'],
      data['population'],
      data['latLong'],
      data['flag'],
    );
  }
}
