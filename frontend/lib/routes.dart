import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/home/home.dart';
import 'package:frontend/ui/screens/signin/signin.dart';
import 'package:frontend/ui/screens/signup/signup.dart';
import 'package:frontend/ui/screens/splash/splash.dart';

import 'core/fade_page_route.dart';

enum Routes { splash, home, signin, signup, room }

class _Paths {
  static const String splash = '/';
  static const String home = '/home';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String room = '/home/room';

  static const Map<Routes, String> _pathMap = {
    Routes.splash: _Paths.splash,
    Routes.home: _Paths.home,
    Routes.signin: _Paths.signin,
    Routes.signup: _Paths.signup,
    Routes.room: _Paths.room,
  };

  static String of(Routes route) => _pathMap[route];
}

class AppNavigator {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case _Paths.splash:
        return FadeRoute(page: const SplashScreen());

      case _Paths.home:
        return FadeRoute(page: const HomeScreen());

      case _Paths.signin:
        return FadeRoute(page: const SignInScreen());

      case _Paths.signup:
        return FadeRoute(page: const SignUpScreen());

      default:
        return FadeRoute(page: const SplashScreen());
    }
  }

  static Future push<T>(Routes route, [T arguments]) =>
      state.pushNamed(_Paths.of(route), arguments: arguments);

  static Future replaceWith<T>(Routes route, [T arguments]) =>
      state.pushReplacementNamed(_Paths.of(route), arguments: arguments);

  static void pop() => state.pop();

  static NavigatorState get state => navigatorKey.currentState;
}
