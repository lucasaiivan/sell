// lib/app/domain/use_cases/authenticate_user_use_case.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

class AuthenticateUserUseCase { 

  final AuthRepository authRepository;  
  AuthenticateUserUseCase() : authRepository = AuthRepositoryImpl(FirebaseAuth.instance, GoogleSignIn());



  // future : autenticar con google
  Future<void> authenticateWithGoogle() async {
    return await authRepository.signInWithGoogle();
  }
  // future : autenticar anonimamente
  Future<void> signInAnonymously() async {
    return await authRepository.signInAnonymously();
  }
  // stream : escuchar cambios en el estado de autenticación
  Stream<User?> authStateChanges() {
    return authRepository.authStateChanges();
  }
}