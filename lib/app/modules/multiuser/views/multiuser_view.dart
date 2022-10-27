import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/modules/splash/controllers/splash_controller.dart';

import '../../../utils/widgets_utils.dart';

class MultiUser extends GetView<SplashController> {
  // ignore: prefer_const_constructors_in_immutables
  MultiUser({super.key});

  @override
  // ignore: prefer_const_constructors
  Widget build(BuildContext context) => LoadingInitView();
}

class LoadingInitView extends StatelessWidget {
  const LoadingInitView({Key? key}) : super(key: key);

  @override
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext buildContext) {

    //  var 
    Color color = Get.theme.brightness == Brightness.dark?Get.theme.scaffoldBackgroundColor:Colors.white;

    return Scaffold(
      backgroundColor: color,
      appBar: appbar,
      drawer: drawerApp(),
      body: body,
    );
  }

  // WIDGETS MAIN
  PreferredSizeWidget get appbar{
    return AppBar(
      title: const Text('Multiusuario'),
      actions: [
        IconButton(onPressed: (){}, icon: const Icon(Icons.add))
      ],
    );
  }
  Widget get body{

    return const  Center(child: Text('Sin usuarios'));
  }

  // WIDGETS COMPONENTS
}
