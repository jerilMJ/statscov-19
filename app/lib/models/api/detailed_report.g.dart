// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detailed_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetailedReportAdapter extends TypeAdapter<DetailedReport> {
  @override
  final typeId = 0;

  @override
  DetailedReport read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetailedReport(
      fields[0] as Report,
      fields[1] as RestCountry,
    );
  }

  @override
  void write(BinaryWriter writer, DetailedReport obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.report)
      ..writeByte(1)
      ..write(obj.country);
  }
}
