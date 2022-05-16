import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../Singletons/global_hive_box.dart';
import '../Scaffolds/login_scaffold.dart';
import '../Functions/show_alert_box.dart';
import '../Functions/username_password_sha256.dart';
import '../HiveEntities/user.dart';

class RegisterUserScaffold extends StatefulWidget {
  final bool firstPageNoUser;
  final bool isAdmin;

  const RegisterUserScaffold({Key? key, required this.firstPageNoUser, required this.isAdmin}) : super(key: key);

  @override
  State<RegisterUserScaffold> createState() => _RegisterUserScaffoldState();
}

class _RegisterUserScaffoldState extends State<RegisterUserScaffold> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool value = true;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 505));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: screenHeight * 0.55,
                  width: screenWidth * 0.20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("Username: "),
                      Text("Password: "),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.55,
                  width: screenWidth * 0.75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          textAlign: TextAlign.right,
                          controller: _usernameController,
                          maxLength: 32,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          obscuringCharacter: '*',
                          obscureText: true,
                          textAlign: TextAlign.right,
                          controller: _passwordController,
                          maxLength: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            (widget.isAdmin)
            ?
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Make Admin: "),
                      Switch(
                        value: value,
                        onChanged: (newValue) {
                          setState(() {
                            value = newValue;
                          });
                        },
                      )
                    ],
                  ),
                )

            : Container(),
            ElevatedButton(
              onPressed: () {
                _registerUser(context);
              },
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  void _registerUser(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (password.length < 8) {
      showAlertBox(context, "Minimum Length Error", "Password must be at-least of 8 characters");
      return;
    }

    String sha256d = sha256UsernamePassword(username, password);
    User person = User(sha256d);

    Box boxToCheck;
    if (value) {
      boxToCheck = GlobalHiveBox.adminUserBox!;
    } else {
      boxToCheck = GlobalHiveBox.regularUserBox!;
    }

    if (boxToCheck.values.where((element) {
      return (element as User).hash == sha256d;
    }).isNotEmpty) {
      await showAlertBox(context, "Conflict", "User already exists...");
      return;
    }
    boxToCheck.add(person);
    boxToCheck.flush();

    await showAlertBox(context, "Successful", "User has been created");
    _usernameController.text = "";
    _passwordController.text = "";

    if (widget.firstPageNoUser) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const LoginScaffold();
      }));
    }
  }
}
