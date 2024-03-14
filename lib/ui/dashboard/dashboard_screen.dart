import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/dashboard_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/dashboard/my_dashboard_screen.dart';
import 'package:invigilatorpc/ui/help/help_screen.dart';
import 'package:invigilatorpc/ui/logout/logout_screen.dart';
import 'package:invigilatorpc/ui/pending_uploads/pending_screen.dart';
import 'package:invigilatorpc/ui/profile/profile_screen.dart';
import 'package:invigilatorpc/ui/results/results_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardViewModel? dashboardViewModel = serviceLocator<DashboardViewModel>();

  int index = 0;
  final selectedColour = Colors.white;
  final unSelectedColour = Colors.white70;
  final labelStyle = const TextStyle(fontFamily: 'Neufreit', fontSize: 10);

  @override
  void initState() {
    dashboardViewModel!.getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: ChangeNotifierProvider<DashboardViewModel?>.value(
            value: serviceLocator<DashboardViewModel>(),
            child: Consumer<DashboardViewModel>(
                builder: (context, model, child) => Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 70,
                          color: Colors.teal[900],
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Welcome to your exam dashboard" +
                                      " " +
                                      dashboardViewModel!.userName!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Container(
                                height: 70,
                                width: 70,
                                padding: EdgeInsets.only(
                                    right: 10, top: 5, bottom: 5),
                                child: CircleAvatar(
                                  child: ClipOval(
                                    child: FastCachedImage(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      url: Commons.profilePicture!,
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                          const Duration(seconds: 1),
                                      errorBuilder:
                                          (context, exception, stacktrace) {
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
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Colors.red,
                                                          value: progress
                                                              .progressPercentage
                                                              .value)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.teal[900],
                                child: Column(
                                  children: [
                                    ListView.separated(
                                        primary: true,
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                              color: Colors.white,
                                              height: 0.5,
                                            ),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: listItems.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return InkWell(
                                              onTap: () {
                                                this.index = index;
                                                setState(() {
                                                  buildPages(index);
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(20),
                                                decoration: this.index == index
                                                    ? BoxDecoration(
                                                        gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                            colors: [
                                                            Colors.teal[300]!,
                                                            Colors.teal[500]!,
                                                          ]))
                                                    : BoxDecoration(),
                                                child: Row(
                                                  children: [
                                                    Icon(listItems[index].value,
                                                        color: Colors.white),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10)),
                                                    Text(
                                                      listItems[index].name,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                ),
                                              ));
                                        }),
                                    Divider(
                                      color: Colors.white,
                                      height: 0.5,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: buildPages(index)),
                            ],
                          ),
                        ),
                      ],
                    )))));
  }

  Widget buildPages(int index) {
    switch (index) {
      case 0:
        return MyDashBorad();
      case 1:
        return ProfileScreen();
      case 2:
        return ResultsScreen();
      case 3:
        return PendingScreen();
      case 4:
        return HelpScreen();
      case 5:
        return LogoutScreen();
      default:
        return Container();
    }
  }
}
