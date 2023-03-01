import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/sellPage/views/sell_view.dart';
import 'package:sell/app/presentation/cataloguePage/views/catalogue_view.dart';
import 'package:sell/app/presentation/transactionsPage/views/transactions_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../multiuser/views/multiuser_view.dart';
import '../controller/home_controller.dart';


class HomeView extends GetView<HomeController> {
  // ignore: prefer_const_constructors_in_immutables
  HomeView({Key? key}) : super(key: key);

  // var 
  Widget getView({required index}) {
    switch (index) {
      case 0:
        return SalesView();
      case 1:
        return TransactionsView();
      case 2:
        return CataloguePage();
      case 3:
        return MultiUser();
      default:
        return SalesView();
    }
  }
  

  @override
  Widget build(BuildContext context) {

    

    // set
    if (controller.getProfileAccountSelected.id == ''){return viewDefault();}
    controller.setBuildContext=context;
    controller.setDarkMode = Theme.of(context).brightness==Brightness.dark;

    // Obx : nos permite observar los cambios en el estado de la variable
    return Obx(() {
      // WillPopScope : nos permite controlar el botón de retroceso del dispositivo
      return WillPopScope(
        onWillPop: () => controller.onBackPressed(context: context), 
        // getView : nos permite crear una vista con un diseño predefinido
        child: getView(index: controller.getIndexPage),
      );
    });
  }
}
