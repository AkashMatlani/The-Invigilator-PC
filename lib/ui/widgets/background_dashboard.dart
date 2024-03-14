import 'package:flutter/material.dart';

class BackgroundDashboard extends StatelessWidget {
  final Widget child;

  const BackgroundDashboard({
    Key? key,
    required this.child,
  }) : super(key: key);

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
              colors: [Colors.teal[300]!, Colors.teal]),
        ),
        child: child);
  }
}
