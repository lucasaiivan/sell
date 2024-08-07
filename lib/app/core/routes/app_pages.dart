
import 'package:get/get.dart';
import 'package:sell/app/presentation/auth/bindings/login_binding.dart'; 
import 'package:sell/app/presentation/home/bindings/home_binding.dart';
import 'package:sell/app/presentation/home/views/home_view.dart';
import 'package:sell/app/presentation/moderator/view/moderator_view.dart';
import 'package:sell/app/presentation/splash/bindings/splash_binding.dart';
import 'package:sell/app/presentation/splash/views/splash_view.dart';

import '../../presentation/account/bindings/account_binding.dart';
import '../../presentation/account/views/account_view.dart';
import '../../presentation/auth/views/login_view.dart';
import '../../presentation/cataloguePage/bindings/catalogue_binding.dart';
import '../../presentation/cataloguePage/views/create_product_form_view.dart';
import '../../presentation/cataloguePage/views/product_edit_view.dart';
import '../../presentation/cataloguePage/views/product_view.dart';
import '../../presentation/cataloguePage/views/productsSearch_view.dart';
import '../../presentation/moderator/bindings/moderator_binding.dart';
import '../../presentation/multiuser/bindings/multiuser_binding.dart';
import '../../presentation/multiuser/views/multiuser_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.account,
      page: () => AccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => AuthView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.splash,
      page: () => const SplashInit(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeView(),
      binding: HomeBinding(),
    ), 
    GetPage(
      name: Routes.editProduct,
      page: () => ProductEdit(),
      binding: ProductsEditBinding(),
    ),
    GetPage(
      name: Routes.createProductForm,
      page: () => ProductNewFormView(),
      binding: ProductsFormCreateBinding(),
    ),
    GetPage(
      name: Routes.searchProduct,
      page: () => ProductsSearch(),
      binding: ProductsSarchBinding(),
    ),
    GetPage(
      name: Routes.multiuser,
      page: () => MultiUser(),
      binding: MultiUserBinding(),
    ), 
    GetPage(
      name: Routes.product,
      page: () => const ProductView(),
      binding: ProductControllerBinding(),
    ),
    GetPage(
      name: Routes.moderator,
      page: () => ModeratorView(),
      binding: ModeratorBinding(),
    ),
  ];
}
