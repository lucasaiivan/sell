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


  List<ProductCatalogue> get getRecentlySelectedProductsList => homeController.getProductsSelectedsList;
  registerSelections({required ProductCatalogue productCatalogue}) {
    bool repeat = false;
    // seach
    for (ProductCatalogue item in getRecentlySelectedProductsList) {
      if (item.id == productCatalogue.id) {
        repeat = true;
      }
    }
    // add
    // ignore: dead_code
    if (repeat == false) {
      productCatalogue.creation = Timestamp.now();

      homeController.addToListProductSelecteds(item: productCatalogue);
    }
  }

  // efecto de sonido para escaner
  void playSoundScan() async {
    AudioCache cache = AudioCache();
    cache.play("soundBip.mp3");
  }

  // text field controllers
  final TextEditingController textEditingControllerAddFlashPrice =
      TextEditingController();
  final TextEditingController textEditingControllerAddFlashDescription =
      TextEditingController();
  final TextEditingController textEditingControllerTicketMount =
      TextEditingController();

  // list product selected
  final RxList _listProductsSelected = [].obs;
  List get getListProductsSelested => _listProductsSelected;
  set setListProductsSelected(List value) =>
      _listProductsSelected.value = value;
  set addProduct(ProductCatalogue product) {
    product.quantity = 1;
    product.select = false;
    _listProductsSelected.add(product);
  }

  set removeProduct(String id) {
    List newList = [];
    for (ProductCatalogue product in _listProductsSelected) {
      if (product.id != id) {
        newList.add(product);
      }
    }
    setListProductsSelected = newList;
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
    // generate id
    var id = Publications.generateUid();

    List listIdsProducts = [];

    for (ProductCatalogue element in getListProductsSelested) {
      // generamos una nueva lista con los id de los productos seleccionas
      listIdsProducts.add({
        'id': element.id,
        'quantity': element.quantity,
        'description': element.description,
        'stock': element.stock,
      });
    }
    //  set values
    getTicket.id = id;
    getTicket.seller = homeController.getIdAccountSelected;
    getTicket.cashRegister='1';
    getTicket.listPoduct = listIdsProducts;
    getTicket.priceTotal = getCountPriceTotal();
    getTicket.valueReceived = getValueReceivedTicket;
    getTicket.creation = Timestamp.now();
    // set firestore
    Database.refFirestoretransactions(
            idAccount: homeController.getIdAccountSelected)
        .doc(getTicket.id)
        .set(getTicket.toJson());
    for (var element in listIdsProducts) {
      // registrar venta
      Database.dbProductStockSalesIncrement(
            idAccount: homeController.getIdAccountSelected,
            idProduct: element['id'],
            quantity: element['quantity']??1,
            );
      // descontar de stock
      if(element['stock']??false){
        Database.dbProductStockDecrement(
            idAccount: homeController.getIdAccountSelected,
            idProduct: element['id'],
            quantity: element['quantity']??1,
            );
      }
    }
  }

  // FUCTIONS

  void seach({required BuildContext context}) {
    // Busca entre los productos de mi catálogo

    // var
    Color colorAccent =
        Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    showSearch(
      context: context,
      delegate: SearchPage<ProductCatalogue>(
        items: homeController.getCataloProducts,
        searchLabel: 'Buscar',
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme
            .copyWith(hintColor: colorAccent, highlightColor: colorAccent),
        suggestion: const Center(child: Text('ej. alfajor')),
        failure: const Center(child: Text('No se encontro en tu cátalogo:(')),
        filter: (product) => [product.description, product.nameMark],
        builder: (product) => Column(
          children: [
            ListTile(
              title: Text(product.nameMark),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                  Text(product.code),
                ],
              ),
              trailing:
                  Text(Publications.getFormatoPrecio(monto: product.salePrice)),
              onTap: () {
                verifyExistenceInSelected(item: product);
                Get.back();
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void verifyExistenceInSelected({required ProductCatalogue item}) {
    if (item.code == '') {
      addProduct = item;
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
    // verifica si el ID del producto esta en la lista de seleccionados
    bool coincidence = false;
    for (ProductCatalogue product in getListProductsSelested) {
      if (product.id == id) {
        product.quantity++;
        coincidence = true;
        update();
      }
    }
    // si no hay coincidencia
    if (coincidence == false) {
      verifyExistenceInCatalogue(id: id);
    }
  }

  void verifyExistenceInCatalogue({required String id}) {
    // verifica si el ID del producto esta en el catálogo de la cuenta
    bool coincidence = false;
    for (ProductCatalogue product in homeController.getCataloProducts) {
      if (product.id == id) {
        coincidence = true;
        addProduct = product;
        update();
      }
    }
    // si no hay coincidencia
    if (coincidence == false) {
      queryProduct(id: id);
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

  void queryProduct({required String id}) {
    // consulta el id del producto en la base de datos global
    if (id != '') {
      // query
      Database.readProductGlobalFuture(id: id).then((value) {
        showDialogAddProductNew(
            productCatalogue: ProductCatalogue.fromMap(value.data() as Map));
        //Get.toNamed(Routes.PRODUCT,arguments: {'product': product.convertProductCatalogue()});
      }).onError((error, stackTrace) {
        // error o no existe en la db
      }).catchError((error) {
        // error al consultar db
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
    // generate id
    var id = Publications.generateUid();
    // var
    String valuePrice = textEditingControllerAddFlashPrice.text;
    String valueDescription = textEditingControllerAddFlashDescription.text;

    if (valuePrice != '') {
      if (double.parse(valuePrice) != 0) {
        addProduct = ProductCatalogue(
            id: id,
            description: valueDescription,
            salePrice: double.parse(textEditingControllerAddFlashPrice.text),
            creation: Timestamp.now(),
            upgrade: Timestamp.now());
        textEditingControllerAddFlashPrice.text = '';
        Get.back();
      } else {
        showMessageAlertApp(
            title: '😔No se puedo agregar 😔',
            message: 'Debe ingresar un valor distinto a 0');
      }
    } else {
      showMessageAlertApp(
          title: '😔', message: 'Debe ingresar un valor valido');
    }
  }

  String getValueReceived() {
    if (getValueReceivedTicket == 0.0)
      return Publications.getFormatoPrecio(monto: 0);
    double result = getValueReceivedTicket - getCountPriceTotal();
    return Publications.getFormatoPrecio(monto: result);
  }

  void confirmedPurchase() {
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
                  addProduct = productCatalogue;
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
              // permision: permiso para guardar el producto nuevo en mi cátalogo (app catalogo)
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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (value != "") {
                      double valuePrice = double.parse(value);
                      if (valuePrice != 0.0) {
                        productCatalogue.salePrice = valuePrice;
                        addProduct = productCatalogue;
                        Get.back();
                      } else {
                        Get.snackbar(
                            '🙁 algo salio mal', 'Inserte un precio valido');
                      }
                    } else {
                      Get.snackbar(
                          '🙁 algo salio mal', 'Inserte un precio valido');
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void showDialogQuickSale() {
    // Dialog
    // dialogo para hacer una venta rapida

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
}
