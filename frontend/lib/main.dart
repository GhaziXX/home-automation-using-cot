import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:frontend/app/theme/color_theme.dart';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/data/provider/api_services.dart';
import 'app/oauth/oauth_lib.dart';
import 'app/routes/app_pages.dart';

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
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: GFTheme.bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: GFTheme.secondaryColor,
      ),
      title: "Home Automation",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
