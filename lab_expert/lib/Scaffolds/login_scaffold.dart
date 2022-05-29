import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

import '../Functions/show_alert_box.dart';
import '../Singletons/global_hive_box.dart';
import '../Scaffolds/home_page_scaffold.dart';
import '../Functions/username_password_sha256.dart';
import '../HiveEntities/user.dart';

class LoginScaffold extends StatefulWidget {
  const LoginScaffold({Key? key}) : super(key: key);

  @override
  State<LoginScaffold> createState() => _LoginScaffoldState();
}

class _LoginScaffoldState extends State<LoginScaffold> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
        title: const Text("Sign In"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: screenHeight * 0.7,
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
                  height: screenHeight * 0.7,
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
            ElevatedButton(
              onPressed: () {
                _loginUser(context);
              },
              child: const Text("Sign In"),
            ),
          ],
        ),
      ),
    );
  }

  void _loginUser(BuildContext context) {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String sha256d = sha256UsernamePassword(username, password);

    bool isAdmin = GlobalHiveBox.adminUserBox!.values.where((User element) {
      return element.hash == sha256d;
    }).isNotEmpty;

    bool isRegularUser = GlobalHiveBox.regularUserBox!.values.where((User element) {
      return element.hash == sha256d;
    }).isNotEmpty;

    if (!isAdmin && !isRegularUser) {
      showAlertBox(context, "Invalid credentials", "Invalid username or password");
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return HomePageScaffold(isAdmin: isAdmin, username: username,);
    }));
  }
}
