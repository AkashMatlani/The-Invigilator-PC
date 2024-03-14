import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invigilatorpc/networking/http_service.dart';
import 'package:invigilatorpc/ui/initialstudentphoto/initial_student_photo.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'package:invigilatorpc/ui/tutorial/tutorial_screen.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';

import '../dashboard/dashboard_screen.dart';

class TermsScreen extends StatefulWidget {
  final bool hasCalibrated;
  final bool hasAddedPhoto;

  TermsScreen(this.hasCalibrated, this.hasAddedPhoto);

  @override
  _TermsScreenState createState() =>
      _TermsScreenState(this.hasCalibrated, this.hasAddedPhoto);
}

class _TermsScreenState extends State<TermsScreen> {
  bool hasCalibrated;
  final bool hasAddedPhoto;

  _TermsScreenState(this.hasCalibrated, this.hasAddedPhoto);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Background(
            alignValue: true,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 10),
                        child: Image.asset(
                          owl,
                          height: size.height * 0.10,
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 0,
                        child: Container(
                          width: size.width * 0.12,
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Text(
                          "Terms & Conditions",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            width: 600,
                            height: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "The Invigilator App helps verify your identity with images of your face, audio of your voice and surroundings and pictures of documents personal to you.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "You will need to consent to the following: ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Using the camera on your device to obtain your image",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Using the camera on your device to obtain images of documents as requested",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Using the speaker on your device to obtain audio of you and your immediate surroundings",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Receiving other data about your device",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Using those images, the audio and your device data:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 13.0, right: 13.0, top: 5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "○  to help authenticate you",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: 'roboto',
                                              fontSize: 13),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        Text(
                                          "○  to improve the Invigilator App",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: 'roboto',
                                              fontSize: 13),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        Text(
                                          "○  to maintain examination and assessment integrity",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: 'roboto',
                                              fontSize: 13),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        Text(
                                          "○  to investigate and report potentially wrongful authentication attempts, unethical behaviour and passing off someone else’s work as your own.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                              fontFamily: 'roboto',
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Collecting your name, student number, email address and phone number",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "•  Sending you QR Codes for purposes of accessing exam papers and other assessments",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.05),
                                  Text(
                                    "By clicking on the Continue button, you agree to the Invigilator App Terms of Use, as follows. If you do not understand please contact our support desk for help. If you do not agree to these terms do not continue to use the Invigilator App.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.04),
                                  Text(
                                    "Terms of Use",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.04),
                                  Text(
                                    "1.  You - the person who clicks on the Continue button – are agreeing to the paragraphs below and our privacy policy available here which is incorporated by reference and to which you will agree as part of your use of the service.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "2.  You authorise the Invigilator to record and upload images of you and your documents (“User Images”) and audio of you and your immediate surrounds (“User Audio”); the Invigilator App may also collect data relating to the device through which User Images and User Audio is provided to reduce the risk of impersonation.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "3.  You must ensure that the camera on your device is pointed only at you when creating your selfie image.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "4.  You authorise the Invigilator App, and contractors directly and indirectly engaged to provide the Invigilator App, to store and use your User Images and User Audio and related data (i) to help verify that a user seeking to authenticate resembles the user who originally registered with the selfie, (ii) to improve the Invigilator App, (iii) to investigate and report potentially wrongful attempts to impersonate or cheat, and (iv) to validate any certification provided by any institution and mitigate the risk of unethical behavior.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "5.  The Invigilator would like to use your GPS location. The Invigilator uses your location to monitor student proximity. Your location is only used by The Invigilator for Invigilation purposes and will only be brought to the attention of your institution when other students are detected close to you during an assessment or examination. Your location will only be used when the Invigilator application is open and in use for assessing and examination purposes.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "6.  The Invigilator App must be used only by people who are at least 15 years old.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "7.  All personal information collected through your use of the Invigilator App will be processed in terms of our privacy policy available here www.invigilator.app",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    "8.  The Invigilator App is provided to you by The Invigilator (Pty) Ltd.",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                        fontFamily: 'roboto',
                                        fontSize: 14),
                                  ),
                                  SizedBox(height: size.height * 0.04),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.teal[400]!, Colors.teal[200]!]),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Spacer(),
                        RoundedButton(
                            text: "I Do Not Accept",
                            color: Colors.teal[200]!,
                            width: 0.2,
                            isFromForgot:false,
                            press: () async {
                              showNoAcceptMessage();
                            }),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        RoundedButton(
                            text: "I Accept",
                            width: 0.2,
                            isFromForgot:false,
                            press: () async {
                              checkConnection().then((isConnected) async {
                                if (!isConnected) {
                                  Commons.invigiFlushBarError(
                                      context, noInternet);
                                } else {
                                  EasyLoading.show(
                                      status: "  Accepting terms...");
                                  HttpService serv = HttpService();
                                  List<String?> accepted =
                                      await serv.acceptTerms();
                                  EasyLoading.dismiss();
                                  if (accepted[0] == "true") {
                                    final preferences =
                                        await HivePreferences.getInstance();
                                    preferences.setHasAcceptedTerms(true);
                                    if (this.hasCalibrated) {
                                      String storageLocation = (await getApplicationDocumentsDirectory()).path;
                                      await FastCachedImageConfig.init(
                                          subDir: storageLocation, clearCacheAfter: const Duration(days: 365));
                                      Navigator.pushAndRemoveUntil<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) =>
                                              this.hasAddedPhoto
                                                  ? DashboardScreen()
                                                  : InitalStudentPhotoScreen(),
                                        ),
                                        (route) =>
                                            false, //if you want to disable back feature set to false
                                      );
                                    } else {
                                      Navigator.pushAndRemoveUntil<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) =>
                                              TutorialScreen(
                                                  this.hasAddedPhoto),
                                        ),
                                        (route) =>
                                            false, //if you want to disable back feature set to false
                                      );
                                    }
                                  } else if (accepted[0] == "timeout") {
                                    Commons.invigiFlushBarError(
                                        context, accepted[1]);
                                  } else {
                                    Commons.invigiFlushBarError(context,
                                        "Unable to accept terms, Please try again.");
                                  }
                                }
                              });
                            }),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  showNoAcceptMessage() {
    Widget cancelBtn = TextButton(
      child: Text("Cancel", style: TextStyle(color: Colors.white)),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey),
          foregroundColor: MaterialStateProperty.all(Colors.black)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    // set up the buttons
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("OK"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');

            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => LoginScreen(),
              ),
              (route) =>
                  false, //if you want to disable back feature set to false
            );
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("You have not accepted terms"),
          content: Text(
              "You will now be taken back to the main screen. Unfortunately, in order to\ncontinue using the app you will need to accept the terms & conditions."),
          actions: [cancelBtn, continueButton],
        ));

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
