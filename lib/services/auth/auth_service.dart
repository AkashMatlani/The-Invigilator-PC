import 'dart:collection';

import 'package:invigilatorpc/business_logic/models/profile.dart';
import 'package:invigilatorpc/networking/http_service.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';

class AuthService {
  final HttpService _api = serviceLocator<HttpService>();

  Future<List<String?>> loginUser(HashMap inputFields) async {
    var loginUser = await _api.loginUser(inputFields);
    return loginUser;
  }

  Future<List<String?>> userRegister(HashMap inputFields) async {
    var registerUser = await _api.registerUser(inputFields);
    return registerUser;
  }

  Future<List<String?>> confirmAccount(String token) async {
    List<String?> confirm = await _api.confirmAccount(token);
    return confirm;
  }

  Future<List<String?>> resendEmail(String email) async {
    List<String?> resent = await _api.resendEmail(email);
    return resent;
  }

  Future<List<String?>> userPassReset(String email) async {
    List<String?> reset = await _api.resetPassword(email);
    return reset;
  }

  Future<List<String?>> sendMobileConfirmation(String? mobile) async {
    List<String?> reset = await _api.sendMobileConfirmation(mobile);
    return reset;
  }

  Future<Profile> getUserProfile() async {
    var userProfile = await _api.getProfile();
    return userProfile;
  }

  Future<List<String?>> updateUserProfile(HashMap inputFields) async {
    var updateProfile = await _api.updateProfile(inputFields);
    return updateProfile;
  }
}
