import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/modules/splash/controllers/splash_controller.dart';

class SplashInit extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) => LoadingInitView();
}

class LoadingInitView extends StatelessWidget {
  const LoadingInitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildContext) {

    //  var 
    Color color = Get.theme.brightness == Brightness.dark?Get.theme.scaffoldBackgroundColor:Colors.white;

    return Scaffold(
      backgroundColor: color,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
