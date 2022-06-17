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

    return ListView.builder(
      itemCount: transactionsController.getTransactionsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: Colors.red,
          title: Text(Publications.getFechaPublicacion(transactionsController.getTransactionsList[index].time.toDate(), Timestamp.now().toDate())),
          subtitle: Text(transactionsController.getTransactionsList[index].payMode),
          leading: const CircleAvatar(backgroundColor: Colors.grey),
          trailing: Text(Publications.getFormatoPrecio(monto: transactionsController.getTransactionsList[index].priceTotal)),
        );
      },
    );
  }
}
