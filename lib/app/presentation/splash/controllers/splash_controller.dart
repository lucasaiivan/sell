import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; 
import '../../../core/routes/app_pages.dart';
import '../../../domain/use_cases/authenticate_use_case.dart';

// Controlador para autentificacion del usuario mediante
// proveedores: GoogleSignIn
// manejador de estados: GetX

class SplashController extends GetxController { 

  // var
  String idAccount = '';
  RxBool isSignIn = true.obs; // default values

  // Stream
  late StreamSubscription authStream;


  @override
  void onReady(){  
    // stream : escuchar cambios en el estado de autenticación
    authStream = _listenAuthStateChanges(); 
    super.onReady();
  }
  
  @override
  void onClose() {
    authStream.cancel();
    super.onClose(); 
  }
  
   StreamSubscription _listenAuthStateChanges() {
    return AuthenticateUserUseCase().authStateChanges().listen((User? user) async {
      if (user == null) {
        // Usuario no autenticado

        // default values 
        await GetStorage().write('idAccount', '');
        Get.offAllNamed(Routes.login);
      } else {
        // si esta autentificado
        idAccount = GetStorage().read('idAccount') ?? ''; // Verificamos si tenemos una referencia de una cuenta guardada en GetStorage ( API del controlador de almacenamiento )
        Get.offAllNamed(Routes.home, arguments: {'currentUser': user,'idAccount': idAccount} );
      }
    });
  }
 
}
