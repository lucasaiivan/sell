
import '../entities/user_model.dart';

abstract class UserRepository {

  Future<UserModel> getAdminProfile( String idAccount,String email);
  Future<UserModel> getUserProfile(String idUser);
  Future<List<UserModel>> getUserManagedAccounts(String email);

}