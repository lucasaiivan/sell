import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_page/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import '../../../models/catalogo_model.dart';
import '../../../services/database.dart';
import '../../../utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';

class ControllerProductsEdit extends GetxController {
  // others controllers
  final HomeController homeController = Get.find();

  //  category selected
  Rx<Category> _categorySelect = Category().obs;
  Category get getCategorySelect => _categorySelect.value;
  set setCategorySelect(Category value) {
    // set
    _categorySelect.value = value;
    update();
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


  // category list
  RxList<Category> _categoryList = <Category>[].obs;
  List<Category> get getCatalogueCategoryList => _categoryList;
  set setCatalogueCategoryList(List<Category> value) {
    _categoryList.value = value;
    update(['tab']);
  }

  // state internet
  bool connected = false;
  set setStateConnect(bool value) {
    connected = value;
    update(['updateAll']);
  }

  bool get getStateConnect => connected;

  // ultimate selection mark
  static Mark _ultimateSelectionMark =
      Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setUltimateSelectionMark(Mark value) => _ultimateSelectionMark = value;
  Mark get getUltimateSelectionMark => _ultimateSelectionMark;

  static Mark _ultimateSelectionMark2 =
      Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setUltimateSelectionMark2(Mark value) => _ultimateSelectionMark2 = value;
  Mark get getUltimateSelectionMark2 => _ultimateSelectionMark2;

  // state account auth
  bool _accountAuth = false;
  set setAccountAuth(value) {
    _accountAuth = value;
    update(['updateAll']);
  }

  bool get getAccountAuth => _accountAuth;

  // text appbar
  String _textAppbar = 'Editar';
  set setTextAppBar(String value) => _textAppbar = value;
  String get getTextAppBar => _textAppbar;

  // variable para saber si el producto ya esta o no en el cátalogo
  bool _inCatalogue = false;
  set setIsCatalogue(bool value) => _inCatalogue = value;
  bool get getIsCatalogue => _inCatalogue;

  // variable para mostrar al usuario una viste para editar o crear un nuevo producto
  bool _newProduct = true;
  set setNewProduct(bool value) => _newProduct = value;
  bool get getNewProduct => _newProduct;

  // variable para editar el documento en modo de moderador
  bool _editModerator = false;
  set setEditModerator(bool value) {
    _editModerator = value;
    update(['updateAll']);
  }

  bool get getEditModerator => _editModerator;

  // parameter
  ProductCatalogue _product =
      ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setProduct(ProductCatalogue product) => _product = product;
  ProductCatalogue get getProduct => _product;

  // TextEditingController
  TextEditingController controllerTextEdit_descripcion =
      TextEditingController();
  TextEditingController controllerTextEdit_quantityStock =
      TextEditingController();
  MoneyMaskedTextController controllerTextEdit_precio_venta =
      MoneyMaskedTextController();
  MoneyMaskedTextController controllerTextEdit_precio_compra =
      MoneyMaskedTextController();

  // mark
  Mark _markSelected =
      Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
  set setMarkSelected(Mark value) {
    _markSelected = value;
    getProduct.idMark = value.id;
    getProduct.nameMark = value.name;
    update(['updateAll']);
  }

  Mark get getMarkSelected => _markSelected;

  // marcas
  List<Mark> _marks = [];
  set setMarks(List<Mark> value) => _marks = value;
  List<Mark> get getMarks => _marks;

  //  category
  Category _category = Category();
  set setCategory(Category value) {
    _category = value;
    getProduct.category = value.id;
    getProduct.nameCategory = value.name;
    update(['updateAll']);
  }

  Category get getCategory => _category;

  //  subcategory
  Category _subcategory = Category();
  set setSubcategory(Category value) {
    _subcategory = value;
    getProduct.subcategory = value.id;
    getProduct.nameSubcategory = value.name;
    update(['updateAll']);
  }

  Category get getSubcategory => _subcategory;

  // imagen
  ImagePicker _picker = ImagePicker();
  XFile _xFileImage = XFile('');
  set setXFileImage(XFile value) => _xFileImage = value;
  XFile get getXFileImage => _xFileImage;

  // indicardor para cuando se guarde los datos
  bool _saveIndicador = false;
  set setSaveIndicator(bool value) => _saveIndicador = value;
  bool get getSaveIndicator => _saveIndicador;

  @override
  void onInit() {
    // llamado inmediatamente después de que se asigna memoria al widget

    // state account auth
    setAccountAuth = homeController.getIdAccountSelected != '';

    // se obtiene el parametro y decidimos si es una vista para editrar o un producto nuevo
    setProduct = Get.arguments['product'] ??ProductCatalogue(upgrade: Timestamp.now(), creation: Timestamp.now());
    setNewProduct = Get.arguments['new'] ?? false;
    // load data product
    loadDataProduct();
    if (getNewProduct == false) {
      // el documento existe
      getDataProduct(id: getProduct.id);
      isCatalogue();
    }

    super.onInit();
  }

  @override
  void onReady() {
    // llamado después de que el widget se representa en la pantalla - ej. showIntroDialog(); //
    super.onReady();
  }

  @override
  void onClose() {
    // llamado justo antes de que el controlador se elimine de la memoria - ej. closeStream(); //
    super.onClose();
  }

  // FUNCTIONES
  set setStock(bool value) {
    getProduct.stock =value;
    update(['updateAll']);
  }
  updateAll() => update(['updateAll']);
  back() => Get.back();

  isCatalogue() {
    homeController.getCataloProducts.forEach((element) {
      if (element.id == getProduct.id) {
        setIsCatalogue = true;
        update(['updateAll']);
      }
    });
  }

  Future<void> save() async {
    if (getProduct.id != '') {
      if (getProduct.description != '') {
        if (getProduct.idMark != '' && getProduct.nameMark != '') {
          if (getProduct.salePrice != 0 && getAccountAuth ||getProduct.salePrice == 0 && getAccountAuth == false) {
            if((getProduct.stock)?(getProduct.quantityStock>=1):true){
              // update view
            setSaveIndicator = true;
            setTextAppBar = 'Espere por favor...';
            updateAll();

            // set
            getProduct.upgrade = Timestamp.now();
            // iamge
            if (getXFileImage.path != '') {
              // image - Si el "path" es distinto '' quiere decir que ahi una nueva imagen para actualizar
              // si es asi procede a guardar la imagen en la base de la app
              Reference ref =
                  Database.referenceStorageProductPublic(id: getProduct.id);
              UploadTask uploadTask = ref.putFile(File(getXFileImage.path));
              await uploadTask;
              // obtenemos la url de la imagen guardada
              await ref
                  .getDownloadURL()
                  .then((value) => getProduct.image = value);
            }
            if (getAccountAuth) {
              // procede agregrar el producto en el cátalogo

              // Mods - save data product global
              if (getNewProduct || getEditModerator) {
                getProduct.verified = true; // TODO : release to false
                saveProductPublic();
              }

              // registra el precio en una colección publica para todos los usuarios
              Price precio = Price(
                id: homeController.getProfileAccountSelected.id,
                idAccount: homeController.getProfileAccountSelected.id,
                imageAccount: homeController.getProfileAccountSelected.image,
                nameAccount: homeController.getProfileAccountSelected.name,
                price: getProduct.salePrice,
                currencySign: getProduct.currencySign,
                province: homeController.getProfileAccountSelected.province,
                town: homeController.getProfileAccountSelected.town,
                time: Timestamp.fromDate(DateTime.now()),
              );
              // Firebase set
              await Database.refFirestoreRegisterPrice(
                      idProducto: getProduct.id, isoPAis: 'ARG')
                  .doc(precio.id)
                  .set(precio.toJson());

              // add/update data product in catalogue
              Database.refFirestoreCatalogueProduct(
                      idAccount: homeController.getProfileAccountSelected.id)
                  .doc(getProduct.id)
                  .set(getProduct.toJson())
                  .whenComplete(() async {
                    await Future.delayed(const Duration(seconds: 3))
                        .then((value) {
                      setSaveIndicator = false;
                      Get.back();
                      Get.back();
                    });
                  })
                  .onError((error, stackTrace) => setSaveIndicator = false)
                  .catchError((_) => setSaveIndicator = false);
            } else {
              getProduct.verified = true; // TODO : release to false
              saveProductPublic();
            }
            }else{
              Get.snackbar('Stock no valido 😐', 'debe proporcionar un cantidad');
            }
          } else {
            Get.snackbar('Antes de continuar 😐', 'debe proporcionar un precio');
          }
        } else {
          Get.snackbar(
              'No se puedo continuar 😐', 'debes seleccionar una marca');
        }
      } else {
        Get.snackbar('No se puedo continuar 👎',
            'debes escribir una descripción del producto');
      }
    }
  }

  Future<void> saveProductPublic() async {
    // esta función procede a guardar el documento de una colleción publica

    if (getProduct.id != '') {
      if (getProduct.description != '') {
        if (getProduct.idMark != '') {
          // activate indicator load
          setSaveIndicator = true;
          setTextAppBar = 'Espere por favor...';
          updateAll();

          // set
          Product newProduct = getProduct.convertProductoDefault();
          newProduct.idAccount = homeController.getProfileAccountSelected.id;
          newProduct.upgrade = Timestamp.fromDate(new DateTime.now());

          // firestore - save product public
          await Database.refFirestoreProductPublic()
              .doc(newProduct.id)
              .set(newProduct.toJson())
              .whenComplete(() {
            Get.back();
            Get.back();
            Get.snackbar(
                'Estupendo 😃', 'Gracias por contribuir a la comunidad');
          });
        } else {
          Get.snackbar(
              'No se puedo continuar 😐', 'debes seleccionar una marca');
        }
      } else {
        Get.snackbar('No se puedo continuar 👎',
            'debes escribir una descripción del producto');
      }
    }
  }

  void deleteProducPublic() async {
    // activate indicator load
    setSaveIndicator = true;
    setTextAppBar = 'Eliminando...';
    updateAll();

    // delete doc product in catalogue account
    await Database.refFirestoreCatalogueProduct(
            idAccount: homeController.getProfileAccountSelected.id)
        .doc(getProduct.id)
        .delete();
    // delete doc product
    await Database.refFirestoreProductPublic()
        .doc(getProduct.id)
        .delete()
        .whenComplete(() {
      Get.back();
      Get.back();
    });
  }

  void getDataProduct({required String id}) {
    if (id != '') {
      Database.readProductGlobalFuture(id: id).then((value) {
        //  get
        Product product = Product.fromMap(value.data() as Map);
        //  set
        setProduct = getProduct.updateData(Product: product);
        loadDataProduct();
      }).catchError((error) {
        printError(info: error.toString());
      }).onError((error, stackTrace) {
        loadDataProduct();
        printError(info: error.toString());
      });
    }
  }

  void loadDataProduct() {
    // set
    controllerTextEdit_descripcion =
        TextEditingController(text: getProduct.description);
    controllerTextEdit_precio_venta =
        MoneyMaskedTextController(initialValue: getProduct.salePrice);
    controllerTextEdit_precio_compra =
        MoneyMaskedTextController(initialValue: getProduct.purchasePrice);

    // primero verificamos que no tenga el metadato del dato de la marca para hacer un consulta inecesaria
    if (getProduct.idMark != '') readMarkProducts();
    if (getProduct.category != '') readCategory();
  }

  void readMarkProducts() {
    if (!getProduct.idMark.isEmpty) {
      Database.readMarkFuture(id: getProduct.idMark).then((value) {
        setMarkSelected = Mark.fromMap(value.data() as Map);
        getProduct.nameMark = getMarkSelected.name; // guardamos un metadato
        update(['updateAll']);
      }).onError((error, stackTrace) {
        setMarkSelected =
            Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
      }).catchError((_) {
        setMarkSelected =
            Mark(upgrade: Timestamp.now(), creation: Timestamp.now());
      });
    }
  }

  void readCategory() {
    Database.readCategotyCatalogueFuture(
            idAccount: homeController.getProfileAccountSelected.id,
            idCategory: getProduct.category)
        .then((value) {
      setCategory = Category.fromDocumentSnapshot(documentSnapshot: value);
      if (getProduct.subcategory != '') readSubcategory();
    }).onError((error, stackTrace) {
      setCategory = Category(id: '0000', name: '');
      setSubcategory = Category(id: '0000', name: '');
    }).catchError((_) {
      setCategory = Category(id: '0000', name: '');
      setSubcategory = Category(id: '0000', name: '');
    });
  }

  void readSubcategory() {
    getCategory.subcategories.forEach((key, value) {
      if (key == getProduct.subcategory) {
        setSubcategory = Category(id: key, name: value.toString());
      }
    });
  }

  // read imput image
  void getLoadImageGalery() {
    _picker
        .pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    )
        .then((value) {
      setXFileImage = value!;
      update(['updateAll']);
    });
  }

  void getLoadImageCamera() {
    _picker
        .pickImage(
      source: ImageSource.camera,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    )
        .then((value) {
      setXFileImage = value!;
      update(['updateAll']);
    });
  }

  Widget loadImage() {
    // devuelve la imagen del product
    if (getXFileImage.path != '') {
      // el usuario cargo un nueva imagen externa
      return AspectRatio(
        aspectRatio: 1 / 1,
        child: Image.file(File(getXFileImage.path), fit: BoxFit.cover),
      );
    } else {
      // se visualiza la imagen del producto
      return AspectRatio(
        aspectRatio: 1 / 1,
        child: getProduct.image == ''
            ? Container(color: Colors.grey.withOpacity(0.2))
            : CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: getProduct.image,
                placeholder: (context, url) => Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: const Center(child: Icon(Icons.cloud, color: Colors.white)),
                ),
                imageBuilder: (context, image) => Image(image: image),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: const Center(child: Icon(Icons.error, color: Colors.white)),
                ),
              ),
      );
    }
  }

  void showDialogDelete() {
    Widget widget = AlertDialog(
      title: const Text(
          "¿Seguro que quieres eliminar este producto de tu catálogo?"),
      content: const Text(
          "El producto será eliminado de tu catálogo y toda la información acumulada"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: const Text('Si, eliminar'),
          onPressed: () {
            Database.refFirestoreCatalogueProduct(
                    idAccount: homeController.getProfileAccountSelected.id)
                .doc(getProduct.id)
                .delete()
                .whenComplete(() {
                  Get.back();
                  back();
                  back();
                })
                .onError((error, stackTrace) => Get.back())
                .catchError((ex) => Get.back());
          },
        ),
      ],
    );

    Get.dialog(widget);
  }

  showModalSelectMarca() {
    Widget widget = WidgetSelectMark();
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

  //TODO: eliminar para release
  // DEVELOPER OPTIONS
  setFavorite({required bool value}) {
    getProduct.favorite =value;
    update(['updateAll']);
  }

  setCheckVerified({required bool value}) {
    getProduct.verified =value;
    update(['updateAll']);
  }

  void showDialogDeleteOPTDeveloper() {
    Get.dialog(AlertDialog(
      title: new Text(
          "¿Seguro que quieres eliminar este documento definitivamente? (Mods)"),
      content: new Text(
          "El producto será eliminado de tu catálogo ,de la base de dato global y toda la información acumulada menos el historial de precios registrado"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new TextButton(
          child: new Text("Cancelar"),
          onPressed: () => Get.back(),
        ),
        new TextButton(
          child: new Text("Borrar"),
          onPressed: () {
            Get.back();
            deleteProducPublic();
          },
        ),
      ],
    ));
  }

  void showDialogSaveOPTDeveloper() {
    Get.dialog(AlertDialog(
      title: new Text("¿Seguro que quieres actualizar este docuemnto? (Mods)"),
      content: new Text(
          "El producto será actualizado de tu catálogo ,de la base de dato global y toda la información acumulada menos el historial de precios registrado"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        new TextButton(
          child: new Text("Cancelar"),
          onPressed: () => Get.back(),
        ),
        new TextButton(
          child: new Text("Actualizar"),
          onPressed: () {
            Get.back();
            save();
          },
        ),
      ],
    ));
  }
}

// select mark
class WidgetSelectMark extends StatefulWidget {
  WidgetSelectMark({Key? key}) : super(key: key);

  @override
  _WidgetSelectMarkState createState() => _WidgetSelectMarkState();
}

class _WidgetSelectMarkState extends State<WidgetSelectMark> {
  //  controllers
  ControllerProductsEdit controllerProductsEdit = Get.find();
  //  var
  List<Mark> list = [];

  @override
  void initState() {
    loadMarks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widgetView();
  }

  Widget widgetView() {
    return Column(
      children: [
        widgetAdd(),
        Expanded(
          child: list.length == 0
              ? widgetAnimLoad()
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 12),
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    Mark marcaSelect = list[index];
                    if (index == 0) {
                      return Column(
                        children: [
                          getWidgetOptionOther(),
                          Divider(endIndent: 12.0, indent: 12.0, height: 0),
                          controllerProductsEdit.getUltimateSelectionMark.id ==
                                      '' ||
                                  controllerProductsEdit
                                          .getUltimateSelectionMark.id ==
                                      'other'
                              ? Container()
                              : listTile(
                                  marcaSelect: controllerProductsEdit
                                      .getUltimateSelectionMark),
                          Divider(endIndent: 12.0, indent: 12.0, height: 0),
                          listTile(marcaSelect: marcaSelect),
                          Divider(endIndent: 12.0, indent: 12.0, height: 0),
                        ],
                      );
                    }
                    return Column(
                      children: <Widget>[
                        listTile(marcaSelect: marcaSelect),
                        Divider(endIndent: 12.0, indent: 12.0, height: 0),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  // WIDGETS
  Widget widgetAnimLoad() {
    return Center(
        child: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              child: Card(child: Container(width: double.infinity, height: 50)),
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              child: Card(child: Container(width: double.infinity, height: 50)),
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              child: Card(child: Container(width: double.infinity, height: 50)),
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              child: Card(child: Container(width: double.infinity, height: 50)),
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              child: Card(child: Container(width: double.infinity, height: 50)),
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Shimmer.fromColors(
              child: Card(child: Container(width: double.infinity, height: 50)),
              highlightColor: Colors.grey.withOpacity(0.01),
              baseColor: Get.theme.scaffoldBackgroundColor),
        ),
      ],
    ));
  }

  Widget getWidgetOptionOther() {
    //values
    late Widget widget;
    // recorre la la de marcas para buscar la informaciób de opción 'other'
    if (controllerProductsEdit.getMarks.isEmpty) {
      widget = Container();
    } else {
      controllerProductsEdit.getMarks.forEach((element) {
        if (element.id == 'other') {
          widget = listTile(
            marcaSelect: element,
          );
        }
      });
    }
    return widget;
  }

  // WIDGETS COMPONENT
  Widget widgetAdd() {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 12),
          child: Row(
            children: [
              Expanded(child: Text('Marcas', style: TextStyle(fontSize: 18))),
              // TODO : delete icon 'add new mark for release'
              IconButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => CreateMark(
                        mark: Mark(
                            upgrade: Timestamp.now(),
                            creation: Timestamp.now())));
                  },
                  icon: Icon(Icons.add)),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Get.back();
                  showSearch(
                    context: context,
                    delegate: SearchPage<Mark>(
                      items: list,
                      searchLabel: 'Buscar marca',
                      suggestion: Center(
                        child: Text('ej. Miller'),
                      ),
                      failure: Center(
                        child: Text('No se encontro :('),
                      ),
                      filter: (product) => [
                        product.name,
                        product.description,
                      ],
                      builder: (mark) => Column(
                        children: <Widget>[
                          listTile(marcaSelect: mark),
                          Divider(endIndent: 12.0, indent: 12.0, height: 0),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget listTile({required Mark marcaSelect, bool icon = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      trailing: !icon
          ? null
          : ImageApp.circleImage(
              texto: marcaSelect.name, url: marcaSelect.image, size: 50.0),
      dense: true,
      title: Text(marcaSelect.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18.0, color: Get.theme.textTheme.bodyText1!.color)),
      subtitle: marcaSelect.description == ''
          ? null
          : Text(marcaSelect.description, overflow: TextOverflow.ellipsis),
      onTap: () {
        controllerProductsEdit.setUltimateSelectionMark = marcaSelect;
        controllerProductsEdit.setMarkSelected = marcaSelect;
        Get.back();
      },
      onLongPress: () {
        // TODO : delete fuction
        Get.to(() => CreateMark(mark: marcaSelect));
      },
    );
  }

  // functions
  loadMarks() async {
    if (controllerProductsEdit.getMarks.length == 0) {
      await Database.readListMarksFuture().then((value) {
        setState(() {
          value.docs.forEach((element) {
            Mark mark = Mark.fromMap(element.data());
            mark.id = element.id;
            list.add(mark);
          });
          controllerProductsEdit.setMarks = list;
        });
      });
    } else {
      // datos ya descargados
      list = controllerProductsEdit.getMarks;
      setState(() => list = controllerProductsEdit.getMarks);
    }
  }
}

// TODO : delete release
class CreateMark extends StatefulWidget {
  late final Mark mark;
  CreateMark({required this.mark, Key? key}) : super(key: key);

  @override
  _CreateMarkState createState() => _CreateMarkState();
}

class _CreateMarkState extends State<CreateMark> {
  // others controllers
  final ControllerProductsEdit controllerProductsEdit = Get.find();

  //var
  var uuid = Uuid();
  bool newMark = false;
  String title = 'Crear nueva marca';
  bool load = false;
  TextStyle textStyle = new TextStyle(fontSize: 24.0);
  ImagePicker _picker = ImagePicker();
  XFile xFile = XFile('');

  @override
  void initState() {
    newMark = widget.mark.id == '';
    title = newMark ? 'Crear nueva marca' : 'Editar';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: body(),
    );
  }

  PreferredSizeWidget appbar() {
    Color? colorAccent = Get.theme.textTheme.bodyText1!.color;

    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Text(
        title,
        style: TextStyle(color: colorAccent),
      ),
      centerTitle: true,
      iconTheme: Get.theme.iconTheme.copyWith(color: colorAccent),
      actions: [
        newMark
            ? Container()
            : IconButton(onPressed: delete, icon: Icon(Icons.delete)),
        load
            ? Container()
            : IconButton(
                icon: Icon(Icons.check),
                onPressed: save,
              ),
      ],
      bottom: load ? ComponentApp.linearProgressBarApp() : null,
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              xFile.path != ''
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(xFile.path)),
                      radius: 76,
                    )
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.mark.image,
                      placeholder: (context, url) => CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        radius: 75.0,
                      ),
                      imageBuilder: (context, image) => CircleAvatar(
                        backgroundImage: image,
                        radius: 75.0,
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        radius: 75.0,
                      ),
                    ),
              load
                  ? Container()
                  : TextButton(
                      onPressed: getLoadImageMark,
                      child: Text("Cambiar imagen")),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            enabled: !load,
            controller: new TextEditingController(text: widget.mark.name),
            onChanged: (value) => widget.mark.name = value,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Nombre de la marca"),
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            enabled: !load,
            controller:
                new TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Descripción (opcional)"),
            style: textStyle,
          ),
        ),
      ],
    );
  }

  //  MARK CREATE
  void getLoadImageMark() {
    _picker
        .pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    )
        .then((value) {
      setState(() => xFile = value!);
    });
  }

  void delete() async {
    setState(() {
      load = true;
      title = 'Eliminando...';
    });

    if (widget.mark.id != '') {
      // delele archive storage
      await Database.referenceStorageProductPublic(id: widget.mark.id)
          .delete()
          .catchError((_) => null);
      // delete document firestore
      await Database.refFirestoreMark()
          .doc(widget.mark.id)
          .delete()
          .then((value) {
        // eliminar el objeto de la lista manualmente para evitar hacer una consulta innecesaria
        controllerProductsEdit.getMarks.remove(widget.mark);
        Get.back();
      });
    }
  }

  void save() async {
    setState(() {
      load = true;
      title = newMark ? 'Guardando...' : 'Actualizando...';
    });

    // set values
    widget.mark.verified = true;
    if (widget.mark.id == '') {
      widget.mark.id = uuid.v1();
      if (widget.mark.id == '') {
        widget.mark.id = new DateTime.now().millisecondsSinceEpoch.toString();
      }
    }
    if (widget.mark.name != '') {
      // image save
      // Si el "path" es distinto '' procede a guardar la imagen en la base de dato de almacenamiento
      if (xFile.path != '') {
        Reference ref =
            Database.referenceStorageProductPublic(id: widget.mark.id);
        // referencia de la imagen
        UploadTask uploadTask = ref.putFile(File(xFile.path));
        // cargamos la imagen a storage
        await uploadTask;
        // obtenemos la url de la imagen guardada
        await ref
            .getDownloadURL()
            .then((value) async {
              // set
              widget.mark.image = value;
              // mark save
              await Database.refFirestoreMark()
                  .doc(widget.mark.id)
                  .set(widget.mark.toJson())
                  .whenComplete(() {
                controllerProductsEdit.setUltimateSelectionMark = widget.mark;
                controllerProductsEdit.setMarkSelected = widget.mark;
                // agregar el obj manualmente para evitar consulta a la db  innecesaria
                controllerProductsEdit.getMarks.add(widget.mark);
                Get.back();
              });
            })
            .onError((error, stackTrace) {})
            .catchError((_) {});
      } else {
        // mark save
        await Database.refFirestoreMark()
            .doc(widget.mark.id)
            .set(widget.mark.toJson())
            .whenComplete(() {
          controllerProductsEdit.setUltimateSelectionMark = widget.mark;
          controllerProductsEdit.setMarkSelected = widget.mark;
          // agregar el obj manualmente para evitar consulta a la db  innecesaria
          controllerProductsEdit.getMarks.add(widget.mark);
          Get.back();
        });
      }
    } else {
      Get.snackbar('', 'Debes escribir un nombre de la marca');
    }
  }
}
