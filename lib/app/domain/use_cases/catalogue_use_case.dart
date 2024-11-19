
//  [ case use ]
//  Esta carpeta contiene los Casos de Uso de la aplicación, 
// que representan la lógica de negocio y las reglas de la aplicación de acuerdo con el patrón de arquitectura Clean Architecture

import 'package:sell/app/domain/entities/catalogo_model.dart'; 
import '../../data/providers/firebase_data_provider.dart'; 
import '../../data/providers/local_data_provider.dart';
import '../../data/repositories/catalogue_repository_impl.dart';
import '../repositories/catalogue_repository.dart';

class GetCatalogueUseCase { 

  final CatalogueRepository catalogueRepository;  

  GetCatalogueUseCase() : catalogueRepository = CatalogueRepositoryImpl(FirebaseCatalogueProvider(),LocalCatalogueProvider());


  // future : obtener lista de productos del catalogo
  Future<List<ProductCatalogue>> getProducts({required String id}) async { 

    // logic business
    // ...

    // return : obtenemos los datos y devolvemos la lista de productos
    //return await catalogueRepository.getCatalogueLocalList(id);
    return await catalogueRepository.getCatalogueList(id);
  }
  // stream : obtener la lista de categorias del catalogo
  Stream<List<Category>> getCategoriesStream({required String idAccount}) {
    // logic business
    // ...

    // return : obtenemos los datos y devolvemos el stream de categorias
    return catalogueRepository.getCategoryListStream(idAccount);
  }
  // future : obtener lista de categorias del catalogo
  Future<List<Category>> getCategories({required String idAccount}) async { 

    // logic business
    // ...

    // return : obtenemos los datos y devolvemos la lista de categorias
    return await catalogueRepository.getCategoriesList(idAccount);
  }
  // stream : obtener los proveedores del catalogo
  Stream<List<Provider>> getProviderListStream({required String idAccount}) {
    // logic business
    // ...

    // return : obtenemos los datos y devolvemos el stream de proveedores
    return catalogueRepository.getProviderListStream(idAccount);
  }

  // stream : obtener stream con los productos del catalogo
  Stream<List<ProductCatalogue>> catalogueStream(String idAccount) {
    // logic business
    // ...

    // return : obtenemos los datos y devolvemos el stream de productos
    return catalogueRepository.getCatalogueListStream(idAccount);
    //return catalogueRepository.getCatalogueLocalStream(idAccount);
  } 

  // Método que elimina el producto del catalogo
  Future<void> productCatalogueDelete({required String productId,required String idAccount}) async {
    catalogueRepository.deleteProduct(idAccount,productId);
  }
 

  Future<void> addProduct(String idAccount,ProductCatalogue product) async {
    return await catalogueRepository.addProduct(idAccount,product);
  }
  Future<void> updateProduct(String idAccount,ProductCatalogue product) async {
    return await catalogueRepository.updateProduct(idAccount,product );
  }
  Future<void> deleteProduct(String idAccount,String productId) async {
    return await catalogueRepository.deleteProduct(idAccount,productId);
  }
  Future<void> incrementStock(String idAccount,String productId,int quantity) async {
    return await catalogueRepository.incrementStock(idAccount,productId,quantity);
  }
  Future<void> decrementStock(String idAccount,String productId,int quantity) async {
    return await catalogueRepository.decrementStock(idAccount,productId,quantity);
  }
  Future<void> incrementSales(String idAccount,String productId,int quantity) async {
    return await catalogueRepository.incrementSales(idAccount,productId,quantity);
  }
 
 // void : register : registra el precio publico de un producto
  Future<void> registerPricePublic(String idProduct,ProductPrice productPrice) async {
    return await catalogueRepository.registerPricePublic(idProduct,productPrice);
  }

  // void : update : actualiza los datos de un producto
  Future<void> updateProductFromMap(String idAccount,String idProduct,Map values) async {
    return await catalogueRepository.updateProductFromMap(idAccount,idProduct,values);
  }

  // future : obtener producto de la DB publica
  Future<Product> getProductPublic(String productId) async {
    return await catalogueRepository.getProductPublic(productId);
  }
  // eliminar categoria
  Future<void> deleteCategory({required String idAccount,required String idCategory}) async {
    return await catalogueRepository.deleteCategory(idAccount,idCategory);
  }
  

}
  
 

 