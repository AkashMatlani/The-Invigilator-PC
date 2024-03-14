import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invigilatorpc/ui/widgets/background_dashboard.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
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
    return Scaffold(
        body: BackgroundDashboard(
            child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              SizedBox(
                height: 10.0,
              ),
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
              SizedBox(
                height: 10.0,
              ),
              DottedBorder(
                  color: Colors.white,
                  strokeWidth: 2,
                  child: Container(
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        'If you are having technical difficulties or have \nany questions, please contact +27 73 505 8273 via \n WhatsApp for student support.',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  )),
              Spacer()
            ]),
      ),
    )));
  }
}
