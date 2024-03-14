import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:invigilatorpc/business_logic/models/profile.dart';
import 'package:invigilatorpc/networking/connection_helper.dart';
import 'package:invigilatorpc/networking/reset_details_connection_helper.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'start_exam_helper.dart';

class HttpService {
  Future<List<String>> cancelExamResult(int? examId) async {
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;
    StartExamHelper api = StartExamHelper();
    try {
      Map responseBody = await api
          .deleteHTTP('/api/v3/cancel_exam/$examId?user_id=$userId')
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        if (responseBody['code'] == 200) {
          preferences.setStarterChosen(null);
          return [
            'true',
            "success",
          ];
        } else {
          return [
            'false',
            "failed",
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String>> getExamDetailsForExam(String? exam, position) async {
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;
    StartExamHelper api = StartExamHelper();
    double latitude;
    double longitude;
    String? studentNum = '';
    String? userName = '';
    String? profilePicture = '';
    try {
      latitude = position.latitude;
      longitude = position.longitude;
      final preferences = await HivePreferences.getInstance();
      preferences.setStartLatitude(latitude);
      preferences.setStartLongitude(longitude);
      studentNum = preferences.getStudentNum();
      userName = preferences.getUserName();
      profilePicture = preferences.getProfileUrl();
      Commons.studentNumber = studentNum;
      Commons.userName = userName;
      Commons.profilePicture = profilePicture;
      FastCachedImageConfig.isCached(imageUrl: profilePicture!);
    } catch (e) {}

    try {
      String? version = dotenv.env['VERSION'];
      Map responseBody = await api
          .getHTTP(
              '/api/v4/exams/$exam?user_id=$userId&version=$version&num=$studentNum')
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        Map responseData = responseBody['body'];
        var error = responseData['error'];
        if (responseBody['code'] == 200) {
          return [
            'true',
            responseData['exam'],
          ];
        } else {
          return [
            'false',
            error,
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List> getPreviousResultsForUser() async {
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .getHTTP('/api/v2/user/$userId/results')
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        if (responseBody['code'] == 200) {
          List<dynamic> results = responseBody['body']['results'];
          if (results.isNotEmpty) {
            return ['true', results];
          } else {
            return ['true', []];
          }
        } else {
          return ['false', []];
        }
      }
    } on TimeoutException {
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> sendMobileConfirmation(String? mobile) async {
    var data = json.encode({
      'mobile': mobile,
    });
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .postHTTP('/api/v2/send_mobile_confirmation', data)
          .timeout(const Duration(seconds: 35));

      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        var statusMessage = responseBody['body']['status'];
        if (responseBody['code'] == 200) {
          return [
            'true',
            statusMessage,
          ];
        } else {
          return [
            'false',
            statusMessage,
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> resetPassword(String email) async {
    var data = json.encode({
      'email': email,
    });
    ResetDetailsConnectionHelper api = ResetDetailsConnectionHelper();
    try {
      Map responseBody = await api
          .postHTTP('/api/v2/reset_password', data)
          .timeout(const Duration(seconds: 35));

      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        var statusMessage = responseBody['body']['status'];
        if (responseBody['code'] == 200) {
          return [
            'true',
            statusMessage,
          ];
        } else {
          return [
            'false',
            statusMessage,
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> loadUniversities() async {
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .getHTTP('/api/v2/universities')
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        List<dynamic> unis = responseBody['body']['universities'];
        return List<String>.from(unis);
      }
    } on TimeoutException {
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> registerUser(HashMap inputFields) async {
    var universityTitle = inputFields['university_title'];
    var firstName = inputFields['first_name'];
    var lastName = inputFields['last_name'];
    var studentNum = inputFields['student_number'];
    var email = inputFields['email'];
    var confirmEmail = inputFields['confirm_email'];
    var mobile = inputFields['mobile'];
    var password = inputFields['password'];
    var confirmPassword = inputFields['confirm_password'];
    var platform = "";
    if (Platform.isWindows) {
      platform = "windows";
    } else {
      platform = "macos";
    }

    var modelName = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isWindows) {
      WindowsDeviceInfo windowInfo = await deviceInfo.windowsInfo;
      modelName = windowInfo.productName;
    } else {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      modelName = macOsDeviceInfo.model;
    }

    var data = json.encode({
      'university_title': universityTitle,
      'first_name': firstName,
      'last_name': lastName,
      'student_number': studentNum,
      'email': email,
      'confirm_email': confirmEmail,
      'mobile_number': mobile,
      'password': password,
      'confirm_password': confirmPassword,
      'version': dotenv.env['VERSION'],
      'platform': platform,
      'device': modelName,
    });
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .postHTTP('/api/v2/users', data)
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        var statusMessage = responseBody['body']['status'];
        if (responseBody['code'] == 200) {
          Map responseData = responseBody['body'];
          var userID = responseData['id'];
          var name = responseData['name'];
          var emailLogged = responseData['email'];
          var mobileNum = responseData['mobile_number'];
          var studentNumber = responseData['student_number'];
          final preferences = await HivePreferences.getInstance();
          preferences.setUserId(userID);
          preferences.setUserName(name);
          preferences.setUserEmail(emailLogged);
          preferences.setUserMobile(mobileNum);
          preferences.setStudentNum(studentNumber);
          preferences.setIsProfileSetup(false);
          preferences.setHasAcceptedTerms(false);
          preferences.setIsAccountConfirmed(false);
          preferences.setIsServiceCalibrated(false);
          return [
            'true',
            statusMessage,
          ];
        } else {
          return [
            'false',
            statusMessage,
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> resendEmail(String email) async {
    var data = json.encode({
      'email': email,
    });
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .postHTTP('/api/v2/user/resend_confirm_email', data)
          .timeout(const Duration(seconds: 35));

      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        if (responseBody['code'] == 200) {
          return [
            'true',
            "success",
          ];
        } else {
          return [
            'false',
            "failed",
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> acceptTerms() async {
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? "" as int;
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .getHTTP('/api/v2/user/$userId/accept_terms')
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        if (responseBody['code'] == 200) {
          return [
            'true',
            "success",
          ];
        } else {
          return [
            'false',
            "failed",
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> confirmAccount(String token) async {
    var data = json.encode({
      'token': token,
    });
    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .postHTTP('/api/v2/user/confirm_account', data)
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        if (responseBody['code'] == 200) {
          return [
            'true',
            "success",
          ];
        } else {
          return [
            'false',
            "failed",
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<List<String?>> loginUser(HashMap inputFields) async {
    var email = inputFields['email'];
    var password = inputFields['password'];
    var platform = "";
    if (Platform.isWindows) {
      platform = "windows";
    } else {
      platform = "macos";
    }

    var modelName = "";
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isWindows) {
      WindowsDeviceInfo windowInfo = await deviceInfo.windowsInfo;
      modelName = windowInfo.productName;
    } else {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      modelName = macOsDeviceInfo.model;
    }

    var data = json.encode({
      'email': email,
      'password': password,
      'version': dotenv.env['VERSION'],
      'device': modelName,
      'platform': platform
    });

    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .postHTTP('/api/v2/sessions/create', data)
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        var statusMessage = responseBody['body']['status'];
        if (responseBody['code'] == 200) {
          Map responseData = responseBody['body'];
          var userID = responseData['id'.toString()];
          var name = responseData['name'];
          var email = responseData['email'];
          var mobile = responseData['mobile_number'];
          var profileUrl = responseData['profile_url'];
          var studentNumber = responseData['student_number'];
          bool? profileDone = responseData['profile_setup'];
          bool? confirmedAccount = responseData['confirmed_account'];
          bool? calibrated = responseData['calibrated'];
          bool? acceptedTerms = responseData['accepted_terms'];

          // obtain hive preferences
          final preferences = await HivePreferences.getInstance();
          preferences.setUserId(userID);
          preferences.setUserName(name);
          preferences.setUserEmail(email);
          preferences.setStudentNum(studentNumber);
          preferences.setUserMobile(mobile);
          preferences.setIsProfileSetup(profileDone);
          preferences.setHasAcceptedTerms(acceptedTerms);
          preferences.setIsAccountConfirmed(confirmedAccount);
          preferences.setIsServiceCalibrated(calibrated);
          if (profileUrl != null) {
            preferences.setProfileUrl(profileUrl);
            try {
              Commons.profilePicture = profileUrl;
              FastCachedImageConfig.isCached(imageUrl: profileUrl!);
            } catch (e) {}
          }
          return [
            'true',
            statusMessage,
          ];
        } else {
          return [
            'false',
            statusMessage,
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }

  Future<Profile> getProfile() async {
    ConnectionHelper api = ConnectionHelper();
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;
    Profile profile = Profile();
    try {
      Map responseBody = await api
          .getHTTP('/api/v3/profile/$userId')
          .timeout(const Duration(seconds: 35));
      if (responseBody['body'] == "timeout") {
        profile.error = "timeout";
        return profile;
      } else if (responseBody['body'] == "error") {
        profile.error = "error";
        return profile;
      } else {
        if (responseBody['code'] == 200) {
          profile.success = true;
          Map<String, dynamic> myProfile =
              Map<String, dynamic>.from((responseBody['body']));
          profile.firstName = myProfile['first_name'];
          profile.lastName = myProfile['last_name'];
          profile.mobileNumber = myProfile['mobile_number'];
          profile.profileImage = myProfile['profile_image'];
          profile.email = myProfile['email'];
          return profile;
        } else {
          profile.success = false;
          profile.error = generalError;
          return profile;
        }
      }
    } on TimeoutException {
      profile.success = false;
      profile.error = "timeout";
      return profile;
    } catch (e) {
      profile.success = false;
      profile.error = generalError;
      return profile;
    }
  }

  Future<List<String?>> updateProfile(HashMap inputFields) async {
    ConnectionHelper api = ConnectionHelper();
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;
    var firstname = inputFields['first_name'];
    var surname = inputFields['last_name'];
    var mobile = inputFields['mobile_number'];
    var password = inputFields['password'];
    var passwordConfirm = inputFields['password_confirmation'];

    var data = json.encode({
      'first_name': firstname,
      'last_name': surname,
      'mobile_number': mobile,
      "password": password,
      "password_confirmation": passwordConfirm,
    });

    try {
      Map responseBody = await api
          .putHTTP('/api/v3/profile/$userId', data)
          .timeout(const Duration(seconds: 35));

      if (responseBody['body'] == "timeout") {
        return [
          'false',
          timeout,
        ];
      } else if (responseBody['body'] == "error") {
        return ['false', responseBody['errorMessage']];
      } else {
        var statusMessage = responseBody['body']['status'];
        if (responseBody['code'] == 200) {
          return [
            'true',
            statusMessage,
          ];
        } else {
          return [
            'false',
            statusMessage,
          ];
        }
      }
    } on TimeoutException catch (e) {
      print(e);
      return [
        'false',
        timeout,
      ];
    } catch (e) {
      return [
        'false',
        generalError,
      ];
    }
  }
}
