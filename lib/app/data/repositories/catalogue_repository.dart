
// readme : Implementar los metodos definidos en el repositorio

import '../../domain/entities/catalogo_model.dart';
import '../../domain/repositories/catalogue_repository.dart';
import '../providers/firebase_data_provider.dart';
import '../providers/local_data_provider.dart';

class CatalogueRepositoryImpl implements CatalogueRepository {

  // proveedores disponibles
  final FirebaseCatalogueProvider firebaseDataProvider; 
  final LocalCatalogueProvider localProvider;

  CatalogueRepositoryImpl(this.firebaseDataProvider,this.localProvider);

  @override
  Future<List<ProductCatalogue>> getCatalogueList(String id) async {

    // obtengo los datos del preoveedor [Firebase]
    return firebaseDataProvider.getCatalogueProducts(id);
  }
  @override
  Stream<List<ProductCatalogue>> getCatalogueListStream(String id) {
    // obtengo los datos del preoveedor [ stream Firebase]
    return firebaseDataProvider.getCatalogueProductsStream(id);
  }

  @override
  Stream<List<ProductCatalogue>> getCatalogueLocalStream(String idAccount) async* {
    // Transforma los datos locales en un Stream.
    yield await localProvider.getCatalogueProducts();
  }
  
  @override
  Future<List<ProductCatalogue>> getCatalogueLocalList(String id) {
    // obtengo los datos del preoveedor [Local]
    return localProvider.getCatalogueProducts();
  }
  
  @override
  void deleteProduct( String idAccount, String productId ) async {
    try {
      // Elimina el producto de Firestore usando su id
      await firebaseDataProvider.deleteProduct(idAccount:idAccount, productId: productId);
    } catch (e) {
      throw Exception('Error al eliminar el producto: $e');
    }
  }

  // Otros métodos para agregar, actualizar y eliminar productos localmentex
  //  @override ...
    
}