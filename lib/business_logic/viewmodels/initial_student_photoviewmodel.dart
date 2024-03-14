import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:macam/macam.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/networking/aws_service.dart';
import 'package:invigilatorpc/providers/initial_photo_provider.dart';
import 'package:invigilatorpc/ui/camera/camera_screen.dart';
import 'package:invigilatorpc/ui/dashboard/dashboard_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:io';

class InitialStudentPhotoViewModel extends ChangeNotifier {
  bool selfiesPassed = true;
  String errorMessage = "";
  bool someCheckHasFailed = false;
  bool successfulCalibration = true;
  String? loadingText = "Uploading...";
  bool isImageLoaded = false;
  bool isProcessing = false;

  showSelfiePhotoDialog(BuildContext context) {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Take Selfie"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            pickImage(context);
          },
        ));
    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Notice!"),
          content: Text(
              "Please ensure that  you take an actual selfie of yourself\nand not a photo of your ID or student card."),
          actions: [
            continueButton,
          ],
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

  Future pickImage(BuildContext context) async {
    var result;

    if (Platform.isMacOS) {
      String name = Commons.createCryptoRandomString(15);
      var filename = "picture-$name";
      final macCamera = Macam();
      String path = await macCamera.openCamera(
          buttonTitle: "Take Selfie", fileName: filename);
      result = [true, path];
    } else {
      var status = await Permission.camera.request();
      if (status.isGranted) {
        result = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => CameraScreen()));
      } else {
        Commons.invigiFlushBarError(context,
            "We need Camera Permission to Start Recoding Video & Selfies.");
        await Future.delayed(Duration(seconds: 3));
        openAppSettings();
      }
    }
    try {
      if (result[0]) {
        captureSelfie(context, result[1]);
      } else {
        Commons.invigiFlushBarError(
            context, "Looks like something went wrong, please retry.");
      }
    } catch (e, stackTrace) {
      Commons.invigiFlushBarError(
          context, "Looks like something went wrong, error is ${e.toString()}");
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void captureSelfie(BuildContext context, imagePath) async {
    var initialPhotoProvider =
        Provider.of<InitialPhotoProvider>(context, listen: false);

    void callLoader({
      String? text,
      bool isProcessing = false,
      String filePath = '',
      bool isImageLoaded = false,
    }) {
      initialPhotoProvider.loadingText = text;
      initialPhotoProvider.isProcessing = isProcessing;
      initialPhotoProvider.filePath = filePath;
      initialPhotoProvider.isImageLoaded = isImageLoaded;
    }

    var path;
    try {
      path = imagePath;
      if (path != null) {
        callLoader(
          text: 'Uploading...',
          isProcessing: false,
          filePath: imagePath,
          isImageLoaded: true,
        );

        AwsService serv = initialPhotoProvider.awsService();
        List<String> loaded =
            await initialPhotoProvider.loadedImage(initialPhotoProvider);

        if (loaded[0] == 'true') {
          List<String?> serverLoaded = await serv.uploadProfile(loaded[1]);
          if (serverLoaded[0] == "true") {
            final preferences = await HivePreferences.getInstance();
            preferences.setIsProfileSetup(true);
            preferences.setProfileUrl(loaded[1]);
            Commons.profilePicture = loaded[1];
            FastCachedImageConfig.isCached(imageUrl: loaded[1]);
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => DashboardScreen(),
              ),
              (route) =>
                  false, //if you want to disable back feature set to false
            );
          } else {
            callLoader(
              text: 'Uploading...',
              isProcessing: false,
              isImageLoaded: false,
            );
            Commons.invigiFlushBarError(context,
                "We could not upload your photo to the server. Please try again");
          }
        } else {
          callLoader(
            text: 'Uploading...',
            isProcessing: false,
            isImageLoaded: false,
          );
          Commons.invigiFlushBarError(context,
              "Something went wrong, please try again, Error: ${loaded[1]}");
        }
      } else {
        callLoader(
          text: 'Uploading...',
          isProcessing: false,
          isImageLoaded: false,
        );
        Commons.invigiFlushBarError(context,
            "We could not find your face in this photo, please try again");
      }
    } catch (e, stackTrace) {
      callLoader(
        text: 'Uploading...',
        isProcessing: false,
        isImageLoaded: false,
      );
      Commons.invigiFlushBarError(
          context, "Looks like something went wrong, error is ${e.toString()}");
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }
}
