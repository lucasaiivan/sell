import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart'; 
import '../../../core/routes/app_pages.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';

class ModeratorController extends GetxController {

  // controllers
  final HomeController homeController = Get.find<HomeController>();

  // estado de carga de la base de datos
  final RxBool loading = true.obs;
  set setLoading(bool value) => loading.value = value;
  bool get getLoading => loading.value;
  // lista de productos filtrados
  final List<Product> productsFiltered = <Product>[];
  set setProductsFiltered(List<Product> value) => productsFiltered.addAll(value);
  List<Product> get getProductsFiltered => productsFiltered;
  // lista de todos los productos
  final List<Product> products = <Product>[].obs; 
  set setProducts(List<Product> value) => products.addAll(value); 
  List<Product> get getProducts => products;
  // list de productos verificados filtrados
  final List<Product> productsFilteredVerified = <Product>[];
  set setProductsFilteredVerified(List<Product> value) => productsFilteredVerified.addAll(value);
  List<Product> get getProductsFilteredVerified => productsFilteredVerified;
  // list de productos filtrados no verificados
  final List<Product> productsFilteredNotVerified = <Product>[];
  set setProductsFilteredNotVerified(List<Product> value) => productsFilteredNotVerified.addAll(value);
  List<Product> get getProductsFilteredNotVerified => productsFilteredNotVerified;
  // lista de productos creados por el usuario
  final List<Product> productsUser = <Product>[];
  set setProductsUser(List<Product> value) => productsUser.addAll(value);
  List<Product> get getProductsUser => productsUser;
  // texto de filtro
  final RxString filterText = 'Filtrar'.obs;
  set setFilterText(String value) => filterText.value = value;
  String get getFilterText => filterText.value;

  // DATA SOURCE
  void loadDB() {
    // description : obtenemos toda la dabase de los productos
    Database.readProductsFuture().then((value) {  
      for (var element in value.docs) { 
        try {
          final Product product = Product.fromMap(element.data());
          // add : agregamos los productos a la lista total
          products.add(product);
          // add : agregamos los productos a la lista de productos filtrados
          if (product.verified) {
            productsFilteredVerified.add(product);
          } else {
            productsFilteredNotVerified.add(product);
          }
          // add : agregamos los productos a la lista de productos creados por el usuario
          if (product.idUserCreation ==  homeController.getProfileAdminUser.email) {
            productsUser.add(product);
          }
        } catch (e) {}
      }
      setLoading = false;
      update();
    });
  }
  // FUNCTION  
  void filterProducts({required String id}) {
     
  }
  
  // NAVIGATION
  void goToProductEdit(Product product) { 
    // item
    ProductCatalogue productCatalogue = product.convertProductCatalogue();
    for (var element in homeController.getCataloProducts) {
      if (element.id == product.id) {
        productCatalogue = element;
      }
    } 
    Get.toNamed(Routes.editProduct, arguments: {'product': productCatalogue});
  }
  
  // OVERRIDE METHODS

  @override
  void onInit() {
    super.onInit();
    loadDB();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
}