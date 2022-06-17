import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/modules/salesPage/views/sales_view.dart';
import 'package:sell/app/modules/stockPage/views/transactions_view.dart';
import 'package:sell/app/modules/transactionsPage/views/transactions_view.dart';

import '../../settingPage/views/transactions_view.dart';
import '../controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  // ignore: prefer_const_constructors_in_immutables
  HomeView({Key? key}) : super(key: key);

  // var
  Widget getView({required index}) {
    switch (index) {
      case 0:
        return SalesView();
      case 1:
        return TransactionsView();
      case 2:
        return StockPage();
      case 3:
        return SettingPage();
      default:
        return SalesView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => getView(index: controller.getIndexPage));
  }
}

