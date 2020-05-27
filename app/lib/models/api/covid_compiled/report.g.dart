// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final typeId = 1;

  @override
  Report read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Report(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as int,
      fields[5] as int,
      fields[6] as int,
      fields[7] as int,
      fields[10] as int,
      fields[11] as int,
      fields[12] as double,
      active: fields[8] as int,
      activeDiff: fields[9] as int,
      coordinates: fields[13] as Coordinates,
      area: fields[14] as num,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.countryName)
      ..writeByte(1)
      ..write(obj.iso)
      ..writeByte(2)
      ..write(obj.countryFlag)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.confirmed)
      ..writeByte(5)
      ..write(obj.confirmedDiff)
      ..writeByte(6)
      ..write(obj.deaths)
      ..writeByte(7)
      ..write(obj.deathsDiff)
      ..writeByte(8)
      ..write(obj.active)
      ..writeByte(9)
      ..write(obj.activeDiff)
      ..writeByte(10)
      ..write(obj.recovered)
      ..writeByte(11)
      ..write(obj.recoveredDiff)
      ..writeByte(12)
      ..write(obj.fatalityRate)
      ..writeByte(13)
      ..write(obj.coordinates)
      ..writeByte(14)
      ..write(obj.area);
  }
}
