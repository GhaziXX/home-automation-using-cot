import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/routes.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'configs/colors.dart';
import 'configs/constants.dart';
import 'configs/fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      color: Colors.white,
      title: 'Home Automation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: AppFonts.circularStd,
        textTheme: theme.textTheme.apply(
          fontFamily: AppFonts.circularStd,
          displayColor: AppColors.black,
        ),
        scaffoldBackgroundColor: AppColors.lightGrey,
        primarySwatch: Colors.blue,
      ),
      navigatorKey: AppNavigator.navigatorKey,
      onGenerateRoute: AppNavigator.onGenerateRoute,
      builder: (context, child) {
        final data = MediaQuery.of(context);
        final smallestSize = min(data.size.width, data.size.height);
        final textScaleFactor =
            min(smallestSize / AppConstants.designScreenSize.width, 1.0);

        return MediaQuery(
          data: data.copyWith(
            textScaleFactor: textScaleFactor,
          ),
          child: child,
        );
      },
    );
  }
}
