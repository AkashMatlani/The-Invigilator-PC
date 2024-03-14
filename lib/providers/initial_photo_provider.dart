import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invigilatorpc/networking/aws_service.dart';
import 'package:invigilatorpc/utils/commons.dart';

class InitialPhotoProvider extends ChangeNotifier {
  // init camera
  // selfie captured
  // face validation
  // upload to backend
  // pick image
  // request permissions
  // camera switcher

  bool _isProcessing = false;
  bool _cameraOpen = false;
  String? _loadingText = "Uploading...";
  String _filePath = '';
  bool _isImageLoaded = false;

  List? cameras;
  int? selectedCameraIndex;
  String? path;
  String? imgPath;

  Future<String> captureSelfie() async {
    final p = await getApplicationDocumentsDirectory();
    final name = Commons.createCryptoRandomString();
    String path = "${p.path}/$name.jpg";
    return path;
  }

  bool get cameraOpen => _cameraOpen;

  set cameraOpen(bool value) {
    _cameraOpen = value;
    notifyListeners();
  }

  bool get isProcessing => _isProcessing;

  set isProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  String? get loadingText => _loadingText;

  set loadingText(String? value) {
    _loadingText = value;
    notifyListeners();
  }

  String get filePath => _filePath;

  set filePath(String value) {
    _filePath = value;
    notifyListeners();
  }

  bool get isImageLoaded => _isImageLoaded;

  set isImageLoaded(bool value) {
    _isImageLoaded = value;
    notifyListeners();
  }

  Future<List<String>> loadedImage(
      InitialPhotoProvider initialPhotoProvider) async {
    AwsService serv = AwsService();
    List<String> loaded =
        await serv.uploadProfileImage(initialPhotoProvider.filePath);
    return loaded;
  }

  AwsService awsService() {
    AwsService serv = AwsService();
    return serv;
  }
}
