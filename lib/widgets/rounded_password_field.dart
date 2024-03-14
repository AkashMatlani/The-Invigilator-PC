import 'package:flutter/material.dart';
import 'package:invigilatorpc/ui/widgets/text_field_container.dart';
import 'package:invigilatorpc/utils/constants.dart';

class RoundedPasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController? editingController;

  const RoundedPasswordField(
      {Key? key, this.hintText = 'Password', this.editingController})
      : super(key: key);

  @override
  _RoundedPasswordFieldState createState() =>
      _RoundedPasswordFieldState(hintText, editingController);
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  final String hintText;
  final TextEditingController? editingController;
  bool canSeePass = false;

  _RoundedPasswordFieldState(this.hintText, this.editingController);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: canSeePass == false ? true : false,
        controller: editingController,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: hintText,
          icon: Icon(
            Icons.lock,
            color: kButtonColor,
          ),
          suffixIcon: IconButton(
            color: kButtonColor,
            icon: canSeePass == false
                ? Icon(Icons.visibility)
                : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                canSeePass = canSeePass == true ? false : true;
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
