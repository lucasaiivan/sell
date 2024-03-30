 
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';  
import 'package:sell/app/domain/entities/cashRegister_model.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/data/datasource/database_cloud.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../domain/entities/ticket_model.dart';
import '../views/sell_view.dart';  
import 'package:mobile_scanner/mobile_scanner.dart';




class SalesController extends GetxController {

  // controllers views //
  final HomeController homeController = Get.find(); 

  // titulo del Appbar //
  String titleText = 'Vender'; 

  // state view barcodescan //
  final RxBool _stateViewBarCodeScan = false.obs;
  bool get getStateViewBarCodeScan => _stateViewBarCodeScan.value;
  set setStateViewBarCodeScan(bool value) {
    _stateViewBarCodeScan.value = value;
    update();
  }
  late MobileScannerController cameraScanBarCodeController;

  // state flash camera scan bar code //
  final RxBool _stateFlashCameraScanBarCode = false.obs;
  bool get getStateFlashCameraScanBarCode => _stateFlashCameraScanBarCode.value;
  set setStateFlashCameraScanBarCode(bool value) {
    _stateFlashCameraScanBarCode.value = value;
    update();
  }

  //  cash register  // 
  void deleteFixedDescription({required String description}){
    // firebase : elimina una descripción fijada
    Database.refFirestoreFixedDescriptions(idAccount:homeController.getProfileAccountSelected.id).doc(description).delete();
  }
  void registerFixerDescription({required String description}){
    // firebase : registra una descripción fija
    Database.refFirestoreFixedDescriptions(idAccount:homeController.getProfileAccountSelected.id).doc(description).set({'description':description});
  }
  Future<List<String>> loadFixerDescriotions(){
    // firebase : obtenemos las descripciones fijadas por el usuario
    return Database.refFirestoreFixedDescriptions(idAccount:homeController.getProfileAccountSelected.id).get().then((value) {
      List<String> list = [];
      for (var element in value.docs) {
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
    homeController.cashRegisterActive.description=description; // asigna la descripcion a la caja 
    homeController.cashRegisterActive.initialCash = initialCash; // asigna el dinero inicial a la caja
    homeController.cashRegisterActive.expectedBalance += expectedBalance;  // asigna el dinero esperado a la caja al iniciar
    cashRegisterLocalSave(); // guarda el id de la caja en el dispositivo
    // firebase : guarda un documento de la caja registradora
    Database.refFirestoreCashRegisters(idAccount:homeController.getProfileAccountSelected.id).doc(uniqueId).set(homeController.cashRegisterActive.toJson());
    update(); // actualiza la vista
  }  
  void closeCashRegisterDefault() {
    // cierre de la caja seleccionada
    homeController.cashRegisterActive.closure = DateTime.now(); // asigna la fecha de cierre
    homeController.cashRegisterActive.expectedBalance = homeController.cashRegisterActive.getExpectedBalance; // actualizamos el balance de la caja actual 
    // firebase : guardamos un copia del documento de la caja en la colección de cajas cerradas
    Database.refFirestoreRecords(idAccount:homeController.getProfileAccountSelected.id).doc(homeController.cashRegisterActive.id).set(homeController.cashRegisterActive.toJson());
    // firebase : eliminamos el documento de la caja de la colección de cajas abiertas
    Database.refFirestoreCashRegisters(idAccount:homeController.getProfileAccountSelected.id).doc(homeController.cashRegisterActive.id).delete();
    // default values
    homeController.cashRegisterActive = CashRegister.initialData();
    update();
  }
  void cashRegisterOutFlow({required double amount,String description = ''}){
    // egreso de dinero al flujo de caja
    //
    // firebase
    FirebaseFirestore  firebaseFirestoreInstance  = FirebaseFirestore.instance;
    firebaseFirestoreInstance.runTransaction((transaction) async {
      // Obtiene el documento actual
      DocumentReference documentRef = Database.refFirestoreCashRegisters(idAccount:homeController.getProfileAccountSelected.id).doc(homeController.cashRegisterActive.id);
      // creamos una transacción de firebase 
      DocumentSnapshot snapshot = await transaction.get(documentRef);
      // Verifica si el documento existe y contiene un campo 'numero'
      if (snapshot.exists) {
        // Crea una instancia de la clase CashRegister a partir de los datos del documento
        CashRegister cashRegister = CashRegister.fromMap(snapshot.data() as Map<String, dynamic>);
        // incrementa el valor total de los ingresos
        cashRegister.cashOutFlow += amount;
        // agregamos el registro del ingreso
        cashRegister.cashOutFlowList.add(CashFlow(id: const Uuid().v4(),userId: homeController.getIdAccountSelected,description: description,amount: amount,date: DateTime.now(),).toJson());
        // Actualiza el valor del número en el documento
        transaction.update(documentRef, cashRegister.toJson());
      }
    }); 
  }
  void cashRegisterInFlow({required double amount,String description = ''}){
    // ingreso de dinero al flujo de caja 
    //
    // firebase
    FirebaseFirestore  firebaseFirestoreInstance  = FirebaseFirestore.instance;
    firebaseFirestoreInstance.runTransaction((transaction) async {
      // Obtiene el documento actual
      DocumentReference documentRef = Database.refFirestoreCashRegisters(idAccount:homeController.getProfileAccountSelected.id).doc(homeController.cashRegisterActive.id);
      // creamos una transacción de firebase 
      DocumentSnapshot snapshot = await transaction.get(documentRef);
      // Verifica si el documento existe y contiene un campo 'numero'
      if (snapshot.exists) {
        // Crea una instancia de la clase CashRegister a partir de los datos del documento
        CashRegister cashRegister = CashRegister.fromMap(snapshot.data() as Map<String, dynamic>);
        // incrementa el valor total de los ingresos
        cashRegister.cashInFlow += amount;
        // agregamos el registro del ingreso
        cashRegister.cashInFlowList.add(CashFlow(id: const Uuid().v4(),description: description,userId: homeController.getIdAccountSelected,amount: amount,date: DateTime.now(),).toJson());
        // Actualiza el valor del número en el documento
        transaction.update(documentRef, cashRegister.toJson());
      }
    }); 
  } 
  void cashRegisterSetTransaction({required double amount,double discount = 0.0 }){
    // incrementar monto de transaccion de caja
    //
    // firebase
    if(homeController.cashRegisterActive.id!=''){
      FirebaseFirestore  firebaseFirestoreInstance  = FirebaseFirestore.instance;
      firebaseFirestoreInstance.runTransaction((transaction) async {
        // Obtiene el documento actual
        DocumentReference documentRef = Database.refFirestoreCashRegisters(idAccount:homeController.getProfileAccountSelected.id).doc(homeController.cashRegisterActive.id);
        // creamos una transacción de firebase 
        DocumentSnapshot snapshot = await transaction.get(documentRef);
        // Verifica si el documento existe y contiene un campo 'numero'
        if (snapshot.exists) {
          // Crea una instancia de la clase CashRegister a partir de los datos del documento
          CashRegister cashRegister = CashRegister.fromMap(snapshot.data() as Map<String, dynamic>);
          // incrementa el valor total de la facturacion de la caja
          cashRegister.billing += amount; 
          // incrementa el valor si es que existe un descuento
          cashRegister.discount += discount;
          // incrementa el valor de las ventas de la caja
          cashRegister.sales ++;
          // Actualiza el valor del número en el documento
          transaction.update(documentRef, cashRegister.toJson());
        }
      }); 
    }
  } 

  void cashRegisterLocalSave()async{  await GetStorage().write('cashRegisterID', homeController.cashRegisterActive.id);}
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
  final MoneyMaskedTextController textEditingControllerAddFlashPrice = MoneyMaskedTextController(leftSymbol: '\$',decimalSeparator: ',',thousandSeparator: '.',precision:2);
  final TextEditingController textEditingControllerAddFlashDescription =TextEditingController();
  final TextEditingController textEditingControllerTicketMount =TextEditingController();

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
  TicketModel _lastTicket = TicketModel(creation: Timestamp.now(), listPoduct: []);
  TicketModel get getLastTicket => _lastTicket;
  set setLastTicket(TicketModel value){
    _lastTicket = value; 
  }
  // ticket : ticket de venta actual
  TicketModel ticket = TicketModel(creation: Timestamp.now(), listPoduct: []);
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

      return 'Descuento:(${(porcent).toStringAsFixed(0)}%) ${Publications.getFormatoPrecio(monto:ticket.discount)}';
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

  // state ticket view
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  // mount  ticket
  final RxDouble _valueReceivedTicket = 0.0.obs;
  double get getValueReceivedTicket => _valueReceivedTicket.value;
  set setValueReceivedTicket(double value) {_valueReceivedTicket.value = value; }

 
  @override
  void onClose() {
    textEditingControllerAddFlashDescription.dispose();
    textEditingControllerAddFlashPrice.dispose();
    textEditingControllerTicketMount.dispose();
    super.dispose();
  }


  // FIREBASE
  
  void registerTransaction() {

    // Procederemos a guardar un documento con la transacción

    // get values    

    // set  : asignamos el ticket a la variable que recibe el ticket
    setLastTicket = TicketModel.fromMap(getTicket.toJson()); 
    //  set values
    getTicket.id = Publications.generateUid(); // generate id  
    getTicket.cashRegisterName = homeController.cashRegisterActive.description.toString(); // nombre de la caja registradora
    getTicket.cashRegisterId = homeController.cashRegisterActive.id; // id de la caja registradora
    getTicket.seller = homeController.getUserAuth.email!; 
    getTicket.priceTotal = getTicket.getTotalPrice;
    getTicket.valueReceived = getValueReceivedTicket; 
    getTicket.creation = Timestamp.now();

    // registramos el monto en caja
    if( homeController.getIsSubscribedPremium ){
      cashRegisterSetTransaction(amount: getTicket.priceTotal,discount: getTicket.discount);
    }
    
    // set firestore : guarda la transacción
    Database.refFirestoretransactions(idAccount: homeController.getIdAccountSelected).doc(getTicket.id).set(getTicket.toJson());
    
    for (dynamic data in getTicket.listPoduct) { 
      // obj
      ProductCatalogue product = ProductCatalogue.fromMap(data as Map<String, dynamic>);

      // set firestore : hace un incremento de las ventas del producto
      Database.dbProductStockSalesIncrement(idAccount: homeController.getIdAccountSelected,idProduct: product.id,quantity: product.quantity );
      // set firestore : hace un descremento en el valor 'stock' del producto si es que tiene stock habilitado
      if (product.stock && homeController.getIsSubscribedPremium ) {
        // set firestore : hace un descremento en el valor 'stock'
        Database.dbProductStockDecrement(idAccount: homeController.getIdAccountSelected,idProduct: product.id,quantity: product.quantity);
      }
    }
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
      late String barcodeScanRes;
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
      if(barcodeScanRes == '-1'){ return;}
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
    }
  }

  void verifyExistenceInCatalogue({required String id}) {
    // verificamos si el producto esta en el catálogo de productos de la cuenta
    bool coincidence = false;
    final listCatalogue =  homeController.getCataloProducts..toList();
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
    }
  }

  void queryProductDbPublic({required String id}) {
    // consulta el código existe en la base de datos de productos publicos
    if (id != '') {
      // firebase
      Future<DocumentSnapshot<Map<String, dynamic>>> documentSnapshot = Database.readProductPublicFuture(id: id);
      // query
      documentSnapshot.then((value) { 

        // get : product
        ProductCatalogue product = ProductCatalogue.fromMap(value.data() as Map);
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
    // generate new ID
    var id = Publications.generateUid();
    // var
    double  valuePrice = textEditingControllerAddFlashPrice.numberValue;
    String valueDescription = textEditingControllerAddFlashDescription.text;

    if (valuePrice != 0) {
      textEditingControllerAddFlashPrice.clear();
      textEditingControllerAddFlashDescription.clear;
      addProductsSelected(product: ProductCatalogue(id: id,description: valueDescription,salePrice: valuePrice,creation: Timestamp.now(),upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()));
      Get.back();
    } else {
      ComponentApp().showMessageAlertApp(title: '😔No se puedo agregar 😔',message: 'Debe ingresar un valor distinto a 0');
    }
  }

  String getValueChange() {

    // text format : devuelte un texto formateado del monto del cambio que tiene que recibir el cliente
    if (getValueReceivedTicket == 0.0) {return Publications.getFormatoPrecio(monto: 0);}
    double result = getValueReceivedTicket - getTicket.getTotalPrice;
    return Publications.getFormatoPrecio(monto: result);
  }
  String getValueReceived() {
    // text format : devuelte un texto formateado del monto que el vendedor recibio
    return Publications.getFormatoPrecio(monto: getValueReceivedTicket);
  }

  void confirmedPurchase() {
    //
    // el [Usuario] procede a confirmar la venta del ticket 
    //

    // condition : registramos la venta si el usuario esta logueado
    if(homeController.getUserAnonymous == false){
      registerTransaction();
    }  
    // el usuario confirmo su venta
    setStateConfirmPurchase = true;  
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[1234567890]'))
                      ],
                      decoration: InputDecoration(  
                        labelText: "Precio",
                        prefixIcon: const Icon(Icons.attach_money_rounded), 
                        border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                        enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent), )
                      ),
                      style: const TextStyle(fontSize: 20.0),
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
                double valueReceived = textEditingControllerTicketMount.text == '' ? 0.0 : double.parse(textEditingControllerTicketMount.text);
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
                  if (valueReceived >= getTicket.getTotalPrice && textEditingControllerTicketMount.text != '') {
                    setValueReceivedTicket = double.parse(textEditingControllerTicketMount.text);
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
}

//
//
// WIDGETS CLASS
//
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
  final SalesController salesController = Get.find<SalesController>();
  late TextEditingController controllerTextEditDescripcion = TextEditingController(text: widget.productCatalogue.description);
  late MoneyMaskedTextController controllerTextEditPrecioVenta = MoneyMaskedTextController(initialValue: widget.productCatalogue.salePrice);
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
    // TODO : RangeError TextFormField : cuando el usuario mantiene presionado el boton de borrar > 'RangeError : Invalid value: only valid value is 0: -1'
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
              decoration: InputDecoration(
                labelText: 'Precio de venta al públuco',
                hintText: 'ej. agua saborisada 500 ml',  
                hintStyle: hintStyle,
                labelStyle: labelStyle,
                prefixIcon: const Icon(Icons.attach_money_rounded), 
                border: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent)),
                enabledBorder: OutlineInputBorder(borderSide:  BorderSide(color: colorAccent), 
                ),
                
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
    Widget checkboxAddProductToCatalogue = homeController.getUserAnonymous?Container(): AnimatedContainer(
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
      child:ComponentApp().button(
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
              if(checkAddCatalogue && homeController.getUserAnonymous == false){
                // add product to catalogue
                homeController.addProductToCatalogue(product: widget.productCatalogue,isProductNew: isProductNew);
              }
              // add : agregamos el producto a la lista de productos seleccionados
              salesController.addProductsSelected(product: widget.productCatalogue);
              // close dialog
              Get.back();
            }
          },
          text: 'Confirmar',
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
  SalesController salesController = Get.find<SalesController>();

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
                padding: const EdgeInsets.symmetric(horizontal:3),
                child: GestureDetector(
                  onTap: (){
                    // set query
                    query = element.name;
                  },
                  child: Chip(  
                    avatar: element.image==''?null:CircleAvatar(backgroundImage: NetworkImage(element.image),),
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
      return const Center(child: Text('No se encontraron resultados'));
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
        // Convertimos la descripción, marca y código del elemento y el query a minúsculas
        final description = item.description.toLowerCase();
        final brand = item.nameMark.toLowerCase();
        final code = item.code.toLowerCase();
        final category = item.nameCategory.toLowerCase();
        final lowerCaseQuery = query.toLowerCase();

        // Dividimos el query en palabras individuales
        final queryWords = lowerCaseQuery.split(' ');

        // Verificamos que todas las palabras del query estén presentes en la descripción, marca código
        return queryWords.every((word) => description.contains(word) || brand.contains(word) || code.contains(word) || category.contains(word));
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
                ImageProductAvatarApp(url: product.local?'':product.image,size: 75,favorite:product.favorite),
                // text : datos del producto
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:12),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(product.description,maxLines:2,overflow: TextOverflow.clip,style: const TextStyle(fontWeight: FontWeight.w500)),
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
                            // favorite
                            product.favorite?Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                dividerCircle,
                                Text('Favorito',style: textStyleSecundary),
                              ],
                            ):Container(),
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
                Text(Publications.getFormatoPrecio(monto: product.salePrice),style: const  TextStyle(fontSize: 18,fontWeight: FontWeight.w300),)
              ],
            ),
          ),
        ), 
      ComponentApp().divider(), 
      ],
    );
  }
}


