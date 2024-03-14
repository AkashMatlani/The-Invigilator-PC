import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:record/record.dart';

class ExamProvider extends ChangeNotifier {
  Record _audioRecorder = Record();
  int? cameraForType;
  bool? cameraOpen;
  int? _current;
  bool? _hasMicCheck;
  int? _currentTime;
  List? cameras;
  int? _selectedCameraIndex;
  bool microphoneProcessing = false;

  int? get selectedCameraIndex => _selectedCameraIndex;
  bool _isWebViewOpen = false;
  bool _isPDFViewOpen = false;
  String spinnerText = "Verifying...";
  String? microphoneFile;

  set selectedCameraIndex(int? value) {
    _selectedCameraIndex = value;
    notifyListeners();
  }

  set isWebViewOpen(bool value) {
    _isWebViewOpen = value;
    notifyListeners();
  }

  set isPDFViewOpen(bool value) {
    _isPDFViewOpen = value;
  }

  bool get isWebViewOpen => _isWebViewOpen;

  bool get isPDFViewOpen => _isPDFViewOpen;

  bool getIsWebViewOpen() {
    return _isWebViewOpen;
  }

  void initializeCamera(
      index, Future cameraError(dynamic error, StackTrace stackTrace)) {}

  Future<io.File> savedImage(
    io.File compressedFile,
  ) async {
    io.Directory appDir;
    appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(compressedFile.path);
    final savedImage = await compressedFile.copy('${appDir.path}/$fileName');
    return savedImage;
  }

  Future<DateTime> examStartedTime() async {
    final preferences = await HivePreferences.getInstance();
    List<dynamic>? examDetails = preferences.getCurrentExam();
    DateTime startedAt = DateTime.parse(examDetails![8]);
    return startedAt;
  }

  Future<int> examTotalLength() async {
    final preferences = await HivePreferences.getInstance();
    List<dynamic>? examDetails = preferences.getCurrentExam();
    int totalExamLength = int.parse(examDetails![1]);
    return totalExamLength;
  }

  Future<int> examMinutesLeft(int examLength) async {
    final preferences = await HivePreferences.getInstance();
    List<dynamic>? examDetails = preferences.getCurrentExam();
    DateTime startedAt = DateTime.parse(examDetails![8]);

    DateTime currentTime = Commons.currentTime();

    int difference = currentTime.difference(startedAt).inMinutes;
    int minutesLeft = examLength - difference;

    return minutesLeft;
  }

  int? get currentTime => _currentTime;

  set currentTime(int? value) {
    _currentTime = value;
    notifyListeners();
  }

  bool? get hasMicCheck => _hasMicCheck;

  int? get current => _current;

  set current(int? value) {
    _current = value;
    notifyListeners();
  }

  var micTimer;

  Future checkMicrophone(
      int? currentTime,
      bool hasMicCheck,
      Future stopRecording(),
      int? recordingTime,
      Future failedStopRecording(String error)) async {
    if (hasMicCheck == true) {
      try {
        await startRecording().timeout(Duration(seconds: 45));
        await Future.delayed(Duration(seconds: recordingTime!));
        stopRecording();
      } catch (e) {
        failedStopRecording(e.toString());
      }
    }
    current = currentTime;
  }

  List generateRandomForChecks(int examLength, int totalchecksRemaining()) {
    if (examLength <= 1) {
      return [];
    }
    List numbers = [];
    int minUsed = (0.3 * examLength).toInt() - 1;
    if (minUsed < 1) {
      minUsed = 1;
    }
    int max = examLength - 1;
    int min = minUsed;
    int breakpoint = max - min;

    if (breakpoint == 0) {
      return [];
    }
    do {
      var rn = new Random();
      var num = min + rn.nextInt(max - min);
      if (!numbers.contains(num)) {
        numbers.add(num);
      }
    } while (numbers.length != totalchecksRemaining() &&
        numbers.length != breakpoint);
    numbers.shuffle();
    //print("INTERVALS ARE: $numbers");
    return numbers;
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
}
