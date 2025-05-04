import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('user_id');
  await prefs.remove('user_role');
  Navigator.pushReplacementNamed(context, '/login');
}
