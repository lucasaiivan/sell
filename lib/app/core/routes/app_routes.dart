part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const splash = _Paths.splash;
  static const login = _Paths.login;
  static const home = _Paths.home;
  static const editProduct = _Paths.editProduc;
  static const createProductForm = _Paths.createProductForm;
  static const searchProduct = _Paths.searchProduct;
  static const account = _Paths.account;
  static const multiuser = _Paths.multiuser;
  static const historyCashTerhgister = _Paths.historyCashTerhgister;
  static const product = _Paths.product;
}

abstract class _Paths {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const createProductForm = '/createProductForm';
  static const editProduc = '/editProduct';
  static const searchProduct = '/seachProduct';
  static const account = '/account';
  static const multiuser = '/multiuser';
  static const historyCashTerhgister = '/historyCashRegister';
  static const product = '/product';
}
