
import 'package:get/get.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
  }
}
