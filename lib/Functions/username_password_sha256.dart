import 'dart:convert';

import 'package:crypto/crypto.dart';

String _mangleTwoStrings(String a, String b) {
  return "username: $a, password: $b";
}

String sha256UsernamePassword(String username, String password) {
  String mangled = _mangleTwoStrings(username, password);
  return base64Encode(sha256.convert(utf8.encode(mangled)).bytes);
}