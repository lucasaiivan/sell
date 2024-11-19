 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sell/app/domain/entities/cashRegister_model.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart';
import '../../domain/entities/ticket_model.dart';
import '../../domain/entities/user_model.dart';

//
// FirestoreCollections : representa las colecciones de Firestore
//
class FirestoreCollections {
  // collections : /APP
  static CollectionReference<Map<String, dynamic>> collectionRefPRegisterPrice({required String idProducto, String isoPAis = 'ARG'}) =>FirebaseFirestore.instance.collection('/APP/$isoPAis/PRODUCTOS/$idProducto/PRICES/'); // registro de precios de cada producto
  static CollectionReference<Map<String, dynamic>> collectionRefProductsPublicDb({String isoPAis = 'ARG'}) => FirebaseFirestore.instance.collection('/APP/$isoPAis/PRODUCTOS'); // productos publicos
  // collections : /ACCOUNTS
  static CollectionReference<Map<String, dynamic>> collectionRefAccounts() => FirebaseFirestore.instance.collection('/ACCOUNTS/');  // cuentas de los negocios
  static CollectionReference<Map<String, dynamic>> collectionRefCatalogue(String idAccount) =>  FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATALOGUE/'); // catalogo de productos
  static CollectionReference<Map<String, dynamic>> collectionRefUsersAccountAdministrators({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/USERS/'); // administradores de la cuenta
  static CollectionReference<Map<String, dynamic>> collectionRefAccountTransactions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS'); // historial de transacciones
  static CollectionReference<Map<String, dynamic>>  collectionRefCategories({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATEGORY'); // categorias del catalogo
  static CollectionReference<Map<String, dynamic>> readCollectionProviders({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/PROVIDER') ; // proveedores del catalogo
  static CollectionReference<Map<String, dynamic>> collectionRefAccountRecors({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/RECORDS'); // historial de arqueos de caja 
  static CollectionReference<Map<String, dynamic>> collectionRefCashRegisters({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CASHREGISTERS/'); // cajas registradoras activas
  static CollectionReference<Map<String, dynamic>> collectionRefFixedsDescriptions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/FIXERDESCRIPTIONS/');  // fixed descriptions
  // collections : /USERS
  static CollectionReference<Map<String, dynamic>> collectionRefUsers() =>FirebaseFirestore.instance.collection('/USERS/'); // usuarios
  static CollectionReference<Map<String, dynamic>> collectionRefUserManagedaccounts({required String email}) =>FirebaseFirestore.instance.collection('/USERS/$email/ACCOUNTS/'); // cuentas administradas por el usuario
  // streams
  static Stream<QuerySnapshot<Map<String, dynamic>>> collectionRefCategoriesQueryStream({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATEGORY') .snapshots(); // categorias del catalogo
  static Stream<QuerySnapshot<Map<String, dynamic>>> collectionRefProvidersStream({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/PROVIDER').snapshots(); // proveedores del catalogo
}  

// user : perfil del usuario 
class FirebaseUserProfileProvider {
  // future : obtengo los datos del perfil del usuario
  Future<UserModel> getAdminProfile(String idAccount,String email) async {
    try {
      
      final docSnapshot = await FirestoreCollections.collectionRefUsersAccountAdministrators( idAccount: idAccount).doc(email).get();
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
  // update : actualizar datos de la cuenta 
 Future<void> updateAccountData(String idAccount,Map<String,dynamic> values) async {
    try {
      await FirestoreCollections.collectionRefAccounts().doc(idAccount).set( Map<String, dynamic>.from(values),SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al actualizar la cuenta: $e');
    }
  }
  // update : actualiza los datos de la cuenta
  Future<void> updateAccount(ProfileAccountModel account) async {
    try {
      await FirestoreCollections.collectionRefAccounts().doc(account.id).set(account.toJson());
      } catch (e) {
        throw Exception('Error al actualizar la cuenta: $e');
     }
    }
  // future : actualizar pind de la cuenta
  Future<void> updateAccountPin(String idAccount,String pin) async {
    try {
      await FirestoreCollections.collectionRefAccounts().doc(idAccount).update({'pin': pin});
    } catch (e) {
      throw Exception('Error al actualizar el pin: $e');
    }
  }
  // future : actualizar siertos datos de la cuenta
  Future<void> updateAccountFromMap(String idAccount,Map values) async {
    try {
      await FirestoreCollections.collectionRefAccounts().doc(idAccount).set( Map<String, dynamic>.from(values),SetOptions(merge: true));
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

  // obtiene un producto de la db publica
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
  // obtenemos los productos del catalogo de la cuenta
  Future<List<ProductCatalogue>> getCatalogueProducts(String idAccount) async {
    try {

      // firebase
      final querySnapshot = await FirestoreCollections.collectionRefCatalogue(idAccount).get();
      
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
  // obtiene los productos del catalogo y escucha los cambios
  Stream<List<ProductCatalogue>> getCatalogueProductsStream(String idAccount) {
    return  FirestoreCollections.collectionRefCatalogue(idAccount).snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ProductCatalogue.fromMap(doc.data() );
      }).toList();
    });
  } 
  // obtenemos la categorias creadas por el usuario y escucha los cambios
  Stream<List<Category>> getCategoriesStream(String idAccount) {
    return FirestoreCollections.collectionRefCategoriesQueryStream(idAccount: idAccount).map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Category.fromMap(doc.data());
      }).toList();
    });
  }
  // obtenemos las categorias del catalogo
  Future<List<Category>> getCategories(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.collectionRefCategoriesQueryStream(idAccount: idAccount).first;
      List<Category> categories = querySnapshot.docs.map((doc) {
        return Category.fromMap(doc.data());
      }).toList();
      return categories;
    } catch (e) {
      return [];
    }
  }
  // obtiene los proveedores de la cuenta
  Future<List<Provider>> getProviders(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.readCollectionProviders(idAccount: idAccount).get();
      List<Provider> providers = querySnapshot.docs.map((doc) {
        return Provider.fromMap(doc.data());
      }).toList();
      return providers;
    } catch (e) {
      return [];
    }
  }
  // obtiene los proveedores y escucha los cambios
  Stream <List<Provider>> getProvidersStream(String idAccount) {
    return FirestoreCollections.collectionRefProvidersStream(idAccount: idAccount).map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Provider.fromMap(doc.data());
      }).toList();
    });
  }
  // agrega un producto al catalogo
  Future<void> addProduct(String idAccount,ProductCatalogue product) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(product.id).set(product.toJson());
  }
  // actualiza un producto del catalogo
  Future<void> updateProduct(String idAccount,ProductCatalogue product) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(product.id).update(product.toJson());
  }
  // elimina un producto del catalogo
  Future<void> deleteProduct(String idAccount,String productId) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(productId).delete();
  }
  // eliminar categoria 
  Future<void> deleteCategory(String idAccount,String idCategory) async {
    await FirestoreCollections.collectionRefCategories(idAccount: idAccount).doc(idCategory).delete();
  }
  // void : eliminar proveedor
  Future<void> deleteProvider(String idAccount,String idProvider) async {
    await FirestoreCollections.readCollectionProviders(idAccount: idAccount).doc(idProvider).delete();
  }
  // void : increment stock : incrementa las ventas de un producto
  Future<void> incrementProductStock(String idAccount,String productId,int quantity) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(productId).update({"quantityStock": FieldValue.increment(quantity)});
  }
  // void : descrement stock : decrementa las ventas de un producto
  Future<void> decrementProductStock(String idAccount,String productId,int quantity) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(productId).update({"quantityStock": FieldValue.increment(-quantity)});
  }
  // void : increment sales : incrementa las ventas de un producto
  Future<void> incrementProductStockSales(String idAccount,String productId,int quantity) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(productId).update({"sales": FieldValue.increment(quantity)});
  }

  // void : add : crea un registro del precio del producto
  Future<void> addPriceRegisterPublic(String idProduct,ProductPrice priceRegister) async {
     FirestoreCollections.collectionRefPRegisterPrice(idProducto: idProduct).doc(priceRegister.id).set(priceRegister.toJson());
  }
  // void : update : actualiza datos del producto
  Future<void> updateProductCatalogueFromMap(String idAccount,String idProduct,Map values) async {
    await FirestoreCollections.collectionRefCatalogue(idAccount).doc(idProduct).set( Map<String, dynamic>.from(values),SetOptions(merge: true));
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

  // retur : list : CashRegister : obtengo los registros de arqueo de caja activos
  Future<List<CashRegister>> getCashRegistersActive(String idAccount) async {
    try {
      final querySnapshot = await FirestoreCollections.collectionRefCashRegisters(idAccount: idAccount).get();
      List<CashRegister> cashRegisters = querySnapshot.docs.map((doc) {
        return CashRegister.fromMap(doc.data());
      }).toList();
      return cashRegisters;
    } catch (e) {
      return [];
    }
  }
  
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
      return querySnapshot.docs.map((doc) { return CashRegister.fromMap(doc.data()); }).toList();
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
      await FirestoreCollections.collectionRefCashRegisters(idAccount: idAccount).doc(cashRegister.id).delete();
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