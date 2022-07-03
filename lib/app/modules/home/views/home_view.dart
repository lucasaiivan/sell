import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/modules/sellPage/views/sell_view.dart';
import 'package:sell/app/modules/cataloguePage/views/catalogue_view.dart';
import 'package:sell/app/modules/transactionsPage/views/transactions_view.dart';
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
        return CataloguePage();
      default:
        return SalesView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => getView(index: controller.getIndexPage));
  }
}

