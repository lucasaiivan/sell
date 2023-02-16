
import 'package:get/get.dart';

import '../controller/catalogue_controller.dart';
import '../controller/product_edit_controller.dart';
import '../controller/productsSearch_controller.dart';

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

class ProductsSarchBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ControllerProductsSearch>(ControllerProductsSearch());
  }
}

class ProductsFormCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ControllerProductsEdit>(ControllerProductsEdit());
  }
}