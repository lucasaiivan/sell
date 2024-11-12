 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/cashRegister_model.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart';
import '../../domain/entities/user_model.dart';

//
// FirestoreCollections : representa las colecciones de Firestore
//
class FirestoreCollections {
  // collections
  static CollectionReference<Map<String, dynamic>> users() =>FirebaseFirestore.instance.collection('/USERS/');
  static CollectionReference<Map<String, dynamic>> accounts() => FirebaseFirestore.instance.collection('/ACCOUNTS/'); 
  static CollectionReference<Map<String, dynamic>> catalogue(String idAccount) =>  FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATALOGUE/');
  static CollectionReference<Map<String, dynamic>> productsPublicDb() => FirebaseFirestore.instance.collection('/APP/ARG/PRODUCTOS');
  static CollectionReference<Map<String, dynamic>> refCollectionUsersAccountAdministrators({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/USERS/');
  static CollectionReference<Map<String, dynamic>> redCollectionUserManagedaccounts({required String email}) =>FirebaseFirestore.instance.collection('/USERS/$email/ACCOUNTS/');
  static CollectionReference<Map<String, dynamic>> refCollectionAccountTransactions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS');
  // future
  static Future<DocumentSnapshot<Map<String, dynamic>>>readAdminUserFuture({required String idAccount,required String email}) =>FirebaseFirestore.instance.collection('ACCOUNTS').doc(idAccount).collection('USERS').doc(email).get();
  // ...
}  

// user : perfil del usuario 
class FirebaseUserProfileProvider {
  // future : obtengo los datos del perfil del usuario
  Future<UserModel> getAdminProfile(String idAccount,String email) async {
    try {
      
      final docSnapshot = await FirestoreCollections.readAdminUserFuture(idAccount:idAccount,email: email);

      if (docSnapshot.exists) {
        return UserModel.fromDocumentSnapshot(documentSnapshot: docSnapshot);
      } else {
        return UserModel( creation: Timestamp.now(),lastUpdate: Timestamp.now());
      }
    } catch (e) {
      return UserModel( creation: Timestamp.now(),lastUpdate: Timestamp.now());
    }
  }
  // future : obtengo los datos del perfil del usuario
  Future<UserModel> getUser(String idUser) async {
    try {
      final docSnapshot = await FirestoreCollections.users().doc(idUser).get();
      if (docSnapshot.exists) {
        return UserModel.fromDocumentSnapshot(documentSnapshot: docSnapshot);
      } else {
        return UserModel(creation: Timestamp.now(),lastUpdate: Timestamp.now());
      }
    } catch (e) {
      return UserModel(creation: Timestamp.now(),lastUpdate: Timestamp.now());
    }
  }
  // futute : obtengo las cuentas administradas por el usuario
  Future<List<UserModel>> getUserManagedAccounts(String email) async {
    try {
      final querySnapshot = await FirestoreCollections.redCollectionUserManagedaccounts(email:email).get();
      return querySnapshot.docs.map((doc) { return UserModel.fromDocumentSnapshot(documentSnapshot: doc);}).toList();
    } catch (e) {
      return [];
    }
  } 
  
}

// account : perfil de la cuenta del negocio
class FirebaseAccountProvider {
 
  // account : obtenemos los datos de la cuenta
  Future<ProfileAccountModel> getAccount(String idAccount) async {
    try {  
      final docSnapshot = await FirestoreCollections.accounts().doc(idAccount).get();
      if (docSnapshot.exists) { 
        return ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: docSnapshot ); 
      } else {return ProfileAccountModel(creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now());}
    } catch (e) { return ProfileAccountModel(creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now()  );}
  }
  // update : actualiza los datos de la cuenta
  Future<void> updateAccount(ProfileAccountModel account) async {
    try {
      await FirestoreCollections.accounts().doc(account.id).set(account.toJson());
      } catch (e) {
        throw Exception('Error al actualizar la cuenta: $e');
     }
    }

  // futute : obtengo los administradores de la cuenta
  Future<List<UserModel>> getUsersAccountAdministrators(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.refCollectionUsersAccountAdministrators(idAccount: idAccount).get();
      List<UserModel> accounts = querySnapshot.docs.map((doc) {
        return UserModel.fromDocumentSnapshot(documentSnapshot: doc);
      }).toList();
      return accounts;
    } catch (e) {
      return [];
    }
  }
  
  }

 // catalogue : obtenemos los productos del catalogo
class FirebaseCatalogueProvider { 
  // 
  Future<List<ProductCatalogue>> getCatalogueProducts(String idAccount) async {
    try {

      // firebase
      final querySnapshot = await FirestoreCollections.catalogue(idAccount).get();
      
      // Mapea cada documento de Firestore a una instancia de ProductCatalogue
      List<ProductCatalogue> products = querySnapshot.docs.map((doc) {
        return ProductCatalogue.fromMap(doc.data());
      }).toList();
      return products;
    } catch (e) {
      //print("Error fetching catalogue products: $e");
      return [];
    }
  }

  Stream<List<ProductCatalogue>> getCatalogueProductsStream(String idAccount) {
    return  FirestoreCollections.catalogue(idAccount).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ProductCatalogue.fromMap(doc.data() );
      }).toList();
    });
  } 

  Future<void> addProduct(String idAccount,ProductCatalogue product) async {
    await FirestoreCollections.catalogue(idAccount).doc(product.id).set(product.toJson());
  }

  Future<void> updateProduct(String idAccount,ProductCatalogue product) async {
    await FirestoreCollections.catalogue(idAccount).doc(product.id).update(product.toJson());
  }

  Future<void> deleteProduct(String idAccount,String productId) async {
    await FirestoreCollections.catalogue(idAccount).doc(productId).delete();
  }
  
}

// transaction : transacciones de la cuenta
class FirebaseTransactionProvider {
  // future : obtengo las transacciones de la cuenta
  Future<List<CashRegister>> getTransactions(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.refCollectionAccountTransactions(idAccount: idAccount).get();
      List<CashRegister> transactions = querySnapshot.docs.map((doc) {
        return CashRegister.fromMap(doc.data());
      }).toList();
      return transactions;
    } catch (e) {
      return [];
    }
  } 
}