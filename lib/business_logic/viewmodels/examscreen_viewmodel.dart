import 'dart:convert';
import 'dart:io';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_compression/image_compression.dart';
import 'package:macam/macam.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/providers/exam_provider.dart';
import 'package:invigilatorpc/providers/timer_provider.dart';
import 'package:invigilatorpc/services/general/alert_service.dart';
import 'package:invigilatorpc/ui/camera/camera_screen.dart';
import 'package:invigilatorpc/ui/exam/exam_upload.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'dart:io' as io;
import 'dart:async';
import 'package:location/location.dart' as locationcheck;
import 'package:record/record.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wakelock/wakelock.dart';
import 'package:battery_plus/battery_plus.dart';

class ExamScreenViewModel extends ChangeNotifier {
  bool activationCodeShowing = false;
  var examTimer;
  bool selfieDialogueOpen = false;
  bool descriptionDialogueOpen = false;
  int? start;
  bool isImageLoaded = false;
  String? filePath;
  String? filePathLow;
  bool isImageTwoLoaded = false;
  String? fileTwoPath;
  String? fileTwoPathLow;
  bool isImageThreeLoaded = false;
  String? fileThreePath;
  String? fileThreePathLow;
  bool isImageFourLoaded = false;
  String? fileFourPath;
  String? fileFourPathLow;
  bool selfieProcessing = false;
  Record _audioRecorder = Record();

  bool _isAccessAllowed = false;
  CapturedData? _lastCapturedData;

  // End Selfies
  // Data for collecting on app closure
  List<String?> selfiesCollected = [];
  List<String?> selfiesCollectedLow = [];

  static List<String>? allSelfies = [];

  List<dynamic> itemPhotosCollected = [];
  List<dynamic> itemPhotosCollectedLow = [];

  bool iscurrentPage = false;
  List<String> secondsOutOfApp = [];
  AlertService alerter = AlertService();

  // Out of app time
  int inAppTimeMinutes = 0;
  bool appInBackground = false;

  // Authentication Code
  String? authCode;
  DateTime? codeActivationTime;
  List<String?> collectedAuthData = [];

  // Microphone
  List<dynamic> recordings = [];

  // Videos
  static List<dynamic> videos = [];

  // screenCapture
  List<dynamic> screenCapture = [];

  bool hasDoneNoiseCheck = false;
  int uniqueDecibelsFound = 99; // Preset to 99 in case nothing

  // Passed Variables
  String? title = "";
  int? selfieAmount = 0;
  bool hasMicCheck = false;
  int? examLength;
  bool? selfieCheck;
  bool? codeRequired;
  bool? examResuming;
  int? microphoneAmount;
  List<String>? itemPhotoDesc;

  var jsonRes;

  int? recordingDuration;
  DateTime? startTime;
  bool? canFinishEarly;

  // Video
  bool? videoCheck;
  int? videoAmount;
  bool? retryUsed = false;

  //screen capture amount
  bool? screenCaptureCheck;
  int? screenCaptureAmount;

  // Timer
  int? currentTimer;
  int? updatedTime;
  DateTime? _examStartedAt;
  int? totalExamLength;
  bool examFinished = false;

  bool timerStarted = false;
  List checkIntervals = [];
  bool examResumeChecked = false;

  // Item Photo Descriptions
  bool descriptivePhotoTaken = false;
  String? descriptivePhoto1;
  String? descriptivePhoto2;
  String? descriptivePhoto3;
  String? descriptivePhoto4;

  String? descriptivePhotoLow1;
  String? descriptivePhotoLow2;
  String? descriptivePhotoLow3;
  String? descriptivePhotoLow4;

  bool openDescriptiveImage = false;

  DateTime? leftAppTime;
  bool canCalculateLeftApp = false;

  // Build Context
  BuildContext? currContext;
  bool finishedExam = false;

  bool? isInVenue = false;

  String? studentNumber = "";
  bool? lowMemory = false;
  late var preferences;

// Battery
  var battery = Battery();
  bool batteryCharging = false;

  String? examPassword = "";
  final GeolocatorPlatform geolocatorWindows = GeolocatorPlatform.instance;

  void getStudentNumber() async {
    final preferences = await HivePreferences.getInstance();
    studentNumber = preferences.getStudentNum();
    Commons.studentNumber = studentNumber;
    notifyListeners();
  }

  void initPreferences() async {
    preferences = await HivePreferences.getInstance();
    lowMemory = preferences.getIsLowMemory() ?? false;
    examPassword = preferences.getStartPassword() ?? "";
  }

  void batteryCheck(BuildContext context) async {
    var level = await battery.batteryLevel;
    if (level <= 30 && batteryCharging) {
      await Commons.setBrightness(0.7);
      Commons.invigiFlushBarError(
          context, "Please plug your Laptop or PC into charger!");
    }
  }

  void updateMinutesInApp(int minutesInApp) async {
    preferences = await HivePreferences.getInstance();
    preferences.setMinutesInApp(minutesInApp);
  }

  void initExamScreen(BuildContext context) async {
    battery.onBatteryStateChanged.listen((BatteryState state) {
      batteryCharging = (state == BatteryState.discharging);
      print("state name"+state.name);
      print("batteryCharging "+batteryCharging.toString());
    });
    await Commons.setBrightness(0.7);
    initPreferences();
    getStudentNumber();
    if (this.examResuming! && examResumeChecked == false) {
      resumeExamChecks(context);
      notifyListeners();
    } else {
      if (timerStarted == false) {
        start = examLength;
        DateTime currentTime = Commons.currentTime();
        int difference = currentTime.difference(this.startTime!).inMinutes;
        var minutesLeft = examLength! - difference;
        currentTimer = minutesLeft;
        updatedTime = currentTimer;
        Provider.of<TimerProvider>(context, listen: false).timeUpdValue =
            updatedTime;
        if (currentTimer! <= 0) {
          storeGPSCoords();
          finishExam(context);
        } else {
          authCode = Commons.createRandomCode();
          var randomChecksProvider =
              Provider.of<ExamProvider>(context, listen: false);
          checkIntervals = randomChecksProvider.generateRandomForChecks(
              minutesLeft, totalChecksRemaining);
          setExamDetails();
          startTimer(context);
        }
        notifyListeners();
      }
    }
  }

  void intervalCheck(BuildContext context) async {
    var timerProvider = Provider.of<TimerProvider>(context, listen: false);
    var examProvider = Provider.of<ExamProvider>(context, listen: false);
    updatedTime =
        timerProvider.updateTimeForCheck(_examStartedAt!, totalExamLength!);
    timerProvider.timeUpdValue = updatedTime;
    notifyListeners();

    // App Time
    if (!appInBackground) {
      inAppTimeMinutes = inAppTimeMinutes + 1;
      updateMinutesInApp(inAppTimeMinutes);
    }

    // Close Selfie Dialogue if open
    if (selfieDialogueOpen || descriptionDialogueOpen) {
      addSelfieExceptionFile("Student Missed Selfie");
      selfieDialogueOpen = false;
      descriptionDialogueOpen = false;
      Navigator.pop(context);
    }
    if (updatedTime! <= 0) {
      storeGPSCoords();
      finishExam(context);
    } else if (checkIntervals.contains(updatedTime)) {
      if (recordings.length == 0 && microphoneAmount! > 0) {
        examProvider.checkMicrophone(updatedTime, this.hasMicCheck,
            stopRecording, recordingDuration, failedStopRecording);
      } else if (selfieAmount! > 0 && !isImageLoaded) {
        await Commons.setBrightness(0.7);
        playNotification();
        showSelfiePhotoDialog(context, updatedTime);
      } else if (selfieAmount! >= 2 && !isImageTwoLoaded) {
        await Commons.setBrightness(0.7);
        playNotification();
        showSelfiePhotoDialog(context, updatedTime);
      } else if (videos.length < videoAmount!) {
        recordVideo(context, updatedTime);
      } else if (screenCapture.length < screenCaptureAmount!) {
        screenCapturePhotos(context, updatedTime);
      } else if (recordings.length == 1 && microphoneAmount! >= 2) {
        examProvider.checkMicrophone(updatedTime, this.hasMicCheck,
            stopRecording, recordingDuration, failedStopRecording);
      } else if (recordings.length == 2 && microphoneAmount! >= 3) {
        examProvider.checkMicrophone(updatedTime, this.hasMicCheck,
            stopRecording, recordingDuration, failedStopRecording);
      } else if (selfieAmount! >= 3 && !isImageThreeLoaded) {
        await Commons.setBrightness(0.7);
        playNotification();
        showSelfiePhotoDialog(context, updatedTime);
      } else if (recordings.length == 3 && microphoneAmount! >= 4) {
        examProvider.checkMicrophone(updatedTime, this.hasMicCheck,
            stopRecording, recordingDuration, failedStopRecording);
      } else if (selfieAmount! >= 4 && !isImageFourLoaded) {
        await Commons.setBrightness(0.7);
        playNotification();
        showSelfiePhotoDialog(context, updatedTime);
      } else if (recordings.length < microphoneAmount!) {
        examProvider.checkMicrophone(updatedTime, this.hasMicCheck,
            stopRecording, recordingDuration, failedStopRecording);
      }
      checkIntervals.remove(updatedTime);
    } else {
      currentTimer = updatedTime;
      batteryCheck(context);
    }
  }

  void startTimer(BuildContext context) {
    examTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      intervalCheck(context);
    });
  }

  void storeGPSCoords() async {
    if (Platform.isMacOS) {
      locationcheck.Location location = locationcheck.Location();
      bool _serviceEnabled = await location.serviceEnabled();
      if (_serviceEnabled) {
        try {
          var pos =
              await location.getLocation().timeout(const Duration(seconds: 25));
          final preferences = await HivePreferences.getInstance();
          preferences.setLatitude(pos.latitude!);
          preferences.setLongitude(pos.longitude!);
        } catch (error, stackTrace) {
          await Sentry.captureException(error, stackTrace: stackTrace);
        }
      }
    } else {
      try {
        checkConnection().then((isConnected) async {
          if (isConnected) {
            Position pos = await geolocatorWindows
                .getCurrentPosition()
                .timeout(const Duration(seconds: 30));

            final preferences = await HivePreferences.getInstance();
            preferences.setLatitude(pos.latitude);
            preferences.setLongitude(pos.longitude);
          }
        });
      } catch (error, stackTrace) {
        await Sentry.captureException(error, stackTrace: stackTrace);
      }
    }
  }

  void updateExitedAppTime(DateTime currentTime) async {
    final preferences = await HivePreferences.getInstance();
    preferences.setClosedAppAt(currentTime);
  }

  void updateTimerAfterBackground(BuildContext context) async {
    var timerProvider = Provider.of<TimerProvider>(context, listen: false);
    var minutesLeft =
        await timerProvider.timerUpdAfterBackground(_examStartedAt!);

    if (minutesLeft <= 0) {
      storeGPSCoords();
      finishExam(context);
    } else {
      await Commons.setBrightness(0.7);
      currentTimer = minutesLeft;
    }
    notifyListeners();
  }

  void finishExam(BuildContext context) async {
    try {
      finishedExam = true;
      notifyListeners();
      examTimer?.cancel();
      examFinished = true;
      final preferences = await HivePreferences.getInstance();
      preferences.setExamFinished(true);
      String profilePicture = "";

      try {
        profilePicture = preferences.getProfileUrl() ?? "";
        preferences.setProfileUrl(profilePicture);
        String storageLocation =
            (await getApplicationDocumentsDirectory()).path;
        await FastCachedImageConfig.init(
            subDir: storageLocation,
            clearCacheAfter: const Duration(days: 365));
        Commons.profilePicture = profilePicture;
      } catch (e) {}
      resetTimer(context);
      // Add fields for Out of app time
      var timerProvider = Provider.of<TimerProvider>(context, listen: false);
      var updatedTime =
          timerProvider.updateTimeForCheck(_examStartedAt, totalExamLength);
      await preferences.setExamLength(totalExamLength);
      await preferences.setMinutesLeft(updatedTime);

      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ExamUpload(
            filePath,
            fileTwoPath,
            fileThreePath,
            fileFourPath,
            selfieAmount,
            hasMicCheck,
            recordings,
            uniqueDecibelsFound,
            videoCheck,
            videos,
            screenCaptureCheck,
            screenCapture,
            itemPhotosCollected,
            itemPhotosCollectedLow,
            authCode,
            codeActivationTime,
            secondsOutOfApp,
            false,
            [],
            false,
            profilePicture,
            title!,
          ),
        ),
        (route) => false, //if you want to disable back feature set to false
      );
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  void resetTimer(BuildContext context) {
    var timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.timeUpdValue = 0;
  }

  Future playNotification() async {
    if (!isInVenue!) alerter.playAlert();
  }

  void showActivation() async {
    codeActivationTime = Commons.currentTime();
    collectedAuthData = [codeActivationTime.toString(), authCode];
    final preferences = await HivePreferences.getInstance();
    preferences.setExamAuthCode(collectedAuthData);
    activationCodeShowing = true;
    notifyListeners();
  }

  bool tappedNew = false;

  Future failedStopRecording(String error) async {
    String rec = "Error: $error";
    recordings.add(rec);
    updateMicrophoneStored();
    try {
      await _audioRecorder.stop();
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  Future stopRecording() async {
    try {
      String? path = await _audioRecorder.stop();
      recordings.add(path);
      updateMicrophoneStored();
    } catch (error, stackTrace) {
      String rec = "Error: ${error.toString()}";
      recordings.add(rec);
      updateMicrophoneStored();
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  void setExamDetails() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setCurrentExam([
      this.title,
      this.examLength.toString(),
      this.selfieCheck.toString(),
      this.selfieAmount.toString(),
      this.hasMicCheck.toString(),
      this.microphoneAmount.toString(),
      json.encode(this.itemPhotoDesc),
      this.codeRequired.toString(),
      this.startTime.toString(),
      "",
      this.recordingDuration.toString(),
      "",
      this.startTime.toString(),
      this.canFinishEarly.toString(),
      this.videoCheck.toString(),
      this.videoAmount.toString(),
      this.screenCaptureCheck.toString(),
      this.screenCaptureAmount.toString()
    ]);
    _examStartedAt = this.startTime;
    totalExamLength = examLength;
  }

  void updateMicrophoneStored() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setExamRecordings(recordings);
  }

  void updateVideoStored() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setExamVideos(videos);
  }

  void updateScreenCapturedPhotosStored() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setExamScreenCapturingPhotos(screenCapture);
  }

  void updateSelfiesStored() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setExamSelfies(selfiesCollected);
  }

  void updateSelfiesLowStored() async {
    final preferences = await HivePreferences.getInstance();
    preferences.setExamSelfiesLow(selfiesCollectedLow);
  }

  void addSelfieExceptionFile(String? exc) async {
    if (isImageLoaded == false && selfieAmount! > 0) {
      filePath = "Error: $exc";
      filePathLow = "Error: $exc";
      isImageLoaded = true;
      selfiesCollected.add(filePath);
      selfiesCollectedLow.add(filePathLow);
      updateSelfiesStored();
      updateSelfiesLowStored();
    } else if (isImageTwoLoaded == false && selfieAmount! >= 2) {
      fileTwoPath = "Error: $exc";
      isImageTwoLoaded = true;
      selfiesCollected.add(fileTwoPath);
      selfiesCollectedLow.add(fileTwoPathLow);
      updateSelfiesStored();
      updateSelfiesLowStored();
    } else if (isImageThreeLoaded == false && selfieAmount! >= 3) {
      fileThreePath = "Error: $exc";
      isImageThreeLoaded = true;
      selfiesCollected.add(fileThreePath);
      selfiesCollectedLow.add(fileThreePathLow);
      updateSelfiesStored();
      updateSelfiesLowStored();
    } else if (isImageFourLoaded == false && selfieAmount! >= 4) {
      fileFourPath = "Error: $exc";
      isImageFourLoaded = true;
      selfiesCollected.add(fileFourPath);
      selfiesCollectedLow.add(fileFourPathLow);
      updateSelfiesStored();
      updateSelfiesLowStored();
    }
    notifyListeners();
  }

  void captureSelfie(BuildContext context, imagePath, int? currentTime) async {
    try {
      if (imagePath != null) {
        selfieProcessing = false;
        if (isImageLoaded == false && selfieAmount! > 0) {
          filePath = imagePath;
          isImageLoaded = true;
          currentTimer = currentTime;
          selfiesCollected.add(imagePath);
          allSelfies!.add(imagePath);
          updateSelfiesStored();
          updateSelfiesLowStored();
        } else if (isImageTwoLoaded == false && selfieAmount! >= 2) {
          fileTwoPath = imagePath;
          isImageTwoLoaded = true;
          currentTimer = currentTime;
          selfiesCollected.add(imagePath);
          allSelfies!.add(imagePath);
          updateSelfiesStored();
          updateSelfiesLowStored();
        } else if (isImageThreeLoaded == false && selfieAmount! >= 3) {
          fileThreePath = imagePath;
          isImageThreeLoaded = true;
          currentTimer = currentTime;
          selfiesCollected.add(imagePath);
          allSelfies!.add(imagePath);
          updateSelfiesStored();
          updateSelfiesLowStored();
        } else if (isImageFourLoaded == false && selfieAmount! >= 4) {
          fileFourPath = imagePath;
          isImageFourLoaded = true;
          currentTimer = currentTime;
          selfiesCollected.add(imagePath);
          allSelfies!.add(imagePath);
          updateSelfiesStored();
          updateSelfiesLowStored();
        }
        notifyListeners();
        await Commons.setBrightness(0.7);
        if (finishedExam == true || isInVenue == true) {
          showActionsLeft(context);
        }
      } else {
        selfieProcessing = false;
        notifyListeners();
        Commons.invigiFlushBarError(context,
            "We could not find your face in this photo, please try again");
        await Future.delayed(Duration(seconds: 5));
        pickImage(context, currentTime);
      }
      await Future.delayed(Duration(seconds: 5));
      Wakelock.toggle(enable: true);
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      selfieProcessing = false;
      notifyListeners();
      Commons.invigiFlushBarError(context,
          "Something went wrong on taking the selfie, please try again. Error: ${error.toString()}");
      await Future.delayed(Duration(seconds: 6));
      pickImage(context, currentTimer);
    }
  }

  Future recordVideo(
    BuildContext context,
    int? currentTime,
  ) async {
    var result;

    if (Platform.isMacOS) {
      final macCamera = Macam();
      String name = Commons.createCryptoRandomString(15);
      var filename = "video-$name";
      String path = await macCamera.openCamera(
          buttonTitle: "Record Video",
          fileName: filename,
          isVideo: true,
          recordingDuration: 11,
          hidden: true);
      result = [true, path];
    } else {
      result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CameraScreen(true, true, currentTime, title)));
    }
    try {
      if (result[0]) {
        retryUsed = false;
        videos.add(result[1]);
        updateVideoStored();
      } else {
        if (!retryUsed!) {
          recordVideo(context, currentTime);
          retryUsed = true;
        } else {
          // There was an error and check to retry recording once
          videos.add("Error: ${result[1]}");
          retryUsed = false;
          updateVideoStored();
        }
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      videos.add("Error: There was an error trying to store the video");
      updateVideoStored();
    }
  }

  Future screenCapturePhotos(
    BuildContext context,
    int? currentTime,
  ) async {
    try {
      _handleClickCapture(context, currentTime);
    } catch (e) {
      screenCapture
          .add("Error: There was an error trying to capture the screenshot");
      updateScreenCapturedPhotosStored();
    }
  }

  Future<File> writeToFile(Uint8List data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _handleClickCapture(BuildContext context, int? currentTime) async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String imageName =
          'Screenshot-${DateTime.now().millisecondsSinceEpoch}.png';
      String imagePath = '${directory.path}/$imageName';
      _lastCapturedData = await ScreenCapturer.instance.capture(
        mode: CaptureMode.screen,
        imagePath: imagePath,
        silent: true,
      );

      if (_lastCapturedData!.imagePath != null &&
          _lastCapturedData!.imagePath!.isNotEmpty) {
        retryUsed = false;
        String screenshotPath = _lastCapturedData!.imagePath!;
        if (Platform.isMacOS) {
          try {
            final file = File(_lastCapturedData!.imagePath!);
            final input = ImageFile(
              rawBytes: file.readAsBytesSync(),
              filePath: file.path,
            );
            var output = compress(ImageFileConfiguration(input: input));

            String compimageName =
                'compressedScreenshot-${DateTime.now().millisecondsSinceEpoch}.jpg';
            String compimagePath = '${directory.path}/$compimageName';
            File compressedScreen =
                await writeToFile(output.rawBytes, compimagePath);
            screenshotPath = compressedScreen.path;
          } catch (error, stackTrace) {
            print("UNABLE TO COMPRESS: $error");
            await Sentry.captureException(error, stackTrace: stackTrace);
          }
        }
        screenCapture.add(screenshotPath);
        updateScreenCapturedPhotosStored();
      } else {
        if (!retryUsed!) {
          screenCapturePhotos(context, currentTime);
          retryUsed = true;
        } else {
          // There was an error and check to retry screenshot once
          screenCapture.add(
              "Error: There was an error trying to capture the screenshot");
          retryUsed = false;
          updateScreenCapturedPhotosStored();
        }
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      screenCapture
          .add("Error: There was an error trying to capture the screenshot");
      updateScreenCapturedPhotosStored();
    }
  }

  Future pickImage(
    BuildContext context,
    int? currentTime,
  ) async {
    var result;
    if (Platform.isMacOS) {
      String name = Commons.createCryptoRandomString(15);
      var filename = "picture-$name";
      final macCamera = Macam();
      String path = await macCamera.openCamera(
          buttonTitle: "Take Photo", fileName: filename);
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
    selfieDialogueOpen = false;
    try {
      if (result[0]) {
        captureSelfie(context, result[1], currentTime);
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  showActionsLeft(BuildContext context) async {
    await Commons.setBrightness(1);
    List<Widget> actionsLeft = [];
    // All Checks
    if (selfieAmount! > 0 && !isImageLoaded) {
      actionsLeft.add(selfieAlertWidget(context, "Take Selfie 1"));
    } else if (selfieAmount! >= 2 && !isImageTwoLoaded) {
      actionsLeft.add(selfieAlertWidget(context, "Take Selfie 2"));
    } else if (selfieAmount! >= 3 && !isImageThreeLoaded) {
      actionsLeft.add(selfieAlertWidget(context, "Take Selfie 3"));
    } else if (selfieAmount! >= 4 && !isImageFourLoaded) {
      actionsLeft.add(selfieAlertWidget(context, "Take Selfie 4"));
    }

    String desc = "";
    String title = "";
    title = actionsLeft.length == 0
        ? 'Continue to upload'
        : 'You have a few checks still required';
    desc = actionsLeft.length == 0
        ? 'You have performed all the checks\nand can continue to upload'
        : 'You still have to complete these checks\nbefore you can continue to upload';

    if (actionsLeft.length == 0 && finishedExam) {
      Widget btn = Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton(
            child: Text("Finish"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(kPrimaryColor),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              storeGPSCoords();
              finishExam(context);
            },
          ));
      actionsLeft.add(btn);
    }

    if (actionsLeft.length == 0 && isInVenue! && !finishedExam) {
      desc = 'You have performed all the checks and can continue your exam.';
      title = 'Continue your exam';
      Widget btn = TextButton(
        child: Text("Continue"),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(kPrimaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          await Commons.setBrightness(0.7);
        },
      );
      actionsLeft.add(btn);
    }

    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text(title),
          content: Text(desc),
          actions: actionsLeft,
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

  Widget selfieAlertWidget(BuildContext context, String buttonText) {
    Widget btn = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text(buttonText),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            showSelfiePhotoDialog(context, currentTimer);
          },
        ));
    return btn;
  }

  finishEarly(BuildContext context) {
    finishedExam = true;
    showActionsLeft(context);
  }

  areYouSureFinishedAlert(BuildContext context) async {
    await Commons.setBrightness(1);
    Widget continueButton = TextButton(
      child: Text("Yes, I am finished"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(kPrimaryColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        finishEarly(context);
      },
    );

    Widget cancelButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("No, Cancel", style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey)),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            await Commons.setBrightness(0.7);
          },
        ));
    WillPopScope alert = WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          title: Text("Are you sure you are finished with your exam?"),
          content: Text(
              "By finishing early you must make sure you have submitted \nyour exam. These finish times will be compared."),
          actions: [continueButton, cancelButton],
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

  showSelfiePhotoDialog(context, current) {
    closeKeyboard();
    // set up the button
    Widget continueButton = Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: TextButton(
          child: Text("Take a selfie"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kPrimaryColor),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
            pickImage(context, current);
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

    // show the dialog
    selfieDialogueOpen = true;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  List<Widget> otherImages(size) {
    return <Widget>[
      // Description Photos
      descriptivePhoto1 != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: size.width * .14,
                  width: size.width * .14,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(io.File(!lowMemory!
                              ? descriptivePhoto1!
                              : descriptivePhotoLow1!)),
                          fit: BoxFit.cover))),
            )
          : Container(),
      descriptivePhoto2 != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: size.width * .14,
                  width: size.width * .14,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(io.File(!lowMemory!
                              ? descriptivePhoto2!
                              : descriptivePhotoLow2!)),
                          fit: BoxFit.cover))),
            )
          : Container(),

      descriptivePhoto3 != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: size.width * .14,
                  width: size.width * .14,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(io.File(!lowMemory!
                              ? descriptivePhoto3!
                              : descriptivePhotoLow3!)),
                          fit: BoxFit.cover))),
            )
          : Container(),

      descriptivePhoto4 != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: size.width * .14,
                  width: size.width * .14,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(io.File(!lowMemory!
                              ? descriptivePhoto4!
                              : descriptivePhotoLow4!)),
                          fit: BoxFit.cover))),
            )
          : Container(),
    ];
  }

  List<Widget> selfies(count, size) {
    return <Widget>[
      isImageLoaded && !(filePath!.contains("Error"))
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(File(filePath!)),
                          fit: BoxFit.cover))),
            )
          : Container(),
      isImageTwoLoaded && !(fileTwoPath!.contains("Error"))
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(File(fileTwoPath!)),
                          fit: BoxFit.cover))),
            )
          : Container(),
      isImageThreeLoaded && !(fileThreePath!.contains("Error"))
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(File(fileThreePath!)),
                          fit: BoxFit.cover))),
            )
          : Container(),
      isImageFourLoaded && !(fileFourPath!.contains("Error"))
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(File(fileFourPath!)),
                          fit: BoxFit.cover))),
            )
          : Container(),
    ];
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Not ready", style: TextStyle(color: Colors.white)),
      style:
          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text("Show me"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(kPrimaryColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        // showActivation();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Warning!"),
      content: Text(
          "Are you sure you are on the question to enter your Exam One Time Pin?"),
      actions: [
        cancelButton,
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

  int totalChecksRemaining() {
    int total = 0;

    if (this.hasMicCheck) {
      total = total + (microphoneAmount! - recordings.length);
    }

    if (this.videoCheck!) {
      total = total + (videoAmount! - videos.length);
    }
    if (this.screenCaptureCheck!) {
      total = total + (screenCaptureAmount! - screenCapture.length);
    }

    if (this.selfieCheck!) {
      if (isImageLoaded == false && selfieAmount! > 0) {
        total = total + 1;
      }
      if (isImageTwoLoaded == false && selfieAmount! >= 2) {
        total = total + 1;
      }
      if (isImageThreeLoaded == false && selfieAmount! >= 3) {
        total = total + 1;
      }
      if (isImageFourLoaded == false && selfieAmount! >= 4) {
        total = total + 1;
      }
    }
    return total;
  }

  void checkTimeOutOfApp(DateTime currentTime) async {
    if (leftAppTime == null || canCalculateLeftApp == false) {
      return;
    }
    var difference = currentTime.difference(leftAppTime!).inSeconds;
    if (difference >= 30) {
      secondsOutOfApp.add(difference.toString());
      final preferences = await HivePreferences.getInstance();
      preferences.setSecondOutOfApp(secondsOutOfApp);

      String currAudit = preferences.getTimeOutAudit() ?? "";
      String timeAudit = currAudit + "$leftAppTime - $currentTime | ";
      preferences.setTimeOutAudit(timeAudit);
    }
  }

  void closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void checkInVenue(BuildContext context) async {
    final preferences = await HivePreferences.getInstance();
    isInVenue = preferences.getInVenue() ?? false;

    if (isInVenue!) {
      if (!selfieCheck!) {
        selfieAmount = 1;
        selfieCheck = true;
      }
      showSelfiePhotoDialog(context, currentTimer);
    }
  }

  void resumeExamChecks(BuildContext context) async {
    var examProvider = Provider.of<ExamProvider>(context, listen: false);
    var startedAt = await examProvider.examStartedTime();
    _examStartedAt = startedAt;
    totalExamLength = await examProvider.examTotalLength();

    int minutesLeft = await examProvider.examMinutesLeft(examLength!);

    final preferences = await HivePreferences.getInstance();
    examResumeChecked = true;
    // Out of app time
    inAppTimeMinutes = preferences.getMinutesInApp() ?? 0;
    List<dynamic>? selfiesInMemory = preferences.getExamSelfies() ?? null;

    // Selfies
    if (selfiesInMemory != null) {
      if (selfiesInMemory.length > 0) {
        filePath = selfiesInMemory[0];
        isImageLoaded = true;
        allSelfies!.add(filePath!);
      }

      if (selfiesInMemory.length >= 2) {
        fileTwoPath = selfiesInMemory[1];
        isImageTwoLoaded = true;
        allSelfies!.add(fileTwoPath!);
      }

      if (selfiesInMemory.length >= 3) {
        fileThreePath = selfiesInMemory[2];
        isImageThreeLoaded = true;
        allSelfies!.add(fileThreePath!);
      }

      if (selfiesInMemory.length >= 4) {
        fileFourPath = selfiesInMemory[3];
        isImageFourLoaded = true;
        allSelfies!.add(fileFourPath!);
      }
      notifyListeners();
    }

    String storageLocation = (await getApplicationDocumentsDirectory()).path;
    await FastCachedImageConfig.init(
        subDir: storageLocation, clearCacheAfter: const Duration(days: 365));

    // Item Photos
    List<dynamic> itemPhotosInMemory = preferences.getItemPhotos() ?? [];
    List<dynamic> itemPhotosInMemoryLow = preferences.getItemPhotosLow() ?? [];

    itemPhotosCollected = itemPhotosInMemory;
    itemPhotosCollectedLow = itemPhotosInMemoryLow;

    if (itemPhotosInMemory.isNotEmpty) {
      if (itemPhotosInMemory.length > 0) {
        descriptivePhotoTaken = true;
        descriptivePhoto1 = itemPhotosInMemory[0];
        descriptivePhotoLow1 = itemPhotosInMemoryLow[0];
      }

      if (itemPhotosInMemory.length >= 2) {
        descriptivePhotoTaken = true;
        descriptivePhoto2 = itemPhotosInMemory[1];
        descriptivePhotoLow2 = itemPhotosInMemoryLow[1];
      }

      if (itemPhotosInMemory.length >= 3) {
        descriptivePhotoTaken = true;
        descriptivePhoto3 = itemPhotosInMemory[2];
        descriptivePhotoLow3 = itemPhotosInMemoryLow[2];
      }

      if (itemPhotosInMemory.length >= 4) {
        descriptivePhotoTaken = true;
        descriptivePhoto4 = itemPhotosInMemory[3];
        descriptivePhotoLow4 = itemPhotosInMemoryLow[3];
      }
    }

    // Microphone
    if (this.hasMicCheck) {
      recordings = preferences.getExamRecordings() ?? [];
      uniqueDecibelsFound = preferences.getUniqueDecibelsFound() ?? 99;
      if (uniqueDecibelsFound != 99) {
        hasDoneNoiseCheck = true;
      }
    }
    // Videos
    if (this.videoCheck!) {
      videos = preferences.getExamVideos() ?? [];
    }
    //ScreenShots
    if (this.screenCaptureCheck!) {
      screenCapture = preferences.getExamScreenCapturingPhotos() ?? [];
    }
    // Seconds Out of App
    secondsOutOfApp = preferences.getSecondOutOfApp() ?? [];
    // Auth Code
    List<dynamic>? authCodeData = preferences.getExamAuthCode() ?? null;

    if (authCodeData != null) {
      codeActivationTime = DateTime.parse(authCodeData[0]);
      authCode = authCodeData[1];
      activationCodeShowing = true;
    } else {
      authCode = Commons.createRandomCode();
    }

    start = minutesLeft;
    examLength = minutesLeft;
    bool finishedLogged = preferences.getExamFinished() ?? false;
    if (minutesLeft <= 0 || finishedLogged) {
      storeGPSCoords();
      finishExam(context);
    } else {
      currentTimer = minutesLeft;
      // Remember to check if 0 also to just upload and to check for auth code
      var randomChecksProvider =
          Provider.of<ExamProvider>(context, listen: false);
      checkIntervals = randomChecksProvider.generateRandomForChecks(
          minutesLeft, totalChecksRemaining);
      intervalCheck(context);
      startTimer(context);
    }

    try {
      var closedTime = preferences.getClosedAppAt() ?? Commons.currentTime();
      leftAppTime = closedTime;
      canCalculateLeftApp = true;
      var t = Commons.currentTime();
      checkTimeOutOfApp(t);
      canCalculateLeftApp = false;
      appInBackground = false;
      preferences.setClosedAppAt(null);
    } catch (e) {}
    notifyListeners();
  }
}
