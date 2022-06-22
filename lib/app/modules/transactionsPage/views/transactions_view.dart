import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';

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
            onSelected: (selectedValue) {
              transactionsController.filterList(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(
                      child: Text('últimos 30 días'), value: '30'),
                  const PopupMenuItem(
                      child: Text('últimos 60 días'), value: '60'),
                  const PopupMenuItem(
                      child: Text('últimos 120 días'), value: '120'),
                ])
      ],
    );
  }

  Widget body({required BuildContext context}) {
    // others controllers
    final TransactionsController transactionsController = Get.find();

    return Expanded(
      child: ListView.builder(
        itemCount: transactionsController.getTransactionsList.length,
        itemBuilder: (context, index) {
          // values
          String payMode = transactionsController.getPayModeFormat(
              idMode:
                  transactionsController.getTransactionsList[index].payMode);

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
                          style:const  TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(transactionsController.getInfoPriceTotal(),
                          textAlign: TextAlign.start),
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  onLongPress: () {},
                  title: Text(Publications.getFechaPublicacion(
                      transactionsController.getTransactionsList[index].creation
                          .toDate(),
                      Timestamp.now().toDate())),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Pago con: $payMode'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.circle,
                                size: 8, color: Get.theme.dividerColor),
                          ),
                          Text(
                              '${transactionsController.getTransactionsList[index].getLengh()} items'),
                        ],
                      ),
                      Text(Publications.getFechaPublicacionFormating(
                          dateTime: transactionsController
                              .getTransactionsList[index].creation
                              .toDate())),
                    ],
                  ),
                  trailing: Text(
                      Publications.getFormatoPrecio(
                          monto: transactionsController
                              .getTransactionsList[index].priceTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 0),
              ],
            );
          }

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                onLongPress: () {},
                title: Text(Publications.getFechaPublicacion(
                    transactionsController.getTransactionsList[index].creation
                        .toDate(),
                    Timestamp.now().toDate())),
                subtitle: Padding(
                  padding: const EdgeInsets.only(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Pago con: $payMode'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.circle,
                                size: 8, color: Get.theme.dividerColor),
                          ),
                          Text(
                              '${transactionsController.getTransactionsList[index].getLengh()} items'),
                        ],
                      ),
                      Text(Publications.getFechaPublicacionFormating(
                          dateTime: transactionsController
                              .getTransactionsList[index].creation
                              .toDate())),
                    ],
                  ),
                ),
                trailing: Text(
                    Publications.getFormatoPrecio(
                        monto: transactionsController
                            .getTransactionsList[index].priceTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 0),
            ],
          );
        },
      ),
    );
  }
}
