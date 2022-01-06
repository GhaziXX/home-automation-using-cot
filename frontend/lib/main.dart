import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import 'app/data/provider/api_services.dart';
import 'app/oauth/oauth_lib.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton<OAuthSettings>(OAuthSettings());
  GetIt.I.registerSingleton<APIServices>(APIServices());
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: appThemeData[AppTheme.MaroonLight],
      title: "Home Automation",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
