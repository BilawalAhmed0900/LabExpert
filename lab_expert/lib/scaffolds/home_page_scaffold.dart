import 'package:flutter/material.dart';
import 'package:lab_expert/scaffolds/add_patient.dart';
import 'package:lab_expert/scaffolds/login_scaffold.dart';
import 'package:lab_expert/scaffolds/register_user_scaffold.dart';

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
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return LoginScaffold();
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
      return const RegisterUserScaffold(firstPageNoUser: false);
    }));
  }
}
