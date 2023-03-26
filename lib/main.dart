
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/core/routes/app_pages.dart';
import 'app/presentation/splash/bindings/splash_binding.dart';
import 'app/core/utils/dynamicTheme_lb.dart';

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
FirebaseOptions get firebaseOptions => const FirebaseOptions(
  apiKey: "AIzaSyAMjGXHafddVhr7NzXp7xI7gq602dCgiq8",
  authDomain: "commer-ef151.firebaseapp.com",
  databaseURL: "https://commer-ef151.firebaseio.com",
  projectId: "commer-ef151",
  storageBucket: "commer-ef151.appspot.com",
  messagingSenderId: "232181553323",
  appId: "1:232181553323:web:33d24d2d7b8545c19b3fee",
  measurementId: "G-YBR07J6S2B"
);

Future<void> main() async {
  // Evita errores causados ​​por la actualización de flutter. 
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
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
  ThemeData themeData = ThemeData(
    dialogTheme:const  DialogTheme(backgroundColor: Color.fromRGBO(249, 242, 237, 1)),
    popupMenuTheme: const PopupMenuThemeData(color: Color.fromRGBO(249, 242, 237, 1)), 
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    useMaterial3: true,
    indicatorColor: Colors.blue,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: colorLight,
    appBarTheme: AppBarTheme(backgroundColor: colorLight),
    drawerTheme: DrawerThemeData(backgroundColor: colorLight),
    canvasColor: colorLight,
    cardColor: colorLight,
    dialogBackgroundColor: colorLight,
    inputDecorationTheme: InputDecorationTheme(filled: true,fillColor: Colors.black.withOpacity(0.03),border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black.withOpacity(0.3)))),
  );
  ThemeData themeDataDark = ThemeData(
    dialogTheme:const  DialogTheme(backgroundColor: Color.fromRGBO(27, 36, 48, 1),),
    popupMenuTheme: const PopupMenuThemeData(color: Color.fromRGBO(27, 36, 48, 1)),
    indicatorColor: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.dark,
    useMaterial3: true,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: colorDark,
    appBarTheme: AppBarTheme(backgroundColor: colorDark),
    drawerTheme: DrawerThemeData(backgroundColor: colorDark),
    canvasColor: colorDark,
    cardColor: colorDark,
    dialogBackgroundColor: colorDark,
    inputDecorationTheme: InputDecorationTheme(filled: true,fillColor: Colors.white.withOpacity(0.03),border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),),
    ), 
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