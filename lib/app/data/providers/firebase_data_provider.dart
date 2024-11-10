 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart';
import '../../domain/entities/user_model.dart';

class FirebaseUserProvider {
  Future<UserModel> getUser(String id) async {
    //  get : obtengo los datos de Firestore
    return UserModel(id:id,creation:Timestamp.now(),lastUpdate: Timestamp.now(),name: 'Usuario (firebase)');
  }
}
 

class FirebaseCatalogueProvider {

  static CollectionReference refFirestoreCatalogueProduct({required String idAccount}) {return FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATALOGUE/');}

  Future<List<ProductCatalogue>> getCatalogueProducts(String idAccount) async {
    try {

      // firebase
      final querySnapshot = await refFirestoreCatalogueProduct(idAccount: idAccount).get();
      
      // Mapea cada documento de Firestore a una instancia de ProductCatalogue
      List<ProductCatalogue> products = querySnapshot.docs.map((doc) {
        return ProductCatalogue.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      return products;
    } catch (e) {
      print("Error fetching catalogue products: $e");
      return [];
    }
  }

  Stream<List<ProductCatalogue>> getCatalogueProductsStream(String idAccount) {
    return refFirestoreCatalogueProduct(idAccount: idAccount).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ProductCatalogue.fromMap(doc.data() as Map<String, dynamic> );
      }).toList();
    });
  }
}