import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../../../core/utils/fuctions.dart';
import '../../../domain/entities/cashRegister_model.dart';
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



// ignore: must_be_immutable
class CashRegisterDetailView extends StatelessWidget {

  final CashRegister cashRegister;
  CashRegisterDetailView({Key? key, required this.cashRegister}) : super(key: key);

  // style 
  TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300 ,color: Colors.black);
  TextStyle textStyleValue = const TextStyle(fontWeight: FontWeight.w600,fontFamily: 'Monospace',letterSpacing: -0.9,color: Colors.black);
 
  @override
  Widget build(BuildContext context) {
    return body;
  }
  // WIDGETS VIEWS
  Widget get body{

    // var
    Color separatorColor = Colors.blueGrey.withOpacity(.06);
   
    // var : tiempo de apertura de caja
    int hour = cashRegister.closure.difference(cashRegister.opening).inHours;
    int minutes = cashRegister.closure.difference(cashRegister.opening).inMinutes.remainder(60);
    String time = hour==0?' $minutes minutos':'$hour horas y $minutes minutos'; 

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [   
              const SizedBox(height: 12),
              // text : 'Detalle de arqueo'
              Text('Detalle de arqueo',style: textStyleDescription.copyWith(fontSize: 18,fontWeight: FontWeight.w600)),
              const Divider(),
              // view info : descripcion
              Row(children: [
                Text('Descripción', style: textStyleDescription),
                const Spacer(),
                Text(cashRegister.description, style: textStyleValue)
              ]),
              // view info : fecha de inicio
              const SizedBox(height: 12),
              Container(
                color: separatorColor,
                child: Row(children: [
                  Text('Inicio', style: textStyleDescription),
                  const Spacer(),
                  Text(
                      Publications.getFechaPublicacionFormating(
                          dateTime: cashRegister.opening),
                      style: textStyleValue)
                ]),
              ),
              // view info : fecha de cierre
              const SizedBox(height: 12),
              Row(children: [
                Text('Cierre', style: textStyleDescription),
                const Spacer(),
                Text( Publications.getFechaPublicacionFormating(dateTime: cashRegister.closure),style: textStyleValue),
              ]),
              // view info : tiempo de apertura
              const SizedBox(height: 12),
              Container(
                color: separatorColor,
                child: Row(children: [
                  Text('Tiempo', style: textStyleDescription),
                  const Spacer(),
                  Text(time, style: textStyleValue)
                ]),
              ),
              // view info : efectivo incial
              const SizedBox(height: 12),
              Row(children: [
                Text('Efectivo inicial', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFormatoPrecio(
                        monto: cashRegister.expectedBalance),
                    style: textStyleValue)
              ]),
              //  view info : cantidad de venta
              const SizedBox(height: 12),
              Container(
                color: separatorColor,
                child: Row(children: [
                  Text('Cantidad de ventas', style: textStyleDescription),
                  const Spacer(),
                  Text(cashRegister.sales.toString(), style: textStyleValue)
                ]),
              ),
              
              cashRegister.cashOutFlowList.isEmpty ? Container():const SizedBox(height: 12),
              // view info : egresos
              cashRegister.cashOutFlowList.isEmpty ? Container()
              :egressAndEntryView(description: 'Egresos',value: Publications.getFormatoPrecio(monto: cashRegister.cashOutFlow),colorValue: Colors.red.shade300,items: cashRegister.cashOutFlowList),
              cashRegister.cashInFlowList.isEmpty ? Container():const SizedBox(height: 12),
              // view info : ingresos
              cashRegister.cashInFlowList.isEmpty ? Container()
              :egressAndEntryView(description: 'Ingresos',value: Publications.getFormatoPrecio(monto: cashRegister.cashInFlow),colorValue: Colors.green.shade300,items: cashRegister.cashInFlowList),
              const SizedBox(height: 12), 
              Container(
                // borde 
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black ),
                  borderRadius: BorderRadius.circular(1),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(children: [
                      const Spacer(),
                      Text('Facturación:   ', style: textStyleDescription), 
                      Text(Publications.getFormatoPrecio(monto: cashRegister.billing),style: textStyleValue)]),
                    const SizedBox(height: 12),
                    // view info : monto esperado 
                    Row(children: [
                      const Spacer(),
                      Text('Monto esperado:   ', style: textStyleDescription),
                      Text(Publications.getFormatoPrecio(monto: cashRegister.expectedBalance),
                          style: textStyleValue)
                    ]),
                    const SizedBox(height: 12),
                    // text : monto de cierre
                    cashRegister.balance == 0?Container():Row(children: [const Spacer(),Text('Monto de cierre:  ', style: textStyleDescription),Text( Publications.getFormatoPrecio(monto: cashRegister.balance),style: textStyleValue)]),
                    cashRegister.balance == 0? Container(): const SizedBox(height: 12),
                    cashRegister.balance == 0
                        ? Container()
                        : Row(children: [
                            const Spacer(),
                            Text('Diferencia:  ', style: textStyleDescription),
                            Text(Publications.getFormatoPrecio(monto: cashRegister.getDifference),style: textStyleValue.copyWith(color: cashRegister.getDifference == 0? null: cashRegister.getDifference < 0? Colors.red.shade300: Colors.green.shade300)) ]),
                  ],
                ),
              ),
              const SizedBox(height:50),
            ],
          ),
        ),
      ),
    );
  }
  // WIDGETS COMPONENTS
  Widget egressAndEntryView({required String description,required String value,Color ?colorValue ,required List<dynamic> items}){
    // description : visualiza los egresos o ingresos de la caja con su respectiva descripción, monto y lista de items
    if(items.isEmpty){return Container();}
    return Column(
      children: [
        Row(
          children: [ 
            // text : description
            Text(description,style: textStyleDescription),
            const Spacer(),
            // text : cantidad de items
            Text('(${items.length}) ',style: textStyleValue),
            // text : value
            Text(value,style: textStyleValue.copyWith(color: colorValue)),
          ],
        ),  
        const Divider(), 
        // list : items
        Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            return Opacity(
              opacity: 0.8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical:2,horizontal:12),
                child: Row(
                  children: [
                    Text(item['description'],style: textStyleValue),
                    const Spacer(),
                    Text(Publications.getFormatoPrecio(monto: item['amount']),style: textStyleValue),
                  ],
                ),
              ),
            );
          }).toList(),
        )
        
      ],
    );

  }
  Widget get egressAndEntryExpansionPanelListView{ 

    return ExpansionPanelList.radio(
      elevation:0,  
      dividerColor: Colors.transparent,
      materialGapSize:0,// separacion entre los elementos 
      expandedHeaderPadding: EdgeInsets.zero,
      children: [
        // ExpansionPanelRadio : ingresos 
        ExpansionPanelRadio(
          canTapOnHeader: true,
          value: 1, 
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Row(
              children: [
                Text('Ingresos',style: textStyleDescription,),
                const Spacer(),
                Text(Publications.getFormatoPrecio(monto: cashRegister.cashInFlow),style: textStyleValue.copyWith(color:cashRegister.cashInFlow == 0? null: Colors.green.shade300)),
              ],
            );
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: cashRegister.cashInFlowList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical:1,horizontal:12),
                child: Row(
                  children: [
                    // text : description
                    Text(cashRegister.cashInFlowList[index]['description'],style: textStyleValue),
                    const Spacer(),
                    // text : value
                    Text(Publications.getFormatoPrecio(monto:cashRegister.cashInFlowList[index]['amount']),style: textStyleValue),
                  ],
                ),
              );
            },
          ), 
        ),
        // ExpansionPanelRadio : egresos 
        ExpansionPanelRadio(
          value: 2,
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Row(
              children: [
                Text('Egresos',style: textStyleDescription,),
                const Spacer(),
                Text(Publications.getFormatoPrecio(monto:cashRegister.cashOutFlow),style: textStyleValue.copyWith(color: cashRegister.cashOutFlow == 0? null: Colors.red.shade300)),
              ]);
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount:cashRegister.cashOutFlowList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    // text : description
                    Text(cashRegister.cashOutFlowList[index]['description'],style: textStyleValue),
                    const Spacer(),
                    // text : value
                    Text(Publications.getFormatoPrecio(monto:cashRegister.cashOutFlowList[index]['amount']),style: textStyleValue),
                  ],
                ),
              );
            },
          ), 
        ),
      ],
    );
  }
  

  
}
