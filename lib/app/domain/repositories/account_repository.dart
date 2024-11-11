// definimos la interfaz del repositorio de cuentas

import '../entities/user_model.dart';

abstract class AccountRepository {
  // obtener los datos de la cuenta
  Future<ProfileAccountModel> getAccount(String idAccount); 
  // update : actualiza los datos de la cuenta
  Future<void> updateAccount(ProfileAccountModel account);
}