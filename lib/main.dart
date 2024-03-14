import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:invigilatorpc/business_logic/viewmodels/examscreen_viewmodel.dart';
import 'package:invigilatorpc/providers/timer_provider.dart';
import 'package:invigilatorpc/services/locator/services_locator.dart';
import 'package:invigilatorpc/ui/welcome/welcome_screen.dart';
import 'package:invigilatorpc/utils/constants.dart';
import 'package:invigilatorpc/utils/custom_animation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/exam_provider.dart';
import 'providers/initial_photo_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.teal[400],
      statusBarColor: Colors.teal,
      statusBarIconBrightness: Brightness.light));
  setupServiceLocator();
  await SentryFlutter.init(
    (options) {
      options.dsn =dotenv.env['SENTRY_DSN'];
    },
    appRunner: () => runApp(MyApp()),
  );

  await Hive.initFlutter();
  configLoading();
}

Future<void> configLoading() async {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.tealAccent
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    _init();
    super.initState();
  }

  void _init() async {
    // Add this line to override the default close handler
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => InitialPhotoProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ExamProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => TimerProvider(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ExamScreenViewModel(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Invigilator PC',
          theme: ThemeData(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Neufreit'),
          builder: EasyLoading.init(),
          home: WelcomeScreen(),
        ));
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      await windowManager.destroy();
    }
  }
}
