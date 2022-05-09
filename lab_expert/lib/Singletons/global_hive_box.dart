import 'package:hive/hive.dart';
import 'package:lab_expert/HiveEntities/patient.dart';
import 'package:lab_expert/HiveEntities/patient_visiting.dart';
import 'package:lab_expert/HiveEntities/report_template.dart';

import '../HiveEntities/user.dart';

class GlobalHiveBox {
  static Box<User>? adminUserBox;
  static Box<User>? regularUserBox;
  static Box<Patient>? patientsBox;
  static Box<ReportTemplate>? reportTemplateBox;
  static Box<PatientVisiting>? patientReportsBox;
}