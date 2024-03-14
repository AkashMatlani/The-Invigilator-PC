import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';
import 'package:invigilatorpc/services/auth/auth_service.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/confirmation/confirm_screen.dart';
import 'package:invigilatorpc/ui/dashboard/dashboard_screen.dart';
import 'package:invigilatorpc/ui/exam/exam_screen.dart';
import 'package:invigilatorpc/ui/initialstudentphoto/initial_student_photo.dart';
import 'package:invigilatorpc/ui/terms/terms_screen.dart';
import 'package:invigilatorpc/ui/tutorial/tutorial_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService? _authService = serviceLocator<AuthService>();

  Future<dynamic> loginUser(BuildContext context, HashMap inputFields) async {
    var loggedIn = await _authService!.loginUser(inputFields);
    print(loggedIn);
    if (loggedIn[0] == 'true') {
      final preferences = await HivePreferences.getInstance();
      if (preferences.getCurrentExam() != null && !await hasOldExamData()) {
        List<dynamic>? examDetails = preferences.getCurrentExam();
        List<String> itemPhotoDescs =
            List<String>.from(json.decode(examDetails![6]));

        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => ExamScreen(
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
            ),
          ),
          (route) => false, //if you want to disable back feature set to false
        );
      } else {
        final preferences = await HivePreferences.getInstance();
        bool hasProfile = preferences.getIsProfileSetup() ?? false;
        bool confirmedAccount = preferences.getIsAccountConfirmed() ?? false;
        bool calibratedDevice = preferences.getIsServiceCalibrated() ?? false;
        bool acceptedTerms = preferences.getHasAcceptedTerms() ?? false;

        if (confirmedAccount == false) {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ConfirmScreen(true),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        } else if (acceptedTerms == false) {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) =>
                  TermsScreen(calibratedDevice, hasProfile),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        } else if (calibratedDevice == false) {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => TutorialScreen(hasProfile),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        } else if (hasProfile == true) {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => DashboardScreen(),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        } else {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => InitalStudentPhotoScreen(),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      }
    } else {
      EasyLoading.dismiss();
      Commons.invigiFlushBarError(context, loggedIn[1]);
    }
  }

  Future<bool> hasOldExamData() async {
    // Old versions of the app had different stored currentExam Data. So we need to remove that
    final preferences = await HivePreferences.getInstance();
    bool hasOldExamData = false;
    if (preferences.getCurrentExam() != null ||
        preferences.getCurrentExam()!.isNotEmpty) {
      List<dynamic>? examDetails = preferences.getCurrentExam();
      if (examDetails!.length <= 9) {
        Commons.removeAllExamData();
        hasOldExamData = true;
      }
    }
    return hasOldExamData;
  }
}
