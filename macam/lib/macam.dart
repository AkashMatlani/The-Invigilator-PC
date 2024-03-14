import 'dart:async';
import 'package:flutter/services.dart';

const _kChannel = 'com.matthewriemer.macam/method';

class Macam {
  Macam() : _channel = MethodChannel(_kChannel) {
    _channel.setMethodCallHandler(_onMethodCall);
  }
  final MethodChannel _channel;

  Future<String> openCamera(
      {String buttonTitle = 'Close',
      String? fileName,
      bool isVideo = false,
      int recordingDuration = 10,
      bool hidden = false}) async {
    assert(fileName != null);

    final path = await _channel.invokeMethod<String>('open', {
      'buttonTitle': buttonTitle,
      'fileName': fileName,
      'isVideo': isVideo,
      'recordingDuration': recordingDuration,
      'hidden': hidden
    });
    return path!;
  }

  Future<void> close() async {
    await _channel.invokeMethod('close');
  }

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'default':
        return;
    }
  }
}
