import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/splash/controllers/splash_controller.dart';

class SplashInit extends GetView<SplashController> {
  const SplashInit({super.key});

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
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
