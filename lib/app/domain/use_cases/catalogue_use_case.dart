
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
 
  // void : create : crea un nuevo producto en la Data Base publica
  Future<void> createProductPublic({required Product product}) async {
    return await catalogueRepository.createProductPublic(product);
  }
  // void : update : actualiza los datos de un producto de la Data Base publica
  Future<void> updateProductPublic({required Product product}) async {
    return await catalogueRepository.createProductPublic(product);
  }

  Future<void> addProduct(String idAccount,ProductCatalogue product) async {
    return await catalogueRepository.addProduct(idAccount,product);
  }
  Future<void> updateProduct({required idAccount,required ProductCatalogue product}) async {
    return await catalogueRepository.updateProduct(idAccount,product );
  }
  Future<void> deleteProduct(String idAccount,String productId) async {
    return await catalogueRepository.deleteProduct(idAccount,productId);
  }
  // void : incrementar seguidor al producto publico
  Future<void> incrementFollowersProductPublic({required String idProduct}) async {
    return await catalogueRepository.incrementFollowersProductPublic(idProduct);
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
  Future<void> registerPriceProductPublic( {required ProductPrice price}) async {
    return await catalogueRepository.registerPriceProductPublic( price);
  }

  // void : update : actualiza los datos de un producto
  Future<void> updateProductFromMap(String idAccount,String idProduct,Map values) async {
    return await catalogueRepository.updateProductFromMap(idAccount,idProduct,values);
  }
  // void : update : actualiza los datos de una categoria
  Future<void> updateCategory({required String idAccount,required Category category}) async {
    return await catalogueRepository.updateCategory(idAccount,category);
  }
  // void : update : actualiza los datos de un proveedor
  Future<void> updateProvider({required String idAccount,required Provider provider}) async {
    return await catalogueRepository.updateProvider(idAccount,provider);
  }
  // future : obtener producto de la DB publica
  Future<Product> getProductPublic(String productId) async {
    return await catalogueRepository.getProductPublic(productId);
  }
  // eliminar categoria
  Future<void> deleteCategory({required String idAccount,required String idCategory}) async {
    return await catalogueRepository.deleteCategory(idAccount,idCategory);
  }
  // eliminar proveedor
  Future<void> deleteProvider({required String idAccount,required Provider provider}) async {
    return await catalogueRepository.deleteProvider(idAccount,provider);
  }
  

  

}
  
 

 