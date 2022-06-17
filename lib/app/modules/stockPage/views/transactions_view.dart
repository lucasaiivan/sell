import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/modules/stockPage/controller/transactions_controller.dart';
import 'package:sell/app/utils/widgets_utils.dart';

class StockPage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  StockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StockPageController>(
      init: StockPageController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: appbar(context: context),
          drawer: drawerApp(),
          body: body(context: context),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {}, //controller.add,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              )),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required BuildContext context}) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Stock'),
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))],
    );
  }

  Widget body({required BuildContext context}) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Container(color: Colors.grey, width: 2, height: 14),
          subtitle: Container(color: Colors.grey, width: 2, height: 14),
          leading: const CircleAvatar(backgroundColor: Colors.grey),
          trailing: Container(color: Colors.grey, width: 14, height: 14),
        );
      },
    );
  }
}
