// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportTemplateAdapter extends TypeAdapter<ReportTemplate> {
  @override
  final int typeId = 2;

  @override
  ReportTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportTemplate(
      fields[0] as String,
      fields[1] as String,
      (fields[2] as Map).cast<String, ReportSectionType>(),
      (fields[3] as Map).cast<String, String>(),
      (fields[4] as Map).cast<String, int>(),
      (fields[5] as Map).cast<String, String>(),

      fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReportTemplate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportName)
      ..writeByte(2)
      ..write(obj.fieldTypes)
      ..writeByte(3)
      ..write(obj.fieldNormals)
      ..writeByte(4)
      ..write(obj.prices)
      ..writeByte(5)
      ..write(obj.units)
      ..writeByte(6)
      ..write(obj.isHead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
