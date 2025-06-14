
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../home/controller/home_controller.dart';
import '../controller/catalogue_controller.dart';

class ViewSeachProductsCataloguie extends StatefulWidget {
  // description: vista para buscar productos en el catalogo 
  const ViewSeachProductsCataloguie({super.key});

  @override
  State<ViewSeachProductsCataloguie> createState() => _ViewSeachProductsCataloguieState();
}

class _ViewSeachProductsCataloguieState extends State<ViewSeachProductsCataloguie> {

  // controllers
  final HomeController homeController = Get.find<HomeController>();
  final CataloguePageController catalogueController = Get.find<CataloguePageController>();
  final TextEditingController _searchQueryController = TextEditingController();

  // get and set : query
  String get getQuery => _searchQueryController.text;
  set setQuery(String value) {
    setState(() {
      _searchQueryController.text = value;
    });
  }
 
  
  @override
  Widget build(BuildContext context) {

    return GetBuilder<CataloguePageController>( 
      builder: (controller) {
        return Obx(() => Material( 
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            appBar: appBar,
            body: body,  

          ),
        ));
      },
    ); 
  }
  //
  // WIDGETS VIEW
  //
  PreferredSizeWidget get appBar{
    // description: appbar de la vista, con un textfield search, un iconbutton de clean y un vista de productos seleccionados
    return AppBar( 
      // padding superior 
      toolbarHeight: 75,
      // title : textfield search con estilo simple  y fondo transparente  con un iconbutton de clean 
      title: TextField(
        controller: _searchQueryController, 
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          fillColor: Colors.transparent,
          hintText: 'Buscar producto',  
        ),  
        onChanged: (value) {
          setState(() {});
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () { 
            if(getQuery==''){Get.back();return;}
            setQuery = ''; 
          },
        ),
      ], 
      // bottom : vista de productos seleccionados
      bottom: catalogueController.buttonAppBar,
    );
  }
  Widget get body{
    // description: cuerpo con vista principal de chips de categorias y marcas o un listview de productos filtrados

    // styles
    final Color primaryTextColor  = Get.isDarkMode?Colors.white70:Colors.black87;
    final TextStyle textStylePrimary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400,fontSize: 16);
    final TextStyle textStyleSecundary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);

    // widgets : chips de marcas
    final Widget viewMarks = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        homeController.getMarkList.isEmpty? Container() : Text('Marcas',style: textStylePrimary),
        const SizedBox(height: 5), 
        Wrap(
          children: [
            for (Mark element in homeController.getMarkList)
              // chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:3),
                child: GestureDetector(
                  onTap: (){
                    // set query
                    setQuery = element.name;
                  },
                  child: Chip( 
                    avatar: element.image==''?null:CircleAvatar(backgroundImage: NetworkImage(element.image),backgroundColor:Colors.black.withOpacity(0.06)),
                    label: Text(element.name,style: textStyleSecundary), 
                    shape: RoundedRectangleBorder(side: BorderSide(color: primaryTextColor.withOpacity(0.5)),borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.transparent,   
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    // widgets : chips de categorias
    final Widget viewCategories = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        homeController.getCatalogueCategoryList.isEmpty?Container():Text('Categorías',style: textStylePrimary),
        const SizedBox(height: 5),
        Wrap(
          children: [
            for (Category element in homeController.getCatalogueCategoryList)
              // chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:3),
                child: GestureDetector(
                  onTap: (){
                    // set query
                    setQuery = element.name;
                  },
                  child: Chip( 
                    
                    label: Text(element.name,style: textStyleSecundary), 
                    shape: RoundedRectangleBorder(side: BorderSide(color: primaryTextColor.withOpacity(0.5)),borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.transparent,   
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    // widget : chips de proveedores
    final Widget viewProviders = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        homeController.getProviderList.isEmpty?Container():Text('Proveedores',style: textStylePrimary),
        const SizedBox(height: 5),
        Wrap(
          children: [
            for (Provider element in homeController.getProviderList)
              // chip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:3),
                child: GestureDetector(
                  onTap: (){
                    // set query
                    setQuery = element.name;
                  },
                  child: Chip( 
                    label: Text(element.name,style: textStyleSecundary), 
                    shape: RoundedRectangleBorder(side: BorderSide(color: primaryTextColor.withOpacity(0.5)),borderRadius: BorderRadius.circular(5)),
                    backgroundColor: Colors.transparent,   
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    
    /// Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query]. 
    final List<ProductCatalogue> filteredSuggestions = catalogueController.filteredItems(query: getQuery);

    // condition : si no hay query entonces mostramos las categorias
    if(getQuery.isEmpty){
      return Padding(
        padding: const EdgeInsets.only(top: 0,left: 12,right: 12),
        child: ListView(
            children: [
              viewProviders,
              viewCategories, 
              viewMarks,
            ],
          ),
      );
    }
    // condition : si se consulto pero no se obtuvieron resultados
    if(filteredSuggestions.isEmpty && getQuery.isNotEmpty){
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No se encontraron resultados',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w300),textAlign: TextAlign.center),
      ));
    }
 

    return ListView.builder( 
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) { 
        // values
        ProductCatalogue product = filteredSuggestions[index];  
        return item(product:product); 
      },
    ); 
  }
   

  //
  // WIDGETS COMPONENTS
  //
  Widget item({required ProductCatalogue product}){

    // var 
    String valueDataUpdate ='Actualizado ${Publications.getFechaPublicacion(fechaPublicacion:product.upgrade.toDate(),fechaActual:  Timestamp.now().toDate() )}'; 


    // styles
    final Color highlightColor = Get.isDarkMode?Colors.white:Colors.black;
    final Color primaryTextColor  = Get.isDarkMode?Colors.white54:Colors.black45;
    final TextStyle textStyleSecundary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);
    // widgets
    final Widget dividerCircle = ComponentApp().dividerDot(color: primaryTextColor);

    // var
    String alertStockText = product.stock ? (product.quantityStock == 0 ? 'Sin stock' : '${product.quantityStock} en stock') : '';
          
    return Column(
      children: [
        InkWell( 
          // color del cliqueable
          splashColor: Colors.blue, 
          highlightColor: highlightColor.withOpacity(0.1),
          onLongPress: () {
            setState(() {
              if(catalogueController.isSelectedProduct(code: product.code)){
                catalogueController.deleteProductSelected(code: product.code);
              }else{ 
                catalogueController.addProductSelected(product: product);
              }
              
            });
          },
          onTap: () {
            // condition : si no hay productos seleccionados
            if(catalogueController.getProductsSelectedList.isEmpty){ 
              Get.back(); // cierra el dialogo
              // navigation : editar producto
              homeController.getUserAnonymous?null:catalogueController.toNavigationProduct(productCatalogue: product);
            }else{ 
              // selecciona el producto
              catalogueController.selectedProduct(product: product); 
            } 
          
          },
          child: Container(
            color: catalogueController.isSelectedProduct(code: product.code)?Colors.blue.withOpacity(0.1):Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // image
                  ImageProductAvatarApp(url:product.local?'':product.image,size: 75 ),
                  // text : datos del producto
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:12),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // icon : favorito
                            product.favorite?const Icon(Icons.star_rounded,color: Colors.amber,size: 14,):Container(),
                            // text : nombre del producto
                            Flexible(child: Text(product.description,maxLines:2,overflow: TextOverflow.ellipsis,style: const TextStyle(fontWeight: FontWeight.w500))),
                          ],
                        ),
                        // view : marca del producto y proveedor
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //text : nombre de la marca
                          product.nameMark==''?Container():Text(
                              product.nameMark,
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: TextStyle(color: product.verified?Colors.blue:null),
                            ),
                          //text : nombre del proveedor
                          product.nameProvider==''?Container(): dividerCircle,
                          product.nameProvider==''?Container():Text(
                              product.nameProvider,
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: textStyleSecundary,
                            ),
                        ],
                      ), 
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          direction: Axis.horizontal,
                          children: <Widget>[
                            // text : code
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  dividerCircle,
                                  Text(product.code,style: textStyleSecundary),
                                ],
                              ),
                              // favorite
                              product.favorite?Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  dividerCircle,
                                  Text('Favorito',style: textStyleSecundary),
                                ],
                              ):Container(),
                            //  text : alert stock 
                              alertStockText != ''?Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  dividerCircle,
                                  Text(alertStockText,style: textStyleSecundary),
                                ],
                              ):Container(),
                            // text : fecha de actualizacion
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  dividerCircle,
                                  Text(valueDataUpdate,style: textStyleSecundary),
                                ],
                              ),
                          ],
                        ),
                                
                      ],
                                    ),
                    ),
                  ),
                  // text : precio
                  Text(Publications.getFormatoPrecio(value: product.salePrice),style: const  TextStyle(fontSize: 18,fontWeight: FontWeight.w300),)
                ],
              ),
            ),
          ),
        ), 
      ComponentApp().divider(), 
      ],
    );
  }

  
  
}