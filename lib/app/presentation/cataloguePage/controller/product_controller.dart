
import 'dart:io'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart'; 
import '../../../core/routes/app_pages.dart'; 
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';

class ProductController extends GetxController {

  // others controllers
  final HomeController homeController = Get.find();
  final ScrollController scrollController = ScrollController();

  // state load data product
  bool _dataUploadStatusProduct = false;
  set setDataUploadStatusProduct(bool value) => _dataUploadStatusProduct = value;
  bool get getDataUploadStatusProduct => _dataUploadStatusProduct;

  // product 
  ProductCatalogue _product = ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
  set setProduct(ProductCatalogue product) => _product = product;
  ProductCatalogue get getProduct => _product;

  // - productos de la misma cátegoria -//
  final RxList<ProductCatalogue> _listProductsCategory = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getListProductsCategory => _listProductsCategory;
  set setListProductsCategory(List<ProductCatalogue> value) => _listProductsCategory.value = value;

  // - productos del mismo proveedor -//
  final RxList<ProductCatalogue> _listProductsProvider = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getListProductsProvider => _listProductsProvider;
  set setListProductsProvider(List<ProductCatalogue> value) => _listProductsProvider.value = value;

  // - productos de la misma marca -//
  final RxList<ProductCatalogue> _listProductsMark = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getListProductsMark => _listProductsMark;
  set setListProductsMark(List<ProductCatalogue> value) => _listProductsMark.value = value;

  //-  mark  -//
  Mark _markSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setMarkSelected(Mark value) { 
    _markSelected = value;
    getProduct.idMark = value.id;
    getProduct.nameMark = value.name;
    update(['updateAll']);
  } 
  Mark get getMarkSelected => _markSelected;
  
  // - prices of product publicated for other users (cuentas)
  final RxList<ProductPrice> _listPricesForProduct = <ProductPrice>[].obs;
  List<ProductPrice> get getListPricesForProduct => _listPricesForProduct;
  set setListPricesForProduct(List<ProductPrice> value) => _listPricesForProduct.value = value;  

  //- variable para saber si el producto ya esta o no en el cátalogo -//
  bool _itsInTheCatalogue = false;
  set setItsInTheCatalogue(bool value) => _itsInTheCatalogue = value;
  bool get getItsInTheCatalogue => _itsInTheCatalogue;
  //-  estado de carga de datos -//
  bool _loadingData = false;
  set setLoadingData(bool value) => _loadingData = value;
  bool get getLoadingData => _loadingData; 
  // ---------------------------- //
  // -------- NAVIGATION -------- //
  // ---------------------------- //
  void toNavigationProductEdit() {
    Get.offAndToNamed(Routes.editProduct, arguments: {'product': getProduct.copyWith()});
  } 

  //-------------------------------//
  // ---------- FUCTIONS ----------//
  //-------------------------------//
  isCatalogue() {
    setItsInTheCatalogue = false;
    // return : si el producto esta en el catalogo
    for (var element in homeController.getCataloProducts) {
      if (element.id == getProduct.id) {
        // get values
        setItsInTheCatalogue = true;
        setProduct = element.copyWith();
        update(['all']);
      }
    }
  } 
  void deleteProductInCatalogue() async{ 

    // showDialog : dialogo de carga de eliinacion 
    showDialog(
      context: Get.context!,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
    
    
    // firebase : eliminar registro de precio de la base de datos publica
    await Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(homeController.getProfileAccountSelected.id).delete();
    // firebase : elimina el producto del cátalogo de la cuenta
    await Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id)
      .doc(getProduct.id)
      .delete()
      .whenComplete(() {
        // eliminar localmente de la lista de productos del cátalogo
        homeController.getCataloProducts.removeWhere((element) => element.id == getProduct.id);
        // Firebase : descontamos el valor de los seguidores del producto
        if (getProduct.followers > 0){
          Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(-1)});
        }  
        // volvemos a navegar a la misma pantalla para que se actualice la vista
        loadData(product: getProduct);
        
        Get.back();
      })
      .onError((error, stackTrace) => Get.back())
      .catchError((ex) => Get.back());
  }
  // ---------------------------- //
  // ---------- LOGIC ----------- //
  // ---------------------------- //
  void setTheme() { 
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black, 
        systemNavigationBarDividerColor: Colors.black,
      ));
    }
  }
  void setThemeDefault(){
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Get.theme.scaffoldBackgroundColor,
        systemNavigationBarDividerColor: Get.theme.scaffoldBackgroundColor,
      ));
    }
  } 
  // ---------------------------- //
  // ------- Data Source -------- //
  // ---------------------------- //
  void loadData({required ProductCatalogue product}){
    
    //  set : copiamos el producto para evitar problemas de referencia en memoria con el producto original
    setProduct = product.copyWith(); 
    // comprobamos si el producto esta en el catalogo de la cuenta y obtenemos los datos
    isCatalogue();
    readListPricesForProduct(); 
    getProductByCategory(idCategory: getProduct.category);
    getProductByProvider(idProvider: getProduct.provider);
    getProductByMark(idMark: getProduct.idMark); 
    // obtenemos los datos del producto de la base de datos global
    getDataProduct(id: getProduct.id);
  }
  void getDataProduct({required String id}) {
    // function : obtiene los datos del producto de la base de datos global 
    if (id != '') {
      print('------------------------- Firebase db public product : doc -----------------------------------');
      // firebase : obtiene los datos del producto
      Database.readProductPublicFuture(id: id).then((value) {
        //  get
        Product product = Product.fromMap(value.data() as Map);  

        //  set
        getProduct.updateData(product: product); 
        setDataUploadStatusProduct = true;
        // update ui  
        update();
        
      }).catchError((error) {
        setDataUploadStatusProduct = true;

      }).onError((error, stackTrace) {
        setDataUploadStatusProduct = true;
      });
    }
  }
  void getProductByCategory({required idCategory}){
    // clean 
    getListProductsCategory.clear();
    // function : obtiene los productos de la misma marca
    for (var element in homeController.getCataloProducts) {
      if (element.category == idCategory && element.category!='') {
        getListProductsCategory.add(element);
      }
    }
  }
  void getProductByProvider({required idProvider}){
    // clean
    getListProductsProvider.clear();
    // function : obtiene los productos del mismo proveedor
    for (var element in homeController.getCataloProducts) {
      if (element.provider == idProvider && element.provider!='') {
        getListProductsProvider.add(element);
      }
    }
  }
  void getProductByMark({required idMark}){
    // clean
    getListProductsMark.clear();
    // function : obtiene los productos de la misma marca
    for (var element in homeController.getCataloProducts) {
      if (element.idMark == idMark && element.idMark!='') {
        getListProductsMark.add(element);
      }
    }
  }
  void readListPricesForProduct({bool limit = false}) {
    print('------------------------- Firebase db public prices : querySnapshop -----------------------------------');
    // devuelve una lista con los precios más actualizados del producto
    Database.readListPricesProductFuture(id: getProduct.id, limit: limit ? 9 : 25)
        .then((value) {
          // var
      int averagePrice = 0;
      List<ProductPrice> list = [];
      // for : recorremos los precios
      for (var element in value.docs) {
        ProductPrice price = ProductPrice.fromMap(element.data());
        list.add(price);
        averagePrice = averagePrice + price.price.toInt();
      } 
      // set
      setListPricesForProduct = list.cast<ProductPrice>();
    });
  }
  void sendReportProduct({required List reports, required String description}){

    // generate id  : code mas id de firebase 
    String id = '${getProduct.code}-${homeController.getUserAuth?.uid}';
    // function : envia un reporte del producto
    Database.refFirestoreReportProduct().doc(id).set(
      ReportProduct(
        id: id,
        idProduct: getProduct.code,
        idUserReport: homeController.getUserAuth!.uid,
        time: Timestamp.now(),
        description:description,
        reports: reports, 
      ).toJson()
    ).then((value) {
      Get.snackbar('Reporte enviado', 'Gracias por tu reporte');
    }).catchError((error) {
      Get.snackbar('Error', 'No se pudo enviar el reporte');
    });
  }
  // --------------------------- //
  // -------  @override -------- //
  // --------------------------- //
  @override
  void onReady() {
    super.onReady();
    setTheme();
  }
  @override
  void onInit() {
    super.onInit();  

    // obtenemos el producto por parametro
    ProductCatalogue productFinal = Get.arguments['product'] ?? ProductCatalogue(documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now(),upgrade: Timestamp.now(), creation: Timestamp.now());
    
    loadData(product: productFinal);
    
  }
  @override
  void onClose() {
    super.onClose();
    setThemeDefault();
  }
  
  
}