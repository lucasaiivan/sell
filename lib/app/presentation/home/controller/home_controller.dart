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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
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
  final List<TargetFocus> targets = List<TargetFocus>.empty(growable: true);
  late final TutorialCoachMark tutorialCoachMark;

  // user anonymous
  bool _userAnonymous = false;
  set setUserAnonymous(bool value) => _userAnonymous = value;
  bool get getUserAnonymous => _userAnonymous;

  // Firebase
  late FirebaseAuth _firebaseAuth;
  set setFirebaseAuth(FirebaseAuth value) => _firebaseAuth = value;
  get getFirebaseAuth => _firebaseAuth;

  // info app
  String _urlPlayStore = '';
  set setUrlPlayStore(String value) => _urlPlayStore = value;
  get getUrlPlayStore {
    return _urlPlayStore == '' ? '' : _urlPlayStore;
  }

  bool _updateApp = false;
  set setUpdateApp(bool value) {
    _updateApp = value;
    update();
  }

  bool get getUpdateApp => _updateApp;

  // buildContext : // buildContext : obtenemos el context de la vista
  late BuildContext _buildContext;
  set setBuildContext(BuildContext context) => _buildContext = context;
  BuildContext get getBuildContext => _buildContext;

  // brillo de la pantalla
  bool _darkMode = false;
  set setDarkMode(bool value) => _darkMode = value;
  bool get getDarkMode => _darkMode;

  // Guide user : Ventas
  bool salesUserGuideVisibility = false;
  void getSalesUserGuideVisibility() {
    // obtenemos la visibilidad de la guía del usuario de ventas
    salesUserGuideVisibility =
        GetStorage().read('salesUserGuideVisibility') ?? true;
    update();
  }

  void disableSalesUserGuide() async {
    // Deshabilitar la guía del usuario de ventas
    salesUserGuideVisibility = false;
    await GetStorage()
        .write('salesUserGuideVisibility', salesUserGuideVisibility);
  }

  // Guide user : Catalogue
  bool catalogUserHuideVisibility = false;
  get getCatalogUserHuideVisibility => catalogUserHuideVisibility;
  void getTheVisibilityOfTheCatalogueUserGuide() {
    // obtenemos la visibilidad de la guía del usuario del catálogo
    catalogUserHuideVisibility =
        GetStorage().read('catalogUserHuideVisibility') ?? true;
    update();
  }

  void disableCatalogUserGuide() async {
    // Deshabilitar la guía del usuario del catálogo
    catalogUserHuideVisibility = false;
    await GetStorage()
        .write('catalogUserHuideVisibility', catalogUserHuideVisibility);
  }

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
  }

  // cash register  //
  CashRegister cashRegister = CashRegister(
      id: '',
      sales: 0,
      description: '',
      opening: DateTime.now(),
      closure: DateTime.now(),
      billing: 0.0,
      cashInFlow: 0.0,
      cashOutFlow: 0.0,
      expectedBalance: 0.0,
      balance: 0.0,
      cashInFlowList: [],
      cashOutFlowList: [],
      initialCash: 0.0);
  List<CashRegister> listCashRegister = [];
  void loadCashRegisters() {
    // firebase : create 'Stream' de la  collecion de cajas registradoras
    Stream<QuerySnapshot<Map<String, dynamic>>> db =
        Database.readCashRegistersStream(
            idAccount: getProfileAccountSelected.id);
    db.listen((event) {
      listCashRegister.clear(); // limpiamos la lista de cajas

      if (event.docs.isNotEmpty) {
        // añadimos las cajas disponibles
        for (var element in event.docs) {
          listCashRegister.add(CashRegister.fromMap(element.data()));
        }
        upgradeCashRegister();
      }
    });
  }

  upgradeCashRegister({String id = ''}) async {
    // description : busca un coincidencia con la id de la caja seleccionada que se guardo para que persista en el dispositivo en la lista de cajas 'getListCashRegister'
    // y la actualiza con la caja actual
    if (id == '') {
      id = GetStorage().read('cashRegisterID') ?? '';
    }
    for (CashRegister item in listCashRegister) {
      if (item.id == id) {
        cashRegister = item;
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

  // lista de porductos seleccionados por el usuario para la venta
  List listProductsSelected = [];

  // list products más vendidos
  final RxList<ProductCatalogue> _productsOutstandingList = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getProductsOutstandingList => _productsOutstandingList;
  set setProductsOutstandingList(List<ProductCatalogue> list) {
    _productsOutstandingList.value = list;
  }

  addToListProductSelecteds({required ProductCatalogue item}) {
    _productsOutstandingList.add(item);
  }

  //  authentication account profile
  late User _userFirebaseAuth;
  User get getUserAuth => _userFirebaseAuth;
  set setUserAuth(User user) => _userFirebaseAuth = user;

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
    setFirebaseAuth = FirebaseAuth.instance;
    isAppUpdated(); // verificamos si la app esta actualizada
    getSalesUserGuideVisibility(); // obtenemos la visibilidad de la guía del usuario de ventas
    getTheVisibilityOfTheCatalogueUserGuide(); // obtenemos la visibilidad de la guía del usuario del catálogo

    // condition : si el usuario es anonimo, se porporcionara algunos datos para que pueda probar la app sin autenticarse
    if (getFirebaseAuth.currentUser!.isAnonymous) {
      readAccountsInviteData();
    } else {
      // obtenemos por parametro los datos de la cuenta de atentificación
      Map map = Get.arguments as Map;
      // verificamos y obtenemos los datos pasados por parametro
      setUserAuth = map['currentUser'];
      // obtenemos el id de la cuenta seleccionada si es que existe
      map.containsKey('idAccount')
          ? readAccountsData(idAccount: map['idAccount'])
          : readAccountsData(idAccount: '');
    }
  }

  @override
  void onClose() {}

  // TUTORIAL PARA EL USUARIO
  TargetFocus get buttonAddItemFlashTargetFocus {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);
    const TextStyle descriptionTextStyle =
        TextStyle(color: Colors.white, fontSize: 18.0);

    return TargetFocus(
        identify: "registro rapido",
        keyTarget: floatingActionButtonRegisterFlashKeyButton,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Registra una venta rápida", style: titleSTexttyle),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                        "Puedes registrar un producto rapido solo con el precio y opcionalmente una descripción",
                        style: descriptionTextStyle),
                  ),
                ],
              ))
        ]);
  }

  TargetFocus get viewTicketTargetFocus {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);
    const TextStyle descriptionTextStyle =
        TextStyle(color: Colors.white, fontSize: 18.0);

    return TargetFocus(
        identify: "ticket",
        keyTarget: floatingActionButtonRegisterFlashKeyButton,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("vista previa del ticket", style: titleSTexttyle),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                        "Puedes registrar un producto rapido solo con el precio y opcionalmente una descripción",
                        style: descriptionTextStyle),
                  ),
                ],
              ))
        ]);
  }

  TargetFocus get buttonAddProductTargetFocus {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);
    const TextStyle descriptionTextStyle =
        TextStyle(color: Colors.white, fontSize: 18.0);

    return TargetFocus(
        identify: "agregar producto",
        keyTarget: itemProductFlashKeyButton,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              align: ContentAlign.bottom,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Agrega productos rápidamente", style: titleSTexttyle),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                        "En esta sección aparecen tus productos favoritos y los que allas vendido",
                        style: descriptionTextStyle),
                  ),
                ],
              ))
        ]);
  }

  TargetFocus get buttonRegisterTransactionTargetFocus {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);
    const TextStyle descriptionTextStyle =
        TextStyle(color: Colors.white, fontSize: 18.0);

    return TargetFocus(
        identify: "Procede a registrar la venta",
        keyTarget: floatingActionButtonTransacctionRegister,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 100.0),
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Registra la venta", style: titleSTexttyle),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text("Procede a registrar tu primera transacción",
                        style: descriptionTextStyle),
                  ),
                ],
              ))
        ]);
  }

  TargetFocus get buttonsOptionsPaymentMethodTargetFocus {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);

    return TargetFocus(
        identify: "metodo de pago",
        keyTarget: buttonsPaymenyMode,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 130.0),
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Elige el método de pago y listo",
                      style: titleSTexttyle),
                  //Padding(padding: EdgeInsets.only(top: 10.0),child: Text("Procede a registrar tu primera transacción",style: TextStyle(color: Colors.white),),),
                ],
              ))
        ]);
  }

  TargetFocus get buttonsConfirmTransactionTargetFocus {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);
    const TextStyle descriptionTextStyle =
        TextStyle(color: Colors.white, fontSize: 18.0);

    return TargetFocus(
        identify: "confirmar venta",
        keyTarget: floatingActionButtonTransacctionConfirm,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Confirma la transacción", style: titleSTexttyle),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                        "Finalmente terminar de concretar tu primera venta",
                        style: descriptionTextStyle),
                  ),
                ],
              ))
        ]);
  }

  TargetFocus get buttonsScanCodeBarTargetFocusGuideUX {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);

    return TargetFocus(
        identify: "button scan bar",
        keyTarget: floatingActionButtonScanCodeBarKey,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 100.0),
              align: ContentAlign.top,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Escanea el código de barra de un producto",
                      style: titleSTexttyle),
                ],
              ))
        ]);
  }

  TargetFocus get buttonsNumCajaTargetFocusGuideUX {
    // style
    const TextStyle titleSTexttyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25.0);

    return TargetFocus(
        identify: "numero de caja",
        keyTarget: floatingActionButtonSelectedCajaKey,
        contents: [
          TargetContent(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, top: 100.0),
              align: ContentAlign.bottom,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Elige la Caja en la que vas a vender",
                      style: titleSTexttyle),
                ],
              ))
        ]);
  }

  void showTutorial({required List<TargetFocus> targetFocus,
      required void Function() next,
      AlignmentGeometry alignSkip = Alignment.bottomRight,
      String textSkip = "Salir"}) async {
    // delay : para que se muestre el tutorial despues de que se muestre la pantalla
    await Future.delayed(const Duration(milliseconds: 1300));

    // condition : comprueba si el usaurio inicio por primera vez la app
    // si es asi, se mostrara el tutorial
    //if (salesUserGuideVisibility==true || getUserAnonymous   ){
    if (textSkip=='') {
      // ignore: use_build_context_synchronously
      TutorialCoachMark(
        targets: targetFocus,
        colorShadow: Colors.black12.withOpacity(0.1),
        textSkip: "Salir",
        alignSkip: alignSkip,
        textStyleSkip: const TextStyle(color: Colors.white, fontSize: 18.0),
        onClickTarget: (target) {
          // onClickTarget : cuando se hace click en el target sin obtener la posicion del click en el target

          next();

          // ignore: avoid_print
          print(target);
        },
        onClickTargetWithTapPosition: (target, tapDetails) {
          // onClickTargetWithTapPosition : cuando se hace click en el target y se obtiene la posicion del click en el target
          // ignore: avoid_print
          print("target: $target");
          // ignore: avoid_print
          print(
              "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
        },
        onClickOverlay: (target) {
          // onClickOverlay : cuando se hace click en el overlay (background)
          // ignore: avoid_print
          print(target);
        },
        onSkip: () {
          // onSkip : cuando se hace click en el boton de skip
          // ignore: avoid_print
          print("skip");
        },
        onFinish: () {
          // onFinish : cuando se termina de mostrar todos los targets
          // ignore: avoid_print
          print("finish");
        },
      ).show(context: getBuildContext);
    }
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
          quantityStock: 18),
    ]; // lista de productos del catálogo
    setProductsOutstandingList = getCataloProducts.toList(); // lista de productos destacados
    setProfileAccountSelected = ProfileAccountModel(creation: Timestamp.now(),name: 'Mi negocio'); // datos de la cuenta
    setManagedAccountsList = []; // lista de cuentas gestionadas
    setProfileAdminUser = UserModel(
        superAdmin: true,
        admin: true,
        email: 'userInvite@correo.com'); // datos del usuario
    setAdminsUsersList = []; // lista de usuarios administradores
  }

  void readAccountsData({required String idAccount}) {
    //default values'
    setUserAnonymous = false;
    setCatalogueCategoryList = [];
    setCatalogueProducts = [];
    setProductsOutstandingList = [];
    setProfileAccountSelected = ProfileAccountModel(creation: Timestamp.now());
    getProfileAccountSelected.id = idAccount;

    // obtenemos las cuentas asociada a este email
    readUserAccountsList(email: getUserAuth.email ?? '');
    // obtenemos los datos de la cuenta
    if (idAccount != '') {
      Database.readProfileAccountModelFuture(idAccount).then((value) {
        // ¿El documento existe?
        if (value.exists) {
          //get profile account
          setProfileAccountSelected =
              ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          // load
          loadCashRegisters();
          readDataAdminUser(
              email: getUserAuth.email ?? '', idAccount: idAccount);
          readProductsCatalogue(idAccount: idAccount);
          readAdminsUsers(idAccount: idAccount);
          readListCategoryListFuture(idAccount: idAccount);
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
        SalesController salesController = Get.find();
        salesController.update();
      } catch (_) {}
    });
  }

  void readProductsCatalogue({required String idAccount}) {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    Stream<QuerySnapshot<Map<String, dynamic>>> streamSubscription =
        Database.readProductsCatalogueStream(id: idAccount);
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
    // firebase : obtenemos la lista de cuentas del usuario
    Database.refFirestoreUserAccountsList(email: email).get().then((value) {
      //  recorre la lista de cuentas
      for (var element in value.docs) {
        // condition : si el id de la cuenta es diferente de vacio para evitar errores de consulta inexistentes
        if (element.get('id') != '') {
          // firebase : obtenemos los datos de la cuenta
          Database.readProfileAccountModelFuture(element.get('id')).then((value) {
            // obtenemos los perfiles de las cuentas administradas
            ProfileAccountModel profileAccountModel = ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
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

  void addProductToCatalogue({required ProductCatalogue product}) async {
    // values : se obtiene los datos para registrar del precio al publico del producto en una colección publica de la db
    ProductPrice precio = ProductPrice(
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

    // Firebase set : se crea un documento con la referencia del precio del producto
    Database.refFirestoreRegisterPrice(idProducto: product.id, isoPAis: 'ARG')
        .doc(precio.id)
        .set(precio.toJson());
    // Firebase set : se actualiza el documento del producto del cátalogo
    Database.refFirestoreCatalogueProduct(
            idAccount: getProfileAccountSelected.id)
        .doc(product.id)
        .set(product.toJson())
        .whenComplete(() async {})
        .onError((error, stackTrace) => null)
        .catchError((_) => null);
    // condition : si el producto no esta verificado se procede a crear un documento en la colección publica
    if (product.verified == false) {
      addProductToCollectionPublic(
          isNew: true, product: product.convertProductoDefault());
    }
  }

  void addProductToCollectionPublic(
      {required bool isNew, required Product product}) {
    // esta función procede a guardar el documento de una colleción publica

    // var
    bool isNew = product.idUserCreation == '';

    // condition : si el producto es nuevo se le asigna los valores de creación
    if (isNew) {
      product.idAccount = getProfileAccountSelected.id;
      product.idUserCreation = getProfileAdminUser.email;
      product.creation = Timestamp.fromDate(DateTime.now());
    }
    //  set : marca de tiempo que se actualizo el documenti
    product.upgrade = Timestamp.fromDate(DateTime.now());
    //  set : id del usuario que actualizo el documento
    product.idUserUpgrade = getProfileAdminUser.email;

    // dondition : si el producto es nuevo se crea un documento, si no se actualiza
    if (isNew) {
      Database.refFirestoreProductPublic()
          .doc(product.id)
          .set(product.toJson());
    } else {
      Database.refFirestoreProductPublic()
          .doc(product.id)
          .update(product.toJson());
    }
  }

  // Cambiar de cuenta
  void accountChange({required String idAccount}) {
    // save key/values Storage
    GetStorage().write('idAccount', idAccount);
    // navegar hacia otra pantalla
    Get.offAllNamed(Routes.HOME,
        arguments: {'currentUser': getUserAuth, 'idAccount': idAccount});
  }

  // BottomSheet - Getx
  void showModalBottomSheetSelectAccount() {
    // muestra las cuentas en el que el usuario tiene accesos
    Widget widget = !checkAccountExistence
        ? WidgetButtonListTile().buttonListTileCrearCuenta()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 20),
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
              // cerrar sesion
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
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
  late double sizePremiumLogo = 16.0;
  Widget icon = Container();
  String title = 'Premium';
  String description = ''; 

  // functions 
  void setData({required String id}) {
    switch (id) {
      case 'premium':
        title = 'Premium';
        description =
            'Funcionalidades especiales para profesionalizar tu negocio';
        icon = const Icon(Icons.star_rounded,
            size: 75, color: Colors.amber);
        sizePremiumLogo = 20;
        break;
      case 'stock':
        title = 'Control de Inventario';
        description =
            'Maneje el stock de sus productos, disfruta además de otras características especiales';
        icon = const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(Icons.inventory_rounded));
        sizePremiumLogo = 20;
        break;
      case 'analytic':
        title = 'Informes y Estadísticas';
        description =
            'Obtenga datos sobre el rendimiento de sus transacciones y otras estadísticas importantes';
        icon = const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(Icons.analytics_outlined));
        sizePremiumLogo = 20;
        break;
      case 'multiuser':
        title = 'Multiusuario';
        description =
            'Permita que más personas gestionen esta cuenta y con permisos personalizados. Además también tenes otras características';
        icon = const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(Icons.people_outline));
        sizePremiumLogo = 20;
        break;
      default:
        title = '';
        description =
            'Funcionalidades especiales para profesionalizar tu negocio';
        icon = Container();
        sizePremiumLogo = 20;
        break;
    }
  }
  // var : para el control de la suscripción
  late LogInResult result;
  Offerings? offerings; // ofertas de suscripción
  bool isSubscribedPremium = false;
  String clientRevenueCatID = ''; // id de la cuenta es la ID personalizada para RevenueCat
  int cantidad = 0; // cantidad de productos
 

  // inicia la identificación de id de usario para revenuecat 
  void initIdentityRevenueCat() async {
    //  configure el SDK de RevvenueCat con una ID de usuario de la aplicación personalizada  
    String clientID = homeController.getProfileAccountSelected.id; 
    
    // logIn : identificar al usuario con un ID personalizada
    await Purchases.logOut();
      result =await Purchases.logIn(clientID).then((value) async{
        // get : obtenemos las ofertas de compra
        await Purchases.getOfferings().then((value) {
          setState(() { 
            offerings = value;
          });
        }); 
        return value;
      }); 
      // get : obtenemos los productos de compra
      result.customerInfo.entitlements.all.forEach((key, value) { 
        if(key == entitlementID){
          setState(() {
            isSubscribedPremium = value.isActive;
          });
        } 
        print('########################################################### key: $key, value: $value');
      }); 
  }

  @override
  void initState() {
    super.initState();
    initIdentityRevenueCat();
    // get  
    setData(id: widget.id);
    
  }



  @override  
  Widget build(BuildContext context) { 
    // values
    setData(id: widget.id);
 
 

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Stack(  
        children: [
          // view : vista con el contenido de la suscripción desplazable
          ListView( 
            children: [
              Container( 
                // color : gradient de un color y transparent 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.1) ,Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.9],
                ), 
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ 
                    const SizedBox(height: 12),
                    // icon 
                    Padding(padding: const EdgeInsets.all(3.0),child: icon),
                    // text : titulo
                    Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // text : descripción
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Opacity(opacity: 0.7,child: Text(description, textAlign: TextAlign.center)),
                    ), 
                    
                  ],
                ),
              ),  
              const Divider(indent: 50, endIndent: 50, height: 50),
              // text : caracteristicas de la suscripción
              const Text('CARACTERÍSTICAS',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w200)),
              const SizedBox(height: 12),
              // ListTile : caracteristicas de la suscripción 'Control de inventario' 
              const Opacity(
                opacity: 0.9,
                child: ListTile(
                  leading: Icon(Icons.inventory_outlined ),
                  title: Text('Control de inventario'),
                  subtitle: Opacity(opacity: 0.5,child: Text('Maneje el stock de sus productos')), 
                ),
              ),
              const Divider(indent: 50),
              // ListTile : caracteristicas de la suscripción 'Multi Usuarios'
              const Opacity(
                opacity: 0.9,
                child: ListTile(
                  leading: Icon(Icons.people_outline),
                  title: Text('Multi Usuarios'),
                  subtitle: Opacity(opacity: 0.5,child: Text('Permita que más personas gestionen esta cuenta y con permisos personalizados')), 
                ),
              ),
              const Divider(indent: 50),
              // ListTile : caracteristicas de la suscripción 'Informes y estadísticas'
              const Opacity(
                opacity: 0.9,
                child: ListTile(
                  leading: Icon(Icons.analytics_outlined),
                  title: Text('Informes y estadísticas'),
                  subtitle: Opacity(opacity: 0.5,child: Text('Obtenga informes y estadísticas de sus ventas')), 
                ),
              ),
              const Divider(indent: 50),
              // ListTile : caracteristicas de la suscripción 'Sin publicidad'
              const Opacity(
                opacity: 0.9,
                child: ListTile(
                  leading: Icon(Icons.remove_red_eye_outlined),
                  title: Text('Sin publicidad'),
                  subtitle: Opacity(opacity: 0.5,child: Text('Sin publicidad en la aplicación')), 
                ),
              ), 
              const SizedBox(height:150),
            ],
          ),
          // view : buton para subcribirse a Premium en la app
          // condition : comprobar que 'offerings' esta inicializado
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              // color : gradient de un color y transparent 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor,
                  ], 
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: offerings==null?const TextButton(onPressed:null, child: Text('Subcribirce a Premium')): ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: offerings?.current?.availablePackages.length,
                itemBuilder: (BuildContext context, int index) {
              
                  // get : obtenemos los productos disponibles
                  List<Package> myProductList =  offerings!.current!.availablePackages;
                  // retornar un Card con color gradient de tres colores
                  return Card(  
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container( 
                      decoration:  BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade700.withOpacity(0.5),
                            Colors.green.shade600.withOpacity(0.5),
                            Colors.green.shade400.withOpacity(0.5),],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        tileColor: Colors.green,
                        titleTextStyle: const TextStyle(color: Colors.white),
                        leadingAndTrailingTextStyle:  const TextStyle(color: Colors.white),
                        onTap: () async {
                          try {
                            // purchasePackage :  compra el paquete de la lista de productos disponibles
                            CustomerInfo customerInfo = await Purchases.purchasePackage(myProductList[index] );
                            EntitlementInfo? entitlement = customerInfo.entitlements.all[entitlementID];
                            bool activate = entitlement?.isActive ?? false;
                          }catch (e) { 
                            // ... handle error
                          }
                        },
                        title: Text(isSubscribedPremium?'Ya estás subcripto':myProductList[index].storeProduct.title,maxLines:1), 
                        trailing:isSubscribedPremium?const Icon(Icons.thumb_up,color: Colors.white,): Text('${myProductList[index].storeProduct.currencyCode} ${myProductList[index].storeProduct.priceString}')),
                    ),
                  ); 
                },
                shrinkWrap: true, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}





