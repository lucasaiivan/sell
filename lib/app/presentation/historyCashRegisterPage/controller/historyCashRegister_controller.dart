import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/cashRegister_model.dart';
import '../../home/controller/home_controller.dart';
import '../views/historyCashRegister_view.dart';

class HistoryCashRegisterController extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();
  // text filter
  RxString textFilter = 'Últimos 7 Días'.obs;
  String get getTextFilter => textFilter.value;
  set setTextFilter(value) => textFilter.value = value;
  // estado para saber si se esta cargando datos
  bool load = true;

  // lista de arqueos de caja
  RxList<CashRegister> listCashRegister = <CashRegister>[].obs;
  List<CashRegister> get getListCashRegister => listCashRegister;
  set setListCashRegister(value) => listCashRegister.value = value;

  // load : obtenemos los arqueos de caja del dia de hoy
  void loadCashRegisterToday() async {
    setTextFilter = 'Hoy';
    // firebase : obtenemos los documentos de arqueos de caja del dia de hoy
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 1)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(
              CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      update(); // actualizamos la vista
    });
  }

  // load : obtenemos los arqueos de caja del dia de ayer
  void loadCashRegisterYesterday() async {
    setTextFilter = 'Ayer';
    // firebase : obtenemos los documentos de arqueos de caja del dia de ayer
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 2)))
        .where('opening',
            isLessThan: DateTime.now().subtract(const Duration(days: 1)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(
              CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      update(); // actualizamos la vista
    });
  }

  // load : obtenemos los arqueos de caja de los ultimos 7 dias
  void loadCashRegisterLast7Days() async {
    setTextFilter = 'Últimos 7 Días';
    load = true;  
    // firebase : obtenemos los documentos de arqueos de caja de los ultimos 7 dias
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',isGreaterThan: DateTime.now().subtract(const Duration(days: 7)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      load = false; // terminamos de cargar
      update(); // actualizamos la vista
    });
  }

  // load : cargamos los arqueos de caja de los ultimos 30 dias
  void loadCashRegisterLast30Days() async {
    setTextFilter = 'Últimos 30 Días';
    // firebase : obtenemos los documentos de arqueos de caja de los ultimos 30 dias
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',isGreaterThan: DateTime.now().subtract(const Duration(days: 30)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      } 
      load = false; // terminamos de cargar
      update(); // actualizamos la vista
    });
  }

  // load : obtenemos los arqueos de caja de este mes
  void loadCashRegisterThisMonth() async {
    setTextFilter = 'Este mes';
    // firebase : obtenemos los documentos de arqueos de caja de este mes
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 30)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(
              CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      update(); // actualizamos la vista
    });
  }

  // load : obtenemos los arqueos de caja del mes pasado
  void loadCashRegisterLastMonth() async {
    setTextFilter = 'El mes pasado';
    // firebase : obtenemos los documentos de arqueos de caja del mes pasado
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 60)))
        .where('opening',
            isLessThan: DateTime.now().subtract(const Duration(days: 30)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(
              CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      update(); // actualizamos la vista
    });
  }

  // load : obtenemos los arqueos de caja de este año
  void loadCashRegisterThisYear() async {
    setTextFilter = 'Este año';
    // firebase : obtenemos los documentos de arqueos de caja de este año
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .where('opening',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 365)))
        .orderBy('opening', descending: true)
        .get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) {
          // add : seteamos y agregamos los arqueos de caja
          getListCashRegister.add(
              CashRegister.fromMap(element.data() as Map<String, dynamic>));
        }
      }
      update(); // actualizamos la vista
    });
  }

  // filter : filtramos los arqueos de caja
  void filterCashRegister({required String filter}) async {
    switch (filter) {
      case 'premium':
        homeController.showModalBottomSheetSubcription(id:'analytic');
        break;
      case 'Hoy':
        loadCashRegisterToday();
        break;
      case 'Ayer':
        loadCashRegisterYesterday();
        break;
      case 'Últimos 7 Días':
        loadCashRegisterLast7Days();
        break;
      case 'Este mes':
        loadCashRegisterThisMonth();
        break;
      case 'Últimos 30 Días':
        loadCashRegisterLast30Days();
        break;
      case 'El mes pasado':
        loadCashRegisterLastMonth();
        break;
      case 'Este año':
        loadCashRegisterThisYear();
        break;
      default:
    }
  }

  // delete : eliminamos un arqueo de caja
  void deleteCashRegister({required CashRegister cashRegister}) async {
    // firebase : eliminamos el arqueo de caja
    Future<void> query = Database.refFirestoreRecords(
            idAccount: homeController.getProfileAccountSelected.id)
        .doc(cashRegister.id)
        .delete();
    query.then((value) {
      // eliminamos el arqueo de caja de la lista
      getListCashRegister.remove(cashRegister);
      update(); // actualizamos la vista
    });
  }

  // generate widget
  List<Widget> get getTransactionsWidgetsViews {

    // var
    List<Widget> transactions = []; // lista de widgets de transacciones 

    // define una variable currentDate para realizar el seguimiento de la fecha actual en la que se está construyendo la lista. Inicializa esta variable con la fecha de la primera transacción en la lista
    DateTime currentDate = getListCashRegister[0].opening;
    // add : Itera sobre la lista de transacciones y verifica si la fecha de la transacción actual es diferente a la fecha actual. Si es así, crea un elemento Divider y actualiza la fecha actual
    for (int i = 0; i < getListCashRegister.length; i++) { 
      // condition : si la fecha actual es diferente a la fecha de la transacción actual
      if (currentDate.day != getListCashRegister[i].opening.day || i == 0) {
        //  set : actualiza la fecha actual de la variable
        currentDate = getListCashRegister[i].opening;
        // var
        String amountTotal = getAmountTotalByDate(date: currentDate);
        // add : añade un Container con el texto de la fecha como divisor
        transactions.add(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          width: double.infinity,
          color: Colors.grey.withOpacity(.05),
          child: Opacity(
            opacity: 0.7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Expanded(
                  child: Text(
                    Publications.getFechaPublicacionSimple(getListCashRegister[i].opening,Timestamp.now().toDate()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
                // text : monto total 
                Text(amountTotal,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              ],
            ),
          )));
      }
      //  add : añade el elemento de la lista actual a la lista de widgets
      transactions.add(itemTile(cashRegister: getListCashRegister[i]));
      // agregar un divider
      transactions.add(ComponentApp().divider(thickness: 0.09));
    }
    return transactions;
  }
  String getAmountTotalByDate({required DateTime date}){
    // description : obtiene el monto total (formateado) de los arqueos de caja de una fecha especifica
    double amount = 0;
    for (var element in getListCashRegister) {
      if (element.opening.day == date.day && element.opening.month == date.month && element.opening.year == date.year) {
        amount += element.balance == 0 ? element.getExpectedBalance : element.balance;
      }
    }
    return Publications.getFormatoPrecio(value: amount);
  }

  // WIDGETS COMPONENTS
  Widget itemTile({required CashRegister cashRegister}) {
    // var : tiempo de apertura de caja
    int hour = cashRegister.closure.difference(cashRegister.opening).inHours;
    int minutes = cashRegister.closure.difference(cashRegister.opening).inMinutes.remainder(60);
    String time = hour==0?'Tiempo: $minutes minutos':'Tiempo: $hour horas y $minutes minutos';
    // var : subtitle
    String subtitle = 'Balance: ${Publications.getFormatoPrecio(value: cashRegister.balance == 0 ? cashRegister.getExpectedBalance : cashRegister.balance)}\n$time';

    return ListTile(
      title: Text(Publications.getFechaPublicacionFormating(
          dateTime: cashRegister.opening)),
      subtitle: Opacity(opacity: 0.7, child: Text(subtitle)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(opacity: 0.5, child: Text(cashRegister.description)),
          const Opacity(
              opacity: 0.5,
              child: Icon(Icons.arrow_right_outlined, size: 16))
        ],
      ),
      onTap: () { 
        Get.dialog(
          Theme(
            data: ThemeData.light(),
            child: ClipRRect(
              borderRadius: const  BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(0)),
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar:AppBar(
                  backgroundColor: Colors.white,
                  actions: [
                    // button : eliminar
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded),
                      onPressed: () {
                        registerDeleteConfirmDialog(cashRegister: cashRegister);
                        
                      },
                    ),
                    
                  ],
                ),
                body: CashRegisterDetailView(cashRegister: cashRegister),
                floatingActionButton: FloatingActionButton(
                  heroTag: 'Compartir',
                  onPressed: () { 
                    Utils().getDetailArqueoScreenShot(context: Get.context!,cashRegister: cashRegister);
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.share,color: Colors.white,),
                ),
                ),
              
            ),
          ),
        ); 
      },
    );
    
  }  
  void registerDeleteConfirmDialog({required CashRegister cashRegister}){
    // dialog : confirmar eliminacion
    Get.dialog(AlertDialog(
      title: const Text('Eliminar informe de caja'),
      content: const Text('¿Está seguro de eliminarlo?'),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () {
              // delete : eliminar caja
              deleteCashRegister( cashRegister: cashRegister);
              Get.back();
              Get.back();
            },
            child: const Text('Si, eliminar')),
      ],
    ));
  }


  @override
  void onInit() async {
    super.onInit();
    // load : obtenemos los arqueos de caja de los ultimos 7 dias
    loadCashRegisterLast7Days();
  }

  @override
  void onClose() {}
}
