
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {


  UserModel user = UserModel(creation: Timestamp.now(),lastUpdate:Timestamp.now() );

  @override
  Future<UserModel> getUser(String idAccount,String email) async{
    // obtenemos los datos del usuario administrador
    return user;

  }

}