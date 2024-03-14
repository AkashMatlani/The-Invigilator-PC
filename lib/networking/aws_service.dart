import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:aws_s3_upload/enum/acl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/hive_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:video_compress/video_compress.dart';
import 'connection_helper.dart';
import 'package:path/path.dart' as path;

class AwsService {
  Future<List<String?>> uploadProfile(String fileUrl) async {
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;

    final data = jsonEncode({
      'user_id': userId.toString(),
      'aws_picture': fileUrl,
    });

    ConnectionHelper api = ConnectionHelper();
    try {
      Map responseBody = await api
          .putHTTP('/api/v2/users/$userId', data)
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
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String>> uploadProfileImage(String filename) async {
    String key = Commons.createCryptoRandomString(14);
    DateTime date = DateTime.now();
    int mins = date.second;
    String uploadFileName = "prof-$key-$mins.jpeg";
    try {
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(filename),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "uploads/public",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "",
          ];
        } else {
          //Initail Selfie file deleted
          File(filename).delete();
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String>> uploadDocumentImage(String filename) async {
    String key = Commons.createCryptoRandomString(14);
    DateTime date = DateTime.now();
    int mins = date.second;
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;
    int examId = preferences.getExamId() ?? 0;
    String uploadFileName = "$userId$examId-doc-$key-$mins.jpg";
    try {
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(filename),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "Documents",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "",
          ];
        } else {
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException {
      return [
        'false',
        "There was a timeout with your upload, please try again.",
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', "Something went wrong on the upload. Please try again"];
    }
  }

  Future<List<String?>> uploadSelfie(
      String? filename, String name, String? existingFile) async {
    try {
      if (existingFile != "") {
        return ['true', existingFile];
      }
      DateTime date = DateTime.now();
      int min = date.second;
      String key = Commons.createCryptoRandomString(15);
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;
      int examId = preferences.getExamId() ?? 0;
      String uploadFileName = "$userId$examId-selfie-$min-$key.jpg";
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(filename!),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "Selfies",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "Failed to upload selfie file",
          ];
        } else {
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<String> compressVideoFFmpeg(
      String inputPath, String outputPath) async {
    try {
      final ffmpegPath = path.join(
        Directory.current.path,
        'ffmpeg',
        'ffmpeg.exe',
      );

      final result = await Process.run(ffmpegPath, [
        '-i',
        inputPath,
        '-c:v',
        'libx264',
        '-crf',
        '28',
        '-preset',
        'medium',
        '-c:a',
        'copy',
        outputPath,
      ]);

      if (result.exitCode == 0) {
        await File(inputPath).delete();
        return outputPath;
      } else {
        return inputPath;
      }
    } catch (e) {
      print("THERE WAS AN ERROR: $e");
      return inputPath;
    }
  }

  Future<void> compressVideo(String videoPath) async {
    try {
      final info = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      final file = File(info!.path!);
      await file.rename(videoPath);
    } catch (e) {}
  }

  Future<List<String?>> uploadVideo(
      String filename, String name, String? existingFile) async {
    try {
      if (existingFile != "") {
        return ['true', existingFile];
      }
      File file = File(filename);
      String filePath = file.path;

      if (Platform.isMacOS) {
        await compressVideo(file.path);
      } else {
        Directory appDocDirectory = await getApplicationDocumentsDirectory();
        String name = Commons.createCryptoRandomString(15);
        String OutputPath =
            appDocDirectory.path + '\\' + "compress_video-$name.mp4";
        filePath = await compressVideoFFmpeg(file.path, OutputPath);
      }

      DateTime date = DateTime.now();
      int min = date.second;
      String key = Commons.createCryptoRandomString(15);
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;
      int examId = preferences.getExamId() ?? 0;
      String uploadFileName = "$userId$examId-video-$min-$key.mp4";
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(filePath),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "Videos",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "Failed to upload the video file",
          ];
        } else {
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String?>> uploadScreenCapture(
      String filename, String name, String? existingFile) async {
    try {
      if (existingFile != "") {
        return ['true', existingFile];
      }
      DateTime date = DateTime.now();
      int min = date.second;
      String key = Commons.createCryptoRandomString(15);
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;
      int examId = preferences.getExamId() ?? 0;
      String uploadFileName = "$userId$examId-screenCapture-$min-$key.jpg";
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(filename),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "ScreenCapture",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "Failed to upload the video file",
          ];
        } else {
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String?>> uploadMicrophone(
      String filename, String name, String? existingFile) async {
    try {
      if (existingFile != "") {
        return ['true', existingFile];
      }
      DateTime date = DateTime.now();
      int min = date.second;
      String key = Commons.createCryptoRandomString(15);
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;
      int examId = preferences.getExamId() ?? 0;
      String uploadFileName = "$userId$examId-mic-$min-$key.mp4";
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(filename),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "Microphone",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "Failed to upload the microphone file",
          ];
        } else {
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String>> uploadDataFile(File datafile) async {
    String key = Commons.createCryptoRandomString(15);
    final preferences = await HivePreferences.getInstance();
    int examId = preferences.getExamId() ?? "none" as int;

    try {
      String uploadFileName = "$key.json";
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(datafile.path),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "Results/$examId",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) async {
        if (value == null) {
          return [
            'false',
            "Failed to upload data file",
          ];
        } else {
          //delete local json file
          File(datafile.path).delete();
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String>> uploadCalibrationFile(
      String filename, String typeofFile, String ext) async {
    DateTime date = DateTime.now();
    int min = date.second;
    String key = Commons.createCryptoRandomString();
    String uploadFileName = "$min-$key-$typeofFile.$ext";
    File file = File(filename);

    try {
      Future<String?> result = AwsS3.uploadFile(
        accessKey: dotenv.env['ACCESS_KEY']!,
        secretKey: dotenv.env['SECRET_KEY']!,
        file: File(file.path),
        bucket: dotenv.env['BUCKET']!,
        region: dotenv.env['REGION']!,
        filename: uploadFileName,
        destDir: "Calibration",
        acl: ACL.bucket_owner_full_control,
      );
      return result.then((value) {
        if (value == null) {
          return [
            'false',
            "Failed to upload the microphone file",
          ];
        } else {
          return [
            'true',
            value,
          ];
        }
      });
    } on TimeoutException catch (e) {
      print('exception: $e');
      return [
        'false',
        timeoutUpload,
      ];
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String?>> uploadCalibrationFileToServer(
      String filePath, String fileName, String uploadKey) async {
    final preferences = await HivePreferences.getInstance();
    int userId = preferences.getUserId() ?? 0;

    final data = jsonEncode({
      'user_id': userId.toString(),
      '$fileName': filePath,
      'lookup_token': uploadKey,
    });

    ConnectionHelper api = ConnectionHelper();

    try {
      Map responseBody = await api
          .postHTTP('/api/v2/device_calibrations', data)
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
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }

  Future<List<String?>> uploadCalibrationResultsServer(
      bool selfiePassed,
      bool facePassed,
      bool descPassed,
      bool videoPassed,
      bool micPassed,
      bool soundPassed,
      String deviceDetails,
      String deviceLookup,
      String uploadKey,
      String errorMessage) async {
    try {
      final preferences = await HivePreferences.getInstance();
      int userId = preferences.getUserId() ?? 0;

      final data = jsonEncode({
        'user_id': userId.toString(),
        'selfie_passed': selfiePassed.toString(),
        'facial_recognition_passed': facePassed.toString(),
        'description_photo_passed': descPassed.toString(),
        'video_passed': videoPassed.toString(),
        'microphone_passed': micPassed.toString(),
        'sound_passed': soundPassed.toString(),
        'device_details': deviceDetails,
        'device_lookup': deviceLookup,
        'lookup_token': uploadKey,
        'error_message': errorMessage
      });

      ConnectionHelper api = ConnectionHelper();
      Map responseBody = await api
          .postHTTP('/api/v2/device_calibrations', data)
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
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
      return ['false', error.toString()];
    }
  }
}
