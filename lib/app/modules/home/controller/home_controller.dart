import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/models/user_model.dart';
import 'package:sell/app/services/database.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/widgets_utils.dart';
import '../../sellPage/controller/sell_controller.dart';

class HomeController extends GetxController {

  // value state : este valor valida si el usuario quiere que el código escaado quiere agregarlo a su cátalogue
  bool checkAddProductToCatalogue = false;
  
  // list admins users
  final RxList<UserModel> _adminsUsersList = <UserModel>[].obs;
  List<UserModel> get getAdminsUsersList => _adminsUsersList;
  set setAdminsUsersList(List<UserModel> list) {
    _adminsUsersList.value = list;
    //...filter
  }

  // category list
  final RxList<Category> _categoryList = <Category>[].obs;
  List<Category> get getCatalogueCategoryList => _categoryList;
  set setCatalogueCategoryList(List<Category> value) {
    _categoryList.value = value;
    update(['tab']);
  }

  // list products for catalogue
  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //...filter
  }

  // list products selecteds
  final RxList<ProductCatalogue> _productsOutstandingList =
      <ProductCatalogue>[].obs;
  get getProductsOutstandingList => _productsOutstandingList;
  set setProductsOutstandingList(List<ProductCatalogue> list) {
    _productsOutstandingList.value = list;
  }

  addToListProductSelecteds({required ProductCatalogue item}) {
    _productsOutstandingList.add(item);
  }

  //  authentication account profile
  late User _userAccountAuth;
  User get getUserAccountAuth => _userAccountAuth;
  set setUserAccountAuth(User user) => _userAccountAuth = user;
  //  profile Admin User
  UserModel _adminUser = UserModel();
  UserModel get getProfileAdminUser => _adminUser;
  set setProfileAdminUser(UserModel user) => _adminUser = user;

  // profile account selected
  ProfileAccountModel _accountProfileSelected =
      ProfileAccountModel(creation: Timestamp.now());
  ProfileAccountModel get getProfileAccountSelected => _accountProfileSelected;
  set setProfileAccountSelected(ProfileAccountModel value) =>
      _accountProfileSelected = value;
  String get getIdAccountSelected => _accountProfileSelected.id;
  bool isSelected({required String id}) {
    bool isSelected = false;
    for (ProfileAccountModel obj in getManagedAccountsList) {
      if (obj.id == getIdAccountSelected) {
        if (id == getIdAccountSelected) {
          isSelected = true;
        }
      }
    }

    return isSelected;
  }

  // administrator account list
  final RxList<ProfileAccountModel> _managedAccountsList =
      <ProfileAccountModel>[].obs;
  List<ProfileAccountModel> get getManagedAccountsList => _managedAccountsList;
  set setManagedAccountsList(List<ProfileAccountModel> value) =>
      _managedAccountsList.value = value;
  set addManagedAccountsList(ProfileAccountModel profileData) {
    // agregamos la nueva cuenta
    _managedAccountsList.add(profileData);
  }

// index
  final RxInt _indexPage = 0.obs;
  int get getIndexPage => _indexPage.value;
  set setIndexPage(int value) => _indexPage.value = value;

  @override
  void onInit() async {
    super.onInit();

    // obtenemos por parametro los datos de la cuenta de atentificación
    Map map = Get.arguments as Map;
    // verificamos y obtenemos los datos pasados por parametro
    setUserAccountAuth = map['currentUser'];
    map.containsKey('idAccount')
        ? readAccountsData(idAccount: map['idAccount'])
        : readAccountsData(idAccount: '');
  }

  @override
  void onClose() {}

  // FUNCTIONS
  Future<bool> onBackPressed({required BuildContext context})async{

    // si el usuario no se encuentra en el index 0, va a devolver la vista al index 0
    if(getIndexPage!=0){
      setIndexPage = 0 ;
      return false;
    }
    
    final  shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('¿Realmente quieres salir de la app?',textAlign: TextAlign.center),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    if (Platform.isIOS) {exit(0);} else {SystemNavigator.pop();}
                  },
                  child: const Text('Si'),
                ),
              ],
            );
          },
        );
        return shouldPop!;
  } 
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
    getProfileAccountSelected.id = idAccount;

    // obtenemos las cuentas asociada a este email
    readUserAccountsList(email: getUserAccountAuth.email ?? 'null');
    // obtenemos los datos de la cuenta
    if (idAccount != '') {
      Database.readProfileAccountModelFuture(getProfileAccountSelected.id)
          .then((value) {
        //get
        if (value.exists) {
          setProfileAccountSelected =
              ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          //  agregamos los datos del perfil de la cuenta en la lista para mostrar al usuario
          /* if (profileAccount.id != '') {
            //addManagedAccount(profileData: profileAccount);
          } */
          // load

          readDataAdminUser(
              email: getUserAccountAuth.email ?? 'null', idAccount: idAccount);
          readProductsCatalogue(idAccount: idAccount);
          readAdminsUsers(idAccount: idAccount);
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

  loadProductsOutstanding({required String idAccount}) {
    // obtenemos los productos más vendidos
    setProductsOutstandingList = [];
    // Firestore get
    Database.readSalesProduct(idAccount: idAccount).listen((value) {
      List<ProductCatalogue> list = [];
      //  get
      for (var element in value.docs) {
        list.add(ProductCatalogue.fromMap(element.data()));
      }
      //  set values
      setProductsOutstandingList = list;
    });
  }

  void readProductsCatalogue({required String idAccount}) {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    Database.readProductsCatalogueStream(id: idAccount).listen((value) {
      List<ProductCatalogue> list = [];

      if (value.docs.isNotEmpty) {
        //  get
        for (var element in value.docs) {
          list.add(ProductCatalogue.fromMap(element.data()));
        }
      }
      //  set values
      loadProductsOutstanding(idAccount: idAccount);
      setCatalogueProducts = list;
    }).onError((error) {
      // error
      setCatalogueProducts = [];
    });
  }

  void readAdminsUsers({required String idAccount}) {
    // obtenemos los usuarios administradores de la cuenta
    Database.readQueryStreamAdminsUsers(idAccount: idAccount).listen((value) {
      List<UserModel> list = [];
      //  get
      for (var element in value.docs) {
        list.add(UserModel.fromMap(element.data()));
      }
      //  set values
      setAdminsUsersList = list;
    }).onError((error) {
      // error
    });
  }

  void readDataAdminUser({required String idAccount, required String email}) {
    // obtenemos los datos del usuario administrador
    Database.readFutureAdminUser(idAccount: idAccount, email: email)
        .then((value) {
      if (value.exists) {
        setProfileAdminUser =
            UserModel.fromDocumentSnapshot(documentSnapshot: value);
      }
    });
  }

  void readUserAccountsList({required String email}) {
    // obtenemos la lista de cuentas del usuario
    Database.refFirestoreUserAccountsList(email: email).get().then((value) {
      //  get
      for (var element in value.docs) {
        if (element.get('id') != '') {
          Database.readProfileAccountModelFuture(element.get('id'))
              .then((value) {
            ProfileAccountModel profileAccountModel =
                ProfileAccountModel.fromDocumentSnapshot(
                    documentSnapshot: value);
            addManagedAccountsList = profileAccountModel;
          });
        }
      }
    });
  }

  Future<void> categoryDelete({required String idCategory}) async =>
      await Database.refFirestoreCategory(
              idAccount: getProfileAccountSelected.id)
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

  void addProductToCatalogue({required ProductCatalogue product}) async {
    // values : registra el precio en una colección publica para todos los usuarios
    Price precio = Price(
      id: getProfileAccountSelected.id,
      idAccount: getProfileAccountSelected.id,
      imageAccount: getProfileAccountSelected.image,
      nameAccount: getProfileAccountSelected.name,
      price: product.salePrice,
      currencySign: product.currencySign,
      province: getProfileAccountSelected.province,
      town: getProfileAccountSelected.town,
      time: Timestamp.fromDate(DateTime.now()),
    );
    // Firebase set : se guarda un documento con la referencia del precio del producto
    await Database.refFirestoreRegisterPrice(
            idProducto: product.id, isoPAis: 'ARG')
        .doc(precio.id)
        .set(precio.toJson());

    // Firebase set : se actualiza los datos del producto del cátalogo de la cuenta
    Database.refFirestoreCatalogueProduct(
            idAccount: getProfileAccountSelected.id)
        .doc(product.id)
        .set(product.toJson())
        .whenComplete(() async {})
        .onError((error, stackTrace) => null)
        .catchError((_) => null);
  }

  // Cambiar de cuenta
  void accountChange({required String idAccount}) {
    // default values of controllers
    setCatalogueCategoryList = [];
    setCatalogueCategoryList = [];
    setCatalogueProducts = [];
    setProductsOutstandingList = [];
    // save key/values Storage
    GetStorage().write('idAccount', idAccount);
    Get.offAllNamed(Routes.HOME, arguments: {
      'currentUser': getUserAccountAuth,
      'idAccount': idAccount,
    });
  }

  // BottomSheet - Getx
  void showModalBottomSheetSelectAccount() {
    // muestra las cuentas en el que el usuario tiene accesos
    Widget widget = getManagedAccountsList.isEmpty
        ? WidgetButtonListTile().buttonListTileCrearCuenta()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            shrinkWrap: true,
            itemCount: getManagedAccountsList.length,
            itemBuilder: (BuildContext context, int index) {
              return WidgetButtonListTile().buttonListTileItemCuenta(perfilNegocio: getManagedAccountsList[index]);
            },
          );

    Widget buttonEditAccount = getManagedAccountsList.isEmpty
        ? Container()
        : getProfileAdminUser.superAdmin
            ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextButton(
                  child: const Text('Editar perfil'),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(Routes.ACCOUNT);
                  },
                ),
              )
            : getIdAccountSelected == ''
                ? Container()
                : const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                        'Tienes que ser administrador para editar esta cuenta',
                        textAlign: TextAlign.center),
                  );
    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget,
          buttonEditAccount,
        ],
      ),
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
}
