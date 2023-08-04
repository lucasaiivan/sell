
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:sell/app/data/datasource/database_cloud.dart'; 
import '../../../core/routes/app_pages.dart'; 
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

  // text titleBar
  Category _selectedCategory = Category(name: 'Cátalogo');
  String get getTextTitleAppBar => _selectedCategory.name;
  Category get getSelectedCategory => _selectedCategory;
  set setTitleAppBar(String value) => _selectedCategory.name = value;
  set setSelectedCategory(Category value) {
    _selectedCategory = value;
    catalogueCategoryFilter();
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
  final List<ProductCatalogue> itemsSelectedList = []; 


  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
    readProductsCatalogue();
  }

  @override
  void onClose() {}

  // FIREBASE
  void readProductsCatalogue() {
    // obtenemos los obj(productos) del catalogo de la cuenta del negocio
    setCatalogueProducts = homeController.getCataloProducts;
  }

  // FUCTIONS
  void catalogueCategoryFilter() {
    List<ProductCatalogue> list = [];

    //filter
    if (getSelectedCategory.id != '') {
      for (var element in homeController.getCataloProducts) {
        if (getSelectedCategory.id == element.category) {
          list.add(element);
        }
      }
    } else {
      list = homeController.getCataloProducts;
    }
    // set
    setCatalogueProducts = list;
  }
  void catalogueFilter({required String key}) {
    List<ProductCatalogue> list = [];

    //filter
    if( key==''){
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
    ProductCatalogue productCatalogue = ProductCatalogue(
        id: id, code: id, creation: Timestamp.now(), upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now());
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

  // 
  // FUCTIONS CATALOGUE VIEW
  //
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
    itemsSelectedList.add(product);
  }
  bool  isSelectedProduct({required String code}){
    // description : verifica si un producto esta seleccionado
    return itemsSelectedList.where((element) => element.code == code).isNotEmpty;
  }
  void deleteProductSelected({required String code}){
    // description : elimina un producto de la lista de seleccionados
    itemsSelectedList.removeWhere((element) => element.code == code);
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
    return  itemsSelectedList.isEmpty?PreferredSize(preferredSize: const Size.fromHeight(0),child: Container(),): PreferredSize(
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
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Productos seleccionados'),
                        // content : lista simple de productos seleccionados con opcion de eliminar un producto de la lista
                        content: SizedBox(
                          height: 300,
                          width: 300,
                          child: ListView.builder(
                            itemCount: itemsSelectedList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text('${itemsSelectedList[index].description}',maxLines: 1,),
                                subtitle: Text('${itemsSelectedList[index].nameMark}',maxLines: 1,),
                                trailing: IconButton(
                                  onPressed: (){
                                    deleteProductSelected(code: itemsSelectedList[index].code);
                                    update();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: (){Get.back();}, child: const Text('Cerrar')),
                      
                        ],
                      )
                    );
                  },
                  child: Text( itemsSelectedList.length==1?'${ itemsSelectedList.length } seleccionado':'${ itemsSelectedList.length } seleccionados'),
                ),
              ),
              // textbutton : cancelar
              TextButton(
                onPressed: () {
                  itemsSelectedList.clear(); 
                  update();
                },
                child: const Text('Cancelar',style: TextStyle(color: Colors.red)),
              ),
              // textbutton : actualizar precio de venta
              TextButton(
                onPressed: () { 
                  
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Actualización cátalogo'), 
                      // content : opciones con el componente [TextButton] y las opciones [actualizar precio de compra, actualizar precio de venta, actualizar stock]
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // text : texto informativo de la cantidad de productos seleccionados
                          Text(itemsSelectedList.length==1?'${ itemsSelectedList.length} producto seleccionado':'${ itemsSelectedList.length} productos seleccionados' ,style: const TextStyle(fontWeight: FontWeight.w400)),
                          // textbutton : actualizar precio de compra
                          TextButton(onPressed: () { },child: const Text('Actualizar precio de compra')),
                          // textbutton : actualizar precio de venta al público
                          TextButton(onPressed: () { },child: const Text('Actualizar precio de venta al público')), 
                          // textbutton : eliminar productos seleccionados de mi catálogo
                          TextButton(onPressed: () { },child: Text('Eliminar de mi catálogo',style: TextStyle(color: Colors.red.shade400),)),
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

                },
                child: const Text('Actualizar',style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      );
  }
}

