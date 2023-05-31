
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart'; 
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/cashRegister_model.dart';
import '../../home/controller/home_controller.dart';

class HistoryCashRegisterController extends GetxController {

  // others controllers
  final HomeController homeController = Get.find(); 

  // state load
  bool load = true;

  // lista de arqueos de caja
  RxList<CashRegister> listCashRegister = <CashRegister>[].obs;
  List<CashRegister> get getListCashRegister => listCashRegister;
  set setListCashRegister(value) => listCashRegister.value = value;

  // load : cargamos los arqueos de caja
  void loadCashRegister() async {
    // firebase : obtenemos los documentos de arqueos de caja
    Future<QuerySnapshot<Object?>> query=Database.refFirestoreRecords(idAccount:homeController.getProfileAccountSelected.id).orderBy('opening',descending: true).get();
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

  @override
  void onInit() async {
    super.onInit(); 

    loadCashRegister();
  }

  @override
  void onClose() {}

}