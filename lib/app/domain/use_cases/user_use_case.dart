

import '../../data/providers/firebase_data_provider.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../entities/user_model.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase{
  
  final UserRepository userRepository;
  
  GetUserUseCase() : userRepository = UserRepositoryImpl(FirebaseUserProfileProvider());


  // future : obtener el perfil administrador del usaurio 
  Future<UserModel> getAdminProfile({required String idUser, required String idAccount}) async {
    // ... logic
    return await userRepository.getAdminProfile(idAccount,idUser);
  }
  // future : obtobtenemos el perfil del usuario
  Future<UserModel> getUserProfile({required String idUser}) async {
    // ... logic
    return await userRepository.getUserProfile(idUser);
  }
  // future : obtenemos las cuentas asociadas al usuario
  Future<List<UserModel>> getUserAssociatedAccounts({required String email}) async {
    // ... logic
    return await userRepository.getUserManagedAccounts(email);
  }
}