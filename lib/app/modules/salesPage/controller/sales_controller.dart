import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/models/ticket_model.dart';
import 'package:sell/app/utils/fuctions.dart';

class SalesController extends GetxController {
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
  set addProduct(ProductCatalogue product) =>
      _listProductsSelected.add(product);
  set removeProduct(String id) {
    List newList = [];
    for (ProductCatalogue product in _listProductsSelected) {
      if (product.id != id) {
        newList.add(product);
      }
    }
    setListProductsSelected = newList;
  }

  // ticket
  TicketModel ticketModel = TicketModel(time: Timestamp.now());
  set setPayModeTicket(String value) {
    ticketModel.payMode = value;
    update();
  }

  // state cofirnm purchase ticket view
  final RxBool _confirmPurchase = false.obs;
  bool get getConfirmPurchase => _confirmPurchase.value;
  set setConfirmPurchase(bool value) => _confirmPurchase.value = value;

  // state ticket view
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  // mount  ticket
  final RxDouble _ticketMount = 0.0.obs;
  double get getTicketMount => _ticketMount.value;
  set setTicketMount(double value) {
    _ticketMount.value = value;
  }

  List<ProductCatalogue> listProducts = [
    ProductCatalogue(
      id: '111',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'MediaTarde',
      salePrice: 90.0,
      image:
          'https://firebasestorage.googleapis.com/v0/b/commer-ef151.appspot.com/o/APP%2FARG%2FPRODUCTOS%2F7790270336307?alt=media&token=a8ff1c29-06e7-4eac-a32a-aff7dbec9d69',
    ),
    ProductCatalogue(
        id: '112',
        upgrade: Timestamp.now(),
        creation: Timestamp.now(),
        description: 'Don Satur agridulce',
        salePrice: 120.0,
        image:
            'https://d3ugyf2ht6aenh.cloudfront.net/stores/001/232/784/products/bizcocho-don-satur-agridulce-x-200-g-copia1-ecbe7767b0e4a86fc516006593163352-480-0.png'),
    ProductCatalogue(
        id: '113',
        upgrade: Timestamp.now(),
        creation: Timestamp.now(),
        description: 'Alfajor Jorgito',
        salePrice: 50.0,
        image:
            'https://www.distribuidorapop.com.ar/wp-content/uploads/2016/08/alfajor-jorgito-chocolate-venta.jpg'),
    ProductCatalogue(
        id: '114',
        upgrade: Timestamp.now(),
        creation: Timestamp.now(),
        description: 'Lays Papa Fritas 60g',
        salePrice: 130.0,
        image:
            'https://i.pinimg.com/originals/c1/cd/1c/c1cd1c2c0806879baeb96c2152cc4caa.jpg'),
    ProductCatalogue(
        id: '115',
        upgrade: Timestamp.now(),
        creation: Timestamp.now(),
        description: 'Coca cola 1.5 L',
        salePrice: 150.0,
        image:
            'https://jumboargentina.vtexassets.com/arquivos/ids/666704/Coca-cola-Sabor-Original-1-5-Lt-2-245092.jpg'),
    ProductCatalogue(
      id: '116',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Don Satur Biscochos',
      salePrice: 120.0,
    ),
    ProductCatalogue(
      id: '117',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Alfajor Jorgito',
      salePrice: 50.0,
    ),
    ProductCatalogue(
      id: '118',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Lays Papa Fritas 60g',
      salePrice: 130.0,
    ),
  ];

  @override
  void onClose() {
    textEditingControllerAddFlashDescription.dispose();
    textEditingControllerAddFlashPrice.dispose();
    textEditingControllerTicketMount.dispose();
  }

  // FUCTIONS

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
    // var
    String valuePrice = textEditingControllerAddFlashPrice.text;
    String valueDescription = textEditingControllerAddFlashDescription.text;
    String idDefault = Timestamp.now().toString();

    if (valuePrice != '') {
      if (double.parse(valuePrice) != 0) {
        addProduct = ProductCatalogue(
            id: idDefault,
            code: idDefault,
            description: valueDescription,
            salePrice: double.parse(textEditingControllerAddFlashPrice.text),
            creation: Timestamp.now(),
            upgrade: Timestamp.now());
        textEditingControllerAddFlashPrice.text = '';
        Get.back();
      } else {
        Get.snackbar(
            'No se puedo agregar 😔', 'Debe ingresar un valor distinto a 0');
      }
    } else {
      Get.snackbar('😔', 'Debe ingresar un valor valido');
    }
  }

  String getChangeMount() {
    if (getTicketMount == 0.0) return Publications.getFormatoPrecio(monto: 0);
    double result = getTicketMount - getCountPriceTotal();
    return Publications.getFormatoPrecio(monto: result);
  }
  
  void confirmedPurchase() {
    // el usuario confirmo su venta
    setConfirmPurchase = true;
  }

  voidShowDialogMount() {
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
                setTicketMount =
                    double.parse(textEditingControllerTicketMount.text);
                textEditingControllerTicketMount.text = '';
                setPayModeTicket = 'effective';
                Get.back();
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
                                setTicketMount = 100;
                                Get.back();
                              },
                        child:
                            const Text('100', style: TextStyle(fontSize: 24))),
                    TextButton(
                        onPressed: getCountPriceTotal() > 200
                            ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setTicketMount = 200;
                                Get.back();
                              },
                        child:
                            const Text('200', style: TextStyle(fontSize: 24))),
                    TextButton(
                        onPressed: getCountPriceTotal() > 500
                            ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setTicketMount = 500;
                                Get.back();
                              },
                        child:
                            const Text('500', style: TextStyle(fontSize: 24))),
                    TextButton(
                        onPressed: getCountPriceTotal() > 1000
                            ? null
                            : () {
                                setPayModeTicket = 'effective';
                                setTicketMount = 1000;
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
                    setTicketMount =
                        double.parse(textEditingControllerTicketMount.text);
                    textEditingControllerTicketMount.text = '';
                    setPayModeTicket = 'effective';
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
