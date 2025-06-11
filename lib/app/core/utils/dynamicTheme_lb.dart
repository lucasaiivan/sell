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
  // get static
  static Color colorDark = const Color.fromRGBO(43, 45, 57, 1);
  static Color colorLight = const Color.fromRGBO(247, 245, 242, 1);

  final ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2196F3),
    onPrimary: Color(0xFF2196F3),
    primaryContainer: Color(0xFF2196F3),
    onPrimaryContainer: Color(0xFF00006E),
    secondary: Color(0xFF2196F3),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE0E0FF),
    onSecondaryContainer: Color(0xFF00006E),
    tertiary: Color(0xFF00629F),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD0E4FF),
    onTertiaryContainer: Color(0xFF001D34),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFD0E4FF),
    onSurface: Color(0xFF1B1B1F),
    onSurfaceVariant: Color(0xFF46464F),
    outline: Color(0xFF777680),
    onInverseSurface: Color(0xFFF3EFF4),
    inverseSurface: Color(0xFF303034),
    inversePrimary: Color.fromARGB(255, 135, 196, 245),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFF2196F3),
    outlineVariant: Color(0xFFC7C5D0),
    scrim: Color(0xFF000000),
  );

  final ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF2196F3),
    onPrimary: Color(0xFF2196F3),
    primaryContainer: Color(0xFF2196F3),
    onPrimaryContainer: Color(0xFFE0E0FF),
    secondary: Color(0xFFBEC2FF),
    onSecondary: Color(0xFF2196F3),
    secondaryContainer: Color(0xFF0000EF),
    onSecondaryContainer: Color(0xFFE0E0FF),
    tertiary: Color(0xFF9BCBFF),
    onTertiary: Color(0xFF003356),
    tertiaryContainer: Color(0xFF004A79),
    onTertiaryContainer: Color(0xFFD0E4FF),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    onError: Color(0xFF690005),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF003356),
    onSurface: Color(0xFFE5E1E6),
    onSurfaceVariant: Color(0xFFC7C5D0),
    outline: Color(0xFF91909A),
    onInverseSurface: Color(0xFF1B1B1F),
    inverseSurface: Color(0xFFE5E1E6),
    inversePrimary: Color(0xFF2196F3),
    shadow: Color(0xFF000000),
    surfaceTint: Color(0xFFBEC2FF),
    outlineVariant: Color(0xFF46464F),
    scrim: Color(0xFF000000),
  );

  late ThemeData themeData = ThemeData(
    colorScheme: lightColorScheme,
    dialogTheme: const DialogThemeData(backgroundColor: Color.fromRGBO(249, 242, 237, 1)),
    popupMenuTheme:
        const PopupMenuThemeData(color: Color.fromRGBO(249, 242, 237, 1)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //brightness: Brightness.light, 
    useMaterial3: true,
    scaffoldBackgroundColor: colorLight,
    appBarTheme: AppBarTheme(backgroundColor: colorLight),
    drawerTheme: DrawerThemeData(backgroundColor: colorLight),
    canvasColor: colorLight,
    cardColor: colorLight,
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.03),
        border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.3)))),
  );
  late ThemeData themeDataDark = ThemeData(
    colorScheme: darkColorScheme,
    dialogTheme: const DialogThemeData(
      backgroundColor: Color.fromRGBO(27, 36, 48, 1),
    ),
    popupMenuTheme:
        const PopupMenuThemeData(color: Color.fromRGBO(27, 36, 48, 1)),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //brightness: Brightness.dark,
    useMaterial3: true,
    primarySwatch: Colors.blue, 
    scaffoldBackgroundColor: colorDark,
    
    appBarTheme: AppBarTheme(backgroundColor: colorDark),
    drawerTheme: DrawerThemeData(backgroundColor: colorDark),
    canvasColor: colorDark,
    cardColor: colorDark,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
    ),
  );
  
  static dynamic  light = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color.fromRGBO(43, 45, 57, 1),
  );
  static dynamic  dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color.fromRGBO(247, 245, 242, 1),
  );
}

class ThemeService {
  static final _storage = GetStorage();
  static const _key = 'isDarkMode';

  /// Get isDarkMode info from local storage and return ThemeMode
  ThemeMode get theme => loadisDArkMode() ? ThemeMode.dark : ThemeMode.light;

  /// Load isDArkMode from local storage and if it's empty, returns false (that means default theme is light)
  static bool loadisDArkMode() => _storage.read(_key) ?? false;

  /// Save isDarkMode to local storage
  static saveSsDarkMode(bool isDarkMode) => _storage.write(_key, isDarkMode);

  /// Switch theme and save to local storage
  static get switchTheme { 
    // variable para cambiar el tema
    bool darkMode = !!Get.isDarkMode;
    // guarda variable en el storage
    saveSsDarkMode(!darkMode);
    // GetX : cambia el tema Get.isDarkMode? ThemeData.light(): ThemeData.dark() 
    Get.changeThemeMode(darkMode ? ThemeMode.light : ThemeMode.dark);
    // condition : para Android cambia el color de la barra de estado y navegación del sistema android
    if (Platform.isAndroid) { 
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: !darkMode? ThemesDataApp.light.scaffoldBackgroundColor : ThemesDataApp.dark.scaffoldBackgroundColor,
        statusBarColor: darkMode? ThemesDataApp.light.scaffoldBackgroundColor: ThemesDataApp.dark.scaffoldBackgroundColor,
        statusBarBrightness:darkMode ? Brightness.light : Brightness.dark,
        statusBarIconBrightness:darkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:darkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarDividerColor: !darkMode? ThemesDataApp.light.scaffoldBackgroundColor: ThemesDataApp.dark.scaffoldBackgroundColor,
      ));
    }
    
    
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Get.theme.brightness == Brightness.light
            ? ThemesDataApp.dark.scaffoldBackgroundColor
            : ThemesDataApp.light.scaffoldBackgroundColor,
        statusBarColor: Get.theme.brightness == Brightness.light
            ? ThemesDataApp.dark.scaffoldBackgroundColor
            : ThemesDataApp.light.scaffoldBackgroundColor,
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
                ? ThemesDataApp.dark.scaffoldBackgroundColor
                : ThemesDataApp.light.scaffoldBackgroundColor,
      ));
  }
}

