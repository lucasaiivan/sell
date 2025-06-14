 
import 'dart:async'; 
import 'package:audioplayers/audioplayers.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';  
import 'package:sell/app/domain/entities/cashRegister_model.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart'; 
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:uuid/uuid.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../domain/entities/ticket_model.dart';
import '../../../domain/use_cases/cash_register_use_case.dart';
import '../../../domain/use_cases/catalogue_use_case.dart';
import '../../../domain/use_cases/transactions_user_case.dart';
import '../views/sell_view.dart';   


class SellController extends GetxController {

  // controllers views //
  final HomeController homeController = Get.find(); 

  // titulo del Appbar //
  String titleText = 'Vender'; 

  //  state load data admin user // 
  final RxBool _stateLoadDataAdminUserComplete = false.obs; 
  set setStateLoadDataAdminUserComplete(bool value) => _stateLoadDataAdminUserComplete.value = value;
  bool get getStateLoadDataAdminUserComplete => _stateLoadDataAdminUserComplete.value;

  // state view barcodescan //
  final RxBool _stateViewBarCodeScan = false.obs;
  bool get getStateViewBarCodeScan => _stateViewBarCodeScan.value;
  set setStateViewBarCodeScan(bool value) {
    _stateViewBarCodeScan.value = value;
    update();
  } 

  // state flash camera scan bar code //
  final RxBool _stateFlashCameraScanBarCode = false.obs;
  bool get getStateFlashCameraScanBarCode => _stateFlashCameraScanBarCode.value;
  set setStateFlashCameraScanBarCode(bool value) {
    _stateFlashCameraScanBarCode.value = value;
    update();
  }

  //  cash register  // 
  void deleteFixedDescription({required String description}){
    // case use : elimina una descripción fija
    CashRegisterUseCase().deleteFixedDescription(homeController.getIdAccountSelected, description); 
  }
  void registerFixerDescription({required String description}){
    if(description=='') return;
    // case use : crea una descripción fija
    CashRegisterUseCase().createFixedDescription(homeController.getIdAccountSelected, description); 
  }
  Future<List<String>> loadFixerDescriotions(){

    return CashRegisterUseCase().getFixedsDescriptions(homeController.getIdAccountSelected).then((value) {
      List<String> list = [];
      for (var element in value) {
        list.add(element['description'] as String);
      }
      return list;
    }); 
    
  }
  void startCashRegister({required String description,required double initialCash,required double expectedBalance}){   
    // inicializa nueva caja
    //
    if(description==''){description=(homeController.listCashRegister.length+1).toString();}
    // set
    String uniqueId = Publications.generateUid(); // genera un id unico
    homeController.cashRegisterActive.id=uniqueId; // asigna el id unico a la caja
    homeController.cashRegisterActive.openingCashiers = homeController.getProfileAdminUser.email; // asigna el id del usuario que hace la apertura de la caja
    homeController.cashRegisterActive.description=description; // asigna la descripcion a la caja 
    homeController.cashRegisterActive.initialCash = initialCash; // asigna el dinero inicial a la caja
    homeController.cashRegisterActive.expectedBalance += expectedBalance;  // asigna el dinero esperado a la caja al iniciar
    cashRegisterLocalSave(); // guarda el id de la caja en el dispositivo
    // firebase : guarda un documento de la caja registradora
    CashRegisterUseCase().createUpdateCashRegister(homeController.getIdAccountSelected, homeController.cashRegisterActive);
    update(); // actualiza la vista
  }  
  void closeCashRegisterDefault() {
    // cierre de la caja seleccionada
    homeController.cashRegisterActive.closure = DateTime.now(); // asigna la fecha de cierre
    homeController.cashRegisterActive.expectedBalance = homeController.cashRegisterActive.getExpectedBalance; // actualizamos el balance de la caja actual 
    // firebase : guardamos el arqueo de caja en el historial de arqueos
    CashRegisterUseCase().addCashRegisterHistory(homeController.getIdAccountSelected, homeController.cashRegisterActive);
    // firebase : eliminamos el documento de la caja de la colección de cajas abiertas
    Database.refFirestoreCashRegisters(idAccount:homeController.getProfileAccountSelected.id).doc(homeController.cashRegisterActive.id).delete();
    // default values
    homeController.cashRegisterActive = CashRegister.initialData();
    update();
  }
  void cashRegisterOutFlow({required double amount,String description = ''}){
    //
    // egreso de dinero al flujo de caja
    //
    final CashRegister cashRegister = homeController.cashRegisterActive;
    // incrementa el valor total de los ingresos
    cashRegister.cashOutFlow += amount;
    // agregamos el registro del ingreso
    cashRegister.cashOutFlowList.add(CashFlow(id: const Uuid().v4(),userId: homeController.getIdAccountSelected,description: description,amount: amount,date: DateTime.now(),).toJson());
    
    // case use : actualiza la caja registradora
    CashRegisterUseCase().createUpdateCashRegister(homeController.getIdAccountSelected, cashRegister);
     
  }
  void cashRegisterInFlow({required double amount,String description = ''}){
    //
    // ingreso de dinero al flujo de caja 
    //

    // Crea una instancia de la clase CashRegister a partir de los datos del documento
    final CashRegister cashRegister = homeController.cashRegisterActive;
    // incrementa el valor total de los ingresos
    cashRegister.cashInFlow += amount;
    // agregamos el registro del ingreso
    cashRegister.cashInFlowList.add(CashFlow(id: const Uuid().v4(),description: description,userId: homeController.getIdAccountSelected,amount: amount,date: DateTime.now(),).toJson());
    
    // case use : actualiza la caja registradora
    CashRegisterUseCase().createUpdateCashRegister(homeController.getIdAccountSelected, cashRegister);
    
  } 
  void cashRegisterSetTransaction({required double amount,double discount = 0.0 ,required String idUser}){
    // incrementar monto de transaccion de caja
    //
    
    // Crea una instancia de la clase CashRegister a partir de los datos del documento
    CashRegister cashRegister = homeController.cashRegisterActive;
    // agrega el id del usuario que registra la venta si esq no existe en la lista
    if(!cashRegister.cashiers.contains(idUser)){ cashRegister.cashiers.add(idUser);  }
    // incrementa el valor total de la facturacion de la caja
    cashRegister.billing += amount; 
    // incrementa el valor si es que existe un descuento
    cashRegister.discount += discount;
    // incrementa el valor de las ventas de la caja
    cashRegister.sales ++;
    
    // case use : actualiza la caja registradora
    CashRegisterUseCase().createUpdateCashRegister(homeController.getIdAccountSelected, cashRegister);

  } 

  void cashRegisterLocalSave()async{  
      await GetStorage().write('cashRegisterID', homeController.cashRegisterActive.id);
    }
  void upgradeCashRegister({required String id})async{
    await homeController.upgradeCashRegister(id: id);
    cashRegisterLocalSave();
    update();
  }
  List get getListCashRegister => homeController.listCashRegister; 
  

  // others controllers // 
  late AnimationController floatingActionButtonAnimateController;
  late AnimationController newProductSelectedAnimationController;
  void animateAdd({bool itemListAnimated=true }){
    try{
      if(itemListAnimated){newProductSelectedAnimationController.repeat();}
      floatingActionButtonAnimateController.repeat();
    }catch(_){}

  }

  // productos seleccionados recientemente  //
  List<ProductCatalogue> get getRecentlySelectedProductsList => homeController.getProductsOutstandingList;

  // sound : efecto de sonido para escaner
  void playSoundScan() async {
    final player = AudioPlayer(); // "soundBip.mp3"
    await player.play(AssetSource("soundBip.mp3")); 
  }

  // text field controllers 
  final AppMoneyTextEditingController textEditingControllerAddFlashPrice = AppMoneyTextEditingController();
  final TextEditingController textEditingControllerAddFlashDescription =TextEditingController();
  final AppMoneyTextEditingController textEditingControllerTicketMount =AppMoneyTextEditingController();

  // xfiel : imagen temporal del producto
  XFile _xFileImageCaptureBarCode = XFile('');
  set setXFileImage(XFile value) => _xFileImageCaptureBarCode = value;
  XFile get getXFileImage => _xFileImageCaptureBarCode;
 
  // Seleccionados : lista de porductos seleccionados por el usuario para la venta  
  void addProductsSelected({required ProductCatalogue product}) { 
    ///setIdProductSelected = product.id;
    getTicket.addProduct(product: product);
    update();
  } 
  // id del producto de la lista de productos seleccionados
  String idProductSelected = '';
  String get getIdProductSelected => idProductSelected;
  set setIdProductSelected(String value) {
    idProductSelected = value;
    update();
  }

  //  list : lista de productos seleccionados por el usaurio para la venta
  int get getListProductsSelestedLength {
    int count = 0;
    for (var element in getTicket.listPoduct) {
      ProductCatalogue product = ProductCatalogue.fromMap(element); 
      count += product.quantity;
    }
    return count;
  }
 
  // ticket : ticket de la ultima venta
  TicketModel _lastTicket = TicketModel( listPoduct: []);
  TicketModel get getLastTicket => _lastTicket;
  set setLastTicket(TicketModel value){
    _lastTicket = value; 
  }
  // ticket : ticket de venta actual
  TicketModel ticket = TicketModel( listPoduct: []);
  TicketModel get getTicket => ticket;
  set setTicket(TicketModel value){
    ticket = value;
  }
  set setPayModeTicket(String value) {
    ticket.payMode = value;
    update();
  }
  // discount
  // get : obtiene el descuento formateado si es que existe un valor distinto a 0.0
  String get getDiscount {
    if (ticket.discount != 0.0) {
      // devolver el descuento formateado 'Descuento:(30%) $ 100'
      // var 
      int porcent = ((ticket.discount * 100) / getTicket.getTotalPrice).round().toInt(); 

      return 'Descuento:(${(porcent).toStringAsFixed(0)}%) ${Publications.getFormatoPrecio(value:ticket.discount)}';
    } else {
      return '';
    }
  } 
  set setDiscount(double value) {
    ticket.discount = value;
    update();
  }
  void clearDiscount() {
    ticket.discount = 0.0;
    update();
  }

  // state cofirnm purchase ticket view
  final RxBool _stateConfirmPurchase = false.obs;
  bool get getStateConfirmPurchase => _stateConfirmPurchase.value;
  set setStateConfirmPurchase(bool value) => _stateConfirmPurchase.value = value;
  // stete ticket confirm purchase ticket complete
  final RxBool _stateConfirmPurchaseComplete = false.obs;
  bool get getStateConfirmPurchaseComplete => _stateConfirmPurchaseComplete.value;
  set setStateConfirmPurchaseComplete(bool value) => _stateConfirmPurchaseComplete.value = value;

  // state ticket view
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  // mount  ticket
  final RxDouble _valueReceivedTicket = 0.0.obs;
  double get getValueReceivedTicket => _valueReceivedTicket.value;
  set setValueReceivedTicket(double value) {_valueReceivedTicket.value = value; }



  // FIREBASE 
  void registerTransaction() {

    // Procederemos a guardar la transacción
 
    //  set values
    getTicket.id = Publications.generateUid(); // generate id  
    getTicket.cashRegisterName = homeController.cashRegisterActive.description.toString(); // nombre de la caja registradora
    getTicket.cashRegisterId = homeController.cashRegisterActive.id; // id de la caja registradora
    getTicket.sellerName = homeController.getProfileAdminUser.name; 
    getTicket.sellerId = homeController.getProfileAdminUser.email;
    getTicket.priceTotal = getTicket.getTotalPrice;
    getTicket.valueReceived = getValueReceivedTicket; 
    getTicket.creation =  Timestamp.now();

    // set  : replicamos el ticket actual temporalmente  
    setLastTicket = TicketModel.fromMap(getTicket.toJson()); 

    // registramos el monto en caja
    if( homeController.getIsSubscribedPremium ){
      cashRegisterSetTransaction(amount: getTicket.priceTotal,discount: getTicket.discount,idUser: homeController.getProfileAdminUser.email);
    }
    
    // set firestore : guarda la transacción
    GetTransactionUseCase().addTransaction(homeController.getIdAccountSelected, getTicket).then(
      (value) {
        
      // incrementamos la cantidad de venta y descrementamos el stock de los productos del catálogo
      for (dynamic data in getTicket.listPoduct) { 
        // obj
        ProductCatalogue product = ProductCatalogue.fromMap(data as Map<String, dynamic>);
        if(product.code == ''){continue;} // si el producto no tiene código no se registra en el catálogo
        ProductCatalogue productCatalogue = homeController.getProductCatalogue(id: product.id).copyWith(); // obtenemos el producto del catálogo con los datos actualizados

        // firestore : hace un incremento de 1 en el valor 'sales' del producto
        productCatalogue.sales ++;
        GetCatalogueUseCase().incrementSales(homeController.getIdAccountSelected, product.id, 1);
        //Database.dbProductStockSalesIncrement(idAccount: homeController.getIdAccountSelected,idProduct: product.id,quantity: 1 );
        // condition :  hace un descremento en el valor 'stock' del producto si es que tiene stock habilitado
        if (product.stock && homeController.getIsSubscribedPremium ) {
          //  firestore : hace un descremento en el valor 'stock'
          productCatalogue.quantityStock -= product.quantity;
          //Database.dbProductStockDecrement(idAccount: homeController.getIdAccountSelected,idProduct: product.id,quantity: product.quantity);
          GetCatalogueUseCase().decrementStock(homeController.getIdAccountSelected, product.id, product.quantity);
        }
        // actualizamos la lista de producto de  catálogo  en memoria de la app
        homeController.sincronizeCatalogueProducts(product: productCatalogue);
      }
      setStateConfirmPurchaseComplete = true;
      // set : default values  
      setTicket = TicketModel(creation: Timestamp.now(), listPoduct: []);

      }
    );

    /* Database.refFirestoretransactions(idAccount: homeController.getIdAccountSelected).doc(getTicket.id).set(getTicket.toJson()).whenComplete((){
      
    }); */
    
  }
  Future<void> pricesProductCatalogueUpdate({required ProductCatalogue product,double salePrice=0.0,double purchasePrice = 0.0})async {

    // obj : se obtiene los datos para registrar del precio al publico del producto en una colección publica de la db
    final ProductPrice precio = ProductPrice(id: homeController.getProfileAccountSelected.id,idAccount: homeController.getProfileAccountSelected.id,imageAccount: homeController.getProfileAccountSelected.image,nameAccount: homeController.getProfileAccountSelected.name,price: product.salePrice,currencySign: product.currencySign,province: homeController.getProfileAccountSelected.province,town: homeController.getProfileAccountSelected.town,time: Timestamp.fromDate(DateTime.now()));
     
    // var
    Timestamp upgrade =  Timestamp.now();
    Map data = {'upgrade':upgrade};
    if(salePrice!=0){ 
      data['salePrice']=salePrice; 
      product.salePrice = salePrice;
      precio.price = salePrice; 
      }
    if(purchasePrice!=0){ 
      data['purchasePrice']=purchasePrice; 
      product.purchasePrice = purchasePrice;
      }
    // set : fecha de actualización del producto
    product.upgrade = upgrade;

    // case use : registramos el precio del producto en la colección de precios publicos
    GetCatalogueUseCase().registerPriceProductPublic( price: precio );
    // case use : Actualizamos los datos del producto
    GetCatalogueUseCase().updateProductFromMap(homeController.getIdAccountSelected, product.id,data);

    // actualiza la lista de productos seleccionados
    getTicket.updateData(product: product);
    // actualiza la lista de productos del cátalogo en la memoria de la app
    homeController.sincronizeCatalogueProducts(product: product);
    // vuelve a abrir el dialog para editar la cantidad del producto seleccionado
    Get.dialog( EditProductSelectedDialogView(product: product) ); 
    update();
  }
  Future<void> setProductFavorite({required ProductCatalogue product,required bool favorite})async {
    
    // var
    Map data = {'favorite':favorite};
    product.favorite = favorite; 
    // case use : Actualizamos los datos
    GetCatalogueUseCase().updateProductFromMap(homeController.getIdAccountSelected, product.id,data);
    //docRefProductCatalogue.set(Map<String, dynamic>.from(data), SetOptions(merge: true));
    // actualiza la lista de productos seleccionados
    getTicket.updateData(product: product);
    // actualiza la lista de productos del cátalogo en la memoria de la app
    homeController.sincronizeCatalogueProducts(product: product);
  }

  // FUCTIONS  
  void showSeach({required BuildContext context}) {
    // Busca entre los productos de mi catálogo 
    showSearch(
      context: context,
      delegate: CustomSearchDelegate(items: homeController.getCataloProducts),
    );

  }
  Future<void>  scanBarcodeNormal() async {   
 
    // Escanner Code - Abre en pantalla completa la camara para escanear el código
    try {
      //  var
      late String barcodeScanRes;
      // scan
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666','Cancel',true,ScanMode.BARCODE);
      // condition : si el usuario cancela el escaneo
      if(barcodeScanRes == '-1'){ 
        setStateViewBarCodeScan = false;
        return;
      }else{
        setStateViewBarCodeScan = true;
      }
      // sound
      playSoundScan();
      // verifica el código de barra
      verifyExistenceInSelectedScanResult(id:barcodeScanRes);
    
    } on PlatformException {
      Get.snackbar('scanBarcode', 'Failed to get platform version');
    } 
  }

  void selectedProduct({required ProductCatalogue item}) { 
    // agregamos un nuevo producto a la venta

  // verificamos si se trata de un código existente
    if (item.code == '') {
      addProductsSelected(product: item);
    } else {
      // verifica si el ID del producto esta en la lista de seleccionados
      bool coincidence = false;
      for (var i = 0; i < getTicket.listPoduct.length; i++) {  
        if (getTicket.listPoduct[i]['id'] == item.id) {
          getTicket.listPoduct[i]['quantity']++;
          coincidence = true;
          update();
          animateAdd(itemListAnimated: false);
        }
      }
      // condition : si no hay coincidencia
      if (!coincidence) {
        // verifica si el producto esta en el catálogo de la cuenta
        verifyExistenceInCatalogue(id: item.id);
      }
    }
  }

  void verifyExistenceInSelectedScanResult({required String id}) {
    // primero se verifica si el producto esta en la lista de productos seleccionados
    bool coincidence = false; 
    for (var item in getTicket.listPoduct) {
      ProductCatalogue product = ProductCatalogue.fromMap(item);
      if (product.id == id) {
        // este producto esta selccionado
        getTicket.addProduct(product: product); 
        coincidence = true;
        update();
        animateAdd();
        
      }
    }
    
    if (coincidence == false) {
      // el producto no esta en la lista de productos seleccionados del ticket
      verifyExistenceInCatalogue(id: id);
    }else{ 
      if( getStateViewBarCodeScan){ 
        Future.delayed(const Duration(milliseconds:500),(){
          scanBarcodeNormal();
        });
      }
    }
  }

  void verifyExistenceInCatalogue({required String id}) {
    // verificamos si el producto esta en el catálogo de productos de la cuenta
    bool coincidence = false;
    final listCatalogue =  homeController.getCataloProducts..toList();
    // recorremos la lista de productos del catálogo para verificar si el producto se encuentra
    for (final ProductCatalogue product in listCatalogue) {
      // si el producto se encuentra en el cátalgo de la cuenta se agrega a la lista de productos seleccionados
      if (product.id == id) {
        coincidence = true;
        addProductsSelected(product: product); 
        animateAdd();
      }
    }
    // si el producto no se encuentra en el cátalogo de la cuenta se va consultar en la base de datos de productos publicos
    if (coincidence == false) {
      queryProductDbPublic(id: id);
    }else{
      if( getStateViewBarCodeScan){ 
        Future.delayed(const Duration(milliseconds:500),(){
          scanBarcodeNormal();
        });
      }
    }
  }

  void queryProductDbPublic({required String id}) {
    // consulta el código existe en la base de datos de productos publicos
    if (id != '') {
      // case use : consulta el producto en la base de datos de productos publicos
      GetCatalogueUseCase().getProductPublic(id).then((data) {
        if(data.id=='') throw 'null';

        // get : product
        ProductCatalogue product = data.convertProductCatalogue();
        // set : marca de tiempo
        product.upgrade = Timestamp.now();
        // show dialog
        showDialogAddProductNew(productCatalogue:product);
      }).onError((error, stackTrace) {
        // no se encontro el producto en la base de datos
        //
        // dialog : agregar producto nuevo
        showDialogAddProductNew(productCatalogue: ProductCatalogue(id: id,description:'',code: id, creation: Timestamp.now(), documentCreation: Timestamp.now(), upgrade: Timestamp.now(), documentUpgrade: Timestamp.now()));
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
    getTicket.listPoduct = [];
    setTicketView = false;
    update();
    Get.back();
  } 
  void addSaleFlash() {
    var id = Publications.generateUid();
    // var
    double  valuePrice = textEditingControllerAddFlashPrice.doubleValue;
    String valueDescription = textEditingControllerAddFlashDescription.text == '' ? 'Sin descripción' : textEditingControllerAddFlashDescription.text;

    if (valuePrice != 0) {
      textEditingControllerAddFlashPrice.clear();
      textEditingControllerAddFlashDescription.clear;
      addProductsSelected(product: ProductCatalogue(id: id,description: valueDescription,salePrice: valuePrice,creation: Timestamp.now(),upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()));
      Get.back();
    } else {
      ComponentApp().showMessageAlertApp(title: '😔No se puedo agregar 😔',message: 'Debe ingresar un valor distinto a 0');
    }
  }
  void confirmedPurchase() { 
    // el [Usuario] procede a confirmar la venta del ticket  //

    // el usuario confirmo su venta
    setStateConfirmPurchase = true;  

    // condition : registramos la venta si el usuario esta logueado
    if(homeController.getUserAnonymous == false){
      registerTransaction();
    }else{
      // set : default values  
      setStateConfirmPurchaseComplete = true; 
      setLastTicket = TicketModel.fromMap(getTicket.toJson()); 
      setTicket = TicketModel();
    }
    
  }

  // Getters //
  String getValueChange() {

    // text format : devuelte un texto formateado del monto del cambio que tiene que recibir el cliente
    if (getValueReceivedTicket == 0.0) {return Publications.getFormatoPrecio(value: 0);}
    double result = getValueReceivedTicket - getTicket.getTotalPrice;
    return Publications.getFormatoPrecio(value: result);
  }
  String getValueReceived() {
    // text format : devuelte un texto formateado del monto que el vendedor recibio
    return Publications.getFormatoPrecio(value: getValueReceivedTicket);
  }

  // DIALOG // 
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
  void showDialogAddDiscount() {

    // dialog : añadir descuento al ticket 
    
     // creamos un dialog con GetX
    Get.dialog(
      const ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
        child: ViewAddDiscount(),
      ),
    ); 
  }
  void showDialogQuickSale( ) {
    // Dialog view : Hacer una venta rapida 

    //var 
    final FocusNode myFocusNode = FocusNode();  
    
    // style
    final Color colorAccent = Get.isDarkMode?Colors.white:Colors.black; 
    // widgets
    Widget content = Scaffold(
      backgroundColor: Get.context!.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Venta rapida'), 
        actions: [
          IconButton(
            onPressed: () {
              textEditingControllerAddFlashPrice.text = '';Get.back();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
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
                      autofocus: true,
                      controller: textEditingControllerAddFlashPrice,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        AppMoneyInputFormatter()
                      ],
                      decoration: InputDecoration(  
                        labelText: "Ingrese el monto",
                        hintText: '\$0', 
                        border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                        enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent), )
                      ),
                      style: const TextStyle(fontSize: 40.0),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox( height: 20),
                  // descrption textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      focusNode: myFocusNode,
                      autofocus: false,
                      controller: textEditingControllerAddFlashDescription,
                      decoration: InputDecoration( 
                        labelText: "Descripción (opcional)",
                        border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                        enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent), )
                        ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        addSaleFlash();
                        textEditingControllerAddFlashPrice.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(), 
            // buttons 
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ComponentApp().button(  
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  colorButton: Colors.blue,
                  text: 'Agregar',
                  onPressed: () {
                    addSaleFlash();
                    textEditingControllerAddFlashPrice.clear(); 
                    },
                    
                    ),
              ),
            )
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
                double valueReceived = textEditingControllerTicketMount.doubleValue;
                // condition : verificar si el usaurio ingreso un monto valido y que sea mayor al monto total del ticket
                if (valueReceived >= getTicket.getTotalPrice && textEditingControllerTicketMount.text != '') {
                  setValueReceivedTicket = valueReceived;
                  textEditingControllerTicketMount.text = '';
                  setPayModeTicket = 'effective';
                  
                }
              Get.back();

              },
              child: const Text('aceptar')),
        ),
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: Wrap(
                spacing: 5.0,
                children: [
                  // chip : efectivo '100'
                  getTicket.getTotalPrice > 100 ? Container() :ChoiceChip(
                    label: const Text('100'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 100;
                      Get.back();
                    },
                  ),   
                  // chip : efectivo '200'
                  getTicket.getTotalPrice > 200 ? Container() :ChoiceChip(
                    label: const Text('200'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 200;
                      Get.back();
                    },
                  ), 
                  // chip : efectivo '500'
                  getTicket.getTotalPrice > 500 ? Container() :ChoiceChip(
                    label: const Text('500'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 500;
                      Get.back();
                    },
                  ), 
                  // chip : efectivo '1000'
                  getTicket.getTotalPrice > 1000 ? Container() :ChoiceChip(
                    label: const Text('1.000'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 1000;
                      Get.back();
                    },
                  ), 
                  // chip : efectivo '1500'
                  getTicket.getTotalPrice > 1500 ? Container() :ChoiceChip(
                    label: const Text('1.500'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 1500;
                      Get.back();
                    },
                  ),
                  // chip : efectivo '2000'
                  getTicket.getTotalPrice > 2000 ? Container() :ChoiceChip(
                    label: const Text('2.000'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 2000;
                      Get.back();
                    },
                  ), 
                  // chip : efectivo '5000'
                  getTicket.getTotalPrice > 5000 ? Container() :ChoiceChip(
                    label: const Text('5.000'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 5000;
                      Get.back();
                    },
                  ),
                  // chip : efectivo '10000'
                  getTicket.getTotalPrice > 10000 ? Container() :ChoiceChip(
                    label: const Text('10.000'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 10000;
                      Get.back();
                    },
                  ),
                  // chip : efectivo '20000'
                  getTicket.getTotalPrice > 20000 ? Container() :ChoiceChip(
                    label: const Text('20.000'),
                    selected: false,
                    onSelected: (bool value) {
                      setPayModeTicket = 'effective';
                      setValueReceivedTicket = 20000;
                      Get.back();
                    },
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
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [AppMoneyInputFormatter()],
                decoration: const InputDecoration(
                  hintText: '\$',
                  labelText: "Escribe el monto",
                ),
                style: const TextStyle(fontSize: 20.0),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  //var
                  double valueReceived = textEditingControllerTicketMount.doubleValue;
                  // condition : verificar si el usaurio ingreso un monto valido y que sea mayor al monto total del ticket
                  if (valueReceived >= getTicket.getTotalPrice && textEditingControllerTicketMount.text != '') {
                    setValueReceivedTicket = textEditingControllerTicketMount.doubleValue;
                    textEditingControllerTicketMount.text = '';
                    setPayModeTicket = 'effective';
                    Get.back();
                  }  
                  Get.back();
                },
              ),
            ),
          ],
        ));
  }
  void checkDataAdminUser() {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if ( homeController.getProfileAdminUser.email != '') {
      setStateLoadDataAdminUserComplete = true; 
      timer.cancel(); // Detiene el temporizador cuando _stateConfirmPurchaseComplete es true
    }
  });
}
  void showUpdatePricePurchaseAndSalesDialog({required ProductCatalogue product}){
    // controllers
    AppMoneyTextEditingController pricePurchaseController = AppMoneyTextEditingController();
    AppMoneyTextEditingController priceSaleController = AppMoneyTextEditingController();

    // set values 
    pricePurchaseController.updateValue(product.purchasePrice);
    priceSaleController.updateValue(product.salePrice);

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar precios'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // textfield : precio de compra
            TextField( 
              autofocus: false,
              controller: pricePurchaseController,
              enabled: true, 
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Costo',prefixIcon: Icon(Icons.monetization_on_rounded)),
            ),
            const SizedBox(height: 10),
            // textfield : precio de venta
            TextField( 
              autofocus: false,
              controller: priceSaleController,
              enabled: true, 
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Venta al público',prefixIcon: Icon(Icons.monetization_on_rounded)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // fuction : actualizar precios de los productos seleccionado
              pricesProductCatalogueUpdate(
                product: product,
                purchasePrice: pricePurchaseController.doubleValue,  
                salePrice: priceSaleController.doubleValue,
              );
              
            },
            child: const Text('Actualizar'),
          ),
        ],
      )
    );
  }
  // OVERRIDE //
  @override
  void onInit() { 
    // chequeamos cada segundo si se cargo los datos del usuario admin hasta que se cargue
    checkDataAdminUser();
    super.onInit();
  }
  @override
  void onClose() {
    textEditingControllerAddFlashDescription.dispose();
    textEditingControllerAddFlashPrice.dispose();
    textEditingControllerTicketMount.dispose();
    super.dispose();
  }
}
 
//
// WIDGETS CLASS
// 
class NewProductView extends StatefulWidget {
  
  // parametro obligatorio
  late final ProductCatalogue productCatalogue ;
  
  // ignore: prefer_const_constructors_in_immutables
  NewProductView({Key? key, required this.productCatalogue}) : super(key: key);

  @override
  State<NewProductView> createState() => _NewProductViewState();
}
class _NewProductViewState extends State<NewProductView> { 

  // Añade un constructor sin nombre a la clase
  _NewProductViewState();
  
  // controllers 
  final HomeController homeController = Get.find<HomeController>();
  final SellController salesController = Get.find<SellController>();
  late TextEditingController controllerTextEditDescripcion = TextEditingController(text: widget.productCatalogue.description);
  late AppMoneyTextEditingController controllerTextEditPrecioVenta = AppMoneyTextEditingController();
  // keys form
  GlobalKey<FormState> descriptionFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> priceFormKey = GlobalKey<FormState>();

  // variables
  late Color  colorAccent ;
  bool isProductNew = true ; 
  bool checkAddCatalogue = true; 
  Color checkActiveColor =  Colors.blue;
  // styles
  late TextStyle hintStyle ;
  late TextStyle labelStyle ;
  late TextStyle textStyle ;
    
  @override
  void initState() {
    super.initState();

    // set
    isProductNew = widget.productCatalogue.description=='' &&  widget.productCatalogue.salePrice==0.0 ;
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


    // style
    const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 5,horizontal: 20);
    

    // widgets 
    Widget listtileCode = Padding(
      padding: padding,
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Código: ',style: textStyle),
        // icon : verificacion del producto
        widget.productCatalogue.verified?const Icon(Icons.verified_rounded,color: Colors.blue, size: 20):Container(),
        const SizedBox(width: 5),
        // text :  crear un rich text para poder darle estilo al texto
        Text(widget.productCatalogue.code,style: textStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 16)),
        const Spacer(),
        TextButton(
          child: const Text('Volver a escanear'),
          onPressed: () {
            Get.back();
            salesController.scanBarcodeNormal();
          }, 
        ),
      ],
    ), 
    ); 
    Widget listtileDescription = Padding(
      padding: padding,
      child: // text :  crear un rich text para poder darle estilo al texto
        RichText(
          maxLines: 2,
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
          inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ0-9\- .³%]')) ],
          decoration:  InputDecoration(
                  hintText: ' ej. agua saborisada 500 ml',
                  labelText: 'Descripción del producto',
                  hintStyle: hintStyle,
                  labelStyle: labelStyle, 
                  border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                  enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                ), 
           textInputAction: TextInputAction.next,
          onChanged: (value) => widget.productCatalogue.description =value,
          // validator: validamos el texto que el usuario ha ingresado.
          validator: (value) {
            // condition : si el usuario no ha seleccionado la opcion de añadir el producto al catalogo no se valida el campo
            if (checkAddCatalogue && (value == null || value.isEmpty) ) { return 'Por favor, introduzca la descripción del producto'; }
            return null;
          },
        ),
      ),
    ); 
    // widget : entrada de monto del precio de venta al publico 
    Widget widgetTextFieldPrice = Padding(
          padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
          child: Form(
            key:  priceFormKey,
            child: TextFormField( 
              style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              autofocus: true,
              focusNode: null,
              controller: controllerTextEditPrecioVenta,
              enabled: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),  
              inputFormatters: [AppMoneyInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Precio de venta al públuco',
                hintText: '0.0',  
                hintStyle: hintStyle,
                labelStyle: labelStyle,
                prefixIcon: const Icon(Icons.attach_money_rounded), 
                border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent), 
                ),
                
                ), 
              onChanged: (value) {
                // condition : comprobar si es un monto valido 
                if (controllerTextEditPrecioVenta.doubleValue > 0.0) {
                  widget.productCatalogue.salePrice = controllerTextEditPrecioVenta.doubleValue;
                }
              },
              // validator: validamos el texto que el usuario ha ingresado.
              validator: (value) {
                if ( controllerTextEditPrecioVenta.doubleValue == 0.0) { return 'Por favor, introduzca el precio del producto'; }
                return null;
              },
            ),
          ),
        );
    // checkbox : agregar producto al catálogo
    Widget checkboxAddProductToCatalogue = homeController.getUserAnonymous?Container(): AnimatedContainer(
      width:double.infinity, 
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(border: Border.all(color: checkAddCatalogue?checkActiveColor:colorAccent,width: 0.5),color: checkAddCatalogue?checkActiveColor.withOpacity(0.2):Colors.transparent,borderRadius: BorderRadius.circular(5)), 
      child: CheckboxListTile( 
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
      child:  ComponentApp().button(
        text: 'Confirmar',
        colorAccent: Colors.white,
        colorButton: Colors.blue,
        onPressed: () {
          // variables de condiciones
          bool conditionDescription = widget.productCatalogue.verified?true:descriptionFormKey.currentState!.validate();
          bool conditionPrice = priceFormKey.currentState!.validate();
          // condition : validamos los campos del formulario
          if (  conditionPrice && conditionDescription) {
            // set 
            widget.productCatalogue.description = controllerTextEditDescripcion.text;
            widget.productCatalogue.salePrice = controllerTextEditPrecioVenta.doubleValue;
            //
            // condition : si el usuario quiere agregar el producto a la lista de productos del catálogo
            // entonces lo agregamos a la lista de productos del catálogo y a la colección de productos publica de la DB
            //
            if(checkAddCatalogue && homeController.getUserAnonymous == false){
              // add product to catalogue
              homeController.addProductToCatalogue(product: widget.productCatalogue.copyWith(),isProductNew: isProductNew);
              
            }
            // add : agregamos el producto a la lista de productos seleccionados
            salesController.addProductsSelected(product: widget.productCatalogue);
            // close dialog
            Get.back();
            // condition  : si el usuario no cancelo el escaneo consecutivo 
            if(salesController.getStateViewBarCodeScan){ 
              Future.delayed(const Duration(milliseconds:500),(){
                salesController.scanBarcodeNormal();
              });
            }
          }
        }, 
      ), 
    );
    
    return Scaffold(
      appBar: AppBar( 
        title: Row(
          children: [
            widget.productCatalogue.image==''?Container():
            ImageProductAvatarApp(url: widget.productCatalogue.image, size: 35),
            const SizedBox(width: 12),
            const Text('Nuevo producto'),
          ],
        ), 
        backgroundColor: Colors.transparent, 
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView( 
          children: [  
            // text : codigo del producto
            listtileCode,  
            // textfield : descripcion del producto
            widgetTextFieldDescription,
            const SizedBox(height: 12),
            // textfield : precio de venta
            widgetTextFieldPrice,
            // widget :  permiso para guardar el producto nuevo en mi cátalogo (app catalogo)
            Padding(padding: const EdgeInsets.all(12.0),child: checkboxAddProductToCatalogue),
            // button 
            SizedBox(width: double.infinity,child: buttonConfirm),
          ],
        ),
      ),
    );
  }
}
 
// search delegate : implementar el buscador de productos
class CustomSearchDelegate<T> extends SearchDelegate<T> {

  // vars
  final List<ProductCatalogue> items; 
  final Color primaryTextColor  = Get.isDarkMode?Colors.white70:Colors.black87;

  CustomSearchDelegate({
    required this.items, 
  });

  // controllers
  HomeController homeController = Get.find<HomeController>();
  SellController salesController = Get.find<SellController>();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if(query.isEmpty){
            Get.back();
          }else{
            query = '';
          } 
        },
      ),
    ];
  } 
  // estilo de la barra de busqueda
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Get.theme.copyWith(hintColor: primaryTextColor, highlightColor: primaryTextColor,inputDecorationTheme: const InputDecorationTheme(filled: false));
  } 
  // texto de ayuda del textfield de busqueda
  @override
  String get searchFieldLabel => 'Buscar'; 

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () { 
        Get.back();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount: _filteredItems.length, 
      itemBuilder: (context, index) {  
        return item(product:_filteredItems[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // styles
    final Color primaryTextColor  = Get.isDarkMode?Colors.white70:Colors.black87;
    final TextStyle textStylePrimary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400,fontSize: 16);
    final TextStyle textStyleSecundary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);
    
    // widget : lista de chips de las marcas de los productos
    final Widget viewMarks = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        homeController.getMarkList.isEmpty?Container(): Text('Marcas',style: textStylePrimary),
        const SizedBox(height: 5), 
        Wrap(
          children: [
            for (Mark element in homeController.getMarkList)
              // chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:2,vertical:1),
                child: GestureDetector(
                  onTap: (){
                    // set query
                    query = element.name;
                  },
                  child: Chip(  
                    avatar: element.image==''?null:CircleAvatar(backgroundImage: NetworkImage(element.image),backgroundColor:primaryTextColor.withOpacity(0.1) ),
                    label: Text(element.name,style: textStyleSecundary), 
                    shape: RoundedRectangleBorder(side: BorderSide(color: primaryTextColor.withOpacity(0.5)),borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.transparent,   
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    final Widget viewCategories = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        homeController.getCatalogueCategoryList.isEmpty?Container():Text('Categorías',style: textStylePrimary),
        const SizedBox(height: 5),
        Wrap(
          children: [
            for (Category element in homeController.getCatalogueCategoryList)
              // chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:3),
                child: GestureDetector(
                  onTap: (){
                    // set query
                    query = element.name;
                  },
                  child: Chip( 
                    label: Text(element.name,style: textStyleSecundary), 
                    shape: RoundedRectangleBorder(side: BorderSide(color: primaryTextColor.withOpacity(0.5)),borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.transparent,   
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    
    /// Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query]. 
    final filteredSuggestions = _filteredItems;
    

    // condition : si no hay query entonces mostramos las categorias y quitamos el foco del teclado
    if(query.isEmpty){

      // control de vista
      SystemChannels.textInput.invokeMethod('TextInput.hide'); // quita el foco

      // condition : si no hay ningun producto en el catalogo
      if(filteredSuggestions.isEmpty){
        return const Center(child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('aun no hay productos en el catálogo',textAlign: TextAlign.center,style: TextStyle(fontSize: 30)),
        ));
      }

      return Padding(
        padding: const EdgeInsets.only(top: 20,left: 12,right: 12),
        child: ListView(
            children: [
              viewCategories, 
              viewMarks,
            ],
          ),
      );
    }
    // condition : si se consulto pero no se obtuvieron resultados
    if(filteredSuggestions.isEmpty && query.isNotEmpty){
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No se encontraron resultados',style: TextStyle(fontSize: 30),textAlign: TextAlign.center),
      ));
    } 
    return ListView.builder(
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) { 
        // values
        ProductCatalogue product = filteredSuggestions[index]; 
        return item(product:product); 
      },
    );
  }

  List<ProductCatalogue> get _filteredItems {
    /// Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query].
    /// Los elementos se filtran de acuerdo a coincidencias encontradas en los atributos
    /// 'description', 'nombre de la marca' y 'codigo' de cada elemento.
    return query.isEmpty
    ? items
    : items.where((item) {
        // normalizamos los textos
        final description = Utils.normalizeText(item.description.toLowerCase());
        final brand = Utils.normalizeText(item.nameMark.toLowerCase());
        final code =  Utils.normalizeText(item.code.toLowerCase());
        final category = Utils.normalizeText(item.nameCategory.toLowerCase());
        final lowerCaseQuery = Utils.normalizeText(query); 
        final provider = Utils.normalizeText(item.nameProvider.toLowerCase());

        // Dividimos el query en palabras individuales
        final queryWords = lowerCaseQuery.split(' ');

        // Verificamos que todas las palabras del query estén presentes en la descripción, marca código
        return queryWords.every((word) => description.contains(word) || brand.contains(word) || code.contains(word) || category.contains(word) || provider.contains(word) );
      }).toList();
  }

  // WIDGETS
  Widget item({required ProductCatalogue product}){

    // styles
    final Color highlightColor = Get.isDarkMode?Colors.white:Colors.black;
    final Color primaryTextColor  = Get.isDarkMode?Colors.white54:Colors.black45;
    final TextStyle textStyleSecundary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);
    // widgets
    final Widget dividerCircle = Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child:Icon(Icons.circle,size: 4, color: primaryTextColor.withOpacity(0.5)));

    // var
    String alertStockText =product.stock ? (product.quantityStock == 0 ? 'Sin stock' : '${product.quantityStock} en stock') : '';
          
    return Column(
      children: [
        InkWell(
          // color del cliqueable
          splashColor: Colors.blue, 
          highlightColor: highlightColor.withOpacity(0.1), 
          onTap: () {
            salesController.selectedProduct(item: product);
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // image
                ImageProductAvatarApp(url: product.local?'':product.image,size: 75),
                // text : datos del producto
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:12),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // icon : favorito 
                          product.favorite?const Icon(Icons.star_rate_rounded,color: Colors.amber,size:14,):Container(),
                          // text : nombre del producto
                          Flexible(child: Text(product.description,maxLines:2,overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.w500))),
                        ],
                      ),
                      product.nameMark==''?Container():Text(product.nameMark,maxLines: 1,overflow: TextOverflow.clip,style: TextStyle(color: product.verified?Colors.blue:null)),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        children: <Widget>[
                          // text : code
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                dividerCircle,
                                Text(product.code,style: textStyleSecundary),
                              ],
                            ), 
                          //  text : alert stockv
                            alertStockText != ''?Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                dividerCircle,
                                Text(alertStockText,style: textStyleSecundary),
                              ],
                            ):Container(),
                        ],
                      ), 
                    ],
                    ),
                  ),
                ),
                // text : precio
                Text(Publications.getFormatoPrecio(value: product.salePrice),style: const  TextStyle(fontSize: 18,fontWeight: FontWeight.w300),)
              ],
            ),
          ),
        ), 
      ComponentApp().divider(), 
      ],
    );
  }
}
 
class CurrencyTextEditingController extends TextEditingController {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '',
    decimalDigits: 2,
  );

  CurrencyTextEditingController() {
    addListener(_formatText);
  }

  void _formatText() {
    final String text = this.text;
    if (text.isEmpty) return;

    final String newText = _formatter.format(double.tryParse(text.replaceAll(',', '')) ?? 0);
    final int selectionIndex = this.selection.end + (newText.length - text.length);

    this.value = this.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

