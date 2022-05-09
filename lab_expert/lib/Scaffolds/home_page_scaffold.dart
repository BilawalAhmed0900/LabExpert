import 'package:flutter/material.dart';
import 'package:lab_expert/Scaffolds/edit_reports.dart';
import 'package:lab_expert/Scaffolds/finalize_reports_scaffold.dart';
import 'package:lab_expert/Scaffolds/search_patient.dart';
import 'package:lab_expert/Scaffolds/view_finalized_reports.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';

import '../Scaffolds/add_patient.dart';
import '../Scaffolds/login_scaffold.dart';
import '../Scaffolds/register_user_scaffold.dart';

class HomePageScaffold extends StatelessWidget {
  final bool isAdmin;

  const HomePageScaffold({Key? key, required this.isAdmin}) : super(key: key);

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

  void _customizeReportLayout(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const EditReportsLayout();
    }));
  }

  void _searchPatient(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return const SearchPatientScaffold();
      }),
    );
  }

  void _finalizeReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return const FinalizeReportsScaffold();
      }),
    );
  }

  void _viewFinalizeReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return const ViewFinalizedReportsScaffold();
      }),
    );
  }
}
