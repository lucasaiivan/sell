
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
    
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //title: Text(catalogueController.getTextTitleAppBar),
      title: ComponentApp().buttonAppbar(
        context:  context,
        onTap: () => catalogueController.showSeach(context: context), 
        text: 'Catálogo',
        iconLeading: Icons.search,
        colorBackground: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        colorAccent: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.7),
        ), 
      actions: [ 
        // buttons : filter list
        PopupMenuButton( 
          icon: ComponentApp().buttonAppbar(
            context: context,
            text:  catalogueController.getTextFilter,
            iconTrailing: Icons.filter_list,  
          ), 
            onSelected: (selectedValue) => catalogueController.popupMenuButtonCatalogueFilter(key: selectedValue),
            itemBuilder: (BuildContext ctx) => [
                  const PopupMenuItem(value: '0', child: Text('Mostrar todos')),
                  const PopupMenuItem(value: '2', child: Text('Favoritos')),
                  homeController.getIsSubscribedPremium?const PopupMenuItem(child: null,height: 0): const PopupMenuItem(value: 'premium',child: Text('Opciones Premium',style: TextStyle(color: Colors.amber,fontWeight: FontWeight.w600),)),
                  PopupMenuItem(value: '1',enabled: catalogueController.homeController.getIsSubscribedPremium, child: const Text('Con stock')),
                  PopupMenuItem(value: '3',enabled: catalogueController.homeController.getIsSubscribedPremium, child: const Text('Con stock bajos')),
                  PopupMenuItem(value: '4',enabled: catalogueController.homeController.getIsSubscribedPremium, child: const Text('Actualizado hace más de 2 meses')),
                  const PopupMenuItem(value: '5', child: Text('Actualizado hace más de 5 meses')),
                  // TODO :release :  disabled options
                  //const PopupMenuItem(value: '6', child: Text('Sin verificación')),
                  //const PopupMenuItem(value: '7', child: Text('Cargar toda la Base de Datos')),
                  //const PopupMenuItem(value: '8', child: Text('DB sin verificar')),
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
              tabs: const [
                // tab : productos
                Tab(text: 'Productos'),
                // tab : categorias
                Tab(text: "Cátegorias"),
                // tab : proveedores
                Tab(text: "Proveedores"),
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

    // var : cantidad de articulos del catalogo
    String totalItemsCatalogue = controller.getTotalItemsCatalogue;
    // var : total del inventario
    String totalInventory = controller.getInventoryTotal;
    // var : valor total del inventario
    String totalInventoryValue = controller.getTotalInventory;

    // si el cátalogo esta vacio
    if (controller.getCataloProducts.isEmpty) { 

      return const Center(
        child: Text('Sin productos'),
      );
    }
    // widget 
    Widget infoChips =  Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap( 
        spacing: 10,
        children: [
          // chip : cantidad de articulos del catalogo y filtrados
          Chip(  
            side: const BorderSide(color: Colors.transparent), 
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(totalItemsCatalogue,style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Artículos',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),  
          // conditiom : comprobar subscripcion premium
          !homeController.getIsSubscribedPremium?const SizedBox():
          Chip(  
            side: BorderSide(color: Get.theme.colorScheme.secondary.withOpacity(0.0)),   
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(totalInventory,style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Inventario',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // chip : monto total del inventario
          Chip(  
            side: BorderSide(color: Get.theme.colorScheme.secondary.withOpacity(0.0)),   
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(totalInventoryValue,style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Valor del inventario',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
      
        ],
      ),
    );

    return Obx(() => ListView.builder(
          itemCount: controller.getCataloProducts.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* // text : cantidad de veces que se consulta la db del catalogo
                  homeController.dbQueryAmoun==0?Container():Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('query database: ${homeController.dbQueryAmoun}',style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w300)),
                  ), */
                  // view : control de inventario
                  homeController.getIsSubscribedPremium?controller.viewStockAlert:Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed:()=>homeController.showModalBottomSheetSubcription(id: 'stock'), child: const  Text('Controla tu inventario')),
                        LogoPremium(id: 'stock'),
                      ],
                    ),
                  ),
                  // view : informacion del inventario
                  controller.getCataloProducts.isNotEmpty?infoChips:Container(), 
                  // view : lista de productos
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

    // var
    Widget icon = controller.getProductsSelectedList.isNotEmpty?Text(controller.getProductsSelectedList.length.toString(),style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.white),): const Icon(Icons.add,color: Colors.white);
    return Row(
      mainAxisAlignment:  MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min, 
      children: [
        // button : limpia la lista de productos seleccionados
        controller.getProductsSelectedList.isEmpty?const Spacer():
        FloatingActionButton( 
            backgroundColor:Colors.grey,
            onPressed: (){    
              controller.getProductsSelectedList.clear();
            },
            child: const Icon(Icons.clear,color: Colors.white),
          ),
        controller.getProductsSelectedList.isEmpty?const Spacer():const SizedBox(width: 10),
        // button : multifuncion (agregar producto, categoria o proveedor y vista de productos seleccionados)
        FloatingActionButton( 
            backgroundColor: controller.homeController.getUserAnonymous?Colors.grey:Colors.blue,
            onPressed: (){  
              // condition : si hay productos seleccionados
              if(controller.getProductsSelectedList.isNotEmpty){
                // dialog : vista de productos seleccionados
                Get.dialog( const ViewProductsSelected()); 
                return;
              } 
              switch (controller.tabController.index) {
                case 0:
                // navigation : agregar producto
                  controller.toSeachProduct();
                  break;
                case 1:
                // dialog : agregar categoria
                  showDialogSetCategoria(categoria: Category());
                  break;
                case 2:
                // dialog : agregar proveedor
                  showDialogSetProvider(supplier: Provider());
                  break;
                default:
              }
            },
            child: icon,
          ),
      ],
    );
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

    // widgets 
    Widget description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // view : marca del producto y proveedor
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            item.verified?const Icon(Icons.verified,size: 11,color: Colors.blue):Container(),
            item.verified ? const SizedBox(width:1):Container(),
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
        //  text : codigo
        Text(item.code,style: textStyleSecundary.copyWith(fontSize: 12)),
        // text : stock
        alertStockText == '' ? Container() : Text(alertStockText),
        // text : fecha de la ultima actualización
        Text( valueDataUpdate ,style: textStyleSecundary.copyWith(fontSize: 12)),
      ],
    );
    dynamic priceWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // text : monto de la ganancia
        item.getBenefits==''?Container():Text(item.getBenefits,style:const TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
        // text : porcentaje de ganancia
        item.getPorcentageFormat==''?Container():Opacity(opacity:0.7,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_upward_rounded,size: 14,color: Colors.green),
              Text(item.getPorcentageFormat,style:const TextStyle(color: Colors.green,fontWeight: FontWeight.w300)),
            ],
          )),
        
        
      ],
    );

    return ElasticIn(
      child: InkWell(
        onTap: homeController.getUserAnonymous?null: (){
          // condition : si no hay productos seleccionados
          if(catalogueController.getProductsSelectedList.isEmpty){
            // navigation : editar producto
            catalogueController.toNavigationProduct(productCatalogue: item);
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
                    // image : avatar del producto
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal:item.image==''?27:0),
                      child: ImageProductAvatarApp(url:item.local?'': item.image,size:item.image==''?25: 80 ),
                    ),
                    // view : contenido
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // view : description y icon favorite
                                Flexible( 
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, 
                                    children: [
                                      // text and icon of favorite
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          !item.favorite?Container():const Icon(Icons.star_purple500_sharp,size: 12,color: Colors.orange),
                                          !item.favorite?Container():const SizedBox(width: 2),
                                          Flexible(child: Text(item.description, maxLines: 1,overflow:TextOverflow.ellipsis,style: textStylePrimery.copyWith( fontSize: titleSize))),
                                        ],
                                      ),
                                      description,
                                    ],
                                  ),
                                ),
                                // view : datos de precios y ganancia
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: priceWidget,
                                ),
                              ],
                            ),
                            // 
                            // text : precio de venta
                            Row(
                              children: [
                                Text(Publications.getFormatoPrecio(value: item.salePrice),style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold,color: homeController.getDarkMode?Colors.white:Colors.black )),
                                const Spacer(),
                                // button : editar producto
                                OutlinedButton(
                                  onPressed: ()=>catalogueController.toNavigationProductEdit(productCatalogue: item), 
                                  child: Text('Editar',style: TextStyle(color: Get.isDarkMode?Colors.white:Colors.black))
                                ),
                              ],
                            ),
                            // text : stock
                            homeController.getIsSubscribedPremium==false?Container():
                            item.stock?Row(
                              children: [
                                Text(item.quantityStock.toString(),style: textStylePrimery.copyWith(color: catalogueController.getStockColor(productCatalogue: item,color: textStyleSecundary.color as Color))),
                                Text(' Disponible ',style: textStylePrimery.copyWith(color: catalogueController.getStockColor(productCatalogue: item,color: textStyleSecundary.color as Color))),
                              ],
                            ):Container(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Opacity(opacity: 0.3,child: Divider(height: 0)),
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
    
    // controllers
    final HomeController homeController = Get.find();

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
                    homeController.providerDelete(idProvider: supplier.id);
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
    
    // controllers 
    final HomeController homeController = Get.find();

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
                    homeController.categoryDelete(idCategory: categoria.id);
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
    final HomeController homeController = Get.find();
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
            child: loadSave == false?const Text('GUARDAR'):const CircularProgressIndicator(),
            onPressed: () async {
              if (loadSave == false) {
                loadSave = true;
                supplier.name = textEditingController.text;
                await homeController.providerSave(provider: supplier);
                Get.back();
              }
            })
      ],
    ));
  }
  showDialogSetCategoria({required Category categoria}) async {

    // controllers
    final HomeController homeController = Get.find();
    TextEditingController textEditingController = TextEditingController(text: categoria.name);
    // var
    bool loadSave = false;
    bool newProduct = false;

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
                homeController.update();
                // save
                await homeController.categoryUpdate(categoria: categoria).whenComplete(() => Get.back()).catchError((error, stackTrace) {
                  loadSave = false;
                  homeController.update();
                });
              }
            })
      ],
    ));
  }
}
