
import 'package:sell/app/domain/entities/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {


  UserModel user = UserModel();

  @override
  Future<UserModel> getUser(String idAccount,String email) async{
    // obtenemos los datos del usuario administrador
    return user;

  }

}