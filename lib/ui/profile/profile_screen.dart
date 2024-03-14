import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/myprofile_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background_dashboard.dart';
import 'package:invigilatorpc/ui/widgets/rounded_button.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileViewModel? modelProfile = serviceLocator<ProfileViewModel>();
  var _firstnameController = TextEditingController();
  var _surnameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _password1Controller = TextEditingController();
  var _password2Controller = TextEditingController();
  HashMap inputFields = HashMap<String, String>();
  bool _passwordVisible1 = true;
  bool _passwordVisible2 = true;

  @override
  void initState() {
    super.initState();
    modelProfile!.getUserProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileViewModel?>(
        create: (context) => modelProfile,
        child: Consumer<ProfileViewModel>(builder: (context, model, child) {
          return Scaffold(
              backgroundColor: Colors.teal[500],
              body: !model.isLoading
                  ? profileView(model)
                  : Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.teal[400],
                            borderRadius: new BorderRadius.circular(10.0)),
                        width: 300.0,
                        height: 200.0,
                        alignment: AlignmentDirectional.center,
                        child: Commons.invigiLoading(
                            "Getting user profile", false),
                      ),
                    ));
        }));
  }

  Widget profileView(ProfileViewModel model) {
    return BackgroundDashboard(
        child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30, 20, 30, 25),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Container(
            child: CircleAvatar(
              maxRadius: 70,
              backgroundImage: NetworkImage(model.profileImage ?? ""),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextFormField(
                              autofocus: false,
                              keyboardType: TextInputType.name,
                              maxLines: 1,
                              validator: (value) => (value!.isEmpty)
                                  ? "Please enter a first name."
                                  : null,
                              style: TextStyle(color: Colors.black54),
                              controller: _firstnameController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kPrimaryLightColor,
                                prefixIcon: Icon(Icons.account_circle,
                                    color: kPrimaryColor),
                                hintText: model.userFirstName!,
                                hintStyle: TextStyle(color: Colors.black54),
                                labelText: 'Firstname',
                                labelStyle: TextStyle(color: kPrimaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: Colors.white60,
                                    width: 0.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.30,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    validator: (value) =>
                        (value!.isEmpty) ? "Please enter a last name." : null,
                    autofocus: false,
                    keyboardType: TextInputType.name,
                    maxLines: 1,
                    style: TextStyle(color: Colors.black54),
                    controller: _surnameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      prefixIcon:
                          Icon(Icons.account_circle, color: kPrimaryColor),
                      hintText: model.userSurName,
                      hintStyle: TextStyle(color: Colors.black54),
                      labelText: 'Surname',
                      labelStyle: TextStyle(color: kPrimaryColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white60,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 4),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FittedBox(
                              child: Icon(Icons.email, color: kPrimaryColor),
                              fit: BoxFit.fill),
                          SizedBox(width: 5),
                          Text(
                            model.userEmail!,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: kPrimaryLightColor,
                      borderRadius: BorderRadius.all(Radius.circular(29)),
                      border: Border.all(width: 1.0, color: Colors.white70)),
                ),
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.30,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    maxLines: 1,
                    validator: (value) => (value!.isEmpty)
                        ? "Please enter a valid phone number."
                        : null,
                    style: TextStyle(color: Colors.black54),
                    controller: _phoneController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      prefixIcon: Icon(Icons.phone, color: kPrimaryColor),
                      hintText: model.phoneNumber,
                      hintStyle: TextStyle(color: Colors.black54),
                      labelText: 'Phone',
                      labelStyle: TextStyle(color: kPrimaryColor),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white60,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.30,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    style: TextStyle(color: Colors.black54),
                    obscureText: _passwordVisible1,
                    validator: Validators.compose([
                      Validators.required('Password is required.'),
                      Validators.patternString(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                          'Invalid Password')
                    ]),
                    controller: _password1Controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible1
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible1 = !_passwordVisible1;
                          });
                        },
                      ),
                      prefixIcon: Icon(Icons.password, color: kPrimaryColor),
                      hintText: "",
                      hintStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0,
                        ),
                      ),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: kPrimaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white60,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * 0.30,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.visiblePassword,
                    maxLines: 1,
                    obscureText: _passwordVisible2,
                    validator: Validators.compose([
                      Validators.required('Password is required.'),
                      Validators.patternString(
                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                          'Invalid Password')
                    ]),
                    style: TextStyle(color: Colors.black54),
                    controller: _password2Controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible2
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible2 = !_passwordVisible2;
                          });
                        },
                      ),
                      prefixIcon: Icon(Icons.password, color: kPrimaryColor),
                      hintText: "",
                      hintStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1.0,
                        ),
                      ),
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: kPrimaryColor),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.white60,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              RoundedButton(
                text: "Modify your details",
                color: kButtonColor,
                isFromForgot:false,
                press: () async {
                  updateProfile();
                },
              ),
            ],
          ),
        )),
      ],
    ));
  }

  updateProfile() {
    var validated = false;
    if (_firstnameController.text == "" &&
        _surnameController.text == "" &&
        _phoneController.text == "" &&
        _password1Controller.text == "" &&
        _password2Controller.text == "") {
      Commons.invigiFlushBarError(context, "No information has been entered.");
      validated = false;
    } else {
      if (_password1Controller.text != "" || _password2Controller.text != "") {
        if (_password1Controller.text != _password2Controller.text) {
          Commons.invigiFlushBarError(context, "Passwords do not match.");
          validated = false;
        } else {
          validated = true;
        }
      } else {
        validated = true;
      }
    }

    if (validated) {
      inputFields['first_name'] = _firstnameController.text;
      inputFields['last_name'] = _surnameController.text;
      inputFields['mobile_number'] = _phoneController.text;
      inputFields['password'] = _password1Controller.text;
      inputFields['password_confirmation'] = _password2Controller.text;
      modelProfile!.updateUserProfile(context, inputFields);
    }
  }
}
