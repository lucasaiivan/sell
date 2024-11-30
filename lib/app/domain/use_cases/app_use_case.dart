//  [ case use ]
//  Este archivo contiene los Casos de Uso de la aplicación
 
import '../../data/providers/firebase_data_provider.dart';
import '../../data/providers/local_data_provider.dart';
import '../../data/repositories/app_info_impl.dart';
import '../entities/app_info.dart';
import '../repositories/app_repository.dart';

class GetAppData {
  final AppInfoRepository appRepository;

  GetAppData() : appRepository = AppInfoImpl(FirebaseAppInfoProvider() , LocalAppDataProvider());


  // get : int : obtener informacion de la aplicacion
  Future<AppInfo> getAppInfo() async { 
    return await appRepository.getAppInfo();
  } 
  // get : storage local : idAccount : obtenemos el id de la cuenta seleccionado desde el [storage local}
  Future<String> getStorageLocalIdAccount() {
    return appRepository.getStorageLocalIdAccount();
  }
  // get : storage local : cashRegisterID : recuperamos si existe el id de la caja registradora que se creo/selecciona por el usuario
  Future<String> getStorageLocalCashRegisterID() { 
    return appRepository.getStorageLocalCashRegisterID();
  }
  // get : storage local : obtenemos el estado de modo cajero activado [cashierMode]
  Future<bool> getStorageLocalCashierMode() { 
    return appRepository.getStorageLocalCashierMode();
  }


  // set : storage local : modo cajero activado [cashierMode]
  Future<void> setStorageLocalCashierMode(bool cashierMode) {
    return appRepository.setStorageLocalCashierMode(cashierMode);
  }
  // set : storage local : idAccount : guardamos el id se la cuenta seleccionada
  Future<void> setStorageLocalIdAccount(String idAccount) {
    return appRepository.setStorageLocalIdAccount(idAccount);
  }
  // set : storage local : cashRegisterID : guardamos el id de la caja registradora seleccionada
  Future<void> setStorageLocalCashRegisterID(String cashRegisterID) {
    return appRepository.setStorageLocalCashRegisterID(cashRegisterID);
  }

  // void : limpiar datos y cache local de la app
  Future<void> clearLocalData() async {
    await appRepository.cleanLocalData(); 
  }

}