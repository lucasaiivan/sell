
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
      initState: (_) {
        // init : inicializamos el controlador
        Get.put(CataloguePageController());
      },
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
    final CataloguePageController catalogueController = Get.find();
    final HomeController homeController = Get.find();
    final bool darkTheme = Theme.of(context).brightness == Brightness.dark;

    // style 
    Color iconTextColor =  homeController.getIsSubscribedPremium==false?Colors.amber: darkTheme?Colors.white:Colors.black;
    Color textColor = darkTheme == false || homeController.getIsSubscribedPremium==false?Colors.white:Colors.black;
    
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(catalogueController.getTextTitleAppBar),
      // bottom : vista de productos seleccionados
      bottom: catalogueController.buttonAppBar,
      actions: [
        // iconButton : buscar un producto del cátalogo
        IconButton(icon: const Icon(Icons.search),onPressed: (() => catalogueController.showSeach(context: context))),
        // buttons : filter list
        catalogueController.filterState?IconButton(onPressed: catalogueController.catalogueFilter, icon: const Icon(Icons.close),padding: const EdgeInsets.all(0))
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Material(
            color: iconTextColor,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 1),
              child: PopupMenuButton( 
                  child: Row(
                    children: [
                      Text('Filtrar',style:TextStyle(color:textColor,fontWeight: FontWeight.w400)),
                      const SizedBox(width: 5),
                    Icon(Icons.filter_list,color: textColor),
                    ],
                  ), 
                  onSelected: (selectedValue) => catalogueController.popupMenuButtonCatalogueFilter(key: selectedValue),
                  itemBuilder: (BuildContext ctx) => [
                        const PopupMenuItem(value: '0', child: Text('Mostrar todos')),
                        const PopupMenuItem(value: '2', child: Text('Mostrar favoritos')),
                        const PopupMenuItem(value: '5', child: Text('Hace más de 5 meses')),
                        homeController.getIsSubscribedPremium?const PopupMenuItem(child: null,height: 0): const PopupMenuItem(value: 'premium',child: Text('Opciones Premium',style: TextStyle(color: Colors.amber,fontWeight: FontWeight.w600),)),
                        PopupMenuItem(value: '1',enabled: catalogueController.homeController.getIsSubscribedPremium, child: const Text('Mostrar con stock')),
                        PopupMenuItem(value: '3',enabled: catalogueController.homeController.getIsSubscribedPremium, child: const Text('Mostrar con stock bajos')),
                        PopupMenuItem(value: '4',enabled: catalogueController.homeController.getIsSubscribedPremium, child: const Text('Actualizado hace más de 2 meses')),
                        // TODO : delete release
                        const PopupMenuItem(value: '6', child: Text('Sin verificación')),
                        const PopupMenuItem(value: '7', child: Text('Cargar toda la Base de Datos')),
                        const PopupMenuItem(value: '8', child: Text('DB sin verificar')),
                      ]),
            ),
          ),
        ),
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
                // tab : productos
                Tab(child: Row(children: [
                  const Flexible(child: Text("Productos",overflow: TextOverflow.ellipsis)),
                  controller.getCataloProducts.isEmpty?Container():Padding(
                    padding: const EdgeInsets.only(left: 5                                                                                                                                                                                                                ),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal:3,vertical: 1),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue.withOpacity(0.1)), child: Text(controller.getCataloProducts.length.toString(), style: const TextStyle(color: Colors.blue, fontSize: 12),)),
                  ),
                ],)),
                // tab : categorias
                const Tab(text: "Cátegorias"),
                // tab : proveedores
                const Tab(text: "Proveedores"),
              ]),
        ),
        Flexible(
          child: TabBarView(controller: controller.tabController, children: [
            viewCatalogue(),
            viewCategory(),
            viewProvider(),
          ]),
        )
      ],
    );
  }

  Widget viewCatalogue() {
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
                  homeController.getIsSubscribedPremium?controller.viewStockAlert:Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed:()=>homeController.showModalBottomSheetSubcription(id: 'stock'), child: const  Text('Controla tu inventario')),
                        LogoPremium(id: 'stock',personalize: true,accentColor: Colors.amber),
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
 // view : vista de la lista de categorias 
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
  // view : vista de la lista de proveedores
  Widget viewProvider() {
    // controllers
    final HomeController controller = Get.find();
    final CataloguePageController cataloguePageController = Get.find(); 
    //var
    double titleSize = 18;
    Color dividerColor = controller.getDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5);
    Widget divider = Divider(color: dividerColor,thickness: 0.2,height: 0,);

    if (controller.getProviderList.isEmpty) {
      return const Center(
        child: Text('Sin proveedores'),
      );
    }
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shrinkWrap: true,
        itemCount: controller.getProviderList.length,
        itemBuilder: (BuildContext context, int index) {
          
          //get
          Provider provider = controller.getProviderList[index]; 
      
          return index == 0
            ? Column(
                children: <Widget>[
                  controller.getProviderList.isNotEmpty
                      ? ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                          dense: true,
                          title: Text("Mostrar todos",style: TextStyle(fontSize: titleSize,fontWeight: FontWeight.w400)),
                          onTap: () { 
                            
                            cataloguePageController.catalogueFilter();  // mostramos todos los productos 
                            cataloguePageController.tabController.animateTo(0); // desplaza la vista a la lista de los productos

                          },
                        )
                      : Container(),
                  divider,
                  listTileProviderItem(provider: provider),
                  divider,
                ],
              )
            :Column(
              children: <Widget>[
                listTileProviderItem(provider: provider),
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
        backgroundColor: controller.homeController.getUserAnonymous?Colors.grey:Colors.blue,
        onPressed: (){ 

          switch (controller.tabController.index) {
            case 0:
              controller.toSeachProduct();
              break;
            case 1:
              showDialogSetCategoria(categoria: Category());
              break;
            case 2:
              showDialogSetProvider(supplier: Provider());
              break;
            default:
          }
        },
        child: const Icon(Icons.add,color: Colors.white));
  }

  Widget listTileProduct({required ProductCatalogue item}) {
    // description : ListTile con detalles del producto

    //  controllers
    final CataloguePageController catalogueController = Get.find(); 
    final HomeController homeController = Get.find();
    
    // var
    double titleSize = 16; 
    String alertStockText = item.stock ? (item.quantityStock == 0 ? 'Sin stock' : '') : ''; 
    String valueDataUpdate ='Actualizado ${Publications.getFechaPublicacion(fechaPublicacion:item.upgrade.toDate(),fechaActual:  Timestamp.now().toDate() )}'; 

    // styles
    final Color primaryTextColor  = Get.isDarkMode?Colors.white:Colors.black;
    final Color secundayTextColor = Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black.withOpacity(0.5);
    final TextStyle textStylePrimery = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);
    final TextStyle textStyleSecundary = TextStyle(color: secundayTextColor,fontWeight: FontWeight.w400);
    // widgets
    final Widget dividerCircle = ComponentApp().dividerDot(color: secundayTextColor);
    Widget divider = ComponentApp().divider();

    // widgets 
    Widget description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // view : marca del producto y proveedor
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //text : nombre de la marca
            item.nameMark==''?Container():Text(
                item.nameMark,
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: TextStyle(color: item.verified?Colors.blue:null),
              ),
            //text : nombre del proveedor
            item.nameProvider==''?Container(): dividerCircle,
            item.nameProvider==''?Container():Flexible(
              child: Text(
                  item.nameProvider,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyleSecundary,
                ),
            ),
          ],
        ), 
        // view : texts
        homeController.getIsSubscribedPremium==false?Container():
        item.stock?Row(
          children: [
            Text(item.quantityStock.toString(),style: textStylePrimery.copyWith(color: catalogueController.getStockColor(productCatalogue: item,color: textStyleSecundary.color as Color))),
            Text(' Disponible ',style: textStylePrimery.copyWith(color: catalogueController.getStockColor(productCatalogue: item,color: textStyleSecundary.color as Color))),
          ],
        ):Container(),
        // text : favorito
        Row(
          children: [
            item.favorite? Text('Favorito',style: TextStyle(color: Colors.yellow.shade800)):Container(),
            item.favorite && alertStockText != ''? dividerCircle:Container(),
            alertStockText == '' ? Container() : Text(alertStockText),
          ],
        ),
        // text : fecha de la ultima actualización
        Text( valueDataUpdate ,style: textStyleSecundary.copyWith(fontSize: 12)),
      ],
    );
    dynamic priceWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // text : monto de la ganancia
        item.getBenefits==''?Container():Text(item.getBenefits,style:const TextStyle(color: Colors.green,fontWeight: FontWeight.w300)),
        // text : porcentaje de ganancia
        item.getPorcentage==''?Container():Opacity(opacity:0.7,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_upward_rounded,size: 14,color: Colors.green),
              Text(item.getPorcentage,style:const TextStyle(color: Colors.green,fontWeight: FontWeight.w300)),
            ],
          )),
        // text : precio de venta
        Text(Publications.getFormatoPrecio(monto: item.salePrice),style: TextStyle(fontSize: 18,color: homeController.getDarkMode?Colors.white:Colors.black )),
        const SizedBox(width: 5),
        
      ],
    );

    return ElasticIn(
      child: InkWell(
        onTap: homeController.getUserAnonymous?null: (){
          // condition : si no hay productos seleccionados
          if(catalogueController.getProductsSelectedList.isEmpty){
            // navigation : editar producto
            catalogueController.toNavigationProductEdit(productCatalogue: item); 
          }else{ 
            // selecciona el producto
            catalogueController.selectedProduct(product: item); 
          } 

        },
        onLongPress: (){
          catalogueController.selectedProduct(product: item);
        },
        child: Container(
          // style : color de fondo si el producto esta seleccionado o no
          color: catalogueController.isSelectedProduct(code: item.code)?Colors.blue.withOpacity(0.1):Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImageProductAvatarApp(url: item.image,size: 80,favorite: item.favorite),
                    Flexible( 
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Text(item.description, maxLines: 1,overflow:TextOverflow.ellipsis,style: textStylePrimery.copyWith( fontSize: titleSize)),
                            description,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: priceWidget,
                    ),
                  ],
                ),
              ),
              divider,
            ],
          ),
        ),
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
      // view : texto del nombre de la categoria y cantidad de productos que coinciden con este id
      title: Row(
        children: [
          // text : nombre de la categoria
          Flexible(child: Text(title ,maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w300,fontSize: 18))),
          // view : burbuja de cantidad de productos del catalgoue que coinciden con este id
          controller.readCoincidencesToCatalogue(idCategory: categoria.id) == 0 ?Container():Padding(
            padding: const EdgeInsets.only(left: 5                                                                                                                                                                                                                ),
            child: Container(padding: const EdgeInsets.symmetric(horizontal:3,vertical: 1),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue.withOpacity(0.1)), child: Text(controller.readCoincidencesToCatalogue(idCategory: categoria.id).toString(), style: const TextStyle(color: Colors.blue, fontSize: 12),)),
          ),
        ],
      ),
      onTap: () {
        controller.setSelectedCategory = categoria;
        controller.tabController.animateTo(0);
      },
      trailing: dropdownButtonCategory(categoria: categoria),
    );
  }
  Widget listTileProviderItem({required Provider provider}) { 

    // controllers
    final CataloguePageController controller = Get.find();

    //  values
    String title = provider.name==''?'': provider.name.substring(0, 1).toUpperCase() + provider.name.substring(1);

    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      dense: true,
      // view : texto del nombre del proveedor y cantidad de productos que coinciden con este id
      title: Row(
        children: [
          // text : nombre del proveedor
          Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w300,fontSize: 18))),
          // view : burbuja de cantidad de productos del catalgoue que coinciden con este id
          controller.readCoincidencesToCatalogue(idProvider: provider.id) == 0 ?Container():Padding(
            padding: const EdgeInsets.only(left: 5                                                                                                                                                                                                                ),
            child: Container(padding: const EdgeInsets.symmetric(horizontal:3,vertical: 1),decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue.withOpacity(0.1)), child: Text(controller.readCoincidencesToCatalogue(idProvider: provider.id).toString(), style: const TextStyle(color: Colors.blue, fontSize: 12),)),
          ),
        ],
      ),
      onTap: () { 
        controller.setSelectedSupplier = provider;
        controller.tabController.animateTo(0);
      },  
      trailing: dropdownButtonSupplier(supplier: provider),
    );
  }
  // menu options
  Widget dropdownButtonSupplier({required Provider supplier}) {
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
            showDialogSetProvider(supplier: supplier);
            break;
          case "eliminar":
            Get.defaultDialog(
              title: 'Alerta',
              middleText: '¿Desea continuar eliminando este proveedor?',
              confirm: TextButton.icon(
                  onPressed: () async {
                    controller.providerDelete(idSupplier: supplier.id);
                    Get.back();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Aceptar')),
              cancel: TextButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar')),
            );
            break;
        }
      },
    );
  }
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
  showDialogSetProvider({required Provider supplier}) async {
    
    // controllers
    final CataloguePageController cataloguePageController = Get.find();
    TextEditingController textEditingController = TextEditingController(text: supplier.name);
    // var
    bool loadSave = false; 

    if (supplier.id == '') { 
      supplier = Provider();
      supplier.id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    await Get.dialog(AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: textEditingController,
              autofocus: true,
              decoration: const InputDecoration( labelText: 'Proveedor', hintText: 'Ej. Proveedor de bebidas'),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(child: const Text('CANCEL'),onPressed: () {Get.back();}),
        TextButton(
            child: loadSave == false?const Text('SAVE'):const CircularProgressIndicator(),
            onPressed: () async {
              if (loadSave == false) {
                loadSave = true;
                supplier.name = textEditingController.text;
                await cataloguePageController.providerSave(provider: supplier);
                Get.back();
              }
            })
      ],
    ));
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
