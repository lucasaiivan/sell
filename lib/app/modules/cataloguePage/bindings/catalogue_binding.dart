
import 'package:get/get.dart';

import '../controller/catalogue_controller.dart';
import '../controller/product_edit_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CataloguePageController>(CataloguePageController());
  }
}


class ProductsEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ControllerProductsEdit>(ControllerProductsEdit());
  }
}