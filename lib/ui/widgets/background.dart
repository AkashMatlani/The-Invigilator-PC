import 'package:flutter/material.dart';

//ignore: must_be_immutable
class Background extends StatelessWidget {
  Widget child;
  bool? alignValue;

  Background({Key? key, required this.child, this.alignValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.teal[400]!, Colors.teal[200]!]),
      ),
      child: alignValue != null && alignValue!
          ? Stack(children: <Widget>[child])
          : Stack(alignment: Alignment.center, children: <Widget>[child]),
    );
  }
}
