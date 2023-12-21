import 'dart:io'; 
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; 
import 'package:sell/app/presentation/sellPage/controller/sell_controller.dart';
import 'package:sell/app/data/datasource/database_cloud.dart'; 
import '../../../core/routes/app_pages.dart';
import '../../../data/datasource/constant.dart';
import '../../../domain/entities/cashRegister_model.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../domain/entities/user_model.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../auth/controller/login_controller.dart';

class HomeController extends GetxController {

  // var : tutorial para el usuario
  final GlobalKey floatingActionButtonRegisterFlashKeyButton = GlobalKey();
  final GlobalKey itemProductFlashKeyButton = GlobalKey();
  final GlobalKey floatingActionButtonTransacctionRegister = GlobalKey();
  final GlobalKey floatingActionButtonTransacctionConfirm = GlobalKey();
  final GlobalKey floatingActionButtonScanCodeBarKey = GlobalKey();
  final GlobalKey floatingActionButtonSelectedCajaKey = GlobalKey();
  final GlobalKey buttonsPaymenyMode = GlobalKey();
  
  // estado de la conexión a internet
  bool _internetConnection = false;
  set setInternetConnection(bool value) => _internetConnection = value;
  bool get getInternetConnection => _internetConnection;

  // user anonymous
  bool _userAnonymous = false;
  set setUserAnonymous(bool value) => _userAnonymous = value;
  bool get getUserAnonymous => _userAnonymous;

  // Firebase : auth 
  late FirebaseAuth _firebaseAuth;
  set setFirebaseAuth(FirebaseAuth value) => _firebaseAuth = value;
  get getFirebaseAuth => _firebaseAuth;

  // info app
  String _urlPlayStore = '';
  set setUrlPlayStore(String value) => _urlPlayStore = value;
  get getUrlPlayStore {
    return _urlPlayStore == '' ? '' : _urlPlayStore;
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
    //  configure el SDK de RevvenueCat con una ID de usuario de la aplicación personalizada  
    clientRevenueCatID= getProfileAccountSelected.id;  
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
        if(key == entitlementID){ setIsSubscribedPremium = value.isActive; }  
      }); 
    }catch(e){
      // ignore: avoid_print
      print('Error en initIdentityRevenueCat: $e');
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
  
  // provider list
  final RxList<Provider> _providerList = <Provider>[].obs;
  List<Provider> get getProviderList => _providerList;
  set setProviderList(List<Provider> value) {
    _providerList.value = value;
  }

  // cash register  //
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
    );
  List<CashRegister> listCashRegister = [];
  void loadCashRegisters() {
    // description : carga las cajas registradoras activas de la cuenta seleccionada
    // firebase : create 'Stream' de la  collecion de cajas registradoras
    Stream<QuerySnapshot<Map<String, dynamic>>> db = Database.readCashRegistersStream(idAccount: getProfileAccountSelected.id);
    db.listen((event) {
      // default values
      listCashRegister.clear(); // limpiamos la lista de cajas
      // condition : si hay cajas registradoras
      if (event.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in event.docs) { 
          listCashRegister.add(CashRegister.fromMap(element.data()));
        }
        upgradeCashRegister(); // actualizamos el arqueo de caja actual activo
      }
    });
  }

  upgradeCashRegister({String id = ''}) async {
    // description : si se selecciono una, actualiza el arqueo de caja actual 
    // condition : si no se actualiza el arqueo de caja actual verificamos si hay un arqueo de caja seleccionada 
    if (id == '') {
      id = GetStorage().read('cashRegisterID') ?? '';
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
      Mark mark = Mark(id: item.idMark, name: item.nameMark,creation: Timestamp.now(),upgrade: Timestamp.now());
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
    _productsOutstandingList.add(item);
  }

  //  authentication account profile
  late User _userFirebaseAuth;
  User get getUserAuth => _userFirebaseAuth;
  set setUserAuth(User user) => _userFirebaseAuth = user;

  //  perfil de usuario administrador actual de la cuenta
  UserModel _adminUser = UserModel(creation: Timestamp.now(),lastUpdate: Timestamp.now());
  UserModel get getProfileAdminUser => _adminUser;
  set setProfileAdminUser(UserModel user) {
    _adminUser = user;  
    update();
  }

  // profile account selected
  ProfileAccountModel _accountProfileSelected = ProfileAccountModel(creation: Timestamp.now());
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
    String idAccountAthentication = getUserAuth.uid;
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

  @override
  void onInit() async {
    super.onInit(); 
  
    // inicialización de la variable
    setFirebaseAuth = FirebaseAuth.instance; // inicializamos la autenticación de firebase
    isAppUpdated(); // verificamos si la app esta actualizada 
    
    // condition : comprobamos si el usuario esta autenticado o es un usuario anonimo
    if (getFirebaseAuth.currentUser.isAnonymous) {
      // obtenemos datos de prueba para que el usaurio pueda probar la app sin autenticarse
      readAccountsInviteData();
    } else {
      // GetX : obtenemos por parametro los datos de la cuenta de atentificación
      Map arguments = Get.arguments;
      // verificamos y obtenemos los datos pasados por parametro
      setUserAuth = arguments['currentUser'];
      // obtenemos el id de la cuenta seleccionada si es que existe 
      readAccountsData(idAccount: arguments['idAccount']);
    }
  }

  @override
  void onClose() { 
    // ...
    super.onClose(); 
  }


  // FUNCTIONS
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
    ProductCatalogue product = ProductCatalogue(
        creation: Timestamp.now(),
        upgrade: Timestamp.now(),
        documentCreation: Timestamp.now(),
        documentUpgrade: Timestamp.now());
    for (final element in getCataloProducts) {
      if (element.id == id) {
        product = element;
      }
    }
    return product;
  }

  // login
  void login() async {
    // Inicio de sesión con Google
    // Primero comprobamos que el usuario acepto los términos de uso de servicios y que a leído las politicas de privacidad

    // FirebaseAuth and GoogleSignIn instances
    late final GoogleSignIn googleSign = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    // set state load
    CustomFullScreenDialog.showDialog();

    // signIn : Inicia la secuencia de inicio de sesión de Google.
    GoogleSignInAccount? googleSignInAccount = await googleSign.signIn();
    // condition : Si googleSignInAccount es nulo, significa que el usuario no ha iniciado sesión.
    if (googleSignInAccount == null) {
      CustomFullScreenDialog.cancelDialog();
    } else {
      // Obtenga los detalles de autenticación de la solicitud
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      // Crea una nueva credencial de OAuth genérica.
      OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);
      // Una vez que haya iniciado sesión, devuelva el UserCredential
      await firebaseAuth.signInWithCredential(oAuthCredential);
      // navigation : navegamos a la pantalla principal
      Get.offAllNamed(Routes.HOME, arguments: {
        'currentUser': firebaseAuth.currentUser,
        'idAccount': ''
      });
      // finalizamos el diálogo alerta
      CustomFullScreenDialog.cancelDialog();
    }
  }

// cerrar sesion de firebase
  Future<void> signOutFirebase() async {
    // visualizamos un diálogo alerta
    CustomFullScreenDialog.showDialog();
    // FirebaseAuth and GoogleSignIn instances
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    // signOut : Cierra la sesión del usuario actual.
    await firebaseAuth.signOut();
    // navigation : navegamos a la pantalla principal
    Get.offAllNamed(Routes.LOGIN);
    // finalizamos el diálogo alerta
    CustomFullScreenDialog.cancelDialog();
  }

// cerrar sesión
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

  // FUCTION : cerrar sesión de google y firebase
  Future<void> signOutGoogleAndFirebase() async {
    // intancias de FirebaseAuth para proceder a cerrar sesión
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    // cerramos sesión
    try {
      // 1. Cerrar sesión de Google
      await googleSignIn.signOut();

      // 2. Cerrar sesión de Firebase
      await auth.signOut();

      // 3. Revocar el token de acceso actual
      await googleSignIn.disconnect();

      // Eliminar los datos de la memoria del dispositivo
      await const FlutterSecureStorage().deleteAll();
    } catch (error) {
      print('#### error : signOutGoogle');
    }
  }

  //
  // QUERIES FIRESTORE
  //

  Future<void> isAppUpdated() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);
      final docSnapshot = await Database.readVersionApp();
      final firestoreVersion = docSnapshot.data()!['versionApp'] as int;
      //urlPlayStore
      setUrlPlayStore = docSnapshot.data()!['urlPlayStore'] as String;
      setUpdateApp = firestoreVersion > currentVersion;
    } catch (e) {
      setUpdateApp = false;
    }
  }

  void readAccountsInviteData() {
    //default values
    setUserAnonymous = true;
    setCatalogueCategoryList = []; // lista de categorias del catálogo
    setCatalogueProducts = [
      ProductCatalogue(
          creation: Timestamp.now(),
          upgrade: Timestamp.now(),
          documentCreation: Timestamp.now(),
          documentUpgrade: Timestamp.now(),
          id: '078943658457643',
          code: '078943658457643',
          description: 'Agua Mineral 1L',
          salePrice: 170,
          purchasePrice: 99,
          favorite: true,
          sales: 4,
          stock: true,
          quantityStock: 22),
      ProductCatalogue(
          creation: Timestamp.now(),
          upgrade: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          documentCreation: Timestamp.now(),
          documentUpgrade: Timestamp.now(),
          id: '69696435423878',
          code: '69696435423878',
          description: 'Alfajor De Chocolate Con Dulce De Leche 110 g',
          salePrice: 60,
          purchasePrice: 35,
          sales: 1,
          stock: true,
          quantityStock: 47),
      ProductCatalogue(
          creation: Timestamp.now(),
          upgrade: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 1))),
          documentCreation: Timestamp.now(),
          documentUpgrade: Timestamp.now(),
          id: '98679678967969',
          code: '98679678967969',
          description: 'Galletitas Dulces 200 g',
          salePrice: 140,
          purchasePrice: 80,
          sales: 7,
          stock: true,
          quantityStock: 18,
          ),
    ]; // lista de productos del catálogo
    setProductsOutstandingList = getCataloProducts.toList(); // lista de productos destacados
    setProfileAccountSelected = ProfileAccountModel(creation: Timestamp.now(),name: 'Mi negocio'); // datos de la cuenta
    setManagedAccountsList = []; // lista de cuentas gestionadas
    setProfileAdminUser = UserModel(
        superAdmin: true,
        admin: true,
        email: 'userInvite@correo.com',
        creation: Timestamp.now(),
        lastUpdate: Timestamp.now(),
        ); // datos del usuario
    setAdminsUsersList = []; // lista de usuarios administradores
  }

  void readAccountsData({required String idAccount}) {

    //default values'
    setUserAnonymous = false;
    setCatalogueCategoryList = [];
    setCatalogueProducts = [];
    setProductsOutstandingList = [];
    setProfileAccountSelected = ProfileAccountModel(creation: Timestamp.now());
    getProfileAccountSelected.id = idAccount; // asignamos el id de la cuenta

    // obtenemos las cuentas asociada a este email
    readUserAccountsList(email: getUserAuth.email ?? '');
    // obtenemos los datos de la cuenta
    if (idAccount!= '') {
      // firebase : obtenemos los datos de la cuenta
      Database.readProfileAccountModelFuture(idAccount).then((value) {
        // condition : ¿El documento existe?
        if (value.exists) {
          //get profile account
          setProfileAccountSelected = ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          // subcription premium  : inicializamos la identidad de revenue cat
          initIdentityRevenueCat(); // inicializamos la identidad de revenue cat
          // load
          loadCashRegisters(); // obtenemos las cajas registradoras activas
          readProductsCatalogue(idAccount: idAccount); // obtenemos los productos del catálogo
          readListCategoryListFuture(idAccount: idAccount); // obtenemos las categorias creadas por el usuario
          readProvidersListFuture(idAccount: idAccount); // obtenemos los proveedores creados por el usuario
          readDataAdminUser( email: getUserAuth.email ?? '', idAccount: idAccount); // obtenemos los datos del usuario administrador de la cuenta
          readAdminsUsers(idAccount: idAccount);  // obtenemos los usuarios administradores de la cuenta
        }
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
  void readProvidersListFuture({required String idAccount}) {
    // obtenemos la categorias creadas por el usuario
    Database.readProvidersQueryStream(idAccount: idAccount).listen((event) {
      List<Provider> list = [];
      for (var element in event.docs) {
        list.add(Provider.fromMap(element.data()));
      }
      setProviderList = list;
    });
  }

  getTheBestSellingProducts({required String idAccount}) {
    // obtenemos los productos más vendidos
    // Firestore get
    Database.readSalesProduct(idAccount: idAccount, limit: 100).listen((value) {
      // values
      List<ProductCatalogue> list = [];
      //  obtenemos todos los productos ordenas con más ventas
      for (var element in value.docs) {
        list.add(ProductCatalogue.fromMap(element.data()));
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
        SalesController salesController = Get.find();
        salesController.update();
      } catch (_) {}
    });
  }

  void readProductsCatalogue({required String idAccount}) {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    Stream<QuerySnapshot<Map<String, dynamic>>> streamSubscription = Database.readProductsCatalogueStream(id: idAccount);
    streamSubscription.listen((value) {
      //  values
      List<ProductCatalogue> list = [];

      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          list.add(ProductCatalogue.fromMap(element.data()));
        }
      }
      //  obtenemos los productos más vendidos
      getTheBestSellingProducts(idAccount: idAccount);
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
      // ordenamos la lista por fecha de actualizacion
      list.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
      //  set values
      setAdminsUsersList = list;
    }).onError((error) {
      // error
    });
  }

  void readDataAdminUser({required String idAccount, required String email}) {
    // obtenemos los datos de los permisos del usuario en la cuenta
    Database.readFutureAdminUser(idAccount: idAccount, email: email).then((value) {
      if (value.exists) {
        // set : datos de los permisos del usuario en la cuenta
        setProfileAdminUser = UserModel.fromDocumentSnapshot(documentSnapshot: value); 
      }
    });
  }

  void readUserAccountsList({required String email}) {
    // firebase : obtenemos la lista de cuentas del usuario
    Database.refFirestoreUserAccountsList(email: email).get().then((value) {
      //  recorre la lista de cuentas
      for (var element in value.docs) {
        // condition : si el id de la cuenta es diferente de vacio para evitar errores de consulta inexistentes
        if (element.get('id') != '') {
          // firebase : obtenemos los datos de la cuenta
          Database.readProfileAccountModelFuture(element.get('id')).then((value) {
            // obtenemos los perfiles de las cuentas administradas
            ProfileAccountModel profileAccountModel = ProfileAccountModel.fromDocumentSnapshot(documentSnapshot:value);
            // set
            addManagedAccountsList = profileAccountModel; 
          });
        }
      }
      // actualizamos el estado de la lista de cuentas administradas
      setLoadedManagedAccountsList = true;
    }).onError((error, stackTrace){
      setLoadedManagedAccountsList = true;
    }).catchError((onError) {
      // error
      setLoadedManagedAccountsList = true;
    });
  }

  Future<void> categoryDelete({required String idCategory}) async =>
      await Database.refFirestoreCategory(
              idAccount: getProfileAccountSelected.id)
          .doc(idCategory)
          .delete();
  Future<void> categoryUpdate({required Category categoria}) async {
    // refactorizamos el nombre de la cátegoria
    String name = categoria.name.substring(0, 1).toUpperCase() +
        categoria.name.substring(1);
    categoria.name = name;
    // ref
    var documentReferencer =
        Database.refFirestoreCategory(idAccount: getProfileAccountSelected.id)
            .doc(categoria.id);
    // Actualizamos los datos
    documentReferencer.set(
        Map<String, dynamic>.from(categoria.toJson()), SetOptions(merge: true));
  }

  void addProductToCatalogue({required ProductCatalogue product,required isProductNew}) async {
    // obj : se obtiene los datos para registrar del precio al publico del producto en una colección publica de la db
    ProductPrice precio = ProductPrice(id: getProfileAccountSelected.id,idAccount: getProfileAccountSelected.id,imageAccount: getProfileAccountSelected.image,nameAccount: getProfileAccountSelected.name,price: product.salePrice,currencySign: product.currencySign,province: getProfileAccountSelected.province,town: getProfileAccountSelected.town,time: Timestamp.fromDate(DateTime.now()));
    // condition : si el producto es nuevo se le asigna los valores de creación
    if(isProductNew){
      // el producto no existe 
      product.creation = Timestamp.fromDate(DateTime.now()); // fecha de creación del producto
      product.followers++; // incrementamos el contador de los seguidores del producto publico 
    }else{
      // el producto ya existe
      //
      // firebase : acutalizamos los seguidores del producto publico 
      Database.refFirestoreProductPublic().doc(product.id).update({'followers': FieldValue.increment(1)});
    }
    // set : fecha de actualización del producto
    product.upgrade = Timestamp.fromDate(DateTime.now()); 
    
    // Firebase : se crea un registro de precio al publico del producto en una colección publica de la db
    Database.refFirestoreRegisterPrice(idProducto: product.id, isoPAis: 'ARG').doc(precio.id).set(precio.toJson());
    
    // Firebase : se actualiza el documento del producto del cátalogo
    Database.refFirestoreCatalogueProduct(idAccount: getProfileAccountSelected.id).doc(product.id).set(product.toJson());
    
    // condition : si el producto no esta verificado se procede a crear un documento en la colección publica
    if (product.verified == false) {
      addProductToCollectionPublic(isNew: isProductNew, product: product.convertProductoDefault());
    }
  }

  void addProductToCollectionPublic({required bool isNew, required Product product}) {
    // description : esta función procede a guardar el documento de una colleción publica
 

    // condition : si el producto es nuevo se le asigna los valores de creación
    if (isNew && product.verified == false) {
      // datos de creación por primera vez
      product.idAccount = getProfileAccountSelected.id;
      product.idUserCreation = getProfileAdminUser.email;
      product.creation = Timestamp.fromDate(DateTime.now());
    }
    //  set : marca de tiempo que se actualizo el documenti
    product.upgrade = Timestamp.fromDate(DateTime.now());
    //  set : id del usuario que actualizo el documento
    product.idUserUpgrade = getProfileAdminUser.email;

    // dondition : si el producto es nuevo se crea un documento, si no se actualiza
    if (isNew && product.verified == false) { 
      // firebase : se crea un documento en la colección publica
      Database.refFirestoreProductPublic().doc(product.id).set(product.toJson());
    } else {
      // firebase : se actualiza un documento en la colección publica
      Database.refFirestoreProductPublic().doc(product.id).update(product.toJson());
    }
  }

  // void : funcion para cambiar de cuenta en la app
  void accountChange({required String idAccount}) async {
    // save key/values Storage
    await GetStorage().write('idAccount', idAccount);
    // navegar hacia otra pantalla
    Get.offAllNamed(Routes.HOME,arguments: {'currentUser': getUserAuth, 'idAccount': idAccount} );
  }

  // BottomSheet - Getx
  void showModalBottomSheetSelectAccount() {
    // muestra las cuentas en el que el usuario tiene accesos

    // widgets
    Widget widget = !checkAccountExistence
      ? WidgetButtonListTile().buttonListTileCrearCuenta()
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 20),
            child: Text('Tienes acceso a estas cuentas'),
          ),
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
              // button : cerrar sesion
              ListTile(
                title: const Text('Cerrar sesión'),
                subtitle: Text(getUserAuth.email.toString(),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                onTap: showDialogCerrarSesion,
              ),
              ComponentApp().divider(),
              widget,
            ],
          ),
        ],
      ),
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }

  void showModalBottomSheetSubcription({String id = 'premium'}) {
    // bottomSheet : muestre la hoja inferior modal de getx
    Get.bottomSheet(
      SizedBox(height: 600, child: WidgetBottomSheet(id: id)),
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
}

class WidgetBottomSheet extends StatefulWidget {
  late final String id;
  // ignore: prefer_const_constructors_in_immutables
  WidgetBottomSheet({Key? key, required this.id}) : super(key: key);

  @override
  State<WidgetBottomSheet> createState() => _WidgetBottomSheetState();
}

class _WidgetBottomSheetState extends State<WidgetBottomSheet> {
  // others controllers
  final HomeController homeController = Get.find();

  // values 
  double sizePremiumLogo = 75.0;
  Widget icon = Container();
  String title = 'Premium';
  String description = ''; 

  // functions 
  void setData({required String id}) {
    switch (id) {
      case 'premium':
        title = 'Premium';
        description = 'Funcionalidades especiales para profesionalizar tu negocio';
        icon =  Icon(Icons.star_rounded,size: sizePremiumLogo,color: Colors.amber); 
        break;
      case 'arching':
        title = 'Arqueo de caja';
        description = 'Realiza arqueo de caja, controla el saldo de tu caja al final de cada día';
        icon = Padding(
            padding: const EdgeInsets.only(right: 5),
            // icon : icono de caja registradora 
            child: Icon(Icons.point_of_sale_rounded,size: sizePremiumLogo,color: Colors.amber));
        break;
      case 'stock':
        title = 'Control de Inventario';
        description ='Maneje el stock de sus productos, disfruta además de otras características especiales';
        icon = Padding(padding:const EdgeInsets.only(right: 5),child: Icon(Icons.inventory_rounded,size: sizePremiumLogo,color: Colors.amber)); 
        break;
      case 'analytic':
        title = 'Informes y Estadísticas';
        description ='Obtenga datos, rendimiento de sus transacciones y otras estadísticas importantes';
        icon = Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(Icons.analytics_outlined,size: sizePremiumLogo,color: Colors.amber)); 
        break;
      case 'multiuser':
        title = 'Multiusuario';
        description = 'Permita que más personas gestionen esta cuenta y con permisos personalizados. Además también tenes otras características';
        icon = Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(Icons.people_outline,size: sizePremiumLogo,color: Colors.amber));
        break;
      default:
        title = '';
        description =
            'Funcionalidades especiales para profesionalizar tu negocio';
        icon = Container(); 
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
    setData(id: widget.id);
 
 

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: colorCard,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Stack(  
        children: [
          // view : contenido de la suscripción desplazable
          ListView( 
            // efecto rebote
            physics: const BouncingScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  const SizedBox(height: 8),
                  // icon 
                  Padding(padding: const EdgeInsets.only(top:12),child: icon),
                  // text : titulo
                  Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  // text : descripción
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Opacity(opacity: 0.7,child: Text(description, textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.w300))),
                  ), 
                  
                ],
              ),  
              // view : caracteristicas de la suscripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column( 
                  children: [
                    const SizedBox(height:12),
                    // view :   texto de caracteristicas de la suscripción
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(  
                        gradient: LinearGradient( 
                          colors: [
                            colorCard,
                            Colors.amber.shade200.withOpacity(0.3),
                            colorCard,
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
              const SizedBox(height:200),
            ],
          ),
          // view : buton para subcribirse a Premium en la app 
          //
          // Positioned : para posicionar el boton en la parte inferior de la pantalla
          Positioned(
            bottom: 0,left: 0,right: 0,
            child: Container(   
              // color : gradient de un color y transparent 
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent,Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),Theme.of(context).scaffoldBackgroundColor], begin: Alignment.topCenter,end: Alignment.bottomCenter),),
              // condition : comprobar que 'offerings' esta inicializado
              child:  true ?// homeController.offerings==null? 
              TextButton(onPressed:(){
                homeController.setIsSubscribedPremium = true;
                }, 
                child: const Text('Subcribirce a Premium'))
                :Column(
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
                        margin: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
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
                            title: Text(homeController.getIsSubscribedPremium?'Ya estás subcripto':myProductList[index].storeProduct.title,maxLines:1), 
                            trailing:homeController.getIsSubscribedPremium?const Icon(Icons.thumb_up,color: Colors.white,): Text('${myProductList[index].storeProduct.currencyCode} ${myProductList[index].storeProduct.priceString}')),
                        ),
                      ); 
                    }, 
                  ),
                  // view : texto de información de la suscripción y textbuton de condiciones de uso y política de privacidad
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0,top: 0.0,left: 20.0,right: 20.0),
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





