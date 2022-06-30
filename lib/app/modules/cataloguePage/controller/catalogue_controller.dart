import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/services/database.dart';

import '../../../routes/app_pages.dart';

class CataloguePageController extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();

  // catalogue
  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //...filter 
  }

  @override
  void onInit() async {
    super.onInit();
    readProductsCatalogue();
  }

  @override
  void onClose() {}

  // FIREBASE
  void readProductsCatalogue() {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    Database.readProductsCatalogueStream(
            id: homeController.getProfileAccountSelected.id)
        .listen((value) {
      List<ProductCatalogue> list = [];
      //  get
      for (var element in value.docs) {
        list.add(ProductCatalogue.fromMap(element.data()));
      }
      //  set values
      setCatalogueProducts = list;
      homeController.setCatalogueProducts = list;
    }).onError((error) {
      // error
    });
  }

  // FUCTIONS
  Future<void> categoryDelete({required String idCategory}) async =>
      await Database.refFirestoreCategory(
              idAccount: homeController.getProfileAccountSelected.id)
          .doc(idCategory)
          .delete();
  Future<void> categoryUpdate({required Category categoria}) async {
    // ref
    var documentReferencer =
        Database.refFirestoreCategory(idAccount: homeController.getProfileAccountSelected.id)
            .doc(categoria.id);
    // Actualizamos los datos
    documentReferencer
        .set(Map<String, dynamic>.from(categoria.toJson()),
            SetOptions(merge: true))
        .whenComplete(() {
      print("######################## FIREBASE updateAccount whenComplete");
    }).catchError((e) => print(
            "######################## FIREBASE updateAccount catchError: $e"));
  }


  // navigator
  void toProductEdit({required ProductCatalogue productCatalogue}) {
    Get.toNamed(Routes.EDITPRODUCT, arguments: {'product': productCatalogue});
  }
}
