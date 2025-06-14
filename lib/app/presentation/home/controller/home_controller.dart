import 'dart:io';      
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:purchases_flutter/purchases_flutter.dart'; 
import 'package:sell/app/presentation/sellPage/controller/sell_controller.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/fuctions.dart';
import '../../../data/datasource/constant.dart'; 
import '../../../domain/entities/app_info.dart';
import '../../../domain/entities/cashRegister_model.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../domain/entities/user_model.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../domain/use_cases/account_use_case.dart';
import '../../../domain/use_cases/app_use_case.dart';
import '../../../domain/use_cases/authenticate_use_case.dart';
import '../../../domain/use_cases/cash_register_use_case.dart';
import '../../../domain/use_cases/catalogue_use_case.dart';
import '../../../domain/use_cases/user_use_case.dart';  
import '../views/home_view.dart';

class HomeController extends GetxController {
   

  // var : tutorial para el usuario
  final GlobalKey floatingActionButtonRegisterFlashKeyButton = GlobalKey();
  final GlobalKey itemProductFlashKeyButton = GlobalKey();
  final GlobalKey floatingActionButtonTransacctionRegister = GlobalKey();
  final GlobalKey floatingActionButtonTransacctionConfirm = GlobalKey();
  final GlobalKey floatingActionButtonScanCodeBarKey = GlobalKey();
  final GlobalKey floatingActionButtonSelectedCajaKey = GlobalKey();
  final GlobalKey buttonsPaymenyMode = GlobalKey();
  
  // user auth
  late UserAuth? _userAuth = UserAuth();
  set setUserAuth(UserAuth value) => _userAuth = value;
  UserAuth? get getUserAuth => _userAuth;

  // user anonymous
  final RxBool _userAnonymous = false.obs;
  set setUserAnonymous(bool value){
    
    // guardar dato en el almacenamiento local [SharedPreferences] 
    _userAnonymous.value = value;
    // obtenemos datos de prueba para que el usaurio pueda probar la app sin autenticarse
    if(value)readAccountsInviteData();
  }
  bool get getUserAnonymous => _userAnonymous.value;

  // info app
  String _urlPlayStore = '';
  set setUrlPlayStore(String value) => _urlPlayStore = value;
  get getUrlPlayStore {
    return _urlPlayStore == '' ? '' : _urlPlayStore;
  } 

  // modo cajero 
  bool _cashierMode = false;
  set setCashierMode(bool value) { 
    // guardar dato en el almacenamiento local [SharedPreferences]
    AppDataUseCase().setStorageLocalCashierMode(value); 
    _cashierMode = value;
  }
  bool get getCashierMode{  
    return _cashierMode;
  }
  
 // estado de actualización de la app
  bool _updateApp = false;
  set setUpdateApp(bool value) {
    _updateApp = value;
    update();
  }
  bool get getUpdateApp => _updateApp;

  // buildContext : // buildContext : obtenemos el context de la vista
  late BuildContext _homeBuildContext;
  set setHomeBuildContext(BuildContext context) => _homeBuildContext = context;
  BuildContext get getHomeBuildContext => _homeBuildContext;

  // var : para el control de la suscripción
  String clientRevenueCatID = ''; // id de la cuenta es la ID personalizada para RevenueCat 
  Offerings? offerings; // ofertas de suscripción  
  RxBool isSubscribedPremium = false.obs; // control la suscripción premium
  set setIsSubscribedPremium(bool value) => isSubscribedPremium.value = value;
  bool get getIsSubscribedPremium => isSubscribedPremium.value;
 
  // inicia la identificación de id de usario para revenuecat 
  void initIdentityRevenueCat() async {
    //  ------------------------------------------------------------------------------------  //
    //  configure el SDK de RevenueCat con una ID de usuario de la aplicación personalizada  //
    //  ------------------------------------------------------------------------------------  //

    // var
    clientRevenueCatID = getProfileAccountSelected.id;  
    if(clientRevenueCatID == ''){
      // si no hay una cuenta seleccionada
      setIsSubscribedPremium = false;
      // si no hay una cuenta seleccionada
      return;
    }
    
    try{
      // logIn : identificar al usuario con un ID personalizada
      // condition : comprobar si en revenuecat se inicio sesion  
      //await Purchases.logOut(); 
      // loginResult : resultado de la identificación de usuario
      LogInResult result = await Purchases.logIn(clientRevenueCatID).then((value) async{
        // get : obtenemos las ofertas de compra
        await Purchases.getOfferings().then((value) => offerings = value ); 
        return value;
      }); 
      // get : obtenemos los productos de compra
      result.customerInfo.entitlements.all.forEach((key, value) { 
        // conditionm : si la subcripcion es premium esta activa
        if(key == entitlementID){  
          setIsSubscribedPremium = value.isActive;
          //Get.snackbar('RevenueCat', value.isActive?'Suscripción premium activa':'Suscripción premium inactiva');  
        }  
      }); 
      // prueba gratuita : comprobamos si la cuenta tiene una prueba gratuita activada
      if(getIsSubscribedPremium == false ){
        // imprimir las marcas de tiempo 
        if(getProfileAccountSelected.trialEnd.toDate().isAfter(DateTime.now())){ 
          // si la prueba gratuita esta activa
          setIsSubscribedPremium = true;
        }
      }
    }catch(e){
      // ignore: avoid_print
      print('Error en initIdentityRevenueCat: $e');
      //Get.snackbar('Error RevenueCat', 'Error en initIdentityRevenueCat: $e');
    }
  } 

  // brillo de la pantalla
  bool _darkMode = false;
  set setDarkMode(bool value) => _darkMode = value;
  bool get getDarkMode => _darkMode; 

  // list admins users
  final RxList<UserModel> _adminsUsersList = <UserModel>[].obs;
  List<UserModel> get getAdminsUsersList => _adminsUsersList;
  set setAdminsUsersList(List<UserModel> list) { _adminsUsersList.value = list;
    //...filter
  }

  // category list
  final RxList<Category> _categoryList = <Category>[].obs;
  List<Category> get getCatalogueCategoryList => _categoryList;
  set setCatalogueCategoryList(List<Category> value) {
    _categoryList.value = value;
  }
  void categorySelected({required Category category}) {
    // description : posiciona el item (categoria) seleccionado en el primer lugar de la lista
    _categoryList.remove(category);
    _categoryList.insert(0, category);
  }
  
  // provider list
  final RxList<Provider> _providerList = <Provider>[].obs;
  List<Provider> get getProviderList => _providerList;
  set setProviderList(List<Provider> value) {
    _providerList.value = value;
  }
  void providerSelected({required Provider provider}) {
    // description : posiciona el item (proveedor) seleccionado en el primer lugar de la lista
    _providerList.remove(provider);
    _providerList.insert(0, provider);
  }

  // cash register  //
  late CashRegister cashRegisterActiveTemp; 
  set setCashRegisterActiveTemp(CashRegister value) => cashRegisterActiveTemp = value; 
  CashRegister get getCashRegisterActiveTemp => cashRegisterActiveTemp;
  CashRegister cashRegisterActive = CashRegister(
      id: '',
      sales: 0,
      description: '',
      opening: DateTime.now(),
      closure: DateTime.now(),
      billing: 0.0,
      discount: 0.0,
      cashInFlow: 0.0,
      cashOutFlow: 0.0,
      expectedBalance: 0.0,
      balance: 0.0,
      cashInFlowList: [],
      cashOutFlowList: [],
      initialCash: 0.0,
      cashiers: [],
      openingCashiers: '',
    );
  List<CashRegister> listCashRegister = [];
  
  void loadCashRegisters() {
    // user case : obtener las caajas registradoras activas
    CashRegisterUseCase().getCashRegisterActive(getProfileAccountSelected.id).then((value) {
      // default values
      listCashRegister.clear(); // limpiamos la lista de cajas
      // condition : si hay cajas registradoras
      if (value.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in value) {
          listCashRegister.add(element);
        }
        upgradeCashRegister(); // actualizamos el arqueo de caja actual activo
      }
    });
    
  }

  upgradeCashRegister({String id = ''}) async {
    // description : si se selecciono una, actualiza el arqueo de caja actual 
    // condition : si no se actualiza el arqueo de caja actual verificamos si hay un arqueo de caja seleccionada 
    if (id == '') { 
      id = await AppDataUseCase().getStorageLocalCashRegisterID();
    }
    for (CashRegister item in listCashRegister) {
      if (item.id == id) {
        cashRegisterActive = item; // actualizamos el arqueo de caja actual activo
        update();
        break;
      }
    }
  }

  // list products for catalogue
  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //...filter
  }  

  // list : marcas de productos disponibles en el catálogo
  final List<Mark> _markList = [];
  List<Mark> get getMarkList => _markList; 
  void loadMarkCatalogue(){
    // obtenemos las marcas de los productos disponibles en el catálogo
    _markList.clear();
    for (ProductCatalogue item in _catalogueBusiness) {
      // object : obtenemos los datos de la marca
      Mark mark = Mark(id: item.idMark, name: item.nameMark,image: item.imageMark,creation: Utils().getTimestampNow(),upgrade: Utils().getTimestampNow() );
      // condition : validamos la marca del producto
      if(mark.id !='' && mark.name != ''){
        // condition : si la marca no esta en la lista la añadimos
        if(!_markList.contains(mark)){
          _markList.add(mark);
        }
      }
    }  
  }

  // list products más vendidos
  RxBool productsBestSellersLoadComplete = false.obs; // loading state
  final RxList<ProductCatalogue> _productsOutstandingList = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getProductsOutstandingList => _productsOutstandingList;
  set setProductsOutstandingList(List<ProductCatalogue> list) {
    productsBestSellersLoadComplete.value = true;
    _productsOutstandingList.value = list;
    loadMarkCatalogue();
  }

  addToListProductSelecteds({required ProductCatalogue item}) { 
    _productsOutstandingList.insert(0, item);
  }
 

  //  perfil de usuario administrador actual de la cuenta
  UserModel _adminUser = UserModel(creation: Utils().getTimestampNow(),lastUpdate: Utils().getTimestampNow());
  UserModel get getProfileAdminUser => _adminUser;
  set setProfileAdminUser(UserModel user) {
    _adminUser = user;  
    update();
  }

  // profile account selected
  ProfileAccountModel _accountProfileSelected = ProfileAccountModel(creation: Utils().getTimestampNow(),trialEnd: Utils().getTimestampNow(),trialStart: Utils().getTimestampNow());
  ProfileAccountModel get getProfileAccountSelected => _accountProfileSelected;
  set setProfileAccountSelected(ProfileAccountModel value) => _accountProfileSelected = value;
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

  // variable para saber el estado si se cargo la lista de cuenta administradas o si no tiene ningun 
  RxBool loadedManagedAccountsList = false.obs;
  set setLoadedManagedAccountsList(bool value) {
    loadedManagedAccountsList.value = value;
  }
  get getLoadedManagedAccountsList => loadedManagedAccountsList.value;

  // administrator account list : managed accounts
  final RxList<ProfileAccountModel> _managedAccountsList =<ProfileAccountModel>[].obs;
  List<ProfileAccountModel> get getManagedAccountsList => _managedAccountsList;
  set setManagedAccountsList(List<ProfileAccountModel> value) => _managedAccountsList.value = value;
  set addManagedAccountsList(ProfileAccountModel profileData) {
    // agregamos la nueva cuenta
    _managedAccountsList.add(profileData);
  }

  bool get checkAccountExistence {
    // comprobamos si el usuario autenticado ya creo un cuenta
    String idAccountAthentication = getUserAuth!.uid; 
    for (ProfileAccountModel element in getManagedAccountsList) {
      if (idAccountAthentication == element.id) {
        return true;
      }
    }
    return false;
  }
     

// index
  final RxInt _indexPage = 0.obs;
  int get getIndexPage => _indexPage.value;
  set setIndexPage(int value) => _indexPage.value = value;

  // GETTERS //
  bool pinSegurityCheck({required String pin}) {
    // verifica si el pin ingresado es correcto
    return getProfileAccountSelected.pin == pin;
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


  // FUNCTIONS //
  Future<bool> onBackPressed({required BuildContext context}) async {
    // si el usuario no se encuentra en el index 0, va a devolver la vista al index 0
    if (getIndexPage != 0) {
      setIndexPage = 0;
      return false;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Realmente quieres salir de la app?',
              textAlign: TextAlign.center),
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
                if (Platform.isIOS) {
                  exit(0);
                } else {
                  SystemNavigator.pop();
                }
              },
              child: const Text('Si'),
            ),
          ],
        );
      },
    );
    return shouldPop!;
  }
  ProductCatalogue getProductCatalogue({required String id}) {
    ProductCatalogue product = ProductCatalogue(
        creation: Utils().getTimestampNow(),
        upgrade: Utils().getTimestampNow(),
        documentCreation: Utils().getTimestampNow(),
        documentUpgrade: Utils().getTimestampNow(),
      );
    for (final element in getCataloProducts) {
      if (element.id == id) {
        product = element;
      }
    }
    return product;
  }
  void sincronizeCatalogueProducts({required ProductCatalogue product,bool delete = false}) {
    // sincronizamos los productos del catálogo
    bool exist = false;
    if(delete){
      // eliminamos el producto del catálogo
      getCataloProducts.removeWhere((element) => element.id == product.id);
    }else{
      for (int i = 0; i < getCataloProducts.length; i++) {
        if (getCataloProducts[i].id == product.id) {
          getCataloProducts[i] = product;
          exist = true;
          break;
        }
      }
      // condition : si el producto no existe en la lista lo añadimos
      if (exist==false) {  
        getCataloProducts.insert(0, product);
      }
    }
    // ordenamos por fecha de actualización
    getCataloProducts.sort((a, b) => b.upgrade.compareTo(a.upgrade));
  }

  // fuction : cerrar sesion de firebase
  Future<void> navigationLogin() async {
    // case use : cerrar sesión de google y firebase
    await signOutGoogleAndFirebase();
    // navigation : navegamos a la pantalla principal
    Get.offAllNamed(Routes.login);
  }
  // fuction : cerrar sesión de google y firebase
  Future<void> signOutGoogleAndFirebase() async {
    // case use : intancias de FirebaseAuth para proceder a cerrar sesión
    
    // cerramos sesión
    try {
      // Eliminar los datos de la memoria del dispositivo
      await AppDataUseCase().clearLocalData();
      // set : id de la cuenta seleccionada nulo por defecto 
      await AppDataUseCase().setStorageLocalIdAccount('');
      
       // case use : cerrar sesión de firebase y google 
      await AuthenticateUserUseCase().signOut();


    } catch (error) {
      print('#### error : signOutGoogle');
    }
  }

  // FIRESTORE //
  void createPin({required String pin}) {

    // case use : actualizar el pin de la cuenta
    final updatePinAccount = GetAccountUseCase();
    // apdate  
    updatePinAccount.updateAccountPin( account: getProfileAccountSelected, pin: pin);
    getProfileAccountSelected.pin = pin; 
    
  }
  Future<void> isAppUpdated() async {
    // comprobamos si la app esta actualizada
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);
      // case use : obtener información de la app
      AppInfo appInfo = await AppDataUseCase().getAppInfo(); 
      final firestoreVersion = appInfo.versionApp;
      //urlPlayStore
      setUrlPlayStore = appInfo.urlPlayStore;

      setUpdateApp = firestoreVersion > currentVersion;
    } catch (e) {
      setUpdateApp = false;
    }
  }

  void readAccountsInviteData() {
    //default values 
    setCatalogueCategoryList = []; // lista de categorias del catálogo
    setCatalogueProducts = [
      ProductCatalogue(
          creation: Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation: Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://ardiaprod.vtexassets.com/arquivos/ids/298980/Gaseosa-CocaCola-Sabor-Original-500-Ml-_1.jpg',
          id: '7790895000782',
          code: '7790895000782',
          description: 'Coca Cola Original 500 Ml',
          salePrice: 1200,
          purchasePrice: 600,
          favorite: true,
          sales: 4,
          stock: true,
          quantityStock: 22),
      ProductCatalogue(
          creation: Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation: Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://img.sistemastock.com/img/7795735000335.jpg',
          id: '7795735000335',
          code: '7795735000335',
          description: 'Don Satur Dulce 200G',
          salePrice: 866,
          purchasePrice: 400,
          sales: 1,
          stock: true,
          favorite: true,
          quantityStock: 47),
      ProductCatalogue(
          creation: Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation:Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://img.sistemastock.com/img/7790310984192.jpg',
          id: '7790310984192',
          code: '7790310984192',
          description: 'Doritos 85G',
          salePrice: 2200,
          purchasePrice: 1500,
          sales: 7,
          stock: true,
          quantityStock: 18,
          ),
        ProductCatalogue(
          creation: Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation: Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://img.sistemastock.com/img/0000077953124.jpg',
          id: '77953124',
          code: '77953124',
          description: 'COFLER BLOCK 38 GR',
          salePrice: 1000,
          purchasePrice: 600,
          sales: 7,
          stock: true,
          quantityStock: 18,
          ),
        ProductCatalogue(
          creation: Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation: Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://img.sistemastock.com/img/7790895000836.jpg',
          id: '7790895000836',
          code: '7790895000836',
          description: 'FANTA NARANJA X 500 ML',
          salePrice: 900,
          purchasePrice: 490,
          sales: 7,
          stock: true,
          quantityStock: 18,
          ),
          ProductCatalogue(
          creation: Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation: Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://img.sistemastock.com/img/7790387015324.jpg',
          id: '7790387015324',
          code: '7790387015324',
          description: 'Yerba Mate Mañanita 500g',
          salePrice: 2100,
          purchasePrice: 1000,
          sales: 7,
          stock: true,
          quantityStock: 18,
          ),
          ProductCatalogue(
          creation:Utils().getTimestampNow(),
          upgrade: Utils().getTimestampNow(),
          documentCreation: Utils().getTimestampNow(),
          documentUpgrade: Utils().getTimestampNow(),
          image: 'https://img.sistemastock.com/img/7791324157022.jpg',
          id: '7791324157022',
          code: '7791324157022',
          description: 'PITUSAS VAINILLA 160G',
          salePrice: 800,
          purchasePrice: 450,
          sales: 7,
          stock: true,
          quantityStock: 18,
          ),
    ]; // lista de productos del catálogo
    setProductsOutstandingList = getCataloProducts.toList(); // lista de productos destacados
    setProfileAccountSelected = ProfileAccountModel(creation: Utils().getTimestampNow(),name: 'Mi negocio',trialEnd: Utils().getTimestampNow(),trialStart: Utils().getTimestampNow()); // datos de la cuenta
    setManagedAccountsList = []; // lista de cuentas gestionadas
    setProfileAdminUser = UserModel(
        superAdmin: true,
        admin: true,
        email: 'userInvite@correo.com',
        creation: Utils().getTimestampNow(),
        lastUpdate: Utils().getTimestampNow(),
        ); // datos del usuario
    setAdminsUsersList = []; // lista de usuarios administradores
  }

  void readAccountsData({required String idAccount}) {

    //default values'
    setUserAnonymous = false;
    setCatalogueCategoryList = [];
    setCatalogueProducts = [];
    setProductsOutstandingList = [];
    setProfileAccountSelected = ProfileAccountModel(creation: Utils().getTimestampNow(),trialEnd: Utils().getTimestampNow(),trialStart:Utils().getTimestampNow());
    getProfileAccountSelected.id = idAccount; // asignamos el id de la cuenta

    // obtenemos las cuentas asociada a este email
    readUserAccountsList(email: getUserAuth?.email ?? '');
    // obtenemos los datos de la cuenta
    if (idAccount!= '') {

    // use case : obtener los productos del catálogo
    final getAccount = GetAccountUseCase();

    // future : obtenemos los productos del catálogo una sola ves
    getAccount.getAccount(idAccount: idAccount).then((value) {

      if(value.id!=''){
        setProfileAccountSelected = value;
        // subcription premium  : inicializamos la identidad de revenue cat
        initIdentityRevenueCat();  
        // load
        loadCashRegisters(); // obtenemos las cajas registradoras activas
        readProductsCatalogue(idAccount: idAccount); // obtenemos los productos del catálogo
        readListCategoryListFuture(idAccount: idAccount); // obtenemos las categorias creadas por el usuario
        readProvidersListFuture(idAccount: idAccount); // obtenemos los proveedores creados por el usuario
        readDataAdminUser( email: getUserAuth?.email ?? '', idAccount: idAccount); // obtenemos los datos del usuario administrador de la cuenta
        readAdminsUsers(idAccount: idAccount);  // obtenemos los usuarios administradores de la cuenta
      }
      
      }) ; 
    }
  }

  void readListCategoryListFuture({required String idAccount}) {
     

    // case use : obtener las categorias creadas por el usuario
    final getCategories = GetCatalogueUseCase();

    getCategories.getCategoriesStream(idAccount: idAccount).listen((event) {
      List<Category> list = [];
      for ( var category in event) { list.add(category); }
      setCatalogueCategoryList = list;
    }); 
  }
  void readProvidersListFuture({required String idAccount}) {

    // case use : obtener los proveedores
    final getProviders = GetCatalogueUseCase();
    getProviders.getProviderListStream(idAccount: idAccount).listen((event) {
      List<Provider> list = [];
      for ( var provider in event) { list.add(provider); }
      setProviderList = list;
    });
  }

  getTheBestSellingProducts({required List<ProductCatalogue> productsList}) {
    
    // values
      List<ProductCatalogue> list = [];
      //  obtenemos todos los productos ordenas con más ventas
      for (var element in productsList) {
        list.add(element);
      }

      // filtramos los productos que esten marcados como favoritos
      List<ProductCatalogue> favoriteList = [];
      for (ProductCatalogue element in list) {
        if (element.favorite) {
          favoriteList.add(element);
        }
      }
      // filtramos los productos que no sean favoritos
      List<ProductCatalogue> filterList = [];
      for (ProductCatalogue element in list) {
        if (element.favorite == false) {
          filterList.add(element);
        }
      }
      // obtenemos una nueva lista con los productos favoritos primeros ordenados por los que tienen más ventas
      List<ProductCatalogue> finalList = [];
      for (ProductCatalogue element in favoriteList) {
        finalList.add(element);
      }
      // luego obtenemos los demas productos ordenados por los que tienen más ventas
      for (ProductCatalogue element in filterList) {
        finalList.add(element);
      }
      //  set values
      setProductsOutstandingList = finalList;
      try {
        // actualizamos la vista de ventas
        SellController salesController = Get.find();
        salesController.update();
      } catch (_) {}
  }

  void readProductsCatalogue({required String idAccount}) {

    // use case : obtener los productos del catálogo
    final getCatalogue = GetCatalogueUseCase();

    // future : obtenemos los productos del catálogo una sola ves
    getCatalogue.getProducts(id:idAccount).then((value) {
      // set : productos del catálogo
      setCatalogueProducts = value;
      // obtenemos los productos más vendidos
      getTheBestSellingProducts(productsList: value);  
    }).onError((error, stackTrace) {
      // error
      setCatalogueProducts = [];
    });
  }

  void readAdminsUsers({required String idAccount}) {

    // use case : obtener los usuarios administradores de la cuenta
    final usersAssociate = GetAccountUseCase().getAccountAdmins(idAccount: idAccount);

    // obtenemos los usuarios administradores de la cuenta
    usersAssociate.then((value) {
      List<UserModel> list = [];
      for (var element in value) {
        list.add(element);
      }
      // ordenamos la lista por fecha de actualizacion
      list.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
      //  set values
      setAdminsUsersList = list;
    }); 
  }
  
  void readDataAdminUser({required String idAccount, required String email}) {

    // use case : obtener los datos del usuario administrador de la cuenta
    final getAccount = GetUserUseCase().getAdminProfile(idAccount: idAccount,idUser: email);

    // obtenemos los datos de los permisos del usuario en la cuenta
    getAccount.then((value) {
        if (value.email != '') { 
        // set : datos de los permisos del usuario en la cuenta
        setProfileAdminUser = value;   
        // condition : comprobar que el usuario no este inactivo
        if(getProfileAdminUser.inactivate == true){
          //  ------------------------------------  //
          //  acceso inactivo por el administrador  //
          //  ------------------------------------  //
          Get.dialog(
            PopScope( 
              canPop: false, // Evita que el diálogo se cierre cuando se presiona el botón de retroceso
              child: Center(
                child: AlertDialog(
                  icon: const Icon(Icons.lock),
                  title: const Text('Usuario inactivo'),
                  content: const Text('Tu acceso a la cuenta ha sido restringido ponte en contacto con el administrador'),
                  actions: [
                    // button : cambiar de cuenta
                    TextButton(
                      onPressed: () {
                        // navigation : navegamos a la pantalla de inicio de sesión
                        Get.offAllNamed(Routes.home, arguments: {
                          'currentUser': getUserAuth,
                          'idAccount': ''
                        });
                      },
                      child: const Text('ok'),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
            barrierColor: const Color(0xff141A31).withOpacity(.3),
            useSafeArea: true, navigatorKey: Get.key,
          );

        // condition : denegar el acceso si esta fuera de horario o dia [hasAccessDay, hasAccessHour] a menos que sea [superAdmin, admin]
        }else if( getProfileAdminUser.hasAccessDay == false && getProfileAdminUser.superAdmin == false  || getProfileAdminUser.hasAccessHour == false && getProfileAdminUser.superAdmin == false){ 
          
          //  --------------------------------------  //
          // acceso restringido por horario de acceso //
          //  --------------------------------------  //
          Get.dialog(
            PopScope( 
              canPop: false, // Evita que el diálogo se cierre cuando se presiona el botón de retroceso
              child: Center(
                child: AlertDialog(
                  icon: const Icon(Icons.lock_clock),
                  title: const Text('No tienes acceso'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [ 
                      // text : dias con acceso
                      const Text('Días de acceso:'),
                      const SizedBox(height: 10),
                      // text : dias con acceso 
                      Wrap(
                        spacing: 4,
                        children: getProfileAdminUser.getDaysOfWeek.map((e) => Chip(label: Text(e),backgroundColor: Colors.transparent)).toList(),
                      ),
                      // text : horario de acceso
                      Text('Horario: ${getProfileAdminUser.getAccessTimeFormat}'),
                    ],
                  ),
                  actions: [
                    // button : cambiar de cuenta
                    TextButton(
                      onPressed: () {
                        // navigation : navegamos a la pantalla de inicio de sesión
                        Get.offAllNamed(Routes.home, arguments: {
                          'currentUser': getUserAuth,
                          'idAccount': ''
                        });
                      },
                      child: const Text('ok'),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
            barrierColor: const Color(0xff141A31).withOpacity(.3),
            useSafeArea: true, navigatorKey: Get.key,
          );
        }
        
      }
    },);
  }

  void readUserAccountsList({required String email}) { 

    // use case : obtener las cuentas administradas por el usuario
    final getAccounts = GetUserUseCase().getUserAssociatedAccounts(email: email);
 

    // firebase : obtenemos la lista de cuentas del usuario
    getAccounts.then((value) { 
      //  recorre la lista de cuentas
      for (var userModel in value){ 
        // condition : si el id de la cuenta es diferente de vacio para evitar errores de consulta inexistentes
        if (userModel.account != '') {
          // case use : obtener los datos de la cuenta
          final accountProfileFuture = GetAccountUseCase().getAccount(idAccount: userModel.account);
          accountProfileFuture.then((value) {
            // set : datos de la cuenta
            addManagedAccountsList = value;
            setLoadedManagedAccountsList = true;
          }); 
        }
      } 
      if(value.isEmpty){
        setLoadedManagedAccountsList = true;
      }
      
    }).onError((error, stackTrace){
      setLoadedManagedAccountsList = true;
    }).catchError((onError) {
      // error
      setLoadedManagedAccountsList = true;
    });
  }
  Future<void> activateTrial() async {
    // registramos la fecha de inicio y fin de la prueba gratuita
    // var 
    var  trialEnd = Utils().getFreeTrialTimesTampEnd();
    var  trialStart = Utils().getTimestampNow();
    
    // case use : actualizar datos de la cuenta
    final account = GetAccountUseCase();
     // set
    account.updateAccountData(idAccount: getProfileAccountSelected.id, data: {'trialEnd': trialEnd,'trialStart': trialStart,'trial': true});
    getProfileAccountSelected.trialEnd = trialEnd;
    getProfileAccountSelected.trialStart = trialStart;
    // set
    setIsSubscribedPremium = true;
  }
  Future<void> categoryDelete({required String idCategory}) async{

    // case use : eliminar la categoria
    return GetCatalogueUseCase().deleteCategory( idAccount: getProfileAccountSelected.id, idCategory: idCategory);
    //return await Database.refFirestoreCategory(idAccount: getProfileAccountSelected.id).doc(idCategory).delete();
  }
  Future<void> categoryUpdate({required Category categoria}) async {

    // refactorizamos el nombre de la cátegoria
    String name = categoria.name.substring(0, 1).toUpperCase() + categoria.name.substring(1);
    categoria.name = name;

    // case use : actualizar la categoria
    return GetCatalogueUseCase().updateCategory( idAccount: getProfileAccountSelected.id, category: categoria); 
  }
  Future<void> providerDelete({required Provider provider}) async => {
    // case use : eliminar el proveedor
     await GetCatalogueUseCase().deleteProvider( idAccount: getProfileAccountSelected.id, provider: provider)
  };
  Future<void> providerSave({required Provider provider}) async { 

    // case use : actualizar el proveedor
    return GetCatalogueUseCase().updateProvider( idAccount: getProfileAccountSelected.id, provider: provider);
  }
  
  void addProductToCatalogue({required ProductCatalogue product,required isProductNew}) async {
    // obj : se obtiene los datos para registrar del precio al publico del producto en una colección publica de la db
    ProductPrice precio = ProductPrice(
      id: getProfileAccountSelected.id,
      idProduct: product.id, 
      idAccount: getProfileAccountSelected.id,imageAccount: getProfileAccountSelected.image,nameAccount: getProfileAccountSelected.name,price: product.salePrice,currencySign: product.currencySign,province: getProfileAccountSelected.province,town: getProfileAccountSelected.town,time: Utils().getTimestampNow() );
    // condition : si el producto es nuevo se le asigna los valores de creación
    if(isProductNew){
      // el producto no existe 
      product.creation = Utils().getTimestampNow(); // fecha de creación del producto 
      product.followers++; // incrementamos el contador de los seguidores del producto publico 
   
    }else{
      //
      // el producto ya existe
      // 
      // case use : incrementar el contador de seguidores del producto publico 
      GetCatalogueUseCase().incrementFollowersProductPublic(idProduct: product.id);
    }
    // set : fecha de actualización del producto
    product.upgrade = Utils().getTimestampNow();  
    // case use : publica el precio del producto en la colección de precios publicos
    GetCatalogueUseCase().registerPriceProductPublic(price: precio);

    // case use : se actualiza el documento del producto del cátalogo
    GetCatalogueUseCase().updateProduct(idAccount: getProfileAccountSelected.id, product: product);
     
    // actualiza la lista de productos del cátalogo en la memoria de la app
    sincronizeCatalogueProducts(product: product);
    
    // condition : si el producto no esta verificado o no existe 
    if (product.verified == false || isProductNew ) { 
      // fuction : se crea un documento en la colección publica
      addProductToCollectionPublic(isNew: isProductNew, product: product.convertProductoDefault());
    }
  }

  void addProductToCollectionPublic({required bool isNew, required Product product}) {
    // description : esta función procede a guardar el documento de una colleción publica
 

    // condition : si el producto es nuevo se le asigna los valores de creación
    if (isNew && product.verified == false) {
      // datos de creación por primera vez 
      product.idUserCreation = getProfileAdminUser.email;
      product.creation = Utils().getTimestampNow();
    }
    //  set : marca de tiempo que se actualizo el documenti
    product.upgrade = Utils().getTimestampNow();
    //  set : id del usuario que actualizo el documento
    product.idUserUpgrade = getProfileAdminUser.email;

    // dondition : si el producto es nuevo se crea un documento, si no se actualiza
    if (isNew && product.verified == false) { 
      // case use : crear un documento en la colección publica de productos
      GetCatalogueUseCase().createProductPublic(product: product); 
    } else {
      // case use : actualizar un documento en la colección publica de productos
      GetCatalogueUseCase().updateProductPublic(product: product);
    }
  }

  void accountChange({required String idAccount}) async {
    // save key/values Storage
    await AppDataUseCase().setStorageLocalIdAccount(idAccount); 
    // navegar hacia otra pantalla
    Get.offAllNamed(Routes.home,arguments: {'currentUser': getUserAuth, 'idAccount': idAccount} );
  }
  // GETTERS // 
  String calcularDiferenciaFechas(DateTime fechaInicio, DateTime fechaFin) {
     // Asegurar que la fecha final es posterior a la fecha inicial
    if (fechaFin.isBefore(fechaInicio)) {
      throw ArgumentError('La fecha final debe ser posterior a la fecha inicial.');
    }

    // Calcular la diferencia entre las fechas en milisegundos
    final diferencia = fechaFin.difference(fechaInicio);

    // Extraer días y horas
    final dias = diferencia.inDays;
    final horas = diferencia.inHours % 24;

    // Formatear la salida según si quedan días o solo horas
    if (dias > 0) {
      return '$dias días y $horas horas';
    } else {
      return '$horas horas';
    }
  }
  String get getDaysLeftTrialFormat{
    // devuelva en un string formateado los dias y hora restantes de la prueba gratuita y sino queda mas tiempo devuelve un string vacio
    if(getTrialActive){
      return calcularDiferenciaFechas(DateTime.now(),getProfileAccountSelected.trialEnd.toDate());
    }
    return '';
  }
  bool get getTrialActive { 
    // description : verifica si la prueba gratuita esta activa
    return getProfileAccountSelected.trialEnd.toDate().isAfter(DateTime.now());
  }
  bool get getButtonTrialActive{ 
    return getProfileAccountSelected.trialEnd.toDate().year == getProfileAccountSelected.trialStart.toDate().year && getProfileAccountSelected.trialEnd.toDate().month == getProfileAccountSelected.trialStart.toDate().month && getProfileAccountSelected.trialEnd.toDate().day == getProfileAccountSelected.trialStart.toDate().day;
  }
  // DIALOGS //
  void showDialogCerrarSesion() {
    Widget widget = AlertDialog(
      title: const Text("Cerrar sesión"),
      content: const Text("¿Estás seguro de que quieres cerrar la sesión?"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('cancelar')),
        TextButton(
            child: const Text('si'),
            onPressed: () async {
              // visualizamos un diálogo alerta
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
                barrierColor: const Color(0xff141A31).withOpacity(.3),
                useSafeArea: true,
              );
              //
              // instancias de FirebaseAuth para proceder a cerrar sesión
              //
              await signOutGoogleAndFirebase();
            }),
      ],
    );

    Get.dialog(
      widget,
    );
  }
  void showModalBottomSheetConfig() {  
    
    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      MyConfigView(),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
  void showModalBottomSheetSelectAccount() {
    // description : muestra las cuentas en el que el usuario tiene accesos

    // widgets
    Widget widget = Column(
      children: [ 
        // text : titulo  y iconobutton
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // text : titulo
                const Text('Cuentas',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600)),
                const Spacer(),
                // icon : close
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ), 
          // view : lista de cuentas administradas
          ListView.builder(
            padding: const EdgeInsets.symmetric(),
            shrinkWrap: true,
            itemCount: getManagedAccountsList.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  WidgetButtonListTile().buttonListTileItemCuenta( perfilNegocio: getManagedAccountsList[index]),
                  ComponentApp().divider(),
                ],
              );
            },
          ),
        // button : crear cuenta
          getLoadedManagedAccountsList && checkAccountExistence? Container():
          Column(
            children: [
              ComponentApp().divider(), 
              WidgetButtonListTile().buttonListTileCrearCuenta(),
              ComponentApp().divider(),
            ],
          ), 
      ],
    );

    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      ListView(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [ 
              ComponentApp().divider(),
              widget,
            ],
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
  void showModalBottomSheetSubcription({String id = 'premium'}) {
    // bottomSheet : muestre la hoja inferior modal de getx
    Get.bottomSheet(
      SizedBox(
        height: 600, 
        child: WidgetBottomSheetSubcription(id: id)),
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
  
  // NAVIGATION //
  void navigationToPage({required ProductCatalogue productCatalogue}) {
    // condition : verifica si es un producto local
    if(productCatalogue.local){
      // navega hacia la vista de producto
      Get.toNamed(Routes.editProduct, arguments: {'product': productCatalogue.copyWith()});
    }else{
      Get.toNamed(Routes.product, arguments: {'product': productCatalogue.copyWith()});
    }
  }

  // OVERRIDE //
  @override
  void onInit() async {
    super.onInit(); 

    // GetX : obtenemos por parametro los datos de la cuenta de atentificación
    final Map arguments = Get.arguments; 

    // case use : instancias de las clases de caso de uso 
    final appData = AppDataUseCase();

    // obtenemos los datos pasados por argumentos de [get.arguments]
    setUserAuth = arguments['currentUser'] ?? UserAuth(); 
    setUserAnonymous = getUserAuth!.isAnonymous;
 
    // inicialización de la variable     
    setCashierMode = await appData.getStorageLocalCashierMode();
    isAppUpdated(); // verificamos si la app esta actualizada 
 
    
    // condition : comprobamos si el usuario esta autenticado o es un usuario anonimo
    if (!getUserAnonymous) { 
      // obtenemos el id de la cuenta seleccionada si es que existe 
      readAccountsData( idAccount: arguments['idAccount'] );
    }

  }

  @override
  void onClose() { 
    // ...
    super.onClose(); 
  }

}

class WidgetBottomSheetSubcription extends StatefulWidget {
  late final String id;
  // ignore: prefer_const_constructors_in_immutables
  WidgetBottomSheetSubcription({Key? key, required this.id}) : super(key: key);

  @override
  State<WidgetBottomSheetSubcription> createState() => _WidgetBottomSheetSubcriptionState();
}
class _WidgetBottomSheetSubcriptionState extends State<WidgetBottomSheetSubcription> {
  // others controllers
  final HomeController homeController = Get.find();

  // values 
  double sizePremiumLogo = 75.0;
  Widget icon = Container();
  String title = 'Premium';
  String description = ''; 
  String assetImage = '';

  // functions 
  void setData({required String id}) {
    switch (id) {
      case 'premium':
        title = 'Premium';
        description = 'Funcionalidades especiales para profesionalizar tu negocio';
        icon =  Icon(Icons.star_rounded,size: sizePremiumLogo,color: Colors.amber); 
        assetImage = 'assets/premium.jpeg';
        break;
      case 'arching':
        title = 'Arqueo de caja';
        description = 'Realiza arqueo de caja, controla el saldo de tu caja al final de cada día';
        icon = Padding(
            padding: const EdgeInsets.only(right: 5),
            // icon : icono de caja registradora 
            child: Icon(Icons.point_of_sale_rounded,size: sizePremiumLogo,color: Colors.amber));
        assetImage = 'assets/sell05.jpeg';
        break;
      case 'stock':
        title = 'Control de Inventario';
        description ='Maneje el stock de sus productos, disfruta además de otras características especiales';
        icon = Padding(padding:const EdgeInsets.only(right: 5),child: Icon(Icons.inventory_rounded,size: sizePremiumLogo,color: Colors.amber)); 
        assetImage = 'assets/stock.jpeg';
        break;
      case 'analytic':
        title = 'Informes y Estadísticas';
        description ='Obtenga datos, rendimiento de sus transacciones y otras estadísticas importantes';
        icon = Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(Icons.analytics_outlined,size: sizePremiumLogo,color: Colors.amber)); 
        assetImage = 'assets/sell04.jpeg';
        break;
      case 'multiuser':
        title = 'Multiusuario';
        description = 'Permita que más personas gestionen esta cuenta y con permisos personalizados. Además también tenes otras características';
        icon = Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(Icons.people_outline,size: sizePremiumLogo,color: Colors.amber));
        assetImage = 'assets/analytics.jpg';
        break;
      default:
        title = '';
        description =
            'Funcionalidades especiales para profesionalizar tu negocio';
        icon = Container(); 
        assetImage = 'assets/premium.jpeg';
        break;
    }
  }
  

  @override
  void initState() {
    super.initState(); 
    // get  
    setData(id: widget.id);
    
  }



  @override  
  Widget build(BuildContext context) { 

    // values
    Color colorCard = Get.isDarkMode?Get.theme.scaffoldBackgroundColor:const Color.fromARGB(255, 243, 238, 228); 
    Color colorAccent = Get.isDarkMode?Colors.white:Colors.black;
    // widgets
    TextButton trialActivateTextButton = TextButton(
      style: TextButton.styleFrom( side: const BorderSide(color: Colors.blue,width: 1),minimumSize: const Size(200, 40),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      onPressed: () { 
        // activar prueba gratuita
        homeController.activateTrial();
        Get.back();
      },
      child:const Text('ACTIVAR PRUEBA POR 30 DÍAS'),
    );
    TextButton trialResumenTextButton = TextButton(
      style: TextButton.styleFrom( side: const BorderSide(color: Colors.blue,width: 1),minimumSize: const Size(200, 40),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      onPressed: () { 
        return;
      },
      child: Text('Quedan ${homeController.getDaysLeftTrialFormat} de prueba'),
    );

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: colorCard,
      clipBehavior: Clip.antiAlias,
      child: Stack(   
        children: [ 
          // view : contenido de la suscripción desplazable
          ListView(  
            children: [
              Stack(
                children: [
                  // Imagen de fondo
                  Image.asset(
                    assetImage,
                    fit: BoxFit.cover, // Ajusta la imagen al contenedor
                    //color: Colors.black, // Aplica el color negro como overlay 
                    height: 240,
                    width: double.infinity, 
                  ), 
                  // Degradado superpuesto
                  Container(
                    height: 241.5, 
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          colorCard,
                        ], 
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      // icon 
                      Padding(padding: const EdgeInsets.only(top:12),child: icon),
                      // text : titulo
                      Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,color: Colors.white)),
                      const SizedBox(height: 5),
                      homeController.getButtonTrialActive?trialActivateTextButton:homeController.getTrialActive == false ?Container():trialResumenTextButton,
                      // button moderador : button activacion premiun
                      TextButton(child: const Text('Activar Premium'),onPressed:(){
                        // activar la suscripción premium
                        Get.back();
                        homeController.setIsSubscribedPremium = true ;
                      }),
                      const SizedBox(height: 5),
                      // text : descripción
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Opacity(opacity: 0.7,child: Text(description, textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.w300,color: Colors.white))),
                      ), 
                      
                    ],
                  ),
                ],
              ),  
              // view : caracteristicas de la suscripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical:12),
                child: Container(
                  // contorno delineado
                  decoration: BoxDecoration(
                    border: Border.all(color: colorAccent.withOpacity(0.1),width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.amber.shade200.withOpacity(0.05),
                  ),
                  child: Column( 
                    children: [
                      const SizedBox(height:20),
                      // view :   texto de caracteristicas de la suscripción
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(  
                          gradient: LinearGradient( 
                            colors: [
                              Colors.amber.shade200.withOpacity(0.01),
                              Colors.amber.shade200.withOpacity(0.3),
                              Colors.amber.shade200.withOpacity(0.01),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        // text : caracteristicas de la suscripción
                        child: const Text('CARACTERÍSTICAS PREMIUM',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w200)),
                      ),   
                      const SizedBox(height:5),
                      // LisTile : caracteristicas de la suscripción 'Arqueo de caja'
                      const Opacity(
                        opacity: 0.9,
                        child: ListTile(
                          leading: Icon(Icons.point_of_sale_sharp),
                          title: Text('Arqueo de caja'),
                          subtitle: Opacity(opacity: 0.5,child: Text('Realiza arqueo de caja, controla el saldo de tu caja al final de cada día')), 
                        ),
                      ),
                      const Opacity(opacity: 0.5,child: Divider(indent: 50,endIndent:50,thickness:0.5)),
                      // ListTile : caracteristicas de la suscripción 'Control de inventario' 
                      const Opacity(
                        opacity: 0.9,
                        child: ListTile(
                          leading: Icon(Icons.inventory_outlined ),
                          title: Text('Control de inventario'),
                          subtitle: Opacity(opacity: 0.5,child: Text('Maneje el stock de sus productos')), 
                        ),
                      ),
                      const Opacity(opacity: 0.5,child: Divider(indent: 50,endIndent:50,thickness:0.5)),
                      // ListTile : caracteristicas de la suscripción 'Multi Usuarios'
                      const Opacity(
                        opacity: 0.9,
                        child: ListTile(
                          leading: Icon(Icons.people_outline),
                          title: Text('Multi Usuarios'),
                          subtitle: Opacity(opacity: 0.5,child: Text('Permita que más personas gestionen esta cuenta y con permisos personalizados')), 
                        ),
                      ),
                      const Opacity(opacity: 0.5,child: Divider(indent: 50,endIndent:50,thickness:0.5)),
                      // ListTile : caracteristicas de la suscripción 'Informes y estadísticas'
                      const Opacity(
                        opacity: 0.9,
                        child: ListTile(
                          leading: Icon(Icons.analytics_outlined),
                          title: Text('Informes y estadísticas'),
                          subtitle: Opacity(opacity: 0.5,child: Text('Obtenga datos, informes y estadísticas de sus transacciones y productos')), 
                        ),
                      ),
                      const Opacity(opacity: 0.5,child: Divider(indent: 50,endIndent:50,thickness:0.5)),
                      // ListTile : Version web y para windows proximamente
                      const Opacity(
                        opacity: 0.9,
                        child: ListTile(
                          leading: Icon(Icons.web),
                          title: Text('Versión Web y para Windows (proximamente)'),
                          subtitle: Opacity(opacity: 0.5,child: Text('Accede cualquier navegador web o desde tu computadora')), 
                        ),
                      ),
                    ],
                  ),
                ),
              ), 
              const SizedBox(height:200),
            ],
          ),
          // icon : cerrar dialog
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close,color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          // view : buton para subcribirse a Premium en la app 
          //
          // Positioned : para posicionar el boton en la parte inferior de la pantalla
          Positioned(
            bottom: 0,left: 0,right: 0,
            child: Container(   
              // color : gradient de un color y transparent 
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent,Theme.of(context).scaffoldBackgroundColor ], begin: Alignment.topCenter,end: Alignment.bottomCenter,stops: const [0.0,0.6])),
              // condition : comprobar que 'offerings' esta inicializado
              child: Column(
                children: [
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: homeController.offerings?.current?.availablePackages.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                  
                      // get : obtenemos los productos disponibles
                      List<Package> myProductList =  homeController.offerings!.current!.availablePackages;
                      // card : con un color gradient de tres colores y bordes redondeados
                      return Card(  
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: BorderSide.none),
                        clipBehavior: Clip.antiAlias,
                        // container : aplicamos un gradiente de tres colores
                        child: Container( 
                          decoration:  BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade700.withOpacity(0.5),Colors.green.shade600.withOpacity(0.5),Colors.green.shade400.withOpacity(0.5),],begin: Alignment.topLeft,end: Alignment.bottomRight)),
                          // listTile :  con información del producto y un boton para comprar
                          child: ListTile(
                            tileColor: Colors.green,
                            titleTextStyle: const TextStyle(color: Colors.white),
                            leadingAndTrailingTextStyle:  const TextStyle(color: Colors.white),
                            onTap: ()  async{
                              try {
                                // purchasePackage :  compra el paquete de la lista de productos disponibles 
                                await Purchases.purchasePackage(myProductList[index]).then((customerInfo) { 
                                  EntitlementInfo? entitlement = customerInfo.entitlements.all[entitlementID]; //obtenemos la información de la suscripción
                                  homeController.setIsSubscribedPremium = entitlement?.isActive ?? false; // seteamos el estado de la suscripción
                                  Get.back(); // volvemos a la pantalla anterior
                                }); 
                              }catch (e) { 
                                // ... handle error
                              }
                            },  
                            leading: homeController.getIsSubscribedPremium?null: SizedBox(width: 40,height: 40,child: Lottie.asset('assets/premium_anim.json')),
                            title: Text(homeController.getIsSubscribedPremium?'Ya estás subcripto':myProductList[index].storeProduct.title,maxLines:1), 
                            trailing:homeController.getIsSubscribedPremium?const Icon(Icons.thumb_up,color: Colors.white,): Text('${myProductList[index].storeProduct.currencyCode} ${myProductList[index].storeProduct.priceString}')),
                        ),
                      ); 
                    }, 
                  ),
                  // view : texto de información de la suscripción y textbuton de condiciones de uso y política de privacidad
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0,top: 0.0,left: 20.0,right: 20.0),
                    child: Column(  
                      children: [
                        // text : cancelar de la suscripción
                        const Text('Podrá cancelar la suscripción en cualquier momento en su cuenta de Google Play',textAlign: TextAlign.center,style: TextStyle(fontSize:12,fontWeight: FontWeight.w200)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // text : condiciones de uso
                            TextButton(onPressed: (){}, child: const Text('Condiciones de uso',style: TextStyle(color: Colors.blue,fontSize: 12))),
                            // text : política de privacidad
                            TextButton(onPressed: (){}, child: const Text('Política de privacidad',style: TextStyle(color: Colors.blue,fontSize: 12))),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

