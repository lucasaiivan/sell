
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/core/routes/app_pages.dart';
import 'app/presentation/splash/bindings/splash_binding.dart';
import 'package:firebase_core/firebase_core.dart';


// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const FirebaseOptions firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyAMjGXHafddVhr7NzXp7xI7gq602dCgiq8",
    authDomain: "commer-ef151.firebaseapp.com",
    databaseURL: "https://commer-ef151.firebaseio.com",
    projectId: "commer-ef151",
    storageBucket: "commer-ef151.appspot.com",
    messagingSenderId: "232181553323",
    appId: "1:232181553323:web:e20bbcc40716001c9b3fee",
    measurementId: "G-8X75V0XVWS"
);

Future<void> main() async {
  // Evita errores causados ​​por la actualización de flutter. 
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  if(kIsWeb){
    await Firebase.initializeApp(options: firebaseConfig );
  }else{
    await Firebase.initializeApp();
  }  

  await GetStorage.init();
  SplashBinding().dependencies(); //
  
  // theme
   bool isDark = false;//(GetStorage().read('isDarkMode') ?? false);
  
  // if (Platform.isAndroid) {
  //
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     systemNavigationBarColor:
  //         isDark ? ThemesDataApp.colorBlack : ThemesDataApp.colorLight,
  //     statusBarColor:
  //         isDark ? ThemesDataApp.colorBlack : ThemesDataApp.colorLight,
  //     statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
  //     statusBarIconBrightness: isDark ? Brightness.dark : Brightness.light,
  //     systemNavigationBarIconBrightness:
  //         isDark ? Brightness.light : Brightness.dark,
  //     systemNavigationBarDividerColor:
  //         isDark ? ThemesDataApp.colorBlack : ThemesDataApp.colorLight,
  //   ));
  // }
  Color colorPrimary = const Color.fromARGB(255, 33, 150, 243); // 0xFF2196F3
  // theme
  Color colorDark = const Color.fromRGBO(43, 45, 57, 1);
  Color colorLight = const Color.fromRGBO(247, 245, 242, 1);

  ColorScheme lightColorScheme = const ColorScheme(
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
    background: Color(0xFFFFFBFF),
    onBackground: Color(0xFF1B1B1F),
    surface: Color(0xFFD0E4FF),
    onSurface: Color(0xFF1B1B1F),
    surfaceVariant: Color(0xFFE4E1EC),
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


ColorScheme darkColorScheme = const ColorScheme(
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
  background: Color(0xFF1B1B1F),
  onBackground: Color(0xFFE5E1E6),
  surface: Color(0xFF003356),
  onSurface: Color(0xFFE5E1E6),
  surfaceVariant: Color(0xFF46464F),
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


  ThemeData themeData = ThemeData(
  
    colorScheme: lightColorScheme,
    dialogTheme:const  DialogTheme(backgroundColor: Color.fromRGBO(249, 242, 237, 1)),
    popupMenuTheme: const PopupMenuThemeData(color: Color.fromRGBO(249, 242, 237, 1)), 
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //brightness: Brightness.light,
    useMaterial3: true, 
    scaffoldBackgroundColor: colorLight,
    appBarTheme: AppBarTheme(backgroundColor: colorLight),
    drawerTheme: DrawerThemeData(backgroundColor: colorLight),
    canvasColor: colorLight,
    cardColor: colorLight,
    dialogBackgroundColor: colorLight,
    inputDecorationTheme: InputDecorationTheme(filled: true,fillColor: Colors.black.withOpacity(0.03),border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black.withOpacity(0.3)))),
  );
  ThemeData themeDataDark = ThemeData(
    colorScheme: darkColorScheme, 
    dialogTheme:const  DialogTheme(backgroundColor: Color.fromRGBO(27, 36, 48, 1),),
    popupMenuTheme: const PopupMenuThemeData(color: Color.fromRGBO(27, 36, 48, 1)),
    indicatorColor: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //brightness: Brightness.dark,
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
  // runApp( MaterialApp(home: Scaffold(
  //   appBar: AppBar(title: Text('web')),
  // ),));
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
 