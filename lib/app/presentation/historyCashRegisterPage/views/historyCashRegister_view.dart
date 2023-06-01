 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';  
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:sell/app/domain/entities/cashRegister_model.dart';  
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

    /* return ListView.builder( 
      itemCount: transactionsController.getListCashRegister.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(Publications.getFechaPublicacionFormating(dateTime: transactionsController.getListCashRegister[index].opening)),
          subtitle: Opacity(opacity: 0.7,child: Text( Publications.getFormatoPrecio(monto: transactionsController.getListCashRegister[index].getBalance))),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(opacity: 0.5,child: Text(transactionsController.getListCashRegister[index].description.toString())),
              const Opacity(opacity: 0.5,child: const Icon(Icons.arrow_forward_ios_rounded))
            ],
          ),
        );
      },
      ); */

    // define una variable currentDate para realizar el seguimiento de la fecha actual en la que se está construyendo la lista. Inicializa esta variable con la fecha de la primera transacción en la lista
    DateTime currentDate = transactionsController.getListCashRegister[0].opening;
    // lista de widgets List<Widget> donde se almacenarán los elementos de la lista
    List<Widget> transactions = []; 
    // add : Itera sobre la lista de transacciones y verifica si la fecha de la transacción actual es diferente a la fecha actual. Si es así, crea un elemento Divider y actualiza la fecha actual
    for (int i = 0; i < transactionsController.getListCashRegister.length; i++) {
      // condition : si es la primera transacción
      if(i==0){
        // add : añade tarjetas de estadísticas
        //transactions.add(StaticsCards());  
      }
      // condition : si la fecha actual es diferente a la fecha de la transacción actual
      if (currentDate.day != transactionsController.getListCashRegister[i].opening.day || i==0) {
        //  set : actualiza la fecha actual de la variable
        currentDate = transactionsController.getListCashRegister[i].opening;
        // add : añade un Container con el texto de la fecha como divisor
        transactions.add(Container(padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),width: double.infinity,color: Colors.grey.withOpacity(.05),child: Opacity(opacity: 0.8,child: Text(Publications.getFechaPublicacionSimple(  transactionsController.getListCashRegister[i].opening,Timestamp.now().toDate()),textAlign: TextAlign.center,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w300)))));
      }
      //  add : añade el elemento de la lista actual a la lista de widgets
      transactions.add(itemTile(cashRegister: transactionsController.getListCashRegister[i]));
      // agregar un divider
      transactions.add( ComponentApp().divider());
    }
    // Finalmente, utiliza la lista de widgets widgets e
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (BuildContext context, int index) => transactions[index],
    );

  }
  Widget viewDetails({required CashRegister cashRegister}){

    // var 
    TextStyle textStyleDescription = const TextStyle( fontWeight: FontWeight.w300);
    TextStyle textStyleValue = const TextStyle(fontSize: 18,fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(title: const Text('Informe de caja')),
      body: ListView( 
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        children: [
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
          // view info : facturacion
          const SizedBox(height: 12),
          Row(children: [Text('Facturación',style: textStyleDescription),const Spacer(),Text( Publications.getFormatoPrecio(monto:cashRegister.billing),style: textStyleValue)]),
          // view info : egresos
          const SizedBox(height: 12),
          Row(children: [Text('Egresos',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.cashOutFlow),style: textStyleValue.copyWith(color: Colors.red.shade300))]),
          // view info : ingresos
          const SizedBox(height: 12),
          Row(children: [Text('Ingresos',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.cashInFlow),style: textStyleValue)]),
          // view info : monto esperado en la caja
          const SizedBox(height: 12),
          const Divider(),
          Row(children: [Text('Monto esperado',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.getExpectedBalance),style: textStyleValue)]),
          const SizedBox(height: 12),
          cashRegister.balance==0?Container():Row(children: [Text('Monto de cierre',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.balance),style: textStyleValue)]),
          cashRegister.balance==0?Container():const SizedBox(height: 12),
          cashRegister.balance==0?Container():Row(children: [Text('Diferencia',style: textStyleDescription),const Spacer(),Text(Publications.getFormatoPrecio(monto: cashRegister.getDifference),style: textStyleValue.copyWith(color: cashRegister.getDifference<0?Colors.red.shade300:null))]),
        ],
      ),
    );
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
          const Opacity(opacity: 0.5,child: Icon(Icons.arrow_forward_ios_rounded))
        ],
      ),
      onTap: () => Get.dialog(viewDetails(cashRegister: cashRegister)),
    );
  }

}