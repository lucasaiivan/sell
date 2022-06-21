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
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Transacciones'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))
      ],
    );
  }

  Widget body({required BuildContext context}) {
    // others controllers
    final TransactionsController transactionsController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 20),
          child: Text('Hace un mes',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: transactionsController.getTransactionsList.length,
            itemBuilder: (context, index) {
              // values 
              String payMode = transactionsController.getPayModeFormat(idMode: transactionsController.getTransactionsList[index].payMode);
        
              return Column(
                children: [
                  ListTile(
                    onLongPress: () {},
                    title: Text(Publications.getFechaPublicacion(
                        transactionsController.getTransactionsList[index].creation
                            .toDate(),
                        Timestamp.now().toDate())),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Pago con: $payMode'),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Icon(Icons.circle, size: 8,color: Get.theme.dividerColor),
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
                    trailing: Text(Publications.getFormatoPrecio(
                        monto: transactionsController
                            .getTransactionsList[index].priceTotal)),
                  ),
                  const Divider(height: 0),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
