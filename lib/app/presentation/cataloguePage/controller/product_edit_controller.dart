import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_page/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';

class ControllerProductsEdit extends GetxController {

  // var style
  Color cardProductDetailColor = Colors.grey.withOpacity(0.2);
  bool darkMode = false;


  // controller : carousel de componentes para que el usuario complete los campos necesarios para crear un nuevo producto nuevo
  CarouselController carouselController = CarouselController();
  // var : logic  para que el usuario complete los campos necesarios para crear un nuevo producto nuevo
  int currentSlide = 0 ;
  bool formEditing = false;
  bool formComplete = false;
  bool checkValidateForm = false;
  bool enabledButton = false;
  // var : TextFormField
  final descriptionTextFormFieldfocus = FocusNode(); 
  final purchasePriceTextFormFieldfocus = FocusNode(); 
  final salePriceTextFormFieldfocus = FocusNode(); 
  final formKey = GlobalKey<FormState>(); // Crear una clave global que identifique de forma única el widget de formulario y permite la validación del formulario.


  // others controllers
  final HomeController homeController = Get.find();


  Future<void> categoryDelete({required String idCategory}) async => await Database.refFirestoreCategory(idAccount: homeController.getProfileAccountSelected.id).doc(idCategory).delete();
  Future<void> categoryUpdate({required Category categoria}) async {
    // ref
    var documentReferencer = Database.refFirestoreCategory(idAccount: homeController.getProfileAccountSelected.id).doc(categoria.id);
    // Actualizamos los datos
    documentReferencer.set(Map<String, dynamic>.from(categoria.toJson()),SetOptions(merge: true))
        .whenComplete(() {
      print("######################## FIREBASE updateAccount whenComplete");
    }).catchError((e) => print(
            "######################## FIREBASE updateAccount catchError: $e"));
  }

  // concentimiento del usuario
  bool _userConsent = false;
  set setUserConsent(bool value) {
    _userConsent = value;
    update(['updateAll']);
  }
  bool get getUserConsent => _userConsent;

  // category list
  final RxList<Category> _categoryList = <Category>[].obs;
  List<Category> get getCatalogueCategoryList => _categoryList;
  set setCatalogueCategoryList(List<Category> value) {
    _categoryList.value = value;
    update(['tab']);
  }

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

  static Mark _ultimateSelectionMark2 = Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setUltimateSelectionMark2(Mark value) => _ultimateSelectionMark2 = value;
  Mark get getUltimateSelectionMark2 => _ultimateSelectionMark2;

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
  bool get itsInTheCatalogue => _itsInTheCatalogue;

  // variable para mostrar al usuario una viste para editar o crear un nuevo producto
  bool _newProduct = true;
  set setNewProduct(bool value) => _newProduct = value;
  bool get getNewProduct => _newProduct;

  // variable para editar el documento en modo de moderador
  bool _editModerator = false;
  set setEditModerator(bool value) {
    _editModerator = value;
    update(['updateAll']);
  }

  bool get getEditModerator => _editModerator;

  // parameter
  ProductCatalogue _product = ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
  set setProduct(ProductCatalogue product) => _product = product;
  ProductCatalogue get getProduct => _product;

  // TextEditingController
  TextEditingController controllerTextEditDescripcion = TextEditingController();
  TextEditingController controllerTextEditMark = TextEditingController();
  TextEditingController controllerTextEditCategory = TextEditingController();
  TextEditingController controllerTextEditQuantityStock = TextEditingController();
  TextEditingController controllerTextEditAlertStock = TextEditingController();
  MoneyMaskedTextController controllerTextEditPrecioVenta = MoneyMaskedTextController();
  MoneyMaskedTextController controllerTextEditPrecioCompra = MoneyMaskedTextController();

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

  //  category
  Category _category = Category();
  set setCategory(Category value) {
    _category = value;
    getProduct.category = value.id;
    getProduct.nameCategory = value.name;
    controllerTextEditCategory.text = value.name;
    update(['updateAll']);
  }

  Category get getCategory => _category;


  // imagen
  final ImagePicker _picker = ImagePicker();
  XFile _xFileImage = XFile('');
  set setXFileImage(XFile value) => _xFileImage = value;
  XFile get getXFileImage => _xFileImage;

  // indicardor para cuando se guarde los datos
  bool _saveIndicador = false;
  set setSaveIndicator(bool value) => _saveIndicador = value;
  bool get getSaveIndicator => _saveIndicador;

  @override
  void onInit() {
    // llamado inmediatamente después de que se asigna memoria al widget

    // state account auth
    setAccountAuth = homeController.getIdAccountSelected != '';

    // se obtiene el parametro y decidimos si es una vista para editrar o un producto nuevo
    setNewProduct = Get.arguments['new'] ?? false;
    // obtenemos el producto por parametro
    ProductCatalogue productFinal = Get.arguments['product'] ?? ProductCatalogue(documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now(),upgrade: Timestamp.now(), creation: Timestamp.now());
    //  si es un producto nuevo se le asigna solo el codigo del producto
    if(getNewProduct){productFinal = ProductCatalogue(documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now(),upgrade: Timestamp.now(), creation: Timestamp.now()).copyWith(code:productFinal.code );}
    //  finalmente  asigna el producto
    setProduct = productFinal;
    // load data product
    if (getNewProduct == false) {
      // el documento existe
      isCatalogue();
      getDataProduct(id: getProduct.id);
    }else{
      loadDataFormProduct();
    }

    super.onInit();
  }

  @override
  void onReady() {
    // llamado después de que el widget se representa en la pantalla - ej. showIntroDialog(); //
    super.onReady();
  }

  @override
  void onClose() {
    // llamado justo antes de que el controlador se elimine de la memoria - ej. closeStream(); //
    super.onClose();
  }

  // get 
  bool get isSubscribed => homeController.getProfileAccountSelected.subscribed;

  // FUNCTIONES
  set setStock(bool value) {
    if( homeController.getProfileAccountSelected.subscribed == false ){
      homeController.showModalBottomSheetSubcription(id: 'stock');
    }else{
      getProduct.stock = value;
      update(['updateAll']);
    }
    
  }
  set setFavorite(bool value) {
    getProduct.favorite = value;
    update(['updateAll']);
  }

  updateAll() => update(['updateAll']);
  back() => Get.back();

  isCatalogue() {
    for (var element in homeController.getCataloProducts) {
      if (element.id == getProduct.id) {
        // get values
        setItsInTheCatalogue = true;
        setProduct = element;
        update(['updateAll']);
      }
    }
  }

  Future<void> save() async {
    if (getProduct.id != '') {
      if (getProduct.description != '') {
        if (getProduct.idMark != '' && getProduct.nameMark != '') {


          if (getProduct.salePrice != 0 && getAccountAuth ||getProduct.salePrice == 0 && getAccountAuth == false) {
            if ((getProduct.stock) ? (getProduct.quantityStock >= 1) : true) {

              // Deshabilitar la guía del usuario del catálogo
              homeController.disableCatalogUserGuide();
              
              // update view
              setSaveIndicator = true;
              setTextAppBar = 'Espere por favor...';
              updateAll();

              // set : marca de tiempo
              getProduct.upgrade = Timestamp.now();
              // actualización de la imagen de perfil de la cuetna
              if (getXFileImage.path != '') {
                // image - Si el "path" es distinto '' quiere decir que ahi una nueva imagen para actualizar
                // si es asi procede a guardar la imagen en la base de la app
                Reference ref = Database.referenceStorageProductPublic(id: getProduct.id);
                UploadTask uploadTask = ref.putFile(File(getXFileImage.path));
                await uploadTask;
                // obtenemos la url de la imagen guardada
                await ref.getDownloadURL().then((value) => getProduct.image = value);
              }
              // procede agregrar el producto en el cátalogo
              // Mods - save data product global
              if (getNewProduct || getEditModerator) {
                  setProductPublicFirestore(product: getProduct.convertProductoDefault());
              }
              
              // Registra el precio en una colección publica
                Price precio = Price(
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
                // Firebase set : se guarda un documento con la referencia del precio del producto
                Database.refFirestoreRegisterPrice(idProducto: getProduct.id, isoPAis: 'ARG').doc(precio.id).set(precio.toJson());

                // Firebase set : se actualiza los datos del producto del cátalogo de la cuenta
                if(getNewProduct){
                  Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id)
                    .set(getProduct.toJson())
                    .whenComplete(() async {
                      await Future.delayed(const Duration(seconds: 3)).then((value) {setSaveIndicator = false; Get.back();});
                    }).onError((error, stackTrace) => setSaveIndicator = false).catchError((_) => setSaveIndicator = false);
                }else{
                  if(itsInTheCatalogue){
                    Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id)
                      .update(getProduct.toJson())
                      .whenComplete(() async {
                        await Future.delayed(const Duration(seconds: 3)).then((value) {setSaveIndicator = false; Get.back(); });
                    }).onError((error, stackTrace) => setSaveIndicator = false).catchError((_) => setSaveIndicator = false);
                  }else{
                    Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(getProduct.id)
                      .set(getProduct.toJson())
                      .whenComplete(() async {
                        await Future.delayed(const Duration(seconds: 3)).then((value) {setSaveIndicator = false; Get.back(); });
                    }).onError((error, stackTrace) => setSaveIndicator = false).catchError((_) => setSaveIndicator = false);
                  }
                }
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
    }
  }

  void saveProductPublic() async {
    // esta función procede a guardar el documento de una colleción publica

    if (getProduct.id != '') {
      if (getProduct.description != '') {
        if (getProduct.idMark != '') {

            // activate - indicator load
            setSaveIndicator = true;
            setTextAppBar = 'Espere por favor...';
            updateAll();
            
            // values 
            Product product = getProduct.convertProductoDefault();

            // actualización de la imagen de perfil de la cuetna
            if (getXFileImage.path != '') {
              // image - Si el "path" es distinto '' quiere decir que ahi una nueva imagen para actualizar
              // si es asi procede a guardar la imagen en la base de la app
              Reference ref = Database.referenceStorageProductPublic(id: product.id);
              UploadTask uploadTask = ref.putFile(File(getXFileImage.path));
              await uploadTask;
              // obtenemos la url de la imagen guardada
              await ref.getDownloadURL().then((value) => product.image = value);
            }

            // set firestore
            if(getNewProduct){
              Database.refFirestoreProductPublic().doc(product.id).set(product.toJson()).whenComplete(() {
                Get.back();
                Get.snackbar('Estupendo 😃', 'Gracias por contribuir a la comunidad');
              });
            }else{
              Database.refFirestoreProductPublic().doc(product.id).update(product.toJson()).whenComplete(() {
                Get.back();
                Get.snackbar('Estupendo 😃', 'Gracias por contribuir a la comunidad');
              });
            }
            
        } else {
          Get.snackbar('No se puedo continuar 😐', 'debes seleccionar una marca');
        }
      } else {
        Get.snackbar('No se puedo continuar 👎','debes escribir una descripción del producto');
      }
    }
  }
  void setProductPublicFirestore({required Product product})  {
    // esta función procede a guardar el documento de una colleción publica
    
    //  set : id de la cuenta desde la cual se creo el producto
    product.idAccount = homeController.getProfileAccountSelected.id; 
    //  set : marca de tiempo que se creo el documenti por primera vez
    if(getNewProduct) { product.creation = Timestamp.fromDate(DateTime.now()); } 
    //  set : marca de tiempo que se actualizo el documenti
    product.upgrade = Timestamp.fromDate(DateTime.now());
    //  set : id del usuario que creo el documentoi 
    if(getNewProduct) { product.idUserCreation = homeController.getProfileAdminUser.email;}
    //  set : id del usuario que actualizo el documento
    product.idUserUpgrade = homeController.getProfileAdminUser.email;

    // set firestore - save product public
    if(getNewProduct){
      Database.refFirestoreProductPublic().doc(product.id).set(product.toJson());
    }else{
      Database.refFirestoreProductPublic().doc(product.id).update(product.toJson());
    }
  }

  void deleteProducPublic() async {
    // activate indicator load
    setSaveIndicator = true;
    setTextAppBar = 'Eliminando...';
    updateAll();

    // delete doc product in catalogue account
    await Database.refFirestoreCatalogueProduct(
            idAccount: homeController.getProfileAccountSelected.id)
        .doc(getProduct.id)
        .delete();
    // delete doc product
    await Database.refFirestoreProductPublic()
        .doc(getProduct.id)
        .delete()
        .whenComplete(() {
      Get.back();
      Get.back();
    });
  }

  void getDataProduct({required String id}) {
    // lee el documento del producto
    if (id != '') {
      Database.readProductPublicFuture(id: id).then((value) {
        //  get
        Product product = Product.fromMap(value.data() as Map);
        //  set
        setProduct = getProduct.updateData(product: product);
        loadDataFormProduct();
        
      }).catchError((error) {
        printError(info: error.toString());
      }).onError((error, stackTrace) {
        loadDataFormProduct();
        printError(info: error.toString());
      });
    }
  }

  void loadDataFormProduct() {
    // set
    controllerTextEditDescripcion =TextEditingController(text: getProduct.description);
    controllerTextEditPrecioVenta =MoneyMaskedTextController(initialValue: getProduct.salePrice);
    controllerTextEditPrecioCompra =MoneyMaskedTextController(initialValue: getProduct.purchasePrice);
    controllerTextEditQuantityStock =TextEditingController(text: getProduct.quantityStock.toString());
    controllerTextEditAlertStock = TextEditingController(text: getProduct.alertStock.toString());
    // primero verificamos que no tenga el metadato del dato de la marca para hacer un consulta inecesaria
    if (getProduct.idMark != '') readMarkProducts();
    if (getProduct.category != '') readCategory();
  }

  void readMarkProducts() {
    if (getProduct.idMark.isNotEmpty) {
      Database.readMarkFuture(id: getProduct.idMark).then((value) {
        setMarkSelected = Mark.fromMap(value.data() as Map);
        getProduct.nameMark = getMarkSelected.name; // guardamos un metadato
        update(['updateAll']);
      }).onError((error, stackTrace) {
        setMarkSelected =
            Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
      }).catchError((_) {
        setMarkSelected =
            Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
      });
    }
  }

  void readCategory() {
    Database.readCategotyCatalogueFuture(
            idAccount: homeController.getProfileAccountSelected.id,
            idCategory: getProduct.category)
        .then((value) {
      setCategory = Category.fromDocumentSnapshot(documentSnapshot: value);
    }).onError((error, stackTrace) {
      setCategory = Category(id: '0000', name: '');
    }).catchError((_) {
      setCategory = Category(id: '0000', name: '');
    });
  }


  // read XFile image
  void getLoadImageGalery() {
    _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    ).then((value) {
      setXFileImage = value!;
      formEditing = true;
      update(['updateAll']);  //  actualizamos la vista
      next(); //  siguiente componente
    });
  }

  void getLoadImageCamera() {
    _picker
        .pickImage(
      source: ImageSource.camera,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    )
    .then((value) {
      formEditing = true;
      setXFileImage = value!;
      update(['updateAll']);  //  actualizamos la vista
      next(); //  siguiente componente
    });
  }

  //-------------------------------------------------//
  //- FUNCTIONS LOGIC VIEW CREATE NEW PRODUCT START -//
  //-------------------------------------------------//
  void checkValidatorFroms({required bool check}){
    // function : validamos el formulario

    // button onClick
    if(check){
      formKey.currentState!.validate();
    }
    // onchange texfieldFrom
    if(check = false & checkValidateForm){
      formKey.currentState!.validate();
    }
    // comprobamos si los datos estan completos
    enabledButton = getProduct.isComplete;

    // set values 
    checkValidateForm = check;
  }
  void saveProductNewForm() async {
    // function : procedemos a verificar el formulario y simular el salvado de los datos con una animacion
    
    if(getProduct.isComplete){
       // Validar devuelve verdadero si el formulario es válido o falso en caso contrario.
      checkValidateForm=true;
      // validate : Si el formulario es válido,
      if (formKey.currentState!.validate()) { 
        // view : animated
        formComplete = true; 
        
        // actualizamos el estado de las vistas
        update(['updateAll']); 
      }
    }else{ 
      //  view : snackbar
      Get.snackbar('Complete el formulario', 'Algunos campos requieren ser completados',snackPosition: SnackPosition.BOTTOM,snackStyle: SnackStyle.FLOATING,);
    }
  }
   double get getProgressForm{
    // value : progreso del formulario
    double progress = 0.0;
    // estado de progreso
    switch(currentSlide){
      case 0:progress = 0.11; break;
      case 1:progress = 0.22; break;
      case 2:progress = 0.33; break;
      case 3:progress = 0.44; break;
      case 4:progress = 0.55; break;
      case 5:progress = 0.66; break;
      case 6:progress = 0.77; break;
      case 7:progress = 0.88; break;
      case 8:progress = 1.0; break;
      default:progress;
    } 
    return progress;
  }
  
  void previousPage(){
    carouselController.animateToPage(currentSlide-1);
  }
  void next(){
    // function : verificamos que el campor actual este completo para pasar al siguiente campo y complertar el formulario

    // value 
    bool next = true;
    //
    // imagen : este campo es opcional 
    if(currentSlide == 0  ){next=true; }
    //  descripción : este campo es obligatorio
    if(currentSlide == 1 && getProduct.description == ''){
      Get.snackbar('Debes ingresar una descripción', 'Este campo no puede dejarse vacio',snackPosition: SnackPosition.TOP,snackStyle: SnackStyle.FLOATING,);
      next=false;
    }
    //  marca : este campo es obligatorio
    if(currentSlide == 2 && getProduct.nameMark == ''){
      Get.snackbar('Debes elegir la marca el producto', 'Este campo no puede dejarse vacio',snackPosition: SnackPosition.TOP,snackStyle: SnackStyle.FLOATING,);
      next=false;
    } 

    // category : este campo es opcional
    //... currentSlide : 3

    // precio de compra : este campo es opcional
    //... currentSlide : 4

    // precio de venta al publico: este campo es obligatorio
    if(currentSlide == 5 && getProduct.salePrice == 0){
      Get.snackbar('Debes ingresar el precio de venta al publico', 'Este campo no puede dejarse vacio',snackPosition: SnackPosition.TOP,snackStyle: SnackStyle.FLOATING,);
      next=false;
    }
    
    // favorito : este campo es opcional
    //... currentSlide : 6

    // control de stock : este campo es opcional
    //... currentSlide : 7

    // concentimientos del usuario : este campo es obligatorio para crear un producto nuevo
    if(currentSlide == 8 && getUserConsent == false){
      Get.snackbar('Debes aceptar los terminos y condiciones', 'Este campo no puede dejarse vacio',snackPosition: SnackPosition.TOP,snackStyle: SnackStyle.FLOATING,);
      next=false;
    }

    // carrousel textfield : pasa a la siquiente vista si es posible
    if(next){carouselController.nextPage();} 

    // el formulario esta completo
    if(currentSlide == 8 && getUserConsent){save();}

    // actualizamos el estado de las vistas
    update(['updateAll']);
  }
  //-------------------------------------------------//
  //- FUNCTIONS LOGIC VIEW CREATE NEW PRODUCT FINAL -//
  //-------------------------------------------------//


  // WIDGETS

  Widget loadImage({double size = 120}) {

    // devuelve la imagen del product
    if (getXFileImage.path != '') {
      // el usuario cargo un nueva imagen externa
      return ImageAvatarApp(path: getXFileImage.path ,size: size,onTap: getNewProduct || getEditModerator? showModalBottomSheetCambiarImagen : null );
    } else {
      // se visualiza la imagen del producto
      return ImageAvatarApp(url: getProduct.image ,size: size,onTap: getNewProduct || getEditModerator? showModalBottomSheetCambiarImagen : null );
    }
  }

  void showModalBottomSheetCambiarImagen() {
    Widget widget =   Wrap(
      children: <Widget>[
        ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Capturar una imagen'),
            onTap: () {
              Get.back();
              getLoadImageCamera;
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

  void showDialogDelete() {
    Widget widget = AlertDialog(
      title: const Text(
          "¿Seguro que quieres eliminar este producto de tu catálogo?"),
      content: const Text(
          "El producto será eliminado de tu catálogo y toda la información acumulada"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('Si, eliminar'),
          onPressed: () {
            Database.refFirestoreCatalogueProduct(
                    idAccount: homeController.getProfileAccountSelected.id)
                .doc(getProduct.id)
                .delete()
                .whenComplete(() {
                  Get.back();
                  back();
                  back();
                })
                .onError((error, stackTrace) => Get.back())
                .catchError((ex) => Get.back());
          },
        ),
      ],
    );

    Get.dialog(widget);
  }

  showModalSelectMarca() {
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

  //TODO: eliminar para release
  // DEVELOPER OPTIONS
  setOutstanding({required bool value}) {
    getProduct.outstanding = value;
    update(['updateAll']);
  }

  setCheckVerified({required bool value}) {
    getProduct.verified = value;
    update(['updateAll']);
  }

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
            save();
          },
        ),
      ],
    ));
  }

  Widget get widgetTextButtonAddProduct{
    // widget : este texto button se va a mostrar por unica ves 

    // comprobamos si es la primera ves que se inicia la aplicación
    if(homeController.catalogUserHuideVisibility && !homeController.isCatalogue(id: getProduct.id)){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50,left: 12,right: 12,bottom: 20),
            child: Opacity(opacity: 0.8,child: Text('¡Eso es todo 😃!',textAlign: TextAlign.center,style: TextStyle(fontSize: 20))),
          ),
          TextButton(onPressed: save,child: const Text('Agregar a mi cátalogo')),
        ],
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
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
          IconButton(icon: const Icon(Icons.search),onPressed: () {Get.back();showSeachMarks();})
        ],
      ),
      body: list.isEmpty
          ? widgetAnimLoad()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {

                //  values
                Mark marcaSelect = list[index];

                if (index == 0) {
                  return Column(
                    children: [
                      getWidgetOptionOther(),
                      const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                      controllerProductsEdit.getUltimateSelectionMark.id ==
                                  '' ||
                              controllerProductsEdit
                                      .getUltimateSelectionMark.id ==
                                  'other'
                          ? Container()
                          : listTile(
                              marcaSelect: controllerProductsEdit
                                  .getUltimateSelectionMark),
                      const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                      listTile(marcaSelect: marcaSelect),
                      const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                    ],
                  );
                }
                return Column(
                  children: <Widget>[
                    listTile(marcaSelect: marcaSelect),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0,thickness: 0.1),
                  ],
                );
              },
            ),
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

  Widget getWidgetOptionOther() {
    //values
    late Widget widget;
    // recorre la la de marcas para buscar la informaciób de opción 'other'
    if (controllerProductsEdit.getMarks.isEmpty) {
      widget = Container();
    } else {
      for (var element in controllerProductsEdit.getMarks) {
        if (element.id == 'other') {
          widget = listTile(
            marcaSelect: element,
          );
        }
      }
    }
    return widget;
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
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent),
        items: list,
        searchLabel: 'Buscar marca',
        suggestion: const Center(child: Text('ej. Miller')),
        failure: const Center(child: Text('No se encontro :(')),
        filter: (product) => [product.name,product.description],
        builder: (mark) => Column(mainAxisSize: MainAxisSize.min,children: <Widget>[listTile(marcaSelect: mark),const Divider(height: 0)]),
      ),
    );
  }

  Widget listTile({required Mark marcaSelect, bool icon = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      trailing:!icon? null  : ImageAvatarApp(url: marcaSelect.image,size: 50,description:marcaSelect.name),
      dense: true,
      title: Text(marcaSelect.name,overflow: TextOverflow.ellipsis),
      subtitle: marcaSelect.description == ''
          ? null
          : Text(marcaSelect.description, overflow: TextOverflow.ellipsis),
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
      await Database.readListMarksFuture().then((value) {
        setState(() {
          for (var element in value.docs) {
            Mark mark = Mark.fromMap(element.data());
            mark.id = element.id;
            list.add(mark);
          }
          controllerProductsEdit.setMarks = list;
        });
      });
    } else {
      // datos ya descargados
      list = controllerProductsEdit.getMarks;
      setState(() => list = controllerProductsEdit.getMarks);
    }
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
    Color? colorAccent = Get.theme.textTheme.bodyText1!.color;

    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Text(title, style: TextStyle(color: colorAccent)),
      centerTitle: true,
      iconTheme: Get.theme.iconTheme.copyWith(color: colorAccent),
      actions: [
        newMark || load ? Container(): IconButton(onPressed: delete, icon: const Icon(Icons.delete)),
        load? Container() : IconButton(icon: const Icon(Icons.check),onPressed: save),
      ],
      bottom: load ? ComponentApp.linearProgressBarApp() : null,
    );
  }

  Widget body() {

    // widgets
    Widget circleAvatarDefault = CircleAvatar(backgroundColor: Colors.grey.shade300,radius: 75.0);
    
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
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: "Nombre de la marca"),
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
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



