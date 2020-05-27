import 'package:hive/hive.dart';
import 'package:statscov/models/api/coordinates.dart';

part 'country.g.dart';

/// Api model used in most of the api requests.
///
/// Stores country details just enough for identification.
@HiveType(typeId: 7)
class Country {
  const Country(this.countryName, this.isoCode, this.coordinates);

  @HiveField(0)
  final String countryName;
  @HiveField(1)
  final String isoCode;
  @HiveField(2)
  final Coordinates coordinates;

  Map<String, dynamic> toJson() {
    return {
      'country_name': this.countryName,
      'iso_code': this.isoCode,
      'coordinates': this.coordinates.toJson(),
    };
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(json['country_name'], json['iso_code'],
        Coordinates.fromMap(json['coordinates']));
  }
}
