import 'package:flutter/material.dart';
import 'package:lab_expert/Scaffolds/edit_reports.dart';

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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const RegisterUserScaffold(firstPageNoUser: true);
    }));
  }

  void _customizeReportLayout(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const EditReportsLayout();
    }));
  }
}
