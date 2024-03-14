import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/results_viewmodel.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/widgets/background.dart';
import 'package:invigilatorpc/utils/commons.dart';

class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  ResultsViewModel? modelResults = serviceLocator<ResultsViewModel>();

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
    return ChangeNotifierProvider<ResultsViewModel?>(
        create: (context) => modelResults,
        child: Consumer<ResultsViewModel>(
            builder: (context, model, child) => Scaffold(
                  body: Background(
                      child: model.gettingResults
                          ? Center(
                              child: Commons.invigiLoading(
                                  model.loadingText, false))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                model.data != null && model.data!.length > 0
                                    ? Container(
                                        color: Color.fromRGBO(82, 156, 145, 1),
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text("Exam Module",
                                                  style: TextStyle(
                                                      height: 1.5,
                                                      color: Colors.white,
                                                      fontSize: 16.0,
                                                      fontFamily: 'Neufreit')),
                                            ),
                                            Spacer(),
                                            Text("Reference",
                                                style: TextStyle(
                                                    height: 1.5,
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                    fontFamily: 'Neufreit')),
                                            Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Text("Upload Time",
                                                  style: TextStyle(
                                                      height: 1.5,
                                                      color: Colors.white,
                                                      fontSize: 16.0,
                                                      fontFamily: 'Neufreit')),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: model.data == null
                                        ? 0
                                        : model.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                          child: Material(
                                              elevation: 4.0,
                                              color: index % 2 == 0
                                                  ? Color.fromRGBO(
                                                      102, 195, 181, 1)
                                                  : Color.fromRGBO(
                                                      82, 156, 145, 1),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0, left: 10),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${model.data![index]["exam"]}",
                                                              style: TextStyle(
                                                                  height: 1.5,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontFamily:
                                                                      'Neufreit'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '${model.data![index]["reference"]}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontFamily:
                                                                      'Neufreit'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          10.0),
                                                              child: Text(
                                                                  model.data![
                                                                          index]
                                                                      [
                                                                      "created"],
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14.0,
                                                                      fontFamily:
                                                                          'Neufreit')),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 40),
                                                    ],
                                                  ))));
                                    },
                                  ),
                                ),
                              ],
                            )),
                )));
  }
}
