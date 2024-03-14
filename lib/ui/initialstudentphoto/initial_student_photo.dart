import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/initial_student_photoviewmodel.dart';
import 'package:invigilatorpc/providers/initial_photo_provider.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/utils/app_drawbles.dart';
import 'package:invigilatorpc/utils/commons.dart';

class InitalStudentPhotoScreen extends StatefulWidget {
  @override
  _InitalStudentPhotoScreenState createState() =>
      _InitalStudentPhotoScreenState();
}

class _InitalStudentPhotoScreenState extends State<InitalStudentPhotoScreen>
    with WidgetsBindingObserver {
  InitialStudentPhotoViewModel? initailStudentPhotolViewModel =
      serviceLocator<InitialStudentPhotoViewModel>();
  var scrollBarController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    String storageLocation = (await getApplicationDocumentsDirectory()).path;
    await FastCachedImageConfig.init(
        subDir: storageLocation, clearCacheAfter: const Duration(days: 365));
  }

  @override
  Widget build(BuildContext context) {
    var initialPhotoProvider = Provider.of<InitialPhotoProvider>(context);
    initailStudentPhotolViewModel!.loadingText =
        initialPhotoProvider.loadingText;
    initailStudentPhotolViewModel!.isProcessing =
        initialPhotoProvider.isProcessing;
    initailStudentPhotolViewModel!.isImageLoaded =
        initialPhotoProvider.isImageLoaded;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: ChangeNotifierProvider<InitialStudentPhotoViewModel?>(
            create: (context) => initailStudentPhotolViewModel,
            child: Consumer<InitialStudentPhotoViewModel>(
                builder: (context, model, child) => Background(
                    alignValue: true,
                    child: Scrollbar(
                        thumbVisibility: true,
                        controller: scrollBarController,
                        child: SingleChildScrollView(
                            controller: scrollBarController,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 10),
                                        child: Image.asset(
                                          owl,
                                          height: size.height * 0.10,
                                        ),
                                      ),
                                      Spacer(),
                                      Expanded(
                                        flex: 0,
                                        child: Container(
                                          width: size.width * 0.12,
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: const Text(
                                          "Initial Student Photo",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  model.isImageLoaded || model.isProcessing
                                      ? Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.teal[400],
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        10.0)),
                                            width: 500.0,
                                            height: 400.0,
                                            alignment:
                                                AlignmentDirectional.center,
                                            child: Commons.invigiLoading(
                                                model.loadingText!, false),
                                          ),
                                        )
                                      : Column(children: <Widget>[
                                          Image.asset(initialSelfie),
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Text(
                                                "Add your initial student photo (Selfie) by clicking the camera icon. We will use this to compare\n all other exam photos to.",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Neufreit',
                                                    fontSize: 16),
                                              ),
                                            ),
                                          )
                                        ]),
                                ])))))),
        floatingActionButton: floatingWidget(initailStudentPhotolViewModel!));
  }

  Widget floatingWidget(
      InitialStudentPhotoViewModel initialStudentPhotoViewModel) {
    return initialStudentPhotoViewModel.isImageLoaded ||
            initialStudentPhotoViewModel.isProcessing
        ? Container()
        : FloatingActionButton.extended(
            icon: Icon(Icons.camera_indoor),
            onPressed: () {
              initialStudentPhotoViewModel.showSelfiePhotoDialog(context);
            },
            label: Text("Open Camera"),
            backgroundColor: Colors.teal[900],
          );
  }
}
