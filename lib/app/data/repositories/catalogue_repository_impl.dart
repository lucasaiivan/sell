
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
  Stream<List<Category>> getCategoryListStream(String idAccount) {
    return firebaseDataProvider.getCategoriesStream(idAccount);
  }

  
  @override
  Future<void> addProduct(String idAccount,ProductCatalogue product) async {
    return await firebaseDataProvider.addProduct(idAccount,product);
  }
  
  @override
  Future<void> deleteProduct(String idAccount,String productId) async {
    return await firebaseDataProvider.deleteProduct(idAccount,productId);
  }
  
  @override
  Future<void> updateProduct(String idAccount,ProductCatalogue product) async {
    return await firebaseDataProvider.updateProduct(idAccount,product); 
  }

  
  
  @override
  Future<void> decrementStock(String idAccount, String productId, int quantity) async {
    return await firebaseDataProvider.decrementProductStock(idAccount, productId, quantity);
  }
  
  @override
  Future<void> incrementSales(String idAccount, String productId, int quantity) async {
    return firebaseDataProvider.incrementProductStockSales(idAccount, productId, quantity);
  }
  
  @override
  Future<void> incrementStock(String idAccount, String productId, int quantity) async {
    return await firebaseDataProvider.incrementProductStock(idAccount, productId, quantity);
  }
  
  @override
  Future<void> updateProductFromMap(String idAccount,String idProduct, Map values) {
    return firebaseDataProvider.updateProductCatalogueFromMap(idAccount, idProduct, values);
  }
  
  @override
  Future<void> registerPricePublic(String idProduct , ProductPrice productPrice) {
    return firebaseDataProvider.addPriceRegisterPublic(idProduct, productPrice);
  }
  
  @override
  Future<Product> getProductPublic(String productId) {
    return firebaseDataProvider.getProductPublic(productId);
  }
  
  @override
  Future<List<Category>> getCategoriesList(String idAccount) {
    return firebaseDataProvider.getCategories(idAccount);
  }
  
  @override
  Stream<List<Provider>> getProviderListStream(String idAccount) {
    return firebaseDataProvider.getProvidersStream(idAccount);
  }
  
  @override
  Future<void> deleteCategory(String idAccount, String idCategory) {
    return firebaseDataProvider.deleteCategory(idAccount, idCategory);
  }
  
 

   
  // Otros métodos para agregar, actualizar y eliminar productos localmentex
  //  @override ...
    
}