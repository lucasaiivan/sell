 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';  
import 'package:sell/app/core/utils/widgets_utils.dart';  
import '../controller/historyCashRegister_controller.dart'; 

// ignore: must_be_immutable
class HistoryCashRegisterView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  HistoryCashRegisterView({Key? key}) : super(key: key);

  // var 
  bool darkTheme=false;
  late BuildContext buildContext;

  @override
  Widget build(BuildContext context) {

    // set 
    buildContext = context;

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
    final HistoryCashRegisterController transactionsController = Get.find();

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
                    Text('Filtrar',style:TextStyle(color: darkTheme?Colors.black:Colors.white,fontWeight: FontWeight.w400)),
                    const SizedBox(width: 5),
                    Icon(Icons.filter_list,color: darkTheme?Colors.black:Colors.white),
                  ],
                ),
              ),
            ),
            onSelected: (selectedValue) {
              // transactionsController.filterList(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'ayer', child: Text('Ayer')),
                  const PopupMenuItem(value: 'este mes', child: Text('Este mes')),
                  const PopupMenuItem(value: 'el mes pasado', child: Text('El mes pasado')),
                  const PopupMenuItem(value: 'este año', child: Text('Este año')),
                  const PopupMenuItem(value: 'el año pasado', child: Text('El año pasado')),
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {

    // others controllers
    final HistoryCashRegisterController transactionsController = Get.find();

    if( transactionsController.load ){ return const Center(child: Text('cargarndo datos...'),);}
    if( !transactionsController.load && transactionsController.getListCashRegister.isEmpty ){ return const Center(child: Text('sin datos'),);}

    return ListView.builder( 
      itemCount: transactionsController.getListCashRegister.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(Publications.getFechaPublicacionFormating(dateTime: transactionsController.getListCashRegister[index].opening)),
          subtitle: Opacity(opacity: 0.7,child: Text( Publications.getFormatoPrecio(monto: transactionsController.getListCashRegister[index].getBalance))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(opacity: 0.5,child: Text(transactionsController.getListCashRegister[index].description.toString())),
              const Icon(Icons.arrow_forward_ios_rounded)
            ],
          ),
        );
      },
      );

  }

}