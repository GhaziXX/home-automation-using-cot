import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/configs/images.dart';

import '../../../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const double _splashIconSize = 50;

  @override
  void initState() {
    scheduleMicrotask(() async {
      await AppImages.precacheAssets(context);
      await Future.delayed(const Duration(milliseconds: 400));
      await AppNavigator.replaceWith(Routes.signin);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const Image(
              image: AppImages.loader,
              width: _splashIconSize,
              height: _splashIconSize,
              fit: BoxFit.contain,
            ),
            const Text(
              'Home Automation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}
