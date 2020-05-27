// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_country.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestCountryAdapter extends TypeAdapter<RestCountry> {
  @override
  final typeId = 2;

  @override
  RestCountry read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RestCountry(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as int,
      (fields[6] as List)?.cast<double>(),
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RestCountry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.alpha2Code)
      ..writeByte(2)
      ..write(obj.alpha3Code)
      ..writeByte(3)
      ..write(obj.region)
      ..writeByte(4)
      ..write(obj.subRegion)
      ..writeByte(5)
      ..write(obj.population)
      ..writeByte(6)
      ..write(obj.latLong)
      ..writeByte(7)
      ..write(obj.flagUrl);
  }
}
