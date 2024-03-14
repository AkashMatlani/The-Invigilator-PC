import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:invigilatorpc/services/auth/auth_service.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/ui/widgets/rounded_input_field.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';

class ForgotScreen extends StatelessWidget {
  final email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  owl,
                  height: size.height * 0.25,
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  "LOGIN",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: size.height * 0.03),
                RoundedInputField(
                  hintText: "Email or Mobile Number",
                  editingController: email,
                ),
                RoundedButton(
                    text: "SEND LOGIN RESET EMAIL OR SMS",
                    color: kButtonColor,
                    isFromForgot: true,
                    press: () async {
                      EasyLoading.show(status: "  Sending...");
                      var authService = AuthService();
                      var reset = await authService.userPassReset(email.text);
                      EasyLoading.dismiss();
                      if (reset[0] == 'true') {
                        Commons.invigiFlushBarSuccess(context, reset[1]);
                      } else {
                        Commons.invigiFlushBarError(context, reset[1]);
                      }
                      EasyLoading.dismiss();
                    }),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Back to Login",
                        style: TextStyle(
                          color: kButtonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
