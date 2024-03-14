import 'dart:convert';

import 'package:invigilatorpc/utils/hive_preferences.dart';

import '../../utils/commons.dart';

class ExamFilesStorage {
  Future<bool> setExamDataFile(
      String? selfie1,
      String? selfie2,
      String? selfie3,
      String? selfie4,
      int? selfieCount,
      List<dynamic>? recordings,
      List<dynamic>? videos,
      List<dynamic>? screenCaptures,
      int? uniqueDecibelCount,
      List<dynamic>? descImages,
      String? verificationCode,
      DateTime? codeActivationTime,
      List<dynamic>? secondsOutOfApp,
      bool incomplete,
      bool scriptsAlreadyLoaded,
      ) async {
    try {
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;
      int examResId = preferences.getExamResultId() ?? 0;
      List documents;
      if (scriptsAlreadyLoaded) {
        documents = preferences.getCurrentDocuments() ?? [];
      } else {
        documents = preferences.getLocalDocuments() ?? [];
      }
      double latitude = preferences.getLatitude() ?? 0;
      double longitude = preferences.getLongitude() ?? 0;
      double startLatitude = preferences.getStartLatitude() ?? 0;
      double startLongitude = preferences.getStartLongitude() ?? 0;
      DateTime finishedExamAt =
          preferences.getFinishedExamAt() ?? Commons.currentTime();
      int examId = preferences.getExamId() ?? "0" as int;
      // Out of App Time
      int? minutesInApp = preferences.getMinutesInApp() ?? 0;
      int? totalExamLength = preferences.getExamLength() ?? 0;
      int? minutesLeft = preferences.getMinutesLeft() ?? 0;
      String? outOfAppAudit = preferences.getTimeOutAudit() ?? "";

      List<dynamic>? examDetails = preferences.getCurrentExam();
      String title = examDetails![0];
      List<String> allLocalFiles = preferences.getLocalExamFiles() ?? [];

      Map allFields = {
        "$examId$userId": {
          'exam_id': examId,
          'user_id': userId,
          'incomplete': incomplete,
          'title': title,
          'exam_result_id': examResId,
          'selfie_1': selfie1,
          'selfie_2': selfie2,
          'selfie_3': selfie3,
          'selfie_4': selfie4,
          'selfie_count': selfieCount,
          'desc_images': descImages,
          'verification_code': verificationCode,
          'code_activated_at': codeActivationTime.toString(),
          'recordings': recordings,
          'videos': videos,
          'screen_captures': screenCaptures,
          'unique_decibal_count': uniqueDecibelCount,
          'seconds_out_app': secondsOutOfApp,
          'minutes_in_app': minutesInApp,
          'total_exam_length': totalExamLength,
          'minutes_left': minutesLeft,
          'scripts_loaded': scriptsAlreadyLoaded,
          'documents': documents,
          'latitude': latitude,
          'longitude': longitude,
          'start_latitude': startLatitude,
          'start_longitude': startLongitude,
          'finished_exam_at': finishedExamAt.toString(),
          'time_out_app_intervals': outOfAppAudit,
        }
      };
      print(json.encode(allFields));
      allLocalFiles.add(json.encode(allFields));
      preferences.setLocalExamFiles(allLocalFiles);
      return true;
    } catch (error, stacktrace) {
      print("WE HAVE AN ERROR AND IT IS $error");
      print(stacktrace);
      return false;
    }
  }
}