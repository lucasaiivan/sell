

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../entities/user_model.dart';
import '../repositories/account_repository.dart';

class GetAccountUseCase{ 

  final AccountRepository catalogueRepository;  
  GetAccountUseCase() : catalogueRepository = AccountRepositoryImpl(FirebaseAccountProvider());

  // future : Acutalizar datos de la cuenta
  Future<void> updateAccountData({required String idAccount,required Map<String, dynamic> data}) async {
    // logic business
    // ... 
    return await catalogueRepository.updateAccountData(idAccount,data);
  }
  // future : obtener datos de la cuenta
  Future<ProfileAccountModel> getAccount({required String idAccount}) async {
    // logic business
    // ... 
    return await catalogueRepository.getAccount(idAccount);
  }
  // future : obtenemos los administradores de la cuenta
  Future<List<UserModel>> getAccountAdmins({required String idAccount}) async {
    // logic business
    // ... 
    return await catalogueRepository.getAccountAdmins(idAccount);
  }
  // void : actualizar pin de la cuenta
  Future<void> updateAccountPin({required ProfileAccountModel account,String pin = ''}) async {
    // logic business
    if(pin.isEmpty){return;}
    // ... 
    return await catalogueRepository.updatePinAccount(account.id,pin);
  } 
}