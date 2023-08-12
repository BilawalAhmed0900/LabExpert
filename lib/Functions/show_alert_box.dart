import 'package:flutter/material.dart';

Future<void> showAlertBox(BuildContext context, String title, String message) async {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
      );
    },
  );
}
