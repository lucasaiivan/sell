import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';

import '../../../models/ticket_model.dart';
import '../../../utils/dynamicTheme_lb.dart';
import '../controller/transactions_controller.dart';

class TransactionsView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  TransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionsController>(
      init: TransactionsController(),
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
    // others controllers
    final TransactionsController transactionsController = Get.find();

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Transacciones'),
      actions: [
        PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            onSelected: (selectedValue) {
              transactionsController.filterList(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: 'hoy', child: Text('Hoy')),
                  const PopupMenuItem(value: 'ayer', child: Text('Ayer')),
                  const PopupMenuItem(
                      value: 'este mes', child: Text('Este mes')),
                  const PopupMenuItem(
                      value: 'el mes pasado', child: Text('El mes pasado')),
                  const PopupMenuItem(
                      value: 'este año', child: Text('Este año')),
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {
    // others controllers
    final TransactionsController transactionsController = Get.find();

    // vista para mostrar en el caso que no alla ninguna transacción
    if (transactionsController.getTransactionsList.isEmpty) {
      return Center(
          child: Text(
              'Sin transacciones ${transactionsController.getFilterText.toLowerCase()}'));
    }

    return ListView.builder(
      itemCount: transactionsController.getTransactionsList.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(transactionsController.getFilterText,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(transactionsController.getInfoPriceTotal(),textAlign: TextAlign.start,style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w200)),
                  ],
                ),
              ),
              tileItem(
                  ticketModel:
                      transactionsController.getTransactionsList[index]),
              const Divider(height: 0),
            ],
          );
        }

        return Column(
          children: [
            tileItem(
                ticketModel: transactionsController.getTransactionsList[index]),
            const Divider(height: 0),
          ],
        );
      },
    );
  }

  // WIDGETS COMPONENTS
  Widget tileItem({required TicketModel ticketModel}) {
    // controllers
    final TransactionsController transactionsController = Get.find();

    // values
    String payMode =
        transactionsController.getPayModeFormat(idMode: ticketModel.payMode);

    return ElasticIn(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onLongPress: () =>
            transactionsController.deleteSale(ticketModel: ticketModel),
        title: Text(
            Publications.getFechaPublicacion(
                ticketModel.creation.toDate(), Timestamp.now().toDate()),
            style: const TextStyle(fontWeight: FontWeight.w400)),
        subtitle: Padding(
          padding: const EdgeInsets.only(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Publications.getFechaPublicacionFormating(
                  dateTime: ticketModel.creation.toDate())),
              Row(
                children: [
                  Text('Pago con: $payMode'),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(Icons.circle,
                          size: 8, color: Get.theme.dividerColor)),
                  Text('${ticketModel.getLengh()} items'),
                ],
              ),
              ticketModel.valueReceived == 0
                  ? Container()
                  : Text(
                      'Vuelto: ${Publications.getFormatoPrecio(monto: ticketModel.valueReceived - ticketModel.priceTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.w300)),
            ],
          ),
        ),
        trailing: Text(
            Publications.getFormatoPrecio(monto: ticketModel.priceTotal),
            style: const TextStyle(fontWeight: FontWeight.w300)),
      ),
    );
  }
}
