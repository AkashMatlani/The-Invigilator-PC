import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:invigilatorpc/networking/http_service.dart';
import 'package:invigilatorpc/services/auth/auth_service.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/confirmation/confirm_screen.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthService? _authService = serviceLocator<AuthService>();
  HttpService? _api = serviceLocator<HttpService>();
  List<String?> _universities = [];
  String? currentSelectedValue = "";
  bool hasConnection = true;
  bool gettingUniversities = true;
  String? loadingText = "Getting Universities..";
  HashMap inputFields = HashMap<String, String?>();

  List<String?> get universities => _universities;

  Future<dynamic> signUpUser(BuildContext context) async {
    var loggedIn = await _authService!.userRegister(inputFields);
    if (loggedIn[0] == 'true') {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ConfirmScreen(false),
        ),
        (route) => false, //if you want to disable back feature set to false
      );
    } else {
      Commons.invigiFlushBarError(context, loggedIn[1]);
    }
  }

  void getUniversities(BuildContext context) async {
    hasConnection = true;
    gettingUniversities = true;
    loadingText = "Getting Universities..";
    List<String?> unis = await _api!.loadUniversities();
    if (unis[0] == 'false') {
      hasConnection = false;
      gettingUniversities = false;
      loadingText = unis[1];
      notifyListeners();
      Commons.invigiFlushBarError(context, unis[1]);
      await Future.delayed(Duration(seconds: 3));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
      );
    } else {
      hasConnection = true;
      gettingUniversities = false;
      currentSelectedValue = "University";
      _universities = unis;
      inputFields['university_title'] = "University";
      notifyListeners();
    }
  }
}
