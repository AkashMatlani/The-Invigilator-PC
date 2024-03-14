import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:invigilatorpc/ui/camera/exam_layout.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'dart:io';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';

//ignore: must_be_immutable
class CameraScreen extends StatefulWidget {
  bool? isVideo;
  bool? isExamVideo;
  int? examMinsLeft;
  String? profileTitle;

  CameraScreen(
      [this.isVideo, this.isExamVideo, this.examMinsLeft, this.profileTitle]);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> _cameras = <CameraDescription>[];
  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;
  bool _recording = false;
  bool _recordingTimed = false;
  bool _recordAudio = true;
  Size? _previewSize;
  ResolutionPreset _resolutionPreset = ResolutionPreset.high;
  StreamSubscription<CameraErrorEvent>? _errorStreamSubscription;
  StreamSubscription<CameraClosingEvent>? _cameraClosingStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _fetchCameras();
    loadDLL();
    if (widget.isExamVideo == null) {
      widget.isExamVideo = false;
      widget.examMinsLeft = 0;
    }
  }

  @override
  void dispose() {
    _disposeCurrentCamera();
    _errorStreamSubscription?.cancel();
    _errorStreamSubscription = null;
    _cameraClosingStreamSubscription?.cancel();
    _cameraClosingStreamSubscription = null;
    super.dispose();
  }

  /// Fetches list of available cameras from camera_windows plugin.
  Future<void> _fetchCameras() async {
    String cameraInfo;
    List<CameraDescription> cameras = <CameraDescription>[];

    int cameraIndex = 0;
    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        cameraInfo = 'No available cameras';
      } else {
        cameraIndex = _cameraIndex % cameras.length;
        cameraInfo = 'Found camera: ${cameras[cameraIndex].name}';
      }
    } on PlatformException catch (e) {
      cameraInfo = 'Failed to get cameras: ${e.message}';
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                title: Text('Error'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Code: ${e.code}'),
                    Text('Message: ${cameraInfo}'),
                  ],
                ),
                actions: [
                  Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: TextButton(
                        child: Text('Continue'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          FastCachedImageConfig.clearAllCachedImages();
                          Commons.removeAllExamData();
                          HivePreferences.deleteAllPreferences();
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => LoginScreen(),
                            ),
                            (route) =>
                                false, //if you want to disable back feature set to false
                          );
                        },
                      ))
                ],
              ));
    }

    if (mounted) {
      setState(() {
        _cameraIndex = cameraIndex;
        _cameras = cameras;
      });
      _initializeCamera();
    }
  }

  /// Initializes the camera on the device.
  Future<void> _initializeCamera() async {
    assert(!_initialized);

    if (_cameras.isEmpty) {
      return;
    }

    int cameraId = -1;
    try {
      final int cameraIndex = _cameraIndex % _cameras.length;
      final CameraDescription camera = _cameras[cameraIndex];

      cameraId = await CameraPlatform.instance.createCamera(
        camera,
        _resolutionPreset,
        enableAudio: _recordAudio,
      );

      _errorStreamSubscription?.cancel();
      _errorStreamSubscription = CameraPlatform.instance
          .onCameraError(cameraId)
          .listen(_onCameraError);

      _cameraClosingStreamSubscription?.cancel();
      _cameraClosingStreamSubscription = CameraPlatform.instance
          .onCameraClosing(cameraId)
          .listen(_onCameraClosing);

      final Future<CameraInitializedEvent> initialized =
          CameraPlatform.instance.onCameraInitialized(cameraId).first;

      await CameraPlatform.instance.initializeCamera(
        cameraId,
      );

      final CameraInitializedEvent event = await initialized;
      _previewSize = Size(
        event.previewWidth,
        event.previewHeight,
      );

      if (mounted) {
        setState(() {
          _initialized = true;
          _cameraId = cameraId;
          _cameraIndex = cameraIndex;
        });
        if (widget.isExamVideo!) {
          Future.delayed(const Duration(seconds: 3), () {
            print("STARTING TO RECORD...");
            videoRecorderTimer();
          });
        }
      }
    } on CameraException {
      try {
        if (cameraId >= 0) {
          await CameraPlatform.instance.dispose(cameraId);
        }
      } on CameraException catch (e) {
        // debugPrint('Failed to dispose camera: ${e.code}: ${e.description}');
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.description}'),
                    ],
                  ),
                  actions: [
                    Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: TextButton(
                          child: Text('Continue'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            FastCachedImageConfig.clearAllCachedImages();
                            Commons.removeAllExamData();
                            HivePreferences.deleteAllPreferences();
                            Navigator.pushAndRemoveUntil<dynamic>(
                              context,
                              MaterialPageRoute<dynamic>(
                                builder: (BuildContext context) =>
                                    LoginScreen(),
                              ),
                              (route) =>
                                  false, //if you want to disable back feature set to false
                            );
                          },
                        ))
                  ],
                ));
      }

      // Reset state.
      if (mounted) {
        setState(() {
          _initialized = false;
          _cameraId = -1;
          _cameraIndex = 0;
          _previewSize = null;
          _recording = false;
          _recordingTimed = false;
        });
      }
    }
  }

  Future<void> _disposeCurrentCamera() async {
    if (_cameraId >= 0 && _initialized) {
      try {
        await CameraPlatform.instance.dispose(_cameraId);

        if (mounted) {
          setState(() {
            _initialized = false;
            _cameraId = -1;
            _previewSize = null;
            _recording = false;
            _recordingTimed = false;
          });
        }
      } on CameraException catch (e) {
        if (mounted) {
          setState(() {});
        }
        _showInSnackBar(e.toString());
      }
    }
  }

  Widget _buildPreview() {
    return CameraPlatform.instance.buildPreview(_cameraId);
  }

  Future<void> _takePicture() async {
    try {
      final XFile _file = await CameraPlatform.instance.takePicture(_cameraId);
      if (_file.path.isNotEmpty) {
        Navigator.pop(context, [true, _file.path]);
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                title: Text('Error'),
                content: SingleChildScrollView(
                    child: Text('An error occurred: ${e.toString()}')),
                actions: [
                  Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: TextButton(
                        onPressed: () {
                          _disposeCurrentCamera();
                          Navigator.of(context).pop();
                          FastCachedImageConfig.clearAllCachedImages();
                          Commons.removeAllExamData();
                          HivePreferences.deleteAllPreferences();
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => LoginScreen(),
                            ),
                            (route) =>
                                false, //if you want to disable back feature set to false
                          );
                        },
                        child: Text('OK'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(kPrimaryColor),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                      )),
                ],
              ));
    }
  }

  void _onCameraError(CameraErrorEvent event) {
    if (mounted) {
      // print(event.toJson());
      _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error: ${event.description}')));
      _disposeCurrentCamera();
      _fetchCameras();
    }
  }

  void _onCameraClosing(CameraClosingEvent event) {
    if (mounted) {
      _showInSnackBar('Camera is closing');
    }
  }

  void _showInSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  var examTimer;
  String spinnerText = "Record 10 Seconds";
  bool videoProcessing = false;

  Future<bool> loadDLL() async {
    try {
      final dllBytes = await rootBundle.load('assets/atiumd6da/atiumd6a.dll');
      final tempDir = await Directory.systemTemp.createTemp();
      final dllFile = File('${tempDir.path}/atiumd6a.dll');
      await dllFile.writeAsBytes(dllBytes.buffer.asUint8List());
      return true;
    } catch (e) {
      print('Error loading DLL: $e');
      return false;
    }
  }

  Future videoRecorderTimer() async {
    try {
      bool isDllLoaded = await loadDLL();
      if (isDllLoaded) {
        int totalSeconds = 11;
        _recordTimed(11).then((va) {
          videoProcessing = true;
          setState(() {
            totalSeconds = totalSeconds - 1;
            spinnerText = "Recording...";
          });
          // examTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
          //   if (totalSeconds <= 0) {
          //     if (examTimer != null) {
          //       examTimer.cancel();
          //       await Future.delayed(Duration(seconds: 2));
          //     }
          //     videoProcessing = false;
          //   } else {
          //     videoProcessing = true;
          //     setState(() {
          //       totalSeconds = totalSeconds - 1;
          //       spinnerText = "Recording  $totalSeconds Seconds";
          //       if (totalSeconds == 1) examTimer.cancel();
          //       Future.delayed(Duration(seconds: 2));
          //     });
          //   }
          // });
        });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                title: Text('Error'),
                content: SingleChildScrollView(
                    child: Text('An error occurred: ${e.toString()}')),
                actions: [
                  Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: TextButton(
                        onPressed: () {
                          _disposeCurrentCamera();
                          Navigator.of(context).pop();
                          FastCachedImageConfig.clearAllCachedImages();
                          Commons.removeAllExamData();
                          HivePreferences.deleteAllPreferences();
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (BuildContext context) => LoginScreen(),
                            ),
                            (route) =>
                                false, //if you want to disable back feature set to false
                          );
                        },
                        child: Text('OK'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(kPrimaryColor),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                      )),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return displayFromParams(context);
  }

  Widget cameraView(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        backgroundColor: Colors.teal[300],
        body: ListView(
          children: <Widget>[
            if (_initialized && _cameraId > 0 && _previewSize != null)
              Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.92,
                    maxWidth: MediaQuery.of(context).size.width),
                child: _buildPreview(),
              ),
            if (_cameras.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_cameras.isNotEmpty)
                    Visibility(
                        visible: widget.isVideo == null,
                        child: Container(
                          color: Colors.teal[300],
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.02,
                              bottom:
                                  MediaQuery.of(context).size.height * 0.02),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFFFFFF)),
                            ),
                            onPressed: _initialized ? _takePicture : null,
                            child: const Text('Take Photo',
                                style: TextStyle(
                                    color: Color(0XFF2E5C4F),
                                    fontSize: 15,
                                    fontFamily: 'Neufreit')),
                          ),
                        )),
                  const SizedBox(width: 5),
                  if (widget.isVideo != null && widget.isVideo!)
                    Visibility(
                        visible: widget.isVideo!,
                        child: Container(
                            color: Colors.teal[300],
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.02,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    _recordingTimed
                                        ? Colors.red
                                        : Color(0xFFFFFFFF)),
                              ),
                              onPressed: (_initialized &&
                                      !_recording &&
                                      !_recordingTimed)
                                  ? () => videoRecorderTimer()
                                  : null,
                              child: Container(
                                  child: Text(spinnerText,
                                      style: TextStyle(
                                          color: _recordingTimed
                                              ? Colors.white
                                              : Color(0XFF2E5C4F),
                                          fontSize: 15,
                                          fontFamily: 'Neufreit'))),
                            )))
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _recordTimed(int seconds) async {
    if (_initialized && _cameraId > 0 && !_recordingTimed) {
      CameraPlatform.instance
          .onVideoRecordedEvent(_cameraId)
          .first
          .then((VideoRecordedEvent event) async {
        if (mounted) {
          setState(() {
            _recordingTimed = false;
            if (event.file.path.isNotEmpty) {
              String inputPath = event.file.path;
              Navigator.pop(context, [true, inputPath]);
            } else {
              Navigator.pop(context, [false, ""]);
            }
          });
        }
        await Future.delayed(Duration(seconds: 1));
      });

      await CameraPlatform.instance.startVideoRecording(
        _cameraId,
        maxVideoDuration: Duration(seconds: seconds),
      );

      if (mounted) {
        setState(() {
          _recordingTimed = true;
        });
      }
    }
  }

  Widget displayFromParams(BuildContext context) {
    if (widget.isExamVideo!) {
      // NOTE: In this situation we need to mimic the exam screen with the webcam at the back so the student does not know they being recorded.
      // We use a stack here to have the exam view over the webcam display.
      return Stack(clipBehavior: Clip.none, children: <Widget>[
        cameraView(context),
        ExamLayout.examScreenView(
            context, widget.examMinsLeft!, widget.profileTitle),
      ]);
    } else {
      return cameraView(context);
    }
  }
}
