/* Este paquete gestiona el cambio de su tema durante el tiempo de ejecución y su persistencia. */

/* FUNCIONES */
/* 1 * Cambia el brillo del tema actual (oscuro/luz) */

/* Paquetes internos */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/* Paquetes externos */
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
export 'package:animate_do/animate_do.dart';

class ThemesDataApp {

  static Color colorBlack = const Color.fromARGB(255, 43, 45, 57);
  static Color colorLight = const Color.fromARGB(255, 238, 238, 238);
  
  static late dynamic  light = ThemeData.light().copyWith(
    scaffoldBackgroundColor: colorLight,
  );
  static late dynamic  dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: colorBlack,
  );
}

class ThemeService {
  static final _storage = GetStorage();
  static final _key = 'isDarkMode';

  /// Get isDarkMode info from local storage and return ThemeMode
  ThemeMode get theme => loadisDArkMode() ? ThemeMode.dark : ThemeMode.light;

  /// Load isDArkMode from local storage and if it's empty, returns false (that means default theme is light)
  static bool loadisDArkMode() => _storage.read(_key) ?? false;

  /// Save isDarkMode to local storage
  static saveSsDarkMode(bool isDarkMode) => _storage.write(_key, isDarkMode);

  /// Switch theme and save to local storage
  static void switchTheme() {
    if (Platform.isAndroid) {
      
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: loadisDArkMode()
            ? ThemesDataApp.light.scaffoldBackgroundColor
            : ThemesDataApp.dark.scaffoldBackgroundColor,
        statusBarColor: loadisDArkMode()
            ? ThemesDataApp.light.scaffoldBackgroundColor
            : ThemesDataApp.dark.scaffoldBackgroundColor,
        statusBarBrightness:
            loadisDArkMode() ? Brightness.light : Brightness.dark,
        statusBarIconBrightness:
            loadisDArkMode() ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            loadisDArkMode() ? Brightness.dark : Brightness.light,
        systemNavigationBarDividerColor: loadisDArkMode()
            ? ThemesDataApp.light.scaffoldBackgroundColor
            : ThemesDataApp.dark.scaffoldBackgroundColor,
      ));
    }
    Get.changeThemeMode(loadisDArkMode() ? ThemeMode.light : ThemeMode.dark);
    saveSsDarkMode(!loadisDArkMode());
  }
  static void switchThemeColor({required Color color}) {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: color,
        statusBarColor: color,
        statusBarBrightness: Get.theme.brightness,
        statusBarIconBrightness: Get.theme.brightness,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: color,
      ));
    }
  }
  static void switchThemeDefault() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Get.theme.brightness == Brightness.light
            ? ThemesDataApp.light.scaffoldBackgroundColor
            : ThemesDataApp.dark.scaffoldBackgroundColor,
        statusBarColor: Get.theme.brightness == Brightness.light
            ? ThemesDataApp.light.scaffoldBackgroundColor
            : ThemesDataApp.dark.scaffoldBackgroundColor,
        statusBarBrightness: Get.theme.brightness == Brightness.light
            ? Brightness.light
            : Brightness.dark,
        statusBarIconBrightness: Get.theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarIconBrightness:
            Get.theme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
        systemNavigationBarDividerColor:
            Get.theme.brightness == Brightness.light
                ? ThemesDataApp.light.scaffoldBackgroundColor
                : ThemesDataApp.dark.scaffoldBackgroundColor,
      ));
    }
  }
}

