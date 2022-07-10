import 'package:flutter/material.dart';
import 'package:lab_expert/HiveEntities/report_template.dart';
import 'package:lab_expert/Scaffolds/change_password.dart';
import 'package:lab_expert/Scaffolds/edit_reports.dart';
import 'package:lab_expert/Scaffolds/finalize_reports_scaffold.dart';
import 'package:lab_expert/Scaffolds/search_patient.dart';
import 'package:lab_expert/Scaffolds/view_finalized_reports.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';

import '../HiveEntities/report_section_type.dart';
import '../Scaffolds/add_patient.dart';
import '../Scaffolds/login_scaffold.dart';
import '../Scaffolds/register_user_scaffold.dart';

class HomePageScaffold extends StatelessWidget {
  final bool isAdmin;
  final String username;
  final String sha256;

  const HomePageScaffold({Key? key, required this.isAdmin, required this.username, required this.sha256}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: (isAdmin) ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                      return const AddPatientScaffold();
                    }));
                  },
                  child: const Text("Add Patient"),
                ),
                (isAdmin)
                    ? ElevatedButton(
                        onPressed: () {
                          _addUser(context);
                        },
                        child: const Text("Add Users"),
                      )
                    : Container(),
                (isAdmin)
                    ? ElevatedButton(
                        onPressed: () {
                          _customizeReportLayout(context);
                        },
                        child: const Text("Edit Reports"),
                      )
                    : Container(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _searchPatient(context);
                  },
                  child: const Text("Search Patient"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _finalizeReports(context);
                  },
                  child: const Text("Finalize Reports"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _viewFinalizeReports(context);
                  },
                  child: const Text("View Reports"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return ChangePasswordScaffold(username: username, oldSha256: sha256, isAdmin: isAdmin,);
                    }));
                  },
                  child: const Text("Change Password"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return const LoginScaffold();
                    }));
                  },
                  child: const Text("Log out"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return RegisterUserScaffold(firstPageNoUser: false, isAdmin: isAdmin,);
      }),
    );
  }

  void cleanReports(ReportTemplate template) {
    Map<String, ReportSectionType> updatedMap = <String, ReportSectionType>{};

    template.fieldTypes.forEach((key, value) {
      if (GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).isNotEmpty) {
        updatedMap[key] = value;
      }
    });

    template.fieldTypes = updatedMap;
    template.fieldTypes.forEach((key, value) {
      cleanReports(GlobalHiveBox.reportTemplateBox!.values.singleWhere((element) => element.id == key));
    });
  }

  void _customizeReportLayout(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const EditReportsLayout();
    })).then((value) {
      GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).forEach((element) {
        cleanReports(element);
      });
    });
  }

  void _searchPatient(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return SearchPatientScaffold(username: username,);
      }),
    );
  }

  void _finalizeReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return FinalizeReportsScaffold(username: username,);
      }),
    );
  }

  void _viewFinalizeReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ViewFinalizedReportsScaffold(username: username,);
      }),
    );
  }
}
