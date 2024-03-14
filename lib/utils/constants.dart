import 'package:flutter/material.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

const kPrimaryColor = Color(0xFF186052);
const kButtonColor = Color(0xFF186052);
const kPrimaryLightColor = Color(0xFFF1E6FF);
const String noInternet = "Please connect your device to the internet.";
const String timeout = "There was a timeout, please try again.";
const String generalError = "There was an error, please try again.";
const String timeoutUpload =
    "There was a timeout with your upload, please try again.";
List<ListItem> listItems = [
  ListItem(Icons.dashboard, "My Dashboard"),
  ListItem(Icons.supervised_user_circle_outlined, "Profile"),
  ListItem(Icons.cloud_upload_outlined, "View Invigilated assessments"),
  ListItem(Icons.pending_outlined, "Pending Uploads"),
  ListItem(Icons.help, "Help"),
  ListItem(Icons.login, "Logout")
];

Future<bool> checkConnection() async {
  bool isConnected = await SimpleConnectionChecker.isConnectedToInternet();
  if (isConnected) {
    return true;
  } else {
    return false;
  }
}

class ListItem {
  IconData value;
  String name;

  ListItem(this.value, this.name);
}
