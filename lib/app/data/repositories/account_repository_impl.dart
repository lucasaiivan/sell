 
import 'package:sell/app/domain/entities/user_model.dart';
import '../../domain/repositories/account_repository.dart';
import '../providers/firebase_data_provider.dart';

class AccountRepositoryImpl implements AccountRepository {

  // proveedores disponibles
  final FirebaseAccountProvider firebaseDataProvider;  
  AccountRepositoryImpl(this.firebaseDataProvider );
  


  @override
  Future<ProfileAccountModel> getAccount(String idAccount) {
    // obtengo los datos del preoveedor [Firebase] 
    return firebaseDataProvider.getAccount(idAccount);
  }

  @override
  Future<void> updateAccount(ProfileAccountModel account) { 
    // actualiza los datos de la cuenta
    return firebaseDataProvider.updateAccount(account);
  }
  
  @override
  Future<List<UserModel>> getAccountAdmins(String idAccount) {
    // obtengo los administradores de la cuenta
    return firebaseDataProvider.getUsersAccountAdministrators(idAccount);
  }
  
  @override
  Future<void> updatePinAccount(String idAccount, String pin) {
    // actualizar pin de la cuenta
    return firebaseDataProvider.updateAccountPin(idAccount, pin);
  }
  
  @override
  Future<void> updateAccountData(String idAccount, Map<String, dynamic> data) {
    // obtener los datos de la cuenta
    return firebaseDataProvider.updateAccountData(idAccount, data);
  } 
    
}