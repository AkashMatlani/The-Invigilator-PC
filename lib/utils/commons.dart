import 'dart:convert';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examscreen_viewmodel.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:screen_brightness/screen_brightness.dart';

class Commons {
  static String? studentNumber = "";
  static String? userName = "";
  static String? profilePicture = "";

  static Widget invigiLoader() {
    return Center(
        child: SpinKitWave(
          color: Colors.white,
        ));
  }

  static Widget errorNoInternet() {
    return Container(
      margin: EdgeInsets.only(top: 25.00),
      padding: EdgeInsets.all(10.00),
      color: Colors.orange,
      child: Row(children: [
        Container(
          margin: EdgeInsets.only(right: 6.00),
          child: Icon(Icons.wifi_off, color: Colors.white),
        ),
        Text("Please check your connection.",
            style: TextStyle(color: Colors.white)),
      ]),
    );
  }

  static offLineWidget() {
    return errorNoInternet();
  }

  static Widget dateTimeStudent(double fontSize) {
    DateTime currentDateTime = DateTime.now();
    String formattedDate =
    DateFormat('yyyy-MM-dd – kk:mm').format(currentDateTime);
    return Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Student number:",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontFamily: 'Neufreit'),
                  ),
                  Text(
                    Commons.studentNumber ?? "",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontFamily: 'Neufreit'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date and Time:",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontFamily: 'Neufreit'),
                  ),
                  Text(
                    formattedDate.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontFamily: 'Neufreit'),
                  )
                ],
              )
            ]));
  }

  static Widget invigiLoading(String message, bool includeStamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        includeStamp ? dateTimeStudent(10.0) : Container(),
        includeStamp
            ? SizedBox(
          height: 30,
        )
            : Container(),
        Padding(
            padding: EdgeInsets.all(18),
            child: AnimatedTextKit(
              animatedTexts: [
                FadeAnimatedText(
                  message,
                  textStyle: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                FadeAnimatedText(
                  'Thanks for your patience.',
                  textStyle: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                FadeAnimatedText(
                  'Please wait...',
                  textStyle: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            )),
        invigiLoader(),
      ],
    );
  }

  static Widget invigiMicLoading(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontFamily: 'Neufreit'),
          ),
        ),
        Center(
            child: SpinKitWave(
              color: Colors.white,
            )),
      ],
    );
  }

  static invigiFlushBarNoInternet(BuildContext context) {
    Flushbar(
      title: "Error",
      message: noInternet,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInOut,
      backgroundColor: Colors.red,
      isDismissible: false,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.close, color: Colors.black),
    ).show(context);
  }

  static invigiFlushBarError(BuildContext context, String? message) {
    Flushbar(
      title: "Error",
      message: message,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInOut,
      backgroundColor: Colors.red,
      isDismissible: false,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.close, color: Colors.black),
    ).show(context);
  }

  static invigiFlushBarErrorOrange(BuildContext context, String message) {
    Flushbar(
      title: "Alert",
      message: message,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInOut,
      backgroundColor: Colors.yellow[800]!,
      isDismissible: false,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.close, color: Colors.black),
    ).show(context);
  }

  static invigiFlushBarSuccess(BuildContext context, String? message) {
    Flushbar(
      title: "Success",
      message: message,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInOut,
      backgroundColor: Colors.green[400]!,
      isDismissible: false,
      duration: Duration(seconds: 10),
    ).show(context);
  }

  static invigiFlushBarGeneral(BuildContext context, String message) {
    Flushbar(
      message: message,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.easeInOut,
      backgroundColor: Colors.teal[400]!,
      isDismissible: false,
      duration: Duration(seconds: 5),
      icon: Icon(Icons.close, color: Colors.black),
    ).show(context);
  }

  static String createCryptoRandomString([int length = 8]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  static String createRandomCode() {
    List pin = [];
    var rng = Random();
    for (var i = 0; i < 4; i++) {
      pin.add(rng.nextInt(9).toString());
    }
    return pin.join();
  }

  static DateTime currentTime() {
    return DateTime.now().toUtc().add(Duration(hours: 2));
  }

  static Future removeAllExamData() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentExam(null);
    preferences.setItemPhotos(null);
    preferences.setExamRecordings(null);
    preferences.setExamSelfies(null);
    preferences.setExamVideos(null);
    preferences.setExamScreenCapturingPhotos(null);
    preferences.setExamSelfiesLow(null);
    preferences.setExamAuthCode(null);
    preferences.setExamId(null);
    preferences.setSecondOutOfApp(null);
    preferences.setUniqueDecibelsFound(null);
    preferences.setExamResultId(null);
    preferences.setItemPhotosLow(null);
    preferences.setStartPassword(null);
    preferences.setFinishedExamAt(null);
    preferences.setLocalDocuments(null);
    preferences.setIndexOfReupload(null);
    preferences.setMinutesInApp(null);
    preferences.setExamLength(null);
    preferences.setMinutesLeft(null);
    preferences.setTimeOutAudit(null);
    preferences.setCurrentDocuments(null);
    preferences.setExamFinished(null);
    ExamScreenViewModel.allSelfies = [];
    ExamScreenViewModel.videos = [];
  }

  static void logOut(BuildContext context) async {
    HivePreferences.deleteAllPreferences();
    FastCachedImageConfig.clearAllCachedImages();
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => LoginScreen(),
      ),
          (route) => false, //if you want to disable back feature set to false
    );
  }

  static void logOutDialog(BuildContext context) {
    Widget yesButton = TextButton(
      child: Text("Yes"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        logOut(context);
      },
    );
    Widget noButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("No", style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              foregroundColor: MaterialStateProperty.all(Colors.black)),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ));
    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Logout"),
          content: Text("Are you sure, do you want to logout?"),
          actions: [yesButton, noButton],
        ));

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      print(e);
      throw 'Failed to set brightness';
    }
  }
}