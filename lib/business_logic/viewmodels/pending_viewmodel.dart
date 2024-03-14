import 'package:flutter/material.dart';
import 'package:invigilatorpc/ui/exam/exam_upload.dart';
import 'dart:convert';
import 'package:invigilatorpc/utils/hive_preferences.dart';

class PendingViewModel extends ChangeNotifier {
  List<String>? data;
  List? convertedData;

  void uploadFiles(int index, BuildContext context,
      [String? title, bool? isFromPending]) async {
    Map resultFile = convertedData![index].values.first;
    final preferences = await HivePreferences.getInstance();
    preferences.setStudentNum(preferences.getStudentNum() ?? "");
    preferences.setExamId(resultFile['exam_id']);
    preferences.setUserId(resultFile['user_id']);
    preferences.setExamResultId(resultFile['exam_result_id']);
    preferences.setLatitude(resultFile['latitude']);
    preferences.setLongitude(resultFile['longitude']);
    preferences.setStartLatitude(resultFile['start_latitude']);
    preferences.setStartLongitude(resultFile['start_longitude']);
    preferences
        .setFinishedExamAt(DateTime.parse(resultFile['finished_exam_at']));
    preferences.setMinutesInApp(resultFile['minutes_in_app']);
    preferences.setExamLength(resultFile['total_exam_length']);
    preferences.setMinutesLeft(resultFile['minutes_left']);
    preferences.setTimeOutAudit(resultFile['time_out_app_intervals']);
    if (resultFile['scripts_loaded']) {
      List<String?>? awsDocs = (resultFile['documents'] as List)
          .map((item) => item as String)
          .toList();
      preferences.setCurrentDocuments(awsDocs);
    }

    // Set index for removal
    preferences.setIndexOfReupload(index);
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => ExamUpload(
          resultFile['selfie_1'],
          resultFile['selfie_2'],
          resultFile['selfie_3'],
          resultFile['selfie_4'],
          resultFile['selfie_count'],
          resultFile['recordings'].length > 0,
          resultFile['recordings'],
          resultFile['unique_decibal_count'],
          resultFile['videos'].length > 0,
          resultFile['videos'],
          resultFile['screen_captures'].length > 0,
          resultFile['screen_captures'],
          resultFile['desc_images'],
          [],
          resultFile['verification_code'],
          DateTime.parse(resultFile['code_activated_at']),
          resultFile['seconds_out_app'],
          false,
          resultFile['scripts_loaded'] ? [] : resultFile['documents'],
          true,
          title != null ? title : "",
          preferences.getStudentNum(),
          isFromPending,
        ),
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }

  Future getData(BuildContext context) async {
    final preferences = await HivePreferences.getInstance();
    data = preferences.getLocalExamFiles() ?? [];
    convertedData = json.decode(data.toString());
    notifyListeners();
  }
}
