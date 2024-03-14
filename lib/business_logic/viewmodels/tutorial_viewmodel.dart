import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_audio_recorder/flutter_desktop_audio_recorder.dart';
import 'package:macam/macam.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:invigilatorpc/networking/aws_service.dart';
import 'package:invigilatorpc/services/general/alert_service.dart';
import 'package:invigilatorpc/ui/camera/camera_screen.dart';
import 'package:invigilatorpc/ui/dashboard/dashboard_screen.dart';
import 'package:invigilatorpc/ui/initialstudentphoto/initial_student_photo.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:record/record.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:video_compress/video_compress.dart';

class TutorialViewModel extends ChangeNotifier {
  Record _audioRecorder = Record();
  List<String> imagesTaken = [];
  bool uploading = false;
  String loadingText = "Uploading data";
  bool successUploading = false;
  var examTimer;
  int minutesForUpload = 20;
  bool selfieProcessing = false;
  bool microphoneProcessing = false;
  bool uploadingData = false;
  String spinnerText = "Verifying...";
  String uploadKey = Commons.createCryptoRandomString();
  bool failedUpload = false;
  bool successfulCalibration = true;
  bool _hasMicPermission = true;

  // Sounds
  AlertService alerter = AlertService();

  // Pass Tests
  bool selfiesPassed = true;
  bool descriptionPhotoPassed = true;

  bool videoPassed = true;
  bool microphonePassed = true;
  bool soundPassed = true;
  bool facePassed = true;

  int failedFaceRecognition = 0;
  String? selfieFile;
  String? videoFile;
  String? microphoneFile;

  late bool hasAddedPhoto;
  String errorMessage = "";

  bool someCheckHasFailed = false;
  FlutterDesktopAudioRecorder recorder = FlutterDesktopAudioRecorder();

  //Screenshot
  bool _isAccessAllowed = false;
  CapturedData? _lastCapturedData;
  bool? retryUsed = false;

  welcomeTut(BuildContext context) {
    Widget continueButton = Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TextButton(
          child: Text("Continue"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () async {
            if (_hasMicPermission) {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              gettingStarted(context);
            } else {
              Commons.invigiFlushBarError(context,
                  "We need permission to your microphone before you start.");
              recorder.requestMicPermission();
            }
          }),
    );

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Welcome to the Invigilator"),
          content: Text(
              "This tutorial will check your device to make sure it is\ncompatable with the app and show you how to use\nthe application in an assessment"),
          actions: [continueButton],
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

  gettingStarted(BuildContext context) async {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Continue"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            selfyNotice(context);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Getting Started"),
          content: Text(
              "On the bottom of your screen you will notice a timer\nwhich represents the amount of time left in your exam.\nWhen the timer reaches 0 it will progress you to the\nupload screen where it will submit all the files collected\nduring the exam. Let's test if your PC is setup correctly."),
          actions: [continueButton],
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

  selfyNotice(BuildContext context) {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Continue"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            await Future.delayed(Duration(seconds: 1));
            alerter.playAlert();
            showSelfiePhotoDialog(context);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Selfie Check"),
          content: Text(
              "At random intervals in the exam the app will ask you to\ntake a selfie. Let's check if your device is configured,\nin 2 seconds the selfie notice will appear to take a selfie."),
          actions: [continueButton],
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

  showSelfiePhotoDialog(BuildContext context) {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Continue"),
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
          title: Text("Attention!"),
          content: Text(
              "You will need to take a selfie now. Please make sure your\nface is fully in the camera."),
          actions: [
            continueButton,
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

  showNoCapturePermissionDialog(BuildContext context) {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Retry"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            showCaptureDialog(context);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Permission Denied for Screen Capture"),
          content: Text(
              "We have prompted you to allow permission for us to capture your screen. Please allow the permission and retry (You may have to quit and re-open after giving permission)"),
          actions: [
            continueButton,
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

  showCaptureDialog(BuildContext context) {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Continue"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            if (Platform.isWindows) {
              await Future.delayed(Duration(seconds: 1));
            }
            screenCapturePhotos(context);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Screen Capture Check"),
          content: Text(
              "At random intervals the application will take a screen capture.\nLet's check if your PC Configured,in 2 seconds we will \ntake a capture of your screen"),
          actions: [
            continueButton,
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

  showVideoDialog(BuildContext context) {
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Continue"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            pickVideo(context);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Video Check"),
          content: Text(
              "At random intervals the application will record footage\nfrom your webcam.Let's check if your PC is configured,\nin 2 seconds we will record some footage from your\nwebcam"),
          actions: [
            continueButton,
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

  microphoneNotice(BuildContext context) {
    closeKeyboard();
    Widget continueButton = Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TextButton(
        child: Text("Start"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            foregroundColor: MaterialStateProperty.all(Colors.white)),
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          microphoneCheck(context);
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
          title: Text("Microphone Check"),
          content: Text(
              "Everything looks good with the camera. Now let's test\nout your microphone to make sure that is configured.\nTap start to begin recording for 15 seconds."),
          actions: [continueButton],
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

  Future microphoneCheck(BuildContext context) async {
    try {
      bool hasPermissions = await _audioRecorder.hasPermission();
      if (hasPermissions) {
        int totalSeconds = 15;
        startRecording().then((value) => {
              examTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
                if (totalSeconds <= 0) {
                  if (examTimer != null) {
                    examTimer.cancel();
                  }
                  microphoneProcessing = false;
                  notifyListeners();
                  stopRecording(context);
                } else {
                  microphoneProcessing = true;
                  spinnerText = "Recording.. $totalSeconds";
                  notifyListeners();
                }
                totalSeconds = totalSeconds - 1;
              })
            });
      } else {}
    } catch (error, stackTrace) {
      microphonePassed = false;
      errorMessage = "Error on Microphone: ${error.toString()}";
      someCheckHasFailed = true;
      errorAlertNotice(context, "Microphone check");
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  soundCheckNotice(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("No", style: TextStyle(color: Colors.white)),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        soundPassed = false;
        calibrationSuccessWithoutSound(context);
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
          child: Text("Yes"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            calibrationSuccessNotice(context);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Can you hear the alert?"),
          content: Text(
              "Everything looks good. Now we just need to check\nif you can hear the alert sounds? Please make sure \nyour PC is not on Mute tap Test Sound to re-test."),
          actions: [
            soundButton,
            cancelButton,
            startButton,
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

  calibrationSuccessWithoutSound(BuildContext context) {
    // set up the buttons
    Widget uploadButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Upload Data"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            successfulCalibration = true;
            uploadResults(context, successfulCalibration);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text(
            "Some issues found !",
            style: TextStyle(color: Colors.orange),
          ),
          content: Text(
              "Everything looks good with all the other checks\nexcept sound. We will let this device progress but\nif your sound still does not play we recommend\nusing another device. Everytime you start an\nexam in the dashboard you can also check your\nsound to make sure."),
          actions: [uploadButton],
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

  calibrationSuccessNotice(BuildContext context) {
    // set up the buttons
    Widget uploadButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Upload Data"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            successfulCalibration = true;
            uploadResults(context, successfulCalibration);
          },
        ));

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text(
            "Success!",
            style: TextStyle(color: Colors.green),
          ),
          content: Text(
              "Everything looks good with this device. We will now upload\nyour data to save your calibrations on this device."),
          actions: [uploadButton],
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

  errorAlertNotice(BuildContext context, String errorArea) {
    Widget failButton = TextButton(
      child: Text("Upload Data"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        successfulCalibration = false;
        uploadResults(context, successfulCalibration);
      },
    );

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text(
            "Device Error!",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          content: Text(
              "Looks like this device has an error in the $errorArea test. We will\nupload the data and check it on our side. This could have been a once\noff hardware issue so please try re-login after the upload and\nperform the calibration again."),
          actions: [failButton],
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

  void failedUploadAction(BuildContext context, String? error) {
    Commons.invigiFlushBarError(
        context, "We had an issue uploading your data. Error: $error");
    failedUpload = true;
    uploadingData = false;
    notifyListeners();
  }

  void uploadResults(BuildContext context, bool success) async {
    AwsService aws = AwsService();
    failedUpload = false;
    uploadingData = true;
    spinnerText = "Uploading..";
    notifyListeners();
    if (selfieFile != null) {
      spinnerText = "Uploading Selfie..";
      notifyListeners();
      List<String> uploadData =
          await aws.uploadCalibrationFile(selfieFile!, 'image', 'jpeg');
      if (uploadData[0] == 'true') {
        String fileToLink = uploadData[1];
        List<String?> uploadedToServer =
            await aws.uploadCalibrationFileToServer(
                fileToLink, "selfie_file", uploadKey);
        if (uploadedToServer[0] == "true") {
          if (selfieFile != null && selfieFile!.isNotEmpty) {
            await File(selfieFile!).delete();
          }
        } else {
          failedUploadAction(context, "Error on server upload");
        }
      } else {
        failedUploadAction(context, uploadData[1]);
      }
    }

    if (videoFile != null && failedUpload == false) {
      spinnerText = "Uploading Video..";
      notifyListeners();
      String OutputPath;
      if (Platform.isWindows) {
        // Compress Windows One
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        String name = Commons.createCryptoRandomString(15);
        OutputPath = appDocDirectory.path + '\\' + "compress_video-$name.mp4";
        videoFile = await compressVideoFFmpeg(videoFile!, OutputPath);
      }
      List<String> uploadData =
          await aws.uploadCalibrationFile(videoFile!, 'video', 'mp4');
      if (uploadData[0] == 'true') {
        String fileToLink = uploadData[1];
        List<String?> uploadedToServer = await aws
            .uploadCalibrationFileToServer(fileToLink, "video", uploadKey);
        if (uploadedToServer[0] == "true") {
          if (videoFile != null && videoFile!.isNotEmpty) {
            await File(videoFile!).delete();
          }
        } else {
          failedUploadAction(context, "Error on server upload");
        }
      } else {
        failedUploadAction(context, uploadData[1]);
      }
    }

    if (microphoneFile != null && failedUpload == false) {
      spinnerText = "Uploading Microphone..";
      notifyListeners();
      List<String> uploadData =
          await aws.uploadCalibrationFile(microphoneFile!, 'microphone', 'm4a');
      if (uploadData[0] == 'true') {
        String fileToLink = uploadData[1];
        List<String?> uploadedToServer =
            await aws.uploadCalibrationFileToServer(
                fileToLink, "microphone_file", uploadKey);
        if (uploadedToServer[0] == "true") {
          if (microphoneFile != null && microphoneFile!.isNotEmpty) {
            await File(microphoneFile!).delete();
          }
        } else {
          failedUploadAction(context, uploadData[1]);
        }
      } else {
        failedUploadAction(context, uploadData[1]);
      }
    }

    if (failedUpload == false) {
      spinnerText = "Syncing Server..";
      notifyListeners();
      late List<String?> serverSynced;
      var modelName = "";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isWindows) {
        WindowsDeviceInfo windowInfo = await deviceInfo.windowsInfo;
        modelName = windowInfo.productName;
      } else {
        MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
        modelName = macOsDeviceInfo.model;
      }
      try {
        serverSynced = await aws.uploadCalibrationResultsServer(
            selfiesPassed,
            facePassed,
            descriptionPhotoPassed,
            videoPassed,
            microphonePassed,
            soundPassed,
            modelName,
            modelName,
            uploadKey,
            errorMessage);
      } catch (e) {
        serverSynced[0] = "false";
      }

      if (serverSynced[0] == "true") {
        final preferences = await HivePreferences.getInstance();
        if (success) {
          preferences.setIsServiceCalibrated(true);
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => hasAddedPhoto
                  ? DashboardScreen()
                  : InitalStudentPhotoScreen(),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
        } else {
          preferences.setUserId(null);
          preferences.setUserName(null);
          preferences.setUserEmail(null);
          preferences.setUserMobile(null);
          preferences.setIsProfileSetup(null);
          preferences.setIsAccountConfirmed(null);
          preferences.setIsServiceCalibrated(null);
          preferences.setHasAcceptedTerms(null);

          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => LoginScreen()),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      } else {
        failedUploadAction(context, serverSynced[1]);
      }
    }
  }

  Future<String> compressVideoFFmpeg(
      String inputPath, String outputPath) async {
    try {
      final ffmpegPath = path.join(
        Directory.current.path,
        'ffmpeg',
        'ffmpeg.exe',
      );

      final result = await Process.run(ffmpegPath, [
        '-i',
        inputPath,
        '-c:v',
        'libx264',
        '-crf',
        '28',
        '-preset',
        'medium',
        '-c:a',
        'copy',
        outputPath,
      ]);

      if (result.exitCode == 0) {
        await File(inputPath).delete();
        return outputPath;
      } else {
        return inputPath;
      }
    } catch (e) {
      print("THERE WAS AN ERROR: $e");
      return inputPath;
    }
  }

  Future<void> compressVideo(String videoPath) async {
    final info = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
      includeAudio: true,
    );

    final file = File(info!.path!);
    await file.rename(videoPath);
  }

  Future pickVideo(BuildContext context) async {
    /* video*/
    var result;
    if (Platform.isMacOS) {
      final macCamera = Macam();
      String name = Commons.createCryptoRandomString(15);
      var filename = "video-$name";
      String path = await macCamera.openCamera(
          buttonTitle: "Record Video",
          fileName: filename,
          isVideo: true,
          recordingDuration: 8,
          hidden: false);
      result = [true, path];
    } else {
      var status = await Permission.camera.request();
      if (status.isGranted) {
        result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => CameraScreen(true)));
      } else {
        Commons.invigiFlushBarError(context,
            "We need Camera Permission to Start Recoding Video & Selfies.");
        await Future.delayed(Duration(seconds: 3));
        openAppSettings();
      }
    }
    try {
      if (result[0]) {
        if (Platform.isMacOS) {
          await compressVideo(result[1]);
        }
        captureVideo(context, result[1]);
      } else {
        showCameraException(context, result[1]);
      }
    } catch (e) {
      showCameraException(context, e.toString());
    }
  }

  Future pickImage(BuildContext context) async {
    var result;
    if (Platform.isMacOS) {
      String name = Commons.createCryptoRandomString(15);
      var filename = "picture-$name";
      final macCamera = Macam();
      String path = await macCamera.openCamera(
          buttonTitle: "Take Photo", fileName: filename);
      result = [true, path];
    } else {
      result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CameraScreen()));
    }
    try {
      if (result[0]) {
        captureSelfie(context, result[1]);
      } else {
        showCameraException(context, result[1]);
      }
    } catch (e) {
      showCameraException(context, e.toString());
    }
  }

  showCameraException(BuildContext context, String? error) {
    selfiesPassed = false;
    errorMessage = "Error on Camera Exception: $error";
    someCheckHasFailed = true;
    errorAlertNotice(context, "Camera check");
  }

  List<Widget> imagesTakenList(BuildContext context) {
    List<Widget> totalImages = [];
    for (var image in imagesTaken) {
      Padding pad = Padding(
        padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
        child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: FileImage(File(image)), fit: BoxFit.cover))),
      );
      totalImages.add(pad);
    }
    return totalImages;
  }

  void captureSelfie(BuildContext context, imagePath) async {
    if (imagePath != null) {
      try {
        selfieProcessing = false;
        imagesTaken.add(imagePath);
        selfieFile = imagePath;
        notifyListeners();
        await Future.delayed(Duration(seconds: 1));

        if (!someCheckHasFailed) {
          showVideoDialog(context);
        } else {
          selfieProcessing = false;
          notifyListeners();
          failedFaceRecognition = failedFaceRecognition + 1;
          Commons.invigiFlushBarError(context,
              "We could not find your face in this photo, please try again");
          await Future.delayed(Duration(seconds: 5));
          pickImage(context);
        }
      } catch (error, stackTrace) {
        selfiesPassed = false;
        someCheckHasFailed = true;
        errorAlertNotice(context, "selfie check");
        await Sentry.captureException(error, stackTrace: stackTrace);
      }
    }
  }

  void captureVideo(BuildContext context, imagePath) async {
    if (imagePath != null) {
      try {
        selfieProcessing = false;
        final byteData = await rootBundle.load("assets/images/video_icon.png");
        Directory tempDir = await getTemporaryDirectory();
        File tempVideo = File("${tempDir.path}/assets/images/video_icon.png")
          ..createSync(recursive: true)
          ..writeAsBytesSync(byteData.buffer
              .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        imagesTaken.add(tempVideo.path);
        videoFile = imagePath;
        notifyListeners();
        await Future.delayed(Duration(seconds: 2));
        if (!someCheckHasFailed) {
          showCaptureDialog(context);
        } else {
          selfieProcessing = false;
          notifyListeners();
          Commons.invigiFlushBarError(context,
              "We could not find your face in this Video, please try again");
          await Future.delayed(Duration(seconds: 5));
          pickVideo(context);
        }
      } catch (error, stackTrace) {
        videoPassed = false;
        errorMessage = "Error in Video Recording: ${error.toString()}";
        someCheckHasFailed = true;
        errorAlertNotice(context, "Video check");
        await Sentry.captureException(error, stackTrace: stackTrace);
      }
    }
  }

  Future screenCapturePhotos(
    BuildContext context,
  ) async {
    _isAccessAllowed = await ScreenCapturer.instance.isAccessAllowed();
    if (_isAccessAllowed) {
      _handleClickCapture(context);
    } else {
      ScreenCapturer.instance.requestAccess();
      showNoCapturePermissionDialog(context);
    }
  }

  void _handleClickCapture(BuildContext context) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String imageName =
        'Screenshot-${DateTime.now().millisecondsSinceEpoch}.jpg';
    String imagePath = '${directory.path}/$imageName';
    _lastCapturedData = await screenCapturer.capture(
      mode: CaptureMode.screen,
      imagePath: imagePath,
      silent: true,
    );

    try {
      if (_lastCapturedData!.imagePath != null &&
          _lastCapturedData!.imagePath!.isNotEmpty) {
        retryUsed = false;
        await File(_lastCapturedData!.imagePath!).delete();
        microphoneNotice(context);
      } else {
        if (!retryUsed!) {
          screenCapturePhotos(context);
          retryUsed = true;
        } else {
          // There was an error and check to retry screenshot once
          someCheckHasFailed = true;
          errorAlertNotice(context, "Screen Capture check");
        }
      }
    } catch (error, stackTrace) {
      someCheckHasFailed = true;
      errorAlertNotice(context, "Screen Capture check");
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  Future startRecording() async {
    bool permissionsGranted;
    if (Platform.isMacOS) {
      // NOTE: MACOS HAS ISSUE WITH PERMISSIONS AT THIS LEVEL (FREEZES HERE). SO THIS CHECK IS REMOVED FOR MAC
      permissionsGranted = true;
    } else {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.storage,
        Permission.microphone,
      ].request();

      permissionsGranted = permissions[Permission.storage]!.isGranted &&
          permissions[Permission.microphone]!.isGranted;
    }
    String pathRecording = "";
    if (permissionsGranted) {
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String name = Commons.createCryptoRandomString(15);
      pathRecording = appDocDirectory.path + '\\' + "recordings-$name.mp4";
      await _audioRecorder.start(path: pathRecording);
    } else {
      print('Permissions not granted');
    }
  }

  void stopRecording(BuildContext context) async {
    String? path = await _audioRecorder.stop();
    microphoneFile = path;
    await Future.delayed(Duration(seconds: 2));
    alerter.playAlert();
    if (!someCheckHasFailed) {
      soundCheckNotice(context);
    }
  }

  void stopRecordingWindows(BuildContext context) async {
    String? path = await _audioRecorder.stop();
    if (await io.File(path!).exists()) {
      await File(path).delete();
      Timer.run(() => welcomeTut(context));
    } else {
      retryTut(context);
    }
  }

  void closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future microphoneCheckTwoSeconds(BuildContext context) async {
    try {
      bool hasPermissions = await _audioRecorder.hasPermission();
      if (hasPermissions) {
        int totalSeconds = 2;
        startRecording().then((value) => {
              examTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
                if (totalSeconds <= 0) {
                  if (examTimer != null) {
                    examTimer.cancel();
                  }
                  microphoneProcessing = false;
                  notifyListeners();
                  stopRecordingWindows(context);
                } else {
                  microphoneProcessing = true;
                  spinnerText = "Verifying microphone permission..";
                  notifyListeners();
                }
                totalSeconds = totalSeconds - 1;
              })
            });
      } else {
        Commons.invigiFlushBarError(
            context, "We need permission to your microphone before you start.");
      }
    } catch (error, stackTrace) {
      microphonePassed = false;
      errorMessage = "Error on Microphone: ${error.toString()}";
      someCheckHasFailed = true;
      errorAlertNotice(context, "Microphone check");
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  retryTut(BuildContext context) {
    Widget continueButton = Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TextButton(
          child: Text("Retry"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white)),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            microphoneCheckTwoSeconds(context);
          }),
    );

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Please allow permission to your microphone"),
          content: Text(
              "Select Start > Settings > Privacy > Microphone. Please allow\naccess to the microphone on this PC. Select change and\nensure microphone access has been granted to continue."),
          actions: [continueButton],
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
