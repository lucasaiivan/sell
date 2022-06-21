import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/models/user_model.dart';
import 'package:sell/app/services/database.dart';

class HomeController extends GetxController {
  // list products for catalogue

  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //...filter
  }

  // list products selecteds
  List<ProductCatalogue> listProductSelecteds = <ProductCatalogue>[].obs;
  saveListProductSelecteds({required List<ProductCatalogue> list}) {
    GetStorage().write('listProductSelecteds', list);
    listProductSelecteds = list;
  }

  addToListProductSelecteds({required ProductCatalogue item}) {
    listProductSelecteds.add(item);
    GetStorage().write('listProductSelecteds', listProductSelecteds);
  }

  loadListProductSelecteds() {
    listProductSelecteds = GetStorage().read('listProductSelecteds') ?? [];
  }

  //  authentication account profile
  late User _userAccountAuth;
  User get getUserAccountAuth => _userAccountAuth;
  set setUserAccountAuth(User user) => _userAccountAuth = user;

  // profile user
  ProfileAccountModel _accountProfile =
      ProfileAccountModel(creation: Timestamp.now());
  ProfileAccountModel get getAccountProfile => _accountProfile;
  set setAccountProfile(ProfileAccountModel value) => _accountProfile = value;

  final RxInt _indexPage = 0.obs;
  int get getIndexPage => _indexPage.value;
  set setIndexPage(int value) => _indexPage.value = value;

  @override
  void onInit() async {
    super.onInit();

    // obtenemos por parametro los datos de la cuenta de atentificación
    Map map = Get.arguments as Map;

    // load data app
    loadListProductSelecteds();

    // verificamos y obtenemos los datos pasados por parametro
    setUserAccountAuth = map['currentUser'];
    map.containsKey('idAccount')? readAccountsData(idAccount: getUserAccountAuth.uid): readAccountsData(idAccount: '');
  
  }

  @override
  void onClose() {}

  // QUERIES FIRESTORE
  void readAccountsData({required String idAccount}) {
    //default values
    setAccountProfile = ProfileAccountModel(creation: Timestamp.now());
    // obtenemos los datos de la cuenta
    if (idAccount != '') {
      // load 
    readProductsCatalogue(idAccount:idAccount);
      Database.readProfileAccountModelFuture(idAccount).then((value) {
        //get
        if (value.exists) {
          setAccountProfile =
              ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          //  agregamos los datos del perfil de la cuenta en la lista para mostrar al usuario
          /* if (profileAccount.id != '') {
            //addManagedAccount(profileData: profileAccount);
          } */
        }
      }).catchError((error) {
        print('########################home readManagedAccountsData: ' +
            error.toString());
      });
    }
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
      setCatalogueProducts = list;
    }).onError((error) {
      // error
    });
  }
}
