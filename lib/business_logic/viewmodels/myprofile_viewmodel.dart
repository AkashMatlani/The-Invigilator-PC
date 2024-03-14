import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:invigilatorpc/services/auth/auth_service.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/utils/commons.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService? _authService = serviceLocator<AuthService>();
  String? userFirstName = "";
  String? userSurName = "";
  String? userEmail = "";
  String? phoneNumber = "";
  String? profileImage = "";

  bool isLoading = false;
  bool isUpdatingProfile = false;

  void getUserProfile(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    var userProfile = await _authService!.getUserProfile();
      if (userProfile.success == true) {
        isLoading = false;
        userFirstName = userProfile.firstName;
        userSurName = userProfile.lastName;
        userEmail = userProfile.email;
        phoneNumber = userProfile.mobileNumber;
        profileImage = userProfile.profileImage;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
        Commons.invigiFlushBarError(context, userProfile.error);
      }
  }

  void updateUserProfile(BuildContext context, HashMap inputFields) async {
    isUpdatingProfile = true;
    notifyListeners();
    var userProfile = await _authService!.updateUserProfile(inputFields);
    if (userProfile[0] == 'true') {
      isUpdatingProfile = false;
      Commons.invigiFlushBarSuccess(context, "Successfully updated user profile.");
      notifyListeners();
    } else {
      isUpdatingProfile = false;
      notifyListeners();
      Commons.invigiFlushBarError(context, userProfile[1]);
    }
  }
}
