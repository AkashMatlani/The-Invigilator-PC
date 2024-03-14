import 'package:hive/hive.dart';

class HivePreferences {
  static const _preferencesBox = '_preferencesBox';
  static const _currentExamKey = '_currentExam';
  static const _examItemPhotosKey = '_examItemPhotos';
  static const _examItemPhotosLowKey = '_examItemPhotosLow';
  static const _examRecordingsKey = '_examRecordings';
  static const _examVideosKey = '_examVideos';
  static const _examScreenCapturePhotosKey = '_examScreenCapturePhotos';
  static const _examSelfiesKey = '_examSelfies';
  static const _examSelfiesLowKey = '_examSelfiesLow';
  static const _examAuthCodeKey = '_examAuthCode';
  static const _examIdKey = '_examId';
  static const _secondsOutOfAppKey = '_secondsOutOfApp';
  static const _minutesInAppKey = '_minutesInApp';
  static const _totalExamLength = '_totalExamLength';
  static const _minsLeftOnFinished = '_minsLeftOnFinished';
  static const _uniqueDecibelsFoundKey = '_uniqueDecibelsFound';
  static const _examResultIdKey = '_examResultId';
  static const _currentDocumentsKey = '_currentDocuments';
  static const _userName = '_userName';
  static const _userId = '_userId';
  static const _localResults = '_localResults';
  static const _userEmail = '_userEmail';
  static const _userMobile = '_userMobile';
  static const _profileSetup = '_profileSetup';
  static const _confirmAccount = '_confirmAccount';
  static const _calibratedDevice = '_calibratedDevice';
  static const _acceptedTerms = '_acceptedTerms';
  static const _latitude = '_latitude';
  static const _longitude = '_longitude';
  static const _studentNum = '_studentNum';
  static const _startLatitude = '_startLatitude';
  static const _startLongitude = '_startLongitude';
  static const _inVenue = '_inVenue';
  static const _isLowMemory = '_isLowMemory';
  static const _isGoogleSignIn = '_isGoogleSignIn';
  static const _startPassword = '_startPassword';
  static const _starterChosen = '_starterChosen';
  static const _finishedExamAt = '_finishedExamAt';
  static const _timeOutAudit = '_timeOutAudit';
  static const _examFiles = '_examFiles';
  static const _localDocuments = '_localDocuments';
  static const _reploadIndex = '_reploadIndex';
  static const _finishedExam = '_finishedExam';
  static const _profileUrl = '_profileUrl';
  static const _closedAppAt = '_closedAppAt';

  final Box<dynamic> _box;

  HivePreferences._(this._box);

  static Future<HivePreferences> getInstance() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    return HivePreferences._(box);
  }

  static void deleteAllPreferences() async {
    final box = await Hive.openBox<dynamic>(_preferencesBox);
    for (dynamic key in box.keys) {
      if (key != _localResults) {
        box.delete(key);
      }
    }
  }

  bool? getIsGoogleSignIn() => _getValue(_isGoogleSignIn);

  Future<void> setIsGoogleSignIn(bool? isGoogleSignIn) =>
      _setValue(_isGoogleSignIn, isGoogleSignIn);

  bool? getInVenue() => _getValue(_inVenue);

  Future<void> setInVenue(bool? inVenue) => _setValue(_inVenue, inVenue);

  bool? getExamFinished() => _getValue(_finishedExam);

  Future<void> setExamFinished(bool? finishedExam) =>
      _setValue(_finishedExam, finishedExam);

  String? getProfileUrl() => _getValue(_profileUrl);

  Future<void> setProfileUrl(String? profileUrl) =>
      _setValue(_profileUrl, profileUrl);

  String? getStartPassword() => _getValue(_startPassword);

  Future<void> setStartPassword(String? startPassword) =>
      _setValue(_startPassword, startPassword);

  int? getStarterChosen() => _getValue(_starterChosen);

  Future<void> setStarterChosen(int? starterChosen) =>
      _setValue(_starterChosen, starterChosen);

  bool? getIsLowMemory() => _getValue(_isLowMemory);

  Future<void> setIsLowMemory(bool isLowMemory) =>
      _setValue(_isLowMemory, isLowMemory);

  int? getIndexOfReupload() => _getValue(_reploadIndex);

  Future<void> setIndexOfReupload(int? reploadIndex) =>
      _setValue(_reploadIndex, reploadIndex);

  List<dynamic>? getCurrentExam() => _getValue(_currentExamKey);

  Future<void> setCurrentExam(List<dynamic>? currentExam) =>
      _setValue(_currentExamKey, currentExam);

  List<dynamic>? getItemPhotos() => _getValue(_examItemPhotosKey);

  Future<void> setItemPhotos(List<dynamic>? itemPhotos) =>
      _setValue(_examItemPhotosKey, itemPhotos);

  List<dynamic>? getItemPhotosLow() => _getValue(_examItemPhotosLowKey);

  Future<void> setItemPhotosLow(List<dynamic>? itemPhotosLow) =>
      _setValue(_examItemPhotosLowKey, itemPhotosLow);

  List<dynamic>? getExamRecordings() => _getValue(_examRecordingsKey);

  Future<void> setExamRecordings(List<dynamic>? examRecordings) =>
      _setValue(_examRecordingsKey, examRecordings);

  List<dynamic>? getExamVideos() => _getValue(_examVideosKey);

  Future<void> setExamVideos(List<dynamic>? examRecordings) =>
      _setValue(_examVideosKey, examRecordings);

  Future<void> setExamScreenCapturingPhotos(
          List<dynamic>? examScreenCapturingPhotos) =>
      _setValue(_examScreenCapturePhotosKey, examScreenCapturingPhotos);

  List<dynamic>? getExamScreenCapturingPhotos() =>
      _getValue(_examScreenCapturePhotosKey);

  List<dynamic>? getExamSelfies() => _getValue(_examSelfiesKey);

  Future<void> setExamSelfies(List<String?>? examSelfies) =>
      _setValue(_examSelfiesKey, examSelfies);

  List<dynamic>? getExamSelfiesLow() => _getValue(_examSelfiesLowKey);

  Future<void> setExamSelfiesLow(List<dynamic>? examSelfiesLow) =>
      _setValue(_examSelfiesLowKey, examSelfiesLow);

  List<dynamic>? getExamAuthCode() => _getValue(_examAuthCodeKey);

  Future<void> setExamAuthCode(List<dynamic>? examAuthCode) =>
      _setValue(_examAuthCodeKey, examAuthCode);

  int? getExamId() => _getValue(_examIdKey);

  Future<void> setExamId(int? examId) => _setValue(_examIdKey, examId);

  List<String>? getSecondOutOfApp() => _getValue(_secondsOutOfAppKey);

  Future<void> setSecondOutOfApp(List<String?>? secondsOutOfApp) =>
      _setValue(_secondsOutOfAppKey, secondsOutOfApp);

  int? getUniqueDecibelsFound() => _getValue(_uniqueDecibelsFoundKey);

  Future<void> setUniqueDecibelsFound(int? uniqueDecibelsFound) =>
      _setValue(_secondsOutOfAppKey, uniqueDecibelsFound);

  int? getMinutesInApp() => _getValue(_minutesInAppKey);

  Future<void> setMinutesInApp(int? minutesInApp) =>
      _setValue(_minutesInAppKey, minutesInApp);

  int? getExamLength() => _getValue(_totalExamLength);

  Future<void> setExamLength(int? totalExamLength) =>
      _setValue(_totalExamLength, totalExamLength);

  int? getMinutesLeft() => _getValue(_minsLeftOnFinished);

  Future<void> setMinutesLeft(int? minutesLeft) =>
      _setValue(_minsLeftOnFinished, minutesLeft);

  int? getExamResultId() => _getValue(_examResultIdKey);

  Future<void> setExamResultId(int? examResultId) =>
      _setValue(_examResultIdKey, examResultId);

  List<String>? getCurrentDocuments() => _getValue(_currentDocumentsKey);

  Future<void> setCurrentDocuments(List<String?>? currentDocuments) =>
      _setValue(_currentDocumentsKey, currentDocuments);

  List<dynamic>? getLocalDocuments() => _getValue(_localDocuments);

  Future<void> setLocalDocuments(List<dynamic>? localDocuments) =>
      _setValue(_localDocuments, localDocuments);

  String? getUserName() => _getValue(_userName);

  Future<void> setUserName(String? userName) => _setValue(_userName, userName);

  String? getStudentNum() => _getValue(_studentNum);

  Future<void> setStudentNum(String? studentNum) =>
      _setValue(_studentNum, studentNum);

  int? getUserId() => _getValue(_userId);

  Future<void> setUserId(int? userId) => _setValue(_userId, userId);

  List<String>? getLocalResults() => _getValue(_localResults);

  Future<void> setLocalResults(List<String?>? localResults) =>
      _setValue(_localResults, localResults);

  List<String>? getLocalExamFiles() => _getValue(_examFiles);

  Future<void> setLocalExamFiles(List<String?>? examFiles) =>
      _setValue(_examFiles, examFiles);

  String? getUserEmail() => _getValue(_userEmail);

  Future<void> setUserEmail(String? userEmail) =>
      _setValue(_userEmail, userEmail);

  String? getUserMobile() => _getValue(_userMobile);

  Future<void> setUserMobile(String? userMobile) =>
      _setValue(_userMobile, userMobile);

  bool? getIsProfileSetup() => _getValue(_profileSetup);

  Future<void> setIsProfileSetup(bool? isProfileSetup) =>
      _setValue(_profileSetup, isProfileSetup);

  DateTime? getFinishedExamAt() => _getValue(_finishedExamAt);

  Future<void> setFinishedExamAt(DateTime? finishedExamAt) =>
      _setValue(_finishedExamAt, finishedExamAt);

  bool? getIsAccountConfirmed() => _getValue(_confirmAccount);

  Future<void> setIsAccountConfirmed(bool? isAccountConfirmed) =>
      _setValue(_confirmAccount, isAccountConfirmed);

  bool? getIsServiceCalibrated() => _getValue(_calibratedDevice);

  Future<void> setIsServiceCalibrated(bool? isServiceCalibrated) =>
      _setValue(_calibratedDevice, isServiceCalibrated);

  bool? getHasAcceptedTerms() => _getValue(_acceptedTerms);

  Future<void> setHasAcceptedTerms(bool? hasAcceptedTerms) =>
      _setValue(_acceptedTerms, hasAcceptedTerms);

  double? getLatitude() => _getValue(_latitude);

  double? getLongitude() => _getValue(_longitude);

  Future<void> setLatitude(double latitude) => _setValue(_latitude, latitude);

  Future<void> setLongitude(double longitude) =>
      _setValue(_longitude, longitude);

  double? getStartLatitude() => _getValue(_startLatitude);

  double? getStartLongitude() => _getValue(_startLongitude);

  Future<void> setStartLatitude(double latitude) =>
      _setValue(_startLatitude, latitude);

  Future<void> setStartLongitude(double longitude) =>
      _setValue(_startLongitude, longitude);

  String? getTimeOutAudit() => _getValue(_timeOutAudit);

  DateTime? getClosedAppAt() => _getValue(_closedAppAt);
  Future<void> setClosedAppAt(DateTime? closedAppAt) =>
      _setValue(_closedAppAt, closedAppAt);

  Future<void> setTimeOutAudit(String? timeOutAudit) =>
      _setValue(_timeOutAudit, timeOutAudit);

  _getValue<T>(key, {defaultValue}) =>
      _box.get(key, defaultValue: defaultValue);

  Future<void> _setValue<T>(key, value) => _box.put(key, value);
}
