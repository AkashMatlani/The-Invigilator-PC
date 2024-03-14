import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examscreen_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:wakelock/wakelock.dart';
import 'package:window_manager/window_manager.dart';
import '../../../utils/commons.dart';
import '../../../utils/constants.dart';

class ExamScreen extends StatefulWidget {
  final String? title;
  final int? examLength;
  final bool? selfieCheck;
  final int? selfieAmount;
  final bool microphoneCheck;
  final int? microphoneAmount;
  final List<String>? itemPhotoDesc;
  final bool? codeRequired;
  final bool? examResuming;
  final bool? videoCheck;
  final int? videoAmount;
  final bool? screenCapturingCheck;
  final int? screenCapturingAmount;
  final jsonRes;
  final int? recordingDuration;
  final DateTime? startTime;
  final bool? canFinishEarly;

  ExamScreen(
      this.title,
      this.examLength,
      this.selfieCheck,
      this.selfieAmount,
      this.microphoneCheck,
      this.microphoneAmount,
      this.itemPhotoDesc,
      this.codeRequired,
      this.examResuming,
      this.recordingDuration,
      this.startTime,
      this.canFinishEarly,
      this.videoCheck,
      this.videoAmount,
      this.screenCapturingCheck,
      this.screenCapturingAmount,
      this.jsonRes);

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen>
    with WidgetsBindingObserver, WindowListener {
  ExamScreenViewModel? modelExamScreen = serviceLocator<ExamScreenViewModel>();

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    modelExamScreen!.title = widget.title;
    modelExamScreen!.examLength = widget.examLength;
    modelExamScreen!.selfieCheck = widget.selfieCheck;
    modelExamScreen!.selfieAmount = widget.selfieAmount;
    modelExamScreen!.hasMicCheck = widget.microphoneCheck;
    modelExamScreen!.microphoneAmount = widget.microphoneAmount;
    modelExamScreen!.itemPhotoDesc = widget.itemPhotoDesc;
    modelExamScreen!.codeRequired = widget.codeRequired;
    modelExamScreen!.examResuming = widget.examResuming;
    modelExamScreen!.recordingDuration = widget.recordingDuration;
    modelExamScreen!.startTime = widget.startTime;
    modelExamScreen!.canFinishEarly = widget.canFinishEarly;
    modelExamScreen!.videoCheck = widget.videoCheck;
    modelExamScreen!.videoAmount = widget.videoAmount;
    modelExamScreen!.screenCaptureCheck = widget.screenCapturingCheck;
    modelExamScreen!.screenCaptureAmount = widget.screenCapturingAmount;
    modelExamScreen!.jsonRes = widget.jsonRes;
    modelExamScreen!.checkInVenue(context);

    Wakelock.toggle(enable: true);
    modelExamScreen!.initExamScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: ChangeNotifierProvider<ExamScreenViewModel?>.value(
            value: modelExamScreen,
            child: Consumer<ExamScreenViewModel>(
              builder: (context, model, child) {
                return Scaffold(
                  appBar: examAppBar() as PreferredSizeWidget?,
                  body: Background(
                      child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(children: <Widget>[
                      ExamScreenViewModel.allSelfies != null &&
                                  ExamScreenViewModel.allSelfies!.isNotEmpty ||
                              ExamScreenViewModel.videos.isNotEmpty
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 30.0),
                              child: Image.asset(
                                owl,
                                height: 80,
                              )),
                      GestureDetector(
                        onTap: () async {},
                        child: model.selfieProcessing
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                      child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.teal[400],
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    width: 300.0,
                                    height: 200.0,
                                    alignment: AlignmentDirectional.center,
                                    child: Commons.invigiLoading(
                                        "Processing..", true),
                                  ))
                                ],
                              )
                            : SingleChildScrollView(
                                child: examUIView(model),
                              ),
                      ),
                    ]),
                  )),
                  floatingActionButton: Visibility(
                      maintainState: true,
                      visible: true,
                      child: FloatingActionButton.extended(
                        icon: Icon(Icons.timer),
                        heroTag: 'examscreen',
                        onPressed: () {},
                        label: Text(model.updatedTime.toString()),
                        backgroundColor: Colors.teal[900],
                      )),
                );
              },
            )));
  }

  Widget examUIView(ExamScreenViewModel model) {
    Size size = MediaQuery.of(context).size;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: size.height * .05),
          model.isImageLoaded || model.descriptivePhotoTaken
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Image.asset(
                        owl,
                        height: size.height * 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: size.height * 0.50,
                      width: size.width * 0.45,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(selfieBoxActive),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Padding(
                              padding:
                                  const EdgeInsets.only(left: 22, right: 30),
                              child: Wrap(
                                direction: Axis.horizontal,
                                children:
                                    model.selfies(model.selfieAmount, size),
                              )),
                          model.descriptivePhotoTaken
                              ? Positioned(
                                  top: 100.0,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 22, right: 30),
                                      child: Wrap(
                                        direction: Axis.horizontal,
                                        children: model.otherImages(size),
                                      )),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Spacer()
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    selfieBoxEmpty,
                    height: size.height * 0.45,
                    width: size.width * 0.80,
                  )),
          SizedBox(height: size.height * .02),
          model.examPassword != ""
              ? Column(children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        "Start Exam With Pin",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontFamily: 'Neufreit'),
                      )),
                  SizedBox(height: size.height * .02),
                  Container(
                    color: Colors.teal[900],
                    width: size.width * 0.7,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      model.examPassword!,
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Neufreit'),
                    ),
                  )
                ])
              : Container(),
          model.codeRequired!
              ? Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: model.activationCodeShowing
                      ? Text(
                          "Exam OTP to Enter",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontFamily: 'Neufreit'),
                        )
                      : RoundedButton(
                          text: "Show Exam OTP to Enter",
                          color: kPrimaryColor,
                          textColor: Colors.white,
                          fontSize: 17,
                          isFromForgot: false,
                          press: () {
                            model.showAlertDialog(context);
                          },
                        ),
                )
              : Container(),
          SizedBox(height: size.height * .02),
          model.activationCodeShowing
              ? Container(
                  color: Colors.teal[900],
                  width: size.width * 0.7,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    model.authCode!,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Neufreit'),
                  ),
                )
              : Container(),
          SizedBox(height: size.height * .04),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Text(
              "You will be able to see your time remaining in the bottom floating bar. At certain \ntimes the app will ask you to take a picture so keep your device close.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 16.0, fontFamily: 'Neufreit'),
            ),
          ),
          SizedBox(height: size.height * .02),
          Text(
            "Good Luck!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Neufreit'),
          ),
          SizedBox(height: size.height * .02),
          model.canFinishEarly! && !model.finishedExam
              ? RoundedButton(
                  width: 0.25,
                  text: "Finish Assessment",
                  color: kButtonColor,
                  isFromForgot: false,
                  press: () {
                    model.areYouSureFinishedAlert(context);
                  })
              : Container(),
        ]);
  }

  Widget examAppBar() {
    DateTime currentDateTime = DateTime.now();
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(currentDateTime);
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: Colors.teal[900],
      systemOverlayStyle: SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Expanded(
              flex: 1,
              child: Row(children: [
                Container(
                  height: 70,
                  width: 70,
                  padding: EdgeInsets.only(right: 10, top: 5, bottom: 5),
                  child: ClipOval(
                    child: FastCachedImage(
                      height: 30,
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
                                    style: const TextStyle(color: Colors.red)),
                              SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                      color: Colors.red,
                                      value:
                                          progress.progressPercentage.value)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Text(Commons.studentNumber ?? "",
                    style:
                        TextStyle(fontFamily: 'Neufreit', color: Colors.white)),
                Spacer(),
                Text(widget.title ?? "",
                    style:
                        TextStyle(fontFamily: 'Neufreit', color: Colors.white)),
                Spacer(),
                Text(formattedDate.toString(),
                    style:
                        TextStyle(fontFamily: 'Neufreit', color: Colors.white)),
              ])),
        ],
      ),
    );
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() {
    var t = Commons.currentTime();
    modelExamScreen!.updateExitedAppTime(t);
  }

  @override
  void onWindowFocus() {
    modelExamScreen?.updateTimerAfterBackground(context);
  }

  @override
  void onWindowBlur() {}

  @override
  void onWindowMaximize() {}

  @override
  void onWindowUnmaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowRestore() {
    modelExamScreen?.updateTimerAfterBackground(context);
  }

  @override
  void onWindowResize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    modelExamScreen!.examTimer?.cancel();
    super.dispose();
  }
}
