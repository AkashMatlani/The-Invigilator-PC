import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';

import '../utils/commons.dart';

class TimerProvider extends ChangeNotifier {
  DateTime? examStartedAt;
  List<String>? examDetails;
  bool pageInd = false;
  int? timeValue;
  int? timeUpdValue;
  dynamic examTimer;
  bool? testNew;

  int? getTimer() {
    if (timeUpdValue != null && timeUpdValue! > 0) {
      return timeUpdValue;
    } else {
      return timeValue;
    }
  }

  int? updateTimerVal() {
    return timeUpdValue;
  }

  Future<int> timerUpdAfterBackground(DateTime examStartedAt) async {
    final preferences = await HivePreferences.getInstance();
    List<dynamic>? examDetails = preferences.getCurrentExam();
    DateTime startedAt = examStartedAt;
    DateTime currentTime = Commons.currentTime();

    int totalExamLength = int.parse(examDetails![1]);
    int difference = currentTime.difference(startedAt).inMinutes;
    int minutesLeft = totalExamLength - difference;

    return minutesLeft;
  }

  int updateTimeForCheck(DateTime? examStartedAt, int? totalExamLength) {
    DateTime currentTime = Commons.currentTime();
    int difference = currentTime.difference(examStartedAt!).inMinutes;
    var minutesLeft = totalExamLength! - difference;
    var updatedTime = minutesLeft - 1;
    notifyListeners();
    return updatedTime;
  }
}