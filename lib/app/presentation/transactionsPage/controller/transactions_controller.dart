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
    Map<String,Map> productsList = {};

    // recorremos todos los tickers que se filtraron
    for (TicketModel ticket in list) {
      // recorremos los productos de cada tocket
      for ( Map item in ticket.listPoduct ) {

        // get 
        ProductCatalogue product = ProductCatalogue.fromMap(item);

        if( ! productsList.containsKey(product.id) ){
          // si ya existe el producto
  
          //productsList.update(product.id, (value) => value.update('quantity', (value) => value + product.quantity));
          //productsList.update(product.id, (value) => value.update('salePrice', (value) => value + product.salePrice));
          productsList[product.id] = { 'quantity': productsList[product.id]??0.0 + product.quantity , 'salePrice':product.salePrice}; // sumamos los productos que se repiten
        }else{
          // si no existe el producto, lo creamos
          productsList[product.id] ={'quantity':1,'salePrice':product.salePrice};
        }
      }
    }

    // ordenar los productos en forma descendente
    Map<String,Map> sortMap = Map.fromEntries( (productsList.entries.toList()..sort((a, b)=> b.value['quantity'].compareTo(a.value['quantity']))) );
    // y por ultimo obtenemos los 3 treprimeros productos
    Map<String,int> featuredProducts = {}; // limit 3 items
    int count = 0;
    for( final item in sortMap.entries){
      count++;
      featuredProducts[item.key] = item.value['quantity'].toInt(); // add
      if( count == 5){ break;}
    }
    // obtenemos los productos más vendidos por cantidad
    List<ProductCatalogue> listProducts = [];
    for( var elment in featuredProducts.entries){
      for ( ProductCatalogue element in homeController.getCataloProducts) {
        if( elment.key == element.id ){ 
            element.quantity =  elment.value ; 
            listProducts.add(element); break; 
          }
      }
    }
    // actualizamos lista para mostrar al usuario
    setMostSelledProducts = listProducts;

    // obtenemos los productos más vendidos por el precio
    List<Map> listNew=[];
    productsList.forEach((key, value) { 
      listNew.add({'id':key,'quantity':value['quantity'],'priceTotal':(value['salePrice']*value['quantity']??0)});
    });
    listNew = listNew..sort((a, b) => b['priceTotal'].compareTo(a['priceTotal']) ); // ordenamiento
    List<ProductCatalogue> listProductBySales = [];
    int count2 = 0;
    for (var data in listNew) {
      
      for ( ProductCatalogue element in homeController.getCataloProducts) {
        if( data['id'] == element.id ){ 
            element.quantity =  data['quantity']; 
            element.salePrice =data['priceTotal']; 
            listProductBySales.add(element); 
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
    //  devuelve el producto que se obtubo más ganancias

    // var
    Map<String,double> productsList  = {}; // en esta lista almacenamos las ganancias de los productos

    // recorremos la lista de tickets y obtenemos la ganancias de los productos que se vendieron
    for (TicketModel ticket in getTransactionsList) {
      for (Map itenm in ticket.listPoduct) {

        ProductCatalogue product = ProductCatalogue.fromMap(itenm);

        // obtenemos la ganancia 
        double revenueValue =product.salePrice - product.purchasePrice;

        // comprobamos si existe el producto en la nueva lista 
        if( productsList.containsKey(product.id) ){ 
          productsList.update(product.id, (value) => value + revenueValue);
        }else{
          // es un producto nuevo //
          // asignamos el nuevo valor que es la ganancia del producto
          productsList[product.id] = revenueValue ;
        }
      } 
    } 
    // ordenamiento
    //productsList = productsList.entries.toList()..sort((a, b) => b['priceTotal'].compareTo(a['priceTotal']) );
    // ordenar los productos en forma descendente
    var sortedByKeyMap = Map.fromEntries( productsList.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));

    // nuevos valores
    // obtenemos la ganancia
    int count = 0;
    List newValuesList = [];
    if( sortedByKeyMap.isNotEmpty){
      for (var element in sortedByKeyMap.entries) { 
        newValuesList.add(element);
        count++;
        if( count==3) break;
      }
    }
    // obtenemos los datos del producto
    List<ProductCatalogue> newList = [];
    for ( var data in newValuesList) {
      for (ProductCatalogue element in homeController.getCataloProducts) { 
        if(element.id == data.key ){
          // asignamos las ganancias acumuladas de este producto 
          element.revenue = data.value;
          // add
          newList.add(element);
          break;
        }
      }
    } 
    
    setBestSellingProductList =  newList;
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
        ProductCatalogue product = ProductCatalogue.fromMap(item);

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
