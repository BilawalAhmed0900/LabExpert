import 'package:hive/hive.dart';
import 'package:lab_expert/HiveEntities/patient.dart';

import '../HiveEntities/user.dart';

class GlobalHiveBox {
  static Box<User>? adminUserBox;
  static Box<User>? regularUserBox;
  static Box<Patient>? patientsBox;
}