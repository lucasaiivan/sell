import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';

import '../controller/transactions_controller.dart';

class SettingPage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingPageController>(
      init: SettingPageController(),
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
      title: const Text('Configuración'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  Widget body({required BuildContext context}) {
    return Container();
  }
}
