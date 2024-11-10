
import 'package:sell/app/domain/entities/catalogo_model.dart';

abstract class CatalogueRepository {
  Future<List<ProductCatalogue>> getCatalogueList(String id);
  Stream<List<ProductCatalogue>> getCatalogueListStream(String id);
}