import 'dart:convert';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invigilatorpc/ui/dashboard/dashboard_screen.dart';
import 'package:invigilatorpc/ui/exam/exam_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';

class WelcomeViewModel extends ChangeNotifier {
  Future takeUserToCorrectScreen(
      BuildContext context, HivePreferences preferences) async {
    bool hasProfile = preferences.getIsProfileSetup() ?? false;
    bool confirmedAccount = preferences.getIsAccountConfirmed() ?? false;
    bool calibratedDevice = preferences.getIsServiceCalibrated() ?? false;
    bool acceptedTerms = preferences.getHasAcceptedTerms() ?? false;

    if (hasProfile && confirmedAccount && calibratedDevice && acceptedTerms) {
      String storageLocation = (await getApplicationDocumentsDirectory()).path;
      await FastCachedImageConfig.init(
          subDir: storageLocation, clearCacheAfter: const Duration(days: 365));
      String profilePicture = preferences.getProfileUrl() ?? "";
      Commons.profilePicture = profilePicture;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return DashboardScreen();
          },
        ),
      );
    }
  }

  Future takeUserToCurrentExam(
      BuildContext context, HivePreferences preferences) async {
    List<dynamic>? examDetails = preferences.getCurrentExam();

    if (examDetails!.length <= 9) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return DashboardScreen();
          },
        ),
      );
    } else {
      List<String> itemPhotoDescs =
          List<String>.from(json.decode(examDetails[6]));
      String storageLocation = (await getApplicationDocumentsDirectory()).path;
      await FastCachedImageConfig.init(
          subDir: storageLocation, clearCacheAfter: const Duration(days: 365));
      String profilePicture = preferences.getProfileUrl() ?? "";
      Commons.profilePicture = profilePicture;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ExamScreen(
              examDetails[0],
              int.parse(examDetails[1]),
              examDetails[2].toLowerCase() == 'true',
              int.parse(examDetails[3]),
              examDetails[4].toLowerCase() == 'true',
              int.parse(examDetails[5]),
              itemPhotoDescs,
              examDetails[7].toLowerCase() == 'true',
              true,
              int.parse(examDetails[10]),
              DateTime.parse(examDetails[12]),
              examDetails[13].toLowerCase() == 'true',
              examDetails[14].toLowerCase() == 'true',
              int.parse(examDetails[15]),
              examDetails[16].toLowerCase() == 'true',
              int.parse(examDetails[17]),
              examDetails,
            );
          },
        ),
      );
    }
  }

  Future checkUserLogin(BuildContext context) async {
    try {
      await Hive.initFlutter();
      final preferences = await HivePreferences.getInstance();
      int? userId = preferences.getUserId() ?? null;
      if (userId != null) {
        if (preferences.getCurrentExam() != null) {
          takeUserToCurrentExam(context, preferences);
        } else {
          takeUserToCorrectScreen(context, preferences);
        }
      }
    } catch (e) {
      print("Error is ${e.toString()}");
    }
  }
}
