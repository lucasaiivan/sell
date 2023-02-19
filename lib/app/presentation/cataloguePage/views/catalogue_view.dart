
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/presentation/cataloguePage/controller/catalogue_controller.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart';

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
              floatingActionButton:floatingActionButton(controller: controller),
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
      actions: [
        // iconButton : buscar un producto del cátalogo
        IconButton(icon: const Icon(Icons.search),onPressed: (() => controller.seach(context: context))),
        // buttons : filter list
        PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            onSelected: (selectedValue) {
              controller.catalogueFilter(key: selectedValue);
            },
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: '0', child: Text('Mostrar con stock')),
                  const PopupMenuItem(value: '1', child: Text('Mostrar favoritos')),
                  const PopupMenuItem(value: '2', child: Text('Mostrar con stock bajos')),
                  const PopupMenuItem(value: '3', child: Text('Mostrar todos')),
                ]),
      ],
    );
  }

  Widget body({required BuildContext context}) {
    // controllers
    final CataloguePageController controller = Get.find();

    return Column(
      children: <Widget>[
        Container(
          color: Get.theme.scaffoldBackgroundColor,
          constraints: const BoxConstraints.expand(height: 50),
          child: TabBar(
              controller: controller.tabController,
              labelColor: Get.theme.textTheme.bodyMedium?.color,
              tabs: [
                Tab(child: Row(children: [
                  const Text("Productos"),
                  controller.getCataloProducts.isEmpty?Container():Padding(
                    padding: const EdgeInsets.only(left: 5                                                                                                                                                                                                                ),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal:3,vertical: 1),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue.withOpacity(0.1)), child: Text(controller.getCataloProducts.length.toString(), style: const TextStyle(color: Colors.blue, fontSize: 12),)),
                  ),
                ],)),
                const Tab(text: "Cátegorias"),
              ]),
        ),
        Expanded(
          child: TabBarView(controller: controller.tabController, children: [
            viewCatalogueProductsVerticalList(),
            viewCategory(),
          ]),
        )
      ],
    );
  }

  Widget viewCatalogueProductsVerticalList() {
    // controllers
    final CataloguePageController controller = Get.find();
    final HomeController homeController = Get.find();
 
    // si el cátalogo esta vacio
    if (controller.getCataloProducts.isEmpty) {

      // mostramos las sugerencias de productos en el primer inicio de la aplicación
      if(homeController.catalogUserHuideVisibility){
        return Center(child: controller.widgetSuggestionProduct);
      }

      return const Center(
        child: Text('Sin productos'),
      );
    }

    return Obx(() => ListView.builder(
          itemCount: controller.getCataloProducts.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  homeController.getProfileAccountSelected.subscribed?controller.viewStockAlert:Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed:()=>homeController.showModalBottomSheetSubcription(id: 'stock'), child: const  Text('Control del inventario')),
                        LogoPremium(personalize: true,accentColor: Colors.amber),
                      ],
                    ),
                  ),
                  listTileProduct(item: controller.getCataloProducts[index]),
                ],
              );
            }
            return listTileProduct(item: controller.getCataloProducts[index]);
          },
        ));
  }

  Widget viewCategory() {

    // controllers
    final HomeController controller = Get.find();
    final CataloguePageController cataloguePageController = Get.find();
    //var
    double titleSize = 18;
    Color dividerColor = controller.getDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5);
    Widget divider = Divider(color: dividerColor,thickness: 0.2,height: 0,);

    if (controller.getCatalogueCategoryList.isEmpty) {
      return const Center(
        child: Text('Sin cátegorias'),
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
      
          return index == 0
              ? Column(
                  children: <Widget>[
                    controller.getCatalogueCategoryList.isNotEmpty
                        ? ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            dense: true,
                            title: Text("Mostrar todos",style: TextStyle(fontSize: titleSize,fontWeight: FontWeight.w400)),
                            onTap: () {
                              cataloguePageController.setSelectedCategory =Category(name: 'Cátalogo');
                              // desplaza la vista a la lista de los productos
                              cataloguePageController.tabController.animateTo(0);
                            },
                          )
                        : Container(),
                    divider,
                    listTileCategoryItem(categoria: categoria),
                    divider,
                  ],
                )
              : Column(
                  children: <Widget>[
                    listTileCategoryItem(categoria: categoria),
                    divider,
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
    // description : ListTile con detalles del producto

    //  controller
    final CataloguePageController cataloguePageController = Get.find(); 
    final HomeController homeController = Get.find();
    
    // values
    double titleSize = 18; 
    String alertStockText = item.stock ? (item.quantityStock == 0 ? 'Sin stock' : '') : '';
    Color dividerColor = homeController.getDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5);
    // widgets
    Widget divider = Divider(color: dividerColor,thickness: 0.15,height: 0,);
    Widget description = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // text : nombre de la marca
                Text(
                    item.nameMark,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: Colors.blue),
                  ), 
                Wrap(
                  children: [
                    // text : precio de venta
                    Text(Publications.getFormatoPrecio(monto: item.salePrice),style: TextStyle(fontWeight:FontWeight.w600,color: homeController.getDarkMode?Colors.white:Colors.black )),
                    const SizedBox(width: 5),
                    // text : porcentaje de ganancia
                    Text(item.sProcentaje,style:const TextStyle(color: Colors.green,fontWeight: FontWeight.w500)),
                    SizedBox(width: item.sProcentaje==''?0:5),
                    // text : fecha de la ultima actualización
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle,size: 8, color: Get.theme.dividerColor),
                        const SizedBox(width: 5),
                        Text(Publications.getFechaPublicacion(item.upgrade.toDate(), Timestamp.now().toDate())),
                        const SizedBox(width: 5),
                      ],
                    ),
                    // text : cantidad de ventas
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        item.sales == 0? Container(): Icon(Icons.circle,size: 8, color: Get.theme.dividerColor),
                        item.sales == 0? Container():const SizedBox(width: 5),
                        item.sales == 0? Container(): Text('${item.sales} ${item.sales == 1 ? 'venta' : 'ventas'}'),
                      ],
                    ),
                  ],
                ),
                // text : favorito y control de stock
                Row(
                  children: [
                    item.favorite? const Text('Favorito'):Container(),
                    item.favorite && alertStockText != ''? Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)):Container(),
                    alertStockText == '' ? Container() : Text(alertStockText),
                  ],
                ),
              ],
            );
    dynamic stockWidget = item.stock
                ? Column(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Stock',style: TextStyle(fontSize:10,color: cataloguePageController.getStockColor(productCatalogue: item))),
                    Text(item.quantityStock.toString(),style: TextStyle(color: cataloguePageController.getStockColor(productCatalogue: item))),
                  ],
                )
                : Container();

    return ElasticIn(
      child: InkWell(
        onTap: () => cataloguePageController.toProductEdit(productCatalogue: item),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'avatarProduct',
                    child: ImageAvatarApp(url: item.image,size: 80,favorite: item.favorite)),
                  Flexible( 
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description, maxLines: 1,style: TextStyle(fontSize: titleSize,fontWeight: FontWeight.w400)),
                          description,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: stockWidget,
                  ),
                ],
              ),
            ),
            divider,
          ],
        ),
      ),
    );

    return ElasticIn(
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            onTap: () => cataloguePageController.toProductEdit(productCatalogue: item), 
            leading: ImageAvatarApp(url: item.image,size: 50,favorite: item.favorite),  // image : avatar del producto
            title: Text(item.description, maxLines: 1,style: TextStyle(fontSize: titleSize,fontWeight: FontWeight.w400)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // text : nombre de la marca
                Text(
                    item.nameMark,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: Colors.blue),
                  ), 
                Wrap(
                  children: [
                    // text : precio de venta
                    Text(Publications.getFormatoPrecio(monto: item.salePrice),style: TextStyle(fontWeight:FontWeight.w600,color: homeController.getDarkMode?Colors.white:Colors.black )),
                    const SizedBox(width: 5),
                    // text : porcentaje de ganancia
                    Text(item.sProcentaje,style:const TextStyle(color: Colors.green,fontWeight: FontWeight.w500)),
                    SizedBox(width: item.sProcentaje==''?0:5),
                    // text : fecha de la ultima actualización
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle,size: 8, color: Get.theme.dividerColor),
                        const SizedBox(width: 5),
                        Text(Publications.getFechaPublicacion(item.upgrade.toDate(), Timestamp.now().toDate())),
                        const SizedBox(width: 5),
                      ],
                    ),
                    // text : cantidad de ventas
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        item.sales == 0? Container(): Icon(Icons.circle,size: 8, color: Get.theme.dividerColor),
                        item.sales == 0? Container():const SizedBox(width: 5),
                        item.sales == 0? Container(): Text('${item.sales} ${item.sales == 1 ? 'venta' : 'ventas'}'),
                      ],
                    ),
                  ],
                ),
                // text : favorito y control de stock
                Row(
                  children: [
                    item.favorite? const Text('Favorito'):Container(),
                    item.favorite && alertStockText != ''? Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child: Icon(Icons.circle,size: 8, color: Get.theme.dividerColor)):Container(),
                    alertStockText == '' ? Container() : Text(alertStockText),
                  ],
                ),
              ],
            ),
            // text : stock
            trailing: item.stock
                ? Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Stock',style: TextStyle(fontSize:10,color: cataloguePageController.getStockColor(productCatalogue: item))),
                      Text(item.quantityStock.toString(),style: TextStyle(color: cataloguePageController.getStockColor(productCatalogue: item))),
                    ],
                  ),
                )
                : null,
          ),
          divider,
        ],
      ),
    );
  }

  Widget listTileCategoryItem({required Category categoria}) {
    // controllers
    final CataloguePageController controller = Get.find();

    //  values
    String title = categoria.name.substring(0, 1).toUpperCase() + categoria.name.substring(1);

    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      dense: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w300,fontSize: 18)),
      onTap: () {
        controller.setSelectedCategory = categoria;
        controller.tabController.animateTo(0);
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
      dropdownColor: Get.theme.popupMenuTheme.color,
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
              decoration: const InputDecoration( labelText: 'Categoria', hintText: 'Ej. golosinas'),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(child: const Text('CANCEL'),onPressed: () {Get.back();}),
        TextButton(
            child: loadSave == false? Text(newProduct ? 'GUARDAR' : "ACTUALIZAR"): const CircularProgressIndicator(),
            onPressed: () async {
              if (textEditingController.text != '') {
                // set
                categoria.name = textEditingController.text;
                loadSave = true;
                controller.update();
                // save
                await controller.categoryUpdate(categoria: categoria).whenComplete(() => Get.back()).catchError((error, stackTrace) {
                  loadSave = false;
                  controller.update();
                });
              }
            })
      ],
    ));
  }
}
