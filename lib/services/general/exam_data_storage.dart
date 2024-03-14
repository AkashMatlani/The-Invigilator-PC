import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';

class ExamDataStorage {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await localPath;
    String key = Commons.createCryptoRandomString(14);
    return File('$path/$key.json');
  }

  Future<List<dynamic>> setExamDataFile(
      List<String?> recordings,
      List<String?> videos,
      List<String?> screenCapturePhotos,
      String? selfie1,
      String? selfie2,
      String? selfie3,
      String? selfie4,
      String? desc1,
      String? desc2,
      String? desc3,
      String? desc4,
      String? authCode,
      DateTime? codeActivationTime,
      List<dynamic>? secondsOutsideApp) async {
    try {
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;
      int examResId = preferences.getExamResultId() ?? 0;
      List documents = preferences.getCurrentDocuments() ?? [];
      String? name = preferences.getUserName() ?? "";
      double latitude = preferences.getLatitude() ?? 0;
      double longitude = preferences.getLongitude() ?? 0;
      double startLatitude = preferences.getStartLatitude() ?? 0;
      double startLongitude = preferences.getStartLongitude() ?? 0;
      DateTime finishedExamAt =
          preferences.getFinishedExamAt() ?? Commons.currentTime();

      // Out of App Time
      int? minutesInApp = preferences.getMinutesInApp();
      int? totalExamLength = preferences.getExamLength();
      int? minutesLeft = preferences.getMinutesLeft();
      String? outOfAppAudit = preferences.getTimeOutAudit() ?? "";

      Map allFields = {
        'exam_result_id': examResId.toString(),
        'user_id': userId.toString(),
        'user_name': name,
        'aws_selfie_1': selfie1,
        'aws_selfie_2': selfie2,
        'aws_selfie_3': selfie3,
        'aws_selfie_4': selfie4,
        'aws_item_photo_1': desc1,
        'aws_item_photo_2': desc2,
        'aws_item_photo_3': desc3,
        'aws_item_photo_4': desc4,
        'verification_code': authCode,
        'code_activated_at': codeActivationTime.toString(),
        'minutes_in_app': minutesInApp,
        'total_exam_length': totalExamLength,
        'minutes_left': minutesLeft,
        'documents': documents.toString(),
        'latitude': latitude,
        'longitude': longitude,
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'finished_exam_at': finishedExamAt.toString(),
        'time_out_app_intervals': outOfAppAudit,
      };
      int i = 1;
      for (var microphone in recordings) {
        allFields.addAll({'aws_microphone_$i': microphone});
        i = i + 1;
      }
      int p = 1;
      for (var video in videos) {
        allFields.addAll({'aws_video_$p': video});
        p = p + 1;
      }

      int q = 1;
      for (var screenCapturePhoto in screenCapturePhotos) {
        allFields.addAll({'aws_screencapture_$q': screenCapturePhoto});
        q = q + 1;
      }

      final data = jsonEncode(allFields);
      final file = await _localFile;

      await file.writeAsString(data, mode: FileMode.append);
      return [file, true];
    } catch (error) {
      return [null, false];
    }
  }
}