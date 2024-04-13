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



class CashRegisterDetailView extends StatelessWidget {
  final CashRegister cashRegister;
  CashRegisterDetailView({Key? key, required this.cashRegister}) : super(key: key);

  // others controllers
  final HistoryCashRegisterController transactionsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de arqueo'),
      ),
      body: body,
      floatingActionButton: floatingActionButtons,
    );
  }
  // WIDGETS VIEWS
  Widget get body{

    // var
    Color separatorColor = Colors.blueGrey.withOpacity(.06);
    TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300);
    TextStyle textStyleValue = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    // var : tiempo de apertura de caja
    int hour = cashRegister.closure.difference(cashRegister.opening).inHours;
    int minutes = cashRegister.closure.difference(cashRegister.opening).inMinutes.remainder(60);
    String time = hour==0?' $minutes minutos':'$hour horas y $minutes minutos';

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [   
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
        // view info : facturacion
        const SizedBox(height: 12),
        Row(children: [
          Text('Facturación', style: textStyleDescription),
          const Spacer(),
          Text(Publications.getFormatoPrecio(monto: cashRegister.billing),
              style: textStyleValue)
        ]),
        cashRegister.cashOutFlowList.isEmpty && cashRegister.cashInFlowList.isEmpty? Container()
        :Column(
          children: [
            const Divider(),
            // view : egresos e ingresos
            egressAndEntryExpansionPanelListView,  
          ],
        ),
        const Divider(),
        Row(children: [
          const Spacer(),
          Text('Monto esperado:   ', style: textStyleDescription), 
          Text(
              Publications.getFormatoPrecio(
                  monto: cashRegister.getExpectedBalance),
              style: textStyleValue)
        ]),
        const SizedBox(height: 12),
        cashRegister.balance == 0
            ? Container()
            : Row(children: [
                const Spacer(),
                Text('Monto de cierre:  ', style: textStyleDescription),
                Text( Publications.getFormatoPrecio(monto: cashRegister.balance),style: textStyleValue)
              ]),
        cashRegister.balance == 0
            ? Container()
            : const SizedBox(height: 12),
        cashRegister.balance == 0
            ? Container()
            : Row(children: [
                const Spacer(),
                Text('Diferencia:  ', style: textStyleDescription),
                Text(
                    Publications.getFormatoPrecio(
                        monto: cashRegister.getDifference),
                    style: textStyleValue.copyWith(
                        color: cashRegister.getDifference == 0
                            ? null
                            : cashRegister.getDifference < 0
                                ? Colors.red.shade300
                                : Colors.green.shade300))
              ]),
        const SizedBox(height:100),
      ],
    );
  }
  // WIDGETS COMPONENTS
  Widget get floatingActionButtons{
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // button : eliminar
        FloatingActionButton(
          heroTag: 'delete',
          onPressed: () {
            registerDeleteConfirmDialog();
          },
          backgroundColor: Colors.red.shade400,
          child: const Icon(Icons.delete,color: Colors.white,),
        ),
        const SizedBox(width: 10),
        // button : cerrar
        FloatingActionButton(
          heroTag: 'close',
          onPressed: () {
            Get.back();
          },
          backgroundColor: Colors.grey,
          child: const Icon(Icons.close,color: Colors.white,),
        ),
        
        
      ],
    );
  }
  Widget get egressAndEntryExpansionPanelListView{

    // style 
    TextStyle textStyleValue = const TextStyle(fontSize: 14);
    TextStyle textStyleDescription = const TextStyle(fontWeight: FontWeight.w300);

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
                Text(Publications.getFormatoPrecio(monto: cashRegister.cashInFlow),style: textStyleValue.copyWith(color: cashRegister.cashInFlow == 0? null: Colors.green.shade300)),
              ],
            );
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: cashRegister.cashInFlowList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: ListTile( 
                  tileColor: Colors.blueGrey.withOpacity(0.08),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12), 
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(cashRegister.cashInFlowList[index]['description'],style: textStyleValue,overflow: TextOverflow.ellipsis,maxLines:3),
                  trailing: Text(Publications.getFormatoPrecio(monto: cashRegister.cashInFlowList[index]['amount']),style: textStyleValue.copyWith(color: Colors.green.shade300)),
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
                Text(Publications.getFormatoPrecio(monto: cashRegister.cashOutFlow),style: textStyleValue.copyWith(color:  cashRegister.cashOutFlow == 0? null: Colors.red.shade300)),
              ]);
          },
          body: ListView.builder(
            shrinkWrap: true,
            itemCount: cashRegister.cashOutFlowList.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: ListTile(
                  tileColor: Colors.blueGrey.withOpacity(0.08),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12), 
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(cashRegister.cashOutFlowList[index]['description'],style: textStyleValue),
                  trailing: Text(Publications.getFormatoPrecio(monto: cashRegister.cashOutFlowList[index]['amount']),style: textStyleValue.copyWith(color: Colors.red.shade300)),
                ),
              );
            },
          ), 
        ),
      ],
    );
  }

  // dialog 
  void registerDeleteConfirmDialog(){
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
              transactionsController.deleteCashRegister( cashRegister: cashRegister);
              Get.back();
              Get.back();
            },
            child: const Text('Si, eliminar')),
      ],
    ));
  }
}
