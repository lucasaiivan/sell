import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/sellPage/views/sell_view.dart';
import 'package:sell/app/presentation/cataloguePage/views/catalogue_view.dart';
import 'package:sell/app/presentation/transactionsPage/views/transactions_view.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../multiuser/views/multiuser_view.dart';
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
      case 3:
        return MultiUser();
      default:
        return SalesView();
    }
  }
  

  @override
  Widget build(BuildContext context) {

    if (controller.getProfileAccountSelected.id == ''){return viewDefault();}
    controller.setBuildContext=context;

    return Obx(() {
      return WillPopScope(
        onWillPop: () => controller.onBackPressed(context: context),
        child: getView(index: controller.getIndexPage),
      );
    });
  }
}
