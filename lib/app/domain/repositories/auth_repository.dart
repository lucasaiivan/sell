// lib/app/domain/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signInAnonymously();
  Stream<User?> authStateChanges();
}