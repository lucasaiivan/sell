
//  [ case use ]
//  Esta carpeta contiene los Casos de Uso de la aplicación, 
// que representan la lógica de negocio y las reglas de la aplicación de acuerdo con el patrón de arquitectura Clean Architecture

import 'package:sell/app/domain/entities/catalogo_model.dart'; 
import '../../data/providers/firebase_data_provider.dart'; 
import '../../data/providers/local_data_provider.dart';
import '../../data/repositories/catalogue_repository.dart';
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
    return await catalogueRepository.updateProduct(idAccount,product);
  }
  Future<void> deleteProduct(String idAccount,String productId) async {
    return await catalogueRepository.deleteProduct(idAccount,productId);
  }
 

}
  
 

 