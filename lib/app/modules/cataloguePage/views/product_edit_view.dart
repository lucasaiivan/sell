import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_page/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../models/catalogo_model.dart';
import '../../../services/database.dart';
import '../../../utils/fuctions.dart';
import '../../../utils/widgets_utils.dart';
import '../../home/controller/home_controller.dart';
import '../controller/product_edit_controller.dart';

class ProductEdit extends StatelessWidget {
  ProductEdit({Key? key}) : super(key: key);

  final ControllerProductsEdit controller = Get.find();
  final Widget space = const SizedBox(
    height: 16.0,
    width: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    // GetBuilder - refresh all the views
    return GetBuilder<ControllerProductsEdit>(
      id: 'updateAll',
      init: ControllerProductsEdit(),
      initState: (_) {},
      builder: (_) {
        return OfflineBuilder(
            child: Container(),
            connectivityBuilder: (
              BuildContext context,
              ConnectivityResult connectivity,
              Widget child,
            ) {
              final connected = connectivity != ConnectivityResult.none;

              if (!connected) {
                Color? colorAccent = Get.theme.textTheme.bodyText1!.color;
                return Scaffold(
                  appBar: AppBar(
                    elevation: 0.0,
                    backgroundColor: Get.theme.scaffoldBackgroundColor,
                    iconTheme: Theme.of(context)
                        .iconTheme
                        .copyWith(color: colorAccent),
                    title: controller.getSaveIndicator
                        ? Text(controller.getTextAppBar,
                            style:
                                TextStyle(fontSize: 18.0, color: colorAccent))
                        : Text('Espere por favor...',
                            style:
                                TextStyle(fontSize: 18.0, color: colorAccent)),
                  ),
                  body: Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.wifi_off_rounded),
                      ),
                      Text('No hay internet'),
                    ],
                  )),
                );
              }

              return scaffold(context: context);
            });
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appBar({required BuildContext contextPrincipal}) {
    Color? colorAccent = Get.theme.textTheme.bodyText1!.color;

    return AppBar(
      elevation: 0.0,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      iconTheme:
          Theme.of(contextPrincipal).iconTheme.copyWith(color: colorAccent),
      title: controller.getSaveIndicator
          ? Text(controller.getTextAppBar,
              style: TextStyle(fontSize: 18.0, color: colorAccent))
          : Text(controller.getIsCatalogue ? 'Editar' : 'Nuevo',
              style: TextStyle(fontSize: 18.0, color: colorAccent)),
      actions: <Widget>[
        controller.getSaveIndicator
            ? Container()
            : IconButton(
                icon: Icon(controller.getIsCatalogue ? Icons.check : Icons.add),
                onPressed: controller.save),
      ],
      bottom: controller.getSaveIndicator
          ? ComponentApp.linearProgressBarApp()
          : null,
    );
  }

  Widget scaffold({required BuildContext context}) {
    return Scaffold(
      appBar: appBar(contextPrincipal: context),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          widgetsImagen(),
          widgetFormEditText(),
        ],
      ),
    );
  }

  Widget widgetsImagen() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.grey.withOpacity(0.1),
      width: double.infinity,
      height: Get.size.height * 0.25,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // button
          controller.getSaveIndicator
              ? Container()
              : controller.getNewProduct || controller.getEditModerator
                  ? IconButton(
                      onPressed: controller.getLoadImageCamera,
                      icon: const Icon(Icons.camera_alt, color: Colors.grey))
                  : Container(),
          //  image
          controller.loadImage(),
          //  button
          controller.getSaveIndicator
              ? Container()
              : controller.getNewProduct || controller.getEditModerator
                  ? IconButton(
                      onPressed: controller.getLoadImageGalery,
                      icon: const Icon(Icons.image, color: Colors.grey))
                  : Container(),
        ],
      ),
    );
  }

  Widget widgetFormEditText() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          space,
          TextField(
            enabled: controller.getSaveIndicator
                ? false
                : controller.getEditModerator || controller.getNewProduct,
            minLines: 1,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            onChanged: (value) => controller.getProduct.description = value,
            decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                border: const OutlineInputBorder(),
                labelText: "Descripción"),
            textInputAction: TextInputAction.done,
            controller: controller.controllerTextEditDescripcion,
          ),
          //TODO: eliminar para desarrrollo
          // widget debug
          TextButton(
              onPressed: () async {
                String clave = controller.controllerTextEditDescripcion.text;
                String url =
                    "https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text('Buscar descripción en Google')),
          TextButton(
              onPressed: () async {
                String clave = controller.getProduct.code;
                String url =
                    "https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text('Buscar en código Google')),
          space,
          textfielButton(
              textValue: controller.getMarkSelected.name,
              labelText: controller.getMarkSelected.id == ''
                  ? 'seleccionar una marca'
                  : 'Marca',
              onTap: controller.getNewProduct || controller.getEditModerator
                  ? controller.showModalSelectMarca
                  : () {}),
          // buttons categoty
          !controller.getAccountAuth ? Container() : space,
          !controller.getAccountAuth
              ? Container()
              : textfielButton(
                  textValue: controller.getCategory.id == ''
                      ? ''
                      : controller.getCategory.name,
                  labelText: controller.getCategory.id == ''
                      ? 'Seleccionar categoría'
                      : 'Categoría',
                  onTap: controller.getSaveIndicator
                      ? () {}
                      : SelectCategory.show,
                ),
          space,
          // textfield prices
          !controller.getAccountAuth
              ? Container()
              : Column(
                  children: [
                    space,
                    TextField(
                      enabled: !controller.getSaveIndicator,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => controller
                              .getProduct.purchasePrice =
                          controller.controllerTextEditPrecioCompra.numberValue,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Precio de compra"),
                      textInputAction: TextInputAction.next,
                      //style: textStyle,
                      controller: controller.controllerTextEditPrecioCompra,
                    ),
                    space,
                    TextField(
                      enabled: !controller.getSaveIndicator,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => controller.getProduct.salePrice =
                          controller.controllerTextEditPrecioVenta.numberValue,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Precio de venta"),
                      textInputAction: TextInputAction.done,
                      //style: textStyle,
                      controller: controller.controllerTextEditPrecioVenta,
                    ),
                    space,
                    CheckboxListTile(
                      enabled: controller.getSaveIndicator ? false : true,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: controller.getProduct.stock,
                      title: Text(controller.getProduct.stock
                          ? 'Quitar de stock'
                          : 'Habilitar control de stock'),
                      onChanged: (value) {
                        if (!controller.getSaveIndicator) {
                          controller.setStock = value ?? false;
                        }
                      },
                    ),
                    controller.getProduct.stock ? space : Container(),
                    controller.getProduct.stock
                        ? ElasticIn(
                            child: TextField(
                              enabled: !controller.getSaveIndicator,
                              keyboardType: TextInputType.number,
                              onChanged: (value) =>
                                  controller.getProduct.quantityStock =
                                      int.parse(controller
                                          .controllerTextEditQuantityStock
                                          .text),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Stock"),
                              textInputAction: TextInputAction.done,
                              //style: textStyle,
                              controller:
                                  controller.controllerTextEditQuantityStock,
                            ),
                          )
                        : Container(),
                    controller.getProduct.stock ? space : Container(),
                    controller.getProduct.stock
                        ? ElasticIn(
                            child: TextField(
                              enabled: !controller.getSaveIndicator,
                              keyboardType: TextInputType.number,
                              onChanged: (value) =>
                                  controller.getProduct.alertStock = int.parse(
                                      controller
                                          .controllerTextEditAlertStock.text),
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Alerta de stock"),
                              textInputAction: TextInputAction.done,
                              //style: textStyle,
                              controller:
                                  controller.controllerTextEditAlertStock,
                            ),
                          )
                        : Container(),
                    space,
                  ],
                ),
          !controller.getNewProduct ? Container() : space,
          controller.getProduct.code != ""
              ? Opacity(
                  opacity: 0.8,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 14),
                        const SizedBox(width: 5),
                        Text(controller.getProduct.code,
                            style: const TextStyle(
                                height: 1,
                                fontSize: 12,
                                fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                )
              : Container(),
          space,
          controller.getSaveIndicator
              ? Container()
              : controller.getIsCatalogue
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          bottom: 12, top: 40, left: 0, right: 0),
                      child: button(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 5),
                          colorAccent: Colors.white,
                          colorButton: Colors.red.shade400,
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          text: 'Eliminar de mi catálogo',
                          onPressed: controller.showDialogDelete),
                    )
                  : Container(),
          //TODO: eliminar para desarrrollo
          /* OPCIONES PARA DESARROLLADOR - ELIMINAR ESTE CÓDIGO PARA PRODUCCION */
          controller.getNewProduct
              ? Container()
              : Column(
                  children: [
                    const SizedBox(height: 20.0),
                    Row(
                      children: const [
                        Expanded(
                            child: Divider(
                          height: 3.0,
                          endIndent: 12.0,
                          indent: 12.0,
                          thickness: 2,
                        )),
                        Text("OPCIONES PARA MODERADOR"),
                        Expanded(
                            child: Divider(
                                thickness: 2,
                                height: 3.0,
                                endIndent: 12.0,
                                indent: 12.0))
                      ],
                    ),
                    SizedBox(height: !controller.getSaveIndicator ? 20.0 : 0.0),
                    CheckboxListTile(
                      enabled: controller.getEditModerator
                          ? controller.getSaveIndicator
                              ? false
                              : true
                          : false,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: controller.getProduct.favorite,
                      title: Text(controller.getProduct.favorite
                          ? 'Detacado'
                          : 'Sin destacar'),
                      onChanged: (value) {
                        if (!controller.getSaveIndicator) {
                          controller.setFavorite(value: value ?? false);
                        }
                      },
                    ),
                    SizedBox(height: !controller.getSaveIndicator ? 20.0 : 0.0),
                    CheckboxListTile(
                      enabled: controller.getEditModerator
                          ? controller.getSaveIndicator
                              ? false
                              : true
                          : false,
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      value: controller.getProduct.verified,
                      title: Text(controller.getProduct.verified
                          ? 'Verificado'
                          : 'Sin verificar'),
                      onChanged: (value) {
                        if (controller.getEditModerator) {
                          if (!controller.getSaveIndicator) {
                            controller.setCheckVerified(value: value ?? false);
                          }
                        }
                      },
                    ),
                    SizedBox(height: !controller.getSaveIndicator ? 20.0 : 0.0),
                    controller.getSaveIndicator
                        ? Container()
                        : button(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            icon:
                                const Icon(Icons.security, color: Colors.white),
                            onPressed: () {
                              if (controller.getEditModerator) {
                                controller.showDialogSaveOPTDeveloper();
                              }
                              controller.setEditModerator =
                                  !controller.getEditModerator;
                            },
                            colorAccent: Colors.white,
                            colorButton: controller.getEditModerator
                                ? Colors.green
                                : Colors.orange,
                            text: controller.getEditModerator
                                ? 'Actualizar documento'
                                : "Editar documento",
                          ),
                    const SizedBox(height: 20.0),
                    controller.getSaveIndicator
                        ? Container()
                        : button(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            icon:
                                const Icon(Icons.security, color: Colors.white),
                            onPressed: controller.showDialogDeleteOPTDeveloper,
                            colorAccent: Colors.white,
                            colorButton: Colors.red,
                            text: "Eliminar documento",
                          ),
                    const SizedBox(height: 50.0),
                  ],
                  // fin widget debug
                ),
                    ]             ,
      ),
    );
  }

  /* WIDGETS COMPONENT */
  Widget textfielButton(
      {required String labelText,
      String textValue = '',
      required Function() onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: onTap,
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: textValue),
        decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            border: const OutlineInputBorder(),
            labelText: labelText),
      ),
    );
  }

  Widget button(
      {double width = double.infinity,
      required Widget icon,
      String text = '',
      required dynamic onPressed,
      EdgeInsets padding =
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      Color colorButton = Colors.purple,
      Color colorAccent = Colors.white}) {
    return FadeInRight(
        child: Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.all(12.0),
              primary: colorButton,
              textStyle: TextStyle(color: colorAccent)),
          icon: icon,
          label: Text(text, style: TextStyle(color: colorAccent)),
        ),
      ),
    ));
  }
}

// category
class SelectCategory extends StatefulWidget {
  SelectCategory();

  @override
  _SelectCategoryState createState() => _SelectCategoryState();

  static void show() {
    Widget widget = SelectCategory();
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

class _SelectCategoryState extends State<SelectCategory> {
  _SelectCategoryState();

  // Variables
  final Category categoriaSelected = Category();
  bool crearCategoria = false, loadSave = false;
  final HomeController welcomeController = Get.find();
  final ControllerProductsEdit controllerProductsEdit = Get.find();

  @override
  void initState() {
    crearCategoria = false;
    loadSave = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    if (welcomeController.getCatalogueCategoryList.isEmpty) {
      return ListTile(
        onTap: () => showDialogSetCategoria(categoria: Category()),
        title: const Text('Crear categoría', style: TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.add),
      );
    }

    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: welcomeController.getCatalogueCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          Category categoria =
              welcomeController.getCatalogueCategoryList[index];
          MaterialColor color = Utils.getRandomColor();
          return index == 0
              ? Column(
                  children: <Widget>[
                    Row(
                      children: [
                        const Expanded(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child:
                              Text('Categoría', style: TextStyle(fontSize: 18)),
                        )),
                        IconButton(
                            icon: const Icon(Icons.add),
                            padding: const EdgeInsets.all(20.0),
                            onPressed: () =>
                                showDialogSetCategoria(categoria: Category()))
                      ],
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        radius: 24.0,
                        child: Text(categoria.name.substring(0, 1),
                            style: TextStyle(
                                fontSize: 18.0,
                                color: color,
                                fontWeight: FontWeight.bold)),
                      ),
                      dense: true,
                      title: Text(categoria.name),
                      onTap: () {
                        controllerProductsEdit.setCategory = categoria;
                        controllerProductsEdit.updateAll();
                        Get.back();
                      },
                      trailing: popupMenuItemCategoria(categoria: categoria),
                    ),
                    const Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
                  ],
                )
              : Column(
                  children: <Widget>[
                    const Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        radius: 24.0,
                        child: categoria.name != ""
                            ? Text(categoria.name.substring(0, 1),
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: color,
                                    fontWeight: FontWeight.bold))
                            : const Text("C"),
                      ),
                      dense: true,
                      title: Text(categoria.name),
                      onTap: () {
                        controllerProductsEdit.setCategory = categoria;
                        controllerProductsEdit.setSubcategory = Category();
                        Get.back();
                      },
                      trailing: popupMenuItemCategoria(categoria: categoria),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget popupMenuItemCategoria({required Category categoria}) {
    final HomeController controller = Get.find();

    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(child: const Text('Editar'), value: 'editar'),
        PopupMenuItem<String>(child: const Text('Eliminar'), value: 'eliminar'),
      ],
      onSelected: (value) async {
        switch (value) {
          case "editar":
            showDialogSetCategoria(categoria: categoria);
            break;
          case "eliminar":
            await showDialog<String>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(16.0),
                  content: Row(
                    children: <Widget>[
                      const Expanded(
                        child:
                            Text("¿Desea continuar eliminando esta categoría?"),
                      )
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    TextButton(
                        child: loadSave == false
                            ? Text("ELIMINAR")
                            : CircularProgressIndicator(),
                        onPressed: () async {
                          controller.categoryDelete(idCategory: categoria.id);
                          Navigator.pop(context);
                        })
                  ],
                );
              },
            );
            break;
        }
      },
    );
  }

  showDialogSetCategoria({required Category categoria}) async {
    final HomeController controller = Get.find();
    bool loadSave = false;
    bool newProduct = false;
    TextEditingController textEditingController =
        TextEditingController(text: categoria.name);

    if (categoria.id == '') {
      newProduct = true;
      categoria = new Category();
      categoria.id = new DateTime.now().millisecondsSinceEpoch.toString();
    }

    await showDialog<String>(
      context: context,
      builder: (context) {
        return new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Categoria', hintText: 'Ej. golosinas'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Get.back();
                }),
            new TextButton(
                child: loadSave == false
                    ? Text(newProduct ? 'GUARDAR' : "ACTUALIZAR")
                    : CircularProgressIndicator(),
                onPressed: () async {
                  if (textEditingController.text != '') {
                    // set
                    categoria.name = textEditingController.text;
                    setState(() => loadSave = true);
                    // save
                    await controller
                        .categoryUpdate(categoria: categoria)
                        .whenComplete(() {
                      welcomeController.getCatalogueCategoryList.add(categoria);
                      setState(() {
                        Get.back();
                      });
                    }).catchError((error, stackTrace) =>
                            setState(() => loadSave = false));
                  }
                })
          ],
        );
      },
    );
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
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
  TextStyle textStyle = const TextStyle(fontSize: 24.0);
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
            : IconButton(onPressed: delete, icon: const Icon(Icons.delete)),
        load
            ? Container()
            : IconButton(
                icon: const Icon(Icons.check),
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
                      child: const Text("Cambiar imagen")),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.name),
            onChanged: (value) => widget.mark.name = value,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: "Nombre de la marca"),
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value,
            decoration: const InputDecoration(
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
        widget.mark.id = DateTime.now().millisecondsSinceEpoch.toString();
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
