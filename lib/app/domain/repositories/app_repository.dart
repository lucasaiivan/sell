// definimos la interfaz del repositorio de la aplicación

import '../entities/app_info.dart';

abstract class AppInfoRepository {
  // get : int : obtener la version de la aplicacion actual
  Future<AppInfo> getAppInfo();
  // get : storage local : idAccount : obtenemos el id de la cuenta seleccionado desde el [storage local}
  Future<String> getStorageLocalIdAccount();
  // get : storage local : cashRegisterID : recuperamos si existe el id de la caja registradora que se creo/selecciona por el usuario
  Future<String> getStorageLocalCashRegisterID();
  // get : storage local : obtenemos el estado de modo cajero activado [cashierMode]
  Future<bool> getStorageLocalCashierMode();
  
  // set : storage local : modo cajero activado [cashierMode]
  Future<void> setStorageLocalCashierMode(bool cashierMode);
  // set : storage local : idAccount : guardamos el id se la cuenta seleccionada
  Future<void> setStorageLocalIdAccount(String idAccount);
  // set : storage local : cashRegisterID : guardamos el id de la caja registradora seleccionada
  Future<void> setStorageLocalCashRegisterID(String cashRegisterID);

  // void : limpiar datos y cache local de la app
  Future<void> cleanLocalData();

}