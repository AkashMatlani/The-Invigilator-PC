import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({Key? key}) : super(key: key);

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  void initState() {
    super.initState();
    closeKeyboard();
  }

  void closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Background(
        child: Scaffold(
            backgroundColor: Colors.teal[300],
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130.0,
                    height: 130.0,
                    margin: const EdgeInsets.only(
                      top: 36.0,
                      bottom: 34.0,
                    ),
                    child: Image.asset(
                      owl,
                    ),
                  ),
                  InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      Commons.logOutDialog(context);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Center(
                            child: Text("Logout",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: 'Neufreit')),
                          ),
                        ),
                      ],
                    ),
                  )
                ])));
  }
}
