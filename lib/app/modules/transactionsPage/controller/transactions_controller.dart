import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';

class TransactionsController extends GetxController {
  // var
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  List<ProductCatalogue> listProducts = [
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'MediaTarde',
      salePrice: 90.0,
      image:
          'https://firebasestorage.googleapis.com/v0/b/commer-ef151.appspot.com/o/APP%2FARG%2FPRODUCTOS%2F7790270336307?alt=media&token=a8ff1c29-06e7-4eac-a32a-aff7dbec9d69',
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Don Satur agridulce',
      salePrice: 120.0,
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Alfajor Jorgito',
      salePrice: 50.0,
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Lays Papa Fritas 60g',
      salePrice: 130.0,
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Coca cola',
      salePrice: 150.0,
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Don Satur agridulce',
      salePrice: 120.0,
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Alfajor Jorgito',
      salePrice: 50.0,
    ),
    ProductCatalogue(
      upgrade: Timestamp.now(),
      creation: Timestamp.now(),
      description: 'Lays Papa Fritas 60g',
      salePrice: 130.0,
    ),
  ];

  @override
  void onClose() {}

  double getCountPriceTotal() {
    double total = 0.0;
    for (var element in listProducts) {
      total = total + element.salePrice;
    }
    return total;
  }
}
