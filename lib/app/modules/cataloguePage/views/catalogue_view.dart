import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/cataloguePage/controller/catalogue_controller.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';
import '../../../utils/dynamicTheme_lb.dart';

class CataloguePage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  CataloguePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CataloguePageController>(
      init: CataloguePageController(),
      initState: (_) {},
      builder: (controller) {
        return Obx(() => Scaffold(
              appBar: appbar(context: context),
              drawer: drawerApp(),
              body: body(context: context),
              floatingActionButton:
                  floatingActionButton(controller: controller),
            ));
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required BuildContext context}) {
    // controllers
    final CataloguePageController controller = Get.find();

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(controller.getTextTitleAppBar),
    );
  }

  Widget body({required BuildContext context}) {
    // controllers
    final CataloguePageController controller = Get.find();

    return Column(
      children: <Widget>[
        Container(
          constraints: const BoxConstraints.expand(height: 50),
          child: TabBar(
              controller: controller.tabController,
              labelColor: Get.theme.textTheme.bodyText1?.color,
              tabs: [
                Tab(text: "${controller.getCataloProducts.length} productos"),
                const Tab(text: "Cátegorias"),
              ]),
        ),
        Expanded(
          child: TabBarView(controller: controller.tabController, children: [
            widgetListVertical(),
            viewCategory(),
          ]),
        )
      ],
    );
  }

  Widget widgetListVertical() {
    // controllers
    final CataloguePageController controller = Get.find();

    return Obx(() => ListView.builder(
          itemCount: controller.getCataloProducts.length,
          itemBuilder: (context, index) {
            return listTileProduct(item: controller.getCataloProducts[index]);
          },
        ));
  }

  Widget viewCategory() {
    // controllers
    final HomeController controller = Get.find();
    final CataloguePageController cataloguePageController = Get.find();

    if (controller.getCatalogueCategoryList.isEmpty) {
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
        itemCount: controller.getCatalogueCategoryList.length,
        itemBuilder: (BuildContext context, int index) {
          //get
          Category categoria = controller.getCatalogueCategoryList[index];
          MaterialColor color = Utils.getRandomColor();

          return index == 0
              ? Column(
                  children: <Widget>[
                    controller.getCatalogueCategoryList.isNotEmpty
                        ? ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 12.0),
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              radius: 24.0,
                              child: Icon(Icons.all_inclusive, color: color),
                            ),
                            dense: true,
                            title: Text("Mostrar todos",
                                style: Get.theme.textTheme.bodyText1),
                            onTap: () {
                              cataloguePageController.setSelectedCategory =
                                  Category(name: 'Cátalogo');
                            },
                          )
                        : Container(),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0),
                    listTileCategoryItem(categoria: categoria),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0),
                  ],
                )
              : Column(
                  children: <Widget>[
                    listTileCategoryItem(categoria: categoria),
                    const Divider(endIndent: 0.0, indent: 0.0, height: 0.0),
                  ],
                );
        },
      ),
    );
  }

  // WIDGETS COMPONENTS
  Widget floatingActionButton({required CataloguePageController controller}) {
    return FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => controller.tabController.index == 0
            ? controller.toSeachProduct()
            : showDialogSetCategoria(categoria: Category()),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ));
  }

  Widget listTileProduct({required ProductCatalogue item}) {
    //  controller
    final CataloguePageController cataloguePageController = Get.find();
    // values
    Color tileColor = item.stock
        ? (item.quantityStock == 0
            ? Colors.red.withOpacity(0.5)
            : Colors.transparent)
        : Colors.transparent;
    String alertStockText =
        item.stock ? (item.quantityStock == 0 ? 'Sin stock' : '') : '';

    return ElasticIn(
      child: Column(
        children: [
          ListTile(
            tileColor: tileColor,
            contentPadding: const EdgeInsets.all(12),
            onTap: () => cataloguePageController.toProductEdit(productCatalogue: item),
            title: Text(item.description, maxLines: 1),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(Publications.getFormatoPrecio(monto: item.salePrice)),
                    item.sales == 0
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.circle,
                                size: 8, color: Get.theme.dividerColor),
                          ),
                    item.sales == 0
                        ? Container()
                        : Text(
                            '${item.sales} ${item.sales == 1 ? 'venta' : 'ventas'}'),
                  ],
                ),
                alertStockText == '' ? Container() : Text(alertStockText),
              ],
            ),
            leading: CachedNetworkImage(
              imageUrl: item.image,
              placeholder: (context, url) =>
                  CircleAvatar(backgroundColor: Get.theme.dividerColor),
              imageBuilder: (context, image) => CircleAvatar(
                backgroundImage: image,
              ),
              errorWidget: (context, url, error) =>
                  CircleAvatar(backgroundColor: Get.theme.dividerColor),
            ),
            trailing: item.stock
                ? Material(
                    color: Get.theme.dividerColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item.quantityStock.toString()),
                    ),
                  )
                : null,
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  Widget listTileCategoryItem({required Category categoria}) {
    // controllers
    final CataloguePageController controller = Get.find();

    //  values
    String title =
        categoria.name.substring(0, 1).toUpperCase() + categoria.name.substring(1);

    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      dense: true,
      title: Text(title,
          style: Get.theme.textTheme.bodyText1),
      onTap: () {
        controller.setSelectedCategory = categoria;
      },
      trailing: dropdownButtonCategory(categoria: categoria),
    );
  }

  // menu options
  Widget dropdownButtonCategory({required Category categoria}) {
    final CataloguePageController controller = Get.find();

    return DropdownButton<String>(
      icon: const Icon(Icons.more_vert),
      value: null,
      elevation: 10,
      underline: Container(),
      items: const [
        DropdownMenuItem(
          value: 'editar',
          child: Text("Editar"),
        ),
        DropdownMenuItem(
          value: 'eliminar',
          child: Text("Eliminar"),
        ),
      ],
      onChanged: (value) async {
        switch (value) {
          case "editar":
            showDialogSetCategoria(categoria: categoria);
            break;
          case "eliminar":
            Get.defaultDialog(
              title: 'Alerta',
              middleText: '¿Desea continuar eliminando esta categoría?',
              confirm: TextButton.icon(
                  onPressed: () async {
                    controller.categoryDelete(idCategory: categoria.id);
                    Get.back();
                  },
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text('Si, Eliminar')),
              cancel: TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.delete),
                  label: const Text('Descartar')),
            );
            break;
        }
      },
    );
  }

  showDialogSetCategoria({required Category categoria}) async {
    final CataloguePageController controller = Get.find();
    bool loadSave = false;
    bool newProduct = false;
    TextEditingController textEditingController =
        TextEditingController(text: categoria.name);

    if (categoria.id == '') {
      newProduct = true;
      categoria = Category();
      categoria.id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await Get.dialog(AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Categoria', hintText: 'Ej. golosinas'),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: const Text('CANCEL'),
            onPressed: () {
              Get.back();
            }),
        TextButton(
            child: loadSave == false
                ? Text(newProduct ? 'GUARDAR' : "ACTUALIZAR")
                : const CircularProgressIndicator(),
            onPressed: () async {
              if (textEditingController.text != '') {
                // set
                categoria.name = textEditingController.text;
                loadSave = true;
                controller.update();
                // save
                await controller
                    .categoryUpdate(categoria: categoria)
                    .whenComplete(() => Get.back())
                    .catchError((error, stackTrace) {
                  loadSave = false;
                  controller.update();
                });
              }
            })
      ],
    ));
  }

  Widget get widgetProducts {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey.withOpacity(0.1),
              ),
            );
            /* return CachedNetworkImage(
                      imageUrl: cataloguePageController
                          .getCataloProducts[index].image,
                      placeholder: (context, url) =>
                          CircleAvatar(backgroundColor: Get.theme.dividerColor),
                      imageBuilder: (context, image) => CircleAvatar(
                        backgroundImage: image,
                      ),
                      errorWidget: (context, url, error) =>
                          CircleAvatar(backgroundColor: Get.theme.dividerColor),
                    ); */
          },
        ),
      ),
    );
  }
}
