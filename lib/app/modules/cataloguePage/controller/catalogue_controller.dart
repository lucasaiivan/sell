import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:search_page/search_page.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/services/database.dart';

import '../../../routes/app_pages.dart';
import '../../../utils/fuctions.dart';

class CataloguePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // others controllers
  final HomeController homeController = Get.find();
  late TabController tabController;

  // text titleBar
  Category _selectedCategory = Category(name: 'Cátalogo');
  String get getTextTitleAppBar => _selectedCategory.name;
  Category get getSelectedCategory => _selectedCategory;
  set setSelectedCategory(Category value) {
    _selectedCategory = value;
    catalogueFilter();
    update();
  }

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
    tabController = TabController(vsync: this, length: 2);
    readProductsCatalogue();
  }

  @override
  void onClose() {}

  // FIREBASE
  void readProductsCatalogue() {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    setCatalogueProducts = homeController.getCataloProducts;
  }

  // FUCTIONS
  void catalogueFilter() {
    List<ProductCatalogue> list = [];

    //filter
    if (getSelectedCategory.id != '') {
      for (var element in homeController.getCataloProducts) {
        if (getSelectedCategory.id == element.category) {
          list.add(element);
        }
      }
    } else {
      list = homeController.getCataloProducts;
    }
    // set
    setCatalogueProducts = list;
  }

  void toProductNew({required String id}) {
    //values default
    ProductCatalogue productCatalogue = ProductCatalogue(
        id: id, code: id, creation: Timestamp.now(), upgrade: Timestamp.now());
    // navega hacia una nueva vista para crear un nuevo producto
    Get.toNamed(Routes.EDITPRODUCT,
        arguments: {'new': true, 'product': productCatalogue});
  }

  void toSeachProduct() {
    Get.toNamed(Routes.SEACH_PRODUCT, arguments: {'id': ''});
  }

  Future<void> categoryDelete({required String idCategory}) async =>
      await Database.refFirestoreCategory(
              idAccount: homeController.getProfileAccountSelected.id)
          .doc(idCategory)
          .delete();
  Future<void> categoryUpdate({required Category categoria}) async {
    // ref
    var documentReferencer = Database.refFirestoreCategory(
            idAccount: homeController.getProfileAccountSelected.id)
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

  

  void seach({required BuildContext context}) {
    // Busca entre los productos de mi catálogo

    // var
    Color colorAccent =
        Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    showSearch(
      context: context,
      delegate: SearchPage<ProductCatalogue>(
        items: homeController.getCataloProducts,
        searchLabel: 'Buscar',
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme
            .copyWith(hintColor: colorAccent, highlightColor: colorAccent),
        suggestion: const Center(child: Text('ej. alfajor')),
        failure: const Center(child: Text('No se encontro en tu cátalogo:(')),
        filter: (product) => [product.description, product.nameMark],
        builder: (product) => Column(
          children: [
            ListTile(
              title: Text(product.nameMark),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                  ),
                  Text(product.code),
                ],
              ),
              trailing:
                  Text(Publications.getFormatoPrecio(monto: product.salePrice)),
              onTap: () {
                Get.back();
                toProductEdit(productCatalogue: product);
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
