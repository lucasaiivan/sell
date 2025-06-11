// lib/app/data/repositories/auth_repository_impl.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl(this.firebaseAuth, this.googleSignIn);

  @override
  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      throw Exception('User cancelled the login process');
    } else {
      GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await firebaseAuth.signInWithCredential(oAuthCredential);
    }
  }
  
  @override
  Future<void> signInAnonymously() {
    return firebaseAuth.signInAnonymously();
  }

  @override
  Stream<UserAuth?> authStateChanges() { 
    return firebaseAuth.authStateChanges().map((user) => user == null ? UserAuth() : UserAuth(
      uid: user.uid,
      email: user.email as String,
      displayName: user.displayName as String,
      isAnonymous: user.isAnonymous,
    ));
  }
  
  @override
  Future<void> signOut() { 
    return Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
      googleSignIn.disconnect(),
    ]);
  }
   
  
  @override 
  Future<bool> get isAnonymous async => Future.value(firebaseAuth.currentUser!.isAnonymous);
  
  @override
  Future<UserAuth> getUserAuth() {   
    return Future.value(UserAuth(
      uid: firebaseAuth.currentUser!.uid,
      email: firebaseAuth.currentUser!.email as String,
      displayName: firebaseAuth.currentUser!.displayName as String, 
      isAnonymous: firebaseAuth.currentUser!.isAnonymous,
    ));
  }
  
}