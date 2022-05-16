import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:desktop_window/desktop_window.dart';
import './HiveEntities/patient.dart';
import './HiveEntities/patient_visiting.dart';
import './HiveEntities/report_section_type.dart';
import './HiveEntities/report_template.dart';
import './HiveEntities/user.dart';

import './scaffolds/login_scaffold.dart';
import './scaffolds/register_user_scaffold.dart';

import './Constants/constants.dart';
import './Singletons/global_hive_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   //await DesktopWindow.setMaxWindowSize(const Size(1920, 1080));
  //   //await DesktopWindow.setMinWindowSize(const Size(720, 505));
  //   await DesktopWindow.setWindowSize(const Size(720, 505));
  // }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  await Hive.initFlutter();

  // const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  //
  // String? hiveKey = await secureStorage.read(key: Constants.hiveKey);
  // if (hiveKey == null) {
  //   hiveKey = base64Encode(Hive.generateSecureKey());
  //   await secureStorage.write(key: Constants.hiveKey, value: hiveKey);
  // }

  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(ReportTemplateAdapter());
  Hive.registerAdapter(ReportSectionTypeAdapter());
  Hive.registerAdapter(PatientVisitingAdapter());

  GlobalHiveBox.adminUserBox = await Hive.openBox<User>(Constants.adminUsersVaultKey,
      /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/);

  GlobalHiveBox.regularUserBox = await Hive.openBox<User>(Constants.regularUsersVaultKey,
      /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/);

  GlobalHiveBox.patientsBox = await Hive.openBox<Patient>(Constants.patientVaultKey,
      /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/);

  GlobalHiveBox.reportTemplateBox = await Hive.openBox<ReportTemplate>(Constants.reportTemplateVaultKey,
    /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/);

  GlobalHiveBox.patientReportsBox = await Hive.openBox<PatientVisiting>(Constants.patientReportsVaultKey,
    /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/);

  if (GlobalHiveBox.adminUserBox!.isEmpty && GlobalHiveBox.regularUserBox!.isEmpty) {
    runApp(MaterialApp(
      home: const RegisterUserScaffold(firstPageNoUser: true, isAdmin: true),
      theme: ThemeData.dark(),
    ));
  } else {
    runApp(MaterialApp(
      home: const LoginScaffold(),
      theme: ThemeData.dark(),
    ));
  }
}
