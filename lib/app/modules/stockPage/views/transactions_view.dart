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
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required BuildContext context}) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget body({required BuildContext context}) {
    return Container(
      child: const Center(child: Text('stock')),
    );
  }
}
