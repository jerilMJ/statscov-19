// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryAdapter extends TypeAdapter<Country> {
  @override
  final typeId = 7;

  @override
  Country read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Country(
      fields[0] as String,
      fields[1] as String,
      fields[2] as Coordinates,
    );
  }

  @override
  void write(BinaryWriter writer, Country obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.countryName)
      ..writeByte(1)
      ..write(obj.isoCode)
      ..writeByte(2)
      ..write(obj.coordinates);
  }
}
