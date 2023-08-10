
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/widgets_utils.dart'; 
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/data/datasource/database_cloud.dart'; 
import '../../../core/routes/app_pages.dart'; 
import '../../../core/utils/fuctions.dart';
import '../../../domain/entities/catalogo_model.dart'; 
import '../views/catalogueSeach_view.dart';

class CataloguePageController extends GetxController with GetSingleTickerProviderStateMixin {
  
  // others controllers
  final HomeController homeController = Get.find();
  late TabController tabController;

  // color del texto de disponibilidad
   Color? getStockColor( {required ProductCatalogue productCatalogue,Color color = Colors.black }){

    // var 
    Color? color = Get.theme.listTileTheme.textColor;

    // disponibilidad baja
    if( productCatalogue.stock){
      if( productCatalogue.quantityStock <= productCatalogue.alertStock ){
        color = Colors.red;
      }
    }

    return color;
  }
  // titulo del appbar
  String _titleAppBar = 'Cátalogo';
  String get getTextTitleAppBar => _titleAppBar;
  set setTitleAppBar(String value) => _titleAppBar = value;

  // state filter activado 
  bool filterState = false;

  // proveedor seleccionado para filtrar en el cátalogo 
  set setSelectedSupplier(Provider value) { 
    setTitleAppBar  = value.description;
    catalogueFilter(filter: value.id);
    update();
  }

  // categoria seleccionada para filtrar en el cátalogo 
  set setSelectedCategory(Category value) { 
    setTitleAppBar = value.name;
    catalogueFilter(filter: value.id);
    update();
  }

  // catalogue
  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts => _catalogueBusiness;
  set setCatalogueProducts(List<ProductCatalogue> products) {
    _catalogueBusiness.value = products;
    //...filter
  }
  // items seleccionados del cátalogo
  final RxList<ProductCatalogue> _productsSelectedList = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getProductsSelectedList => _productsSelectedList; 

  
  
  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(vsync: this, length:3);
    readProductsCatalogue();
  }

  @override
  void onClose() {}

  // FIREBASE
  void readProductsCatalogue() {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    setCatalogueProducts = homeController.getCataloProducts;
  }
  //
  // FUCTIONS CATALOGUE VIEW 
  //
  void catalogueFilter({String filter = ''}) {

    List<ProductCatalogue> list = [];

    //filter
    if (filter != '') {
      filterState = true;
      for (var element in homeController.getCataloProducts) {
        if (filter == element.category || filter == element.provider) {
          list.add(element);
        }
      }
    } else {
      setTitleAppBar = 'Cátalogo';
      filterState = false;
      list = homeController.getCataloProducts;
    }
    // set
    setCatalogueProducts = list;
  }
  void popupMenuButtonCatalogueFilter({required String key}) {
    List<ProductCatalogue> list = [];

    //filter
    if( key==''){
        setTitleAppBar = 'Cátalogo';
        list = homeController.getCataloProducts;
      }else{
        switch(key){
          case 'premium':
            homeController.showModalBottomSheetSubcription(id:'analytic');
            break;
          case '0': // Mostrar todos
            setTitleAppBar = 'Cátalogo';
            list = homeController.getCataloProducts;
            break; 
          case '1': //  Mostrar productos con stock
            setTitleAppBar = 'Stock';
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.stock)listSFilter.add(item);}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            break;
          case '2': //  Mostrar productos favoritos
            setTitleAppBar = 'Favoritos';
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.favorite)listSFilter.add(item);}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            break;
          case '3': // Mostrar productos con stock bajos
            setTitleAppBar = 'Stock Bajo';
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.stock){if(item.quantityStock<=item.alertStock){listSFilter.add(item);}}}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            break;
          case '4': // Mostrar productos actualizados hace más de 90 días
            setTitleAppBar = 'Filtro';
            list = homeController.getCataloProducts.where((producto) {
              DateTime fechaActualizacion = producto.upgrade.toDate();
              return fechaActualizacion.isBefore(DateTime.now().subtract( const Duration(days: 90)));
            }).toList();
          
            break;
          case '5': // Mostrar productos actualizados hace más de 150 días
            setTitleAppBar = 'Filtro';
            list = homeController.getCataloProducts.where((producto) {
              DateTime fechaActualizacion = producto.upgrade.toDate();
              return fechaActualizacion.isBefore( DateTime.now().subtract( const Duration(days: 5 * 30)) );
            }).toList(); 
          break; 

          case '6': // mostrar los productos que no estan verificados
            setTitleAppBar = 'Sin verificar';
            list = homeController.getCataloProducts.where((producto) {
              return producto.verified==false;
            }).toList();
          break;
          case '7': // obtener los los porductos de la base de datos publica 'Database.readProductsFuture()'
            setTitleAppBar = 'Base de Datos'; 
            // obtenemos todos los documentos de la base de datos publica
            Database.readProductsFuture().then((value) {
              // obtenemos los productos de la cuenta del negocio  
              //
              // condition : si la lista de productos no esta vacia
              if (value.docs.isNotEmpty) {
                for (var element in value.docs) {
                  // condition : si el producto no esta en la lista de productos del negocio
                  if(element.data().containsKey('id')){ 
                    // get : object product
                    ProductCatalogue product = Product.fromMap( element.data() ).convertProductCatalogue();
                    // add : agrega el producto a la lista  
                    if(isProductCatalogue(id: product.id) == false){
                      list.add(product);
                    }
                  }
                  
                } 
                update();
              } 
            });
          break;
          case '8': // obtener los los porductos de la base de datos publica 'Database.readProductsFuture()'
            setTitleAppBar = 'Productos sin verificar'; 
            // obtenemos todos los documentos de la base de datos publica
            Database.readProductsFutureNoVerified().then((value) {
              // obtenemos los productos de la cuenta del negocio   
              //
              // condition : si la lista de productos no esta vacia
              if (value.docs.isNotEmpty) {
                for (var element in value.docs) {
                  // condition : si el producto no esta en la lista de productos del negocio
                  if(element.data().containsKey('id')){ 
                    // get : object product
                    ProductCatalogue product = Product.fromMap( element.data() ).convertProductCatalogue(); 
                    // add
                    if(isProductCatalogue(id: product.id) == false){
                      list.add(product);
                    } 
                  }
                  
                } 
                update();
              } 
            });
          break;
          
        }
      }
    // set
    setCatalogueProducts = list;
  }
  // si el producto esta en el catalogo devuelve el precio de venta
  bool isProductCatalogue({required String id}) { 
    for (var element in homeController.getCataloProducts) {
      if (element.id == id) {
        return true; 
      }
    }
    return false;
  }

  void toProductNew({required String id}) {
    //values default
    ProductCatalogue productCatalogue = ProductCatalogue(id: id, code: id, creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
    // navega hacia una nueva vista para crear un nuevo producto
    Get.toNamed(Routes.EDITPRODUCT,arguments: {'new': true, 'product': productCatalogue});
  }

  void toSeachProduct() {
    Get.toNamed(Routes.SEACH_PRODUCT, arguments: {'id': ''});
  }

  Future<void> categoryDelete({required String idCategory}) async => await Database.refFirestoreCategory(idAccount: homeController.getProfileAccountSelected.id).doc(idCategory).delete();
  Future<void> categoryUpdate({required Category categoria}) async {

    // refactorizamos el nombre de la cátegoria
    String name = categoria.name.substring(0, 1).toUpperCase() + categoria.name.substring(1);
    categoria.name=name;
    // firestore : reference
    var documentReferencer = Database.refFirestoreCategory(idAccount: homeController.getProfileAccountSelected.id).doc(categoria.id);
    // firestore : Actualizamos los datos
    documentReferencer.set(Map<String, dynamic>.from(categoria.toJson()),SetOptions(merge: true));
  }
  Future<void> providerDelete({required String idSupplier}) async => await Database.refFirestoreProvider(idAccount: homeController.getProfileAccountSelected.id).doc(idSupplier).delete();
  Future<void> providerSave({required Provider provider}) async {
    // firestore : reference
    var documentReferencer = Database.refFirestoreProvider(idAccount: homeController.getProfileAccountSelected.id).doc(provider.id);
    // firestore : Actualizamos los datos
    documentReferencer.set(Map<String, dynamic>.from(provider.toJson()),SetOptions(merge: true));
  }
  void toNavigationProductEdit({required ProductCatalogue productCatalogue}) {
    Get.toNamed(Routes.EDITPRODUCT, arguments: {'product': productCatalogue.copyWith()});
  }
  void showSeach({required BuildContext context}) {
    // dialog : Busca entre los productos de mi catálogo 
    Get.dialog( const ViewSeachProductsCataloguie()); 
  }
  void filterAlertStock() {

    // obtenemos una lista nueva con los productos que tienen un stock
    List<ProductCatalogue> stockActivateList = [];
    for (var element in getCataloProducts) {
      if (element.stock) {
        stockActivateList.add(element);
      }
    }
    stockActivateList
        .sort((a, b) => a.quantityStock.compareTo(b.quantityStock));

    // obtenemos una lista nueva con los productos que no tienen el stock activado
    List<ProductCatalogue> stockDesactivateList = [];
    for (var element in getCataloProducts) {
      if (element.stock == false) {
        stockDesactivateList.add(element);
      }
    }
    stockDesactivateList.sort((a, b) => b.quantityStock.compareTo(a.quantityStock));
    // creamos una nueva lista con todos los productos ya filtrados
    List<ProductCatalogue> newFilterList = [];
    for (var element in stockActivateList) {
      newFilterList.add(element);
    }
    for (var element in stockDesactivateList) {
      newFilterList.add(element);
    }
    // actualizamos la lista para mostrar al usuario
    setCatalogueProducts = newFilterList;
  }
  //
  // FUCTIONS CATALOGUE SEARCH VIEW
  //  
  void selectedProduct({required ProductCatalogue product}){
    // description : selecciona un producto
    if(isSelectedProduct(code: product.code)){
      deleteProductSelected(code: product.code);
    }else{
      addProductSelected(product: product);
    }
    update();
  }
  void addProductSelected({required ProductCatalogue product}){
    // description : agrega un producto a la lista de seleccionados
    getProductsSelectedList.add(product);  
  }
  void deleteProductSelected({required String code}){
    // description : elimina un producto de la lista de seleccionados
    getProductsSelectedList.removeWhere((element) => element.code == code);
  }
  void deleteProductList({required List<ProductCatalogue> list}){
    // firebase : elimina todos los productos de la lista pasado por parametro de la base de datos del catalogo
    for (var element in list) {
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).delete();
    }
    getProductsSelectedList.clear();
  }
  void updatePricePurchaseAndSales({required List<ProductCatalogue> list,required double pricePurchase,required double priceSales}){
    // firebase : actualiza el precio de compra y venta de todos los productos de la lista pasado por parametro
    for (var element in list) {
      element.purchasePrice = pricePurchase; // actualizamos el precio de compra
      element.salePrice = priceSales; // actualizamos el precio de venta
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
    } 
    getProductsSelectedList.clear();
  }
  void updateSalesPriceProducts({required List<ProductCatalogue> list,required double price}){
    // firebase : actualiza el precio de venta de todos los productos de la lista pasado por parametro
    for (var element in list) {
      element.salePrice = price; // actualizamos el precio de venta
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
    }
    getProductsSelectedList.clear();
  }
  void updatePurchasePriceProducts({required List<ProductCatalogue> list,required double price}){
    // firebase : actualiza el precio de compra de todos los productos de la lista pasado por parametro
    for (var element in list) {
      element.purchasePrice = price; // actualizamos el precio de compra
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
    }
    getProductsSelectedList.clear();
  }
  bool  isSelectedProduct({required String code}){
    // description : verifica si un producto esta seleccionado
    return getProductsSelectedList.where((element) => element.code == code).isNotEmpty;
  }
  // get : filter
  List<ProductCatalogue> filteredItems({required String query}) {
    // description : Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query].
    // Los elementos se filtran de acuerdo a coincidencias encontradas en los atributos
    // 'description', 'nombre de la marca' y 'codigo' de cada elemento.
    return query.isEmpty
    ? getCataloProducts
    : getCataloProducts.where((item) {
        // Convertimos la descripción, marca y código del elemento y el query a minúsculas
        final description = item.description.toLowerCase();
        final brand = item.nameMark.toLowerCase();
        final code = item.code.toLowerCase();
        final category = item.nameCategory.toLowerCase();
        final lowerCaseQuery = query.toLowerCase();

        // Dividimos el query en palabras individuales
        final queryWords = lowerCaseQuery.split(' ');

        // Verificamos que todas las palabras del query estén presentes en la descripción, marca código
        return queryWords.every((word) => description.contains(word) || brand.contains(word) || code.contains(word) || category.contains(word));
      }).toList();
  }
 //
 // WIDGETS
 //
  Widget get viewStockAlert {
    // buscamos los productos que tengan un stock vacio o bajo
    int countProducts = 0;
    for (var product in getCataloProducts) {
      if (product.quantityStock <= product.alertStock && product.stock) {
        countProducts++;
      }
    }
    if (countProducts == 0) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextButton(
            onPressed: filterAlertStock,
            child: Text('Tienes $countProducts productos con stock bajas',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w200))),
      );
    }
  }
  Widget get widgetSuggestionProduct{
    // widget : este texto se va a mostrar en la primera venta

    // comprobamos si es la primera ves que se inicia la aplicación
    if(homeController.salesUserGuideVisibility){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 50,left: 12,right: 12,bottom: 20),
            child: Opacity(opacity: 0.8,child: Text('¡Agrega tu primer producto!',textAlign: TextAlign.center,style: TextStyle(fontSize: 20))),
          ),
          TextButton(onPressed: toSeachProduct,child: const Text('Agregar')),
        ],
      );
      }
    // si no es la primera ves que se inicica la aplicación devuelve una vistra vacia
    return Container();
  }
  PreferredSizeWidget get buttonAppBar{
    // bottom : vista de productos seleccionados con un [TextButton] que diga cuantos productos seleccionados hay con opciones para cancelar y actualizar precio de venta
    return  getProductsSelectedList.isEmpty?PreferredSize(preferredSize: const Size.fromHeight(0),child: Container(),): PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.blue.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // text : cantidad de productos seleccionados
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton(
                  onPressed: () { 
                    // dialog : vista de productos seleccionados
                    Get.dialog( const ViewProductsSelected());
                  },
                  child: Text( getProductsSelectedList.length==1?'${ getProductsSelectedList.length } seleccionado':'${ getProductsSelectedList.length } seleccionados'),
                ),
              ),
              // textbutton : cancelar
              TextButton(
                onPressed: () {
                  getProductsSelectedList.clear();  
                },
                child: const Text('Descartar',style: TextStyle(color: Colors.red)),
              ), 
            ],
          ),
        ),
      );
  }
}

// StatelessWidget : lista de productos seleccionados con opcion de eliminar de la lista
class ViewProductsSelected extends StatefulWidget {
  const ViewProductsSelected({super.key});

  @override
  State<ViewProductsSelected> createState() => _ViewProductsSelectedState();
}

class _ViewProductsSelectedState extends State<ViewProductsSelected> {

  // controllers
  final CataloguePageController catalogueController = Get.find<CataloguePageController>();

  // Widget
  Widget circleDivider = Padding(padding: const EdgeInsets.symmetric(horizontal: 4),child: Icon(Icons.circle,size: 5, color: Get.theme.dividerColor));

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        appBar: appbar,
        body: body,
      ),
    );
  }

  //
  // WIDGETS VIEW
  //
  PreferredSizeWidget get appbar{
    return AppBar(
      title: const Text('Productos seleccionados'), 
    );
  }
  Widget get body{ 
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: catalogueController.getProductsSelectedList.length,
            itemBuilder: (context, index) {
              return itemProduct(product: catalogueController.getProductsSelectedList[index] );
            },
          ),
        ),
        // button : abre un dialog para actualizar el precio de venta de los productos seleccionados
        ComponentApp().button(icon: const Text('Actualizar'), onPressed: (){
          Get.back();
          updateDialog();
        }),
        // button : abre un dialog para eliminar los productos seleccionados
        ComponentApp().button(
          defaultStyle: false,
          icon: const Text('Eliminar de mi catálogo',style: TextStyle(color: Colors.white)), 
          colorButton: Colors.red.withOpacity(0.4),
        onPressed: (){ 
          // dialog : confirmar la eliminación de los productos seleccionados
          confirmDeleteProductDialog();
        }),
        // textButton : descartar los productos seleccionados
        TextButton(onPressed: (){ 
          catalogueController.getProductsSelectedList.clear();
          Get.back();
          }, child: Text('Descartar',style: TextStyle(color: Colors.red.shade400))),
      ],
    );
  }

  // 
  // WIDGETS COMPONENTS
  //
  Widget itemProduct({required ProductCatalogue product}){

    return Column(
      children: [
        ListTile(
          title: Text(product.description,maxLines: 1,),
          // subtitle: un Wrap con la marca en color azul si esta verificado, codigo del producto, precio de venta y precio de compra con un icon de circulo pequeño como dividor
          subtitle: Column(
            children: [
              Row(
                children: [
                  // text : marca del producto 
                  product.nameMark==''?Container():Text(product.nameMark,style: TextStyle(color: product.verified?Colors.blue:Colors.grey.shade400)),
                  product.nameMark==''?Container():circleDivider,
                  // text : codigo del producto
                  Text(product.code), 
                  
                ],
              ),
              // text : precio de venta
              Row(
                children: [
                  // text : precio de compra
                  product.purchasePrice==0?Container():Text('compra ${Publications.getFormatoPrecio(monto: product.purchasePrice)}'),
                  // text : precio de venta
                  product.salePrice==0?Container():circleDivider,
                  product.salePrice==0?Container():Text('venta ${Publications.getFormatoPrecio(monto: product.salePrice)}'),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: (){
              setState(() {
                // fuction : eliminar producto de la lista de productos seleccionados
                catalogueController.deleteProductSelected(code: product.code);
              });
            },
            icon: const Icon(Icons.close),
          ),
        ),
        ComponentApp().divider(),
      ],
    );
  }

  // 
  // DIALOG
  //
  void updateDialog(){
    Get.dialog(
      AlertDialog(
        title: const Text('Actualización cátalogo'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            // textbutton : actualizar precio de compra
            TextButton(onPressed: () { 
              Get.back();
              updatePricePurchaseDialog();
            },child: const Text('Actualizar precio de costo')),
            // textbutton : actualizar precio de venta al público
            TextButton(onPressed: () {
              Get.back();
              updateSalesPriceDialog();
            },child: const Text('Actualizar precio de venta al público')), 
            // textButton : actualizar ambos precios
            TextButton(onPressed: () {
              Get.back();
              updatePricePurchaseAndSalesDialog(); 
            },child: const Text('Actualizar ambos precios')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cerrar'),
          ),
        ],
      )
    );
  }
  void updatePricePurchaseAndSalesDialog(){
    // controllers
    MoneyMaskedTextController pricePurchaseController = MoneyMaskedTextController();
    MoneyMaskedTextController priceSaleController = MoneyMaskedTextController();

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar precios'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            // textfield : precio de compra
            TextField( 
              autofocus: false,
              controller: pricePurchaseController,
              enabled: true, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de costo'),
            ),
            const SizedBox(height: 10),
            // textfield : precio de venta
            TextField( 
              autofocus: false,
              controller: priceSaleController,
              enabled: true, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de venta al público'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // fuction : actualizar precios de los productos seleccionados
              catalogueController.updatePricePurchaseAndSales(list:catalogueController.getProductsSelectedList,pricePurchase: pricePurchaseController.numberValue,priceSales: priceSaleController.numberValue);
              Get.back();
            },
            child: const Text('Actualizar'),
          ),
        ],
      )
    );
  }
  void updateSalesPriceDialog(){
    // controllers
    MoneyMaskedTextController priceSaleController = MoneyMaskedTextController();

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar precio de venta al público'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            // textfield : precio de venta
            TextField( 
              autofocus: false,
              controller: priceSaleController,
              enabled: true, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de venta'),  
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              if(priceSaleController.numberValue==0){
                Get.snackbar('Error', 'El precio de venta no puede ser 0');
                return;
              }
              // function : actualizar precio de venta de los productos seleccionados 
              catalogueController.updateSalesPriceProducts( list: catalogueController.getProductsSelectedList,price: priceSaleController.numberValue); 
              Get.back();
            },
            child: const Text('Actualizar'),
          ),
        ],
      )
    );
  }
  void updatePricePurchaseDialog(){
    // controllers
    MoneyMaskedTextController controllerTextEditPrecioCosto = MoneyMaskedTextController(leftSymbol: '\$');

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar precio de costo'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            // textfield : precio de costo
            TextField( 
              autofocus: false,
              controller: controllerTextEditPrecioCosto,
              enabled: true, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de costo'),  
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // condition : precio de compra no puede ser 0
              if(controllerTextEditPrecioCosto.numberValue==0){
                Get.snackbar('Error', 'El precio de compra no puede ser 0');
                return;
              }
              // function : actualizar precio de compra de los productos seleccionados
              catalogueController.updatePurchasePriceProducts(list: catalogueController.getProductsSelectedList,price: controllerTextEditPrecioCosto.numberValue);
              Get.back();
            },
            child: const Text('Actualizar'),
          ),
        ],
      )
    );
  }
  void confirmDeleteProductDialog(){
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar de mi catálogo'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            const SizedBox(height: 10),
            // text : texto informativo de la cantidad de productos seleccionados 
            Text('¿Está seguro que desea eliminar ${ catalogueController.getProductsSelectedList.length==1?'este producto':'${ catalogueController.getProductsSelectedList.length} productos'}?',style: const TextStyle(fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // function : eliminar producto de la lista de productos seleccionados
              catalogueController.deleteProductList(list: catalogueController.getProductsSelectedList); 
              
              Get.back();
            },
            child: const Text('Eliminar'),
          ),
        ],
      )
    );
  }
}
