import 'dart:async'; 
import 'package:get/get.dart'; 
import 'package:sell/app/domain/entities/user_model.dart'; 
import '../../../core/routes/app_pages.dart';
import '../../../domain/use_cases/app_use_case.dart';
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


    // case use : definimos los casos de uso
    final auth = AuthenticateUserUseCase(); 
    final appData = AppDataUseCase();
    // stream : escuchar cambios en el estado de autenticación del usuario
    return auth.authStateChanges().listen((UserAuth? user) async {
      if ( user!.isAnonymous) {
        // si esta autentificado como anonimo //   
        Get.offAllNamed(Routes.home, arguments: {'currentUser': UserAuth(),'idAccount':''} );
      }else if ( user.uid == '' ) {
        // Usuario no autenticado // 
        appData.setStorageLocalIdAccount(''); 
        appData.clearLocalData();
        Get.offAllNamed(Routes.login);
      } else {
        // si esta autentificado // 
        idAccount = await appData.getStorageLocalIdAccount(); // obtenemos el id de la cuenta seleccionado desde el [storage local} 
        Get.offAllNamed(Routes.home, arguments: {'currentUser': user,'idAccount': idAccount,'isAnonymous':user.isAnonymous} );
      }
    });
  }
 
}
