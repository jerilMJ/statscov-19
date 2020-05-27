// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_case.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryCaseAdapter extends TypeAdapter<CountryCase> {
  @override
  final typeId = 4;

  @override
  CountryCase read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryCase(
      fields[0] as String,
      fields[1] as int,
      fields[2] as int,
      fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CountryCase obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.confirmed)
      ..writeByte(2)
      ..write(obj.recovered)
      ..writeByte(3)
      ..write(obj.deaths);
  }
}
