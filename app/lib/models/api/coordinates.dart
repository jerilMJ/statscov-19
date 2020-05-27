import 'package:hive/hive.dart';

part 'coordinates.g.dart';

/// Minimal replacement for the deprecated LatLng class.
@HiveType(typeId: 3)
class Coordinates {
  const Coordinates(this.lat, this.long);

  @HiveField(0)
  final num lat;
  @HiveField(1)
  final num long;

  @override
  String toString() {
    return '{'
        'latitude: ${this.lat},'
        'longitude: ${this.long}'
        '}';
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': this.lat,
      'long': this.long,
    };
  }

  factory Coordinates.fromMap(Map data) {
    return Coordinates(
      data['lat'],
      data['long'],
    );
  }
}
