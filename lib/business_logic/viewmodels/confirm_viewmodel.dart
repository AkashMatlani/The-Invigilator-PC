import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:invigilatorpc/services/auth/auth_service.dart';
import 'package:invigilatorpc/ui/terms/terms_screen.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';

import '../../services/locator/services_locator.dart';

class ConfirmViewModel extends ChangeNotifier {
  final AuthService? _authService = serviceLocator<AuthService>();
  String tokenEntered = "";
  String emailEntered = "";

  void getUserEmail() async {
    final preferences = await HivePreferences.getInstance();
    String? email = preferences.getUserEmail() ?? "";
    emailEntered = email;
    notifyListeners();
  }

  void resendEmail(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    List<String?> resend = await _authService!.resendEmail(emailEntered);
    if (resend[0] == "true") {
      Commons.invigiFlushBarSuccess(context,
          "Re-sent confirmation email, please check your inbox on $emailEntered");
    } else if (resend[0] == "timeout") {
      Commons.invigiFlushBarSuccess(context, resend[1]);
    } else {
      Commons.invigiFlushBarError(
          context, "Unable to re-send confirmation email");
    }
  }

  void resendUnconfirmedEmail(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    List<String?> resend = await _authService!.resendEmail(emailEntered);
    if (resend[0] == "true") {
      print("Sent unconfirmed silent email.");
    } else if (resend[0] == "timeout") {
      Commons.invigiFlushBarSuccess(context, resend[1]);
    } else {
      Commons.invigiFlushBarError(context, "Unable to send confirmation email");
    }
  }

  void confirmAccountAction(BuildContext context) async {
    EasyLoading.show(status: "  Verifying...");
    List<String?> confirmed = await _authService!.confirmAccount(tokenEntered);
    EasyLoading.dismiss();
    if (confirmed[0] == "true") {
      final preferences = await HivePreferences.getInstance();
      preferences.setIsAccountConfirmed(true);
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => TermsScreen(false, false),
        ),
        (route) => false, //if you want to disable back feature set to false
      );
    } else if (confirmed[0] == "timeout") {
      Commons.invigiFlushBarError(context, confirmed[1]);
    } else {
      Commons.invigiFlushBarError(context,
          "Invalid pin entered. Please make sure the token is the exact same as the token received in your email.");
    }
  }

  void sendMobileConfirmation(BuildContext context) async {
    final preferences = await HivePreferences.getInstance();
    String? mobileNum = preferences.getUserMobile() ?? "";
    var reset = await _authService!.sendMobileConfirmation(mobileNum);
    if (reset[0] == 'true') {
      Commons.invigiFlushBarSuccess(context, reset[1]);
    } else {
      Commons.invigiFlushBarError(context, reset[1]);
    }
  }
}
