import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sell/app/models/ticket_model.dart';
import 'package:sell/app/services/database.dart';

import '../../home/controller/home_controller.dart';

class TransactionsController extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();

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
    readCatalogueListProductsStream(id: homeController.getAccountProfile.id);
  }

  @override
  void onClose() {}

  // FIREBASE
  void readCatalogueListProductsStream({required String id, int days = 30}) {
    
    // a la marca de tiempo actual le descontamos dias
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(Timestamp.now()
        .toDate()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch);
    // marca de tiempo actual
    Timestamp timeEnd = Timestamp.now();

    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    if (id != '') {
      Database.readTransactionsFilterTimeStream(
        idAccount: id,
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
