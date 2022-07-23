import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:search_page/search_page.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/models/ticket_model.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/services/database.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';

class SalesController extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();

  // productos seleccionados recientemente
  List<ProductCatalogue> get getRecentlySelectedProductsList => homeController.getProductsOutstandingList;
  registerSelections({required ProductCatalogue productCatalogue}) {
    bool repeat = false;
    // seach
    for (ProductCatalogue item in getRecentlySelectedProductsList) {if (item.id == productCatalogue.id) {repeat = true; } }
    // add
    // ignore: dead_code
    if (repeat == false) {
      productCatalogue.creation = Timestamp.now();
      homeController.addToListProductSelecteds(item: productCatalogue);
    }
  }

  // efecto de sonido para escaner
  void playSoundScan() async {AudioCache cache = AudioCache();cache.play("soundBip.mp3");}

  // text field controllers
  final TextEditingController textEditingControllerAddFlashPrice = TextEditingController();
  final TextEditingController textEditingControllerAddFlashDescription =TextEditingController();
  final TextEditingController textEditingControllerTicketMount =TextEditingController();

  // list : lista de productos seleccionados por el usaurio para la venta
  List get getListProductsSelested => homeController.listProductsSelected;
  set setListProductsSelected(List value) => homeController.listProductsSelected = value;
  void addProduct({required ProductCatalogue product}) {
    product.quantity = 1;
    product.select = false;
    homeController.listProductsSelected.add(product);
  }

  set removeProduct(String id) {
    List newList = [];
    for (ProductCatalogue product in homeController.listProductsSelected) {
      if (product.id != id) {newList.add(product);}
    }
    setListProductsSelected = newList;
    update();
  }

  int get getListProductsSelestedLength {
    int count = 0;
    for (ProductCatalogue element in getListProductsSelested) {
      count += element.quantity;
    }
    return count;
  }

  // ticket
  TicketModel _ticket = TicketModel(creation: Timestamp.now(), listPoduct: []);
  TicketModel get getTicket => _ticket;
  set setTicket(TicketModel value) => _ticket = value;
  set setPayModeTicket(String value) {
    _ticket.payMode = value;
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
  set setValueReceivedTicket(double value) {
    _valueReceivedTicket.value = value;
  }
  @override
  void onClose() {
    textEditingControllerAddFlashDescription.dispose();
    textEditingControllerAddFlashPrice.dispose();
    textEditingControllerTicketMount.dispose();
  }


  // FIREBASE

  void registerTransaction() {

    // Procederemos a guardar un documento con la transacción

    // get values 
    var id = Publications.generateUid(); // generate id
    List listIdsProducts = [];

    for (ProductCatalogue element in getListProductsSelested) {
      // generamos una nueva lista con los id de los productos seleccionas
      listIdsProducts.add({
        'id': element.id,
        'quantity': element.quantity,
        'description': element.description,
        'stock': element.stock}
        );
    }
    //  set values
    getTicket.id = id;
    getTicket.seller = homeController.getIdAccountSelected;
    getTicket.cashRegister = '1';
    getTicket.listPoduct = listIdsProducts;
    getTicket.priceTotal = getCountPriceTotal();
    getTicket.valueReceived = getValueReceivedTicket;
    getTicket.creation = Timestamp.now();
    // set firestore : guarda la transacción
    Database.refFirestoretransactions(idAccount: homeController.getIdAccountSelected).doc(getTicket.id).set(getTicket.toJson());
    for (var element in listIdsProducts) {
      // set firestore : hace un incremento en el valor sales'ventas'  del producto
      Database.dbProductStockSalesIncrement(idAccount: homeController.getIdAccountSelected,idProduct: element['id'],quantity: element['quantity'] ?? 1);
      // set firestore : hace un descremento en el valor 'stock' del producto
      if (element['stock'] ?? false) {
        // set firestore : hace un descremento en el valor 'stock'
        Database.dbProductStockDecrement(idAccount: homeController.getIdAccountSelected,idProduct: element['id'],quantity: element['quantity'] ?? 1,);
      }
    }
  }

  // FUCTIONS

  void seach({required BuildContext context}) {
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
          Color tileColor = product.stock? (product.quantityStock <= product.alertStock? Colors.red.withOpacity(0.3): product.favorite?Colors.amber.withOpacity(0.1):Colors.transparent): product.favorite?Colors.amber.withOpacity(0.1):Colors.transparent;
          String alertStockText =product.stock ? (product.quantityStock == 0 ? 'Sin stock' : '${product.quantityStock} en stock') : '';
          
          return Column(
          children: [
            ListTile(
              contentPadding:const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
              tileColor: tileColor,
              title: Text(product.nameMark),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // text : code
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
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
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        //  text : alert stock
                        alertStockText != ''?Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                            Text(alertStockText),
                          ],
                        ):Container(),
                        // text : cantidad de ventas
                        product.sales == 0? Container():Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)),
                            Text('${product.sales} ${product.sales == 1 ? 'venta' : 'ventas'}'),
                          ],
                        ),
                    ],
                  ),

                ],
              ),
              trailing: Text(Publications.getFormatoPrecio(monto: product.salePrice)),
              onTap: () {
                selectedProduct(item: product);
                Get.back();
              },
            ),
            const Divider(height: 0),
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
        }
      }
      // si no hay coincidencia
      if (coincidence == false) {
        verifyExistenceInCatalogue(id: item.id);
      }
    }
  }

  void verifyExistenceInSelectedScanResult({required String id}) {
    // primero se verifica si el producto esta en la lista de productos deleccionados
    bool coincidence = false;
    for (ProductCatalogue product in getListProductsSelested) {
      if (product.id == id) {
        product.quantity++;
        coincidence = true;
        update();
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
        showDialogAddProductNew(productCatalogue: ProductCatalogue.fromMap(value.data() as Map));
      }).onError((error, stackTrace) {
        // error o no existe en la db
        showDialogQuickSale();
        Get.snackbar('Lo siento','🙁 no se encontro el producto en nuestra base de datos');
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

  String getValueReceived() {
    if (getValueReceivedTicket == 0.0) {
      return Publications.getFormatoPrecio(monto: 0);
    }
    double result = getValueReceivedTicket - getCountPriceTotal();
    return Publications.getFormatoPrecio(monto: result);
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

  void showDialogAddProductNew({required ProductCatalogue productCatalogue}) {
    // Dialog
    // muestra este dialog cuando el producto no se encuentra en los registros de stock

    Get.defaultDialog(
        title: 'Nuevo Producto',
        titlePadding: const EdgeInsets.all(20),
        middleTextStyle: TextStyle(color: Get.theme.textTheme.bodyText1?.color),
        cancel: TextButton(onPressed: Get.back, child: const Text('Cancelar')),
        confirm: Theme(
          data: Get.theme.copyWith(brightness: Get.theme.brightness),
          child: TextButton(
              onPressed: () {
                if (productCatalogue.salePrice != 0.0) {
                  addProduct(product: productCatalogue);
                  if (homeController.checkAddProductToCatalogue) {homeController.addProductToCatalogue(product: productCatalogue);}
                  update();
                  Get.back();
                } else {
                  Get.snackbar('🙁 algo salio mal', 'Inserte un precio valido');
                }
              },
              child: const Text('Agregar')),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              // return Widget view : permision: permiso para guardar el producto nuevo en mi cátalogo (app catalogo)
              CheckBoxAddProduct(productCatalogue: productCatalogue),
              // mount textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    if (value != "") {
                      double valuePrice = double.parse(value);
                      productCatalogue.salePrice = valuePrice;
                    }
                  },
                  autofocus: true,
                  keyboardType:const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[1234567890]'))],
                  decoration: const InputDecoration(hintText: '\$',labelText: "Escribe el precio"),
                  style: const TextStyle(fontSize: 20.0),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (value != "") {
                      double valuePrice = double.parse(value);
                      if (valuePrice != 0.0) {
                        productCatalogue.salePrice = valuePrice;
                        addProduct(product: productCatalogue);
                        if (homeController.checkAddProductToCatalogue) {homeController.addProductToCatalogue(product: productCatalogue);}
                        update();
                        Get.back();
                      } else {Get.snackbar('🙁 algo salio mal', 'Inserte un precio valido');}
                    } else {Get.snackbar('🙁 algo salio mal', 'Inserte un precio valido');}
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void showDialogQuickSale() {
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

  void showDialogMount() {
    // dialog show
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
                double valueReceived =
                    textEditingControllerTicketMount.text == ''
                        ? 0.0
                        : double.parse(textEditingControllerTicketMount.text);
                // condition : verificar si el usaurio ingreso un monto valido y que sea mayor al monto total del ticket
                if (valueReceived >= getCountPriceTotal() &&
                    textEditingControllerTicketMount.text != '') {
                  setValueReceivedTicket = valueReceived;
                  textEditingControllerTicketMount.text = '';
                  setPayModeTicket = 'effective';
                  Get.back();
                } else {
                  showMessageAlertApp(
                      title: '😔',
                      message: 'Tiene que ingresar un monto valido');
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
                        child:
                            const Text('1000', style: TextStyle(fontSize: 24))),
                            
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
                    double valueReceived = textEditingControllerTicketMount
                                .text ==
                            ''
                        ? 0.0
                        : double.parse(textEditingControllerTicketMount.text);
                    // condition : verificar si el usaurio ingreso un monto valido y que sea mayor al monto total del ticket
                    if (valueReceived >= getCountPriceTotal() &&
                        textEditingControllerTicketMount.text != '') {
                      setValueReceivedTicket =
                          double.parse(textEditingControllerTicketMount.text);
                      textEditingControllerTicketMount.text = '';
                      setPayModeTicket = 'effective';
                      Get.back();
                    } else {
                      showMessageAlertApp(
                          title: '😔',
                          message: 'Tiene que ingresar un monto valido');
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
      return Column(
        children: const [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Opacity(opacity: 0.8,child: Text('Aquí vamos a sugerirte algunos productos 😉',textAlign: TextAlign.end,style: TextStyle(fontSize: 20))),
          ),
        ],
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
  }
  Widget get widgetTextFirstSale{
    // widget : este texto se va a mostrar en la primera venta

    // comprobamos si es la primera ves que se inicia la aplicación
    if(homeController.salesUserGuideVisibility){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 50,left: 12,right: 12,bottom: 20),
            child: Opacity(opacity: 0.8,child: Text('¡Elige el método de pago y listo\n😁\nregistra tu primera venta!',textAlign: TextAlign.center,style: TextStyle(fontSize: 20))),
          ),
        ],
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
  }
}
