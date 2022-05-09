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
  Uint8List receiptPdf;

  @HiveField(3)
  DateTime receiptTime;

  @HiveField(4)
  Uint8List? reportPdf;

  @HiveField(5)
  DateTime? reportTime;

  PatientVisiting(this.patientId, this.reportsSelected, this.receiptPdf, this.receiptTime, [this.reportPdf, this.reportTime]);
}
