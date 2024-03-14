import 'package:get_it/get_it.dart';
import 'package:invigilatorpc/business_logic/viewmodels/confirm_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/dashboard_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examscreen_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examupload_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/initial_student_photoviewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/login_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/myprofile_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/pending_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/results_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/signup_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/stamp_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/tutorial_viewmodel.dart';
import 'package:invigilatorpc/business_logic/viewmodels/welcome_viewmodel.dart';
import 'package:invigilatorpc/networking/http_service.dart';
import 'package:invigilatorpc/services/auth/auth_service.dart';

GetIt serviceLocator = GetIt.instance;

setupServiceLocator() {
  serviceLocator.registerLazySingleton(() => HttpService());
  serviceLocator.registerFactory<AuthService>(() => AuthService());
  serviceLocator.registerLazySingleton(() => SignupViewModel());
  serviceLocator.registerFactory<LoginViewModel>(() => LoginViewModel());
  serviceLocator.registerFactory<ConfirmViewModel>(() => ConfirmViewModel());
  serviceLocator.registerFactory<WelcomeViewModel>(() => WelcomeViewModel());
  serviceLocator.registerFactory<TutorialViewModel>(() => TutorialViewModel());
  serviceLocator.registerFactory<InitialStudentPhotoViewModel>(
      () => InitialStudentPhotoViewModel());
  serviceLocator.registerLazySingleton(() => DashboardViewModel());
  serviceLocator.registerFactory<ProfileViewModel>(() => ProfileViewModel());
  serviceLocator.registerFactory<ResultsViewModel>(() => ResultsViewModel());
  serviceLocator
      .registerFactory<ExamScreenViewModel>(() => ExamScreenViewModel());
  serviceLocator.registerLazySingleton(() => StampViewModel());
  serviceLocator
      .registerFactory<ExamUploadViewModel>(() => ExamUploadViewModel());
  serviceLocator.registerFactory<PendingViewModel>(() => PendingViewModel());
}
