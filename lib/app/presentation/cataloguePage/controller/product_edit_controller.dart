import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:search_page/search_page.dart';
import 'package:sell/app/core/utils/fuctions.dart'; 
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';
import '../../moderator/controller/moderator_controller.dart'; 

class ControllerProductsEdit extends GetxController {

  // others controllers
  final HomeController homeController = Get.find();
  HomeController get getHomeController => homeController;

  // Build context
  BuildContext? context;
  BuildContext get getContext => context!;
  set setContext(BuildContext value) => context = value;

  // var : obtenemos el precio de venta al publico original para determinar si se actualizo
  double priceSaleOriginal = 0.0;

  // datos del producto estan actualizados
  bool _dataProductUpdate = false;
  set setDataProductUpdate(bool value) => _dataProductUpdate = value;
  bool get getDataProductUpdate => _dataProductUpdate;

  // var : message notification
  String _messageNotification = '';
  set setMessageNotification(String value) => _messageNotification = value;
  String get getMessageNotification => _messageNotification;

  // var style
  Color colorLoading = Colors.blue; 
  final Color colorButton = Colors.blue; 
  bool darkMode = false; 

  // var : TextFormField formKey
  GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> markFormKey = GlobalKey<FormState>(); 
  GlobalKey<FormState> purchasePriceFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> salePriceFormKey = GlobalKey<FormState>(); 
  GlobalKey<FormState> quantityStockFormKey = GlobalKey<FormState>(); 
 

  // state internet
  bool connected = false;
  set setStateConnect(bool value) {
    connected = value;
    update(['updateAll']);
  }

  bool get getStateConnect => connected;

  // ultimate selection mark
  static Mark _ultimateSelectionMark = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setUltimateSelectionMark(Mark value) => _ultimateSelectionMark = value;
  Mark get getUltimateSelectionMark => _ultimateSelectionMark;
 

  // state account auth
  bool _accountAuth = false;
  set setAccountAuth(value) {
    _accountAuth = value;
    update(['updateAll']);
  }

  bool get getAccountAuth => _accountAuth;

  // text appbar
  String _textAppbar = 'Editar';
  set setTextAppBar(String value) => _textAppbar = value;
  String get getTextAppBar => _textAppbar;

  // variable para saber si el producto ya esta o no en el cátalogo
  bool _itsInTheCatalogue = false;
  set setItsInTheCatalogue(bool value) => _itsInTheCatalogue = value;
  bool get getItsInTheCatalogue => _itsInTheCatalogue;
 

  // variable para editar el documento en modo de moderador
  bool _editModerator = false;
  set setEditModerator(bool value) {
    _editModerator = value;
    update(['updateAll']);
  }

  bool get getEditModerator => _editModerator;

  // producto seleccionado
  ProductCatalogue _product = ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
  set setProduct(ProductCatalogue product) => _product = product;
  ProductCatalogue get getProduct => _product;

  // nuevo producto encontrado en la DB Global para actualizar
  Product _productPublicUpdate = Product(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setProductPublicUpdate(Product product) {
    _productPublicUpdate = product;
    setProductPublicUpdateStatus = true;
    setMessageNotification = 'Producto encontrado con este código';
    updateAll();
  }
  Product get getProductPublicUpdate => _productPublicUpdate;
  bool productPublicUpdate = false; 
  bool get getProductPublicUpdateStatus => productPublicUpdate;
  set setProductPublicUpdateStatus(bool value) => productPublicUpdate = value;

  // TextEditingController
  TextEditingController controllerTextEditDescripcion = TextEditingController();
  TextEditingController controllerTextEditMark = TextEditingController(); 
  TextEditingController controllerTextEditProvider = TextEditingController();
  TextEditingController controllerTextEditCategory = TextEditingController();
  TextEditingController controllerTextEditQuantityStock = TextEditingController();
  TextEditingController controllerTextEditAlertStock = TextEditingController();
  MoneyMaskedTextController controllerTextEditPrecioVenta = MoneyMaskedTextController(leftSymbol: '\$');
  MoneyMaskedTextController controllerTextEditPrecioCosto = MoneyMaskedTextController(leftSymbol: '\$');

  // description
  String _description = '';
  set setDescription(String value) {
    _description = value;
    getProduct.description = value;
    controllerTextEditDescripcion.text = value;
    update(['updateAll']);
  }
  get getDescription => _description;

  // mark
  Mark _markSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setMarkSelected(Mark value) {
    controllerTextEditMark.text = value.name;
    _markSelected = value;
    getProduct.idMark = value.id;
    getProduct.nameMark = value.name;
    update(['updateAll']);
  }

  Mark get getMarkSelected => _markSelected;

  // marcas
  List<Mark> _marks = [];
  set setMarks(List<Mark> value) => _marks = value;
  List<Mark> get getMarks => _marks;

  // supplier
  Provider _provider = Provider();
  set setProvider(Provider value) {
    _provider = value;
    controllerTextEditProvider.text = value.name; // actualizamos el textfield porque no se actualiza solo al cambiar el valor en un dialog
    update(['updateAll']);
  }
  Provider get getProvider => _provider;

  //  category
  Category _category = Category();
  set setCategory(Category value) {
    _category = value; 
    controllerTextEditCategory.text = value.name; // actualizamos el textfield porque no se actualiza solo al cambiar el valor en un dialog
    update(['updateAll']);
  }
  Category get getCategory => _category;
  // precio de compra
  double _purchasePrice = 0.0;
  set setPurchasePrice(double value) {
    _purchasePrice = value;
    controllerTextEditPrecioCosto.updateValue(value);
    update(['updateAll']);
  }
  get getPurchasePrice => _purchasePrice;
  // precio de vente
  double _salePrice = 0.0;
  set setSalePrice(double value) {
    _salePrice = value;
    controllerTextEditPrecioVenta.updateValue(value); 
    update(['updateAll']);
  }
  get getSalePrice => _salePrice;

  // faovrite
  bool _favorite = false;
  bool get getFavorite => _favorite;  
  set setFavorite(bool value ) {
    _favorite=value;
    update(['updateAll']);
  }
  
  // control de stock
  bool _stock = false;
  bool get getStock => _stock;
  set setStock(bool value){
    _stock = value;
    update(['updateAll']);
  }
  // quantity stock
  int _quantityStock = 0;
  set setQuantityStock(int value) {
    _quantityStock = value;
    controllerTextEditQuantityStock.text = value.toString();
    update(['updateAll']);
  }
  int get getQuantityStock => _quantityStock;
  //  alert stock
  int _alertStock = 5;
  set setAlertStock(int value) {
    _alertStock = value;
    controllerTextEditAlertStock.text = value.toString();
    update(['updateAll']);
  }
  int get getAlertStock => _alertStock;

  // imagen
  final ImagePicker _picker = ImagePicker();
  XFile _xFileImage = XFile('');
  set setXFileImage(XFile value) => _xFileImage = value;
  XFile get getXFileImage => _xFileImage;

  // estado de carga de datos
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


  @override
  void onInit() {
    // llamado inmediatamente después de que se asigna memoria al widget

    // anim : carga de datos 
    checkDataUploadStatusProduct(dataUploadStatusCategory:false,dataUploadStatusMark:false,dataUploadStatusProvider:false,dataUploadStatusProduct:false);

    // state account auth
    setAccountAuth = homeController.getIdAccountSelected != ''; 
    // obtenemos el producto por parametro
    ProductCatalogue productFinal = Get.arguments['product'] ?? ProductCatalogue(documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now(),upgrade: Timestamp.now(), creation: Timestamp.now());
    //  set : copiamos el producto para evitar problemas de referencia en memoria con el producto original
    setProduct = productFinal.copyWith();
    // load data product
    setTextAppBar = 'Editar';
    isCatalogue();
    if(productFinal.local){
      // obtenemos los datos solo del cátalogo de la cuenta
      loadDataFormProduct();  
      // comprobamos si el producto local tiene existencia en la base de datos publica
      checkUpdateProductPublic();
    }else{
      // obtenemos los datos del producto de la base de datos global
      getDataProduct(id: getProduct.id);
    }
    

    super.onInit();
  }

  @override
  void onReady() {
    // llamado después de que el widget se representa en la pantalla - ej. showIntroDialog(); //
    super.onReady();
    controllerTextEditPrecioCosto.addListener( () => updateAll() );
  }

  @override
  void onClose() {
    // llamado justo antes de que el controlador se elimine de la memoria - ej. closeStream(); //
    controllerTextEditAlertStock.dispose();
    controllerTextEditProvider.dispose();
    controllerTextEditCategory.dispose();
    controllerTextEditDescripcion.dispose();
    controllerTextEditMark.dispose();
    controllerTextEditPrecioCosto.dispose();
    controllerTextEditPrecioVenta.dispose();
    controllerTextEditQuantityStock.dispose();

    super.onClose();
  }

  // TODO : la subcripción por defecto es true
  // get 
  bool get isSubscribed => true; //homeController.getProfileAccountSelected.subscribed;

  //
  // FUNCTIONS
  //
  updateAll() => update(['updateAll']); 

  String get getPorcentage{
    // description : obtenemos el porcentaje de las ganancias
    if ( controllerTextEditPrecioCosto.numberValue == 0 ) {
      return '';
    }
    if ( controllerTextEditPrecioVenta.numberValue == 0 ) {
      return '0%';
    }
    double dCosto = controllerTextEditPrecioCosto.numberValue;
    double ganancia = controllerTextEditPrecioVenta.numberValue - controllerTextEditPrecioCosto.numberValue; 
    double porcentajeGanancia = (ganancia / dCosto) * 100;

    
    if (ganancia % 1 != 0) {
      return '${porcentajeGanancia.toInt()}%';
    } else {
      return '${porcentajeGanancia.toInt()}%';
    }
  }

  isCatalogue() {
    // return : si el producto esta en el catalogo
    for (var element in homeController.getCataloProducts) {
      if (element.id == getProduct.id) {
        // get values
        setItsInTheCatalogue = true;
        setProduct = element.copyWith();
        update(['updateAll']);
      }
    }
  } 

  //  fuction : comprobamos los datos necesarios para proceder publicar o actualizar el producto
  Future<void> save() async {
    if (getProduct.id != '') {
      if ( controllerTextEditDescripcion.text != '') {
        if (getMarkSelected.id != '' && getMarkSelected.name != '' || getProduct.local == true ) {
          if (controllerTextEditPrecioVenta.numberValue > 0 ) {
            if ( getStock ? (getQuantityStock >= 1) : true) { 
              
              // update view
              setLoadingData = true;
              setTextAppBar = 'Espere por favor...';
              updateAll();

              // marca de tiempo 
              Timestamp time = Timestamp.now();  

              // set : values 
              getProduct.description = Utils().capitalize(controllerTextEditDescripcion.text); // format : actualiza a mayuscula la primera letra de cada palabra
              getProduct.code = getProduct.code == '' ? getProduct.id : getProduct.code;
              getProduct.idMark = getMarkSelected.id;
              getProduct.nameMark = getMarkSelected.name;
              getProduct.imageMark = getMarkSelected.image;
              getProduct.purchasePrice = controllerTextEditPrecioCosto.numberValue;
              getProduct.salePrice = controllerTextEditPrecioVenta.numberValue;
              getProduct.favorite = getFavorite;
              getProduct.stock = getStock;
              if(controllerTextEditQuantityStock.text!=''){getProduct.quantityStock = int.parse( controllerTextEditQuantityStock.text );}
              getProduct.provider = getProvider.id;
              getProduct.nameProvider = getProvider.name;
              getProduct.category = getCategory.id; 
              getProduct.nameCategory = getCategory.name; 
              if(controllerTextEditAlertStock.text!=''){getProduct.alertStock  = int.parse( controllerTextEditAlertStock.text );}
              // se actualiza la marca de tiempo si se actualiza el precio de venta al publico
              if (priceSaleOriginal != getProduct.salePrice || getDataProductUpdate ) {
                getProduct.upgrade = time;
              } 

              // actualización de la imagen del producto
              if (getXFileImage.path != '') {
                // image - Si el "path" es distinto '' quiere decir que ahi una nueva imagen para actualizar
                // si es asi procede a guardar la imagen en la base de la app
                Reference ref = Database.referenceStorageProductPublic(id: getProduct.id); // obtenemos la referencia en el storage
                UploadTask uploadTask = ref.putFile(File(getXFileImage.path)); // cargamos la imagen
                await uploadTask; // esperamos a que se suba la imagen 
                await ref.getDownloadURL().then((value) => getProduct.image = value); // obtenemos la url de la imagen
              }
              // procede agregrar en la base de datos global de productos
              // TODO : delete release (getEditModerator)
              if ( getEditModerator || getProduct.local == false) { 
                // set
                getProduct.documentUpgrade = time;
                // se guarda el producto en la base de datos global
                  setProductPublicFirestore( );
              }
              // condition : verifica si el producto es global publico
              if(!getProduct.local){
                // Registra el precio en una colección publica
                ProductPrice precio = ProductPrice(
                  id: homeController.getProfileAccountSelected.id,
                  idAccount: homeController.getProfileAccountSelected.id,
                  imageAccount: homeController.getProfileAccountSelected.image,
                  nameAccount: homeController.getProfileAccountSelected.name,
                  price: getProduct.salePrice,
                  currencySign: getProduct.currencySign,
                  province: homeController.getProfileAccountSelected.province,
                  town: homeController.getProfileAccountSelected.town,
                  time: Timestamp.fromDate(DateTime.now()),
                );

                // condition : si el producto no existe en el cátalogo
                if (getItsInTheCatalogue == false) {
                  // Firebase set : incrementamos el valor de los seguidores del producto
                  Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(1)});
                }

                // Firebase set : se crea un documento con la referencia del precio del producto
                Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(precio.id).set(precio.toJson());
              }

              // Firebase set : se crea los datos del producto del cátalogo de la cuenta
              Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id).set(getProduct.toJson());

              // actualiza la lista de productos del cátalogo en la memoria de la app
              homeController.sincronizeCatalogueProducts(product: getProduct);
              // sleep : espera 3 segundos para que se actualice la vista
              await Future.delayed(const Duration(milliseconds: 500)).then((value) {
                setLoadingData = false; Get.back(); 
              });

              

            } else {
              Get.snackbar(
                  'Stock no valido 😐', 'debe proporcionar un cantidad');
            }
          } else {
            Get.snackbar(
                'Antes de continuar 😐', 'debe proporcionar un precio');
          }
        } else {
          Get.snackbar(
              'No se puedo continuar 😐', 'debes seleccionar una marca');
        }
      } else {
        Get.snackbar('No se puedo continuar 👎',
            'debes escribir una descripción del producto');
      }
    }else{
      Get.snackbar('No se puedo continuar 👎',
            'se produjo un error');}
  }
  void setProductPublicFirestore()  { 
    // esta función procede a guardar el documento de una colleción publica

    // valores
    Product product = getProduct.convertProductoDefault(); 
    //  set
    product.idUserUpgrade = homeController.getProfileAdminUser.email; // id del usuario que actualizo el documento

    // firebase: actualizar el documento del producto publico
    Database.refFirestoreProductPublic().doc(product.id).update(product.toJsonUpdate());

    // condition : verifica si existe el controlador
    if (Get.isRegistered<ModeratorController>()) {
      // si accedemos desde la vista de moderador
      // controllers
      final ModeratorController controller = Get.find<ModeratorController>(); 
      // actualizamos el producto modificado
      controller.updateProducts(product: product);
    } 
  } 
  void deleteProductInCatalogue() async{
    // activate indicator load
    setLoadingData = true;
    setTextAppBar = 'Eliminando...';
    updateAll();
    
    // firebase : eliminar registro de precio de la base de datos publica
    await Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(homeController.getProfileAccountSelected.id).delete();
    // firebase : elimina el producto del cátalogo de la cuenta
    await Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id)
      .doc(getProduct.id)
      .delete()
      .whenComplete(() {
        // actualiza la lista de productos del cátalogo en la memoria de la app
        homeController.sincronizeCatalogueProducts(product: getProduct, delete: true);
        // Firebase : descontamos el valor de los seguidores del producto
        if (getProduct.followers > 0){
          Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(-1)});
        }
        Get.back();
        Get.back();
      })
      .onError((error, stackTrace) => Get.back())
      .catchError((ex) => Get.back());
  }
  void deleteProducPublic() async {
    // activate indicator load
    setLoadingData = true;
    setTextAppBar = 'Eliminando...';
    updateAll();

    // firebase : delete doc product in catalogue account
    await Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id).delete();
    // firebase : eliminar registro de precio de la base de datos publica
    await Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(homeController.getProfileAccountSelected.id).delete();
    // firebase : delete doc product
    await Database.refFirestoreProductPublic().doc(getProduct.id).delete().whenComplete(() {
      Get.back();
      Get.back();
    });
  }
  // read : carga los datos del producto en el formulario una ves que se obtienen de la base de datos
  void loadDataFormProduct() {
 
    // set : datos del producto para validar 
    setFavorite = getProduct.favorite;
    setPurchasePrice = getProduct.purchasePrice;
    setSalePrice = getProduct.salePrice;
    setQuantityStock = getProduct.quantityStock;
    setAlertStock = getProduct.alertStock;
    setStock = getProduct.stock;
    setDescription= getProduct.description;
    setMarkSelected = Mark(id: getProduct.idMark, name: getProduct.nameMark, creation:getProduct.documentCreation, upgrade: getProduct.documentUpgrade);
    setCategory = Category(id: getProduct.category, name: getProduct.nameCategory); 
    setProvider = Provider(id: getProduct.provider);
    // set : precio de venta original para determinar si se actualizo
    priceSaleOriginal = getProduct.salePrice; 

    checkDataUploadStatusProduct(dataUploadStatusProduct: true);
    
    // set : controles de las entradas de texto
    controllerTextEditDescripcion = TextEditingController(text: getDescription);
    controllerTextEditPrecioVenta = MoneyMaskedTextController(initialValue: getSalePrice,leftSymbol: '\$');
    controllerTextEditPrecioCosto = MoneyMaskedTextController(initialValue: getPurchasePrice,leftSymbol: '\$');
    controllerTextEditQuantityStock = TextEditingController(text: getQuantityStock.toString());
    controllerTextEditAlertStock = TextEditingController(text: getAlertStock.toString());
    controllerTextEditCategory = TextEditingController(text: getCategory.name);

    // primero verificamos que no tenga el metadato del dato de la marca para hacer un consulta inecesaria
    if (getProduct.idMark != ''){readMarkProducts();} else{ checkDataUploadStatusProduct(dataUploadStatusMark: true); }
    if (getProduct.category != ''){readCategory();} else{ checkDataUploadStatusProduct(dataUploadStatusCategory: true); }
    if (getProduct.provider != ''){readProvider();} else{ checkDataUploadStatusProduct(dataUploadStatusProvider: true); }
  }
  // read : obtiene los datos de la maraca del producto
  void readMarkProducts() {
    //  function : lee la marca del producto 
    if (getProduct.idMark.isNotEmpty) {
      Database.readMarkFuture(id: getProduct.idMark).then((value) {
        Mark brand = Mark.fromMap(value.data() as Map);
        getProduct.nameMark = brand.name; // guardamos un metadato
        setMarkSelected = brand;
        checkDataUploadStatusProduct(dataUploadStatusMark: true);
      }).onError((error, stackTrace) {
        setMarkSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
        checkDataUploadStatusProduct(dataUploadStatusMark: true);
      }).catchError((_) {
        setMarkSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
        checkDataUploadStatusProduct(dataUploadStatusMark: true);
      });
    }
  }
  // read : obtiene los datos de la categoria del producto
  void readCategory() {
    //  function : lee la categoria del producto
    Database.readCategotyCatalogueFuture(idAccount: homeController.getProfileAccountSelected.id, idCategory: getProduct.category)
        .then((value) {
      setCategory = Category.fromDocumentSnapshot(documentSnapshot: value);
      checkDataUploadStatusProduct(dataUploadStatusCategory: true);
      }).onError((error, stackTrace) {
        setCategory = Category(id: '', name: '');
        checkDataUploadStatusProduct(dataUploadStatusCategory: true);
      }).catchError((_) {
        setCategory = Category(id: '', name: '');
        checkDataUploadStatusProduct(dataUploadStatusCategory: true);
      });
  }
  // read : obtiene los datos del proveedor del producto
  void readProvider() {
    //  function : lee el proveedor del producto
    Database.refFirestoreProvider(idAccount:homeController.getIdAccountSelected).doc(getProduct.provider).get().then((value) {
      setProvider = Provider.fromDocumentSnapshot(documentSnapshot: value);
      checkDataUploadStatusProduct(dataUploadStatusProvider: true);
    }).onError((error, stackTrace) {
      setProvider = Provider(id: '', name: '');
      checkDataUploadStatusProduct(dataUploadStatusProvider: true);
    }).catchError((_) {
      setProvider = Provider(id: '', name: '');
      checkDataUploadStatusProduct(dataUploadStatusProvider: true);
    });
  }
  // read : comprobamos actualización en la DB publica de productos
  void checkUpdateProductPublic() {
    // firebase : comprobamos si el producto existe en la base de datos publica
    Database.readProductPublicFuture(id: getProduct.id).then((value) {
      // get 
      Product product = Product.fromMap(value.data() as Map);  

      //  set
      if(product.verified){
        setProductPublicUpdate = product; 
      } 
    });
  }
  void updateProductCatalogue() {
    // description : actualiza el producto en el cátalogo de la cuenta
    // get
    ProductCatalogue product = getProduct; 
    setProduct = product.updateData(product: getProductPublicUpdate);
    // Firebase set  
    Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id).set( getProduct.toJson()).whenComplete(() {
      // Firebase set : incrementamos el valor de los seguidores del producto o
      Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(1)});
    });
    getProduct.followers++;
    setProductPublicUpdateStatus = false;
    updateAll();
  }
  // read XFile image
  void getLoadImageGalery() {
    //  function : selecciona una imagen de la galeria
    _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    ).then((value) {
      setXFileImage = value!; 
      update(['updateAll']);  //  actualizamos la vista 
    });
  }
  void getLoadImageCamera() {
    //  function : selecciona una imagen de la camara
    _picker.pickImage(source: ImageSource.camera,maxWidth: 720.0,maxHeight: 720.0,imageQuality: 55,)
    // esperamos a que se seleccione la imagen
    .then((value) {
      // set 
      setXFileImage = value!; // conservamos la imagen
      update(['updateAll']);  //  actualizamos la vista 
    });
  }

  // WIDGETS
  void showDialogAddProfitPercentage( ) {
    // Dialog view :  muestra el dialogo para agregar el porcentaje de ganancia

    //var 
    final ButtonStyle buttonStyle = ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.all(12)));
    TextEditingController controller = TextEditingController(text: getProduct.getPorcentageValue.toString());

    // widgets
    Widget content = Scaffold(
      appBar: AppBar(
        title: const Text('Porcentaje de beneficio'), 
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Get.back();
            },
          ),
        ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // mount textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      
                      controller: controller, 
                      autofocus: true, 
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      // icoono de porcentaje

                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[1234567890]'))
                      ],
                      decoration: const InputDecoration( 
                        hintText: '%',
                        labelText: "Porcentaje",
                        prefixIcon: Icon(Icons.percent),
                      ),
                      style: const TextStyle(fontSize: 20.0),
                      textInputAction: TextInputAction.next,
                    ),
                  ),  
                ],
              ),
            ),
            const Spacer(),
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(style:  buttonStyle,onPressed: () { Get.back();}, child: const Text('Cancelar',textAlign: TextAlign.center)),
                TextButton(style:  buttonStyle,onPressed: () {
                  //  function : guarda el nuevo porcentaje de ganancia
                  if(controller.text != ''){
                    double porcentajeDeGanancia  = double.parse(controller.text); 
                    double ganancia = controllerTextEditPrecioCosto.numberValue * (porcentajeDeGanancia / 100);
                    setSalePrice = controllerTextEditPrecioCosto.numberValue + ganancia;  
                    
                  }
                  //  action : cierra el dialogo
                  Get.back();
                }, 
                child: const Text('aceptar',textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
    );


    // creamos un dialog con GetX
    Get.dialog(
      ClipRRect(
        borderRadius: const  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
        child: content,
      ),
    );  
  }

  // widget : imagen del producto
  Widget loadImage({double size = 120}) {
    
    // var
    double radius = 5;

    // devuelve la imagen del product
    if (getXFileImage.path != '') {
      // el usuario cargo un nueva imagen externa 
      return ImageProductAvatarApp( radius: radius,path: getXFileImage.path,size: size,onTap: getProduct.verified==false || getEditModerator? showModalBottomSheetCambiarImagen : null );
    } else { 

      // si no contiene ningun dato la imagen del producto se visualiza una imagen con un icon para agregar foto
      if(getProduct.image == ''){
        return ImageProductAvatarApp(radius: radius, iconAdd: true,path: '',size: size,onTap: getProduct.verified==false || getEditModerator? showModalBottomSheetCambiarImagen : null );
      }
      // se visualiza la imagen del producto
      return ImageProductAvatarApp(radius: radius,url: getProduct.image ,size: size,onTap: getProduct.verified==false || getEditModerator? showModalBottomSheetCambiarImagen : null );
    }
  }

  void showModalBottomSheetCambiarImagen() {
    Widget widget =   Wrap(
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.only(top: 12,left: 12,right: 12),
          leading: const Icon(Icons.camera),
          title: const Text('Capturar una imagen'),
          onTap: () {
            getLoadImageCamera();
            Get.back();
            
          }),
        ListTile(
          contentPadding: const EdgeInsets.only(top: 12,left: 12,right: 12,bottom: 20),
          leading: const Icon(Icons.image),
          title: const Text('Galería de fotos'),
          onTap: () {
            Get.back();
            getLoadImageGalery();
          },
        ),
      ],
    );
    // muestre la hoja inferior modal de getx
    Get.bottomSheet( 
      widget,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
  // DIALOG // 
  void showDialogDelete() {
    Widget widget = AlertDialog(
      title: const Text("¿Seguro que quieres eliminar este producto de tu catálogo?"),
      content: const Text("El producto será eliminado de tu catálogo y toda la información acumulada"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(child: const Text('Cancelar'),onPressed: () {Get.back(); }),
        TextButton(onPressed: ()=> deleteProductInCatalogue(),child: const Text('Si, eliminar')),
      ],
    );
    // muestre el dialogo
    Get.dialog(widget);
  }
  void showDialogDescription(){
    // Dialog view :  muestra el dialogo para agregar la descripción del producto

    // var
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    // style  
    TextStyle valueTextStyle = TextStyle(color: Get.isDarkMode?Colors.white:Colors.black,fontSize: 18,fontWeight: FontWeight.w400);
    // controllers
    final TextEditingController controllerTextEditDescripcion = TextEditingController(text: getProduct.description);
    // widgets
    Widget content = AlertDialog( 
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // mount textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:0),
                    child: TextFormField(
                      style: valueTextStyle,
                      autofocus: true, 
                      controller:  controllerTextEditDescripcion,
                      enabled: true, 
                      maxLines: null, 
                      autovalidateMode: AutovalidateMode.onUserInteraction, 
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration( 
                        filled: true,
                        fillColor: fillColor,
                        labelText: 'Descripción',
                        border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                        ),        
                      // validator: validamos el texto que el usuario ha ingresado.
                      validator: (value) {
                        // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                        return null; 
                      },
                    ),
                  ),  
                ],
              ),
            ), 
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton( onPressed: () { Get.back();}, child: const Text('Cancelar',textAlign: TextAlign.center)),
                TextButton( onPressed: () {
                  //  function : guarda el nuevo porcentaje de ganancia
                  setDescription = controllerTextEditDescripcion.text;
                  //  action : cierra el dialogo
                  Get.back();
                },
                child: const Text('ok',textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
    );

    // dialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return content;
      },
    );
  }
  void showDialogPriceSale(){
    // Dialog view :  muestra el dialogo para agregar el porcentaje de ganancia

    // var
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    // style  
    TextStyle valueTextStyle = TextStyle(color: Get.isDarkMode?Colors.white:Colors.black,fontSize: 18,fontWeight: FontWeight.w400);
    // controllers
    final MoneyMaskedTextController controllerTextEditPrecioVenta = MoneyMaskedTextController(initialValue: getProduct.salePrice,leftSymbol: '${homeController.getProfileAccountSelected.currencySign} ');
    // widgets
    Widget content = AlertDialog( 
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // mount textfield
                  TextFormField(
                    style: valueTextStyle,
                    autofocus: true, 
                    controller:  controllerTextEditPrecioVenta,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration( 
                      filled: true,
                      fillColor: fillColor,
                      labelText: 'Precio de venta',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      ),        
                    // validator: validamos el texto que el usuario ha ingresado.
                    validator: (value) {
                      // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                      return null; 
                    },
                  ),  
                ],
              ),
            ), 
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton( onPressed: () { Get.back();}, child: const Text('Cancelar',textAlign: TextAlign.center)),
                TextButton( onPressed: () {
                  //  function : guarda el nuevo porcentaje de ganancia
                  if(controllerTextEditPrecioVenta.numberValue != 0
                  ){
                    double precioVenta  = controllerTextEditPrecioVenta.numberValue; 
                    setSalePrice = precioVenta;  
                  }
                  //  action : cierra el dialogo
                  Get.back();
                },
                child: const Text('ok',textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
    );

    // dialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return content;
      },
    );
  }
  void showDialogPricePurchase(){
    // Dialog view :  muestra el dialogo para agregar el porcentaje de ganancia

    // var
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    // style  
    TextStyle valueTextStyle = TextStyle(color: Get.isDarkMode?Colors.white:Colors.black,fontSize: 18,fontWeight: FontWeight.w400);
    // controllers
    final MoneyMaskedTextController controllerTextEdit = MoneyMaskedTextController(initialValue: getProduct.purchasePrice,leftSymbol: '${homeController.getProfileAccountSelected.currencySign} ');
    // widgets
    Widget content = AlertDialog( 
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // mount textfield
                  TextFormField(
                    style: valueTextStyle,
                    autofocus: true, 
                    controller:  controllerTextEdit,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration( 
                      filled: true,
                      fillColor: fillColor,
                      labelText: 'Precio de Costo',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      ),        
                    // validator: validamos el texto que el usuario ha ingresado.
                    validator: (value) {
                      // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                      return null; 
                    },
                  ),  
                ],
              ),
            ), 
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton( onPressed: () { Get.back();}, child: const Text('Cancelar',textAlign: TextAlign.center)),
                TextButton( onPressed: () {
                  //  function : guarda el nuevo porcentaje de ganancia
                  if(controllerTextEdit.numberValue != 0
                  ){
                    double price  = controllerTextEdit.numberValue; 
                    setPurchasePrice = price;  
                  }
                  //  action : cierra el dialogo
                  Get.back();
                },
                child: const Text('ok',textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
    );

    // dialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return content;
      },
    );
  }
  void showDialogStock(){
    // Dialog view :  muestra el dialogo para agregar la cantidad de stock del producto

    // var
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    // style
    TextStyle valueTextStyle = TextStyle(color: Get.isDarkMode?Colors.white:Colors.black,fontSize: 18,fontWeight: FontWeight.w400);
    // controllers
    final TextEditingController controllerTextEdit = TextEditingController(text: getQuantityStock.toString());
    // widgets
    Widget content = AlertDialog( 
      title: const Text('Cantidad en stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // mount textfield
                  TextFormField(
                    style: valueTextStyle,
                    autofocus: true, 
                    controller:  controllerTextEdit,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration( 
                      filled: true,
                      fillColor: fillColor,
                      labelText: 'Cantidad',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      ),   
                    // validator: validamos el texto que el usuario ha ingresado.
                    validator: (value) {
                      // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                      return null; 
                    },
                  ),  
                ],
              ),
            ), 
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton( onPressed: () { Get.back();}, child: const Text('Cancelar',textAlign: TextAlign.center)),
                TextButton( onPressed: () {
                  //  function : guarda el nuevo porcentaje de ganancia
                  if(controllerTextEdit.text != ''){
                    int cantidad  = int.parse(controllerTextEdit.text); 
                    setQuantityStock = cantidad;  
                  }
                  //  action : cierra el dialogo
                  Get.back();
                }, 
                child: const Text('ok',textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
    );

    // dialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return content;
      },
    );
  }
  void showDialogStockAlert(){
    // Dialog view :  muestra el dialogo para introducir la cantidad del control de stock bajos

    // var
    final Color boderLineColor = Get.isDarkMode?Colors.white.withOpacity(0.3):Colors.black.withOpacity(0.3);
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    // style  
    TextStyle valueTextStyle = TextStyle(color: Get.isDarkMode?Colors.white:Colors.black,fontSize: 18,fontWeight: FontWeight.w400);
    // controllers
    final TextEditingController controllerTextEdit = TextEditingController(text: getAlertStock.toString());
    // widgets
    Widget content = AlertDialog( 
      title: const Text('Alerta de bajo stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // mount textfield
                  TextFormField(
                    style: valueTextStyle,
                    autofocus: true, 
                    controller:  controllerTextEdit,
                    enabled: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    decoration: InputDecoration( 
                      filled: true,
                      fillColor: fillColor,
                      labelText: 'Cantidad',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: boderLineColor)),
                      ),   
                    // validator: validamos el texto que el usuario ha ingresado.
                    validator: (value) {
                      // if (value == null || value.isEmpty) { return 'Por favor, escriba un precio de compra'; }
                      return null; 
                    },
                  ),  
                ],
              ),
            ), 
            // buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton( onPressed: () { Get.back();}, child: const Text('Cancelar',textAlign: TextAlign.center)),
                TextButton( onPressed: () {
                  //  function : guarda el nuevo porcentaje de ganancia
                  if(controllerTextEdit.text != ''){
                    int cantidad  = int.parse(controllerTextEdit.text); 
                    setAlertStock = cantidad;  
                  }
                  //  action : cierra el dialogo
                  Get.back();
                }, 
                child: const Text('ok',textAlign: TextAlign.center)),
              ],
            ),
          ],
        ),
    );

    // dialog
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return content;
      },
    );
  }
  // BOTTONSHET //
  void showModalSelectMarca() {
    // widget
    Widget widget = const WidgetSelectMark();
    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      widget,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }

  setOutstanding({required bool value}) {
    getProduct.outstanding = value;
    update(['updateAll']);
  }

  setCheckVerified({required bool value}) {
    getProduct.verified = value;
    update(['updateAll']);
  }

  //TODO: eliminar para release
  // DEVELOPER OPTIONS
  void showDialogDeleteOPTDeveloper() {
    Get.dialog(AlertDialog(
      title: const Text(
          "¿Seguro que quieres eliminar este documento definitivamente? (Mods)"),
      content: const Text(
          "El producto será eliminado de tu catálogo ,de la base de dato global y toda la información acumulada menos el historial de precios registrado"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Get.back(),
        ),
        TextButton(
          child: const Text("Borrar"),
          onPressed: () {
            Get.back();
            deleteProducPublic();
          },
        ),
      ],
    ));
  }
  void getDataProduct({required String id}) {
    // function : obtiene los datos del producto de la base de datos y los carga en el formulario de edición 
    if (id != '') {
      print('------------------------- Firebase db public -----------------------------------');
      // firebase : obtiene los datos del producto 
      Database.readProductPublicFuture(id: id).then((value) {
        //  get 
        Product product = Product.fromMap(value.data() as Map); 

        // commprobar que las fechas de actualización sean diferentes
        DateTime date1 = getProduct.documentUpgrade.toDate().copyWith(hour: 0,minute: 0,millisecond: 0,second: 0,microsecond: 0  );
        DateTime date2 = product.upgrade.toDate().copyWith(hour: 0,minute: 0,millisecond: 0,second: 0,microsecond: 0);
        if (date1.isBefore(date2)  ) {
          // se notifica que existen datos actualizados del producto
          setMessageNotification = 'Producto actualizado';
          setDataProductUpdate = true;
        } 

        //  set
        setProduct = getProduct.updateData(product: product);
        // carga los datos del producto en el formulario
        loadDataFormProduct();
        // actualiza la vista ui
        checkDataUploadStatusProduct(dataUploadStatusProduct: true);
        
      }).catchError((error) {
        checkDataUploadStatusProduct(dataUploadStatusProduct: false);
      }).onError((error, stackTrace) {
        checkDataUploadStatusProduct(dataUploadStatusProduct: false);
      });
    }
  }
  void increaseFollowersProductPublic() { 
    // function : aumenta el valor de los seguidores del producto publico
    Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(1)});
    // actualizamos el valor de los seguidores del producto
    getProduct.followers++;
    update(['updateAll']);
  }
  void descreaseFollowersProductPublic() {
    // function : disminuye el valor de los seguidores del producto publico
    Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(-1)});
    // actualizamos el valor de los seguidores del producto
    getProduct.followers--;
    update(['updateAll']);
  }
  void showDialogSaveOPTDeveloper() {
    Get.dialog(AlertDialog(
      title: const Text("¿Seguro que quieres actualizar este docuemnto? (Mods)"),
      content: const Text( "El producto será actualizado de tu catálogo ,de la base de dato global y toda la información acumulada menos el historial de precios registrado"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(child: const Text("Cancelar"),onPressed: () => Get.back()),
        TextButton(
          child: const Text("Si, actualizar"),
          onPressed: () {
            Get.back();
            save(); // save product
          },
        ),
      ],
    ));
  } 

}

// select mark
class WidgetSelectMark extends StatefulWidget {
  const WidgetSelectMark({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WidgetSelectMarkState createState() => _WidgetSelectMarkState();
}

class _WidgetSelectMarkState extends State<WidgetSelectMark> {
  //  controllers
  ControllerProductsEdit controllerProductsEdit = Get.find();
  //  var
  List<Mark> list = [];
  bool viewListState = false;

  @override
  void initState() {
    loadMarks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widgetView();
  }

  Widget widgetView() {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcas'),
        actions: [
          // TODO : delete icon 'add new mark for release'
          IconButton(onPressed: () {Get.back(); Get.to(() => CreateMark(mark: Mark(upgrade: Timestamp.now(),creation: Timestamp.now())));},icon: const Icon(Icons.add)),
          IconButton(icon: Icon( viewListState? Icons.grid_view_rounded:Icons.table_rows_rounded),onPressed: () { 
            setState(() {
              viewListState = !viewListState;
            });
          }),
          IconButton(icon: const Icon(Icons.search),onPressed: () {Get.back();showSeachMarks();})
        ],
      ),
      body: list.isEmpty ? widgetAnimLoad() : viewListState? bodyList() : bodyGrid(),
    );
  }

  // WIDGETS VIEW 
  Widget bodyList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        //  values
        Mark marcaSelect = list[index]; 
        return Column(
          children: <Widget>[
            itemList(marcaSelect: marcaSelect),
            ComponentApp().divider(),
          ],
        );
      },
    );
  } 
  Widget bodyGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      shrinkWrap: true, 
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,childAspectRatio: 1),
      itemBuilder: (BuildContext context, int index) {
        //  values
        Mark marcaSelect = list[index];
        return itemGrid(marcaSelect: marcaSelect);
      },
    );
  }

  // WIDGETS
  Widget widgetAnimLoad() {
    return Center(
        child: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(
                  child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(
                  child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(
                  child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(
                  child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(
                  child: SizedBox(width: double.infinity, height: 50))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor,
              child: const Card(
                  child: SizedBox(width: double.infinity, height: 50))),
        ),
      ],
    ));
  } 

  // WIDGETS COMPONENT
  showSeachMarks(){

    // description : muestra la barra de busqueda para buscar marcas

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    showSearch(
      context: context,
      delegate: SearchPage<Mark>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: list,
        searchLabel: 'Buscar marca',
        suggestion: const Center(child: Text('ej. agua')),
        failure: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se encontro :('),

            // TODO : disable moderador ( crear marca )
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {Get.back(); Get.to(() => CreateMark(mark: Mark(upgrade: Timestamp.now(),creation: Timestamp.now())));},
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Crear marca'),
            )
          ],
        )),
        filter: (product) => [product.name,product.description],
        builder: (mark) => Column(mainAxisSize: MainAxisSize.min,children: <Widget>[
          itemList(marcaSelect: mark),
          ComponentApp().divider(),
          ]),
      ),
    );
  }
  
  Widget itemGrid({required Mark marcaSelect}) {
    return InkWell(
      onTap: () {
        controllerProductsEdit.setUltimateSelectionMark = marcaSelect;
        controllerProductsEdit.setMarkSelected = marcaSelect;
        Get.back();
      },
      onLongPress: (){
        // TODO : delete fuction
        Get.to(() => CreateMark(mark: marcaSelect));
      },
      borderRadius: BorderRadius.circular(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageProductAvatarApp(url: marcaSelect.image,size: 50,description:marcaSelect.name),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(marcaSelect.name,style: const TextStyle(fontWeight: FontWeight.w400 ),textAlign: TextAlign.center,maxLines: 2,),
            ),
          ),
        ],
      ),
    );
  }
  Widget itemList({required Mark marcaSelect, bool icon = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      trailing:!icon? null  :marcaSelect.image==''?null: ImageProductAvatarApp(url: marcaSelect.image,size: 50,description:marcaSelect.name),
      dense: true,
      title: Text(marcaSelect.name,overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.w400,fontSize: 18)),
      subtitle: marcaSelect.description == ''
          ? null
          : Text(marcaSelect.description, overflow: TextOverflow.ellipsis,maxLines: 2,),
      onTap: () {
        controllerProductsEdit.setUltimateSelectionMark = marcaSelect;
        controllerProductsEdit.setMarkSelected = marcaSelect;
        Get.back();
      },
      onLongPress: () {
        // TODO : delete fuction
        Get.to(() => CreateMark(mark: marcaSelect));
      },
    );
  }

  // functions
  loadMarks() async {
    if (controllerProductsEdit.getMarks.isEmpty) {
      print('------------------------- Firebase db public product brands -----------------------------------');
      // firebase : obtiene las marcas de la base de datos
      await Database.readListMarksFuture().then((value) {
        setState(() {
          for (var element in value.docs) {
            Mark mark = Mark.fromMap(element.data());
            mark.id = element.id;
            list.add(mark);
          }
          updateListMarkSelected();
          controllerProductsEdit.setMarks = list;
        });
      });
    } else {
      // datos ya descargados
      list = controllerProductsEdit.getMarks;
      updateListMarkSelected();
      setState(() => list = controllerProductsEdit.getMarks);
    }
  }
  updateListMarkSelected() {
    //  description : posicionamos el ultimo item seleccionado por el usuario en el segundo lugar 
    //                para que el usuario pueda encontrarlo facilmente

    // comprobamos que ahi un item seleccionado
    if (controllerProductsEdit.getUltimateSelectionMark.id != '') {
      // eliminamos el item seleccionado de la lista
      list.removeWhere((element) => element.id == controllerProductsEdit.getUltimateSelectionMark.id);
      // insertamos el item seleccionado en la segunda posicion de la lista
      list.insert(1, controllerProductsEdit.getUltimateSelectionMark);
    }
    // obtenemos el item con id 'other'
    Mark? mark = list.firstWhereOrNull((element) => element.id == 'other'); 
    // eliminamos el item con la id 'other' de la lista
    list.removeWhere((element) => element.id == 'other');
    // insertar en la primera posicion de la lista 
    if(mark != null) list.insert(0, mark);
  }
  
}

// TODO : delete release
class CreateMark extends StatefulWidget {
  final Mark mark;
  const CreateMark({required this.mark, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateMarkState createState() => _CreateMarkState();
}
class _CreateMarkState extends State<CreateMark> {
  // others controllers
  final ControllerProductsEdit controllerProductsEdit = Get.find();

  //var
  var uuid = const Uuid();
  bool newMark = false;
  String title = 'Nueva marca';
  bool load = false;
  TextStyle textStyle = const TextStyle(fontSize: 24.0);
  final ImagePicker _picker = ImagePicker();
  XFile xFile = XFile('');

  @override
  void initState() {
    newMark = widget.mark.id == '';
    title = newMark ? 'Nueva marca' : 'Editar';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
    );
  }

  PreferredSizeWidget appbar() {
    Color? colorAccent = Get.theme.textTheme.bodyLarge!.color;

    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Text(title, style: TextStyle(color: colorAccent)),
      iconTheme: Get.theme.iconTheme.copyWith(color: colorAccent),
      actions: [
        newMark || load ? Container(): IconButton(onPressed: delete, icon: const Icon(Icons.delete)),
        load? Container() : IconButton(icon: const Icon(Icons.check),onPressed: save),
      ],
      bottom: load ? ComponentApp().linearProgressBarApp() : null,
    );
  }

  Widget body() {

    // widgets
    Widget circleAvatarDefault = CircleAvatar(backgroundColor: Colors.grey.shade300,radius: 75.0);

    // var
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              xFile.path != ''
                  ? CircleAvatar(backgroundImage: FileImage(File(xFile.path)),radius: 76,)
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.mark.image,
                      placeholder: (context, url) => circleAvatarDefault,
                      imageBuilder: (context, image) => CircleAvatar(backgroundImage: image,radius: 75.0),
                      errorWidget: (context, url, error) => circleAvatarDefault,
                    ),
              load ? Container(): TextButton(onPressed: getLoadImageMark,child: const Text("Cambiar imagen")),
            ],
          ),
        ),
        // view : nombre de la marca
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.name),
            onChanged: (value) => widget.mark.name = value,
            decoration: InputDecoration(
                filled: true, 
                fillColor: fillColor,
                labelText: "Nombre de la marca"),
            style: textStyle,
          ),
        ),
        // view : descripcion de la marca
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value, 
            minLines: 1, // Definir el mínimo de líneas
            maxLines: null, // Permitir cualquier cantidad de líneas
            maxLength: 160,
            decoration: InputDecoration(
                filled: true, 
                fillColor: fillColor,
                labelText: "Descripción (opcional)"),
            style: textStyle,
          ),
        ),
        // view : botones de edicionales
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // view : buscar en google
              Row(
                children: [
                  // text 
                  const Text('Buscar en google:'),
                  const Spacer(),
                  // button : textButton : buscar en google
                  TextButton(
                      onPressed: () async {
                        String clave = 'logo ${widget.mark.name}';
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                        await launchUrl(uri,mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Imagen del logo' )),
                  // textButton : buscar en google
                  TextButton(
                      onPressed: () async {
                        String clave = 'que industria es la marca ${widget.mark.name}?';
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave");
                        await launchUrl(uri,mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Información')),
                ],
              ),
              // buttom : edicion de imagen
              TextButton(
                onPressed: () async{
                  // values
                  Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.camerasideas.instashot&pcampaignid=web_share');
                  //  redireccionara para la tienda de aplicaciones
                  await launchUrl(uri,mode: LaunchMode.externalApplication);
                },
                child: const Text('Editar imagen con InstaShot'),
              ),
            ],
          ),
        ), 
      ],
    );
  }

  //  MARK CREATE
  void getLoadImageMark() {
    _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    ).then((value) {
      setState(() => xFile = value!);
    });
  }

  void delete() async {
    setState(() {
      load = true;
      title = 'Eliminando...';
    });

    if (widget.mark.id != '') {
      // delele archive storage
      await Database.referenceStorageProductPublic(id: widget.mark.id).delete().catchError((_) => null);
      // delete document firestore
      await Database.refFirestoreMark().doc(widget.mark.id).delete()
          .then((value) {
        // eliminar el objeto de la lista manualmente para evitar hacer una consulta innecesaria
        controllerProductsEdit.getMarks.remove(widget.mark);
        Get.back();
      });
    }
  }

  void save() async {
    setState(() {
      load = true;
      title = newMark ? 'Guardando...' : 'Actualizando...';
    });

    // set values
    widget.mark.verified = true;
    if (newMark) {
      // generate Id
      widget.mark.id = uuid.v1();
      // en el caso que la ID siga siendo '' generar un ID con la marca del tiempo
      if (widget.mark.id == '') {widget.mark.id = DateTime.now().millisecondsSinceEpoch.toString();}
    }
    if (widget.mark.name != '') {
      // image save
      // Si el "path" es distinto '' procede a guardar la imagen en la base de dato de almacenamiento
      if (xFile.path != '') {
        Reference ref = Database.referenceStorageProductPublic(id: widget.mark.id);
        // referencia de la imagen
        UploadTask uploadTask = ref.putFile(File(xFile.path));
        // cargamos la imagen a storage
        await uploadTask;
        // obtenemos la url de la imagen guardada
        await ref.getDownloadURL().then((value) => widget.mark.image = value);
      } 
      
      // mark save
      if( newMark ){
        // set
        widget.mark.creation = Timestamp.now();
        widget.mark.upgrade = Timestamp.now();
        // creamos un docuemnto nuevo
        await Database.refFirestoreMark().doc(widget.mark.id).set(widget.mark.toJson()).whenComplete(() {

          // set values  
          controllerProductsEdit.setUltimateSelectionMark = widget.mark;
          controllerProductsEdit.setMarkSelected = widget.mark;
          // agregar el obj manualmente para evitar consulta a la db  innecesaria
          controllerProductsEdit.getMarks.add(widget.mark);
          Get.back();
        });
      }else{
        //set 
        widget.mark.upgrade = Timestamp.now();

        // actualizamos un documento existente
        await Database.refFirestoreMark().doc(widget.mark.id).update(widget.mark.toJson()).whenComplete(() {

          // set values
          controllerProductsEdit.setUltimateSelectionMark = widget.mark;
          controllerProductsEdit.setMarkSelected = widget.mark;
          // eliminamos la marca de la lista
          controllerProductsEdit.getMarks.removeWhere((element) => (element.id == widget.mark.id));
          // agregamos la nueva marca actualizada a la lista
          controllerProductsEdit.getMarks.add(widget.mark);
          Get.back();
        });
      }

    } else {
      Get.snackbar('', 'Debes escribir un nombre de la marca');
    }
  }

}


