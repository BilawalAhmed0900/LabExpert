// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_section_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportSectionTypeAdapter extends TypeAdapter<ReportSectionType> {
  @override
  final int typeId = 3;

  @override
  ReportSectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportSectionType.field;
      case 1:
        return ReportSectionType.subHeading;
      case 2:
        return ReportSectionType.multipleLineComment;
      default:
        return ReportSectionType.field;
    }
  }

  @override
  void write(BinaryWriter writer, ReportSectionType obj) {
    switch (obj) {
      case ReportSectionType.field:
        writer.writeByte(0);
        break;
      case ReportSectionType.subHeading:
        writer.writeByte(1);
        break;
      case ReportSectionType.multipleLineComment:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
