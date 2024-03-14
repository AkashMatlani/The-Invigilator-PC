import 'package:flutter/material.dart';
import 'package:invigilatorpc/networking/http_service.dart';
import 'package:invigilatorpc/utils/commons.dart';
import 'dart:convert';

import 'package:invigilatorpc/utils/hive_preferences.dart';

class ResultsViewModel extends ChangeNotifier {
  List? data;
  bool gettingResults = true;
  String loadingText = "Getting Assessment Results..";

  Future<List?> appendLocalData(List resData) async {
    try {
      final preferences = await HivePreferences.getInstance();
      List<String> localResults = preferences.getLocalResults() ?? [];
      List newResults = [];

      for (var i = 0; i < localResults.length; i++) {
        var resultString = localResults[i];
        Map valueMap = json.decode(resultString);
        String? exam = valueMap['exam_id'].toString();
        int userId = preferences.getUserId() ?? 0;
        int? recordUser = valueMap['user_id'];
        bool alreadyInSet = false;
        bool belongsToUser = (userId == recordUser);

        for (var i = 0; i < resData.length; i++) {
          if (exam == resData[i]["exam_id"]) {
            alreadyInSet = true;
          }
        }
        if (alreadyInSet == false && belongsToUser) {
          newResults.add(valueMap);
        }
      }
      newResults.addAll(resData);
      return newResults;
    } catch (error) {
      return data;
    }
  }

  Future getData(BuildContext context) async {
    gettingResults = true;
    loadingText = "Getting Assessment Results..";
    notifyListeners();
    HttpService serv = HttpService();
    data = await serv.getPreviousResultsForUser();

    if (data![0] == 'false') {
      Commons.invigiFlushBarError(context, data![1]);
    } else {
      data = await appendLocalData(data![1]);
      gettingResults = false;
      data = data;
      notifyListeners();
    }
  }
}
