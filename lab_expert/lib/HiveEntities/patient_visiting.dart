import 'dart:typed_data';

import 'package:hive/hive.dart';
part 'patient_visiting.g.dart';

@HiveType(typeId: 4)
class PatientVisiting extends HiveObject {
  @HiveField(0)
  final int patientId;

  @HiveField(1)
  final Map<String, bool> reportsSelected;

  @HiveField(2)
  Uint8List? receiptPdf;

  @HiveField(3)
  Uint8List? reportPdf;

  PatientVisiting(this.patientId, this.reportsSelected, [this.receiptPdf, this.reportPdf]);
}
