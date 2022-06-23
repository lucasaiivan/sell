import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/ticket_model.dart';
import 'package:sell/app/services/database.dart';
import 'package:sell/app/utils/fuctions.dart';

import '../../home/controller/home_controller.dart';

class TransactionsController extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();

  // text filter
  String _filterText = '';
  String get getFilterText => _filterText;
  set setFilterText(String value) => _filterText = value;

  // list transactions
  List<TicketModel> _listTransactions = [];
  List<TicketModel> get getTransactionsList => _listTransactions;
  set setTransactionsList(List<TicketModel> value) {
    _listTransactions = value;
    update();
  }

  // var
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  @override
  void onInit() async {
    super.onInit();
    filterList(key: 'hoy');
  }

  @override
  void onClose() {}

  // set/get
  void filterList({required String key}) {
    switch (key) {
      case 'hoy':
        readCatalogueProductsOfTheDay();
        setFilterText = 'El día de hoy';
        break;
      case '30':
        readCatalogueListProductsStream(days: 30);
        setFilterText = 'Últimos 30 días';
        break;
      case '60':
        readCatalogueListProductsStream(days: 60);
        setFilterText = 'Últimos 60 días';
        break;
      case '120':
        readCatalogueListProductsStream(days: 120);
        setFilterText = 'Últimos 120 días';
        break;
    }
  }

  // FIREBASE
  void readCatalogueListProductsStream({int days = 30}) {
    // a la marca de tiempo actual le descontamos dias
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(Timestamp.now()
        .toDate()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch);
    // marca de tiempo actual
    Timestamp timeEnd = Timestamp.now();

    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    if (homeController.getProfileAccountSelected.id != '') {
      Database.readTransactionsFilterTimeStream(
        idAccount: homeController.getProfileAccountSelected.id,
        timeStart: timeStart,
        timeEnd: timeEnd,
      ).listen((value) {
        List<TicketModel> list = [];
        //  get
        for (var element in value.docs) {
          list.add(TicketModel.fromMap(element.data()));
        }
        //  set
        setTransactionsList = list;
      });
    }
  }
  void readCatalogueProductsOfTheDay() {
    // obtenemos los documentos creados en el día 

    // a la marca de tiempo actual le descontamos las horas del día
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(Timestamp.now().toDate().subtract(Duration(hours: Timestamp.now().toDate().hour)).millisecondsSinceEpoch);
    // marca de tiempo actual
    Timestamp timeEnd = Timestamp.now();

    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    if (homeController.getProfileAccountSelected.id != '') {
      Database.readTransactionsFilterTimeStream(
        idAccount: homeController.getProfileAccountSelected.id,
        timeStart: timeStart,
        timeEnd: timeEnd,
      ).listen((value) {
        List<TicketModel> list = [];
        //  get
        for (var element in value.docs) {
          list.add(TicketModel.fromMap(element.data()));
        }
        //  set
        setTransactionsList = list;
      });
    }
  }

  // FUCTIONS
  String getInfoPriceTotal() {
    double total = 0.0;

    for (TicketModel ticket in getTransactionsList) {
      total += ticket.priceTotal;
    }

    return '${Publications.getFormatoPrecio(monto: total)} de ${getTransactionsList.length} ventas';
  }

  String getPayModeFormat({required idMode}) {
    switch (idMode) {
      case 'effective':
        return 'Efectivo';
      case 'mercadopago':
        return 'Mercado Pago';
      case 'card':
        return 'Tarjeta Credito/Debito';
      default:
        return 'Sin esprecificar';
    }
  }
}
