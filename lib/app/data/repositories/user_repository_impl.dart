
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../providers/firebase_data_provider.dart';

class UserRepositoryImpl extends UserRepository {

  // proveedores disponibles
  final FirebaseUserProfileProvider firebaseUserProfileProvider;  

  UserRepositoryImpl(this.firebaseUserProfileProvider);

  UserModel user = UserModel(creation: Timestamp.now(),lastUpdate:Timestamp.now() );


  // future : obtener el perfil del administrador
  @override
  Future<UserModel> getAdminProfile(String idAccount,String email) async{
    return firebaseUserProfileProvider.getAdminProfile(idAccount,email); 
  }
  // future : obtener el perfil del usuario
  @override
  Future<UserModel> getUserProfile(String idUser) {  
    return firebaseUserProfileProvider.getUser(idUser);
  }
  // future : obtener las cuentas administradas por el usuario
  @override
  Future<List<UserModel>> getUserManagedAccounts(String email) {  
    return firebaseUserProfileProvider.getUserManagedAccounts(email);
  }

}