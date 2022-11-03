import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../splash/controllers/splash_controller.dart';

class LoginController extends GetxController {
  // controllers
  SplashController homeController = Get.find<SplashController>();

  // state - Check Accept Privacy And Use Policy
  RxBool stateCheckAcceptPrivacyAndUsePolicy = false.obs;
  bool get getStateCheckAcceptPrivacyAndUsePolicy =>
      stateCheckAcceptPrivacyAndUsePolicy.value;
  set setStateCheckAcceptPrivacyAndUsePolicy(bool value) =>
      stateCheckAcceptPrivacyAndUsePolicy.value = value;



  @override
  void onClose() {}

  void login() async {
    // LOGIN
    // Inicio de sesión con Google
    // Primero comprobamos que el usuario acepto los términos de uso de servicios y que a leído las politicas de privacidad
    if (getStateCheckAcceptPrivacyAndUsePolicy) {
      
      // set state load
      CustomFullScreenDialog.showDialog();

      // Activar el flujo de autenticación
      GoogleSignInAccount? googleSignInAccount = await homeController.googleSign.signIn();
      if (googleSignInAccount == null) {
        CustomFullScreenDialog.cancelDialog();
      } else {
        // Obtenga los detalles de autenticación de la solicitud
        GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        // Crea una nueva credencial de OAuth genérica.
        OAuthCredential oAuthCredential = GoogleAuthProvider.credential(accessToken: googleSignInAuthentication.accessToken,idToken: googleSignInAuthentication.idToken);
        // Una vez que haya iniciado sesión, devuelva el UserCredential
        await homeController.firebaseAuth.signInWithCredential(oAuthCredential);
        // finalizamos el diálogo alerta
        CustomFullScreenDialog.cancelDialog();
      }

    } else {
      // message for user
      Get.snackbar(
          'Primero tienes que leer nuestras políticas y términos de uso 🙂',
          'Tienes que aceptar nuestros términos de uso y política de privacidad para usar esta aplicación');
    }
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
