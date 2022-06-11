import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';

class SalesController extends GetxController {
  // text field controllers
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController textEditingControllerAddFlash =
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

  // state ticket view
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

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
      image: 'https://d3ugyf2ht6aenh.cloudfront.net/stores/001/232/784/products/bizcocho-don-satur-agridulce-x-200-g-copia1-ecbe7767b0e4a86fc516006593163352-480-0.png'
    ),
    ProductCatalogue(
      id: '113',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Alfajor Jorgito',
      salePrice: 50.0,
      image: 'https://www.distribuidorapop.com.ar/wp-content/uploads/2016/08/alfajor-jorgito-chocolate-venta.jpg'
    ),
    ProductCatalogue(
      id: '114',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Lays Papa Fritas 60g',
      salePrice: 130.0,
      image: 'https://i.pinimg.com/originals/c1/cd/1c/c1cd1c2c0806879baeb96c2152cc4caa.jpg'
    ),
    ProductCatalogue(
      id: '115',
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Coca cola 1.5 L',
      salePrice: 150.0,
      image: 'https://jumboargentina.vtexassets.com/arquivos/ids/666704/Coca-cola-Sabor-Original-1-5-Lt-2-245092.jpg'
    ),
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
  void onClose() {}

  // FUCTIONS

  double getCountPriceTotal() {
    double total = 0.0;
    for (var element in getListProductsSelested) {
      total = total + element.salePrice;
    }
    return total;
  }

  void addSaleFlash({required String value}) {
    if (value != '') {
      if (double.parse(value) != 0) {
        addProduct = ProductCatalogue(
            id: Timestamp.now().toString(),
            salePrice: double.parse(textEditingControllerAddFlash.text),
            creation: Timestamp.now(),
            upgrade: Timestamp.now());
        textEditingControllerAddFlash.text = '';
        Get.back();
      } else {
        Get.snackbar('No se puedo agregar 😔', 'Debe ingresar un valor distinto a 0');
      }
    } else {
      Get.snackbar('😔', 'Debe ingresar un valor valido');
    }
  }
}
