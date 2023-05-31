part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const EDITPRODUCT = _Paths.EDITPRODUCT;
  static const SEACH_PRODUCT = _Paths.SEACH_PRODUCT;
  static const ACCOUNT = _Paths.ACCOUNT;
  static const MULTIUSER = _Paths.MULTIUSER;
  static const HISTORY_CASH_TERHGISTER = _Paths.HISTORY_CASH_TERHGISTER;
}

abstract class _Paths {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const EDITPRODUCT = '/editProduct';
  static const SEACH_PRODUCT = '/seachProduct';
  static const ACCOUNT = '/account';
  static const MULTIUSER = '/multiuser';
  static const HISTORY_CASH_TERHGISTER = '/historyCashRegister';
}
