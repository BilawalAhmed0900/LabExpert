// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_visiting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientVisitingAdapter extends TypeAdapter<PatientVisiting> {
  @override
  final int typeId = 4;

  @override
  PatientVisiting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientVisiting(
      fields[0] as int,
      (fields[1] as Map).cast<String, bool>(),
      fields[2] as Uint8List?,
      fields[3] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, PatientVisiting obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.patientId)
      ..writeByte(1)
      ..write(obj.reportsSelected)
      ..writeByte(2)
      ..write(obj.receiptPdf)
      ..writeByte(3)
      ..write(obj.reportPdf);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientVisitingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
