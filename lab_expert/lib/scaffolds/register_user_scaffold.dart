import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lab_expert/Constants/constants.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';
import 'package:lab_expert/scaffolds/login_scaffold.dart';

import '../Functions/cast_array.dart';
import '../Functions/show_alert_box.dart';
import '../Functions/username_password_sha256.dart';
import '../HiveEntities/user.dart';

class RegisterUserScaffold extends StatefulWidget {
  final bool firstPageNoUser;

  const RegisterUserScaffold({Key? key, required this.firstPageNoUser}) : super(key: key);

  @override
  State<RegisterUserScaffold> createState() => _RegisterUserScaffoldState();
}

class _RegisterUserScaffoldState extends State<RegisterUserScaffold> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.firstPageNoUser;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Please register a user who will administer the database"),
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
                          obscureText: true,
                          textAlign: TextAlign.right,
                          controller: _passwordController,
                          maxLength: 32,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Make Admin:   "),
                      Checkbox(
                        value: value,
                        onChanged: (bool? newValue) => setState(() {
                          value = (widget.firstPageNoUser) ? true : newValue!;
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _registerUser(context);
                      },
                      child: const Text("Register"),
                    ),
                  ),
                ],
              ),
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
        return LoginScaffold();
      }));
    }
  }
}
