
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

  RxInt updateCount = 0.obs; 
  set setUpdateCount(int value) => updateCount.value = value;
  int get getUpdateCount => updateCount.value;

  // controllers
  final HomeController homeController = Get.find<HomeController>();
  // estado de carga de la base de datos
  final RxBool loading = true.obs;
  set setLoading(bool value) => loading.value = value;
  bool get getLoading => loading.value;
  // datos de usuario filtrado
  Map<String, dynamic> userFilter = {'title':'Moderador','id':''};

  // lista de productos filtrados
  bool viewProducts = true;
  final RxList<Product> productsFiltered = <Product>[].obs;
  set setProductsFiltered(List<Product> value) => productsFiltered.addAll(value);
  List<Product> get getProductsFiltered => productsFiltered;
  // lista de todos los productos
  final List<Product> products = <Product>[].obs; 
  set setProducts(List<Product> value) => products.addAll(value); 
  List<Product> get getProducts => products; 
  updateProducts({required Product product}){
    bool noExist = false;
    // description : actualizamos un producto en la lista original
    for (var i = 0; i < getProducts.length; i++) {
      if (getProducts[i].id == product.id) {
        getProducts[i] = product;
        noExist = true;
        break;
      }
    } 
    // actualizamos la lista de productos filtrados
    for (var i = 0; i < getProductsFiltered.length; i++) {
      if (getProductsFiltered[i].id == product.id) {
        getProductsFiltered[i] = product;
        noExist = true;
        break;
      }
    }
    // si no existe el producto lo agregamos
    if (!noExist) {
      getProducts.insert(0, product);
      getProductsFiltered.insert(0, product);
    }
    update();
  }
  // texto de filtro
  final RxString filterText = 'Filtrar'.obs;
  set setFilterText(String value) => filterText.value = value;
  String get getFilterText => filterText.value;
  // lista de id (correo) de los crearon y actualizaron productos
  final Map<String,String> usersMap = {};  
     
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
  int get totalReviewedProducts => products.where((element) => element.reviewed && !element.verified).length;
  int get totalNotReviewedProducts => products.where((element) => !element.reviewed && !element.verified).length;
  int get totalProductsNoData => products.where((element) => element.code == '' || element.idMark == '' || element.description == '' || element.image == '' ).length;
  int get totalProductsFavorite => products.where((element) => element.favorite).length;
  int totalProductsCreatedTodayByUser({required String id}){
    // description : obtenemos el numero de productos creados en el dia actual por el usuario (admin)
    // var
    int count = 0; 
    // Obtenemos la fecha actual del dispositivo
    DateTime now = Timestamp.now().toDate();
    for (var element in products) {
      if (element.idUserCreation == id) {
        // var
        bool isToday = element.creation.toDate().year == now.year && element.creation.toDate().month == now.month && element.creation.toDate().day == now.day;
        if (isToday) {
          count++;
        }
      }
    }
    return count;
  }
  int totalProductsUpdateTodayByUser({required String id}){
    // description : obtenemos el numero de productos actualizados en el dia actual por el usuario (admin)
    // var
    int count = 0; 
    // formateamos la marca de tiempo actual 
    DateTime now = Timestamp.now().toDate(); 

    for (var element in products) {
      if (element.idUserUpgrade ==  id) {
        // var   
        bool isToday = element.upgrade.toDate().year == now.year && element.upgrade.toDate().month == now.month && element.upgrade.toDate().day == now.day;
        if ( isToday) {
          count++;
        }
      }
    }
    return count;
  }
  int totalProductsCreatedCurrentMonthByUser({required String id}){
    // description : obtenemos el numero de productos creados en el mes actual
    // var
    int count = 0; 
    // Obtenemos la fecha actual del dispositivo
    DateTime now = Timestamp.now().toDate();
    for (var element in products) {
      if (element.idUserCreation == id) {
        // var
        bool isCurrentMonth = element.creation.toDate().year == now.year && element.creation.toDate().month == now.month;
        if (isCurrentMonth) {
          count++;
        }
      }
    }
    return count;
  }
  int totalProductsUpdateCurrentMonthByUser({required String id}){
    // description : obtenemos el numero de productos actualizados en el mes actual
    // var
    int count = 0; 
    // Obtenemos la fecha actual del dispositivo
    DateTime now = Timestamp.now().toDate();
    for (var element in products) {
      if (element.idUserUpgrade == id) {
        // var
        bool isCurrentMonth = element.upgrade.toDate().year == now.year && element.upgrade.toDate().month == now.month;
        if (isCurrentMonth) {
          count++;
        }
      }
    }
    return count;
  }
  int totalProductsCreatedByUser({required String id}){
    // description : obtenemos el numero de productos creados por el usuario (admin) 
    // var
    int count = 0; 
    for (var element in products) {
      if (element.idUserCreation == id) {
        count++;
      }
    }
    return count;
  }
  int totalProductsUpdateByUser({required String id}){
    // description : obtenemos el numero de productos actualizados por el usuario (admin) 
    // var
    int count = 0; 
    for (var element in products) {
      if (element.idUserUpgrade == id) {
        count++;
      }
    }
    return count;
  }
  Product? getProduct({required String id}) { 
    // description : obtenemos un producto por su id
    for (var element in products) {
      if (element.id == id) {
        return element;
      }
    }
    return null;
  }
  int totalNumberOfBrandedProducts({required String idBrand}){
    // description : obtenemos el numero de productos de una marca
    int count = 0;
    for (var element in products) {
      if (element.idMark == idBrand) {
        count++;
      }
    }
    return count;
    
  }
  String getNameMark({required String id}) {
    // description : obtenemos el nombre de la marca por su id
    for (var element in getMarks) {
      if (element.id == id) {
        return element.name;
      }
    }
    return '';
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
          // obtenemos el id del usuario que creo y actualizo el producto
          if(product.idUserCreation!='' ){
            usersMap [product.idUserCreation] = product.idUserCreation;
          }
          if(product.idUserUpgrade!='' ){
            usersMap [product.idUserUpgrade] = product.idUserUpgrade;
          }

        } catch (e) {}
      } 

      // obtenemos los datos del usuario actual por defecto
      loadFilteredProductsByUser(idUser: userFilter['id']); 
      setLoading = false; 
      // filtramos los productos
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
  void loadFilteredProductsByUser({ String idUser = ''}) {
    // description : filtramos los datos del usuario seleccionado o por defecto el usuario actual

    // comprobamos si el usuario es el actual
    if (idUser == '' || idUser == homeController.getProfileAdminUser.email) {
      userFilter = {'title':'Moderador','id': homeController.getProfileAdminUser.email};
    }else{
      userFilter = {'title':'Usuario selecionado','id': idUser};
    }

  }
  // FUNCTION  
  void filterProducts({bool? verified,bool?reviewed,String? idUserCreator,String? idUserUpdate,bool? noData,bool? favorite}) {
    // description : filtramos la lista de productos con los parametros dados
    // advertencia : solo se puede filtrar por un parametro a la vez 
    
    // var 
    final List<Product> newList = [];
    // default values 
    viewReports = false;
    viewBrands = false;
    viewProducts =true;
    getProductsFiltered.clear();
    if(idUserCreator==null && idUserUpdate==null  ){
      loadFilteredProductsByUser();
    }
    
    if (verified==null && idUserCreator==null && idUserUpdate==null && noData==null && reviewed==null && favorite==null ) { 
      // add : agregamos todos los productos
      newList.addAll(getProducts);  
    } else { 
      // add : agregamos los productos filtrados
      for (var element in getProducts) {
        // verified
        if ( verified != null &&  idUserCreator==null && noData==null && reviewed==null && idUserUpdate==null && favorite==null) {
          if (element.verified == verified) {
            newList.add(element); 
          } 
        }
        // usuarios creadores
        if (idUserCreator != null && verified == null && noData == null && reviewed == null && idUserUpdate == null && favorite==null) {
          if (element.idUserCreation == idUserCreator) {
            newList.add(element);  
          }
        }
        //  usuarios actualizadores
        if (idUserUpdate != null && verified == null && noData == null && reviewed == null && idUserCreator == null && favorite==null ) {
          if (element.idUserUpgrade == idUserUpdate) {
            newList.add(element); 
          }
        }
        // usuarios creadores y actualizadores
        if (idUserCreator != null && idUserUpdate != null && verified == null && noData == null && reviewed == null && favorite==null) {
          if (element.idUserCreation == idUserCreator || element.idUserUpgrade == idUserUpdate) {
            newList.add(element); 
          }
        }
        // noData
        if (noData != null && verified == null && idUserCreator == null && reviewed == null && idUserUpdate == null && favorite==null ) {
          if (element.code == '' || element.idMark == '' || element.description == '' || element.image == '' ) {
            newList.add(element); 
          }
        }
        // favorite : si es un producto destacado
        if (favorite != null && verified == null && idUserCreator == null && noData == null && reviewed == null && idUserUpdate == null) {
          if (element.favorite == favorite) {
            newList.add(element); 
          }
        }
        // reviewed : si esta revisado
        if ( reviewed != null && verified == null && idUserCreator == null && noData == null && idUserUpdate == null && favorite==null ) {
          // conditiom : si esta revisado
          if (reviewed == true && element.reviewed == true && element.verified == false) {
            newList.add(element); 
          }else if( reviewed == false && element.reviewed == false && element.verified == false){
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
  
  // FUCTION MODERATOR //
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
  void refactorDB() {
    // description : volvemos a actualizar cada producto en la base de datos con los mismo datos actuales
    for (var element in getProducts) {
      // actualizamos el producto nombre de la marca 
      if(element.idMark==''){ 
        element.idMark = 'other'; 
        element.verified = false;
      }
      // firebase : actualizamos el producto
      Database.refFirestoreProductPublic().doc(element.id).set(element.toJson(), SetOptions(merge: true));
    }
  }
  
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
  void goToSeachProduct() {
    Get.toNamed(Routes.searchProduct, arguments: {'id': ''});
  }
  
  // OVERRIDE METHODS
  @override
  void onInit() {
    super.onInit();
    loadDB();
    loadMarks();
    loadReports();
  } 
  
}