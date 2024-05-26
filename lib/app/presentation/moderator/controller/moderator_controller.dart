
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../../../core/routes/app_pages.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';
import '../view/moderator_view.dart';

class ModeratorController extends GetxController {
  
  // VARIABLES //

  // controllers
  final HomeController homeController = Get.find<HomeController>();
  // estado de carga de la base de datos
  final RxBool loading = true.obs;
  set setLoading(bool value) => loading.value = value;
  bool get getLoading => loading.value;
  // lista de productos filtrados
  final RxList<Product> productsFiltered = <Product>[].obs;
  set setProductsFiltered(List<Product> value) => productsFiltered.addAll(value);
  List<Product> get getProductsFiltered => productsFiltered;
  // lista de todos los productos
  final List<Product> products = <Product>[].obs; 
  set setProducts(List<Product> value) => products.addAll(value); 
  List<Product> get getProducts => products; 
  // texto de filtro
  final RxString filterText = 'Filtrar'.obs;
  set setFilterText(String value) => filterText.value = value;
  String get getFilterText => filterText.value;
  // lista de id (correo) de creadores de productos 
  final Map<String, int> idUserCreation = <String, int>{}; 
  Map<String, int> get getIdUserCreation => idUserCreation;
  void addIdUserCreations({required String correo}) {
    if (idUserCreation.containsKey(correo)) {
      idUserCreation[correo] = idUserCreation[correo]! + 1;
    } else {
      idUserCreation[correo] = 1;
    } 
  }
  // lista de marcas de los productos
  bool viewBrands = false;
  final List<Mark> marks = <Mark>[];
  set setMarks(List<Mark> value) => marks.addAll(value);
  List<Mark> get getMarks => marks; 
  // lista de reportes de los productos
  bool viewReports = false;
  final List<ReportProduct> reports = <ReportProduct>[];
  set setReports(List<ReportProduct> value) => reports.addAll(value);
  List<ReportProduct> get getReports => reports;  

// GETTERS
   int get totalProducts => products.length;
  int get totalVerifiedProducts => products.where((element) => element.verified).length;
  int get totalUnverifiedProducts => products.where((element) => !element.verified).length;
  int get totalProductsNoData => products.where((element) => element.code == '' || element.idMark == '' || element.description == '' || element.image == '' ).length;
  Product? getProduct({required String id}) { 
    // description : obtenemos un producto por su id
    for (var element in products) {
      if (element.id == id) {
        return element;
      }
    }
    return null;
  }
  
  // DATA SOURCE
  void loadDB() {
    // default values
    setLoading = true; 
    products.clear();
    // description : obtenemos toda la dabase de los productos
    Database.readProductsFuture().then((value) {  
      for (var element in value.docs) { 
        try {
          final Product product = Product.fromMap(element.data());
          // code 
          if(product.code==''){
            product.code = element.id;
          }
          // add : agregamos los productos a la lista total
          products.add(product);  
          // add : agregamos los id de los creadores de productos
          if(product.idUserCreation!=''){
            addIdUserCreations(correo: product.idUserCreation);
          }
        } catch (e) {}
      } 
      setLoading = false; 
      filterProducts();
    });
  }
  void loadMarks(){
    //  values default 
    getMarks.clear();
    // description : obtenemos toda la dabase de las marcas
    Database.readListMarksFuture().then((value) { 
      for (var element in value.docs) { 
        try {
          final Mark mark = Mark.fromMap(element.data());
          // add : agregamos las marcas a la lista 
          getMarks.add(mark);
        } catch (e) {
          // message : 'Error al cargar las marcas' 
        }
      }
      update();
    });
  }
  void loadReports(){
    // default 
    getReports.clear();
    // description : obtenemos toda la dabase de los reportes
    Database.readReportsProductFuture().then((value) { 
      for (var element in value.docs) { 
        try {
          final ReportProduct report = ReportProduct.fromMap(element.data());
          // add : agregamos los reportes a la lista 
          getReports.add(report);
        } catch (e) {
          // message : 'Error al cargar los reportes' 
        }
      }
      update();
    });
  }
  
  // FUNCTION  
  void filterProducts({bool? verified,String? idUserCreator,bool? noData}) {
    // description : filtramos la lista de productos con los parametros dados
    // advertencia : solo se puede filtrar por un parametro a la vez 
    
    // var 
    final List<Product> newList = [];
    // default values 
    viewReports = false;
    viewBrands = false;
    getProductsFiltered.clear();
    
    if (verified==null && idUserCreator==null && noData==null) { 
      // add : agregamos todos los productos
      newList.addAll(getProducts);  
    } else { 
      // add : agregamos los productos filtrados
      for (var element in getProducts) {
        // verified
        if ( verified != null) {
          if (element.verified == verified) {
            newList.add(element); 
          } 
        }
        // idUserCreator
        if (idUserCreator != null) {
          if (element.idUserCreation == idUserCreator) {
            newList.add(element); 
          }
        }
        // noData
        if (noData != null) {
          if (element.code == '' || element.idMark == '' || element.description == '' || element.image == '' ) {
            newList.add(element); 
          }
        }
      }
      
    
    }

    // set 
    setProductsFiltered = newList; 

    update();
     
  } 
  void deleteReport({required String id}) {
    // description : eliminamos el reporte
    Database.refFirestoreReportProduct().doc(id).delete().then((value) {
      loadReports();
    });
  }
  
  void createDbBackup() {
    // description : creamos una copia de seguridad de un producto
    for (var element in getProducts) {
      // firebase : creamos una copia de seguridad
      Database.refFirestoreProductPublicBackup().doc(element.id).set(element.toJson(), SetOptions(merge: true));
    }
    // description : creamos una copia de seguridad de las marcas
    for (var element in getMarks) {
      // firebase : creamos una copia de seguridad
      Database.refFirestoreBrandsBackup().doc(element.id).set(element.toJson(), SetOptions(merge: true));
    }
  }
  /* void refactorDB() {
    // description : volvemos a actualizar cada producto en la base de datos con los mismo datos actuales
    for (var element in getProducts) {
      // actualizamos el producto nombre de la marca 
      if(element.idUserCreation==''){ 
        element.idUserCreation = 'logica.booleana.2019@gmail.com';

      }
      // firebase : actualizamos el producto
      Database.refFirestoreProductPublic().doc(element.id).set(element.toJson(), SetOptions(merge: true));
    }
  }
  String getNameMark({required String id}) {
    // description : obtenemos el nombre de la marca por su id
    for (var element in getMarks) {
      if (element.id == id) {
        return element.name;
      }
    }
    return '';
  }  */
  
  // DIALOG
  void showSeachDialog() {
    // description : dialogo de busqueda de productos
    Get.dialog(const ViewSeachProductsCataloguie());
  }
  void showEditBrandDialogFullscreen({required Mark mark}) {
    // description : dialogo de edicion de marca
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: CreateMark(mark: mark),
        );
      },
    );
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
    loadMarks();
    loadReports();
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