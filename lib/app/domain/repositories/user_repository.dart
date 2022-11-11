
import '../entities/user_model.dart';

abstract class UserRepository {

  Future<UserModel> getUser(String idAccount,String email);

}