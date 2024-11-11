 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart';
import '../../domain/entities/user_model.dart';

class FirebaseUserProvider {
  Future<UserModel> getUser(String id) async {
    //  get : obtengo los datos de Firestore
    return UserModel(id:id,creation:Timestamp.now(),lastUpdate: Timestamp.now(),name: 'Usuario (firebase)');
  }
}

// FirestoreCollections : representa las colecciones de Firestore
class FirestoreCollections {
  static CollectionReference<Map<String, dynamic>> accounts() => FirebaseFirestore.instance.collection('/ACCOUNTS/'); 
  static CollectionReference<Map<String, dynamic>> catalogue(String idAccount) =>  FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATALOGUE/');
  static CollectionReference<Map<String, dynamic>> productsPublicDb() => FirebaseFirestore.instance.collection('/APP/ARG/PRODUCTOS');

  // Agrega más métodos según sea necesario
} 

// account : cuenta del negocio
class FirebaseAccountProvider {
 
  // account : obtenemos los datos de la cuenta
  Future<ProfileAccountModel> getAccount(String idAccount) async {
    try { 

      final docSnapshot = await FirestoreCollections.accounts().doc(idAccount).get();
      if (docSnapshot.exists) { 
        return ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: docSnapshot ); 
      } else {
        return ProfileAccountModel(creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now()  );
        
      }
    } catch (e) { 
      return ProfileAccountModel(creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now()  );
    }
  }
  // update : actualiza los datos de la cuenta
  Future<void> updateAccount(ProfileAccountModel account) async {
    try {
      await FirestoreCollections.accounts().doc(account.id).set(account.toJson());
      } catch (e) {
        throw Exception('Error al actualizar la cuenta: $e');
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
  // void : eliminar un producto del catalogo
  Future<void> deleteProduct({required String productId,required String idAccount}) async {
    try {
      await FirestoreCollections.catalogue(idAccount).doc(productId).delete();
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }
}