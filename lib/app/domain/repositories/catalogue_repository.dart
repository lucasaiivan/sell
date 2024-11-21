// readme : definir los metodos que se van a utilizar en el repositorio 
import 'package:sell/app/domain/entities/catalogo_model.dart';

abstract class CatalogueRepository { 

  Future<List<ProductCatalogue>> getCatalogueList(String id);
  Future<List<ProductCatalogue>> getCatalogueLocalList(String id);
  Future<List<Category>> getCategoriesList(String idAccount);
  Stream<List<Category>> getCategoryListStream(String idAccount);
  Stream<List<Provider>> getProviderListStream(String idAccount);
  Stream<List<ProductCatalogue>> getCatalogueListStream(String id);
  Stream<List<ProductCatalogue>> getCatalogueLocalStream(String id);
  Future<Product> getProductPublic(String productId);
 
  Future<void> decrementStock(String idAccount,String productId,int quantity); 
  Future<void> incrementStock(String idAccount,String productId,int quantity); 
  Future<void> incrementSales(String idAccount,String productId,int quantity);
  Future<void> incrementFollowersProductPublic(String idProduct);

  Future<void> createProductPublic(Product product);
  Future<void> registerPriceProductPublic( ProductPrice price);
  Future<void> addProduct(String idAccount,ProductCatalogue product);

  Future<void> updateProductFromMap(String idAccount,String idProduct,Map values);
  Future<void> updateProvider(String idAccount,Provider provider);
  Future<void> updateCategory(String idAccount,Category category);
  Future<void> updateProduct(String idAccount,ProductCatalogue product);

  Future<void> deleteProduct(String idAccount,String productId);
  Future<void> deleteProvider(String idAccount,Provider provider);
  Future<void> deleteCategory(String idAccount,String idCategory);
}