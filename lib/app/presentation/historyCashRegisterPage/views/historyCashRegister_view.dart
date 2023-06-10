import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:sell/app/core/utils/widgets_utils.dart';  
import '../controller/historyCashRegister_controller.dart'; 

// ignore: must_be_immutable
class HistoryCashRegisterView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  HistoryCashRegisterView({Key? key}) : super(key: key);

  // var 
  bool darkTheme=false; 

  @override
  Widget build(BuildContext context) { 
    // get
    darkTheme = Get.isDarkMode;

    return GetBuilder<HistoryCashRegisterController>(
      init: HistoryCashRegisterController(),
      initState: (_) {},
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
 
    // var
    bool darkTheme = Get.isDarkMode;

    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Historial de caja',textAlign: TextAlign.center),
      actions: [
        
        PopupMenuButton(
            icon: Material(
              color: darkTheme?Colors.white:Colors.black,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(historyCashRegisterController.getTextFilter,style:TextStyle(color: darkTheme?Colors.black:Colors.white,fontWeight: FontWeight.w400)),
                    const SizedBox(width: 5),
                    Icon(Icons.filter_list,color: darkTheme?Colors.black:Colors.white),
                  ],
                ),
              ),
            ),
            onSelected: (selectedValue) {
              historyCashRegisterController.filterCashRegister(filter: selectedValue.toString());
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'Hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'Ayer', child: Text('Ayer')),
                  const PopupMenuItem(value: 'Últimos 30 Días', child: Text('Últimos 30 Días')),
                  const PopupMenuItem(value: 'Este mes', child: Text('Este mes')),
                  const PopupMenuItem(value: 'El mes pasado', child: Text('El mes pasado')),
                  const PopupMenuItem(value: 'Este año', child: Text('Este año')), 
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {

    //  controllers
    final HistoryCashRegisterController transactionsController = Get.find();

    if( transactionsController.load ){ return const Center(child: Text('cargarndo datos...'),);}
    if( !transactionsController.load && transactionsController.getListCashRegister.isEmpty ){ return const Center(child: Text('sin datos'),);}

    // lista de widgets List<Widget> donde se almacenarán los elementos de la lista
    List<Widget> transactions =  transactionsController.getTransactionsWidgetsViews; 
    
    // Finalmente, utiliza la lista de widgets widgets e
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) => transactions[index],
    );

  }
  

  

}