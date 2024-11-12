// readme : definir los metodos que se van a utilizar en el repositorio 
import 'package:sell/app/domain/entities/catalogo_model.dart';

abstract class CatalogueRepository {
  Future<List<ProductCatalogue>> getCatalogueList(String id);
  Future<List<ProductCatalogue>> getCatalogueLocalList(String id);

  Stream<List<ProductCatalogue>> getCatalogueListStream(String id);
  Stream<List<ProductCatalogue>> getCatalogueLocalStream(String id);


  Future<void> addProduct(String idAccount,ProductCatalogue product);
  Future<void> updateProduct(String idAccount,ProductCatalogue product);
  Future<void> deleteProduct(String idAccount,String productId);

}