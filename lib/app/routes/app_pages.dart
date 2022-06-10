
import 'package:get/get.dart';
import 'package:sell/app/modules/auth/bindings/login_binding.dart';
import 'package:sell/app/modules/home/bindings/home_binding.dart';
import 'package:sell/app/modules/home/views/home_view.dart';
import 'package:sell/app/modules/splash/bindings/splash_binding.dart';
import 'package:sell/app/modules/splash/views/splash_view.dart';
import '../modules/auth/views/login_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => AuthView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashInit(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
