import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/data/datasource/database_cloud.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart';

import '../../../domain/entities/ticket_model.dart';
import '../../home/controller/home_controller.dart';

class TransactionsController extends GetxController {

  // others controllers
  final HomeController homeController = Get.find();

  // producto con más ganancias
  List<ProductCatalogue> bestSellingProductList = [];
  List<ProductCatalogue> get getBestSellingProductList => bestSellingProductList;
  set setBestSellingProductList(List<ProductCatalogue> value) => bestSellingProductList = value;

  // text filter
  String _filterText = '';
  String get getFilterText => _filterText;
  set setFilterText(String value) => _filterText = value;

  // list transactions
  List<TicketModel> _listTransactions = [];
  List<TicketModel> get getTransactionsList => _listTransactions;
  set setTransactionsList(List<TicketModel> value) {
    withMoreSales(list: value);
    _listTransactions = value;
    readProductWithMoreEarnings();
    update();
  }

  // var : ticket
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;

  // var : lista de productos más vendidos por cantidad
  List<ProductCatalogue> _mostSelledProducts = [];
  List<ProductCatalogue> get getMostSelledProducts => _mostSelledProducts;
  set setMostSelledProducts(List<ProductCatalogue> value) => _mostSelledProducts = value;

  // var : productos más vendidpos por precio
  List<ProductCatalogue> _bestSellingProductsByAmount = [];
  List<ProductCatalogue> get getBestSellingProductsByAmount => _bestSellingProductsByAmount;
  set setBestSellingProductsByAmount(List<ProductCatalogue> value) => _bestSellingProductsByAmount = value;

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
        readTransactionsOfTheDay();
        setFilterText = 'El día de hoy';
        break;
      case 'ayer':
        readTransactionsYesterday();
        setFilterText = 'Ayer';
        break;
      case 'este mes':
        readTransactionsThisMonth();
        setFilterText = 'Este mes';
        break;
      case 'el mes pasado':
        readTransactionsLastMonth();
        setFilterText = 'El mes pasado';
        break;
      case 'este año':
        readTransactionsThisYear();
        setFilterText = 'Este año';
        break;
      case 'el año pasado':
        readLastYearTransactions();
        setFilterText = 'El año pasado';
        break;
        // 
    }
  }

  // FIREBASE

  void readLastYearTransactions() {
    //obtenemos los documentos creados el año pasado

    // a la marca de tiempo actual le descontamos dias
    DateTime getTime = Timestamp.now().toDate();
    //Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(DateTime(getTime.year, 1, 1, 0).millisecondsSinceEpoch);
    
    //  a la marca de tiempo actual le descontamos dias del mes
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(getTime.year-1, 0, 0, 0).millisecondsSinceEpoch);
    // marca de tiempo actual
    Timestamp timeEnd = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(getTime.year, 0, 0, 0).millisecondsSinceEpoch);

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
  void readTransactionsThisYear() {
    //obtenemos los documentos creados este año

    // a la marca de tiempo actual le descontamos dias
    DateTime getTime = Timestamp.now().toDate();
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(DateTime(getTime.year, 1, 1, 0).millisecondsSinceEpoch);
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

  void readTransactionsOfTheDay() {
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
        withMoreSales(list: list);
        setTransactionsList = list;
      });
    }
  }
  void withMoreSales({ required List<TicketModel> list }){
    // CARD : PRODUCTOS MÁS VENDIDOS //
    // aqui se actualiza la tarjeta de productos más vendidos
    // obtenemos los primeros 3 productos más vendidos de los tickers que se obtiene por parametro 'list'

    // var
    Map<String,ProductCatalogue> productsList = {}; // en esta lista almacenamos las ganancias de los productos

    // recorremos todos los tickers que se filtraron
    for (TicketModel ticket in list) {
      // recorremos los productos de cada ticket
      for ( Map item in ticket.listPoduct ) {

        // get 
        final ProductCatalogue productNew = ProductCatalogue.fromMap(item); 
         
        productsList.forEach((key, value) {
          if(productNew.id ==  key){
              productNew.quantity = productNew.quantity + value.quantity ;
              productNew.revenue = value.revenue + ((productNew.salePrice - productNew.purchasePrice ) * productNew.quantity) ;
          }
        });

        productsList[productNew.id] = productNew;
      }
    }
    //
    // get  : los productos más vendidos en forma descendente los que tiene más cantidad
    //
    Map<String,ProductCatalogue> sortMap = Map.fromEntries( (productsList.entries.toList()..sort((a, b)=> b.value.quantity.compareTo(a.value.quantity))) );
    // y por ultimo obtenemos los 3 treprimeros productos
    Map<String,ProductCatalogue> featuredProducts = {}; // limit 3 items
    int count = 0;
    for( final item in sortMap.entries){
      count++;
      featuredProducts[item.key] = item.value; // add
      if( count == 5){ break;}
    }
    List<ProductCatalogue> listProducts = [];
    for (var element in featuredProducts.entries) {
      listProducts.add(element.value);
    }
    // actualizamos lista para mostrar al usuario
    setMostSelledProducts = listProducts;

    //
    // get  : obtenemos los productos más vendidos por el precio de venta más alto
    //
    List<ProductCatalogue> listNew=[];
    productsList.forEach((key, value) { 
      value.id = key;
      value.quantity = value.quantity;
      value.priceTotal = value.salePrice*value.quantity; 

      listNew.add(value);
    });
    listNew = listNew..sort((a, b) => b.priceTotal.compareTo(a.priceTotal) ); // ordenamiento
    List<ProductCatalogue> listProductBySales = [];
    int count2 = 0;
    for (var data in listNew) {
      
      for ( final ProductCatalogue element in homeController.getCataloProducts) {

        final ProductCatalogue item = element;
        if( data.id== item.id ){ 
            item.quantity =  data.quantity; 
            item.salePrice =data.priceTotal; 
            listProductBySales.add(item); 
            count2++;
            break; 
          }
      }
      if( count2 == 3){ break;}
     }
    // actualizamos lista para mostrar al usuario
    setBestSellingProductsByAmount = listProductBySales;
  }

  void readTransactionsYesterday() {
    // obtenemos los documentos creados en el día de ayer de la fecha actual

    // a la marca de tiempo actual le descontamos las horas del día
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(Timestamp.now()
        .toDate()
        .subtract(Duration(hours: Timestamp.now().toDate().hour, days: 1))
        .millisecondsSinceEpoch);
    // marca de tiempo actual
    Timestamp timeEnd = Timestamp.fromMillisecondsSinceEpoch(Timestamp.now()
        .toDate()
        .subtract(Duration(hours: Timestamp.now().toDate().hour))
        .millisecondsSinceEpoch);

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

  void readTransactionsThisMonth() {
    //obtenemos los documentos creados este mes

    // marca de tiempo actual
    DateTime getTime = Timestamp.now().toDate();
    //  a la marca de tiempo actual le descontamos dias del mes
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(getTime.year, getTime.month, 1, 0).millisecondsSinceEpoch);
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

  void readTransactionsLastMonth() {
    //obtenemos los documentos creados el mes pasado

    // marca de tiempo actual
    DateTime getTime = Timestamp.now().toDate();
    //  a la marca de tiempo actual le descontamos dias del mes
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(getTime.year, getTime.month - 1, 1, 0).millisecondsSinceEpoch);
    // marca de tiempo actual
    Timestamp timeEnd = Timestamp.fromMillisecondsSinceEpoch(
        DateTime(getTime.year, getTime.month, 1, 0).millisecondsSinceEpoch);

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
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch(Timestamp.now()
        .toDate()
        .subtract(Duration(hours: Timestamp.now().toDate().hour))
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

  void readProductWithMoreEarnings(){

    //
    //  devuelve el producto que se obtubo más ganancias
    //

    // var
    Map<String,ProductCatalogue> productsList = {}; // en esta lista almacenamos las ganancias de los productos

    // recorremos todos los tickers que se filtraron
    for (TicketModel ticket in getTransactionsList) {
      // recorremos los productos de cada ticket
      for ( Map item in ticket.listPoduct ) {

        // get 
        final ProductCatalogue productNew = ProductCatalogue.fromMap(item); 
        bool update=false;
         
        productsList.forEach((key, value) {
          if(productNew.id ==  key){
            update= true;
              
              productNew.revenue = value.revenue + ((productNew.salePrice - productNew.purchasePrice ) * productNew.quantity) ;
              productNew.quantity = productNew.quantity + value.quantity ;
          }
        });

        if(update==false){
          productNew.revenue +=  ((productNew.salePrice - productNew.purchasePrice ) * productNew.quantity) ;
        }

        productsList[productNew.id] = productNew;
      }
    }
    // ordenamiento
    //--productsList = productsList.entries.toList()..sort((a, b) => b['priceTotal'].compareTo(a['priceTotal']) );
    // ordenar los productos en forma descendente
    var sortedByKeyMap = Map.fromEntries( productsList.entries.toList()..sort((e1, e2) => e2.value.revenue.compareTo(e1.value.revenue)));

    // nuevos valores
    // obtenemos la ganancia
    int count = 0;
    List<ProductCatalogue> newValuesList = [];
    if( sortedByKeyMap.isNotEmpty){
      for (var element in sortedByKeyMap.entries) { 
        newValuesList.add(element.value);
        count++;
        if( count==3) break;
      }
    } 
    
    setBestSellingProductList =  newValuesList;
  }

   // FUCTIONS

  int readTotalProducts(){
    // leemos la cantidad total de productos

    int value  = 0;
    // recorremos la lista de productos que se vendieron
    for (TicketModel ticket in getTransactionsList) {
      for (Map product in ticket.listPoduct) {
        value=value + (product['quantity'] as int);
      }
    }
    return value;
  }
  String readTotalEarnings(){
    // leemos el total de las ganancias

    double value  = 0;
    double totalSaleValue = 0.0;
    double fullValueAtCost  = 0.0;
    String currencySymbol = '\$';

    // recorremos la lista de productos que se vendieron
    for (TicketModel ticket in getTransactionsList) {
      currencySymbol= ticket.currencySymbol;
      for (Map item in ticket.listPoduct) {

        // var
        final ProductCatalogue product = ProductCatalogue.fromMap(item);

        totalSaleValue+= product.salePrice * product.quantity;
        fullValueAtCost+= product.purchasePrice * product.quantity;
      }
    }
    value = totalSaleValue-fullValueAtCost; // obtenemos el total de las ganancias

    return value==0.0?  '':'+${Publications.getFormatoPrecio(monto:value,moneda: currencySymbol)}';
  }
  String readEarnings({required TicketModel ticket }){
    // leemos ganancias

    // var
    double value  = 0;
    double totalSaleValue = 0.0;
    double fullValueAtCost  = 0.0;
    String currencySymbol = ticket.currencySymbol;

    // recorremos la lista de productos que se vendieron
    for (Map item in ticket.listPoduct) {

      // var
      ProductCatalogue product = ProductCatalogue.fromMap(item);

      // get : precio de venta
      totalSaleValue+= product.salePrice  * product.quantity;
      //  get : precio de compra
      fullValueAtCost+= product.purchasePrice * product.quantity;
    }
    // obtenemos el resultado final
    value = totalSaleValue - fullValueAtCost; // obtenemos el total de las ganancias

    return value  ==  0.0 ?  '':Publications.getFormatoPrecio(monto:value,moneda: currencySymbol);
  }
  String getInfoPriceTotal() {

    //  var
    double total = 0.0;

    for (TicketModel ticket in getTransactionsList) {
      total += ticket.priceTotal;
    }

    return Publications.getFormatoPrecio(monto: total);
  }

  Map getPayMode({required idMode}) {
    switch (idMode) {
      case 'effective':
        return {'name':'Efectivo','color':Colors.green};
      case 'mercadopago':
        return {'name':'Mercado Pago','color':Colors.blue};
      case 'card':
        return {'name':'Tarjeta Credito/Debito','color':Colors.orange};
      default:
        return {'name':'Sin esprecificar','color':Colors.grey};
    }
  }


  void deleteSale({required TicketModel ticketModel}) {
    Widget widget = AlertDialog(
      title: const Text('¿Seguro que quieres eliminar esta venta?',textAlign: TextAlign.center),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () {
              Database.refFirestoretransactions(
                      idAccount: homeController.getIdAccountSelected)
                  .doc(ticketModel.id)
                  .delete();
              Get.back();
            },
            child: const Text('si, eliminar')),
      ]),
    );
    Get.dialog(widget);
  }
}
