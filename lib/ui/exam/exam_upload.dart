import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examupload_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:wakelock/wakelock.dart';

class ExamUpload extends StatefulWidget {
  // Camera
  final String? selfie1;
  final String? selfie2;
  final String? selfie3;
  final String? selfie4;
  final int? selfieCount;

  // Microphone
  final List<dynamic>? recordings;
  final bool? hasMicCheck;
  final int? uniqueDecibelCount;

  // Video
  final List<dynamic>? videos;
  final bool? videoCheck;

  // screenCapture
  final List<dynamic>? screenCaptures;
  final bool? screenCaptureCheck;

  // Description Images
  final List<dynamic>? descImages;

  // Description Images
  final List<dynamic>? descImagesLow;

  // Verification Code
  final String? verificationCode;
  final DateTime? codeActivationTime;
  final bool uploadToServer;

  // Time Out App
  final List<dynamic>? secondsOutOfApp;

  // Documents
  final List<dynamic>? documentImages;

  // Is Re-Upload
  final bool isReupload;

  final String? profilePicture;
  final String? profileTitle;
  final bool? isFromPending;

  @override
  _ExamUploadState createState() => _ExamUploadState();

  ExamUpload(
      this.selfie1,
      this.selfie2,
      this.selfie3,
      this.selfie4,
      this.selfieCount,
      this.hasMicCheck,
      this.recordings,
      this.uniqueDecibelCount,
      this.videoCheck,
      this.videos,
      this.screenCaptureCheck,
      this.screenCaptures,
      this.descImages,
      this.descImagesLow,
      this.verificationCode,
      this.codeActivationTime,
      this.secondsOutOfApp,
      this.uploadToServer,
      this.documentImages,
      this.isReupload,
      [this.profilePicture,
      this.profileTitle,
      this.isFromPending]);
}

class _ExamUploadState extends State<ExamUpload> {
  ExamUploadViewModel? modelExamUpload = serviceLocator<ExamUploadViewModel>();
  var scollBarController = ScrollController();

  @override
  void initState() {
    super.initState();
    modelExamUpload!.selfie1 = widget.selfie1 ?? "";
    modelExamUpload!.selfie2 = widget.selfie2 ?? "";
    modelExamUpload!.selfie3 = widget.selfie3 ?? "";
    modelExamUpload!.selfie4 = widget.selfie4 ?? "";
    modelExamUpload!.selfieCount = widget.selfieCount ?? 0;
    modelExamUpload!.hasMicCheck = widget.hasMicCheck ?? false;
    modelExamUpload!.recordings = widget.recordings ?? [""];
    modelExamUpload!.videoCheck = widget.videoCheck ?? false;
    modelExamUpload!.videos = widget.videos ?? [""];
    modelExamUpload!.screenCapturePhotosCheck =
        widget.screenCaptureCheck ?? false;
    modelExamUpload!.screenCapturePhotos = widget.screenCaptures ?? [""];
    modelExamUpload!.uniqueDecibelCount = widget.uniqueDecibelCount ?? 0;
    modelExamUpload!.descImages = widget.descImages ?? [""];
    modelExamUpload!.verificationCode = widget.verificationCode ?? "";
    modelExamUpload!.codeActivationTime =
        widget.codeActivationTime ?? Commons.currentTime();
    modelExamUpload!.secondsOutOfApp = widget.secondsOutOfApp ?? [""];
    modelExamUpload!.uploadToServer = widget.uploadToServer;
    modelExamUpload!.documentImages = widget.documentImages ?? [];
    modelExamUpload!.isReupload = widget.isReupload;

    Wakelock.toggle(enable: false);
    modelExamUpload!.uploadDataWithS3(context, widget.isReupload);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: ChangeNotifierProvider<ExamUploadViewModel?>(
            create: (context) => modelExamUpload,
            child: Consumer<ExamUploadViewModel>(
                builder: (context, model, child) => Scaffold(
                      appBar: examAppBar() as PreferredSizeWidget,
                      body: Background(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              controller: scollBarController,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(height: size.height * .05),
                                    Image.asset(
                                      owl,
                                      height: size.height * 0.25,
                                    ),
                                    SizedBox(height: size.height * .01),
                                    Text(
                                      "Version: ${dotenv.env['VERSION']}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    model.failedUpload
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, right: 0, top: 20),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: TextButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red),
                                                    padding:
                                                        MaterialStateProperty.all<
                                                                EdgeInsets>(
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        12)),
                                                  ),
                                                  onPressed: () {
                                                    model.areYouSureCancel(
                                                        context);
                                                  },
                                                  child: Text(
                                                    "Cancel/Upload Later",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.0,
                                                        fontFamily: 'Neufreit'),
                                                  ),
                                                )))
                                        : Container(),
                                    SizedBox(height: size.height * .05),
                                    Text(
                                      "Well done on completing your exam",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18),
                                    ),
                                    SizedBox(height: size.height * .04),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, right: 30),
                                      child: Text(
                                        "Please wait while we upload your data to be analyzed by our servers.\nThis will use some of your data so if you can use WiFi turn it on now.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0),
                                      ),
                                    ),
                                    SizedBox(height: size.height * .04),
                                    model.documentImages!.length > 0
                                        ? model.uploadWidget(
                                            model.docsStatus,
                                            model.docsText,
                                            model.docscol,
                                            context)
                                        : Container(),
                                    model.selfieCount > 0
                                        ? model.uploadWidget(
                                            model.selfie1Status,
                                            model.selfie1Text,
                                            model.selfie1col,
                                            context)
                                        : Container(),
                                    model.selfieCount >= 2
                                        ? model.uploadWidget(
                                            model.selfie2Status,
                                            model.selfie2Text,
                                            model.selfie2col,
                                            context)
                                        : Container(),
                                    model.selfieCount >= 3
                                        ? model.uploadWidget(
                                            model.selfie3Status,
                                            model.selfie3Text,
                                            model.selfie3col,
                                            context)
                                        : Container(),
                                    model.selfieCount >= 4
                                        ? model.uploadWidget(
                                            model.selfie4Status,
                                            model.selfie4Text,
                                            model.selfie4col,
                                            context)
                                        : Container(),
                                    model.descImages.length > 0
                                        ? model.uploadWidget(
                                            model.descItemsStatus,
                                            model.descItemsText,
                                            model.descItemsCol,
                                            context)
                                        : Container(),
                                    model.uploadWidget(model.micStatus,
                                        model.micText, model.mic2col, context),
                                    model.videoCheck
                                        ? model.uploadWidget(
                                            model.videoStatus,
                                            model.videoText,
                                            model.video2col,
                                            context)
                                        : Container(),
                                    model.screenCapturePhotosCheck
                                        ? model.uploadWidget(
                                            model.screenCaptureStatus,
                                            model.screenCaptureText,
                                            model.screenCapture2col,
                                            context)
                                        : Container(),
                                    model.uploadingAWS
                                        ? model.uploadWidget(
                                            model.serverSyncStatus,
                                            model.serverSyncText,
                                            model.serverSynccol,
                                            context)
                                        : Container(),
                                    SizedBox(height: size.height * 0.01),
                                  ]))),
                      floatingActionButton:
                          modelExamUpload!.displayFailedUpload == true ||
                                  modelExamUpload!.failedUpload == true
                              ? FloatingActionButton.extended(
                                  icon: Icon(Icons.file_upload),
                                  onPressed: () {
                                    checkConnection().then((isConnected) {
                                      if (!isConnected) {
                                        Commons.invigiFlushBarError(
                                            context, noInternet);
                                      } else {
                                        modelExamUpload!.uploadDataWithS3(
                                            context, widget.isReupload);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.teal[900],
                                  label: Text("Retry Upload",
                                      style: TextStyle(fontFamily: 'Neufreit')))
                              : null,
                    ))));
  }

  Widget examAppBar() {
    DateTime currentDateTime = DateTime.now();
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(currentDateTime);
    return AppBar(
      backgroundColor: Colors.teal[900],
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
            child: widget.profilePicture != null &&
                    widget.profilePicture!.isNotEmpty
                ? Container(
                    padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                    child: Container(
                      height: 70,
                      width: 70,
                      padding: EdgeInsets.only(right: 10, top: 5, bottom: 5),
                      child: CircleAvatar(
                        radius: 45,
                        child: ClipOval(
                          child: FastCachedImage(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            url: Commons.profilePicture!,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(seconds: 1),
                            errorBuilder: (context, exception, stacktrace) {
                              return Icon(Icons.error);
                            },
                            loadingBuilder: (context, progress) {
                              return Container(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (progress.isDownloading &&
                                        progress.totalBytes != null)
                                      Text(
                                          '${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb',
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: CircularProgressIndicator(
                                            color: Colors.red,
                                            value: progress
                                                .progressPercentage.value)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ))
                : CircleAvatar(
                    maxRadius: 20,
                    child: ClipOval(
                        child: FadeInImage(
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.fill,
                            placeholder: AssetImage(owl),
                            image: AssetImage(owl)))),
          ),
          FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                  Commons.studentNumber != null &&
                          Commons.studentNumber!.isNotEmpty
                      ? Commons.studentNumber!
                      : widget.profileTitle!,
                  style:
                      TextStyle(fontFamily: 'Neufreit', color: Colors.white))),
          Spacer(),
          widget.isFromPending != null && widget.isFromPending!
              ? FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(widget.profilePicture ?? "",
                      style: TextStyle(
                          fontFamily: 'Neufreit', color: Colors.white)))
              : FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                      widget.profileTitle != null
                          ? widget.profileTitle!
                          : widget.profilePicture!,
                      style: TextStyle(
                          fontFamily: 'Neufreit', color: Colors.white))),
          Spacer(),
          FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(formattedDate.toString(),
                  style:
                      TextStyle(fontFamily: 'Neufreit', color: Colors.white))),
        ],
      ),
    );
  }
}
