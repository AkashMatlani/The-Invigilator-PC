import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:collection';
import 'package:invigilatorpc/business_logic/viewmodels/login_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/login/forgot_screen.dart';
import 'package:invigilatorpc/ui/signup/signup_screen.dart';
import 'package:invigilatorpc/ui/widgets/already_have_an_account_acheck.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/ui/widgets/rounded_input_field.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/widgets/rounded_password_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    String storageLocation = (await getApplicationDocumentsDirectory()).path;
    await FastCachedImageConfig.init(
        subDir: storageLocation, clearCacheAfter: const Duration(days: 365));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getLoginUI());
  }

  Widget getLoginUI() {
    Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<LoginViewModel?>(
        create: (context) => serviceLocator<LoginViewModel>(),
        child: Consumer<LoginViewModel>(
            builder: (context, model, child) => Background(
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
                          hintText: "Your Email",
                          editingController: username,
                        ),
                        RoundedPasswordField(
                          editingController: password,
                        ),
                        RoundedButton(
                          text: "LOGIN",
                          color: kButtonColor,
                          isFromForgot: false,
                          press: () async {
                            checkConnection().then((isConnected) async {
                              if (!isConnected) {
                                Commons.invigiFlushBarError(
                                    context, noInternet);
                              } else {
                                EasyLoading.show(status: "  Signing-In...");
                                HashMap inputFields =
                                    HashMap<String, String?>();
                                inputFields['email'] = username.text;
                                inputFields['password'] = password.text;
                                await model.loginUser(context, inputFields);
                                EasyLoading.dismiss();
                              }
                            });
                          },
                        ),
                        SizedBox(height: size.height * 0.03),
                        AlreadyHaveAnAccountCheck(press: () {
                          checkConnection().then((isConnected) {
                            if (isConnected) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SignUpScreen();
                                  },
                                ),
                              );
                            } else {
                              Commons.invigiFlushBarError(context, noInternet);
                            }
                          });
                        }),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ForgotScreen();
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot your password? Reset",
                                style: TextStyle(
                                  color: kButtonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )));
  }
}
