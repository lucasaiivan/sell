// definimos la interfaz del repositorio de cuentas

import '../entities/user_model.dart';

abstract class AccountRepository {
  // set : obtenemos los datos de la cuenta
  Future<void> updateAccountData(String idAccount, Map<String, dynamic> data);
  // get : obtener los datos de la cuenta
  Future<ProfileAccountModel> getAccount(String idAccount); 
  // update : actualiza los datos de la cuenta
  Future<void> updateAccount(ProfileAccountModel account); 
  // get : obtego los administradores de la cuenta
  Future<List<UserModel>> getAccountAdmins(String idAccount);
  // update : actualizar pin de la cuenta
  Future<void> updatePinAccount(String idAccount, String pin);

}