import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/confirm_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';

class EmailNotice extends StatefulWidget {
  @override
  _EmailNoticeState createState() => _EmailNoticeState();
}

class _EmailNoticeState extends State<EmailNotice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ConfirmViewModel?>(
        create: (context) => serviceLocator<ConfirmViewModel>(),
        child: Consumer<ConfirmViewModel>(
            builder: (context, model, child) => Text(
                  "We sent a confirmation email to: " +
                      model.emailEntered +
                      " with the code to activate your account.\n Please enter that code below to activate your account. If you did not receive a code tap \n the link below to re-send the email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontFamily: 'Neufreit'),
                )));
  }
}
