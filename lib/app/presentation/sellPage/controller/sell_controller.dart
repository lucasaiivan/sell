import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:search_page/search_page.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/data/datasource/database_cloud.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../domain/entities/ticket_model.dart';

class SalesController extends GetxController {


  String valueResponseChatGpt = 'Vender'; 

  // others controllers
  final HomeController homeController = Get.find();
  late AnimationController floatingActionButtonAnimateController;
  late AnimationController newProductSelectedAnimationController;

  void animateAdd({bool itemListAnimated=true }){
    try{
      if(itemListAnimated){newProductSelectedAnimationController.repeat();}
    }catch(_){}
    floatingActionButtonAnimateController.repeat();
  }

  // productos seleccionados recientemente
  List<ProductCatalogue> get getRecentlySelectedProductsList => homeController.getProductsOutstandingList;

  // efecto de sonido para escaner
  void playSoundScan() async {AudioCache cache = AudioCache();cache.load("soundBip.mp3");}

  // text field controllers
  final TextEditingController textEditingControllerAddFlashPrice = TextEditingController();
  final TextEditingController textEditingControllerAddFlashDescription =TextEditingController();
  final TextEditingController textEditingControllerTicketMount =TextEditingController();

  // xfiel : imagen temporal del producto
  XFile _xFileImageCaptureBarCode = XFile('');
  set setXFileImage(XFile value) => _xFileImageCaptureBarCode = value;
  XFile get getXFileImage => _xFileImageCaptureBarCode;

  // list : lista de productos seleccionados por el usaurio para la venta
  List get getListProductsSelested => homeController.listProductsSelected;
  set setListProductsSelected(List value) => homeController.listProductsSelected = value;
  void addProduct({required ProductCatalogue product}) {
    product.quantity = 1;
    product.select = false;
    homeController.listProductsSelected.add(product);
    update();
  }
  //  list : lista de productos seleccionados por el usaurio para la venta
  set removeProduct(String id) {
    List newList = [];
    for (ProductCatalogue product in homeController.listProductsSelected) {
      if (product.id != id) {newList.add(product);}
    }
    setListProductsSelected = newList;
    update();
  }
  //  list : lista de productos seleccionados por el usaurio para la venta
  int get getListProductsSelestedLength {
    int count = 0;
    for (ProductCatalogue element in getListProductsSelested) {
      count += element.quantity;
    }
    return count;
  }

  // cash Register Number : obtenemos la caja seleccionada por el usuario en el dispositivo que es actualmente utilizada
  int cashRegisterNumber=1;
  void getCashRegisterNumber(){
    cashRegisterNumber = GetStorage().read('cashRegisterNumber') ?? 1; 
  }
  //  cash Register Number : obtenemos la caja seleccionada por el usuario en el dispositivo que es actualmente utilizada
  void setCashRegisterNumber({required int number})async{
    cashRegisterNumber=number;
    await GetStorage().write('cashRegisterNumber', number);
    update();
    
  }

  // ticket
  TicketModel ticket = TicketModel(creation: Timestamp.now(), listPoduct: []);
  TicketModel get getTicket => ticket;
  set setTicket(TicketModel value) => ticket = value;
  set setPayModeTicket(String value) {
    ticket.payMode = value;
    update();
  }

  // state cofirnm purchase ticket view
  final RxBool _stateConfirmPurchase = false.obs;
  bool get getStateConfirmPurchase => _stateConfirmPurchase.value;
  set setStateConfirmPurchase(bool value) =>
      _stateConfirmPurchase.value = value;

  // state ticket view
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  // mount  ticket
  final RxDouble _valueReceivedTicket = 0.0.obs;
  double get getValueReceivedTicket => _valueReceivedTicket.value;
  set setValueReceivedTicket(double value) {_valueReceivedTicket.value = value; }


  @override
  void onInit() async {
    super.onInit(); 
    getCashRegisterNumber();

  }
  @override
  void onClose() {
    textEditingControllerAddFlashDescription.dispose();
    textEditingControllerAddFlashPrice.dispose();
    textEditingControllerTicketMount.dispose();
  }


  // FIREBASE
 
  Future<void> save({required ProductCatalogue product}) async {
    //  fuction : comprobamos los datos necesarios para proceder publicar el producto
    
    // actualización de la imagen del producto si existe una imagen nueva
    if (getXFileImage.path != '') {
      // image - Si el "path" es distinto '' quiere decir que ahi una nueva imagen para actualizar
      // si es asi procede a guardar la imagen en la base de la app
      Reference ref = Database.referenceStorageProductPublic(id: product.id); // obtenemos la referencia en el storage
      UploadTask uploadTask = ref.putFile(File(getXFileImage.path)); // cargamos la imagen
      await uploadTask; // esperamos a que se suba la imagen 
      await ref.getDownloadURL().then((value) => product.image = value); // obtenemos la url de la imagen
    }

    // Registra el precio en una colección publica
    Price precio = Price(
      id: homeController.getProfileAccountSelected.id,
      idAccount: homeController.getProfileAccountSelected.id,
      imageAccount: homeController.getProfileAccountSelected.image,
      nameAccount: homeController.getProfileAccountSelected.name,
      price: product.salePrice,
      currencySign: product.currencySign,
      province: homeController.getProfileAccountSelected.province,
      town: homeController.getProfileAccountSelected.town,
      time: Timestamp.fromDate(DateTime.now()),
    );
    // Firebase set : se guarda un documento con la referencia del precio del producto
    Database.refFirestoreRegisterPrice(idProducto: product.id, isoPAis: 'ARG').doc(precio.id).set(precio.toJson());
    // Firebase set : se guarda un documento con la referencia del producto en el cátalogo de la cuenta
    Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(product.id).set(product.toJson());

    setProductPublicFirestore(product: product.convertProductoDefault(),isNew: true);

  }
  void setProductPublicFirestore({required Product product,required bool isNew})  {
    // esta función procede a guardar el documento de una colleción publica
    
    //  set : id de la cuenta desde la cual se creo el producto
    product.idAccount = homeController.getProfileAccountSelected.id; 
    //  set : marca de tiempo que se creo el documenti por primera vez
    if(isNew) { product.creation = Timestamp.fromDate(DateTime.now()); } 
    //  set : marca de tiempo que se actualizo el documenti
    product.upgrade = Timestamp.fromDate(DateTime.now());
    //  set : id del usuario que creo el documentoi 
    if(isNew) { product.idUserCreation = homeController.getProfileAdminUser.email;}
    //  set : id del usuario que actualizo el documento
    product.idUserUpgrade = homeController.getProfileAdminUser.email;

    // set firestore - save product public
    if(isNew){
      Database.refFirestoreProductPublic().doc(product.id).set(product.toJson());
    }else{
      Database.refFirestoreProductPublic().doc(product.id).update(product.toJson());
    }
  }

  void registerTransaction() {

    // Procederemos a guardar un documento con la transacción

    // get values 
    var id = Publications.generateUid(); // generate id
    List listIdsProducts = [];

    for (var element in getListProductsSelested) {
      // generamos una nueva lista con los id de los productos seleccionados
      listIdsProducts.add(element.toJson());
    }
    //  set values
    getTicket.cashRegister = cashRegisterNumber.toString();
    getTicket.id = id;
    getTicket.seller = homeController.getUserAuth.email!;
    getTicket.listPoduct = listIdsProducts;
    getTicket.priceTotal = getCountPriceTotal();
    getTicket.valueReceived = getValueReceivedTicket;
    getTicket.creation = Timestamp.now();
    // set firestore : guarda la transacción
    Database.refFirestoretransactions(idAccount: homeController.getIdAccountSelected).doc(getTicket.id).set(getTicket.toJson());
    for (Map element in listIdsProducts) {

      // obtenemos el objeto
      ProductCatalogue product = ProductCatalogue.fromMap(element);

      // set firestore : hace un incremento en el valor sales'ventas'  del producto
      Database.dbProductStockSalesIncrement(idAccount: homeController.getIdAccountSelected,idProduct: product.id,quantity: product.quantity );
      // set firestore : hace un descremento en el valor 'stock' del producto
      if (product.stock) {
        // set firestore : hace un descremento en el valor 'stock'
        Database.dbProductStockDecrement(idAccount: homeController.getIdAccountSelected,idProduct: product.id,quantity: product.quantity);
      }
    }
  }

  // FUCTIONS



  void showSeach({required BuildContext context}) {
    // Busca entre los productos de mi catálogo


    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    showSearch(
      context: context,
      delegate: SearchPage<ProductCatalogue>(
        items: homeController.getCataloProducts,
        searchLabel: 'Buscar',
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent),
        suggestion: const Center(child: Text('ej. alfajor')),
        failure: const Center(child: Text('No se encontro en tu cátalogo:(')),
        filter: (product) => [product.description, product.nameMark,product.code],
        builder: (product) {

          // values
          Color tileColor = product.stock? (product.quantityStock <= product.alertStock && homeController.getProfileAccountSelected.subscribed? Colors.red.withOpacity(0.3): product.favorite?Colors.amber.withOpacity(0.1):Colors.transparent): product.favorite?Colors.amber.withOpacity(0.1):Colors.transparent;
          String alertStockText =product.stock ? (product.quantityStock == 0 ? 'Sin stock' : '${product.quantityStock} en stock') : '';
          
          return Column(
          children: [
            InkWell(
              onTap: () {
                selectedProduct(item: product);
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // image
                    ImageAvatarApp(url: product.image,size: 75,favorite:product.favorite),
                    // text : datos del producto
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:12),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(product.description,maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(product.nameMark,maxLines: 1,overflow: TextOverflow.clip,style: const TextStyle(color: Colors.blue)),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            children: <Widget>[
                              // text : code
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 7, color: Get.theme.dividerColor)),
                                    Text(product.code),
                                  ],
                                ),
                                // favorite
                                product.favorite?Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                                    const Text('Favorito'),
                                  ],
                                ):Container(),
                              //  text : alert stock
                                alertStockText != ''?Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                                    Text(alertStockText),
                                  ],
                                ):Container(),
                            ],
                          ),
                                  
                        ],
                                      ),
                      ),
                    ),
                    // text : precio
                    Text(Publications.getFormatoPrecio(monto: product.salePrice))
                  ],
                ),
              ),
            ), 
          ComponentApp().divider(), 
          ],
        );
        },
      ),
    );
  }
  

  void selectedProduct({required ProductCatalogue item}) {
    // agregamos un nuevo producto a la venta

  // verificamos si se trata de un código existente
    if (item.code == '') {
      addProduct(product: item);
    } else {
      // verifica si el ID del producto esta en la lista de seleccionados
      bool coincidence = false;
      for (ProductCatalogue product in getListProductsSelested) {
        if (product.id == item.id) {
          product.quantity++;
          coincidence = true;
          update();
          animateAdd(itemListAnimated: false);
        }
      }
      // si no hay coincidencia
      if (coincidence == false) {
        verifyExistenceInCatalogue(id: item.id);
      }
    }
  }

  void verifyExistenceInSelectedScanResult({required String id}) {
    // primero se verifica si el producto esta en la lista de productos seleccionados
    bool coincidence = false;
    for (ProductCatalogue product in getListProductsSelested) {
      if (product.id == id) {
        // este producto esta selccionado
        product.quantity++;
        coincidence = true;
        update();
        animateAdd();
      }
    }
    // si no hay coincidencia verificamos si esta en el cátalogo de productos de la cuenta
    if (coincidence == false) {
      verifyExistenceInCatalogue(id: id);
    }
  }

  void verifyExistenceInCatalogue({required String id}) {
    // verificamos si el producto esta en el catálogo de productos de la cuenta
    bool coincidence = false;
    for (ProductCatalogue product in homeController.getCataloProducts) {
      // si el producto se encuentra en el cátalgo de la cuenta se agrega a la lista de productos seleccionados
      if (product.id == id) {
        coincidence = true;
        addProduct(product: product);
        update();
        animateAdd();
      }
    }
    // si el producto no se encuentra en el cátalogo de la cuenta se va consultar en la base de datos de productos publicos
    if (coincidence == false) {
      queryProductDbPublic(id: id);
    }
  }

  Future<void> scanBarcodeNormal() async {
    // Escanner Code - Abre en pantalla completa la camara para escanear el código
    try {
      late String barcodeScanRes;
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
      if(barcodeScanRes == '-1'){return;}
      playSoundScan();
      verifyExistenceInSelectedScanResult(id: barcodeScanRes);
    } on PlatformException {
      Get.snackbar('scanBarcode', 'Failed to get platform version');
    }
  }

  void queryProductDbPublic({required String id}) {
    // consulta el código existe en la base de datos de productos publicos
    if (id != '') {
      // query
      Database.readProductPublicFuture(id: id).then((value) { 

        // show dialog
        showDialogAddProductNew(productCatalogue: ProductCatalogue.fromMap(value.data() as Map));
      
      }).onError((error, stackTrace) { 
        // no se encontro el producto en la base de datos
        //
        // dialog : agregar producto nuevo
        showDialogAddProductNew(productCatalogue: ProductCatalogue(id: id,code: id, creation: Timestamp.now(), documentCreation: Timestamp.now(), upgrade: Timestamp.now(), documentUpgrade: Timestamp.now()));
      }).catchError((error) {
        // error al consultar db
        Get.snackbar('ah ocurrido algo', 'Fallo el escaneo');
      });
    }
  }

  void dialogCleanTicketAlert() {
    Get.defaultDialog(
        title: 'Alerta',
        middleText: '¿Desea descartar este ticket?',
        confirm: TextButton.icon(
            onPressed: cleanTicket,
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Descartar')));
  }

  void cleanTicket() {
    setTicket = TicketModel(creation: Timestamp.now(), listPoduct: []);
    setListProductsSelected = [];
    setTicketView = false;
    update();
    Get.back();
  }

  void selectedItem({required String id}) {

    // seleccionamos el producto 
    for (ProductCatalogue element in getListProductsSelested) {
      if (element.id == id) {
        element.select = true;
      } else {
        element.select = false;
      }
    }
    update();
  }

  double getCountPriceTotal() {
    double total = 0.0;
    for (var element in getListProductsSelested) {
      total = total + (element.salePrice * element.quantity);
    }
    return total;
  }

  void addSaleFlash() {
    // generate new ID
    var id = Publications.generateUid();
    // var
    String valuePrice = textEditingControllerAddFlashPrice.text;
    String valueDescription = textEditingControllerAddFlashDescription.text;

    if (valuePrice != '') {
      if (double.parse(valuePrice) != 0) {
        addProduct(product: ProductCatalogue(id: id,description: valueDescription,salePrice: double.parse(textEditingControllerAddFlashPrice.text),creation: Timestamp.now(),upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()));
        textEditingControllerAddFlashPrice.text = '';
        update();
        Get.back();
      } else {
        showMessageAlertApp(title: '😔No se puedo agregar 😔',message: 'Debe ingresar un valor distinto a 0');
      }
    } else {
      showMessageAlertApp(title: '😔', message: 'Debe ingresar un valor valido');
    }
  }

  String getValueChange() {

    // text format : devuelte un texto formateado del monto del cambio que tiene que recibir el cliente
    if (getValueReceivedTicket == 0.0) {return Publications.getFormatoPrecio(monto: 0);}
    double result = getValueReceivedTicket - getCountPriceTotal();
    return Publications.getFormatoPrecio(monto: result);
  }
  String getValueReceived() {
    // text format : devuelte un texto formateado del monto que el vendedor recibio
    return Publications.getFormatoPrecio(monto: getValueReceivedTicket);
  }

  void confirmedPurchase() {

    // Deshabilitar la guía del usuario de las ventas
    homeController.disableSalesUserGuide();

    // set firestore
    registerTransaction();
    // el usuario confirmo su venta
    setStateConfirmPurchase = true;
    // mostramos una vista 'confirm purchase' por 2 segundos
    Future.delayed(
      const Duration(milliseconds: 1300),
      () {
        // fdefault values
        setListProductsSelected = [];
        setTicket = TicketModel(creation: Timestamp.now(), listPoduct: []);
        //views
        setStateConfirmPurchase = false;
        setTicketView = false;
      },
    );
  }

  void showDialogAddProductNew({ required ProductCatalogue productCatalogue}) {
    // dialog : muestra este dialog cuando el producto no se encuentra en el cáatalogo de la cuenta

    // creamos un dialog con GetX
    Get.dialog(
      ClipRRect(
        borderRadius: const  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
        child: NewProductView(productCatalogue: productCatalogue),
      ),
    ); 
  }

  void showDialogQuickSale({String id = ''}) {
    // Dialog view : Hacer una venta rapida 

    //var
    FocusNode myFocusNode = FocusNode();
    Get.defaultDialog(
        title: 'Venta rápida',
        titlePadding: const EdgeInsets.all(20),
        cancel: TextButton(
            onPressed: () {
              textEditingControllerAddFlashPrice.text = '';
              Get.back();
            },
            child: const Text('Cancelar')),
        confirm: Theme(
          data: Get.theme.copyWith(brightness: Get.theme.brightness),
          child: TextButton(
              onPressed: () {
                addSaleFlash();
                textEditingControllerAddFlashPrice.text = '';
              },
              child: const Text('Agregar')),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              // mount textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  controller: textEditingControllerAddFlashPrice,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[1234567890]'))
                  ],
                  decoration: const InputDecoration(
                    hintText: '\$',
                    labelText: "Escribe el precio",
                  ),
                  style: const TextStyle(fontSize: 20.0),
                  textInputAction: TextInputAction.next,
                ),
              ),
              // descrption textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  focusNode: myFocusNode,
                  autofocus: false,
                  controller: textEditingControllerAddFlashDescription,
                  decoration: const InputDecoration(
                      labelText: "Descripción (opcional)"),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    addSaleFlash();
                    textEditingControllerAddFlashPrice.text = '';
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void dialogSelectedIncomeCash() {

    // Dialog view : Cantidad del total del ingreso abonado
    Get.defaultDialog(
        title: 'Con cuanto abona',
        titlePadding: const EdgeInsets.all(20),
        cancel: TextButton(
            onPressed: () {
              textEditingControllerTicketMount.text = '';
              Get.back();
            },
            child: const Text('Cancelar')),
        confirm: Theme(
          data: Get.theme.copyWith(brightness: Get.theme.brightness),
          child: TextButton(
              onPressed: () {
                //var
                double valueReceived = textEditingControllerTicketMount.text == '' ? 0.0 : double.parse(textEditingControllerTicketMount.text);
                // condition : verificar si el usaurio ingreso un monto valido y que sea mayor al monto total del ticket
                if (valueReceived >= getCountPriceTotal() &&
                    textEditingControllerTicketMount.text != '') {
                      setValueReceivedTicket = valueReceived;
                      textEditingControllerTicketMount.text = '';
                      setPayModeTicket = 'effective';
                      Get.back();
                } else {
                  showMessageAlertApp( title: '😔', message: 'Tiene que ingresar un monto valido');
                }
              },
              child: const Text('aceptar')),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12),
                child: Wrap(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: getCountPriceTotal() > 100
                            ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setValueReceivedTicket = 100;
                                Get.back();
                              },
                        child:
                            const Text('100', style: TextStyle(fontSize: 24))),
                    TextButton(
                        onPressed: getCountPriceTotal() > 200
                            ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setValueReceivedTicket = 200;
                                Get.back();
                              },
                        child:
                            const Text('200', style: TextStyle(fontSize: 24))),
                    TextButton(
                        onPressed: getCountPriceTotal() > 500
                            ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setValueReceivedTicket = 500;
                                Get.back();
                              },
                        child:
                            const Text('500', style: TextStyle(fontSize: 24))),
                    TextButton(
                        onPressed: getCountPriceTotal() > 1000 
                          ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setValueReceivedTicket = 1000;
                                Get.back();
                              },
                        child:const Text('1000', style: TextStyle(fontSize: 24))
                    ),
                    TextButton(
                        onPressed: getCountPriceTotal() > 1500 
                          ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setValueReceivedTicket = 1500;
                                Get.back();
                              },
                        child:const Text('1500', style: TextStyle(fontSize: 24))
                    ),
                    TextButton(
                        onPressed: getCountPriceTotal() > 2000 
                          ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setValueReceivedTicket = 2000;
                                Get.back();
                              },
                        child:const Text('2000', style: TextStyle(fontSize: 24))
                    ),

                  ],
                ),
              ),
              // mount textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  autofocus: true,
                  controller: textEditingControllerTicketMount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[1234567890]'))
                  ],
                  decoration: const InputDecoration(
                    hintText: '\$',
                    labelText: "Escribe el monto",
                  ),
                  style: const TextStyle(fontSize: 20.0),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    //var
                    double valueReceived = textEditingControllerTicketMount.text ==''
                        ? 0.0
                        : double.parse(textEditingControllerTicketMount.text);
                    // condition : verificar si el usaurio ingreso un monto valido y que sea mayor al monto total del ticket
                    if (valueReceived >= getCountPriceTotal() && textEditingControllerTicketMount.text != '') {
                      setValueReceivedTicket = double.parse(textEditingControllerTicketMount.text);
                      textEditingControllerTicketMount.text = '';
                      setPayModeTicket = 'effective';
                      Get.back();
                    } else {
                      showMessageAlertApp( title: '😔', message: 'Tiene que ingresar un monto valido');
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }
  
  Widget get widgetSelectedProductsInformation{
    // widget : información de productos seleccionados que se va a mostrar al usuario por unica vez

    // comprobamos si es la primera ves que se inicia la aplicación
    if(homeController.salesUserGuideVisibility){
      return Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Opacity(opacity: 0.8,child: Text('En estos artículos vacíos aparecerán los productos que selecciones para vender\n    👇',textAlign: TextAlign.start,style: TextStyle(fontSize: 20))),
          ),
        ],
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
  }
  Widget get widgetProductSuggestionInfo{
    // widget : información de sugerencias de los productos que se va a mostrar al usuario por unica ves

    // comprobamos si es la primera ves que se inicia la aplicación
    if(homeController.salesUserGuideVisibility){
      return Opacity(
        opacity: 0.8,
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Aquí vamos a sugerirte algunos productos de tu catálogo 😉',textAlign: TextAlign.end,style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
  }
  Widget get widgetTextFirstSale{
    // widget : este texto se va a mostrar en la primera venta

    // comprobamos si es la primera ves que se inicia la aplicación
    if(homeController.salesUserGuideVisibility){
      return Opacity(
        opacity: 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 50,left: 12,right: 12,bottom: 20),
              child: Text('¡Elige el método de pago y listo\n😁\nregistra tu primera venta!',textAlign: TextAlign.center,style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
  }
}

//
//
// WIDGETS CLASS
//
//


class NewProductView extends StatefulWidget {
  
  // parametro obligatorio
  ProductCatalogue productCatalogue = ProductCatalogue(upgrade: Timestamp.now(), creation:  Timestamp.now(), documentCreation:  Timestamp.now(), documentUpgrade:  Timestamp.now() );
  
  NewProductView({Key? key, required this.productCatalogue}) : super(key: key);

  @override
  State<NewProductView> createState() => _NewProductViewState();
}

class _NewProductViewState extends State<NewProductView> { 

  // Añade un constructor sin nombre a la clase
  _NewProductViewState();
  
  // controllers 
  final HomeController homeController = Get.find<HomeController>();
  final SalesController salesController = Get.find<SalesController>();
  late TextEditingController controllerTextEditDescripcion = TextEditingController(text: widget.productCatalogue.description);
  late MoneyMaskedTextController controllerTextEditPrecioVenta = MoneyMaskedTextController(initialValue: widget.productCatalogue.salePrice);
  // keys form
  GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> priceFormKey = GlobalKey<FormState>();

  // variables
  late Color  colorAccent ;
  late  bool isProductNew ; 
  bool checkAddCatalogue = false; 
  Color checkActiveColor =  Colors.blue;
  // styles
  late TextStyle hintStyle ;
  late TextStyle labelStyle ;
  late TextStyle textStyle ;
    
  @override
  void initState() {
    super.initState();

    // set
    isProductNew = widget.productCatalogue.description==''?true:false;
    colorAccent = Get.isDarkMode?Colors.white:Colors.black;
    hintStyle = TextStyle(color: colorAccent.withOpacity(0.3));
    labelStyle = TextStyle(color: colorAccent.withOpacity(0.9));
    textStyle = TextStyle(color: colorAccent,height: 1,fontSize: 14,fontWeight: FontWeight.normal);
    controllerTextEditDescripcion.text = widget.productCatalogue.description; 
  }

  @override
  void dispose() {
    controllerTextEditDescripcion.dispose();
    controllerTextEditPrecioVenta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

    // widgets 
    Widget listtileCode = ListTile(
      title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Código: ',style: textStyle),
        // icon : verificacion del producto
        widget.productCatalogue.verified?const Icon(Icons.verified_rounded,color: Colors.blue, size: 20):Container(),
        const SizedBox(width: 5),
        // text :  crear un rich text para poder darle estilo al texto
        Text(widget.productCatalogue.code,style: textStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 16)),
      ],
    ), 
    );
    Widget listtileDescription = ListTile(
      title: // text :  crear un rich text para poder darle estilo al texto
        RichText(
          text: TextSpan( 
            style: textStyle,
            children: <TextSpan>[
              const TextSpan(text: 'Descripción: ' ),
              TextSpan(text:widget.productCatalogue.description,style: textStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 16) ),
            ],
          ),
        ), 
    );
    Widget widgetTextFieldDescription = widget.productCatalogue.verified?listtileDescription: Padding(
      padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
      child: Form(
        key: descriptionFormKey,
        child: TextFormField( 
          controller: controllerTextEditDescripcion,
          enabled: true ,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          focusNode: null, // sin foco
          minLines: 1,
          maxLines:2, 
          inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\- .]')),],
          decoration:  InputDecoration(
                  hintText: ' ej. agua saborisada 500 ml',
                  labelText: 'Descripción del producto',
                  hintStyle: hintStyle,
                  labelStyle: labelStyle, 
                  border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                  enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                ),
          onChanged: (value) => widget.productCatalogue.description =value,
          // validator: validamos el texto que el usuario ha ingresado.
          validator: (value) {
            if (value == null || value.isEmpty) { return 'Por favor, introduzca la descripción del producto'; }
            return null;
          },
        ),
      ),
    );
    // TODO : RangeError TextFormField : cuando el usuario mantiene presionado el boton de borrar > 'RangeError : Invalid value: only valid value is 0: -1'
    Widget widgetTextFieldPrice = Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: Form(
            key:  priceFormKey,
            child: TextFormField( 
              style: const TextStyle(fontSize: 18),
              autofocus: true,
              focusNode: null,
              controller: controllerTextEditPrecioVenta,
              enabled: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration( 
                labelText: 'Precio de venta al públuco',
                hintText: 'ej. agua saborisada 500 ml',  
                hintStyle: hintStyle,
                labelStyle: labelStyle,
                border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                
                ), 
              onChanged: (value) {
                // condition : comprobar si es un monto valido 
                if (controllerTextEditPrecioVenta.numberValue > 0.0) {
                  widget.productCatalogue.salePrice = controllerTextEditPrecioVenta.numberValue;
                }
              },
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if ( controllerTextEditPrecioVenta.numberValue == 0.0) { return 'Por favor, introduzca el precio del producto'; }
                return null;
              },
            ),
          ),
        );
    // checkbox : agregar producto al catálogo
    Widget checkboxAddProductToCatalogue =  AnimatedContainer(
      width:double.infinity, 
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(border: Border.all(color: checkAddCatalogue?checkActiveColor:colorAccent,width: 0.5),color: checkAddCatalogue?checkActiveColor.withOpacity(0.2):Colors.transparent,borderRadius: BorderRadius.circular(5)), 
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5,horizontal: 12),
        title: Text('Agregar a mi cátalogo', style: TextStyle(fontSize: 14,color: colorAccent)),
        value: checkAddCatalogue, 
        checkColor: Colors.white,
        activeColor: checkActiveColor, 
        onChanged: (value) {
          setState(() { 
            checkAddCatalogue=value!;
          });
        },
      ),
    );
    // button 
    final Widget buttonConfirm = Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton.icon(
          onPressed: () {
            // variables de condiciones
            bool conditionDescription = widget.productCatalogue.verified?true:descriptionFormKey.currentState!.validate();
            bool conditionPrice = priceFormKey.currentState!.validate();
            // condition : validamos los campos del formulario
            if (  conditionPrice && conditionDescription) {
              // set 
              widget.productCatalogue.description = controllerTextEditDescripcion.text;
              widget.productCatalogue.salePrice = controllerTextEditPrecioVenta.numberValue;
              //
              // condition : si el usuario quiere agregar el producto a la lista de productos del catálogo
              // entonces lo agregamos a la lista de productos del catálogo y a la colección de productos publica de la DB
              //
              if(checkAddCatalogue){
                // add product to catalogue
                homeController.addProductToCatalogue(product: widget.productCatalogue);
              }
              // add : agregamos el producto a la lista de productos seleccionados
              salesController.addProduct(product: widget.productCatalogue);
              // close dialog
              Get.back();
            }
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.all(16.0),
              backgroundColor: Colors.blue,),
          icon: Container(),
          label: const Text('Confirmar',style: TextStyle(color: Colors.white),),
        ),
    );
    
    return Scaffold(
      appBar: AppBar( 
        title: Text(isProductNew?'Nuevo Producto':'Producto'), 
        backgroundColor: Colors.transparent, 
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
        ],
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              // listtile : datos del producto
              listtileCode,
              // textfield : descripcion del producto
              widgetTextFieldDescription,
              const SizedBox(height: 12),
              // textfield : precio de venta
              widgetTextFieldPrice,
              // widget :  permiso para guardar el producto nuevo en mi cátalogo (app catalogo)
              Padding(padding: const EdgeInsets.all(12.0),child: checkboxAddProductToCatalogue),
              const Spacer(),
              SizedBox(width: double.infinity,child: buttonConfirm),
            ],
          ),
        )
      ),
    );
  }
}