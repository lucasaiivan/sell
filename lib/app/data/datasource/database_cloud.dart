import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// operations of CRUD Firestore
class Database {

  //  Escribir datos
  //...
  //...
  //..

  // read values
  //  Podemos leer datos de Firestore de dos formas: como Futuro como Stream. Puede usar Future si desea leer los datos una sola vez.
  //  de lo contrario usaremos Stream, ya que sincronizará automáticamente los datos cada vez que se modifiquen en la base de datos.
  // future - QuerySnapshot
  static Future<QuerySnapshot<Map<String, dynamic>>> readProductsFavoritesFuture({int limit = 0}) =>limit != 0? FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').where('favorite',isEqualTo:true).limit(limit).get(): FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').where('favorite',isEqualTo:true).get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readProductsFuture({int limit = 0}) =>limit != 0? FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').limit(limit).get(): FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').orderBy("upgrade", descending: true).get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readProductsFutureNoVerified() =>FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').where("verified", isEqualTo: false).get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readProductsForMakFuture({required String idMark, int limit = 0}) =>limit != 0? FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').where("idMark", isEqualTo: idMark).limit(limit).get() : FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').where("idMark", isEqualTo: idMark).get();
  static Future<QuerySnapshot<Map<String, dynamic>>>readListPricesProductFuture({required String id, String isoPAis = 'ARG', int limit = 50}) =>FirebaseFirestore.instance.collection('APP/$isoPAis/PRODUCTOS/$id/PRICES').limit(limit).orderBy("time", descending: true).get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readCategoryListFuture({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATEGORY').get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readListMarksFuture() =>FirebaseFirestore.instance.collection('/APP/ARG/MARCAS').orderBy('upgrade',descending:true).get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readReportsProductFuture() =>FirebaseFirestore.instance.collection('/APP/ARG/REPORTS').orderBy('time',descending:true).get();
  // transactions
  static Future<QuerySnapshot<Map<String, dynamic>>> readTransactionsFuture({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS').orderBy("creation", descending: true).get();
  static Future<QuerySnapshot<Map<String, dynamic>>> readProductsVerifiedFuture() => FirebaseFirestore.instance.collection('APP/ARG/PRODUCTOS').where("verified", isEqualTo: false).get();
  
  // future - DocumentSnapshot
  static Future<DocumentSnapshot<Map<String, dynamic>>> readProductPublicFuture({required String id}) =>FirebaseFirestore.instance.collection('/APP/ARG/PRODUCTOS/').doc(id).get();
  static Future<DocumentSnapshot<Map<String, dynamic>>>readProfileAccountModelFuture(String id) =>FirebaseFirestore.instance.collection('ACCOUNTS').doc(id).get();
  static Future<DocumentSnapshot<Map<String, dynamic>>>readProductCatalogueFuture({required String idAccount, required String idProduct}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$idAccount/CATALOGUE/').doc(idProduct).get();
  static Future<DocumentSnapshot<Map<String, dynamic>>>readCategotyCatalogueFuture({required String idAccount, required String idCategory}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATEGORY/').doc(idCategory).get();
  static Future<DocumentSnapshot<Map<String, dynamic>>> readMarkFuture({required String id}) =>FirebaseFirestore.instance.collection('/APP/ARG/MARCAS/').doc(id).get();
  static Future<DocumentSnapshot<Map<String, dynamic>>> readVersionApp() =>FirebaseFirestore.instance.collection('/APP/').doc('INFO').get();
  static Future<DocumentSnapshot<Map<String, dynamic>>>readFutureAdminUser({required String idAccount,required String email}) =>FirebaseFirestore.instance.collection('ACCOUNTS').doc(idAccount).collection('USERS').doc(email).get();
 

  // stream - DocumentSnapshot
  static Stream<DocumentSnapshot<Map<String, dynamic>>> readAccountModelStream(String id) =>FirebaseFirestore.instance.collection('ACCOUNTS').doc(id).snapshots();
  // stream - QuerySnapshot
  static Stream<QuerySnapshot<Map<String, dynamic>>> readTransactionsStream({required String idAccount}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$idAccount/TRANSACTIONS').orderBy("creation", descending: true).snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> readProductsCatalogueStream({required String id}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$id/CATALOGUE').orderBy('upgrade', descending: true).snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> readCategoriesQueryStream({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATEGORY') .snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> readProvidersQueryStream({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/PROVIDER') .snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> readQueryStreamAdminsUsers({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/USERS') .snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> readCashRegistersStream({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CASHREGISTERS/').snapshots();
 
  // STORAGE reference
  static Reference referenceStorageAccountImageProfile({required String id}) => FirebaseStorage.instance.ref().child("ACCOUNTS").child(id).child("PROFILE").child("imageProfile");
  static Reference referenceStorageProductPublic({required String id}) => FirebaseStorage.instance.ref().child("APP").child("ARG").child("PRODUCTOS").child(id);
  // FIRESTORE reference
  static Reference referenceFirestoreAccountProfile({required String id}) => FirebaseStorage.instance.ref().child("ACCOUNTS").child(id).child("PROFILE").child("imageProfile");
  
  // Firestore - CollectionReference
  static CollectionReference refFirestoreAccountsUsersList({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/USERS');
  static CollectionReference refFirestoreUserAccountsList({required String email}) =>FirebaseFirestore.instance.collection('/USERS/$email/ACCOUNTS');
  static CollectionReference refFirestoretransactions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS');
  static CollectionReference refFirestoreAccount() => FirebaseFirestore.instance.collection('/ACCOUNTS/');
  static CollectionReference refFirestoreCategory({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATEGORY/');
  static CollectionReference refFirestoreProvider({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/PROVIDER');
  static CollectionReference refFirestoreCatalogueProduct({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CATALOGUE/');
  static CollectionReference refFirestoreRecords({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/RECORDS/'); // registros de los arqueos de caja
  static CollectionReference refFirestoreCashRegisters({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/CASHREGISTERS/'); // cajas registradoras activas
  static CollectionReference refFirestoreFixedDescriptions({required String idAccount}) =>FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/FIXERDESCRIPTIONS/');  // fixed descriptions
  static CollectionReference refFirestoreProductPublic() =>FirebaseFirestore.instance.collection('/APP/ARG/PRODUCTOS');
  static CollectionReference refFirestoreProductPublicBackup() =>FirebaseFirestore.instance.collection('/APP/ARG/PRODUCTOS_BACKUP');
  static CollectionReference refFirestoreRegisterPrice({required String idProducto, String isoPAis = 'ARG'}) =>FirebaseFirestore.instance.collection('/APP/$isoPAis/PRODUCTOS/$idProducto/PRICES/');
  static CollectionReference refFirestoreMark() =>FirebaseFirestore.instance.collection('/APP/ARG/MARCAS/');
  static CollectionReference refFirestoreBrandsBackup() =>FirebaseFirestore.instance.collection('/APP/ARG/BRANDS_BACKUP');
  static CollectionReference refFirestoreReportProduct() =>FirebaseFirestore.instance.collection('/APP/ARG/REPORTS');

  // set - Firestore
  static Future dbProductStockSalesIncrement({required String idAccount, required String idProduct,int quantity=1}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$idAccount/CATALOGUE/').doc(idProduct).update({"sales": FieldValue.increment(quantity)}); 
  static Future dbProductStockIncrement({required String idAccount, required String idProduct,int quantity=1}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$idAccount/CATALOGUE/').doc(idProduct).update({"quantityStock": FieldValue.increment(quantity)}); 
  static Future dbProductStockDecrement({required String idAccount, required String idProduct,int quantity=-1}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$idAccount/CATALOGUE/').doc(idProduct).update({"quantityStock": FieldValue.increment(-quantity)}); 
  // stream - consultas compuestas
  static Stream<QuerySnapshot<Map<String, dynamic>>>readSalesProduct({required String idAccount,int limit = 50}) =>FirebaseFirestore.instance.collection('ACCOUNTS/$idAccount/CATALOGUE').where("sales", isNotEqualTo:0).orderBy("sales", descending: true).limit(limit).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> readTransactionsFilterIsGreaterThanTimeStream({required String idAccount,required Timestamp timeStart}) => FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS/')
        .orderBy('creation', descending: true)
        .where('creation',isGreaterThan: timeStart )
        .snapshots();
  static Stream<QuerySnapshot<Map<String, dynamic>>> readTransactionsFilterTimeStream({required String idAccount,required Timestamp timeEnd,required Timestamp timeStart}) => FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS/')
        .orderBy('creation', descending: true)
        .where('creation',isGreaterThan: timeStart ) 
        .where('creation', isLessThan: timeEnd)
        .snapshots();
  // future - <QuerySnapshot>
  static Future<QuerySnapshot<Map<String, dynamic>>> readTransactionsFilterTimeFuture({required String idAccount,required Timestamp timeEnd,required Timestamp timeStart}) => FirebaseFirestore.instance.collection('/ACCOUNTS/$idAccount/TRANSACTIONS/')
        .orderBy('creation', descending: true)
        .where('creation',isGreaterThan: timeStart)
        .where('creation', isLessThan: timeEnd)
        .get();
  //  update value
  //  Para actualizar los datos en la base de datos, puede usar el update()método en el documentReferencerobjeto pasando los nuevos datos como un mapa. Para actualizar un documento en particular de la base de datos, deberá usar su ID de documento único .
  //...
  //...
  //...

  //  dalete value
  //  Para eliminar una nota de la base de datos, puede usar su ID de documento particular y eliminarlo usando el delete()método en el documentReferencerobjeto.
  //...
  //...
  //...
}
