import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/pending_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/utils/constants.dart';

//ignore: must_be_immutable
class PendingScreen extends StatefulWidget {
   String? userName;

  PendingScreen([this.userName]);

  @override
  _PendingScreenState createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  PendingViewModel? modelResults = serviceLocator<PendingViewModel>();

  @override
  void initState() {
    super.initState();
    modelResults!.getData(context);
    closeKeyboard();
  }

  void closeKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PendingViewModel?>(
        create: (context) => modelResults,
        child: Consumer<PendingViewModel>(
            builder: (context, model, child) => Scaffold(
                  body: Background(
                      child: ListView.builder(
                    itemCount: model.convertedData == null
                        ? 0
                        : model.convertedData!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          child: Material(
                              elevation: 4.0,
                              color: index % 2 == 0
                                  ? Color.fromRGBO(102, 195, 181, 1)
                                  : Color.fromRGBO(82, 156, 145, 1),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 0, left: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.convertedData![index].values
                                                  .first['title'],
                                              style: TextStyle(
                                                  height: 1.5,
                                                  color: Colors.white,
                                                  fontSize: 15.0,
                                                  fontFamily: 'Neufreit'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        kPrimaryColor),
                                                padding: MaterialStateProperty
                                                    .all<EdgeInsets>(
                                                        EdgeInsets.symmetric(
                                                            vertical: 5,
                                                            horizontal: 12)),
                                              ),
                                              onPressed: () {
                                                model.uploadFiles(
                                                    index,
                                                    context,
                                                    model.convertedData![index]
                                                        .values.first['title'],
                                                    true);
                                              },
                                              child: Text(
                                                "Upload Files",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    fontFamily: 'Neufreit'),
                                              ),
                                            )),
                                      ),
                                      SizedBox(height: 40),
                                    ],
                                  ))));
                    },
                  )),
                )));
  }
}
