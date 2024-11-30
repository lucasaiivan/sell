
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../../../domain/use_cases/authenticate_use_case.dart';
import '../../splash/controllers/splash_controller.dart';

class LoginController extends GetxController {

  // source
  String sellImagen = "assets/sell02.jpeg";
  String transactionImage = "assets/sell05.jpeg";
  String catalogueImage = "assets/catalogue03.jpeg";
 

  // controllers
  SplashController homeController = Get.find<SplashController>();

  // state : style
  Rx<Color> checkPolicyAlertColor = Colors.orange.shade100.withOpacity(0.3).obs;
  // state - Check Accept Privacy And Use Policy
  RxBool stateCheckAcceptPrivacyAndUsePolicy = false.obs;
  bool get getStateCheckAcceptPrivacyAndUsePolicy =>
      stateCheckAcceptPrivacyAndUsePolicy.value;
  set setStateCheckAcceptPrivacyAndUsePolicy(bool value) {
    if(value){checkPolicyAlertColor.value = Colors.transparent;}
    else {checkPolicyAlertColor.value = Colors.orange.shade100.withOpacity(0.3);}
    stateCheckAcceptPrivacyAndUsePolicy.value = value;  
  }



  @override
  void onClose() {}

  void login() async {
    // LOGIN // 
    // Inicio de sesión con Google
    // Primero comprobamos que el usuario acepto los términos de uso de servicios y que a leído las politicas de privacidad
    if (getStateCheckAcceptPrivacyAndUsePolicy) {
      
      // set state load
      CustomFullScreenDialog.showDialog();

      // case use : metodo de autenticación con Google
      var auth = AuthenticateUserUseCase(); 
      await auth.authenticateWithGoogle().whenComplete(
        () {
          // finalizamos el diálogo alerta
          CustomFullScreenDialog.cancelDialog();
        },
      ); 

    } else {
      // message for user
      Get.snackbar(
          'Primero tienes que leer nuestras políticas y términos de uso 🙂',
          'Tienes que aceptar nuestros términos de uso y política de privacidad para usar esta aplicación');
      checkPolicyAlertColor.value = Colors.red.shade100.withOpacity(0.7); 
    }
  } 
  void signInAnonymously() async { 

    // set state load
    CustomFullScreenDialog.showDialog();

    try {
      // user case : signInAnonymously
      final auth = AuthenticateUserUseCase();
      auth.signInAnonymously();
      
      CustomFullScreenDialog.cancelDialog();
    } catch (e) {
      // message : Error: [firebase_auth/operation-not-allowed] Anonymous Sign-In is not enabled for this project. Enable it in the Firebase Console, under the Sign-in method tab of the Auth section.
      Get.snackbar('Error', e.toString());
      CustomFullScreenDialog.cancelDialog();
    }
  }
}




// RELEASE
// Mostrar un diálogo con Get.dialog()
// Pero en esto, no tenemos parámetros como título y contenido, tenemos que construirlos manualmente desde cero.

class CustomFullScreenDialog {
  static void showDialog() {
    Get.dialog(
      const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.yellowAccent),
          ),
        ), // deshabilitar el botón de retroceso del dispositivo
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
