import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Constants {
  static const String _hiveKey = "bf06c232-6291-432a-a548-8e4d8428b65e";
  static const String _regularUsersVaultKey = "regular_users";
  static const String _adminUsersVaultKey = "admin_users";
  static const String _patientVaultKey = "patients";
  static const String _reportTemplateVaultKey = "report_template";
  static const String _patientReportsVaultKey = "patient_reports";

  static const String _secretFileName = "4fd16ce1-f972-4dfd-bd7c-d23da490cced";
  static const String _logFileName = "lab-expert.log";

  static const String _appDirectoryUnderSupport = "lab-expert";

  static String get hiveKey => _hiveKey;
  static String get regularUsersVaultKey => _regularUsersVaultKey;
  static String get adminUsersVaultKey => _adminUsersVaultKey;
  static String get patientVaultKey => _patientVaultKey;
  static String get reportTemplateVaultKey => _reportTemplateVaultKey;
  static String get patientReportsVaultKey => _patientReportsVaultKey;

  static String get secretFileName => _secretFileName;
  static String get logFileName => _logFileName;

  static String get appDirectoryUnderSupport => _appDirectoryUnderSupport;

  static String get _footerStringV1 {
    return base64Encode(utf8.encode("Report generated by Lab Expert, ~uwu~"));
  }

  static String get _footerStringV2 {
    return base64Encode(utf8.encode("Report generated by Lab Expert, ~uwu`"));
  }

  static Future<String> get footerString async {
    const String versionFindingFile = "empty";
    if (File(path.join((await getApplicationSupportDirectory()).path, _appDirectoryUnderSupport, versionFindingFile)).existsSync()) {
      return _footerStringV1;
    }

    return _footerStringV2;
  }
}