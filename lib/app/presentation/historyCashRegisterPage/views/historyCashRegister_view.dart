import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../controller/historyCashRegister_controller.dart';

// ignore: must_be_immutable
class HistoryCashRegisterView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  HistoryCashRegisterView({Key? key}) : super(key: key);

  // var
  bool darkTheme = false;

  @override
  Widget build(BuildContext context) {
    // get
    darkTheme = Get.isDarkMode;

    return GetBuilder<HistoryCashRegisterController>(
      init: HistoryCashRegisterController(),
      initState: (_) {
        // init : inicializamos el controlador
        Get.put(HistoryCashRegisterController());
      },
      builder: (_) {
        return Scaffold(
          appBar: appbar(context: context),
          drawer: drawerApp(),
          body: body(context: context),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required BuildContext context}) {
    // controllers
    HistoryCashRegisterController historyCashRegisterController = Get.find();
 
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Historial de caja', textAlign: TextAlign.center),
      actions: [
        PopupMenuButton( 
            icon: ComponentApp().buttonAppbar(
              context: context,
              text: historyCashRegisterController.getTextFilter,
              iconTrailing: Icons.filter_list,  
            ),
            onSelected: (selectedValue) {
              historyCashRegisterController.filterCashRegister( filter: selectedValue.toString());
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'Hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'Ayer', child: Text('Ayer')),
                  const PopupMenuItem(value: 'Últimos 7 Días', child: Text('Últimos 7 Días')),
                  // opciones premium //
                  historyCashRegisterController.homeController.getIsSubscribedPremium?const PopupMenuItem(child: null,height: 0):const PopupMenuItem(value: 'premium', child: Text('Opciones Premium',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.amber))),
                  PopupMenuItem(value: 'Últimos 30 Días',enabled: historyCashRegisterController.homeController.getIsSubscribedPremium, child: const Text('Últimos 30 Días')),
                  PopupMenuItem(value: 'Este mes', enabled: historyCashRegisterController.homeController.getIsSubscribedPremium,child: const Text('Este mes')),
                  PopupMenuItem(value: 'El mes pasado',enabled: historyCashRegisterController.homeController.getIsSubscribedPremium, child: const Text('El mes pasado')),
                  PopupMenuItem(value: 'Este año',enabled: historyCashRegisterController.homeController.getIsSubscribedPremium, child: const Text('Este año')),
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {
    //  controllers
    final HistoryCashRegisterController transactionsController = Get.find();

    if (transactionsController.load) {
      return const Center(
        child: Text('cargarndo datos...'),
      );
    }
    if (!transactionsController.load &&
        transactionsController.getListCashRegister.isEmpty) {
      return const Center(
        child: Text('sin datos'),
      );
    }

    // lista de widgets List<Widget> donde se almacenarán los elementos de la lista
    List<Widget> transactions = transactionsController.getTransactionsWidgetsViews;

    // Finalmente, utiliza la lista de widgets widgets
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) => transactions[index],
    );
  }
}
