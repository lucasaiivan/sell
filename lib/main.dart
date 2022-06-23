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
  // Evita errores causados ​​por la actualización de flutter. 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  SplashBinding().dependencies(); 
  
  // theme
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
  Color colorDark = const Color.fromRGBO(43, 45, 57, 1);
  Color colorLight = const Color.fromRGBO(247, 245, 242, 1);
  ThemeData themeData = ThemeData
  (
    popupMenuTheme: const PopupMenuThemeData(color: Color.fromRGBO(249, 242, 237, 1)), 
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    useMaterial3: true,
    indicatorColor: Colors.blue,
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
    popupMenuTheme: const PopupMenuThemeData(color: Color.fromRGBO(27, 36, 48, 1)),
    indicatorColor: Colors.blue,
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
