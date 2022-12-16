import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sell/app/presentation/sellPage/controller/sell_controller.dart';
import 'package:sell/app/data/datasource/database_cloud.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../domain/entities/user_model.dart';
import '../../../core/utils/widgets_utils.dart';

class HomeController extends GetxController {

  // buildContext : obtenemos el context para mostrar Sheet ( la hoja inferior )
  late BuildContext _buildContext;
  set  setBuildContext(BuildContext context) => _buildContext=context;
  BuildContext get getBuildContext =>_buildContext; 

  // Guide user : Ventas
  bool salesUserGuideVisibility=false;
  void getSalesUserGuideVisibility(){
    // obtenemos la visibilidad de la guía del usuario de ventas
    salesUserGuideVisibility = GetStorage().read('salesUserGuideVisibility') ?? true;
    update();
  }
  void disableSalesUserGuide()async{
    // Deshabilitar la guía del usuario de ventas
    salesUserGuideVisibility=false;
    await GetStorage().write('salesUserGuideVisibility', salesUserGuideVisibility);
  }

  // Guide user : Catalogue
  bool catalogUserHuideVisibility=false;
  void getTheVisibilityOfTheCatalogueUserGuide(){
    // obtenemos la visibilidad de la guía del usuario del catálogo
    catalogUserHuideVisibility=GetStorage().read('catalogUserHuideVisibility') ?? true;
    update();
  }
  void disableCatalogUserGuide()async{
    // Deshabilitar la guía del usuario del catálogo
    catalogUserHuideVisibility=false;
    await GetStorage().write('catalogUserHuideVisibility', catalogUserHuideVisibility);
  }

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
  get getProductsOutstandingList => _productsOutstandingList;
  set setProductsOutstandingList(List<ProductCatalogue> list) { _productsOutstandingList.value = list;}

  addToListProductSelecteds({required ProductCatalogue item}) {_productsOutstandingList.add(item);}

  //  authentication account profile
  late User _userFirebaseAuth;
  User get getUserAuth => _userFirebaseAuth;
  set setUserAuth(User user) => _userFirebaseAuth = user;

  //  profile Admin User
  UserModel _adminUser = UserModel();
  UserModel get getProfileAdminUser => _adminUser;
  set setProfileAdminUser(UserModel user) => _adminUser = user;

  // profile account selected
  ProfileAccountModel _accountProfileSelected = ProfileAccountModel(creation: Timestamp.now());
  ProfileAccountModel get getProfileAccountSelected => _accountProfileSelected;
  set setProfileAccountSelected(ProfileAccountModel value) => _accountProfileSelected = value;
  String get getIdAccountSelected => _accountProfileSelected.id;
  bool isSelected({required String id}) {
    bool isSelected = false;
    for (ProfileAccountModel obj in getManagedAccountsList) {
      if (obj.id == getIdAccountSelected) {
        if (id == getIdAccountSelected) {isSelected = true;}
      }
    }

    return isSelected;
  }

  // administrator account list
  final RxList<ProfileAccountModel> _managedAccountsList =<ProfileAccountModel>[].obs;
  List<ProfileAccountModel> get getManagedAccountsList => _managedAccountsList;
  set setManagedAccountsList(List<ProfileAccountModel> value) =>_managedAccountsList.value = value;
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

    getSalesUserGuideVisibility();
    getTheVisibilityOfTheCatalogueUserGuide();
    // obtenemos por parametro los datos de la cuenta de atentificación
    Map map = Get.arguments as Map;
    // verificamos y obtenemos los datos pasados por parametro
    setUserAuth = map['currentUser'];
    // obtenemos el id de la cuenta seleccionada si es que existe
    map.containsKey('idAccount') ? readAccountsData(idAccount: map['idAccount']): readAccountsData(idAccount: '');
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
    ProductCatalogue product = ProductCatalogue(creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
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
          setProfileAccountSelected =  ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
          // load
          readDataAdminUser(email: getUserAuth.email ?? '', idAccount: idAccount);
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
    Database.readSalesProduct(idAccount: idAccount).listen((value) {

      // values 
      List<ProductCatalogue> list = [];
      //  obtenemos todos los productos ordenas con más ventas
      for (var element in value.docs) {
        list.add(ProductCatalogue.fromMap(element.data()));
      }


      // filtramos los productos que esten marcados como favoritos
      List <ProductCatalogue> favoriteList = [];
      for (ProductCatalogue element in list) {
        if(element.favorite){
          favoriteList.add(element);
        }
      }
      // filtramos los productos que no sean favoritos
      List <ProductCatalogue> filterList = [];
      for (ProductCatalogue element in list) {
        if(element.favorite== false){
          filterList.add(element);
        }
      }
      // obtenemos una nueva lista con los productos favoritos primeros ordenados por los que tienen más ventas
      List <ProductCatalogue> finalList = [];
      for (ProductCatalogue element in favoriteList) {
        finalList.add(element);
      }
      // luego obtenemos los demas productos ordenados por los que tienen más ventas
      for (ProductCatalogue element in filterList) {
        finalList.add(element);
      }
      //  set values
      setProductsOutstandingList = finalList;
      try{
        SalesController salesController = Get.find();
        salesController.update();
      }catch(_){}
    });
  }

  void readProductsCatalogue({required String idAccount}) {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    Database.readProductsCatalogueStream(id: idAccount).listen((value) {

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
    Database.readFutureAdminUser(idAccount: idAccount, email: email).then((value) {
      if (value.exists) {
        setProfileAdminUser = UserModel.fromDocumentSnapshot(documentSnapshot: value);
      }
    });
  }

  void readUserAccountsList({required String email}) {
    // obtenemos la lista de cuentas del usuario
    Database.refFirestoreUserAccountsList(email: email).get().then((value) {
      //  get
      for (var element in value.docs) {
        if (element.get('id') != '') {
          Database.readProfileAccountModelFuture(element.get('id')).then((value) {
            ProfileAccountModel profileAccountModel = ProfileAccountModel.fromDocumentSnapshot(documentSnapshot: value);
            addManagedAccountsList = profileAccountModel;
          });
        }
      }
    });
  }

  Future<void> categoryDelete({required String idCategory}) async => await Database.refFirestoreCategory(idAccount: getProfileAccountSelected.id).doc(idCategory).delete();
  Future<void> categoryUpdate({required Category categoria}) async {

    // refactorizamos el nombre de la cátegoria
    String name = categoria.name.substring(0, 1).toUpperCase() + categoria.name.substring(1);
    categoria.name=name;
    // ref
    var documentReferencer = Database.refFirestoreCategory(idAccount: getProfileAccountSelected.id).doc(categoria.id);
    // Actualizamos los datos
    documentReferencer.set(Map<String, dynamic>.from(categoria.toJson()),SetOptions(merge: true));
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
    // save key/values Storage
    GetStorage().write('idAccount', idAccount);
    // navegar hacia otra pantalla
    Get.offAllNamed(Routes.HOME, arguments: {'currentUser': getUserAuth,'idAccount': idAccount});
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
  void showModalBottomSheetSubcription({String id='premium'}){  

    // bottomSheet : muestre la hoja inferior modal de getx
    Get.bottomSheet(
      SizedBox(height: 600,child: WidgetBottomSheet(id:id)),
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    ); 
  }

  
}


class WidgetBottomSheet extends StatefulWidget {

  late String id;
  WidgetBottomSheet({Key? key,required this.id}) : super(key: key);

  @override
  State<WidgetBottomSheet> createState() => _WidgetBottomSheetState();
}

class _WidgetBottomSheetState extends State<WidgetBottomSheet> {

  // others controllers
  final HomeController homeController = Get.find();

  // values
  late double sizePremiumLogo = 16.0;
  Widget icon = Container();
  String title = '';
  String description = '';

  // functions
  void setData({required String id}){
    switch(id){
      case 'premium':
        title = '' ;
        description ='Funcionalidades especiales para profesionalizar tu negocio';
        icon =  Container();
        sizePremiumLogo=20;
        break;
      case 'stock':
        title = 'Control de Inventario' ;
        description ='Maneje el stock de sus productos, disfruta además de otras características especiales';
        icon = const Padding(padding: EdgeInsets.only(right: 5),child: Icon(Icons.inventory_rounded));
        sizePremiumLogo=12;
        break;
      case 'analytic':
        title = 'Informes y Estadísticas' ;
        description ='Obtenga datos sobre el rendimiento de sus transacciones y otras estadísticas importantes';
        icon = const Padding(padding: EdgeInsets.only(right: 5),child: Icon(Icons.analytics_outlined));
        sizePremiumLogo=12;
        break;
      case 'multiuser':
        title = 'Multiusuario' ;
        description ='Permita que más personas gestionen esta cuenta y con permisos personalizados. Además también tenes otras características';
        icon = const Padding(padding: EdgeInsets.only(right: 5),child: Icon(Icons.people_outline));
        sizePremiumLogo=12;
        break;
      default:
        title = '' ;
        description ='Funcionalidades especiales para profesionalizar tu negocio';
        icon =  Container();
        sizePremiumLogo=20;
        break;
    }
  }


  @override
  Widget build(BuildContext context) {

    // values 
    setData(id: widget.id);

    // value 
    BorderSide side = const BorderSide(color: Colors.transparent);

    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.start,mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,alignment: WrapAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      Text(title,textAlign: TextAlign.center,style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      LogoPremium(personalize: true,accentColor: Colors.amber.shade600,size: sizePremiumLogo,visible: true,),
                      //const Icon(Icons.workspace_premium_outlined,size: 30,color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Opacity(opacity: 0.7,child: Text(description,textAlign: TextAlign.center )),
                  const SizedBox(height: 12),
                  const Text('Más características',textAlign: TextAlign.center,),
                  const SizedBox(height: 12),
                  Chip(backgroundColor: Colors.transparent,side: side,avatar: const Icon(Icons.check),label: const Text('Control de inventario')),
                  Chip(backgroundColor: Colors.transparent,side: side,avatar: const Icon(Icons.check),label: const Text('Multi Usuarios')),
                  Chip(backgroundColor: Colors.transparent,side: side,avatar:  const Icon(Icons.check),label: const Text('Informes y estadísticas')),
                  Chip(backgroundColor: Colors.transparent,side: side,avatar: const Icon(Icons.check),label: const Text('Sin publicidad')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // button : adquirir premium
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null,/*  (){
                  // actualizamos la subcripción de la cuenta
                  setState(() {
                    homeController.getProfileAccountSelected.subscribed = !homeController.getProfileAccountSelected.subscribed;
                  });
                  if(homeController.getProfileAccountSelected.subscribed){Get.back();}
                },  */
                //  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(homeController.getProfileAccountSelected.subscribed?Colors.grey:Colors.blue)),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.1))),
                icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  // text : homeController.getProfileAccountSelected.subscribed?'Desuscribirme':'Subcribirme'
                  child: Text('Subcribirme',style: TextStyle(fontSize: 24,color: Colors.white)),
                ),
                // icon : homeController.getProfileAccountSelected.subscribed?Icons.close:Icons.arrow_forward_rounded
                label: const Icon(Icons.arrow_forward_rounded,color: Colors.white,),
              ),
            ),
            // text : precio de la versión Premium
            const SizedBox(height: 50),
            /* disponible para cuando las subcripciones esten desarrolladas

            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'US \$6,99',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                  TextSpan(text: ' al mes',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                ],
              ),textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ), */
          ],
        ),
      );
  }
}