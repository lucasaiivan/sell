 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sell/app/domain/entities/cashRegister_model.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart';
import '../../domain/entities/ticket_model.dart';
import '../../domain/entities/user_model.dart';

//
// FirestoreCollections : representa las colecciones de Firestore
//
class FirestoreCollections {
  // collections : app
  static CollectionReference<Map<String, dynamic>> collectionRefPRegisterPrice({required String idProducto, String isoPAis = 'ARG'}) =>FirebaseFirestore.instance.collection('/APP/$isoPAis/PRODUCTOS/$idProducto/PRICES/');
  static CollectionReference<Map<String, dynamic>> collectionRefProductsPublicDb({String isoPAis = 'ARG'}) => FirebaseFirestore.instance.collection('/APP/$isoPAis/PRODUCTOS');
  // collections : account
  static CollectionReference<Map<String, dynamic>> collectionRefAccounts() => FirebaseFirestore.instance.collection('/ACCOUNTS/'); 
  static CollectionReference<Map<String, dynamic>> collectionRefAatalogue(String idAccount) =>  FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATALOGUE/');
  static CollectionReference<Map<String, dynamic>> collectionRefUsersAccountAdministrators({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/USERS/');
  static CollectionReference<Map<String, dynamic>> collectionRefAccountTransactions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS'); // historial de transacciones
  static CollectionReference<Map<String, dynamic>> collectionRefAccountRecors({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/RECORDS'); // historial de arqueos de caja 
  static CollectionReference<Map<String, dynamic>> collectionRefRecords({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/RECORDS/'); // registros de los arqueos de caja
  static CollectionReference<Map<String, dynamic>> collectionRefCashRegisters({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CASHREGISTERS/'); // cajas registradoras activas
  static CollectionReference<Map<String, dynamic>> collectionRefFixedsDescriptions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/FIXERDESCRIPTIONS/');  // fixed descriptions
  // collections : user
  static CollectionReference<Map<String, dynamic>> collectionRefUsers() =>FirebaseFirestore.instance.collection('/USERS/');
  static CollectionReference<Map<String, dynamic>> collectionRefUserManagedaccounts({required String email}) =>FirebaseFirestore.instance.collection('/USERS/$email/ACCOUNTS/');
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
      final docSnapshot = await FirestoreCollections.collectionRefUsers().doc(idUser).get();
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
      final querySnapshot = await FirestoreCollections.collectionRefUserManagedaccounts(email:email).get();
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
      final docSnapshot = await FirestoreCollections.collectionRefAccounts().doc(idAccount).get();
      if (docSnapshot.exists) { 
        return ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: docSnapshot ); 
      } else {return ProfileAccountModel(creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now());}
    } catch (e) { return ProfileAccountModel(creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now()  );}
  }
  // update : actualiza los datos de la cuenta
  Future<void> updateAccount(ProfileAccountModel account) async {
    try {
      await FirestoreCollections.collectionRefAccounts().doc(account.id).set(account.toJson());
      } catch (e) {
        throw Exception('Error al actualizar la cuenta: $e');
     }
    }

  // futute : obtengo los administradores de la cuenta
  Future<List<UserModel>> getUsersAccountAdministrators(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.collectionRefUsersAccountAdministrators(idAccount: idAccount).get();
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

  // return : Product : obtiene un producto de la db publica
  Future<Product> getProductPublic(String idProduct) async {
    try {
      final docSnapshot = await FirestoreCollections.collectionRefProductsPublicDb().doc(idProduct).get();
      if (docSnapshot.exists) { 
        return Product.fromMap(docSnapshot.data()!);
      } else { 
        return Product(upgrade: Timestamp.now(),creation: Timestamp.now());
      }
    } catch (e) {
      return Product(upgrade: Timestamp.now(),creation: Timestamp.now());
    }
  }
  //  
  Future<List<ProductCatalogue>> getCatalogueProducts(String idAccount) async {
    try {

      // firebase
      final querySnapshot = await FirestoreCollections.collectionRefAatalogue(idAccount).get();
      
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
    return  FirestoreCollections.collectionRefAatalogue(idAccount).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ProductCatalogue.fromMap(doc.data() );
      }).toList();
    });
  } 

  Future<void> addProduct(String idAccount,ProductCatalogue product) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(product.id).set(product.toJson());
  }

  Future<void> updateProduct(String idAccount,ProductCatalogue product) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(product.id).update(product.toJson());
  }

  Future<void> deleteProduct(String idAccount,String productId) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(productId).delete();
  }

  // void : increment stock : incrementa las ventas de un producto
  Future<void> incrementProductStock(String idAccount,String productId,int quantity) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(productId).update({"quantityStock": FieldValue.increment(quantity)});
  }
  // void : descrement stock : decrementa las ventas de un producto
  Future<void> decrementProductStock(String idAccount,String productId,int quantity) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(productId).update({"quantityStock": FieldValue.increment(-quantity)});
  }
  // void : increment sales : incrementa las ventas de un producto
  Future<void> incrementProductStockSales(String idAccount,String productId,int quantity) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(productId).update({"sales": FieldValue.increment(quantity)});
  }

  // void : add : crea un registro del precio del producto
  Future<void> addPriceRegisterPublic(String idProduct,ProductPrice priceRegister) async {
     FirestoreCollections.collectionRefPRegisterPrice(idProducto: idProduct).doc(priceRegister.id).set(priceRegister.toJson());
  }
  // void : update : actualiza datos del producto
  Future<void> updateProductCatalogueFromMap(String idAccount,String idProduct,Map values) async {
    await FirestoreCollections.collectionRefAatalogue(idAccount).doc(idProduct).set( Map<String, dynamic>.from(values),SetOptions(merge: true));
  }
}

// transaction : transacciones de la cuenta
class FirebaseTransactionProvider {
  // list : obtengo las transacciones de la cuenta
  Future<List<TicketModel>> getTransactions(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.collectionRefAccountTransactions(idAccount: idAccount).get();
      List<TicketModel> transactions = querySnapshot.docs.map((doc) {
        return TicketModel.fromMap(doc.data());
      }).toList();
      return transactions;
    } catch (e) {
      return [];
    }
  }  
  // add : agrega al historial de transacciones
  Future<void> addTransaction(String idAccount,TicketModel ticketModel) async {
    try {
      await FirestoreCollections.collectionRefAccountTransactions(idAccount: idAccount).add(ticketModel.toJson());
    } catch (e) {
      throw Exception('Error al agregar el registro: $e');
    }
  }
  // delete : elimina un registro del historial de transacciones
  Future<void> deleteTransaction(String idAccount,TicketModel ticketModel) async {
    try {
      await FirestoreCollections.collectionRefAccountTransactions(idAccount: idAccount).doc(ticketModel.id).delete();
    } catch (e) {
      throw Exception('Error al eliminar el registro: $e');
    }
  }
  
}

// historial de arqueos de caja
class FirebaseHistoryCashRegisterProvider {
  // return : list : CashRegister : obtengo los registros de arqueo de caja
  Future<List<CashRegister>> getHistoryCashRegisters(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.collectionRefAccountRecors(idAccount: idAccount).get();
      List<CashRegister> cashRegisters = querySnapshot.docs.map((doc) {
        return CashRegister.fromMap(doc.data());
      }).toList();
      return cashRegisters;
    } catch (e) {
      return [];
    }
  }
  // return : list : CashRegister : obtengo los registros de arqueo de caja
  Stream<List<CashRegister>> getHistoryCashRegistersStream(String idAccount) {
    return FirestoreCollections.collectionRefAccountRecors(idAccount: idAccount).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return CashRegister.fromMap(doc.data());
      }).toList();
    });
  }
  
  // void : add : obtengo los registros de arqueo de caja
  Future<void> addHistoryCashRegister(String idAccount,CashRegister cashRegister) async {
    try {
      await FirestoreCollections.collectionRefAccountRecors(idAccount: idAccount).add(cashRegister.toJson());
    } catch (e) {
      throw Exception('Error al agregar el registro: $e');
    }
  }
  // void : delete : elimina un registro de arqueo de caja
  Future<void> deleteHistoryCashRegister(String idAccount,CashRegister cashRegister) async {
    try {
      await FirestoreCollections.collectionRefAccountRecors(idAccount: idAccount).doc(cashRegister.id).delete();
    } catch (e) {
      throw Exception('Error al eliminar el registro: $e');
    }
  }

  // create/update : actualiza la caja registradora activas
  Future<void> setCashRegister(String idAccount,CashRegister cashRegister) async {
    try {
      await FirestoreCollections.collectionRefCashRegisters(idAccount: idAccount).doc(cashRegister.id).set(cashRegister.toJson());
    } catch (e) {
      throw Exception('Error al actualizar la caja registradora: $e');
    }
  }
  // delete : elimina la caja registradora activa
  Future<void> deleteCashRegister(String idAccount,String idCashRegister) async {
    try {
      await FirestoreCollections.collectionRefCashRegisters(idAccount: idAccount).doc(idCashRegister).delete();
    } catch (e) {
      throw Exception('Error al eliminar la caja registradora: $e');
    }
  }

  // FIXERS : elimina una descripción fijada
  Future<void> deleteFixedDescription(String idAccount,String idDescription) async {
    try {
      await FirestoreCollections.collectionRefFixedsDescriptions(idAccount: idAccount).doc(idDescription).delete();
    } catch (e) {
      throw Exception('Error al eliminar la descripción fijada: $e');
    }
  }
  // FIXERS : registra una descripción fija
  Future<void> createFixedDescription(String idAccount,String idDescription) async {
    try {
      await FirestoreCollections.collectionRefFixedsDescriptions(idAccount: idAccount).doc(idDescription).set({'description':idDescription},SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al agregar la descripción fijada: $e');
    }
  }
  // FIXERS : obtiene las descripciones fijadas
  Future<List<Map>> getFixedsDescriptions(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.collectionRefFixedsDescriptions(idAccount: idAccount).get();
      List<Map> transactionsj = querySnapshot.docs.map((doc) {
        return doc.data() as Map;
      }).toList();
      return transactionsj;
    } catch (e) {
      return [];
    }
  }

}