import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sell/app/routes/app_pages.dart';

// Controlador para autentificacion del usuario mediante
// proveedores: GoogleSignIn
// manejador de estados: GetX

class SplashController extends GetxController {

  // FirebaseAuth and GoogleSignIn instances
  late final GoogleSignIn googleSign = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  
  // var
  String idAccount = '';
  var isSignIn = true.obs; // default values

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {

    // Verificamos si tenemos una referencia de una cuenta guar
    
    /// Workers
    // Los trabajadores lo ayudarán y activarán devoluciones de llamadas específicas cuando ocurra un evento.
    // ever - se llama cada vez que la variable Rx emite un nuevo valor.
    // Se llama cada vez que cambia es estado la variable rx 'isSignIn'
    ever(isSignIn, handleAuthStateChanged);

    // StreamSubscription
    // escuchamos el estado de inicio de sesión del usuario (como inicio de sesión o desconectado)
    firebaseAuth.authStateChanges().listen((event) => isSignIn.value = event != null);


    super.onReady();
  }

  @override
  void onClose() {}

// manejador del estado de autenticación
  void handleAuthStateChanged(isLoggedIn) async {
    // visualizamos un diálogo alerta
    CustomFullScreenDialog.showDialog();
    // aquí, según el estado de autentificación redirigir al usuario a la vista correspondiente
    if (isLoggedIn) {
      // si esta autentificado
      Get.offAllNamed(Routes.HOME, arguments: {});
    } else {
      // si no esta autentificado
      Get.offAllNamed(Routes.LOGIN);
    }
    // finalizamos el diálogo alerta
    CustomFullScreenDialog.cancelDialog();
  }
}

// RELEASE
// Mostrar un diálogo con Get.dialog()
// Pero en esto, no tenemos parámetros como título y contenido, tenemos que construirlos manualmente desde cero.

class CustomFullScreenDialog {
  static void showDialog() {
    Get.dialog(
      WillPopScope(
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.yellowAccent),
          ),
        ),
        // onWillPop - Se llama cada ves que el usuario intenta descartar el ModalRoute adjunta
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      barrierColor: const Color(0xff141A31).withOpacity(.3),
      useSafeArea: true,
    );
  }

  static void cancelDialog() {
    Get.back();
  }
}