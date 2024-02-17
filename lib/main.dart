
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'app/core/routes/app_pages.dart';
import 'app/core/utils/dynamicTheme_lb.dart';
import 'app/data/datasource/constant.dart';
import 'app/presentation/splash/bindings/splash_binding.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:purchases_flutter/purchases_flutter.dart'; 


Future<void> main() async {
  // Evita errores causados por la actualización de flutter.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  if (kIsWeb) {
    // web
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    // disposition android
    await Firebase.initializeApp();

    // RevenueCat : subcripcion 
    await Purchases.setLogLevel(LogLevel.debug); // debug : para ver los errores en la consola
    PurchasesConfiguration configuration = PurchasesConfiguration(googleApiKey)..observerMode = false;
    await Purchases.configure(configuration); // configuramos la compra
  }
  // GetStorage : local storage
  await GetStorage.init(); 
  SplashBinding().dependencies(); 

  // var : theme
  bool isDark = ThemeService.loadisDArkMode();  

  // style : setSystemUIOverlayStyle
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: isDark ? ThemesDataApp.colorDark : ThemesDataApp.colorLight,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: isDark ? ThemesDataApp.colorDark : ThemesDataApp.colorLight,
    systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  ));

  initializeDateFormatting('es', null).then((_){
    runApp(GetMaterialApp(
      title: "Punto de Venta",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemesDataApp().themeData,
      darkTheme: ThemesDataApp().themeDataDark,
      )
    );
  });
  
}
