import 'package:get/get.dart';
import '../controller/moderator_controller.dart'; 

class ModeratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ModeratorController>(ModeratorController());
  }
}
