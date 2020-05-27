// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportsAdapter extends TypeAdapter<Reports> {
  @override
  final typeId = 6;

  @override
  Reports read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reports(
      (fields[0] as Map)?.cast<String, Report>(),
    );
  }

  @override
  void write(BinaryWriter writer, Reports obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._reports);
  }
}
