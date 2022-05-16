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
  final Uint8List receiptPdf;

  @HiveField(3)
  final DateTime receiptTime;

  @HiveField(4)
  final int receiptPrice;

  @HiveField(5)
  final int receiptDiscount;

  @HiveField(6)
  final int receiptNetPrice;

  @HiveField(7)
  Uint8List? reportPdf;

  @HiveField(8)
  DateTime? reportTime;

  PatientVisiting(this.patientId, this.reportsSelected, this.receiptPdf, this.receiptTime, this.receiptPrice,
      this.receiptDiscount, this.receiptNetPrice,
      [this.reportPdf, this.reportTime]);
}
