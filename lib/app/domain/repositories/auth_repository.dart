// lib/app/domain/repositories/auth_repository.dart
import '../entities/user_model.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInAnonymously();
  Stream<UserAuth?> authStateChanges();
  Future<void> signOut();
  Future<UserAuth> getUserAuth();  
  Future<bool> get isAnonymous;
}