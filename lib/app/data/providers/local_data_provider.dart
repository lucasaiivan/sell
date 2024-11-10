

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/catalogo_model.dart';

class LocalCatalogueProvider {
  // Aquí puedes usar SQLite, SharedPreferences, o simplemente una lista en memoria para este ejemplo
  final List<ProductCatalogue> _localProducts = [];

  Future<List<ProductCatalogue>> getCatalogueProducts() async {
    // Retorna los productos almacenados localmente
    // Aquí podrías cargar datos desde SQLite, Hive, etc.
    // Ejemplo ficticio:
    return [
      ProductCatalogue(description: 'Gaseosa Coca cola 1L',salePrice: 100.0,creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()),
      ProductCatalogue(description: 'Gaseosa Pepsi 500 ml',salePrice: 100.0,creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()),
      ProductCatalogue(description: 'Gaseosa Fanta 1L',salePrice: 100.0,creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()),
    ];
    return _localProducts;
  }

  Future<void> saveCatalogueProducts(List<ProductCatalogue> products) async {
    _localProducts.clear();
    _localProducts.addAll(products);
  }
}