
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart'; 
import '../../../core/utils/widgets_utils.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/cashRegister_model.dart';
import '../../home/controller/home_controller.dart';

class HistoryCashRegisterController extends GetxController {

  // others controllers
  final HomeController homeController = Get.find(); 
  // text filter
  RxString textFilter = 'Últimos 30 Días'.obs;
  String get getTextFilter => textFilter.value;
  set setTextFilter(value) => textFilter.value = value;
  // estado para saber si se esta cargando datos
  bool load = true;

  // lista de arqueos de caja
  RxList<CashRegister> listCashRegister = <CashRegister>[].obs;
  List<CashRegister> get getListCashRegister => listCashRegister;
  set setListCashRegister(value) => listCashRegister.value = value;

  // load : cargamos los arqueos de caja de los ultimos 30 dias
  void loadCashRegisterLast30Days() async {
    setTextFilter = 'Últimos 30 Días';
    // firebase : obtenemos los documentos de arqueos de caja de los ultimos 30 dias  
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(idAccount: homeController.getProfileAccountSelected.id).where('opening', isGreaterThan: DateTime.now().subtract(const Duration(days: 30))).orderBy('opening', descending: true).get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) { 
          // add : seteamos y agregamos los arqueos de caja 
          getListCashRegister.add( CashRegister.fromMap(element.data()  as Map<String, dynamic>));
        } 
      }else{
        // sin datos
      }
      load = false; // terminamos de cargar
      update(); // actualizamos la vista

    });
  }
  // load : obtenemos los arqueos de caja del dia de hoy
  void loadCashRegisterToday() async {
    setTextFilter = 'Hoy';
    // firebase : obtenemos los documentos de arqueos de caja del dia de hoy
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(idAccount: homeController.getProfileAccountSelected.id).where('opening', isGreaterThan: DateTime.now().subtract(const Duration(days: 1))).orderBy('opening', descending: true).get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) { 
          // add : seteamos y agregamos los arqueos de caja 
          getListCashRegister.add( CashRegister.fromMap(element.data()  as Map<String, dynamic>));
        } 
      } 
      update(); // actualizamos la vista

    });
  }
  // load : obtenemos los arqueos de caja del dia de ayer
  void loadCashRegisterYesterday() async {
    setTextFilter = 'Ayer';
    // firebase : obtenemos los documentos de arqueos de caja del dia de ayer
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(idAccount: homeController.getProfileAccountSelected.id).where('opening', isGreaterThan: DateTime.now().subtract(const Duration(days: 2))).where('opening', isLessThan: DateTime.now().subtract(const Duration(days: 1))).orderBy('opening', descending: true).get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) { 
          // add : seteamos y agregamos los arqueos de caja 
          getListCashRegister.add( CashRegister.fromMap(element.data()  as Map<String, dynamic>));
        } 
      } 
      update(); // actualizamos la vista

    });
  }
  // load : obtenemos los arqueos de caja de este mes
  void loadCashRegisterThisMonth() async {
    setTextFilter = 'Este mes';
    // firebase : obtenemos los documentos de arqueos de caja de este mes
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(idAccount: homeController.getProfileAccountSelected.id).where('opening', isGreaterThan: DateTime.now().subtract(const Duration(days: 30))).orderBy('opening', descending: true).get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) { 
          // add : seteamos y agregamos los arqueos de caja 
          getListCashRegister.add( CashRegister.fromMap(element.data()  as Map<String, dynamic>));
        } 
      } 
      update(); // actualizamos la vista

    });
  }
  // load : obtenemos los arqueos de caja del mes pasado
  void loadCashRegisterLastMonth() async {
    setTextFilter = 'El mes pasado';
    // firebase : obtenemos los documentos de arqueos de caja del mes pasado
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(idAccount: homeController.getProfileAccountSelected.id).where('opening', isGreaterThan: DateTime.now().subtract(const Duration(days: 60))).where('opening', isLessThan: DateTime.now().subtract(const Duration(days: 30))).orderBy('opening', descending: true).get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) { 
          // add : seteamos y agregamos los arqueos de caja 
          getListCashRegister.add( CashRegister.fromMap(element.data()  as Map<String, dynamic>));
        } 
      } 
      update(); // actualizamos la vista

    });
  }
  // load : obtenemos los arqueos de caja de este año
  void loadCashRegisterThisYear() async {
    setTextFilter = 'Este año';
    // firebase : obtenemos los documentos de arqueos de caja de este año
    Future<QuerySnapshot<Object?>> query = Database.refFirestoreRecords(idAccount: homeController.getProfileAccountSelected.id).where('opening', isGreaterThan: DateTime.now().subtract(const Duration(days: 365))).orderBy('opening', descending: true).get();
    query.then((value) {
      getListCashRegister.clear(); // limpiamos la lista de cajas
      if (value.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value.docs) { 
          // add : seteamos y agregamos los arqueos de caja 
          getListCashRegister.add( CashRegister.fromMap(element.data()  as Map<String, dynamic>));
        } 
      } 
      update(); // actualizamos la vista

    });
  }
  // filter : filtramos los arqueos de caja
  void filterCashRegister({required String filter}) async {
    switch (filter) {
      case 'Hoy':
        loadCashRegisterToday();
        break;
      case 'Ayer':
        loadCashRegisterYesterday();
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
    Future<void> query=Database.refFirestoreRecords(idAccount:homeController.getProfileAccountSelected.id).doc(cashRegister.id).delete();
    query.then((value) {
      // eliminamos el arqueo de caja de la lista
      getListCashRegister.remove(cashRegister);
      update(); // actualizamos la vista
    });
  }
  // generate widget
  List<Widget> get getTransactionsWidgetsViews{

    List<Widget> transactions = []; // lista de widgets de transacciones

    // define una variable currentDate para realizar el seguimiento de la fecha actual en la que se está construyendo la lista. Inicializa esta variable con la fecha de la primera transacción en la lista
    DateTime currentDate = getListCashRegister[0].opening;
    // add : Itera sobre la lista de transacciones y verifica si la fecha de la transacción actual es diferente a la fecha actual. Si es así, crea un elemento Divider y actualiza la fecha actual
    for (int i = 0; i < getListCashRegister.length; i++) {
      // condition : si es la primera transacción
      if(i==0){
        // add : añade tarjetas de estadísticas
        //transactions.add(StaticsCards());  
      }
      // condition : si la fecha actual es diferente a la fecha de la transacción actual
      if (currentDate.day != getListCashRegister[i].opening.day || i==0) {
        //  set : actualiza la fecha actual de la variable
        currentDate = getListCashRegister[i].opening;
        // add : añade un Container con el texto de la fecha como divisor
        transactions.add(Container(padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),width: double.infinity,color: Colors.grey.withOpacity(.05),child: Opacity(opacity: 0.8,child: Text(Publications.getFechaPublicacionSimple(getListCashRegister[i].opening,Timestamp.now().toDate()),textAlign: TextAlign.center,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w300)))));
      }
      //  add : añade el elemento de la lista actual a la lista de widgets
      transactions.add(itemTile(cashRegister: getListCashRegister[i]));
      // agregar un divider
      transactions.add( ComponentApp().divider(thickness: 0.05));
    }
    return transactions;
  }

  // WIDGETS COMPONENTS
  Widget itemTile({required CashRegister cashRegister}){

    // var 
    String subtitle ='caja ${Publications.getFormatoPrecio(monto:cashRegister.balance==0?cashRegister.getExpectedBalance:cashRegister.balance)}';

    return ListTile(
      title: Text(Publications.getFechaPublicacionFormating(dateTime:cashRegister.opening)),
      subtitle: Opacity(opacity: 0.7,child: Text( subtitle)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(opacity: 0.5,child: Text(cashRegister.description)),
          const Opacity(opacity: 0.5,child: Icon(Icons.arrow_forward_ios_rounded,size:16))
        ],
      ),
      onTap: () {
        //  showDialog  : muestra el dialogo de detalles
        showDialog(
          context: Get.context!,
          builder: (BuildContext context) => viewDetails(cashRegister: cashRegister),
        );
      },
    );
  }
  Widget viewDetails({required CashRegister cashRegister}){

    // others controllers
    final HistoryCashRegisterController transactionsController = Get.find();

    // var 
    TextStyle textStyleDescription = const TextStyle( fontWeight: FontWeight.w300);
    TextStyle textStyleValue = const TextStyle(fontSize: 16,fontWeight: FontWeight.w600);

    return AlertDialog(
      content: SizedBox(
        // establece el ancho a toda la pantalla
        width:  Get.width,
        // SingleChildScrollView : permite hacer scroll en el contenido
        child: SingleChildScrollView(
          child: Column( 
              //padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              children: [
                // text : titulo de la alerta
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text("Información de transacción",textAlign: TextAlign.center, style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400)),
                ),
                const SizedBox(height: 20),
                // view info : descripcion
                Row(children: [Text('Descripción',style: textStyleDescription),const Spacer(),Text(cashRegister.description,style: textStyleValue)]),
                // view info : fecha de inicio 
                const SizedBox(height: 12),
                Row(children: [Text('Inicio',style: textStyleDescription), const Spacer(),Text(Publications.getFechaPublicacionFormating(dateTime: cashRegister.opening),style: textStyleValue)]), 
                // view info : fecha de cierre
                const SizedBox(height: 12),
                Row(children: [Text('Cierre',style: textStyleDescription),const Spacer(),Text(Publications.getFechaPublicacionFormating(dateTime: cashRegister.closure),style: textStyleValue)]),
                // view info : efectivo incial
                const SizedBox(height: 12),
                Row(children: [Text('Efectivo inicial',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.expectedBalance),style: textStyleValue)]),
                //  view info : cantidad de venta
                const SizedBox(height: 12),
                Row(children: [Text('Cantidad de ventas',style: textStyleDescription),const Spacer(),Text(cashRegister.sales.toString(),style: textStyleValue)]),
                // view info : facturacion
                const SizedBox(height: 12),
                Row(children: [Text('Facturación',style: textStyleDescription),const Spacer(),Text( Publications.getFormatoPrecio(monto:cashRegister.billing),style: textStyleValue)]),
                // view info : egresos
                const SizedBox(height: 12),
                Row(children: [Text('Egresos',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.cashOutFlow),style: textStyleValue.copyWith(color: Colors.red.shade300))]),
                // view info : ingresos
                const SizedBox(height: 12),
                Row(children: [Text('Ingresos',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.cashInFlow),style: textStyleValue.copyWith(color: cashRegister.cashInFlow==0?null:Colors.green.shade300))]),
                // view info : monto esperado en la caja
                const SizedBox(height: 12),
                const Divider(),
                Row(children: [Text('Monto esperado',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.getExpectedBalance),style: textStyleValue)]),
                const SizedBox(height: 12),
                cashRegister.balance==0?Container():Row(children: [Text('Monto de cierre',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.balance),style: textStyleValue)]),
                cashRegister.balance==0?Container():const SizedBox(height: 12),
                cashRegister.balance==0?Container():Row(children: [Text('Diferencia',style: textStyleDescription ),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.getDifference),style: textStyleValue.copyWith(color: cashRegister.getDifference==0?null:cashRegister.getDifference<0?Colors.red.shade300:Colors.green.shade300))]),
              ],
            ),
          
        ),
      ),
      actions: [
        // textButton : cancelar
        TextButton(
          onPressed: (){ Get.back(); }, 
          child: const Text('Cancelar')
        ),
        // textButton : eliminar
        TextButton(
          onPressed: (){
            Get.dialog(
                AlertDialog(
                  title: const Text('Eliminar informe de caja'),
                  content: const Text('¿Está seguro de eliminarlo?'),
                  actions: [
                    TextButton(onPressed: (){ Get.back(); }, child: const Text('Cancelar')),
                    TextButton(onPressed: (){ 
                      // delete : eliminar caja
                      transactionsController.deleteCashRegister(cashRegister: cashRegister);
                      Get.back(); Get.back(); 
                    }, child: const Text('Si, eliminar')),
                  ],
                )
              );
        }, 
        child: Text('Eliminar',style:TextStyle(color: Colors.red.shade300)),
      ),
      ],
    );
  }

  @override
  void onInit() async {
    super.onInit();  
    loadCashRegisterLast30Days(); // cargar las cajas de los ultimos 30 dias por defecto
  }

  @override
  void onClose() {}

}