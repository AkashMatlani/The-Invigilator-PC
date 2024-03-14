import 'package:flutter/material.dart';
import 'package:invigilatorpc/utils/constants.dart';

class RoundedButton extends StatelessWidget {
  final String? text;
  final Function? press;
  final Color color, textColor;
  final double fontSize;
  final double? width;
  final bool? isFromForgot;

  RoundedButton({
    Key? key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
    this.fontSize = 15.0,
    this.width,
    this.isFromForgot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: width != null ? size.width * width! : size.width * 0.22,
      height: isFromForgot! ? 60 : 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
            padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
          ),
          onPressed: press as void Function()?,
          child: Text(
            text!,
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontFamily: 'Neufreit'),
          ),
        ),
      ),
    );
  }
}
