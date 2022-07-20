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
    catalogueCategoryFilter();
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
  void catalogueCategoryFilter() {
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
  void catalogueFilter({required String key}) {
    List<ProductCatalogue> list = [];

    //filter
    if( key==''){
        list = homeController.getCataloProducts;
      }else{
        switch(key){
          case '0': //  Mostrar productos con stock
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.stock)listSFilter.add(item);}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            break;
          case '1': //  Mostrar productos favoritos
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.favorite)listSFilter.add(item);}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            break;
          case '2': // Mostrar productos con stock bajos
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.stock){if(item.quantityStock<=item.alertStock){listSFilter.add(item);}}}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            break;
          case '3': // Mostrar todos
            list = homeController.getCataloProducts;
            break; 
        }
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
        builder: (product) {

          // values
          Color tileColor = product.stock? (product.quantityStock <= product.alertStock? Colors.red.withOpacity(0.5): Colors.transparent): Colors.transparent;
          String alertStockText =product.stock ? (product.quantityStock == 0 ? 'Sin stock' : '${product.quantityStock} en stock') : '';

          return Column(
          children: [
            ListTile(
              contentPadding:const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
              tileColor: tileColor,
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
                  Row(
                    children: [
                      Text(product.code),
                      alertStockText==''?Container():Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.circle,
                                size: 8, color: Get.theme.dividerColor),
                          ),
                      Text(alertStockText),
                    ],
                  ),
                ],
              ),
              trailing:
                  Text(Publications.getFormatoPrecio(monto: product.salePrice),),
              onTap: () {
                Get.back();
                toProductEdit(productCatalogue: product);
              },
            ),
            const Divider(height: 0),
          ],
        );
        },
      ),
    );
  }

  void filterAlertStock() {

    // obtenemos una lista nueva con los productos que tienen un stock
    List<ProductCatalogue> stockActivateList = [];
    for (var element in getCataloProducts) {
      if (element.stock) {
        stockActivateList.add(element);
      }
    }
    stockActivateList
        .sort((a, b) => a.quantityStock.compareTo(b.quantityStock));

    // obtenemos una lista nueva con los productos que no tienen el stock activado
    List<ProductCatalogue> stockDesactivateList = [];
    for (var element in getCataloProducts) {
      if (element.stock == false) {
        stockDesactivateList.add(element);
      }
    }
    stockDesactivateList.sort((a, b) => b.quantityStock.compareTo(a.quantityStock));
    // creamos una nueva lista con todos los productos ya filtrados
    List<ProductCatalogue> newFilterList = [];
    for (var element in stockActivateList) {
      newFilterList.add(element);
    }
    for (var element in stockDesactivateList) {
      newFilterList.add(element);
    }
    // actualizamos la lista para mostrar al usuario
    setCatalogueProducts = newFilterList;
  }

  Widget get viewStockAlert {
    // buscamos los productos que tengan un stock vacio o bajo
    int countProducts = 0;
    for (var product in getCataloProducts) {
      if (product.quantityStock <= product.alertStock && product.stock) {
        countProducts++;
      }
    }
    if (countProducts == 0) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextButton(
            onPressed: filterAlertStock,
            child: Text('Tienes $countProducts productos con stock bajas',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w200))),
      );
    }
  }
}
