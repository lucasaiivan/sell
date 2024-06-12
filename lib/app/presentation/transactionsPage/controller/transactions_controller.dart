import 'dart:async'; 
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:screenshot/screenshot.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:sell/app/data/datasource/database_cloud.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart'; 
import '../../../domain/entities/cashRegister_model.dart';
import '../../../domain/entities/ticket_model.dart';
import '../../home/controller/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';  




class TransactionsController extends GetxController {

  // Create an instance controllers
  final HomeController homeController = Get.find(); 
  final ScreenshotController screenshotController = ScreenshotController(); 

  // stream  
  StreamSubscription?  streamSubscription;

  // estado de carga de datos
  final RxBool _loading = true.obs;
  bool get getLoading => _loading.value;
  set setLoading(bool value) => _loading.value = value;

  // style : estilo de la vista
  final double cardBoderRadius = 20.0;
  double get getCardBoderRadius => cardBoderRadius;
 
  // obtenemos los medios de pagos y sus respectivas ganancias
  // description : efective (Efectivo) - mercadopago (Mercado Pago) - card (Tarjeta De Crédito/Débito)
  Map<String, double> _analyticsMeansOfPaymentMap = {};
  Map<String, double> get getAnalyticsMeansOfPayment => _analyticsMeansOfPaymentMap;
  set setAnalyticsMeansOfPayment(Map<String, double> value) => _analyticsMeansOfPaymentMap = value;
  Map<String, dynamic> getPreferredPaymentMethod() {   
    //obtenemos el modo de pago que se utilizo más
    List<MapEntry<String, double>> list = getAnalyticsMeansOfPayment.entries.toList();
    // ordenamos la lista de mayor a menor
    list.sort((a, b) => b.value.compareTo(a.value));
    // condition : si la lista no esta vacia
    if (list.isNotEmpty) {

      // obtenemos el monto tortal de la transacciones en determinado medio 'list[0].key'
      double totalAmount = 0.0;
      for (var element in getVisibilityTransactionsList) {
        if (element.payMode == list[0].key) {
          totalAmount += element.priceTotal;
        }
      }
      // retornamos el primer elemento de la lista con el medio de pago que se utilizo más
      return {
        'name': TicketModel.getFormatPayMode(id: list[0].key),
        'value': list[0].value,
        'amount': totalAmount,
        
      };
    }
    return {'name': '', 'value': 0.0, 'amount': 0.0};
  }

  // obtenemos los montos de cada caja
  Map<String, Map> _cashiersList = {};
  Map<String, Map> get getCashiersList => _cashiersList;
  set setCashiersList(Map<String, Map> value) => _cashiersList = value;

  // productos más vendidos
  List<ProductCatalogue> mostSelledProducts = [];
  List<ProductCatalogue> get getMostSelledProducts => mostSelledProducts;
  set setMostSelledProducts(List<ProductCatalogue> value) => mostSelledProducts = value; 

  // var : productos más vendidos con mayor beneficio
  List<ProductCatalogue> _bestSellingProductWithHighestProfit = [];
  List<ProductCatalogue> get getBestSellingProductWithHighestProfit => _bestSellingProductWithHighestProfit;
  set setBestSellingProductWithHighestProfit(List<ProductCatalogue> value) => _bestSellingProductWithHighestProfit = value;


  // producto con más ganancias
  List<ProductCatalogue> bestSellingProductList = [];
  List<ProductCatalogue> get getBestSellingProductList => bestSellingProductList;
  set setBestSellingProductList(List<ProductCatalogue> value) => bestSellingProductList = value;

  // text filter
  String _filterText = '';
  String get getFilterText => _filterText;
  set setFilterText(String value) => _filterText = value;

  // lista del historial de transacciones
  List<TicketModel> _historyTransactionsList = [];
  List<TicketModel> get getHistoryTransactionsList => _historyTransactionsList;
  set setHistoryTransactionsList(List<TicketModel> value) => _historyTransactionsList = value;

  // las transacciones del día actual
  List<TicketModel> _transactionsTodayList = [];
  List<TicketModel> get getTransactionsTodayList => _transactionsTodayList;
  set setTransactionsTodayList(List<TicketModel> value) => _transactionsTodayList = value;

  // list transactions visibles que el usuario va ver
  List<TicketModel> _visibilityTransactionsList = [];
  List<TicketModel> get getVisibilityTransactionsList => _visibilityTransactionsList;
  set setVisivilityTransactionsList(List<TicketModel> value) {
    _visibilityTransactionsList = value; 
    readBestSellingProductWithHighestProfit(); // actualizamos los productos más vendidos
    readProductWithMoreEarnings(); // actualizamos el producto con más ganancias
    readAnalyticsMeansOfPayment(); // actualizamos los medios de pago
    readCashAnalysis(); // actualizamos los montos de cada caja
    readBestSellingProduct(); // actualizamos los productos más vendidos por cantidad
    setLoading = false;
    update();
  }

  // var : ticket
  final RxBool _ticketView = false.obs;
  bool get getTicketView => _ticketView.value;
  set setTicketView(bool value) => _ticketView.value = value;


  // set/get
  void filterList({required String key}) {

    setLoading = true;

    
    switch (key) {
      case 'premium': 
        homeController.showModalBottomSheetSubcription(id:'analytic');
        break;
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
    //
    //  obtenemos los documentos creados el año pasado
    //

    // var : marcas de tiempo
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch( DateTime( Timestamp.now().toDate().year-1 ).millisecondsSinceEpoch);
    Timestamp timeEnd = Timestamp.fromMillisecondsSinceEpoch( DateTime( Timestamp.now().toDate().year ).millisecondsSinceEpoch);

    // stream : obtenemos los documentos creados  el año pasado
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = Database.readTransactionsFilterTimeStream(
      idAccount: homeController.getProfileAccountSelected.id,
      timeStart: timeStart,
      timeEnd: timeEnd,
    );
    // si ahi una suscripcion activa la cancelamos
    streamSubscription?.cancel();
    // stream : obtenemos los documentos creados en el día
    streamSubscription=stream.listen((value) {
      // var
      List<TicketModel> transactionsAlllist =  [];
      // get : agregamos los tickets a la lista
      transactionsAlllist = value.docs.map((e) => TicketModel.fromMap(e.data())).toList();
      //  set
      setVisivilityTransactionsList = transactionsAlllist; 
    }); 
    
  }

  void readTransactionsThisYear() {
    //
    //  obtenemos los documentos creados este año 
    //

    // marca de tiempo actual
    DateTime timeNow = Timestamp.now().toDate();
    // a la marca de tiempo actual le descontamos el tiempo hasta la primera fecha del año actual
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch( DateTime( timeNow.year ).millisecondsSinceEpoch);

    // stream : obtenemos los documentos creados este año
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = Database.readTransactionsFilterTimeStream(
      idAccount: homeController.getProfileAccountSelected.id,
      timeStart: timeStart,
      timeEnd: Timestamp.fromDate(timeNow),
    );
    // si ahi una suscripcion activa la cancelamos
    streamSubscription?.cancel();
    // stream : obtenemos los documentos creados en el día
    streamSubscription=stream.listen((value) { 
      // var
      List<TicketModel> transactionsAlllist =  [];
      // get : agregamos los tickets a la lista
      transactionsAlllist = value.docs.map((e) => TicketModel.fromMap(e.data())).toList(); 
      //  set
      setVisivilityTransactionsList = transactionsAlllist;   
    }); 
  }
  // obtenenemos las transacciones del día actual 
  void readTransactionsOfTheDay(){ 
    // formateamos la marca de tiempo actual 
    DateTime now = Timestamp.now().toDate();
    Timestamp timeStart = Timestamp.fromDate(DateTime(now.year, now.month, now.day));

    // stream : obtenemos los documentos creados en el día
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = Database.readTransactionsFilterIsGreaterThanTimeStream(
      idAccount: homeController.getProfileAccountSelected.id,
      timeStart: timeStart, 
    );    
    // si ahi una suscripcion activa la cancelamos
    streamSubscription?.cancel();
    // stream : obtenemos los documentos creados en el día
    streamSubscription= stream.listen((value) { 
      
      // var 
      List<TicketModel> transactionsTodayList = []; 

      // obtenemos las transacciones del dia de hoy
      for (var element in value.docs) {
        TicketModel ticket = TicketModel.fromMap(element.data());
        transactionsTodayList.add(ticket); 
      } 
      //  set 
      setTransactionsTodayList = transactionsTodayList;
      setVisivilityTransactionsList = transactionsTodayList;  
    });

  }
  

  void readBestSellingProductWithHighestProfit() {
    // description : obtener los producto más vendido con mayor beneficio

    // var
    Map<String, ProductCatalogue> productsList = {}; // en esta lista almacenamos las ganancias de los productos

    // recorremos todos los tickers que se filtraron
    for (TicketModel ticket in getVisibilityTransactionsList) {
      // recorremos los productos de cada ticket
      for (dynamic item in ticket.listPoduct) {
        // get
        final ProductCatalogue productNew = ProductCatalogue.fromMap(item); 
        // var
        bool exist = false;
        // verificamos si el producto ya existe en la lista
        productsList.forEach((key, value) {
          // condition :  si el producto ya existe en la lista
          if (productNew.id == key) {
            exist = true;
            // primero obtenmos la ganancia
            if(productNew.purchasePrice!=0){ 
              productNew.revenue = value.revenue + ((productNew.salePrice - productNew.purchasePrice) * productNew.quantity);
            }
            // sumamos la cantidad de productos vendidos
            productNew.quantity = value.quantity + productNew.quantity;
          }
        });
        if(exist){
          productsList[productNew.id] = productNew;
        }else{
          // primero obtenmos la ganancia
          if(productNew.purchasePrice!=0){ 
            productNew.revenue = ((productNew.salePrice - productNew.purchasePrice) * productNew.quantity);
          }
          productsList[productNew.id] = productNew;
        }
      }
    }
    // ordenar los productos en forma descendente
    var sortedByKeyMap = Map.fromEntries(productsList.entries.toList()..sort((e1, e2) => e2.value.revenue.compareTo(e1.value.revenue)));

    // obtenemos una nueva list<ProductCatalogue>
    setBestSellingProductWithHighestProfit = [];
    for (ProductCatalogue element  in sortedByKeyMap.values) {
      // condition  : evaluamos que sea un producto valido
      if (element.code != '') {
        getBestSellingProductWithHighestProfit.add(element);
      }
    }  
  }
 
  // obtenemos las transacciones del dia de ayer
  void readTransactionsYesterday() {

    // formateamos la marca de tiempo actual 
    // var : marcas de tiempo
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch( DateTime( Timestamp.now().toDate().year,Timestamp.now().toDate().month, Timestamp.now().toDate().day-1).millisecondsSinceEpoch);
    Timestamp timeEnd = Timestamp.fromMillisecondsSinceEpoch( DateTime( Timestamp.now().toDate().year,Timestamp.now().toDate().month,Timestamp.now().toDate().day).millisecondsSinceEpoch);

    // stream : obtenemos los documentos creados en el día
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = Database.readTransactionsFilterTimeStream(
      idAccount: homeController.getProfileAccountSelected.id,
      timeStart: timeStart,
      timeEnd: timeEnd,
    );
    // si ahi una suscripcion activa la cancelamos
    streamSubscription?.cancel();
    // stream : obtenemos los documentos creados en el día
    streamSubscription=stream.listen((value) {
      // var
      List<TicketModel> transactionsTodayList = [];  // lista de las transacciones del día de ayer
      List<TicketModel> transactionsAlllist =  []; // lista de las transacciones de los ultimos 5 dias
      // get : agregamos los tickets a la lista
      transactionsAlllist = value.docs.map((e) => TicketModel.fromMap(e.data())).toList(); 
      // obtenemos todas las transacciones del día e ayer
      for (TicketModel ticket in transactionsAlllist ) { 
        transactionsTodayList.add(ticket);
      }  
      //  set 
      setVisivilityTransactionsList = transactionsTodayList;  
    });
  }
  // obtenemos las transacciones del mes actual
  void readTransactionsThisMonth() async{ 

    // marca de tiempo actual
    DateTime timeEnd = Timestamp.now().toDate();
    //  a la marca de tiempo al inicio del mes actual
    Timestamp timeStart = Timestamp.fromMillisecondsSinceEpoch( DateTime(timeEnd.year, timeEnd.month,0,0,0).millisecondsSinceEpoch);

    // stream : obtenemos los documentos creados en los ultimos 5 meses
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = Database.readTransactionsFilterIsGreaterThanTimeStream(
      idAccount: homeController.getProfileAccountSelected.id,
      timeStart: timeStart, 
    ); 
    // si ahi una suscripcion activa la cancelamos
    streamSubscription?.cancel();
    // obtenemos los documentos creados en el día
    streamSubscription=stream.listen((value) {
      // var 
      List<TicketModel> transactionsTodayList = []; 
      List<TicketModel> transactionsAlllist =  [];
      // get : agregamos los tickets a la lista
      transactionsAlllist = value.docs.map((e) => TicketModel.fromMap(e.data())).toList();
      // obtenemos todas las transacciones del mes actual
      for (var ticket in transactionsAlllist) { 
        if (ticket.creation.toDate().month == Timestamp.now().toDate().month) {
          transactionsTodayList.add(ticket);
        }
      }   
      //  set
      setVisivilityTransactionsList = transactionsTodayList;  
    });  

  } 

  // obtenemos las transacciones del mes pasado
  void readTransactionsLastMonth() {
    // var :  marcas de tiempos 
    DateTime now =  Timestamp.now().toDate(); 
    Timestamp timeEnd = Timestamp.fromDate(DateTime(now.year, now.month,1,0));
    Timestamp timeStart = Timestamp.fromDate(DateTime(now.year, now.month-1,1,0));

    // stream : obtenemos los documentos creados  el mes pasado
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = Database.readTransactionsFilterTimeStream(
      idAccount: homeController.getProfileAccountSelected.id,
      timeStart: timeStart,
      timeEnd: timeEnd,
    );
    // si ahi una suscripcion activa la cancelamos
    streamSubscription?.cancel();
    // stream : obtenemos los documentos  
    streamSubscription=stream.listen((value) {
      
      // var
      List<TicketModel> transactionsAlllist = value.docs.map((e) => TicketModel.fromMap(e.data())).toList();
      
      //  set
      setVisivilityTransactionsList = transactionsAlllist; 

    });

  }

  void readProductWithMoreEarnings() { 
    //
    // description : devuelve el producto que se obtubo más ganancias 
    //

    // var
    Map<String, ProductCatalogue> productsList =
        {}; // en esta lista almacenamos las ganancias de los productos

    // recorremos todos los tickers que se filtraron
    for (TicketModel ticket in getVisibilityTransactionsList) {
      // recorremos los productos de cada ticket
      for (dynamic item in ticket.listPoduct) {
        // get
        final ProductCatalogue productNew = ProductCatalogue.fromMap(item);
        bool update = false;

        productsList.forEach((key, value) {
          if (productNew.id == key) {
            update = true;

            productNew.revenue = value.revenue +
                ((productNew.salePrice - productNew.purchasePrice) *
                    productNew.quantity);
            productNew.quantity = productNew.quantity + value.quantity;
          }
        });

        if (update == false) {
          productNew.revenue +=
              ((productNew.salePrice - productNew.purchasePrice) *
                  productNew.quantity);
        }

        // si el precio de compra es '0' no se va a tener en cuenta la ganancia de ese producto
        if (productNew.purchasePrice == 0) {
          productNew.revenue = 0.0;
        } else {
          productsList[productNew.id] = productNew;
        }
      }
    }
    // ordenar los productos en forma descendente
    var sortedByKeyMap = Map.fromEntries(productsList.entries.toList()
      ..sort((e1, e2) => e2.value.revenue.compareTo(e1.value.revenue)));

    //  obtenemos la ganancia
    int count = 0;
    List<ProductCatalogue> newValuesList = [];
    if (sortedByKeyMap.isNotEmpty) {
      for (var element in sortedByKeyMap.entries) {
        // condition  : evaluamos que sea un producto valido
        if (element.value.code != '') {
          newValuesList.add(element.value);
          count++;
          if (count == 3) break;
        }
      }
    }
    // set : seteamos los nuevos valores de los productos con mas ganancias
    setBestSellingProductList = newValuesList;
  }

  void readAnalyticsMeansOfPayment() {
    //  description : obtenemos el medios de pago mas usado y sus respecvtivas monto transacciones e
    setAnalyticsMeansOfPayment = {}; 
    // recorremos todos los tickers
    for (var element in getVisibilityTransactionsList) {
      switch (element.payMode) {
        case 'effective': 
          getAnalyticsMeansOfPayment.containsKey(element.payMode)
              ? getAnalyticsMeansOfPayment[element.payMode] =getAnalyticsMeansOfPayment[element.payMode]!+element.priceTotal
              : getAnalyticsMeansOfPayment[element.payMode] = element.priceTotal; 
          break;
        case 'mercadopago':
          getAnalyticsMeansOfPayment.containsKey(element.payMode)
              ? getAnalyticsMeansOfPayment[element.payMode] =getAnalyticsMeansOfPayment[element.payMode]!+element.priceTotal
              : getAnalyticsMeansOfPayment[element.payMode] = element.priceTotal;
          break;
        case 'card':
          getAnalyticsMeansOfPayment.containsKey(element.payMode)
              ? getAnalyticsMeansOfPayment[element.payMode] =getAnalyticsMeansOfPayment[element.payMode]!+element.priceTotal
              : getAnalyticsMeansOfPayment[element.payMode] = element.priceTotal;
          break;
        default:
          getAnalyticsMeansOfPayment.containsKey('sinespecificar')
              ? getAnalyticsMeansOfPayment['sinespecificar'] = getAnalyticsMeansOfPayment['sinespecificar']!+element.priceTotal
              : getAnalyticsMeansOfPayment['sinespecificar'] =  element.priceTotal;
          break;
      }
    }
  }

  void readCashAnalysis() {
    //obtenemos el monto de cada caja
    setCashiersList = {};
    // recorremos todos los tickers
    for (TicketModel element in getVisibilityTransactionsList) {
      // get : obtenemos los datos del ticket
      TicketModel ticketModel = element;
      // recorremos todas las cajas
      for (CashRegister cashRegister in homeController.listCashRegister) {
        if (cashRegister.id == ticketModel.cashRegisterId) {

          getCashiersList.containsKey(cashRegister.id)
              ? getCashiersList[cashRegister.id] = {
                  'total': (getCashiersList[cashRegister.id]?['total'] as double) +element.priceTotal,
                  'name': cashRegister.description,
                  'sales': getCashiersList[cashRegister.id]?['sales'] +1, 
                  'opening': Publications.getFechaPublicacionFormating(dateTime: cashRegister.opening),
                  'object': cashRegister.update(sales: getCashiersList[cashRegister.id]?['sales'] +1) ,
                }
              : getCashiersList[cashRegister.id] = {
                  'total': element.priceTotal,
                  'name': cashRegister.description,
                  'sales': 1, 
                  'opening': Publications.getFechaPublicacionFormating(dateTime: cashRegister.opening),
                  'object': cashRegister.update(sales: 1),
                };
        }
      }
    }
    // ordenar las cajas en forma ascendente
    setCashiersList = Map.fromEntries( getCashiersList.entries.toList() ..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  // FUCTIONS  

  void readBestSellingProduct(){
    // description : obtenemos los productos más vendidos  por cantidad  

    // var
    Map<String, ProductCatalogue> productsList = {}; // en esta lista almacenamos las ganancias de los productos

    // recorremos todos los tickers que se filtraron
    for (TicketModel ticket in getVisibilityTransactionsList) {
      // recorremos los productos de cada ticket
      for (dynamic item in ticket.listPoduct) {
        // get
        final ProductCatalogue productNew = ProductCatalogue.fromMap(item);  
        // verificamos si el producto ya existe en la lista
        productsList.forEach((key, value) {
          if (productNew.id == key) {
            // si el producto ya existe en la lista, sumamos la cantidad de productos vendidos
            productNew.quantity = value.quantity + productNew.quantity;
          }
        }); 
        productsList[productNew.id] = productNew; 
      }
    }
    // ordenar los productos en forma descendente
    var sortedByKeyMap = Map.fromEntries(productsList.entries.toList()..sort((e1, e2) => e2.value.quantity.compareTo(e1.value.quantity)));

    // obtenemos una nueva list<ProductCatalogue>
    setMostSelledProducts = [];
    for (ProductCatalogue element  in sortedByKeyMap.values) {
      // condition  : evaluamos que sea un producto valido
      if (element.code != '') {
        getMostSelledProducts.add(element);
      }
    } 
  }

  int get readTotalProducts{
    // leemos la cantidad total de productos

    int value = 0;
    // recorremos la lista de productos que se vendieron
    for (TicketModel ticket in getVisibilityTransactionsList) {
      for (Map product in ticket.listPoduct) {
        value = value + (product['quantity'] as int);
      }
    }
    return value;
  }

  String readTotalEarnings() {
    double totalEarnings = 0;
    String currencySymbol = '\$';

    // recorremos la lista de transacciones de venta
    for (TicketModel ticket in getVisibilityTransactionsList) {
      currencySymbol = ticket.currencySymbol;
      double transactionEarnings = 0;

      // recorremos los productos vendidos en la transacción
      for (dynamic item in ticket.listPoduct) {
        final ProductCatalogue product = ProductCatalogue.fromMap(item);

        // si el precio de compra es distinto de cero, sumamos las ganancias
        if (product.purchasePrice != 0) {
          transactionEarnings +=
              (product.salePrice - product.purchasePrice) * product.quantity;
        }
      }

      // sumamos las ganancias de la transacción al total de ganancias
      totalEarnings += transactionEarnings;
    }

    // devolvemos el total de ganancias formateado como una cadena de texto
    return totalEarnings == 0.0
        ? ''
        : Publications.getFormatoPrecio( value: totalEarnings, moneda: currencySymbol);
  } 

  double get getAmountTotalFilter{
    // var
    double total = 0.0;
    // recorremos la lista de transacciones de venta
    for (TicketModel ticket in getVisibilityTransactionsList) { total += ticket.priceTotal;  }
    return total;
  }
  String get getInfoAmountTotalFilter{  
    return Publications.getFormatoPrecio(value: getAmountTotalFilter);
  }
  double get getEarningsFilteredTotal{ 
    // description : obtenemos el total de ganancias de las transacciones filtradas
    //
    // var 
    double transactionEarnings = 0; // ganancias de la transacción

    for (TicketModel ticket in getVisibilityTransactionsList) { 
      // obtenemos las ganancias de la transacción
      transactionEarnings += ticket.getProfit;
    }
    // devolvemos el total de ganancias
    return transactionEarnings;
  }
  String get getEarningsTotalFilteredFormat{ 
    return Publications.getFormatoPrecio(value: getEarningsFilteredTotal);
  }
  // devuelve el porcentaje de ganancias
  int getPercentEarningsFilteredTotal() { 
    // prueba de error 
    if(getAmountTotalFilter == 0) return 0;
    // devolvemos el porcentaje de ganancias
    return (getEarningsFilteredTotal * 100 / getAmountTotalFilter).round();
  }

  Map getPayMode({required String idMode}) {
    if (idMode == 'effective' || idMode == 'Efectivo') {
      return {
        'name': 'Efectivo',
        'color': Colors.green,
        'iconData': Icons.money
      };
    }
    if (idMode == 'mercadopago' || idMode == 'Mercado Pago') {
      return {
        'name': 'Mercado Pago',
        'color': Colors.blue,
        'iconData': Icons.handshake_outlined
      };
    }
    if (idMode == 'card' || idMode == 'Tarjeta De Crédito/Débito') {
      return {
        'name': 'Tarjeta Cred/Deb',
        'color': Colors.orange,
        'iconData': Icons.credit_card
      };
    }
    return {'name': 'Sin esprecificar', 'color': Colors.grey};
  }

  void deleteTicket({required TicketModel ticketModel}) {
    Database.refFirestoretransactions(idAccount: homeController.getIdAccountSelected).doc(ticketModel.id).delete();
  }

  void deleteSale({required TicketModel ticketModel}) {
    Widget widget = AlertDialog(
      title: const Text('¿Seguro que quieres eliminar esta transacción?',
          textAlign: TextAlign.center),
      content: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () {
              // firebase : elimina la transacción
              Database.refFirestoretransactions(idAccount: homeController.getIdAccountSelected).doc(ticketModel.id).delete();
              Get.back();Get.back();
            },
            child: const Text('si, eliminar')),
      ]),
    );
    Get.dialog(widget);
  }

  // WIDGETS COMPONENTS
  Widget getPieChartView({required List chartData  , double size = 100 }){

    // var
    Map data = {};
    double radius = size / 2;
    TextStyle textStyle = TextStyle(fontSize: radius / 4,fontWeight: FontWeight.bold,color: Colors.white );

    // add data test
    chartData.add({'description' : 'Mercado Pago','value': 259.0,'color':Colors.blue});
    chartData.add({'description' : 'Efectivo','value': 500.0,'color':Colors.green});
    chartData.add({'description' : 'Tarjeta De Crédito/Débito','value': 300.0,'color':Colors.orange});
    chartData.add({'description' : 'Sin esprecificar','value': 100.0,'color':Colors.grey}); 

    // agrega el key description y value 
    for (var item in chartData) { data[item['description']] = item['value']; }

    // calcular el total de los valores de [data]
    double total = 0.0;
    for (var item in data.values) {
      total += item;
    }
    // convertir los valores de [data] en porcentajes
    for (var item in data.keys) {
      data[item] = (data[item] * 100 / total).roundToDouble();
    }

    // crear una lista de PieChartSectionData
    List<PieChartSectionData> sections = [];
    for (var item in data.entries) {

      sections.add(PieChartSectionData(
        value: item.value, 
        title: item.value % 1 == 0 ? '${item.value.round()}%' : '${item.value}%',
        titleStyle: textStyle,
        color: getPayMode(idMode: item.key)['color'],
        radius: radius,
      ));
    }
    // generar List de chip con los datos de [data]
    List<Widget> listChip = [];
    for (var item in chartData ) {
      listChip.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ComponentApp().dividerDot(),
              Text('${item['description']}', style:textStyle.copyWith(color: item['color'] ) ),
            ],
          ),
        ),
      );
    }

    // PieChart : muestra el grafico de torta
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox( 
          height: size*2,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: PieChart(PieChartData(
                    centerSpaceRadius: 5,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    sections: sections,
                  )
                ),
              ),
            const SizedBox(height:5),
            SizedBox(
              width:size*2,
              child: Wrap( 
                runSpacing: 2, 
                alignment: WrapAlignment.center,
                children: listChip,
              ),
            ),
            ],
          ),
        ),
      );


  }
 
  // void : devolver una lista de [double] con el porcentaje en el rango de [0.0 al 9.9] de cada monto [double] de la lista[double] que se obtiene por parametro
  List<double> getPorcentList({required List<double> list}){
 

    // var
    List<double> listPorcent = [];
    double value = 0;
    // calcular el precio mas alto
    for (var item in list) {
      if(item > value) value = item;
    }
    // convertir los valores de [list] en porcentajes  expresados en el rango de [0.0 al 9.9]
    for (var item in list) {
      listPorcent.add((item * 10 / value)); 
    } 
    return listPorcent;
  }

  Widget viewPercentageBarCharTextDataHorizontal({required List<MapEntry<dynamic, dynamic>> chartData, double height = 22 }){
      // description : muestra una lista con barra de porcentajes coloreada en forma horizontal
      // 
      // var 
      TextStyle textStyle = TextStyle(fontSize: height*0.5,fontWeight: FontWeight.w900,color: Colors.white );

      // converit chartData en una nuevo Map
      List<Map> map = [];
      for (var item in chartData) {
        map.add({
          'name':getPayMode(idMode: item.key)['name'],
          'value':item.value,
          'priceTotal':Publications.getFormatoPrecio(value: item.value),
          'color':getPayMode(idMode: item.key)['color'],
          'iconData':getPayMode(idMode: item.key)['iconData'],
          });
      } 
      
      // var
      List<int> listPorcent = [];
      double value = 0;
      // obtener el total de los valores 
      for (Map item in map){
        value += item['value'];
      }
      // convertir los valores de [list] en porcentajes  expresados en el rango de [0 al 100]
      for (Map item in map) {
        listPorcent.add((item['value'] * 100 / value).round());
      } 

      // agregar el nuevo campo 'porcent' a chartData en su respectivas posisicon
      for (var i = 0; i < chartData.length; i++) {
        map[i]['porcent'] = listPorcent[i];
      }

      // determinar el index que mayor valor tiene
      int indexMax = 0;
      for (var i = 0; i < map.length; i++) {
        if(map[i]['porcent'] > map[indexMax]['porcent']) indexMax = i;
      }
  

      return ListView(
        shrinkWrap: true,
        children: List.generate(chartData.length, (index) { 
          // var 
          height = indexMax == index ? height+6 : height;
          Widget icon = indexMax == index ?map[index]['iconData'] == null ? Container() : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(map[index]['iconData'],color: Colors.white ,size: 20),
          ):Container();

          // obtener el porcentaje formateado  redondeado sin reciduo
          String porcent = map[index]['porcent'] % 1 == 0 ? '${map[index]['porcent'].round()}%' : '${map[index]['porcent']}%';
          String priceTotal = map[index]['priceTotal'];
          // crear la barra de porsentaje de fondo con color gris
          Widget percentageBarBackground = Material( 
            borderRadius: BorderRadius.circular(3),
            color: Colors.black12,
            child: SizedBox(height:height,width: double.infinity,),
          );
          // crear un [Material] con el color del 'chartData[index]['color']'  y pintado segun el porcentaje 
          Widget percentageBar = Material( 
            borderRadius: BorderRadius.circular(3), 
            color: map[index]['color'],
            child: FractionallySizedBox(
              widthFactor: map[index]['porcent'] /  100,  
              child:  Container(height:height),
            ),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Stack(  
              alignment: Alignment.centerLeft, // centrar contenido
              children: [
                percentageBarBackground,
                percentageBar,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    children: [
                      // icon : muestra el icono solo del medio de pago que tiene el mayor porcentaje
                      icon,
                      // text : medio de pago, porcentaje y monto total
                      Flexible(child: Text(map[index]['name']+' '+porcent+' '+priceTotal,style: textStyle,overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        ),
      );
  }
  Widget viewBarChartData({required List<Map> chartData, double size = 100 }){
    
    // var
    bool isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
    Map data = {};
    double radius = size / 2;
    TextStyle textStyle = TextStyle(fontSize: radius / 5,fontWeight: FontWeight.bold,color: Colors.white );
 
    // agrega el key description y value 
    for (var item in chartData) { data[item['name']] = item['value']; }

    // calcular el total de los valores de [data]
    double total = 0.0;
    for (var item in data.values) {
      total += item;
    }
    // convertir los valores de [data] en porcentajes
    for (var item in data.keys) {
      data[item] = (data[item] * 100 / total).roundToDouble();
    }

    // crear una lista de PieChartSectionData
    List<PieChartSectionData> sections = [];
    for (var item in data.entries) {

      sections.add(PieChartSectionData(
        value: item.value, 
        title: item.value % 1 == 0 ? '${item.value.round()}%' : '${item.value}%',
        titleStyle: textStyle,
        color: getPayMode(idMode: item.key)['color'],
        radius: radius,
      ));
    }
    // generar List de chip con los datos de [data]
    List<Widget> listChip = [];
    for (var item in chartData ) {
      listChip.add(
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ComponentApp().dividerDot(color: item['color'],size: 8),
              Text('${item['name']}', style:textStyle.copyWith(color: isDarkMode?null:item['color'],fontWeight: FontWeight.w700 ) ),
            ],
          ),
        ),
      );
    }

    BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,  
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: barColor,
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ), 
          borderSide: isTouched ? const BorderSide(color:Colors.black12) : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(show: true,toY: 10,color: Colors.black12),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
    }
    List<BarChartGroupData> showingGroup(){

      // crear lista de valores [el monto] a una lista de valores en porcentajes
      List<double> listPorcent = getPorcentList(list: List.generate(chartData.length, (index) => chartData[index]['value'] ));

      return List.generate(listPorcent.length, (index) => makeGroupData(index,listPorcent[index],barColor: chartData[index]['color'] ));

    }
    
      // BarChart : muestra el grafico de barras
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // view : grafico de barras
            Flexible(
              child: BarChart(  
                BarChartData(
                  barGroups: showingGroup(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),  
                  // desabilitar el eje de las x
                  titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      getTitlesWidget:(value, title){  
                        // obtener primer caracter de la chartData['description'] de la lista
                        String firstLetter = chartData[value.toInt()]['name'].toString().substring(0,1);
 
                        return Text(firstLetter,style: textStyle);
                      } ,
                      reservedSize: 25,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                  
                ), 
              
              swapAnimationDuration: const Duration(milliseconds: 150), // Optional
              swapAnimationCurve: Curves.bounceIn, // Optional
                ),
            ),
            // view : lista de chips con un Wrap
            Wrap( 
              runSpacing: 0, 
              alignment: WrapAlignment.center,
              children: listChip,
            ),
          ],
        ),
      ); 


  }

  // ----------------------- //
  // ------ OVERRIDE-------- //
  // ----------------------- //
  @override
  void onInit() async {
    super.onInit();
    filterList(key: 'hoy');
  }

  @override
  void onClose() {}
 

}