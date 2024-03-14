import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/confirm_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/confirmation/email_notice.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/ui/widgets/rounded_input_field.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';

class ConfirmScreen extends StatefulWidget {
  final bool isFromUnConfirmed;

  ConfirmScreen(this.isFromUnConfirmed);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  ConfirmViewModel? modelConfirm = serviceLocator<ConfirmViewModel>();
  final pinToken = TextEditingController();
  var scollBarController = ScrollController();

  @override
  void dispose() {
    pinToken.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isFromUnConfirmed) modelConfirm!.resendUnconfirmedEmail(context);
    modelConfirm!.getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: ChangeNotifierProvider<ConfirmViewModel?>(
            create: (context) => modelConfirm,
            child: Consumer<ConfirmViewModel>(
                builder: (context, model, child) => Background(
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: scollBarController,
                        child: SingleChildScrollView(
                          controller: scollBarController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                owl,
                                height: size.height * 0.25,
                              ),
                              SizedBox(height: size.height * 0.03),
                              Text(
                                "CONFIRM YOUR ACCOUNT",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontFamily: 'Neufreit'),
                              ),
                              SizedBox(height: size.height * 0.03),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 30, right: 30),
                                child: EmailNotice(),
                              ),
                              SizedBox(height: size.height * 0.03),
                              RoundedInputField(
                                hintText: "Sign-up Verification Pin",
                                editingController: pinToken,
                              ),
                              RoundedButton(
                                text: "VERIFY",
                                color: kButtonColor,
                                isFromForgot:false,
                                press: () async {
                                  checkConnection().then((isConnected) {
                                    if (isConnected) {
                                      model.tokenEntered = pinToken.text;
                                      model.confirmAccountAction(context);
                                    } else {
                                      Commons.invigiFlushBarError(
                                          context, noInternet);
                                    }
                                  });
                                },
                              ),
                              SizedBox(height: size.height * 0.01),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 30, right: 30),
                                child: Text(
                                  "* TIP: check your spam/junk/promotions folder if you don’t see it in your inbox",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Neufreit'),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      checkConnection().then((isConnected) {
                                        if (isConnected) {
                                          model.resendEmail(context);
                                        } else {
                                          Commons.invigiFlushBarError(
                                              context, noInternet);
                                        }
                                      });
                                    },
                                    child: Text(
                                      "Did not receive email? Re-send",
                                      style: TextStyle(
                                        color: kButtonColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      checkConnection().then((isConnected) {
                                        if (!isConnected) {
                                          Commons.invigiFlushBarError(
                                              context, noInternet);
                                        } else {
                                          EasyLoading.show(
                                              status:
                                                  "  Sending verification pin...");
                                          model.sendMobileConfirmation(context);
                                          EasyLoading.dismiss();
                                        }
                                      });
                                    },
                                    child: Text(
                                      "Send verification pin to my cellphone",
                                      style: TextStyle(
                                        color: kButtonColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ))));
  }
}
