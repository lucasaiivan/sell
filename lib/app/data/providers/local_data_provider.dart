

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

import '../../domain/entities/catalogo_model.dart';
import '../../domain/entities/user_model.dart';

class LocalAppDataProvider {
  late GetStorage storageLocal;
  // contrucctor 
  LocalAppDataProvider() {
    storageLocal = GetStorage();
  }

  // get : storage local : idAccount : obtenemos el id de la cuenta seleccionado desde el [storage local}
  Future<String> getStorageLocalIdAccount() async {
    return storageLocal.read('idAccount');
  }
  // get : storage local : cashRegisterID : recuperamos si existe el id de la caja registradora que se creo/selecciona por el usuario
  Future<String> getStorageLocalCashRegisterID() async {
    return storageLocal.read('cashRegisterID');
  }
  // get : storage local : obtenemos el estado de modo cajero activado [cashierMode]
  Future<bool> getStorageLocalCashierMode() async {
    return storageLocal.read('cashierMode') ?? false;
  }



  // set : storage local : modo cajero activado [cashierMode]
  Future<void> setStorageLocalCashierMode(bool cashierMode) async {
    return storageLocal.write('cashierMode', cashierMode);
  }
  // set : storage local : idAccount : guardamos el id se la cuenta seleccionada
  Future<void> setStorageLocalIdAccount(String idAccount) async {
    return storageLocal.write('idAccount', idAccount);
  }
  // set : storage local : cashRegisterID : guardamos el id de la caja registradora seleccionada
  Future<void> setStorageLocalCashRegisterID(String cashRegisterID) async {
    return storageLocal.write('cashRegisterID', cashRegisterID);
  }

  

  // void : limpiar datos y cache local de la app
  Future<void> cleanLocalData() async {
    await const FlutterSecureStorage().deleteAll();
    await storageLocal.erase(); 
  }

}
class LocalAccountProvider{
  // Aquí puedes usar SQLite, SharedPreferences, o simplemente una lista en memoria para este ejemplo
  final ProfileAccountModel _localAccountTest = ProfileAccountModel(id: '1',creation: Timestamp.now(),trialEnd: Timestamp.now(),trialStart: Timestamp.now() );

  Future<ProfileAccountModel> getAccount(String idAccount) async {
    // Retorna la cuenta almacenada localmente
    // Aquí podrías cargar datos desde SQLite, Hive, etc.
    // Ejemplo ficticio:
    return _localAccountTest;
    //return _localAccount;
  }
}
class LocalCatalogueProvider {
  // Aquí puedes usar SQLite, SharedPreferences, o simplemente una lista en memoria para este ejemplo
  final List<ProductCatalogue> _localProducts = [];

  Future<List<ProductCatalogue>> getCatalogueProducts() async {
    // Retorna los productos almacenados localmente
    // Aquí podrías cargar datos desde SQLite, Hive, etc.
    // Ejemplo ficticio:
    return [
      ProductCatalogue(description: 'Gaseosa Coca cola 1L',favorite: true,sales: 5,salePrice: 100.0,creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()),
      ProductCatalogue(description: 'Gaseosa Pepsi 500 ml',salePrice: 100.0,creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()),
      ProductCatalogue(description: 'Gaseosa Fanta 1L',salePrice: 100.0,creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()),
    ];
    //return _localProducts;
  }
  void deleteProduct(String productId) {
    // Elimina un producto de la lista local
    _localProducts.removeWhere((product) => product.id == productId);
  }

  Future<void> saveCatalogueProducts(List<ProductCatalogue> products) async {
    _localProducts.clear();
    _localProducts.addAll(products);
  }
}