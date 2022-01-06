import 'package:get/get.dart';
import 'package:frontend/app/modules/connected_device/bindings/connected_device_binding.dart';
import 'package:frontend/app/modules/connected_device/views/connected_device_view.dart';

import 'package:frontend/app/modules/home/bindings/home_binding.dart';
import 'package:frontend/app/modules/home/views/home_view.dart';
import 'package:frontend/app/modules/signin/signin.dart';
import 'package:frontend/app/modules/signup/signup.dart';
import 'package:frontend/app/modules/splash_screen/bindings/splash_screen_binding.dart';
import 'package:frontend/app/modules/splash_screen/views/splash_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.CONNECTED_DEVICE,
      page: () => ConnectedDeviceView(),
      binding: ConnectedDeviceBinding(),
    ),
    GetPage(
      name: _Paths.SIGNIN,
      page: () => SignInScreen(),
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignUpScreen(),
    ),
  ];
}
