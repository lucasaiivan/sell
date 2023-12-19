
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:sell/app/presentation/historyCashRegisterPage/views/historyCashRegister_view.dart';
import 'package:sell/app/presentation/sellPage/views/sell_view.dart';
import 'package:sell/app/presentation/cataloguePage/views/catalogue_view.dart';
import 'package:sell/app/presentation/transactionsPage/views/transactions_view.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../multiuser/views/multiuser_view.dart';  
import '../controller/home_controller.dart';


class HomeView extends GetView<HomeController> {
  // ignore: prefer_const_constructors_in_immutables
  HomeView({Key? key}) : super(key: key);

  // var 
  InternetConnectivity internetConnectivity = InternetConnectivity();
  Widget getView({required index}) {
    // nos permite crear una vista elegida por el usuario del menú de navegación lateral
    switch (index) {
      case 0:
        return SalesView();
      case 1:
        return HistoryCashRegisterView();
      case 2:
        return TransactionsView();
      case 3:
        return CataloguePage();
      case 4:
        return MultiUser();
      default:
        return SalesView();
    }
  }
  

  @override
  Widget build(BuildContext context) { 
    
    // get : nos permite obtener el valor de una variable
    controller.setHomeBuildContext=context;
    controller.setDarkMode = Theme.of(context).brightness==Brightness.dark;

    // Obx : nos permite observar los cambios en el estado de la variable
    return Obx(() {

      //  condition : si el usuario no ha seleccionado una cuenta
      if (controller.getProfileAccountSelected.id == '' && controller.getFirebaseAuth.currentUser!.isAnonymous == false ){
        // viewDefault : se muestra la vista por defecto para iniciar sesión de una cuenta existente o crear una nueva cuenta
        return viewDefault();
      }

      // PopScope : nos permite controlar el botón de retroceso del dispositivo
      return PopScope( 
        canPop: false, // deshabilitar el botón de retroceso del dispositivo
        onPopInvoked: (_) => controller.onBackPressed(context: context), 
        child: InternetConnectivityBuilder(
          connectivityBuilder: (BuildContext context, bool hasInternetAccess, Widget? child) { 
            if(hasInternetAccess) {
              // con conexión a internet
              controller.setInternetConnection = hasInternetAccess;
              return getView(index: controller.getIndexPage);
            } else {
              // sin conexión a internet
              controller.setInternetConnection = hasInternetAccess;
              return Scaffold(
                appBar: AppBar(
                  // quitar margen
                  toolbarHeight: 20,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off,color: Colors.red.shade300,size: 20),
                      const SizedBox(width: 10),
                      Text('Sin conexión a internet',style: TextStyle(fontSize: 16,color: Colors.red.shade300)),
                    ],
                  ),
                  centerTitle: true, 
                  automaticallyImplyLeading: false,
                ),
                body: getView(index: controller.getIndexPage),
              );
            }
          },
        child: getView(index: controller.getIndexPage),
      ),
      );
    });
  }
}
