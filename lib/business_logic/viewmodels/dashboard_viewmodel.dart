import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:invigilatorpc/networking/http_service.dart';
import 'package:invigilatorpc/services/general/alert_service.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/exam/exam_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:location/location.dart' as locationcheck;
import 'package:location/location.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'stamp_viewmodel.dart';
import 'dart:io' show Platform;

class DashboardViewModel extends ChangeNotifier {
  String? userName = "";
  int? totalPending = 0;
  bool tappedExamCode = false;
  String? examCode;
  bool loadingExam = false;
  String loadingText = "Verifying Assessment...";
  String? authCode;
  DateTime? codeActivationTime;
  List<String> collectedAuthData = [];
  AlertService alerter = AlertService();
  BuildContext? dashboardContext;
  final GeolocatorPlatform geolocatorWindows = GeolocatorPlatform.instance;

  Future getUserDetails() async {
    final preferences = await HivePreferences.getInstance();
    userName = preferences.getUserName();
    List<String>? data = preferences.getLocalExamFiles() ?? [];
    totalPending = data.length;
    notifyListeners();
  }

  void showNoticeForCutoff(dynamic jsonRes, BuildContext context) {
    String cutoff = jsonRes["cutoff_time"];

    Widget startButton = TextButton(
      child: Text("OK"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        startExamWithJson(context, jsonRes);
      },
    );

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          title: Text("This exam has an upload cutoff time"),
          content: Text(
              "Please make sure that everything is uploaded by $cutoff. If you upload your data after this cutoff, you will be penalised."),
          actions: [
            startButton,
          ],
        ));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showExamNoticeForNotLeaving(dynamic jsonRes, BuildContext context) {
    Widget startButton = Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TextButton(
        child: Text("OK"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            foregroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          bool hasCutOff = jsonRes['has_cutoff_time'];
          if (hasCutOff) {
            showNoticeForCutoff(jsonRes, context);
          } else {
            startExamWithJson(context, jsonRes);
          }
        },
      ),
    );

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Please do not leave the computer"),
          content: Text(
              "Please do not close this program while in the exam.\nYou are permitted to minimize in order to complete\nyour examination on the PC. You are now under\nexam conditions."),
          actions: [
            startButton,
          ],
        ));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showVersionOutOfDate(dynamic jsonRes, BuildContext context) {
    Widget startButton = TextButton(
      child: Text("OK"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        showExamNoticeForNotLeaving(jsonRes, context);
      },
    );

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          title: Text(
            "Warning! You are not on the latest version",
            style: TextStyle(
              color: Colors.orange[400],
            ),
          ),
          content: Text(
              "There is a new version available for the app. Please make sure you update your app before your next assessment."),
          actions: [
            startButton,
          ],
        ));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void startExamWithJson(BuildContext context, dynamic jsonRes) async {
    int? id = jsonRes['id'];
    int? resultId = jsonRes['result_id'];
    String? title = jsonRes['title'];
    int? examLength = jsonRes['exam_length'];
    bool selfieCheck = jsonRes['selfie_check'];
    int? selfieAmount = selfieCheck ? jsonRes['selfie_amount'] : 0;
    bool microphoneCheck = jsonRes['microphone_check'];
    int? microphoneAmount =
        microphoneCheck ? jsonRes['mic_recording_amount'] : 0;
    List<String> itemPhotoDescs = [];
    bool? codeRequired = jsonRes['verification_code_required'];
    int? recordingDuration = jsonRes['recording_duration'];
    DateTime startTime = Commons.currentTime();
    bool? canFinishEarly = jsonRes['can_finish_early'];

    // Video Recordings
    bool videoCheck = jsonRes['video_check'];
    int? videoAmount = videoCheck ? jsonRes['video_amount'] : 0;

    //screen capturing
    bool screenCaptureCheck = jsonRes['screenshot_check'];
    int? screenCapturingAmount =
        screenCaptureCheck ? jsonRes['screenshot_amount'] : 0;

    bool? isUctOnline = jsonRes['is_uct_online'];
    final preferences = await HivePreferences.getInstance();
    preferences.setExamId(id);
    preferences.setStarterChosen(null);
    if (isUctOnline!) {
      preferences.setIsGoogleSignIn(true);
    }

    if (resultId != null) {
      preferences.setExamResultId(resultId);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ExamPage"),
        builder: (context) {
          return ExamScreen(
            title,
            examLength,
            selfieCheck,
            selfieAmount,
            microphoneCheck,
            microphoneAmount,
            itemPhotoDescs,
            codeRequired,
            false,
            recordingDuration,
            startTime,
            canFinishEarly,
            videoCheck,
            videoAmount,
            screenCaptureCheck,
            screenCapturingAmount,
            jsonRes,
          );
        },
      ),
    );
  }

  void showStartExamAlert(BuildContext context, List<String> result) async {
    if (result[0] == 'true') {
      try {
        var jsonRes = jsonDecode(result[1]);
        String? title = jsonRes['title'];
        bool? latestVersion = jsonRes['latest_version'];

        final preferences = await HivePreferences.getInstance();
        bool? inVenue = jsonRes['in_venue'];
        preferences.setInVenue(inVenue);

        String? startingPassword = jsonRes['starting_password'];
        if (startingPassword != '') {
          final preferences = await HivePreferences.getInstance();
          preferences.setStartPassword(startingPassword);
        }

        Widget cancelButton = TextButton(
          child: Text("Cancel", style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              foregroundColor: MaterialStateProperty.all(Colors.black)),
          onPressed: () async {
            HttpService serv = HttpService();
            int? examId = jsonRes['id'];
            EasyLoading.show(status: "  Cancelling...");
            List<String> result = await serv.cancelExamResult(examId);
            EasyLoading.dismiss();
            if (result[0] == "true") {
              tappedExamCode = false;
              examCode = "";
              notifyListeners();

              Navigator.of(context, rootNavigator: true).pop('dialog');
            } else {
              Commons.invigiFlushBarError(
                  context, "There was an issue canceling your exam result");
            }
          },
        );
        Widget soundButton = TextButton(
          child: Text("Test Sound!", style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.teal[400]),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            alerter.playAlert();
          },
        );
        Widget startButton = Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton(
            child: Text("Start"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(kPrimaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              if (latestVersion!) {
                showExamNoticeForNotLeaving(jsonRes, context);
              } else {
                showVersionOutOfDate(jsonRes, context);
              }
            },
          ),
        );

        WillPopScope alert = WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              title: Text("Assessment is about to start"),
              content: Text(
                  "$title will start now. Please first check \nyour sound to make sure you can hear alerts."),
              actions: [
                cancelButton,
                soundButton,
                startButton,
              ],
            ));
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      } catch (exception) {
        Commons.invigiFlushBarError(
            context, "There was an issue starting the exam, please try again");
        loadingExam = false;
        notifyListeners();
      }
    } else if (result[0] == 'false') {
      Commons.invigiFlushBarError(context, result[1]);
      loadingExam = false;
      notifyListeners();
    }
  }

  void startExamWithCode(BuildContext context) async {
    final hasPermission;

    bool screenCapAllowed = await ScreenCapturer.instance.isAccessAllowed();
    if (!screenCapAllowed) {
      EasyLoading.dismiss();
      Commons.invigiFlushBarError(context,
          "We need permission to capture your screen. Please allow this before starting your assessment.");
      await Future.delayed(Duration(seconds: 1));
      await ScreenCapturer.instance.requestAccess();
      return;
    }
    if (Platform.isMacOS) {
      PermissionStatus _permissionGranted;
      locationcheck.Location location = locationcheck.Location();

      // Services check
      bool _serviceEnabled = await location.serviceEnabled();

      if (_serviceEnabled) {
        _permissionGranted = await location.hasPermission();
        hasPermission = _permissionGranted == PermissionStatus.granted;

        if (!hasPermission) {
          EasyLoading.dismiss();
          Commons.invigiFlushBarError(context,
              "We first need access to your GPS. Please accept the GPS permission and try again. If you do not see the modal appear requesting permission, please go to Privacy & Security -> Location Services and allow access for the Invigilator PC application.");
          await Future.delayed(Duration(seconds: 1));
          await location.requestPermission();
          return;
        }
      } else {
        EasyLoading.dismiss();
        Commons.invigiFlushBarError(context,
            "Your location services is disabled. Please allow location services to start the assessment.");
        await Future.delayed(Duration(seconds: 1));
        await location.requestService();
        return;
      }
    } else {
      hasPermission = await _handlePermission(context);
      if (!hasPermission) {
        return;
      }
    }

    var position;
    if (Platform.isMacOS) {
      locationcheck.Location location = locationcheck.Location();
      bool _serviceEnabled = await location.serviceEnabled();
      if (_serviceEnabled) {
        try {
          position =
              await location.getLocation().timeout(const Duration(seconds: 28));
        } catch (e) {
          EasyLoading.dismiss();
          Commons.invigiFlushBarError(context,
              "We could not get your GPS location. Please enable location services and try again");
          await Future.delayed(Duration(seconds: 1));
          await location.requestPermission();
          position = null;
        }
      } else {
        position = null;
        EasyLoading.dismiss();
        Commons.invigiFlushBarError(dashboardContext!,
            "We need you to enable location services before you start.");
        await Future.delayed(Duration(seconds: 2));
        await location.requestService();
      }
    } else {
      position = await geolocatorWindows.getCurrentPosition();
    }

    if (position != null &&
        position.longitude != null &&
        position.latitude != null) {
      print("latitude" + position.latitude.toString());
      print("longitude" + position.longitude.toString());
      print("exam Code" + examCode.toString());

      StampViewModel stamp = serviceLocator<StampViewModel>();
      await stamp.getStudentNumber();

      try {
        loadingExam = true;
        HttpService serv = HttpService();
        List<String> result =
            await serv.getExamDetailsForExam(examCode, position);
        EasyLoading.dismiss();
        if (result[0] == "true") {
          loadingExam = false;
          notifyListeners();
          examCode = "";
          showStartExamAlert(context, result);
        } else {
          loadingExam = false;
          notifyListeners();
          Commons.invigiFlushBarError(
              context,
              "There was an issue starting the exam. This issue is " +
                  result[1] +
                  " please try again.");
        }
      } catch (e) {
        loadingExam = false;
        notifyListeners();
        Commons.invigiFlushBarError(
            context, "There was an issue starting the exam, please try again.");
      }
    }
  }

  showAlertPasswordDialog(BuildContext context) {
    // set up the buttons
    Widget scanButton = TextButton(
      child: Text("Scan QR Code", style: TextStyle(color: Colors.white)),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        //  _scanQR(context);
      },
    );
    Widget continueButton = TextButton(
      child:
          Text("Enter Exam Access Code", style: TextStyle(color: Colors.white)),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        tappedExamCode = true;
        notifyListeners();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Start Assessment"),
      content: Text(
          "Scan the exam QR code or enter your exam access code to start the exam."),
      actions: [
        scanButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    Widget continueButton = TextButton(
      child:
          Text("Enter Exam Access Code", style: TextStyle(color: Colors.white)),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        tappedExamCode = true;
        notifyListeners();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Start Assessment"),
      content: Text(
          "Scan the exam QR code or enter your exam access code to start the exam."),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> _handlePermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await geolocatorWindows.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await geolocatorWindows.requestPermission();
    if (permission == LocationPermission.denied) {
      Commons.invigiFlushBarError(
          context, "We need permission to location before you start.");
      await Future.delayed(Duration(seconds: 3));
      _openLocationSettings(context);
      EasyLoading.dismiss();
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      Commons.invigiFlushBarError(
          context, "We need permission to location before you start.");
      await Future.delayed(Duration(seconds: 3));
      _openLocationSettings(context);
      EasyLoading.dismiss();
      return false;
    }
    return true;
  }

  void _openLocationSettings(BuildContext context) async {
    final opened = await geolocatorWindows.openLocationSettings();
    String displayValue;
    if (opened) {
      displayValue = 'Opened Location Settings';
      Commons.invigiFlushBarSuccess(context, displayValue);
    } else {
      displayValue = 'Error opening Location Settings';
      Commons.invigiFlushBarError(context, displayValue);
    }
  }
}
