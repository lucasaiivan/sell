
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
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
    Color? color = Colors.orange;

    // disponibilidad baja
    if( productCatalogue.stock){
      if( productCatalogue.quantityStock <= productCatalogue.alertStock ){
        color = Colors.red;
      }
    }

    return color;
  }
  // titulo del appbar
  String _textFilter = 'Filtrar';
  String get getTextFilter => _textFilter;
  set setTextFilter(String value) => _textFilter = value;

  // proveedor seleccionado para filtrar en el cátalogo 
  set setSelectedSupplier(Provider value) { 
    setTextFilter  = value.name;
    catalogueFilter(filter: value.id);
    update();
  }

  // categoria seleccionada para filtrar en el cátalogo 
  set setSelectedCategory(Category value) { 
    setTextFilter = value.name;
    catalogueFilter(filter: value.id);
    update();
  }

  // catalogue
  final RxList<ProductCatalogue> _catalogueBusiness = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getCataloProducts { 
    return _catalogueBusiness;
  
  }
  set setCatalogueProducts(List<ProductCatalogue> products) {
    // ordenar los productos por fecha de actualizacion
    products.sort((a, b) => b.upgrade.compareTo(a.upgrade));
    _catalogueBusiness.value = products;
    //...filter
  }
  // items seleccionados del cátalogo
  final RxList<ProductCatalogue> _productsSelectedList = <ProductCatalogue>[].obs;
  List<ProductCatalogue> get getProductsSelectedList => _productsSelectedList; 

  
   

  // --------- DATASOURCE -------------- //
  void readProductsCatalogue() {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    setCatalogueProducts = homeController.getCataloProducts;
  }
   
  // ----------- FUCTIONS --------------- // 
  String get getTotalItemsCatalogue => Publications.getFormatAmount(value: getCataloProducts.length);
  String get getInventoryTotal {
    // description : obtiene el inventario total de productos
    int count = 0;
    for (var element in getCataloProducts) {
      if (element.stock) {
        count+=element.quantityStock;
      }else{
        count++;
      
      }
    }
    return Publications.getFormatAmount(value: count);
  }
  String get getTotalInventory {
    // description : obtiene el total del inventario formateado en moneda 
    // var
    double total = 0;
    // loop : recorre los productos del catalogo
    for (var element in getCataloProducts) {
      // condition : verificar que [element.quantityStock] sea mayor a 0
      if (element.quantityStock > 0 && element.stock && homeController.getIsSubscribedPremium) {
        total += element.salePrice *  element.quantityStock;
      }else{
        total += element.salePrice; 
      } 
    }
    return Publications.getFormatoPrecio(value: total,simplified: false);
  }

  void catalogueFilter({String filter = ''}) {
    //  var
    List<ProductCatalogue> list = [];

    //  filter
    if (filter != '') { 
      for (var element in homeController.getCataloProducts) {
        if (filter == element.category || filter == element.provider) {
          list.add(element);
        }
      }
    } else {
      setTextFilter = 'Filtrar'; 
      list = homeController.getCataloProducts;
    }
    // set
    setCatalogueProducts = list;
  }
  void popupMenuButtonCatalogueFilter({required String key}) {

    // var
    List<ProductCatalogue> list = [];

    //filter
    if( key==''){
        setTextFilter = 'Filtrar';
        list = homeController.getCataloProducts;
      }else{
        switch(key){
          case 'premium':
            homeController.showModalBottomSheetSubcription(id:'analytic');
            break;
          case '0': // Mostrar todos
            setTextFilter = 'Filtrar';
            list = homeController.getCataloProducts;
            // set
            setCatalogueProducts = list;
            break; 
          case '1': //  Mostrar productos con stock
            setTextFilter = 'Con stock';
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.stock)listSFilter.add(item);}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            // set
            setCatalogueProducts = list;
            break;
          case '2': //  Mostrar productos favoritos
            setTextFilter = 'Favoritos';
            List<ProductCatalogue> listSFilter = [];
            for(ProductCatalogue item in homeController.getCataloProducts){if(item.favorite)listSFilter.add(item);}
            for(ProductCatalogue item in listSFilter){list.add(item);}
            // set
            setCatalogueProducts = list;
            break;
          case '3': // Mostrar productos con stock bajos
            filterAlertStock();
            break;
          case '4': // Mostrar productos actualizados hace más de 2 meses
            setTextFilter = 'hace más de 2 meses';
            list = homeController.getCataloProducts.where((producto) {
              DateTime fechaActualizacion = producto.upgrade.toDate();
              return fechaActualizacion.isBefore(DateTime.now().subtract( const Duration(days: 2 * 30)));
            }).toList();
            // set
            setCatalogueProducts = list;
          
            break;
          case '5': // Mostrar productos actualizados hace más 5 meses
            setTextFilter = 'hace más de 5 meses';
            list = homeController.getCataloProducts.where((producto) {
              DateTime fechaActualizacion = producto.upgrade.toDate();
              return fechaActualizacion.isBefore( DateTime.now().subtract( const Duration(days: 5 * 30)) );
            }).toList(); 
            // set
            setCatalogueProducts = list;
          break; 

          case '6': // mostrar los productos que no estan verificados
            setTextFilter = 'Sin verificar';
            list = homeController.getCataloProducts.where((producto) {
              return producto.verified==false;
            }).toList();
            // set
            setCatalogueProducts = list;
          break;
          case '7': // obtener los los porductos de la base de datos publica 'Database.readProductsFuture()'
            setTextFilter = 'Base de datos'; 
            // obtenemos todos los documentos de la base de datos publica
            Database.readProductsFuture().then((value) {
              // obtenemos los productos de la cuenta del negocio  
              //
              // condition : si la lista de productos no esta vacia
              if (value.docs.isNotEmpty) {
                for (var element in value.docs) {
                  // get : object product
                  ProductCatalogue product = Product.fromMap( element.data() ).convertProductCatalogue();

                  // condition : si el producto no tiene id se le asigna el id del documento
                  if(product.id == ''){
                    product.id = element.id;
                  }
                  // add : agrega el producto a la lista  
                  if(isProductCatalogue(id: product.id) == false){
                    list.add(product);
                  }
                  
                } 
                // set
                setCatalogueProducts = list;
                update();
              } 
            });
          break;
          case '8': // obtener los los porductos de la base de datos publica 'Database.readProductsFuture()'
            setTextFilter = 'Base de Datos sin verificar'; 
            // obtenemos todos los documentos de la base de datos publica
            Database.readProductsFutureNoVerified().then((value) {
              // obtenemos los productos de la cuenta del negocio   
              //
              // condition : si la lista de productos no esta vacia
              if (value.docs.isNotEmpty) {
                for (var element in value.docs) {
                  // get : object product
                    ProductCatalogue product = Product.fromMap( element.data() ).convertProductCatalogue(); 
                    // condition : si el producto no tiene id se le asigna el id del documento
                    if(product.id == ''){
                      product.id = element.id;
                    }
                    // add
                    if(isProductCatalogue(id: product.id) == false){
                      list.add(product);
                    } 
                  
                } 
                // set
                setCatalogueProducts = list;
                update();
              } 
            });
          break;
          
        }
      }
    
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
    Get.toNamed(Routes.editProduct,arguments: {'new': true, 'product': productCatalogue});
  }

  void toSeachProduct() {
    Get.toNamed(Routes.searchProduct, arguments: {'id': ''});
  }
 
  // ---------------------------- //
  // -------- NAVIGATION -------- //
  // ---------------------------- //
  void toNavigationProductEdit({required ProductCatalogue productCatalogue}) {
    Get.toNamed(Routes.editProduct, arguments: {'product': productCatalogue.copyWith()});
  }
  void toNavigationProduct({required ProductCatalogue productCatalogue}) {
    // condition : verifica si es un producto local
    if(productCatalogue.local){
      // navega hacia la vista de producto
      Get.toNamed(Routes.editProduct, arguments: {'product': productCatalogue.copyWith()});
    }else{
      Get.toNamed(Routes.product, arguments: {'product': productCatalogue.copyWith()});
    }
  }

  void showSeach({required BuildContext context}) {
    // dialog : Busca entre los productos de mi catálogo 
    Get.dialog( const ViewSeachProductsCataloguie()); 
  }
  void filterAlertStock() {
    setTextFilter = 'Stock Bajos';
    List<ProductCatalogue> list = [];
    List<ProductCatalogue> listSFilter = [];
    for(ProductCatalogue item in homeController.getCataloProducts){if(item.stock){if(item.quantityStock<=item.alertStock){listSFilter.add(item);}}}
    for(ProductCatalogue item in listSFilter){list.add(item);}
    // set
    setCatalogueProducts = list;
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
    // recorremos los productos seleccionados
    for (var element in list) {
      // firebase : elimina el producto del catalogo de la cuenta
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).delete();
      // firebase : elimina el registro del precio de la base de datos publica
      Database.refFirestoreRegisterPrice(idProducto: element.id, isoPAis: 'ARG').doc(homeController.getProfileAccountSelected.id).delete();
      // condition : si el producto tiene seguidores
      if(element.followers>0){
        // firebase : descontamos un seguirdor del producto de la base de datos publica
        Database.refFirestoreProductPublic().doc(element.id).update({'followers': FieldValue.increment(-1)});
      }
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element,delete: true);
    }
    getProductsSelectedList.clear();
  } 
  void updatePricePurchaseAndSales({required List<ProductCatalogue> list,required double pricePurchase,required double priceSales}){
    // recorremos los productos seleccionados
    for (var element in list) {
      element.purchasePrice = pricePurchase; // actualizamos el precio de compra
      element.salePrice = priceSales; // actualizamos el precio de venta
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      // firebase : actualizamos el producto
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element );
      // publicamos el precio de venta
      publishSalePricePublic(productCatalogue: element);
    } 
    getProductsSelectedList.clear();
  }
  void updateSalesPriceProducts({required List<ProductCatalogue> list,required double price}){
    // recorremos los productos seleccionados
    for (var element in list) {
      element.salePrice = price; // actualizamos el precio de venta
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      // firebase : actualizamos el producto
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
      // publicamos el precio de venta
      publishSalePricePublic(productCatalogue: element);
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element );
    }
    getProductsSelectedList.clear();
  }
  void updatePurchasePriceProducts({required List<ProductCatalogue> list,required double price}){
    // recorremos los productos seleccionados
    for (ProductCatalogue element in list) {
      element.purchasePrice = price; // actualizamos el precio de compra
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      // firebase : actualizamos el producto
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element );
    }
    getProductsSelectedList.clear();
  }
  void updatePricePurchaseAndSalesWithPercentage({required List<ProductCatalogue> list,required double percentage}){
    // con un porcentaje actualiza el precio de compra y venta de todos los productos de la lista pasado por parametro y redondear al numero mas sercano 
    for (var element in list) {
      element.salePrice = element.salePrice + (element.salePrice * percentage / 100); // actualizamos el precio de venta
      element.purchasePrice =  element.purchasePrice = element.purchasePrice + (element.purchasePrice * percentage / 100); // actualizamos el precio de compra 
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      // firebase 
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element );
      // publicamos el precio de venta
      publishSalePricePublic(productCatalogue: element);
    }
  }
  void updateProvider({required List<ProductCatalogue> list,required String idProvider}){
    // recorremos los productos seleccionados
    for (var element in list) {
      element.provider = idProvider; // actualizamos el proveedor
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      // firebase : actualizamos el producto
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element );
    }
    getProductsSelectedList.clear();
  }
  void updateCategory({required List<ProductCatalogue> list,required String idCategory}){
    // recorremos los productos seleccionados
    for (var element in list) { 
      element.category = idCategory; // actualizamos la categoria
      element.upgrade = Timestamp.now(); // actualizamos la fecha de actualizacion
      // firebase : actualizamos el producto
      Database.refFirestoreCatalogueProduct(idAccount: homeController.getProfileAccountSelected.id).doc(element.id).set(element.toJson());
      // actualiza la lista de productos del cátalogo en la memoria de la app
      homeController.sincronizeCatalogueProducts(product: element );
    }
    getProductsSelectedList.clear();
  }
  void publishSalePricePublic({ required ProductCatalogue productCatalogue}){
    // description : publica el precio de venta de un producto en la base de datos publica
    // Registra el precio en una colección publica
    ProductPrice precio = ProductPrice(
      id: homeController.getProfileAccountSelected.id,
      idAccount: homeController.getProfileAccountSelected.id,
      imageAccount: homeController.getProfileAccountSelected.image,
      nameAccount: homeController.getProfileAccountSelected.name,
      price: productCatalogue.salePrice, // precio de venta
      currencySign: productCatalogue.currencySign, // signo de la moneda
      province: homeController.getProfileAccountSelected.province,
      town: homeController.getProfileAccountSelected.town,
      time: Timestamp.fromDate(DateTime.now()),
    );
    // Firebase set : se crea un documento con la referencia del precio del producto
    Database.refFirestoreRegisterPrice(idProducto: productCatalogue.id, isoPAis: 'ARG').doc(precio.id).set(precio.toJson());
  }
  bool  isSelectedProduct({required String code}){
    // description : verifica si un producto esta seleccionado
    return getProductsSelectedList.where((element) => element.code == code).isNotEmpty;
  }
  int readCoincidencesToCatalogue({String idCategory ='', String idProvider='', String idMark=''}) {
    // read : devuelve una cantidad [int] de coincidencias a partir un ID [idCategory,idProvider,idMark] pasado por parametro
    //
    //  function : lee la categoria del producto
    int coincidences = 0;
    //  condition : si el id de la categoria es distinto de '' se procede a buscar coincidencias
    if (idCategory != '') {
      for (var element in homeController.getCataloProducts) {
        if (element.category == idCategory) {
          coincidences++;
        }
      }
    }
    //  condition : si el id del proveedor es distinto de '' se procede a buscar coincidencias
    if (idProvider != '') {
      for (var element in homeController.getCataloProducts) {
        if (element.provider == idProvider) {
          coincidences++;
        }
      }
    }
    //  condition : si el id de la marca es distinto de '' se procede a buscar coincidencias
    if (idMark != '') {
      for (var element in homeController.getCataloProducts) {
        if (element.idMark == idMark) {
          coincidences++;
        }
      }
    }
    return coincidences;
  }
  // get : filter
  List<ProductCatalogue> filteredItems({required String query}) {
    // description : Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query].
    // Los elementos se filtran de acuerdo a coincidencias encontradas en los atributos
    // 'description', 'nombre de la marca' y 'codigo' de cada elemento.
    return query.isEmpty
    ? getCataloProducts
    : getCataloProducts.where((item) {
        // normalizamos los textos
        final description = Utils.normalizeText(item.description.toLowerCase());
        final brand = Utils.normalizeText(item.nameMark.toLowerCase());
        final code =  Utils.normalizeText(item.code.toLowerCase());
        final category = Utils.normalizeText(item.nameCategory.toLowerCase());
        final lowerCaseQuery = Utils.normalizeText(query); 
        final provider = Utils.normalizeText(item.nameProvider.toLowerCase());

        // Dividimos el query en palabras individuales
        final queryWords = lowerCaseQuery.split(' ');

        // Verificamos que todas las palabras del query estén presentes en la descripción, marca código
        return queryWords.every((word) => description.contains(word) || brand.contains(word) || code.contains(word) || category.contains(word) || provider.contains(word) );
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
            child: Text('Tienes $countProducts productos con stock bajos',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w200))),
      );
    }
  } 
  PreferredSizeWidget get buttonAppBar{

    // style 
    TextStyle infoStyle = const TextStyle( fontWeight: FontWeight.w400,fontSize: 24);
    // bottom : vista de productos seleccionados con un [TextButton] que diga cuantos productos seleccionados hay con opciones para cancelar y actualizar precio de venta
    return  getProductsSelectedList.isEmpty?PreferredSize(preferredSize: const Size.fromHeight(0),child: Container(),): PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.blue.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // icon : close
              IconButton(
                onPressed: () {
                  // function : descartar los productos seleccionados
                  getProductsSelectedList.clear(); 
                },
                icon: const Icon(Icons.close),
              ),
              // text : cantidad de productos seleccionados
              Text( getProductsSelectedList.length.toString(),style: infoStyle),
              const Spacer(),
              // textbutton : cancelar
              TextButton(
                onPressed: () {  
                  // dialog : vista de productos seleccionados
                  Get.dialog( const ViewProductsSelected()); 
                },
                child: const Text('SELECCIONADOS',style: TextStyle(color: Colors.blue)),
              ), 
            ],
          ),
        ),
      );
  }

  // ---------------------------- //
  // -------- OVERRIDE ---------- //
  // ---------------------------- //
  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(vsync: this, length:3);
    readProductsCatalogue();
  }

  @override
  void onClose() {}
}

// -------------------------------------------- //
// ui : vista de productos seleccionados       //
// -------------------------------------------- //

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
        floatingActionButton: floatingActionButtons,
      ),
    );
  }

  // WIDGETS VIEW //
  PreferredSizeWidget get appbar{
    return AppBar( 
      title: const Text('Seleccionados'),
      actions: [
        // textbutton : descartar
        TextButton(
          onPressed: () {
            catalogueController.getProductsSelectedList.clear();
            Get.back();
          },
          child: const Text('Descartar'),
        ),
      ],
      );
  }
  Widget get body{ 
    return ListView.builder(
      itemCount: catalogueController.getProductsSelectedList.length,
      itemBuilder: (context, index) {
        return itemProduct(product: catalogueController.getProductsSelectedList[index] );
      },
    );
  }

  // WIDGETS COMPONENTS // 
  Widget get floatingActionButtons{
    return Row( 
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // iconButton : eliminar
        FloatingActionButton.extended(
          backgroundColor: Colors.red.shade300,
          onPressed: () {
            Get.back();
            confirmDeleteProductDialog();
          },
          label: const Text('Eliminar',style: TextStyle(color: Colors.white)), 
          icon: const Icon(Icons.delete,color: Colors.white)
        ), 
        const SizedBox(width: 10),
        // iconButton : actualizar
        FloatingActionButton.extended(
          onPressed: () { 
            Get.back();
            showUpdateDialog();
          },
          label: const Text('Actualizar',style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.update,color: Colors.white,),
        ),
        const SizedBox(width: 10),
        // iconButton : descartar
        FloatingActionButton(
          backgroundColor: Colors.grey,
          onPressed: () { 
            Get.back();
          }, 
          child: const Icon(Icons.close,color: Colors.white,),
        ),
        
      ],
    );
  }
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
                  product.purchasePrice==0?Container():Text('compra ${Publications.getFormatoPrecio(value: product.purchasePrice)}'),
                  // text : precio de venta
                  product.salePrice==0?Container():circleDivider,
                  product.salePrice==0?Container():Text('venta ${Publications.getFormatoPrecio(value: product.salePrice)}'),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: (){
              setState(() {
                // fuction : eliminar producto de la lista de productos seleccionados
                catalogueController.deleteProductSelected(code: product.code);
                // condition : si es el ultimo producto seleccionado se cierra la vista
                if(catalogueController.getProductsSelectedList.isEmpty){
                  Get.back();
                }
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ),
        ComponentApp().divider(),
      ],
    );
  }
 
  // DIALOG //
  void showUpdateDialog(){
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Actualizar'),
            const SizedBox(width:5),
            // avatar : cantidad de items que se van a actualizar 
            CircleAvatar(child: Text(catalogueController.getProductsSelectedList.length.toString(),style: const TextStyle(color: Colors.white))),
          ],
        ),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            // textbutton : actualizar precio de compra
            TextButton(onPressed: () { 
              Get.back();
              updatePricePurchaseDialog();
            },child: const Text('Precio de costo')),
            // textbutton : actualizar precio de venta al público
            TextButton(onPressed: () {
              Get.back();
              updateSalesPriceDialog();
            },child: const Text('Precio de venta al público')), 
            // textButton : actualizar ambos precios
            TextButton(onPressed: () {
              Get.back();
              updatePricePurchaseAndSalesDialog(); 
            },child: const Text('Ambos precios')),
            // textButton : actualizar precio de compra y venta con porcentaje
            TextButton(onPressed: () {
              Get.back();
              updatePricePurchaseAndSalesWithPercentageDialog();
            },child: const Text('Ambos precios con porcentaje')),
            // textButton : actualizar proveedor
            TextButton(onPressed: (){
              Get.back();
              updateProviderDialog();},child: const Text('Proveedor')),
            // textButton : actualizar categoria
            TextButton(onPressed: () { 
              Get.back();
              updateCategoryDialog();},child: const Text('Categoria')),
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
    AppMoneyTextEditingController pricePurchaseController = AppMoneyTextEditingController();
    AppMoneyTextEditingController priceSaleController = AppMoneyTextEditingController();

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
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de costo',prefixIcon: Icon(Icons.monetization_on_rounded)),
            ),
            const SizedBox(height: 10),
            // textfield : precio de venta
            TextField( 
              autofocus: false,
              controller: priceSaleController,
              enabled: true, 
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de venta al público',prefixIcon: Icon(Icons.monetization_on_rounded)),
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
              catalogueController.updatePricePurchaseAndSales(list:catalogueController.getProductsSelectedList,pricePurchase: pricePurchaseController.doubleValue,priceSales: priceSaleController.doubleValue);
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
    AppMoneyTextEditingController priceSaleController = AppMoneyTextEditingController();

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
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText: 'Precio de venta',prefixIcon: Icon(Icons.monetization_on_rounded)),  
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
              if(priceSaleController.doubleValue==0){
                Get.snackbar('Error', 'El precio de venta no puede ser 0');
                return;
              }
              // function : actualizar precio de venta de los productos seleccionados 
              catalogueController.updateSalesPriceProducts( list: catalogueController.getProductsSelectedList,price: priceSaleController.doubleValue); 
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
    AppMoneyTextEditingController controllerTextEditPrecioCosto = AppMoneyTextEditingController( );

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
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(filled: true,labelText:'Precio de costo',prefixIcon: Icon(Icons.monetization_on_rounded)),  
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
              if(controllerTextEditPrecioCosto.doubleValue==0){
                Get.snackbar('Error', 'El precio de compra no puede ser 0');
                return;
              }
              // function : actualizar precio de compra de los productos seleccionados
              catalogueController.updatePurchasePriceProducts(list: catalogueController.getProductsSelectedList,price: controllerTextEditPrecioCosto.doubleValue);
            
              Get.back();
            },
            child: const Text('Actualizar'),
          ),
        ],
      )
    );
  }
  void updatePricePurchaseAndSalesWithPercentageDialog(){
    // controllers 
    TextEditingController percentageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar costo y venta'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            // textfield : porcentaje
            TextField(  
              autofocus: false,
              controller: percentageController,
              enabled: true, maxLength: 3, 
              inputFormatters: [AppMoneyInputFormatter()],
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              decoration: const InputDecoration(filled: true,labelText:'Porcentaje',prefixIcon: Icon(Icons.percent_rounded)),  
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

              // condition : porcentaje no puede ser 0
              if( percentageController.value.text == ''){
                Get.snackbar('Error', 'Debe ingresar un porcentaje');
                return;
              }

              // var
              double percentage = double.parse(percentageController.value.text);

              // function : actualizar ambos precios con un porcentaje
              catalogueController.updatePricePurchaseAndSalesWithPercentage( list: catalogueController.getProductsSelectedList,percentage: percentage);
            
              Get.back();

            },
            child: const Text('Actualizar'),
          ),
        ],
      )
    );
 
  } 
  void updateProviderDialog(){ 
    // controllers
    final HomeController homeController = Get.find<HomeController>();
    // var  
    String idCategory='';
    

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar proveedor'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            // dropdownButton : proveedor [welcomeController.getProviderList]
            homeController.getProviderList.isEmpty? Container()
            :DropdownButtonFormField<String>( 
              items: homeController.getProviderList.map((e) => DropdownMenuItem(
                value: e.id, 
                child: Text(e.name))).toList(),
              onChanged: (value) {
                idCategory = value!;
              },
              decoration: const InputDecoration(filled: true,labelText:'Proveedor',prefixIcon: Icon(Icons.person_rounded)),
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
              if(idCategory==''){
                Get.snackbar('Inválido', 'Debe seleccionar un proveedor');
                return;
              }
              // function : actualizar proveedor de los productos seleccionados
              catalogueController.updateProvider(list: catalogueController.getProductsSelectedList,idProvider: idCategory);
              Get.back();
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
      
    );
  }
  void updateCategoryDialog(){
    // controllers
    final HomeController homeController = Get.find<HomeController>();
    // var
    String idCategory='';

    Get.dialog(
      AlertDialog(
        title: const Text('Actualizar categoría'),  
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : texto informativo de la cantidad de productos seleccionados
            Text( catalogueController.getProductsSelectedList.length==1?'${ catalogueController.getProductsSelectedList.length} producto seleccionado':'${ catalogueController.getProductsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            // dropdownButton : categoria [homeController.getCategoryList]
            homeController.getCatalogueCategoryList.isEmpty? Container()
            :DropdownButtonFormField<String>( 
              items: homeController.getCatalogueCategoryList.map((e) => DropdownMenuItem(
                value: e.id, 
                child: Text(e.name))).toList(),
              onChanged: (value) {
                idCategory = value!;
              },
              decoration: const InputDecoration(filled: true,labelText:'Categoría',prefixIcon: Icon(Icons.category_rounded)),
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
              if(idCategory==''){
                Get.snackbar('Inválido', 'Debe seleccionar una categoría');
                return;
              }
              // function : actualizar categoria de los productos seleccionados
              catalogueController.updateCategory(list: catalogueController.getProductsSelectedList,idCategory: idCategory);
              Get.back();
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
      
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
            child: const Text('Cancelar'),
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