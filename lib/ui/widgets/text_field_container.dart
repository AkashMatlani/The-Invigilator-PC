import 'package:flutter/material.dart';
import 'package:invigilatorpc/utils/constants.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget? child;
  final double? padding;

  TextFieldContainer({
    Key? key,
    this.padding,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding:
          EdgeInsets.symmetric(horizontal: 20, vertical: this.padding ?? 5),
      width: size.width * 0.3,
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
