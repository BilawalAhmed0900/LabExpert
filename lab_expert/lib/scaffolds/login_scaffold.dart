import 'package:flutter/material.dart';
import 'package:lab_expert/Constants/constants.dart';
import 'package:lab_expert/Functions/show_alert_box.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';
import 'package:lab_expert/scaffolds/home_page_scaffold.dart';

import '../Functions/cast_array.dart';
import '../Functions/username_password_sha256.dart';
import '../HiveEntities/user.dart';

class LoginScaffold extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Please login with a registered user"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Username:   "),
                  SizedBox(
                    width: screenWidth * 0.75,
                    child: TextField(
                      textAlign: TextAlign.right,
                      controller: _usernameController,
                      maxLength: 32,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Password:   "),
                  SizedBox(
                    width: screenWidth * 0.75,
                    child: TextField(
                      obscuringCharacter: '*',
                      textAlign: TextAlign.right,
                      obscureText: true,
                      controller: _passwordController,
                      maxLength: 32,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _loginUser(context);
                },
                child: const Text("Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginUser(BuildContext context) {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String sha256d = sha256UsernamePassword(username, password);

    bool isAdmin = GlobalHiveBox.adminUserBox!.values.where((element) {
      return (element as User).hash == sha256d;
    }).isNotEmpty;

    bool isRegularUser = GlobalHiveBox.regularUserBox!.values.where((element) {
      return (element as User).hash == sha256d;
    }).isNotEmpty;

    if (!isAdmin && !isRegularUser) {
      showAlertBox(context, "Invalid credentials", "Invalid username or password");
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return HomePageScaffold(isAdmin: isAdmin,);
    }));
  }
}
