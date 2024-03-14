import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/dashboard_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/pending_uploads/pending_screen.dart';
import 'package:invigilatorpc/ui/widgets/background_dashboard.dart';
import 'package:invigilatorpc/ui/widgets/text_field_container.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';

class MyDashBorad extends StatefulWidget {
  const MyDashBorad({Key? key}) : super(key: key);

  @override
  State<MyDashBorad> createState() => _MyDashBoradState();
}

class _MyDashBoradState extends State<MyDashBorad> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DashboardViewModel?>.value(
        value: serviceLocator<DashboardViewModel>(),
        child: Consumer<DashboardViewModel>(
            builder: (context, model, child) => Scaffold(
                  backgroundColor: Colors.teal[300],
                  body: getDashBoard(model),
                  floatingActionButton: !model.loadingExam
                      ? floatingActionButton(model)
                      : SizedBox(),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                )));
  }

  Widget getDashBoard(DashboardViewModel model) {
    Size size = MediaQuery.of(context).size;
    return BackgroundDashboard(
        child: model.loadingExam
            ? Center(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.teal[400],
                        borderRadius: BorderRadius.circular(10.0)),
                    width: 300.0,
                    height: 200.0,
                    alignment: AlignmentDirectional.center,
                    child: Commons.invigiLoading(model.loadingText, true)),
              )
            : SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        model.totalPending! > 0
                            ? GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return PendingScreen(model.userName);
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 0.00),
                                  padding: EdgeInsets.all(15.00),
                                  color: Colors.orange[700],
                                  child: Row(children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 6.00),
                                      child: Icon(
                                          Icons.notifications_active_sharp,
                                          color: Colors.white),
                                    ),
                                    Text(
                                        "You have ${model.totalPending!} Pending Upload(s)",
                                        style: TextStyle(color: Colors.white)),
                                  ]),
                                ))
                            : Container(),
                        SizedBox(height: size.height * 0.20),
                        Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                model.tappedExamCode
                                    ? Image.asset(
                                        qrExample,
                                        height: size.height * 0.20,
                                      )
                                    : Image.asset(
                                        owl,
                                        height: size.height * 0.20,
                                      ),
                                SizedBox(height: size.height * .05),
                                model.tappedExamCode
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30, right: 30),
                                        child: Text(
                                          "Welcome to your exam dashboard, " +
                                              model.userName!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontFamily: 'Neufreit'),
                                        ),
                                      ),
                                model.tappedExamCode
                                    ? SizedBox(height: 0)
                                    : SizedBox(height: size.height * .05),
                                model.tappedExamCode
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30, right: 30),
                                        child: Text(
                                          "To start an assessment you should see a QR code on your exam. Click the floating button \n below to enter the code and begin the test. Once you enter the code you will begin the \n assessment and the app may ask you to perform a few tasks.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontFamily: 'Neufreit'),
                                        ),
                                      ),
                                model.tappedExamCode
                                    ? SizedBox(height: 0)
                                    : SizedBox(height: size.height * .03),
                                model.tappedExamCode
                                    ? SizedBox(
                                        child: TextFieldContainer(
                                          padding: 1,
                                          child: TextField(
                                            onChanged: (value) {
                                              model.examCode = value;
                                            },
                                            cursorColor: kPrimaryColor,
                                            decoration: InputDecoration(
                                              icon: Icon(
                                                Icons.description,
                                                color: kButtonColor,
                                              ),
                                              hintText:
                                                  "Enter your access code here",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        width: size.width / 4)
                                    : Container(),
                                model.tappedExamCode
                                    ? Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        width: size.width * 0.25,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(29),
                                          child: model.loadingExam
                                              ? TextButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(kPrimaryColor),
                                                    padding:
                                                        MaterialStateProperty.all<
                                                                EdgeInsets>(
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        20,
                                                                    horizontal:
                                                                        40)),
                                                  ),
                                                  onPressed: () async {},
                                                  child: Text(
                                                    "Verifying....",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: 'Neufreit'),
                                                  ),
                                                )
                                              : TextButton(
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(kPrimaryColor),
                                                    padding:
                                                        MaterialStateProperty.all<
                                                                EdgeInsets>(
                                                            EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        20,
                                                                    horizontal:
                                                                        40)),
                                                  ),
                                                  onPressed: () async {
                                                    // if (!InternetStatusService
                                                    //    .isOnline) {
                                                    //   Commons
                                                    //       .invigiFlushBarError(
                                                    //           context,
                                                    //           noInternet);
                                                    // } else {
                                                    //   EasyLoading.show(
                                                    //       status:
                                                    //           "  Please Wait...");
                                                    //   model.startExamWithCode(
                                                    //       context);
                                                    // }

                                                    checkConnection()
                                                        .then((isConnected) {
                                                      if (!isConnected) {
                                                        Commons
                                                            .invigiFlushBarError(
                                                                context,
                                                                noInternet);
                                                      } else {
                                                        EasyLoading.show(
                                                            status:
                                                                "  Please Wait...");
                                                        model.startExamWithCode(
                                                            context);
                                                      }
                                                    });
                                                  },
                                                  child: Text(
                                                    "Start Assessment",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: 'Neufreit'),
                                                  ),
                                                ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(height: size.height * .02),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30),
                                  child: Text(
                                    "Please make sure your computer is charged or plugged in before you start!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.teal[900],
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Neufreit'),
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }

  Widget floatingActionButton(DashboardViewModel model) {
    return model.tappedExamCode == false
        ? FloatingActionButton.extended(
            icon: Icon(Icons.shutter_speed),
            heroTag: 'dashboardScreen',
            onPressed: () {
              checkConnection().then((isConnected) {
                if (!isConnected) {
                  Commons.invigiFlushBarError(context, noInternet);
                } else {
                  model.tappedExamCode = true;
                  setState(() {});
                }
              });
            },
            backgroundColor: Colors.teal[900],
            label: Text("Start Assessment",
                style: TextStyle(fontFamily: 'Neufreit')))
        : FloatingActionButton.extended(
            heroTag: 'dashboardScreen',
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                model.tappedExamCode = false;
              });
            },
            backgroundColor: Colors.teal[900],
            label: Text("Back to dashboard",
                style: TextStyle(fontFamily: 'Neufreit')));
  }
}
