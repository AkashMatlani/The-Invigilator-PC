import 'package:flutter/cupertino.dart';
import 'package:macam/macam.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  Future<void> _onOpenPressed() async {
    final webview = Macam();
    // String pepper = await webview.takePhoto(
    //     buttonTitle: "Take Photo",
    //     fileName: "Licken",
    //     isVideo: false,
    //     recordingDuration: 10);

    String pepper = await webview.openCamera(
        buttonTitle: "Record Video",
        fileName: "bingbing",
        isVideo: true,
        recordingDuration: 10,
        hidden: false);

    print(pepper);
    // String bol = await webview.onReceivedFile();

    // await webview.open();
    // await Future.delayed(Duration(seconds: 5));
    // await webview.close();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            child: Text('Open as sheet'),
            onPressed: () => _onOpenPressed(),
          ),
        ],
      ),
    );
  }
}
