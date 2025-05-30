import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';
import './HiveEntities/patient.dart';
import './HiveEntities/patient_visiting.dart';
import './HiveEntities/report_section_type.dart';
import './HiveEntities/report_template.dart';
import './HiveEntities/user.dart';

import './Scaffolds/login_scaffold.dart';
import './Scaffolds/register_user_scaffold.dart';

import './Constants/constants.dart';
import './Singletons/global_hive_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String remotePath = path.join((await getApplicationSupportDirectory()).path, Constants.appDirectoryUnderSupport);
  if (!Directory(remotePath).existsSync()) {
    Directory(remotePath).createSync();
  }

  if (!Platform.isAndroid && !Platform.isIOS) {
    if (!File(path.join((await getDownloadsDirectory())!.path, Constants.secretFileName)).existsSync()) {
      File(path.join((await getApplicationDocumentsDirectory()).path, Constants.logFileName)).writeAsStringSync(
        base64Encode(
          utf8.encode("[${DateTime.now().toUtc()}] Cannot open secret file ${File(path.join(remotePath, Constants.secretFileName)).path}"),
        ),
        mode: FileMode.append,
        flush: true,
      );
      runApp(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Error has been written to the log"),
                  ],
                )
              ],
            ),
          ),
        ),
      );
      return;
    }
  }

  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   //await DesktopWindow.setMaxWindowSize(const Size(1920, 1080));
  //   //await DesktopWindow.setMinWindowSize(const Size(720, 505));
  //   await DesktopWindow.setWindowSize(const Size(720, 505));
  // }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  Hive.init(remotePath);

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

  GlobalHiveBox.adminUserBox = await Hive.openBox<User>(
    Constants.adminUsersVaultKey, /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/
  );

  GlobalHiveBox.regularUserBox = await Hive.openBox<User>(
    Constants.regularUsersVaultKey, /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/
  );

  GlobalHiveBox.patientsBox = await Hive.openBox<Patient>(
    Constants.patientVaultKey, /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/
  );

  GlobalHiveBox.reportTemplateBox = await Hive.openBox<ReportTemplate>(
    Constants.reportTemplateVaultKey, /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/
  );

  GlobalHiveBox.patientReportsBox = await Hive.openLazyBox<PatientVisiting>(
    Constants.patientReportsVaultKey, /*encryptionCipher: HiveAesCipher(base64Decode(hiveKey))*/
  );

  try {
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
  } catch (e) {
    print(e);
    File(path.join((await getApplicationDocumentsDirectory()).path, Constants.logFileName)).writeAsStringSync(
      base64Encode(
        utf8.encode("[${DateTime.now().toUtc()}] $e"),
      ),
      mode: FileMode.append,
      flush: true,
    );
  }
}
