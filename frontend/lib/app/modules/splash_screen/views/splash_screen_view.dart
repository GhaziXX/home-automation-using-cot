import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:frontend/app/theme/text_theme.dart';
import 'package:lottie/lottie.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GetBuilder<SplashScreenController>(builder: (_) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/light-bulb.json',
                controller: _.animationController,
                frameRate: FrameRate(60),
                repeat: true,
                width: Get.width * 0.40,
                onLoaded: (composition) {
                  _.animationController..duration = composition.duration;
                },
              ),
              SizedBox(
                height: 50.0,
              ),
              Text(
                'Home Automation',
                style: HomeFiTextTheme.kHeadTextStyle.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
