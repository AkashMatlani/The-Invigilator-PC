import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class AlertService {
  void playAlert() async {
    try {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.setSourceAsset('sounds/swiftly.mp3');
      audioPlayer.play(AssetSource('sounds/swiftly.mp3'));
    } catch (error, stackTrace) {
      await Sentry.captureException(error, stackTrace: stackTrace);
    }
  }
}
