import 'package:flutter/material.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';

class StampViewModel extends ChangeNotifier {
  String? studentNumber = "";

  Future<String> getStudentNumber() async {
    final preferences = await HivePreferences.getInstance();
    studentNumber = preferences.getStudentNum();
    return studentNumber ?? "";
  }
}
