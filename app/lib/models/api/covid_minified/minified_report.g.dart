// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minified_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MinifiedReportAdapter extends TypeAdapter<MinifiedReport> {
  @override
  final typeId = 5;

  @override
  MinifiedReport read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MinifiedReport(
      (fields[0] as Map)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List)?.cast<CountryCase>())),
    );
  }

  @override
  void write(BinaryWriter writer, MinifiedReport obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.cases);
  }
}
