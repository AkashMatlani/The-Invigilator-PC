import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/signup_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/login/login_screen.dart';
import 'package:invigilatorpc/ui/signup/universities.dart';
import 'package:invigilatorpc/ui/widgets/already_have_an_account_acheck.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/ui/widgets/rounded_input_field.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/widgets/rounded_password_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen();

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignUpKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final studentNumber = TextEditingController();
  final email = TextEditingController();
  final confirmEmail = TextEditingController();
  final mobileNumber = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  var scollBarController = ScrollController();

  @override
  void initState() {
    super.initState();
    checkConnection().then((isConnected) {
      if (!isConnected) {
        Commons.invigiFlushBarError(context, noInternet);
      } else {
        serviceLocator<SignupViewModel>().getUniversities(context);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstName.dispose();
    lastName.dispose();
    studentNumber.dispose();
    email.dispose();
    confirmEmail.dispose();
    mobileNumber.dispose();
    password.dispose();
    confirmPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: ChangeNotifierProvider<SignupViewModel?>.value(
            value: serviceLocator<SignupViewModel>(),
            child: Consumer<SignupViewModel>(
                builder: (context, model, child) => Background(
                      alignValue: true,
                      child: model.gettingUniversities
                          ? Center(
                              child: Commons.invigiLoading(
                                  model.loadingText!, false),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Scrollbar(
                                  thumbVisibility: true,
                                  controller: scollBarController,
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      controller: scollBarController,
                                      child: model.gettingUniversities
                                          ? Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Center(
                                                      child: model.hasConnection ==
                                                              false
                                                          ? Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: const <
                                                                  Widget>[
                                                                  Icon(
                                                                      Icons
                                                                          .error,
                                                                      size: 65,
                                                                      color: Colors
                                                                          .red),
                                                                  Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              30),
                                                                      child:
                                                                          Text(
                                                                        noInternet,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                'Neufreit'),
                                                                      )),
                                                                ])
                                                          : Commons.invigiLoading(
                                                              model
                                                                  .loadingText!,
                                                              false)),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.03),
                                                  model.hasConnection == false
                                                      ? RoundedButton(
                                                          text: "Retry",
                                                          color: kButtonColor,
                                                          isFromForgot:false,
                                                          press: () {
                                                            model
                                                                .getUniversities(
                                                                    context);
                                                          })
                                                      : Container(),
                                                ],
                                              ),
                                            )
                                          : Form(
                                              key: _formSignUpKey,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.02),
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                left: 10),
                                                        child: Image.asset(
                                                          owl,
                                                          height: size.height *
                                                              0.10,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Expanded(
                                                        flex: 0,
                                                        child: Container(
                                                          width:
                                                              size.width * 0.16,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: const Text(
                                                          "SIGNUP",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      Spacer(),
                                                    ],
                                                  ),
                                                  UniversityField(),
                                                  RoundedInputField(
                                                    hintText: "First Name",
                                                    editingController:
                                                        firstName,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedInputField(
                                                    hintText: "Last Name",
                                                    editingController: lastName,
                                                    icon: Icons.work,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedInputField(
                                                    hintText: "Student Number",
                                                    icon: Icons.credit_card,
                                                    editingController:
                                                        studentNumber,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedInputField(
                                                    hintText: "Your Email",
                                                    icon: Icons.email,
                                                    editingController: email,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedInputField(
                                                    hintText:
                                                        "Confirm Your Email",
                                                    icon: Icons.email,
                                                    editingController:
                                                        confirmEmail,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedInputField(
                                                    hintText: "Mobile Number",
                                                    icon: Icons.phone,
                                                    editingController:
                                                        mobileNumber,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedPasswordField(
                                                      hintText: 'Password',
                                                      editingController:
                                                          password),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  RoundedPasswordField(
                                                    editingController:
                                                        confirmPassword,
                                                    hintText:
                                                        'Confirm Password',
                                                  ),
                                                  RoundedButton(
                                                      text: "SIGNUP",
                                                      isFromForgot:false,
                                                      press: () async {
                                                        checkConnection().then(
                                                            (isConnected) async {
                                                          if (!isConnected) {
                                                            Commons
                                                                .invigiFlushBarError(
                                                                    context,
                                                                    noInternet);
                                                          } else {
                                                            //Inputs
                                                            model.inputFields[
                                                                    'first_name'] =
                                                                firstName.text;
                                                            model.inputFields[
                                                                    'last_name'] =
                                                                lastName.text;
                                                            model.inputFields[
                                                                    'student_number'] =
                                                                studentNumber
                                                                    .text;
                                                            model.inputFields[
                                                                    'email'] =
                                                                email.text;
                                                            model.inputFields[
                                                                    'confirm_email'] =
                                                                confirmEmail
                                                                    .text;
                                                            model.inputFields[
                                                                    'mobile'] =
                                                                mobileNumber
                                                                    .text;
                                                            model.inputFields[
                                                                    'password'] =
                                                                password.text;
                                                            model.inputFields[
                                                                    'confirm_password'] =
                                                                confirmPassword
                                                                    .text;
                                                            // End Inputs
                                                            EasyLoading.show(
                                                                status:
                                                                    "  Signing-Up...");
                                                            await model
                                                                .signUpUser(
                                                                    context);
                                                            EasyLoading
                                                                .dismiss();
                                                            // }
                                                          }
                                                        });
                                                      }),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                  AlreadyHaveAnAccountCheck(
                                                    login: false,
                                                    press: () {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return LoginScreen();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.06),
                                                ],
                                              ),
                                            )),
                                )
                              ],
                            ),
                    ))));
  }
}
