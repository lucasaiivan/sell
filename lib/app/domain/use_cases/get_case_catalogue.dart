
//  [ case use ]
//  Esta carpeta contiene los Casos de Uso de la aplicación, 
// que representan la lógica de negocio y las reglas de la aplicación de acuerdo con el patrón de arquitectura Clean Architecture

import 'package:sell/app/domain/entities/catalogo_model.dart';
import 'package:sell/app/domain/repositories/account_repository.dart';
import '../entities/user_model.dart';
import '../repositories/catalogue_repository.dart';

class GetAccountUseCase{
  final AccountRepository catalogueRepository;
  GetAccountUseCase(this.catalogueRepository);

  // future : obtener datos de la cuenta
  Future<ProfileAccountModel> getAccount({required String idAccount}) async {
    // logic business
    // ...

    // return : obtenemos los datos de la cuenta
    return await catalogueRepository.getAccount(idAccount);
  }
}

class GetCatalogueUseCase { 
  final CatalogueRepository catalogueRepository; 
  GetCatalogueUseCase(this.catalogueRepository);

  // future : obtener lista de productos del catalogo
  Future<List<ProductCatalogue>> getProducts({required String id}) async { 

    // logic business
    // ...

    // return : obtenemos los datos y devolvemos la lista de productos
    //return await catalogueRepository.getCatalogueLocalList(id);
    return await catalogueRepository.getCatalogueList(id);
  }

  // stream : obtener stream con los productos del catalogo
  Stream<List<ProductCatalogue>> stream(String idAccount) {
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
 

}
 