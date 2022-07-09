import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/models/user_model.dart';
import 'package:sell/app/services/database.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/widgets_utils.dart';
import 'package:in_app_review/in_app_review.dart';

enum Availability { loading, available, unavailable }

class HomeController extends GetxController {

  late Availability _availability = Availability.loading;
  InAppReview _inAppReview = InAppReview.instance;

  // category list
  RxList<Category> _categoryList = <Category>[].obs;
  List<Category> get getCatalogueCategoryList => _categoryList;
  set setCatalogueCategoryList(List<Category> value) {
    _categoryList.value = value;
    update(['tab']);
  }

  // subcategory list selected
  final RxList<Category> _subCategoryList = <Category>[].obs;
  List<Category> get getsubCatalogueCategoryList => _subCategoryList;
  set setCataloguesubCategoryList(List<Category> value) {
    _subCategoryList.value = value;
  }

  // list products for catalogue

  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //...filter
  }

  // list products selecteds
  final RxList<ProductCatalogue> _listProductSelecteds =
      <ProductCatalogue>[].obs;
  get getProductsSelectedsList => _listProductSelecteds;
  saveListProductSelecteds({required List<ProductCatalogue> list}) {
    _listProductSelecteds.value = list;
  }

  addToListProductSelecteds({required ProductCatalogue item}) {
    _listProductSelecteds.add(item);
  }

  //  authentication account profile
  late User _userAccountAuth;
  User get getUserAccountAuth => _userAccountAuth;
  set setUserAccountAuth(User user) => _userAccountAuth = user;

  // profile user
  ProfileAccountModel _accountProfileSelected =
      ProfileAccountModel(creation: Timestamp.now());
  ProfileAccountModel get getProfileAccountSelected => _accountProfileSelected;
  set setProfileAccountSelected(ProfileAccountModel value) =>
      _accountProfileSelected = value;
  String get getIdAccountSelected => _accountProfileSelected.id;
  bool isSelected({required String id}) {
    bool isSelected = false;
    for (ProfileAccountModel obj in getManagedAccountData) {
      if (obj.id == getIdAccountSelected) {
        if (id == getIdAccountSelected) {
          isSelected = true;
        }
      }
    }

    return isSelected;
  }

  // administrator account list
  RxList<ProfileAccountModel> _managedAccountDataList =
      <ProfileAccountModel>[].obs;
  List<ProfileAccountModel> get getManagedAccountData =>
      _managedAccountDataList;
  set setManagedAccountData(List<ProfileAccountModel> value) =>
      _managedAccountDataList.value = value;
  void addManagedAccount({required ProfileAccountModel profileData}) {
    // default values
    _managedAccountDataList = <ProfileAccountModel>[].obs;
    // agregamos la nueva cuenta
    return _managedAccountDataList.add(profileData);
  }

// index
  final RxInt _indexPage = 0.obs;
  int get getIndexPage => _indexPage.value;
  set setIndexPage(int value) => _indexPage.value = value;

  @override
  void onInit() async {
    super.onInit();

     WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();

        _availability = isAvailable && !Platform.isAndroid? Availability.available: Availability.unavailable;
      } catch (e) {
         _availability = Availability.unavailable;
      }
    });

    // obtenemos por parametro los datos de la cuenta de atentificación
    Map map = Get.arguments as Map;
    // verificamos y obtenemos los datos pasados por parametro
    setUserAccountAuth = map['currentUser'];
    map.containsKey('idAccount')
        ? readAccountsData(idAccount: getUserAccountAuth.uid)
        : readAccountsData(idAccount: '');
  }

  @override
  void onClose() {}

  // FUNCTIONS
  bool isCatalogue({required String id}) {
    bool iscatalogue = false;
    List list = getCataloProducts;
    for (var element in list) {
      if (element.id == id) {
        iscatalogue = true;
      }
    }
    return iscatalogue;
  }

  ProductCatalogue getProductCatalogue({required String id}) {
    ProductCatalogue product =
        ProductCatalogue(creation: Timestamp.now(), upgrade: Timestamp.now());
    for (var element in getCataloProducts) {
      if (element.id == id) {
        product = element;
      }
    }
    return product;
  }

  // QUERIES FIRESTORE

  void readAccountsData({required String idAccount}) {
    //default values
    setProfileAccountSelected = ProfileAccountModel(creation: Timestamp.now());

    // obtenemos los datos de la cuenta
    if (idAccount != '') {
      Database.readProfileAccountModelFuture(idAccount).then((value) {
        //get
        if (value.exists) {
          setProfileAccountSelected =
              ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          //  agregamos los datos del perfil de la cuenta en la lista para mostrar al usuario
          /* if (profileAccount.id != '') {
            //addManagedAccount(profileData: profileAccount);
          } */
          // load
          readProductsCatalogue(idAccount: idAccount);
          readListCategoryListFuture(idAccount: idAccount);
        }
      }).catchError((error) {
        print('########################home readManagedAccountsData: ' +
            error.toString());
      });
    }
  }

  void readListCategoryListFuture({required String idAccount}) {
    // obtenemos la categorias creadas por el usuario
    Database.readCategoriesQueryStream(idAccount: idAccount).listen((event) {
      List<Category> list = [];
      for (var element in event.docs) {
        list.add(Category.fromMap(element.data()));
      }
      setCatalogueCategoryList = list;
    });
  }

  loadProductsOutstanding() {
    // productos destacados
    Database.readSalesProduct(idAccount: getUserAccountAuth.uid)
        .listen((value) {
      List<ProductCatalogue> list = [];
      //  get
      for (var element in value.docs) {
        list.add(ProductCatalogue.fromMap(element.data()));
      }
      //  set values
      saveListProductSelecteds(list: list);
    });
  }

  void readProductsCatalogue({required String idAccount}) {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    Database.readProductsCatalogueStream(id: idAccount).listen((value) {
      List<ProductCatalogue> list = [];
      //  get
      for (var element in value.docs) {
        list.add(ProductCatalogue.fromMap(element.data()));
      }
      //  set values
      loadProductsOutstanding();
      setCatalogueProducts = list;
    }).onError((error) {
      // error
    });
  }

  Future<void> categoryDelete({required String idCategory}) async =>
      await Database.refFirestoreCategory(idAccount: getUserAccountAuth.uid)
          .doc(idCategory)
          .delete();
  Future<void> categoryUpdate({required Category categoria}) async {
    // ref
    var documentReferencer =
        Database.refFirestoreCategory(idAccount: getProfileAccountSelected.id)
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

  // Cambiar de cuenta
  void accountChange({required String idAccount}) {
    // save key/values Storage
    GetStorage().write('idAccount', idAccount);
    Get.offAllNamed(Routes.HOME, arguments: {
      'currentUser': getUserAccountAuth,
      'idAccount': idAccount,
    });
  }

  // BottomSheet - Getx
  void showModalBottomSheetSelectAccount() {
    // muestra las cuentas en el que este usuario tiene acceso
    Widget widget = getManagedAccountData.isEmpty
        ? WidgetButtonListTile().buttonListTileCrearCuenta()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            shrinkWrap: true,
            itemCount: getManagedAccountData.length,
            itemBuilder: (BuildContext context, int index) {
              return WidgetButtonListTile().buttonListTileItemCuenta(
                  perfilNegocio: getManagedAccountData[index],
                  adminPropietario: getManagedAccountData[index].id ==
                      getUserAccountAuth.uid);
            },
          );

    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      widget,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }

}
