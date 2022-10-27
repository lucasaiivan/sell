import 'package:get/get.dart';
import '../controllers/multiuser_controller.dart';

class MultiUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MultiUserController>(MultiUserController());
  }
}
