
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_page/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart'; 
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';
import '../../moderator/controller/moderator_controller.dart'; 

class ControllerCreateProductForm extends GetxController{

  // Build context
  BuildContext? context;
  BuildContext get getContext => context!;
  set setContext(BuildContext value) => context = value;

  // var style
  Color colorLoading = Colors.blue; 
  final Color colorButton = Colors.blue; 
  bool darkMode = false;
  // var logic
  bool _onBackPressed = false;


  // controller : carousel de componentes para que el usuario complete los campos necesarios para crear un nuevo producto nuevo
  CarouselController carouselController = CarouselController();
  // var : logic  para que el usuario complete los campos necesarios para crear un nuevo producto nuevo
  bool formEditing = false;
  bool theFormIsComplete = false;
  bool checkValidateForm = false;
  bool enabledButton = false;

  // var : TextFormField formKey
  GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> markFormKey = GlobalKey<FormState>(); 
  GlobalKey<FormState> purchasePriceFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> salePriceFormKey = GlobalKey<FormState>(); 
  GlobalKey<FormState> quantityStockFormKey = GlobalKey<FormState>(); 

  // var : TextFormField focus
  final descriptionTextFormFieldfocus = FocusNode(); 
  final purchasePriceTextFormFieldfocus = FocusNode(); 
  final salePriceTextFormFieldfocus = FocusNode(); 

  // others controllers
  final HomeController homeController = Get.find();
  HomeController get getHomeController => homeController;

  int _currentSlide = 0 ;
  get getCurrentSlide  => _currentSlide;
  set setCurrentSlide(int value) {
    _currentSlide = value;
    update();
  }

  // concentimiento del usuario
  bool _userConsent = false;
  set setUserConsent(bool value) {
    _userConsent = value;
    update();
  }
  bool get getUserConsent => _userConsent; 

  // state internet
  bool connected = false;
  set setStateConnect(bool value) {
    connected = value;
    update();
  }

  bool get getStateConnect => connected;

  // ultimate selection mark
  static Mark _ultimateSelectionMark = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setUltimateSelectionMark(Mark value) => _ultimateSelectionMark = value;
  Mark get getUltimateSelectionMark => _ultimateSelectionMark;

  static Mark _ultimateSelectionMark2 = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setUltimateSelectionMark2(Mark value) => _ultimateSelectionMark2 = value;
  Mark get getUltimateSelectionMark2 => _ultimateSelectionMark2;

  // state account auth
  bool _accountAuth = false;
  set setAccountAuth(value) {
    _accountAuth = value;
    update();
  }

  bool get getAccountAuth => _accountAuth;

  // text appbar
  String _textAppbar = 'Nuevo producto';
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
    update();
  }

  bool get getEditModerator => _editModerator;

  // parameter
  ProductCatalogue _product = ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
  set setProduct(ProductCatalogue product) => _product = product;
  ProductCatalogue get getProduct => _product;

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
    update();
  }
  get getDescription => _description;

  // mark
  Mark _markSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setMarkSelected(Mark value) {
    controllerTextEditMark.text = value.name;
    _markSelected = value;
    getProduct.idMark = value.id;
    getProduct.nameMark = value.name;
    update();
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
    update();
  }
  Provider get getProvider => _provider;

  //  category
  Category _category = Category();
  set setCategory(Category value) {
    _category = value; 
    controllerTextEditCategory.text = value.name; // actualizamos el textfield porque no se actualiza solo al cambiar el valor en un dialog
    update();
  }
  Category get getCategory => _category;
  // precio de compra
  double _purchasePrice = 0.0;
  set setPurchasePrice(double value) {
    _purchasePrice = value;
    update();
  }
  get getPurchasePrice => _purchasePrice;
  // precio de vente
  double _salePrice = 0.0;
  set setSalePrice(double value) {
    _salePrice = value;
    controllerTextEditPrecioVenta.updateValue(value);
    update();
  }
  get getSalePrice => _salePrice;

  // faovrite
  bool _favorite = false;
  bool get getFavorite => _favorite;  
  set setFavorite(bool value ) {
    _favorite=value;
    update();
  }
  
  // control de stock
  bool _stock = false;
  bool get getStock => _stock;
  set setStock(bool value){
    _stock = value;
    update();
  }
  // quantity stock
  int _quantityStock = 0;
  set setQuantityStock(int value) {
    _quantityStock = value;
    update();
  }
  int get getQuantityStock => _quantityStock;
  //  alert stock
  int _alertStock = 5;
  set setAlertStock(int value) {
    _alertStock = value;
    update();
  }
  int get getAlertStock => _alertStock;

  // imagen
  final ImagePicker _picker = ImagePicker();
  XFile _xFileImage = XFile('');
  set setXFileImage(XFile value) => _xFileImage = value;
  XFile get getXFileImage => _xFileImage;

  // estado de carga de datos
  bool _dataUploadStatus = false;
  set setDataUploadStatus(bool value){
    _dataUploadStatus = value; 
  }
  bool get getDataUploadStatus => _dataUploadStatus;
  // estado de carga de datos del producto
  bool _dataUploadStatusProduct = false;
  set setDataUploadStatusProduct(bool value){
    _dataUploadStatusProduct = value;
    checkDataUploadStatus();
  }
  bool get getDataUploadStatusProduct => _dataUploadStatusProduct;
  // estado de carga de datos de la marca 
  bool _dataUploadStatusMark = false; 
  set setDataUploadStatusMark(bool value){
    _dataUploadStatusMark = value;
    checkDataUploadStatus();
  }
  bool get getDataUploadStatusMark => _dataUploadStatusMark;
  // estado de carga de datos del proveedor 
  bool _dataUploadStatusProvider = false;
  set setDataUploadStatusProvider(bool value){
    _dataUploadStatusProvider = value;
    checkDataUploadStatus();
  }
  bool get getDataUploadStatusProvider => _dataUploadStatusProvider;
  // estado de carga de datos de la categoria 
  bool _dataUploadStatusCategory = false;
  set setDataUploadStatusCategory(bool value){
    _dataUploadStatusCategory = value;
    checkDataUploadStatus();
  }
  bool get getDataUploadStatusCategory => _dataUploadStatusCategory;

  // void : comprobar si se cargaron los datos del producto,de la marca, proveedor y categoria
  void checkDataUploadStatus() {
    if (getDataUploadStatusProduct && getDataUploadStatusMark && getDataUploadStatusProvider && getDataUploadStatusCategory) {
      setDataUploadStatus = false;
    }else{
      setDataUploadStatus = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    
    // obtenemos el obj del producto pasado por parametro
    setProduct = Get.arguments['product']?? ProductCatalogue(creation: Timestamp.now(), upgrade: Timestamp.now(), documentCreation: Timestamp.now(), documentUpgrade: Timestamp.now());
  } 
  @override
  void onReady() {
    super.onReady();
    if(getProduct.local){
      carouselController.animateToPage(1);
    }
  }
  @override
  void onClose() {
    super.onClose();

    // llamado justo antes de que el controlador se elimine de la memoria - ej. closeStream(); //
    controllerTextEditAlertStock.dispose();
    controllerTextEditProvider.dispose();
    controllerTextEditCategory.dispose();
    controllerTextEditDescripcion.dispose();
    controllerTextEditMark.dispose();
    controllerTextEditPrecioCosto.dispose();
    controllerTextEditPrecioVenta.dispose();
    controllerTextEditQuantityStock.dispose();
  } 
  // TODO : la subcripción por defecto es true
  // get 
  bool get isSubscribed => true;//homeController.getProfileAccountSelected.subscribed;

  //
  // FUNCTIONS
  //
  updateAll() => update(); 

  String get getPorcentage{
    // description : obtenemos el porcentaje de las ganancias
    if ( controllerTextEditPrecioCosto.numberValue == 0 ) {
      return '';
    }
    if ( controllerTextEditPrecioVenta.numberValue == 0 ) {
      return '0%';
    }
    
    double ganancia = controllerTextEditPrecioVenta.numberValue - controllerTextEditPrecioCosto.numberValue;
    double porcentajeDeGanancia = (ganancia / controllerTextEditPrecioCosto.numberValue) * 100;
    
    if (ganancia % 1 != 0) {
      return '${porcentajeDeGanancia.toStringAsFixed(2)}%';
    } else {
      return '${porcentajeDeGanancia.toInt()}%';
    }
  }

  isCatalogue() {
    // return : si el producto esta en el catalogo
    for (var element in homeController.getCataloProducts) {
      if (element.id == getProduct.id) {
        // get values
        setItsInTheCatalogue = true;
        setProduct = element;
        update();
      }
    }
  } 
  Future<bool> onBackPressed({required BuildContext context})async{
    // fuction : si _onBackPressed es false no se puede salir de la app

    // si _onBackPressed es false no se puede salir de la app
    if(_onBackPressed==false){ 
      _onBackPressed = !_onBackPressed;
      return false;
    }
    // condition : si el slide actual es distinto de 0
    if( getCurrentSlide !=0 && getProduct.local == false || getCurrentSlide !=1 && getProduct.local == true){
      previousPage();
      return false;
    } 

    //  si _onBackPressed es true se puede salir 
    if( getCurrentSlide==0 && getProduct.local==false || (getProduct.local && getCurrentSlide==1)){
      final  shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('¿Realmente quieres salir?',textAlign: TextAlign.center),
              content: const Text('Si sales perderás los datos que no hayas guardado',textAlign: TextAlign.center),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: (){Get.back();Get.back();},
                  child: const Text('Si'),
                ),
              ],
            );
          },
        );
        return shouldPop!;
    }
    return true;
        
  } 

  //  fuction : comprobamos los datos necesarios para proceder publicar o actualizar el producto
  Future<void> save() async {
    if (getProduct.id != '') {
      if ( controllerTextEditDescripcion.text != '') {
        if (getMarkSelected.id != '' && getMarkSelected.name != '') {
          if (controllerTextEditPrecioVenta.numberValue > 0 ) {
            if ( getStock ? (getQuantityStock >= 1) : true) { 
              
              // update view
              setDataUploadStatus = true;
              setTextAppBar =  'Publicando...' ;
              updateAll();

              // set : values
              getProduct.description = Utils().capitalize(controllerTextEditDescripcion.text); // controllerTextEditDescripcion.text;
              getProduct.upgrade = Timestamp.now();
              getProduct.idMark = getMarkSelected.id;
              getProduct.nameMark = getMarkSelected.name;
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

              // TODO : DELETE RELEASE
              getProduct.verified = getProduct.local ? false : true; 

              // actualización de la imagen del producto
              if (getXFileImage.path != '') { 
                // image - Si el "path" es distinto '' quiere decir que ahi una nueva imagen para actualizar
                // si es asi procede a guardar la imagen en la base de la app
                Reference ref = Database.referenceStorageProductPublic(id: getProduct.id); // obtenemos la referencia en el storage
                UploadTask uploadTask = ref.putFile(File(getXFileImage.path)); // cargamos la imagen
                await uploadTask; // esperamos a que se suba la imagen 
                await ref.getDownloadURL().then((value) => getProduct.image = value); // obtenemos la url de la imagen
              }
              if(getProduct.local == false){
                // procede agregrar el producto en una colección publica
                setProductPublicFirestore();
                
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

                // Firebase set : se crea un documento con la referencia del precio del producto
                Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(precio.id).set(precio.toJson());
              }

              // Firebase set : se crea los datos del producto del cátalogo de la cuenta
              Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id)
                .set(getProduct.toJson())
                .whenComplete(() async {
                  await Future.delayed(const Duration(seconds: 3)).then((value) {setDataUploadStatus = false; Get.back();Get.back(); });
              }).onError((error, stackTrace) => setDataUploadStatus = false).catchError((_) => setDataUploadStatus = false);

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

  void setProductPublicFirestore()  async { 
    // esta función procede a guardar el documento de una colleción publica

    // valores
    Product product = getProduct.convertProductoDefault();
    
    // asignamos los valores de creación 
    product.idUserCreation = homeController.getProfileAdminUser.email;
    product.creation = Timestamp.fromDate(DateTime.now());
    //  set : marca de tiempo que se actualizo el documento
    product.upgrade = Timestamp.fromDate(DateTime.now()); 
    //  set : id del usuario que actualizo el documento
    product.idUserUpgrade = homeController.getProfileAdminUser.email;

    // incrementar el valor 'followers' del producto publico
    product.followers++;  
    // crear el documento del producto publico
    await Database.refFirestoreProductPublic().doc(product.id).set(product.toJson());

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
    setDataUploadStatus = true;
    setTextAppBar = 'Eliminando...';
    updateAll();
    
    // firebase : eliminar registro de precio de la base de datos publica
    await Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(homeController.getProfileAccountSelected.id).delete();
    // firebase : elimina el producto del cátalogo de la cuenta
    await Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id)
      .doc(getProduct.id)
      .delete()
      .whenComplete(() {
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
    setDataUploadStatus = true;
    setTextAppBar = 'Eliminando...';
    update();

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
  // fuction : carga los datos del producto en el formulario una ves que se obtienen de la base de datos
  void loadDataFormProduct() {
 
    // set : datos del producto para validar 
    setFavorite = getProduct.favorite;
    setPurchasePrice = getProduct.purchasePrice;
    setSalePrice = getProduct.salePrice;
    setQuantityStock = getProduct.quantityStock;
    setAlertStock = getProduct.alertStock;
    setStock = getProduct.stock;
    setDescription= getProduct.description;
    setMarkSelected = Mark(id: getProduct.idMark, name: getProduct.nameMark, creation: Timestamp.now(), upgrade: Timestamp.now());
    setCategory = Category(id: getProduct.category, name: getProduct.nameCategory); 
    setProvider = Provider(id: getProduct.provider);
    
    // set : controles de las entradas de texto
    controllerTextEditDescripcion =TextEditingController(text: getDescription);
    controllerTextEditPrecioVenta =MoneyMaskedTextController(initialValue: getSalePrice,leftSymbol: '\$');
    controllerTextEditPrecioCosto =MoneyMaskedTextController(initialValue: getPurchasePrice,leftSymbol: '\$');
    controllerTextEditQuantityStock =TextEditingController(text: getQuantityStock.toString());
    controllerTextEditAlertStock = TextEditingController(text: getAlertStock.toString());
    controllerTextEditCategory = TextEditingController(text: getCategory.name);

    // primero verificamos que no tenga el metadato del dato de la marca para hacer un consulta inecesaria
    if (getProduct.idMark != ''){readMarkProducts();} else{ setDataUploadStatusMark = true; }
    if (getProduct.category != ''){readCategory();} else{ setDataUploadStatusCategory = true; }
    if (getProduct.provider != ''){readProvider();} else{ setDataUploadStatusProvider = true; }
  }
  // read : obtiene los datos de la maraca del producto
  void readMarkProducts() {
    //  function : lee la marca del producto
    if (getProduct.idMark.isNotEmpty) {
      Database.readMarkFuture(id: getProduct.idMark).then((value) {
        setMarkSelected = Mark.fromMap(value.data() as Map);
        getProduct.nameMark = getMarkSelected.name; // guardamos un metadato
        setDataUploadStatusMark = true; 
      }).onError((error, stackTrace) {
        setMarkSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
        setDataUploadStatusMark = true;
      }).catchError((_) {
        setMarkSelected = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
        setDataUploadStatusMark = true;
      });
    }
  }
  // read : obtiene los datos de la categoria del producto
  void readCategory() {
    //  function : lee la categoria del producto
    Database.readCategotyCatalogueFuture(idAccount: homeController.getProfileAccountSelected.id, idCategory: getProduct.category)
        .then((value) {
      setCategory = Category.fromDocumentSnapshot(documentSnapshot: value);
      setDataUploadStatusCategory = true;
      }).onError((error, stackTrace) {
        setCategory = Category(id: '', name: '');
        setDataUploadStatusCategory = true;
      }).catchError((_) {
        setCategory = Category(id: '', name: '');
        setDataUploadStatusCategory = true;
      });
  }
  // read : obtiene los datos del proveedor del producto
  void readProvider() {
    //  function : lee el proveedor del producto
    Database.refFirestoreProvider(idAccount:homeController.getIdAccountSelected).doc(getProduct.provider).get().then((value) {
      setProvider = Provider.fromDocumentSnapshot(documentSnapshot: value);
      setDataUploadStatusProvider = true;
    }).onError((error, stackTrace) {
      setProvider = Provider(id: '', name: '');
      setDataUploadStatusProvider = true;
    }).catchError((_) {
      setProvider = Provider(id: '', name: '');
      setDataUploadStatusProvider = true;
    });
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
      formEditing = true;
      update();  //  actualizamos la vista
      next(); //  siguiente componente
    });
  }

  void getLoadImageCamera() {
    //  function : selecciona una imagen de la camara
    _picker.pickImage(source: ImageSource.camera,maxWidth: 720.0,maxHeight: 720.0,imageQuality: 55,)
    // esperamos a que se seleccione la imagen
    .then((value) {
    // set
      formEditing = true; // activamos el formulario
      setXFileImage = value!; // conservamos la imagen
      update();  //  actualizamos la vista
      next(); //  siguiente componente
    });
  }

  //------------------------------------------------------//
  //- FUNCTIONS LOGIC VIEW FORM CREATE NEW PRODUCT START -//
  //------------------------------------------------------//  
   double get getProgressForm{ 
    // function : retorna el progreso del formulario
    // value : progreso del formulario
    double progress = 0.0;
    // estado de progreso hata 9
    switch(getCurrentSlide){
      case 0: progress = 0.0;break;
      case 1: progress = 0.15;break;
      case 2: progress = 0.30;break;
      case 3: progress = 0.45;break;
      case 4: progress = 0.60;break;
      case 5: progress = 0.70;break;
      case 6: progress = 0.80;break;
      case 7: progress = 0.90;break;
      case 8: progress = 0.95;break;
      case 9: progress = 1.0;break;

      default:progress;
    } 
    return progress;
  }
  
  void previousPage(){
    carouselController.animateToPage(getCurrentSlide-1); 
  }
  void next(){
    // function : verificamos que el campo actual este completo para pasar al siguiente campo y complertar el formulario

    // value 
    bool next = true;
    //
    // imagen : este campo es opcional 
    if(getCurrentSlide == 0  ){next=true;}
    //  descripción : este campo es obligatorio
    if(getCurrentSlide == 1 && descriptionFormKey.currentState!.validate()==false ){next=false;}
    //  marca : este campo es obligatorio
    if(getCurrentSlide == 2 && markFormKey.currentState!.validate() == false ){next=false;}

    // category : este campo es opcional
    //... currentSlide : 3

    // precio de compra : este campo es opcional
    //... currentSlide : 4

    // precio de venta al publico: este campo es obligatorio
    if(getCurrentSlide == 6 && salePriceFormKey.currentState!.validate()==false ){next=false;}
    
    // favorito : este campo es opcional
    //... currentSlide : 6

    // control de stock : este campo es opcional
    if(getCurrentSlide == 8 && getStock && quantityStockFormKey.currentState!.validate()==false ){
      Get.snackbar(' Stock no valido 😐', 'debe proporcionar un cantidad');
      next=false;
    }

    // concentimientos del usuario : este campo es obligatorio para crear un producto nuevo
    if(getCurrentSlide == 9 && getUserConsent == false){
      Get.snackbar('Debes aceptar los terminos y condiciones', 'Este campo no puede dejarse vacio',snackPosition: SnackPosition.TOP,snackStyle: SnackStyle.FLOATING,);
      next=false;
    }

    // action : pasa a la siquiente vista si es posible
    if(next){carouselController.nextPage();} 

    update();
 
  }
  //-------------------------------------------------//
  //- FUNCTIONS LOGIC VIEW CREATE NEW PRODUCT FINAL -//
  //-------------------------------------------------//


  // WIDGETS

  void showDialogAddProfitPercentage( ) {
    // Dialog view :  muestra el dialogo para agregar el porcentaje de ganancia

    //var 
    final ButtonStyle buttonStyle = ButtonStyle(padding: MaterialStateProperty.all(const EdgeInsets.all(12)));
    final TextEditingController controller = TextEditingController();

    // widgets
    Widget content = Scaffold(
      appBar: AppBar(
        title: const Text('Porcentaje de beneficio'), 
        automaticallyImplyLeading: false,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[1234567890]'))
                      ],
                      decoration: const InputDecoration( 
                        hintText: '%',
                        labelText: "Porcentaje",
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
                    update();
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
            leading: const Icon(Icons.camera),
            title: const Text('Capturar una imagen'),
            onTap: () {
              getLoadImageCamera();
              Get.back();
              
            }),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text('Seleccionar desde la galería de fotos'),
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
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
  // dialog : muestra el dialogo para eliminar el producto
  void showDialogDelete() {
    Widget widget = AlertDialog(
      title: const Text("¿Seguro que quieres eliminar este producto de tu catálogo?"),
      content: const Text("El producto será eliminado de tu catálogo y toda la información acumulada"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          onPressed: ()=> deleteProductInCatalogue(),
          child: const Text('Si, eliminar'),
        ),
      ],
    );

    Get.dialog(widget);
  }
  // bottomSheet : muestra el modal para seleccionar la categoria
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
    update();
  }

  setCheckVerified({required bool value}) {
    getProduct.verified = value;
    update();
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
      Database.readProductPublicFuture(id: id).then((value) {
        //  get
        Product product = Product.fromMap(value.data() as Map);
        //  set
        setProduct = getProduct.updateData(product: product);
        setDataUploadStatusProduct = true;
        loadDataFormProduct(); // carga los datos del producto en el formulario
        
      }).catchError((error) {
        printError(info: error.toString());
        setDataUploadStatus = false;
      }).onError((error, stackTrace) {
        loadDataFormProduct();
        printError(info: error.toString()); 
      });
    }
  }
  void increaseFollowersProductPublic() {
    // function : aumenta el valor de los seguidores del producto publico
    Database.refFirestoreProductPublic().doc(getProduct.id).update({'followers': FieldValue.increment(1)});
    // actualizamos el valor de los seguidores del producto
    getProduct.followers++;
    update();
  }
  void showDialogSaveOPTDeveloper() {
    Get.dialog(AlertDialog(
      title:
          const Text("¿Seguro que quieres actualizar este docuemnto? (Mods)"),
      content: const Text(
          "El producto será actualizado de tu catálogo ,de la base de dato global y toda la información acumulada menos el historial de precios registrado"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => Get.back(),
        ),
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
  ControllerCreateProductForm controllerProductNew = Get.find();
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
      body: list.isEmpty ? widgetAnimLoad : viewListState ? bodyList : bodyGrid,
    );
  }
  // WIDGETS VIEW 
  Widget get bodyList {


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
  Widget get bodyGrid {
    
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
  Widget get widgetAnimLoad {
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

    // buscar cátegoria

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;


    showSearch(
      context: context,
      delegate: SearchPage<Mark>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: list,
        searchLabel: 'Buscar marca',
        suggestion: const Center(child: Text('ej. Miller')),
        failure: const Center(child: Text('No se encontro :(')),
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
        controllerProductNew.setUltimateSelectionMark = marcaSelect;
        controllerProductNew.setMarkSelected = marcaSelect;
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
          const SizedBox(height:2),
          Text(marcaSelect.name,style: const TextStyle(fontWeight: FontWeight.w400 ),textAlign: TextAlign.center,),
        ],
      ),
    );
  }
  Widget itemList({required Mark marcaSelect, bool icon = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      trailing:!icon? null  :marcaSelect.image==''?null: ImageProductAvatarApp(url: marcaSelect.image,size: 50,description:marcaSelect.name),
      dense: true,
      title: Text(marcaSelect.name,overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
      subtitle: marcaSelect.description == ''
          ? null
          : Text(marcaSelect.description, overflow: TextOverflow.ellipsis),
      onTap: () {
        controllerProductNew.setUltimateSelectionMark = marcaSelect;
        controllerProductNew.setMarkSelected = marcaSelect;
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
    if (controllerProductNew.getMarks.isEmpty) {
      await Database.readListMarksFuture().then((value) {
        setState(() {
          for (var element in value.docs) {
            Mark mark = Mark.fromMap(element.data());
            mark.id = element.id;
            list.add(mark);
          }
          updateListMarkSelected();
          controllerProductNew.setMarks = list;
        });
      });
    } else {
      // datos ya descargados
      list = controllerProductNew.getMarks;
      updateListMarkSelected();
      setState(() => list = controllerProductNew.getMarks);
    }

  }
  updateListMarkSelected() {
    //  description : posicionamos el ultimo item seleccionado por el usuario en el segundo lugar 
    //                para que el usuario pueda encontrarlo facilmente

    // comprobamos que ahi un item seleccionado
    if (controllerProductNew.getUltimateSelectionMark.id != '') {
      // eliminamos el item seleccionado de la lista
      list.removeWhere((element) => element.id == controllerProductNew.getUltimateSelectionMark.id);
      // insertamos el item seleccionado en la segunda posicion de la lista
      list.insert(1, controllerProductNew.getUltimateSelectionMark);
    }

    // eliminamos el item con la id 'other' de la lista
    list.removeWhere((element) => element.id == 'other');
    // insertar en la primera posicion de la lista 
    list.insert(0, Mark(id: 'other',name: 'Otro',upgrade: Timestamp.now(),creation: Timestamp.now()));
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
  final ControllerCreateProductForm controllerProductCreateNew = Get.find();

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

    // style 
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
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value,
            decoration: InputDecoration(
                filled: true, 
                fillColor: fillColor,
                labelText: "Descripción (opcional)"),
            style: textStyle,
          ),
        ),
      ],
    );
  }

  //  MARK CREATE
  void getLoadImageMark() {
    _picker
        .pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    )
        .then((value) {
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
        controllerProductCreateNew.getMarks.remove(widget.mark);
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
        // creamos un docuemnto nuevo
        await Database.refFirestoreMark().doc(widget.mark.id).set(widget.mark.toJson()).whenComplete(() {

          // set values 
          controllerProductCreateNew.setUltimateSelectionMark = widget.mark;
          controllerProductCreateNew.setMarkSelected = widget.mark;
          // agregar el obj manualmente para evitar consulta a la db  innecesaria
          controllerProductCreateNew.getMarks.add(widget.mark);
          Get.back();
        });
      }else{
        // actualizamos un documento existente
        await Database.refFirestoreMark().doc(widget.mark.id).update(widget.mark.toJson()).whenComplete(() {

          // set values
          controllerProductCreateNew.setUltimateSelectionMark = widget.mark;
          controllerProductCreateNew.setMarkSelected = widget.mark;
          // eliminamos la marca de la lista
          controllerProductCreateNew.getMarks.removeWhere((element) => (element.id == widget.mark.id));
          // agregamos la nueva marca actualizada a la lista
          controllerProductCreateNew.getMarks.add(widget.mark);
          Get.back();
        });
      }

    } else {
      Get.snackbar('', 'Debes escribir un nombre de la marca');
    }
  }

}


