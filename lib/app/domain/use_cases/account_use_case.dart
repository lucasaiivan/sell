

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../entities/user_model.dart';
import '../repositories/account_repository.dart';

class GetAccountUseCase{ 

  final AccountRepository catalogueRepository;  
  GetAccountUseCase() : catalogueRepository = AccountRepositoryImpl(FirebaseAccountProvider());

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
}