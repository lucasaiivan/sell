

import 'package:sell/app/domain/entities/catalogo_model.dart';

import '../repositories/catalogue_repository.dart';

class GetCatalogueUseCase {

  final CatalogueRepository catalogueRepository;

  GetCatalogueUseCase(this.catalogueRepository);

  Future<List<ProductCatalogue>> call({required String id}) async {
    return await catalogueRepository.getCatalogueList(id);
  }

  Stream<List<ProductCatalogue>> stream(String idAccount) {
    //return catalogueRepository.getCatalogueListStream(idAccount);
    return catalogueRepository.getCatalogueListStream(idAccount);
  }
 

}
 