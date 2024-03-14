import 'dart:io';

import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'dart:io' as io;
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:invigilatorpc/networking/aws_service.dart';
import 'package:invigilatorpc/providers/initial_photo_provider.dart';
import 'package:invigilatorpc/services/general/exam_data_storage.dart';
import 'package:invigilatorpc/services/general/exam_files_storage.dart';
import 'package:invigilatorpc/ui/dashboard/dashboard_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ExamUploadViewModel extends ChangeNotifier {
  String? selfie1;
  String? selfie2;
  String? selfie3;
  String? selfie4;
  late int selfieCount;

  late List<dynamic> recordings;
  late bool hasMicCheck;
  int? uniqueDecibelCount;

  late List<dynamic> videos;
  late bool videoCheck;

  late List<dynamic> screenCapturePhotos;
  late bool screenCapturePhotosCheck;

  String profileUrl = "";
  bool? uploadToServer;

  // Description Images
  late List<dynamic> descImages;

  // Verification Code
  String? verificationCode;
  DateTime? codeActivationTime;
  List<dynamic>? secondsOutOfApp;

  String selfie1Status = 'pending';
  Color? selfie1col = Colors.grey[400];
  String selfie1Text = "Selfie 1";

  String selfie2Status = 'pending';
  Color? selfie2col = Colors.grey[400];
  String selfie2Text = "Selfie 2";

  String selfie3Status = 'pending';
  Color? selfie3col = Colors.grey[400];
  String selfie3Text = "Selfie 3";

  String selfie4Status = 'pending';
  Color? selfie4col = Colors.grey[400];
  String selfie4Text = "Selfie 4";

  String descItemsStatus = 'pending';
  Color? descItemsCol = Colors.grey[400];
  String descItemsText = "Description Items";

  String micStatus = 'pending';
  Color? mic2col = Colors.grey[400];
  String micText = "Other Data";

  String videoStatus = 'pending';
  Color? video2col = Colors.grey[400];
  String videoText = "Video Data";

  String screenCaptureStatus = 'pending';
  Color? screenCapture2col = Colors.grey[400];
  String screenCaptureText = "Screen Capture Data";

  String docsStatus = 'pending';
  Color? docscol = Colors.grey[400];
  String docsText = "Documents";

  String serverSyncStatus = 'pending';
  Color? serverSynccol = Colors.grey[400];
  String serverSyncText = "Sync with server";

  bool failedUpload = false;
  bool displayFailedUpload = false;

  // AWS Strings
  int _awsRetries = 0;
  bool uploadingAWS = false;
  String? _awsSelfie1 = "";
  String? _awsSelfie2 = "";
  String? _awsSelfie3 = "";
  String? _awsSelfie4 = "";

  List<String?> _awsRecordingFiles = [];
  List<String?> _awsVideoFiles = [];
  List<String?> _awsScreenCaptureFiles = [];
  String? _awsDesc1 = "";
  String? _awsDesc2 = "";
  String? _awsDesc3 = "";
  String? _awsDesc4 = "";

  List<dynamic>? documentImages;
  bool? uploadedDocs = false;
  bool? isReupload;

  int numberOfSelfiesOnDevice() {
    int total = 0;
    if (this.selfie1 != null) {
      total = total + 1;
    }
    if (this.selfie2 != null) {
      total = total + 1;
    }
    if (this.selfie3 != null) {
      total = total + 1;
    }
    if (this.selfie4 != null) {
      total = total + 1;
    }
    return total;
  }

  void showAWSErrorToast(BuildContext context, String? error) {
    Commons.invigiFlushBarError(context, error);
  }

  Future<bool> uploadDocuments() async {
    failedUpload = false;
    AwsService s3 = AwsService();

    int i = 1;
    int totalImages = documentImages!.length;
    List<String> awsImages = [];

    if (documentImages!.length > 0 && (uploadedDocs == false)) {
      for (var image in documentImages!) {
        docsStatus = 'uploading';
        docscol = Colors.white;
        docsText = "Uploading $i/$totalImages";
        notifyListeners();
        List<String> docUpload = await s3.uploadDocumentImage(image);
        if (docUpload[0] == 'true') {
          awsImages.add(docUpload[1]);
        } else {
          uploadedDocs = false;
          failedUpload = true;
        }
      }

      if (failedUpload == false) {
        docsStatus = 'done';
        docscol = Colors.white;
        docsText = "Uploaded";
        notifyListeners();
        final preferences = await HivePreferences.getInstance();
        await preferences.setCurrentDocuments(awsImages);
        uploadedDocs = true;
        return true;
      } else {
        docsStatus = 'error';
        docscol = Colors.red;
        docsText = 'Failed to upload document';
        notifyListeners();
        return false;
      }
    } else {
      return true;
    }
  }

  Future uploadDataWithS3(BuildContext context, bool uploadDocs) async {
    failedUpload = false;
    displayFailedUpload = false;
    uploadingAWS = true;
    selfie1Status = 'pending';
    selfie1col = Colors.grey[400];
    selfie1Text = "Uploading Selfie 1...";

    selfie2Status = 'pending';
    selfie2col = Colors.grey[400];
    selfie2Text = "Uploading Selfie 2...";

    selfie3Status = 'pending';
    selfie3col = Colors.grey[400];
    selfie3Text = "Selfie 3";

    selfie4Status = 'pending';
    selfie4col = Colors.grey[400];
    selfie4Text = "Selfie 4";

    descItemsStatus = 'pending';
    descItemsCol = Colors.grey[400];
    descItemsText = "Description Items";

    micStatus = 'pending';
    mic2col = Colors.grey[400];
    micText = "Other Data";

    videoStatus = 'pending';
    video2col = Colors.grey[400];
    videoText = "Video Data";

    if (uploadDocs) {
      docsStatus = 'pending';
      docscol = Colors.grey[400];
      docsText = "Documents";
    }

    try {
      checkConnection().then((isConnected) async {
        if (!isConnected) {
          selfie1Status = 'error';
          selfie1col = Colors.red;
          selfie2Status = 'error';
          selfie2col = Colors.red;
          descItemsStatus = 'error';
          descItemsCol = Colors.red;
          micStatus = 'error';
          mic2col = Colors.red;
          failedUpload = true;
          notifyListeners();
        } else {
          var initialPhotoProvider =
              Provider.of<InitialPhotoProvider>(context, listen: false);
          AwsService serv = initialPhotoProvider.awsService();

          // Upload Documents
          if (uploadDocs) {
            bool success = await uploadDocuments();
            if (!success) {
              failedUpload = true;
            }
          }

          // Selfies
          if (this.selfieCount > 0 && this.selfie1 != null) {
            if (failedUpload) {
              return;
            }
            selfie1Status = 'uploading';
            selfie1col = Colors.white;
            notifyListeners();
            if (this.selfie1!.contains('Error')) {
              _awsSelfie1 = this.selfie1;
              selfie1Status = 'done';
              selfie1col = Colors.white;
              selfie1Text = "Uploaded Error For Selfie 1";
              notifyListeners();
            } else {
              bool selfie1file = await io.File(this.selfie1!).exists();
              if (selfie1file) {
                List<String?> uploadData = await serv.uploadSelfie(
                    this.selfie1, 'selfie_1', _awsSelfie1);
                if (uploadData[0] == 'true') {
                  _awsSelfie1 = uploadData[1];
                  selfie1Status = 'done';
                  selfie1col = Colors.white;
                  selfie1Text = " Uploaded Selfie 1";
                  notifyListeners();
                } else {
                  showAWSErrorToast(context, uploadData[1]);
                  selfie1Status = 'error';
                  selfie1col = Colors.red;
                  selfie1Text = 'Failed to upload selfie 1';
                  failedUpload = true;
                  _awsRetries = _awsRetries + 1;
                  notifyListeners();
                }
              } else {
                selfie1Status = 'error';
                selfie1col = Colors.red;
                selfie1Text = 'Selfie 1 missing from searched directory';
                notifyListeners();
              }
            }
          }

          if (this.selfieCount >= 2 && this.selfie2 != null) {
            if (failedUpload) {
              return;
            }
            selfie2Status = 'uploading';
            selfie2col = Colors.white;
            notifyListeners();
            if (this.selfie2!.contains('Error')) {
              _awsSelfie2 = this.selfie2;
              selfie2Status = 'done';
              selfie2col = Colors.white;
              selfie2Text = "Uploaded Error For Selfie 2";
              notifyListeners();
            } else {
              bool selfie2file = await io.File(this.selfie2!).exists();
              if (selfie2file) {
                List<String?> uploadData = await serv.uploadSelfie(
                    this.selfie2, 'selfie_2', _awsSelfie2);

                if (uploadData[0] == 'true') {
                  _awsSelfie2 = uploadData[1];
                  selfie2Status = 'done';
                  selfie2col = Colors.white;
                  selfie2Text = "Uploaded Selfie 2";
                  notifyListeners();
                } else {
                  showAWSErrorToast(context, uploadData[1]);
                  selfie2Status = 'error';
                  selfie2col = Colors.red;
                  selfie2Text = 'Failed to upload selfie 2';
                  failedUpload = true;
                  _awsRetries = _awsRetries + 1;
                  notifyListeners();
                }
              } else {
                selfie2Status = 'error';
                selfie2col = Colors.red;
                selfie2Text = 'Selfie 2 missing from searched directory';
                notifyListeners();
              }
            }
          }

          if (this.selfieCount >= 3 && this.selfie3 != null) {
            if (failedUpload) {
              return;
            }
            selfie3Status = 'uploading';
            selfie3col = Colors.white;
            notifyListeners();
            if (this.selfie3!.contains('Error')) {
              _awsSelfie3 = this.selfie3;
              selfie3Status = 'done';
              selfie3col = Colors.white;
              selfie3Text = "Uploaded Error For Selfie 3";
              notifyListeners();
            } else {
              bool selfie3file = await io.File(this.selfie3!).exists();
              if (selfie3file) {
                List<String?> uploadData = await serv.uploadSelfie(
                    this.selfie3, 'selfie_3', _awsSelfie3);
                if (uploadData[0] == 'true') {
                  _awsSelfie3 = uploadData[1];
                  selfie3Status = 'done';
                  selfie3col = Colors.white;
                  selfie3Text = "Uploaded Selfie 3";
                  notifyListeners();
                } else {
                  showAWSErrorToast(context, uploadData[1]);
                  selfie3Status = 'error';
                  selfie3col = Colors.red;
                  selfie3Text = 'Failed to upload selfie 3';
                  failedUpload = true;
                  _awsRetries = _awsRetries + 1;
                  notifyListeners();
                }
              } else {
                selfie3Status = 'error';
                selfie3col = Colors.red;
                selfie3Text = 'Selfie 3 missing from searched directory';
                notifyListeners();
              }
            }
          }

          if (this.selfieCount >= 4 && this.selfie4 != null) {
            if (failedUpload) {
              return;
            }
            selfie4Status = 'uploading';
            selfie4col = Colors.white;
            notifyListeners();
            if (this.selfie4!.contains('Error')) {
              _awsSelfie4 = this.selfie4;
              selfie4Status = 'done';
              selfie4col = Colors.white;
              selfie4Text = "Uploaded Error For Selfie 4";
              notifyListeners();
            } else {
              bool selfie4file = await io.File(this.selfie4!).exists();
              if (selfie4file) {
                List<String?> uploadData = await serv.uploadSelfie(
                    this.selfie4, 'selfie_4', _awsSelfie4);

                if (uploadData[0] == 'true') {
                  _awsSelfie4 = uploadData[1];
                  selfie4Status = 'done';
                  selfie4col = Colors.white;
                  selfie4Text = "Uploaded Selfie 4";
                  notifyListeners();
                } else {
                  showAWSErrorToast(context, uploadData[1]);
                  selfie4Status = 'error';
                  selfie4col = Colors.red;
                  selfie4Text = 'Failed to upload selfie 4';
                  failedUpload = true;
                  _awsRetries = _awsRetries + 1;
                  notifyListeners();
                }
              } else {
                selfie4Status = 'error';
                selfie4col = Colors.red;
                selfie4Text = 'Selfie 4 missing from searched directory';
                notifyListeners();
              }
            }
          }

          // End Selfies
          // Microphone Uploads
          if (this.hasMicCheck) {
            if (failedUpload) {
              return;
            }
            int p = 1;
            for (var microphone in recordings) {
              if (failedUpload) {
                return;
              }
              if (microphone != "") {
                if (microphone.contains('Error')) {
                  int index = p - 1;
                  String? currentFile = "";
                  try {
                    currentFile = _awsRecordingFiles[index];
                  } catch (error) {}
                  micStatus = 'uploading';
                  mic2col = Colors.white;
                  micText = 'Uploading Data $p';
                  notifyListeners();
                  if (currentFile == "") {
                    _awsRecordingFiles.add(microphone);
                  }
                } else {
                  bool microphoneFilePresent =
                      await io.File(microphone).exists();
                  int index = p - 1;
                  String? currentFile = "";
                  try {
                    currentFile = _awsRecordingFiles[index];
                  } catch (error) {}

                  if (microphoneFilePresent) {
                    micStatus = 'uploading';
                    mic2col = Colors.white;
                    micText = 'Uploading Data $p';
                    notifyListeners();
                    List<String?> uploadData = await serv.uploadMicrophone(
                        microphone, 'microphone_$p', currentFile);
                    if (uploadData[0] != 'true') {
                      showAWSErrorToast(context, uploadData[1]);
                      micStatus = 'error';
                      mic2col = Colors.red;
                      micText = "Failed to upload data";
                      failedUpload = true;
                      notifyListeners();
                    } else {
                      if (currentFile == "") {
                        _awsRecordingFiles.add(uploadData[1]);
                      }
                    }
                  }
                }
              }
              p = p + 1;
            }

            if (failedUpload == false) {
              micStatus = 'done';
              mic2col = Colors.white;
              micText = "Uploaded other data";
              notifyListeners();
            }
          }

          // Videos
          if (this.videoCheck) {
            if (failedUpload) {
              return;
            }
            int p = 1;
            for (var video in videos) {
              if (failedUpload) {
                return;
              }
              if (video != "") {
                if (video.contains('Error')) {
                  int index = p - 1;
                  String? currentFile = "";
                  try {
                    currentFile = _awsVideoFiles[index];
                  } catch (error) {}
                  videoStatus = 'uploading';
                  video2col = Colors.white;
                  videoText = 'Uploading Data $p';
                  notifyListeners();
                  if (currentFile == "") {
                    _awsVideoFiles.add(video);
                  }
                } else {
                  bool videoFilePresent = await io.File(video).exists();
                  int index = p - 1;
                  String? currentFile = "";
                  try {
                    currentFile = _awsVideoFiles[index];
                  } catch (error) {}

                  if (videoFilePresent) {
                    videoStatus = 'uploading';
                    video2col = Colors.white;
                    videoText = 'Uploading Data $p';
                    notifyListeners();
                    List<String?> uploadData =
                        await serv.uploadVideo(video, 'video_$p', currentFile);
                    if (uploadData[0] != 'true') {
                      showAWSErrorToast(context, uploadData[1]);
                      videoStatus = 'error';
                      video2col = Colors.red;
                      videoText = "Failed to upload data";
                      failedUpload = true;
                      notifyListeners();
                    } else {
                      if (currentFile == "") {
                        _awsVideoFiles.add(uploadData[1]);
                      }
                    }
                  }
                }
              }
              p = p + 1;
            }

            if (failedUpload == false) {
              videoStatus = 'done';
              video2col = Colors.white;
              videoText = "Uploaded other data";
              notifyListeners();
            }
          }

          // screenCapture
          if (this.screenCapturePhotosCheck) {
            if (failedUpload) {
              return;
            }
            int q = 1;
            for (var screenCapturePhoto in screenCapturePhotos) {
              if (failedUpload) {
                return;
              }
              if (screenCapturePhoto != "") {
                if (screenCapturePhoto.contains('Error')) {
                  int index = q - 1;
                  String? currentFile = "";
                  try {
                    currentFile = _awsScreenCaptureFiles[index];
                  } catch (error) {}
                  screenCaptureStatus = 'uploading';
                  screenCapture2col = Colors.white;
                  screenCaptureText = 'Uploading Data $q';
                  notifyListeners();
                  if (currentFile == "") {
                    _awsScreenCaptureFiles.add(screenCapturePhoto);
                  }
                } else {
                  bool screenCaptureFilePresent =
                      await io.File(screenCapturePhoto).exists();
                  int index = q - 1;
                  String? currentFile = "";
                  try {
                    currentFile = _awsScreenCaptureFiles[index];
                  } catch (error) {}

                  if (screenCaptureFilePresent) {
                    screenCaptureStatus = 'uploading';
                    screenCapture2col = Colors.white;
                    screenCaptureText = 'Uploading Data $q';
                    notifyListeners();
                    List<String?> uploadData = await serv.uploadScreenCapture(
                        screenCapturePhoto, 'ScreenCapture_$q', currentFile);
                    if (uploadData[0] != 'true') {
                      showAWSErrorToast(context, uploadData[1]);
                      screenCaptureStatus = 'error';
                      screenCapture2col = Colors.red;
                      screenCaptureText = "Failed to upload data";
                      failedUpload = true;
                      notifyListeners();
                    } else {
                      if (currentFile == "") {
                        _awsScreenCaptureFiles.add(uploadData[1]);
                      }
                    }
                  }
                }
              }
              q = q + 1;
            }

            if (failedUpload == false) {
              screenCaptureStatus = 'done';
              screenCapture2col = Colors.white;
              screenCaptureText = "Uploaded ScreenCapture data";
              notifyListeners();
            }
          }

          serverSyncStatus = 'uploading';
          serverSynccol = Colors.white;
          serverSyncText = 'Uploading';
          notifyListeners();
          ExamDataStorage ed = new ExamDataStorage();

          List<dynamic> fileData = await ed.setExamDataFile(
              _awsRecordingFiles,
              _awsVideoFiles,
              _awsScreenCaptureFiles,
              _awsSelfie1,
              _awsSelfie2,
              _awsSelfie3,
              _awsSelfie4,
              _awsDesc1,
              _awsDesc2,
              _awsDesc3,
              _awsDesc4,
              verificationCode,
              codeActivationTime,
              this.secondsOutOfApp);

          if (fileData[1] == true) {
            io.File dataFile = fileData[0];
            List<String> uploadData = await serv.uploadDataFile(dataFile);

            if (uploadData[0] != 'true') {
              serverSyncStatus = 'error';
              serverSynccol = Colors.red;
              serverSyncText = "Failed to sync with server";
              failedUpload = true;
              displayFailedUpload = true;
              notifyListeners();
            } else {
              serverSyncStatus = 'done';
              serverSynccol = Colors.white;
              serverSyncText = "Uploaded data";
              notifyListeners();
            }
          } else {
            serverSyncStatus = 'error';
            serverSynccol = Colors.red;
            serverSyncText = "Failed to create data file";
            failedUpload = true;
            displayFailedUpload = true;
            notifyListeners();
          }

          if (failedUpload == false) {
            notifyUserExamUploaded(context);
          }
        }
      });
    } catch (e) {
      selfie1Status = 'error';
      selfie1col = Colors.red;
      selfie2Status = 'error';
      selfie2col = Colors.red;
      descItemsStatus = 'error';
      descItemsCol = Colors.red;
      micStatus = 'error';
      mic2col = Colors.red;
      failedUpload = true;
      notifyListeners();
    }
    //End Microphone Uploads
  }

  Container iconForStatus(status) {
    if (status == 'error') {
      return Container(
          height: 30,
          width: 30,
          child: Icon(
            Icons.error_outline,
            size: 30,
            color: Colors.red,
          ));
    } else if (status == 'done') {
      return Container(
          height: 30,
          width: 30,
          child: Icon(
            Icons.check,
            size: 30,
            color: Colors.white,
          ));
    } else if (status == 'uploading') {
      return Container(
          height: 30,
          width: 30,
          child: SpinKitRing(
            color: Colors.white,
            lineWidth: 3,
          ));
    } else {
      return Container(
          height: 30,
          width: 30,
          child: Icon(
            Icons.cached,
            size: 30,
            color: Colors.grey[400],
          ));
    }
  }

  Future addLocalResultData() async {
    final preferences = await HivePreferences.getInstance();
    try {
      List<String> localResults = preferences.getLocalResults() ?? [];
      int examResId = preferences.getExamResultId() ?? 0;
      int examId = preferences.getExamId() ?? 0;
      List<dynamic>? examDetails = preferences.getCurrentExam();
      DateTime currentTime = DateTime.now();
      final DateFormat formatter = DateFormat.yMd().add_jm();
      String formatted = formatter.format(currentTime);
      String title = examDetails![0];
      int userId = preferences.getUserId() ?? 0;
      Map resultSet = {
        'exam': title,
        'created': formatted,
        'exam_id': examId,
        'reference': 'Processing',
        'id': examResId,
        'user_id': userId
      };

      localResults.add(json.encode(resultSet));
      preferences.setLocalResults(localResults);
    } catch (error) {}
  }

  void progressUserToDashboard(BuildContext context) async {
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => DashboardScreen(),
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }

  notifyUserExamUploaded(BuildContext context) async {
    addLocalResultData();
    final preferences = await HivePreferences.getInstance();
    if (isReupload!) {
      int indexUpload = preferences.getIndexOfReupload() ?? 10;
      List<String>? data = preferences.getLocalExamFiles() ?? [];
      data.removeAt(indexUpload);
      preferences.setLocalExamFiles(data);
    }
    await Commons.removeAllExamData();
    Widget continueButton = TextButton(
      child: Text("Back to Dashboard"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        //delete videos, recordings,screenCaptures, selfies
        await removeSelfies();
        await removeRecordings();
        await removeVideos();
        await removeScreenCaptures();
        progressUserToDashboard(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Well Done!"),
      content: Text("All the files were uploaded successfully."),
      actions: [continueButton],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  removeSelfies() async {
    try {
      if (selfie1 != null && selfie1!.isNotEmpty) {
        await File(selfie1!).delete();
      }
      if (selfie2 != null && selfie2!.isNotEmpty) {
        await File(selfie2!).delete();
      }
      if (selfie3 != null && selfie3!.isNotEmpty) {
        await File(selfie3!).delete();
      }
      if (selfie4 != null && selfie4!.isNotEmpty) {
        await File(selfie4!).delete();
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  removeRecordings() async {
    try {
      if (recordings.isNotEmpty && recordings.length > 0) {
        for (int k = 0; k < recordings.length; k++) {
          await File(recordings[k]).delete();
        }
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  removeVideos() async {
    try {
      if (videos.isNotEmpty && videos.length > 0) {
        for (int i = 0; i < videos.length; i++) {
          await File(videos[i]).delete();
        }
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  removeScreenCaptures() async {
    try {
      if (screenCapturePhotos.isNotEmpty && screenCapturePhotos.length > 0) {
        for (int j = 0; j < screenCapturePhotos.length; j++) {
          await File(screenCapturePhotos[j]).delete();
        }
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  areYouSureCancel(BuildContext context) {
    // set up the buttons
    Widget continueButton = TextButton(
      child: Text("Yes, Cancel"),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.red),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        ExamFilesStorage es = new ExamFilesStorage();
        bool addedFileData = await es.setExamDataFile(
          selfie1,
          selfie2,
          selfie3,
          selfie4,
          selfieCount,
          recordings,
          videos,
          screenCapturePhotos,
          uniqueDecibelCount,
          descImages,
          verificationCode,
          codeActivationTime,
          secondsOutOfApp,
          false,
          true,
        );
        if (addedFileData) {
          await Commons.removeAllExamData();
          progressUserToDashboard(context);
        }
      },
    );

    Widget cancelBtn = TextButton(
      child: Text(
        "No, Don't Cancel",
        style: TextStyle(color: Colors.black),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.grey),
          foregroundColor: MaterialStateProperty.all(Colors.white)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
      title: Text("Are You Sure You Want To Cancel?"),
      content: Text(
          "Your files will not be uploaded. You will be able to upload\nlater, make sure you upload all your files as soon as possible."),
      actions: [
        continueButton,
        cancelBtn,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget uploadWidget(
      String _status, String _text, Color? color, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(left: size.width * .38),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(right: 35, top: 10, bottom: 10),
                    child: Center(child: iconForStatus(_status))),
                Expanded(
                    child: Text(
                  _text,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                      fontFamily: 'Neufreit'),
                )),
              ],
            )),
        FDottedLine(
          color: Colors.white,
          width: 360.0,
        )
      ],
    );
  }
}
