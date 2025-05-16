import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lab_expert/Functions/username_password_sha256.dart';
import 'package:lab_expert/HiveEntities/user.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';

import '../Functions/show_alert_box.dart';

class ChangePasswordScaffold extends StatefulWidget {
  final String username;
  final String oldSha256;
  final bool isAdmin;

  const ChangePasswordScaffold({Key? key, required this.username, required this.oldSha256, required this.isAdmin})
      : super(key: key);

  @override
  _ChangePasswordScaffoldState createState() => _ChangePasswordScaffoldState();
}

class _ChangePasswordScaffoldState extends State<ChangePasswordScaffold> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _showOldOriginal = false;
  bool _showNewOriginal = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.getFullScreen().then((value) {
        if (!(value)) {
          DesktopWindow.setWindowSize(const Size(720, 505));
        }
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.getFullScreen().then((value) {
        if (!(value)) {
          DesktopWindow.setWindowSize(const Size(720, 505));
        }
      });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text("Old Password"),
                SizedBox(
                  width: screenWidth * 0.65,
                  child: TextField(
                    obscuringCharacter: '*',
                    obscureText: !_showOldOriginal,
                    textAlign: TextAlign.right,
                    controller: _oldPasswordController,
                    maxLength: 32,
                  ),
                ),
                Switch(
                  value: _showOldOriginal,
                  onChanged: (value) {
                    setState(() {
                      _showOldOriginal = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text("New Password"),
                SizedBox(
                  width: screenWidth * 0.65,
                  child: TextField(
                    obscuringCharacter: '*',
                    obscureText: !_showNewOriginal,
                    textAlign: TextAlign.right,
                    controller: _newPasswordController,
                    maxLength: 32,
                  ),
                ),
                Switch(
                  value: _showNewOriginal,
                  onChanged: (value) {
                    setState(() {
                      _showNewOriginal = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_newPasswordController.text.length < 8) {
                      await showAlertBox(context, "Password Strength", "New password must be of 8 characters at-least...");
                      return;
                    }

                    String sha256 = sha256UsernamePassword(widget.username, _oldPasswordController.text);
                    if (sha256 == widget.oldSha256) {
                      Box<User> users;
                      if (widget.isAdmin) {
                        users = GlobalHiveBox.adminUserBox!;
                      } else {
                        users = GlobalHiveBox.regularUserBox!;
                      }

                      dynamic keyFound;
                      users.toMap().forEach((key, value) {
                        if (value.hash == sha256) {
                          keyFound = key;
                        }
                      });

                      if (keyFound != null) {
                        users.delete(keyFound);
                        users.add(User(sha256UsernamePassword(widget.username, _newPasswordController.text)));
                        await showAlertBox(context, "Done", "Password changed successfully");

                        Navigator.of(context).pop();
                        return;
                      } else {
                        await showAlertBox(context, "User not Found", "Old user not found...");
                        return;
                      }
                    } else {
                      await showAlertBox(context, "Wrong Password", "Wrong old password...");
                      return;
                    }
                  },
                  child: const Text("Change Password"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
