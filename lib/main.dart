import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/modules/splash/bindings/splash_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/dynamicTheme_lb.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  SplashBinding().dependencies();
  bool isDark = (GetStorage().read('isDarkMode') ?? false);
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          isDark ? ThemesDataApp.colorBlack : ThemesDataApp.colorLight,
      statusBarColor:
          isDark ? ThemesDataApp.colorBlack : ThemesDataApp.colorLight,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor:
          isDark ? ThemesDataApp.colorBlack : ThemesDataApp.colorLight,
    ));
  }

  // theme
  Color colorDark = const Color.fromARGB(255, 43, 45, 57);
  Color colorLight = const Color.fromRGBO(247, 245, 242, 1);
  ThemeData themeData = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    useMaterial3: true,
    primarySwatch: Colors.blue,
    backgroundColor: Colors.amber,
    scaffoldBackgroundColor: colorLight,
    appBarTheme: AppBarTheme(backgroundColor: colorLight),
    drawerTheme: DrawerThemeData(backgroundColor: colorLight),
    canvasColor: colorLight,
    cardColor: colorLight,
    dialogBackgroundColor: colorLight,
  );
  ThemeData themeDataDark = ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    useMaterial3: true,
    primarySwatch: Colors.blue,
    backgroundColor: Colors.amber,
    scaffoldBackgroundColor: colorDark,
    appBarTheme: AppBarTheme(backgroundColor: colorDark),
    drawerTheme: DrawerThemeData(backgroundColor: colorDark),
    canvasColor: colorDark,
    cardColor: colorDark,
    dialogBackgroundColor: colorDark,
  );

  runApp(GetMaterialApp(
    title: "Punto de Venta",
    initialRoute: AppPages.INITIAL,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    theme: themeData,
    darkTheme: themeDataDark,
  ));
}
