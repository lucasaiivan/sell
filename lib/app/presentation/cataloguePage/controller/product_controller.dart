
import 'dart:io'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart'; 
import '../../../core/routes/app_pages.dart'; 
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';

class ProductController extends GetxController {

  // others controllers
  final HomeController homeController = Get.find();

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
  // estado de carga de datos del producto
  bool _dataUploadStatusProduct = false;
  // estado de carga de datos de la marca 
  bool _dataUploadStatusMark = false; 
  // estado de carga de datos del proveedor 
  bool _dataUploadStatusProvider = false;
  // estado de carga de datos de la categoria 
  bool _dataUploadStatusCategory = false;
  // ---------------------------- //
  // -------- NAVIGATION -------- //
  // ---------------------------- //
  void toNavigationProductEdit() {
    Get.offAndToNamed(Routes.editProduct, arguments: {'product': getProduct.copyWith()});
  }
  void toNavigationProduct({required ProductCatalogue product}) { 
    Get.offAndToNamed(Routes.product, arguments: {'product':  product.copyWith() });
  }

  //-------------------------------//
  // ---------- FUCTIONS ----------//
  //-------------------------------//
  isCatalogue() {
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
  void checkDataUploadStatusProduct({bool? dataUploadStatusProduct, bool? dataUploadStatusMark, bool? dataUploadStatusProvider, bool? dataUploadStatusCategory}) {
    // descrioption : chequea si se cargaron los datos del producto, marca, proveedor y categoria
    
    // set : valores
    _dataUploadStatusProduct = dataUploadStatusProduct ?? _dataUploadStatusProduct;
    _dataUploadStatusMark = dataUploadStatusMark ?? _dataUploadStatusMark;
    _dataUploadStatusProvider = dataUploadStatusProvider ?? _dataUploadStatusProvider;
    _dataUploadStatusCategory = dataUploadStatusCategory ?? _dataUploadStatusCategory;
    // condition : comprobamos si se cargaron todos los datos necesarios del producto
    if (_dataUploadStatusProduct && _dataUploadStatusMark && _dataUploadStatusProvider && _dataUploadStatusCategory) {
      setLoadingData = false; // Los datos se cargaron
    }else{
      setLoadingData = true; // no se cargaron todos los datos no cargados
    } 

    // actualizamos la vista
    update(['updateAll']);
  }
  // ---------------------------- //
  // -------- Data Source ------- //
  // ---------------------------- //
  void getDataProduct({required String id}) {
    // function : obtiene los datos del producto de la base de datos y los carga en el formulario de edición 
    if (id != '') {
      // firebase : obtiene los datos del producto
      Database.readProductPublicFuture(id: id).then((value) {
        //  get
        Product product = Product.fromMap(value.data() as Map); 
        // commprobar que las fechas de actualización sean diferentes
        DateTime date1 = getProduct.documentUpgrade.toDate().copyWith(hour: 0,minute: 0,millisecond: 0,second: 0,microsecond: 0  );
        DateTime date2 = product.upgrade.toDate().copyWith(hour: 0,minute: 0,millisecond: 0,second: 0,microsecond: 0);
        if (date1.isBefore(date2)  ) {
          // se notifica que existen datos actualizados del producto
          //-setMessageNotification = 'Producto actualizado';
        } 

        //  set
        setProduct = getProduct.updateData(product: product);
        //loadDataFormProduct(); // carga los datos del producto en el formulario
        // actualiza la vista ui
        //checkDataUploadStatusProduct(dataUploadStatusProduct: true);
        
      }).catchError((error) {
        //checkDataUploadStatusProduct(dataUploadStatusProduct: false);
      }).onError((error, stackTrace) {
        //checkDataUploadStatusProduct(dataUploadStatusProduct: false);
      });
    }
  }
  void getProductByCategory({required idCategory}){
    // function : obtiene los productos de la misma marca
    for (var element in homeController.getCataloProducts) {
      if (element.category == idCategory && element.category!='') {
        getListProductsCategory.add(element);
      }
    }
  }
  void getProductByProvider({required idProvider}){
    // function : obtiene los productos del mismo proveedor
    for (var element in homeController.getCataloProducts) {
      if (element.provider == idProvider && element.provider!='') {
        getListProductsProvider.add(element);
      }
    }
  }
  void getProductByMark({required idMark}){
    // function : obtiene los productos de la misma marca
    for (var element in homeController.getCataloProducts) {
      if (element.idMark == idMark && element.idMark!='') {
        getListProductsMark.add(element);
      }
    }
  }
  void readListPricesForProduct({bool limit = false}) {
    // devuelve una lista con los precios más actualizados del producto
    Database.readListPricesProductFuture(id: getProduct.id, limit: limit ? 9 : 25)
        .then((value) {
      int averagePrice = 0;
      List<ProductPrice> list = [];
      for (var element in value.docs) {
        ProductPrice price = ProductPrice.fromMap(element.data());
        list.add(price);
        averagePrice = averagePrice + price.price.toInt();
      } 
      setListPricesForProduct = list.cast<ProductPrice>();
    });
  }

  // override onready
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
    //  set : copiamos el producto para evitar problemas de referencia en memoria con el producto original
    setProduct = productFinal.copyWith();
    // comprobamos si el producto esta en el catalogo de la cuenta y obtenemos los datos
    isCatalogue();
    readListPricesForProduct();
    getProductByCategory(idCategory: getProduct.category);
    getProductByProvider(idProvider: getProduct.provider);
    getProductByMark(idMark: getProduct.idMark);
    // obtenemos los datos del producto de la base de datos global
    getDataProduct(id: getProduct.id);
    
  }
  @override
  void onClose() {
    super.onClose();
    setThemeDefault();
  }
  
  
}