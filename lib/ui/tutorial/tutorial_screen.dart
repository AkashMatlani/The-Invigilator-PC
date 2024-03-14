import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/tutorial_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import '../../../utils/constants.dart';
import 'dart:io' show Platform;

class TutorialScreen extends StatefulWidget {
  final bool hasAddedPhoto;

  TutorialScreen(this.hasAddedPhoto);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with WidgetsBindingObserver {
  TutorialViewModel? modelExamScreen = serviceLocator<TutorialViewModel>();
  var scollBarController = ScrollController();

  @override
  void initState() {
    super.initState();
    modelExamScreen!.hasAddedPhoto = widget.hasAddedPhoto;
    if (Platform.isMacOS) {
      Timer.run(() => modelExamScreen!.welcomeTut(context));
    } else {
      Timer.run(() => modelExamScreen!.microphoneCheckTwoSeconds(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<TutorialViewModel?>(
        create: (context) => modelExamScreen,
        child: Consumer<TutorialViewModel>(
          builder: (context, model, child) {
            return Scaffold(
              body: model.selfieProcessing ||
                      model.microphoneProcessing ||
                      model.uploadingData
                  ? Background(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                            child: Container(
                          decoration: BoxDecoration(
                              color: Colors.teal[400],
                              borderRadius: BorderRadius.circular(10.0)),
                          width: 300.0,
                          height: 200.0,
                          alignment: AlignmentDirectional.center,
                          child: Commons.invigiMicLoading(model.spinnerText),
                        ))
                      ],
                    ))
                  : Background(
                      alignValue: true,
                      child: GestureDetector(
                        onTap: () async {},
                        child: model.uploading
                            ? Center(
                                child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.teal[400],
                                    borderRadius: BorderRadius.circular(10.0)),
                                width: 300.0,
                                height: 200.0,
                                alignment: AlignmentDirectional.center,
                                child: Commons.invigiLoading(
                                    model.loadingText, false),
                              ))
                            : Scrollbar(
                                thumbVisibility: true,
                                controller: scollBarController,
                                child: SingleChildScrollView(
                                    controller: scollBarController,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10, left: 10),
                                              child: Image.asset(
                                                owl,
                                                height: size.height * 0.10,
                                              ),
                                            ),
                                            Spacer(),
                                            Expanded(
                                              flex: 0,
                                              child: Container(
                                                width: size.width * 0.10,
                                              ),
                                            ),
                                            Flexible(
                                              flex: 1,
                                              child: Text("PC Calibration",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22.0,
                                                      fontFamily: 'Neufreit')),
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                        SizedBox(height: size.height * .20),
                                        Container(
                                          height: size.height * 0.50,
                                          width: size.width * 0.45,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image:
                                                  AssetImage(selfieBoxActive),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: <Widget>[
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          top: 4,
                                                          right: 30),
                                                  child: Wrap(
                                                    direction: Axis.horizontal,
                                                    children:
                                                        model.imagesTakenList(
                                                            context),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.height * .02),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30, right: 30),
                                          child: Text(
                                            "Images and Videos taken from your webcam should appear in the above block to \nshow you that the PC is working on capturing Video and images from your device",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontFamily: 'Neufreit'),
                                          ),
                                        ),
                                        SizedBox(height: size.height * .04),
                                        model.failedUpload == true
                                            ? RoundedButton(
                                                text: "RETRY UPLOAD",
                                                color: kButtonColor,
                                                isFromForgot:false,
                                                press: () {
                                                  checkConnection()
                                                      .then((isConnected) {
                                                    if (isConnected) {
                                                      model.uploadResults(
                                                          context,
                                                          model
                                                              .successfulCalibration);
                                                    } else {
                                                      Commons
                                                          .invigiFlushBarError(
                                                              context,
                                                              noInternet);
                                                    }
                                                  });
                                                })
                                            : Container(),
                                      ],
                                    )),
                              ),
                      )),
              floatingActionButton: FloatingActionButton.extended(
                icon: Icon(Icons.timer),
                onPressed: () {},
                label: Text(model.minutesForUpload.toString()),
                backgroundColor: Colors.teal[900],
              ),
            );
          },
        ));
  }
}
