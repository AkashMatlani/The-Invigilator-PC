import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examscreen_viewmodel.dart';
import '../../utils/app_drawbles.dart';
import '../../utils/commons.dart';
import '../widgets/background.dart';

class ExamLayout {
  // NOTE: This view serves to only mimic the view of the exam.
  // We do this to add a stack on the camera so the camera can sit in the background and the view looks like the normal exam screen to the student
  static Widget examScreenView(BuildContext context, int examTimeLeft,
      [String? profileTitle]) {
    Size size = MediaQuery.of(context).size;
    DateTime currentDateTime = DateTime.now();
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(currentDateTime);
    return Scaffold(
      appBar: examAppBar(profileTitle!, formattedDate, context)
          as PreferredSizeWidget?,
      body: Background(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 60.0),
                    child: Image.asset(
                      owl,
                      height: 80,
                    )),
                SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                      SizedBox(height: size.height * .05),
                      examUIView(context),
                      SizedBox(height: size.height * .06),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Text(
                          "You will be able to see your time remaining in the bottom floating bar. At certain \ntimes the app will ask you to take a picture so keep your device close.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: 'Neufreit'),
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
                    ])),
              ]))),
      floatingActionButton: Visibility(
          maintainState: true,
          visible: true,
          child: FloatingActionButton.extended(
            icon: Icon(Icons.timer),
            heroTag: 'examscreen',
            onPressed: () {},
            label: Text(examTimeLeft.toString()),
            backgroundColor: Colors.teal[900],
          )),
    );
  }

  static Widget examUIView(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: <
        Widget>[
      SizedBox(height: size.height * .05),
      ExamScreenViewModel.allSelfies != null &&
              ExamScreenViewModel.allSelfies!.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          padding: const EdgeInsets.only(left: 22, right: 30),
                          child: Wrap(
                            direction: Axis.horizontal,
                            children: selfiesList(
                                size, ExamScreenViewModel.allSelfies!.length),
                          )),
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
    ]);
  }

  static List<Widget> selfiesList(count, size) {
    return <Widget>[
      ExamScreenViewModel.allSelfies!.asMap().containsKey(0)
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(
                              File(ExamScreenViewModel.allSelfies![0])),
                          fit: BoxFit.cover))),
            )
          : Container(),
      ExamScreenViewModel.allSelfies!.asMap().containsKey(1)
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(
                              File(ExamScreenViewModel.allSelfies![1])),
                          fit: BoxFit.cover))),
            )
          : Container(),
      ExamScreenViewModel.allSelfies!.asMap().containsKey(2)
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(
                              File(ExamScreenViewModel.allSelfies![2])),
                          fit: BoxFit.cover))),
            )
          : Container(),
      ExamScreenViewModel.allSelfies!.asMap().containsKey(3)
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 0, top: 10),
              child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: FileImage(
                              File(ExamScreenViewModel.allSelfies![3])),
                          fit: BoxFit.cover))),
            )
          : Container(),
    ];
  }

  static Widget examAppBar(
      String profileTitle, String formattedDate, BuildContext context) {
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
                  padding: EdgeInsets.only(right: 10, top: 20, bottom: 20),
                  child: Container(
                    height: 70,
                    width: 70,
                    padding: EdgeInsets.only(right: 10, top: 5, bottom: 5),
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
                                      style:
                                          const TextStyle(color: Colors.red)),
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
                ),
                Text(Commons.studentNumber ?? "",
                    style:
                        TextStyle(fontFamily: 'Neufreit', color: Colors.white)),
                Spacer(),
                Text(profileTitle,
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
}
