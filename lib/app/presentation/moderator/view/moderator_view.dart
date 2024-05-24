import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../../../core/utils/dynamicTheme_lb.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../controller/moderator_controller.dart';

class ModeratorView extends GetView<ModeratorController> {
  // ignore: prefer_const_constructors_in_immutables
  ModeratorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: appbar(context: context),
          body: body,
        ));
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({ required BuildContext context}) {


    return AppBar(
    title: const Text('Base de datos'),
    actions: [ 
      // icon : search
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => controller.showSeachDialog(),
        ),
      // buttons : filter list
      PopupMenuButton( 
        icon: ComponentApp().buttonAppbar(
          context: context,
          text:  controller.getFilterText,
          iconTrailing: Icons.filter_list,  
        ), 
          onSelected: (selectedValue){
            // swich
            switch (selectedValue) {
              case 'all':
                controller.setFilterText = 'Todos';
                controller.filterProducts();
                break;
              case 'verified':
                controller.setFilterText = 'verificados';
                controller.filterProducts(verified: true);
                break;
              case 'noVerified':
                controller.setFilterText = 'No verificados';
                controller.filterProducts(verified: false);
                break;
              default:
                controller.setFilterText = 'Todos';
                controller.filterProducts();
            }
            
          },
          itemBuilder: (BuildContext ctx) => [
                const PopupMenuItem(value: 'all', child: Text('Mostrar todos')),
                const PopupMenuItem(value: 'verified', child: Text('Verificados')),
                const PopupMenuItem(value: 'noVerified', child: Text('Sin verificar')), 
                
              ]),
    ], 
    );
  }
  Widget get body {

    // widget
    Widget wrapChipsInfo = Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 10,
        children: [
          // chip : cantidad de articulos del catalogo y filtrados
          ActionChip(
            onPressed: (){
              controller.setFilterText = 'Todos';
              controller.filterProducts();
            },
            side: const BorderSide(color: Colors.transparent),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(Publications.getFormatAmount(value: controller.totalProducts),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Artículos',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // chip : total de productos verificados
          ActionChip(
            onPressed: (){
              controller.setFilterText = 'Verificados';
              controller.filterProducts(verified: true);
            },
            side: BorderSide( color: Get.theme.colorScheme.secondary.withOpacity(0.0)),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(Publications.getFormatAmount(value: controller.totalVerifiedProducts),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Verificados',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // chip : total de productos no verificados
          ActionChip(
            onPressed: (){
              controller.setFilterText = 'No verificados';
              controller.filterProducts(verified: false);
            },
            side: BorderSide( color: Get.theme.colorScheme.secondary.withOpacity(0.0)),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(Publications.getFormatAmount(value: controller.totalUnverifiedProducts),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('No verificados',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ), 
          // chip : total de reportes
          ActionChip(
            onPressed: (){ 
              controller.setFilterText = 'Reportes';
              controller.viewReports = true;
              controller.update();
            },
            side: BorderSide( color: Get.theme.colorScheme.secondary.withOpacity(0.0)),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(Publications.getFormatAmount(value: controller.getReports.length),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Reportes',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
        ],
      ),
    ); 
    Widget wrapChipsFilterIdUserCreations = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // text 
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Usuarios creadores', style: TextStyle(fontWeight: FontWeight.w400)),
        ), 
        // view : filtros de id de usuario
        SizedBox(
          height: 40,
          child: ListView( 
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            children: controller.getIdUserCreation.keys.map((key) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: ActionChip(
                  onPressed: (){
                    controller.setFilterText = key;
                    controller.filterProducts(idUserCreator: key);
                  },
                  side: const BorderSide(color: Colors.transparent),
                  visualDensity: VisualDensity.compact, 
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // text : id del usuario
                      Text( key,style: const TextStyle(fontWeight: FontWeight.bold)),
                      // text : cantidad de productos creados por el usuario
                      Text(' (${ Publications.getFormatAmount(value:controller.getIdUserCreation[key]!).toString()})',style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
    Widget chipsDataView = Column(
      children: [
        wrapChipsInfo,
        wrapChipsFilterIdUserCreations,
      ],
    );

    if(controller.getLoading){
      return const Center(child: CircularProgressIndicator());
    }
    if(controller.viewReports){ 

      return ListView.builder(
        itemCount: controller.getReports.length,
        itemBuilder: (BuildContext context, int index) {
          // var
          String description = controller.getReports[index].description == '' ? 'Descripción: sin datos' : 'Descripción: ${controller.getReports[index].description}';

          return Column(
            children: [
              index==0?chipsDataView:Container(),
              //const Divider(height: 0),
              ListTile(
                title: Text(controller.getReports[index].idProduct),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // text : descripcion del reporte
                    Text(description),
                    // text : reportes items
                    controller.getReports.isEmpty?Container():Row(
                      children: controller.getReports[index].reports.map((e) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Material(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          color: Colors.blue.withOpacity(0.09),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4,vertical:1),
                            child: Text('$e'),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ), 
                onTap: (){},
                 
              ),
              const Divider(height: 0,thickness:0.4),
            ],
          );
        },
      );
    }
    if(controller.getProductsFiltered.isEmpty){
      return Column(
        children: [
          chipsDataView,
          const Flexible(child: Center(child: Text('Sin productos',style: TextStyle(fontWeight: FontWeight.w300)))),
        ],
      );
    }

    // description : cuerpo de la vista
    return ListView.builder(
          itemCount: controller.getProductsFiltered.length  ,
          itemBuilder: (BuildContext context, int index) { 
            return Column(
              children: [ 
                index == 0?chipsDataView:Container(),  
                index == 0?const SizedBox(height: 10):Container(),
                index == 0?Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Productos'),
                      const Spacer(),
                      Text('Total: ${Publications.getFormatAmount(value: controller.getProductsFiltered.length)}'),
                    ],
                  ),
                ):Container(),
                const Divider(height: 0),
                listTileProduct(product: controller.getProductsFiltered[index]),
              ],
            );
          },
        );
  }

  // WIDGETS COMPONENTS
  Widget listTileProduct({required Product product}) {
    // description : ListTile con detalles del producto

    // var
    double titleSize = 16;
    String valueDataUpdate ='Actualizado ${Publications.getFechaPublicacion(fechaPublicacion: product.upgrade.toDate(), fechaActual: Timestamp.now().toDate())}';


    // styles
    final Color primaryTextColor = Get.isDarkMode ? Colors.white : Colors.black;
    final Color secundayTextColor = Get.isDarkMode
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5);
    final TextStyle textStylePrimery =
        TextStyle(color: primaryTextColor, fontWeight: FontWeight.w400);
    final TextStyle textStyleSecundary =
        TextStyle(color: secundayTextColor, fontWeight: FontWeight.w400);

    // widgets
    Widget description = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // view : marca del producto y proveedor
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            product.verified
                ? const Icon(Icons.verified, size: 11, color: Colors.blue)
                : Container(),
            product.verified ? const SizedBox(width: 1) : Container(),
            //text : nombre de la marca
            product.nameMark == ''
                ? Container()
                : Text(
                    product.nameMark,
                    maxLines: 2,
                    overflow: TextOverflow.clip,
                    style:
                        TextStyle(color: product.verified ? Colors.blue : null),
                  ),
          ],
        ),
        //  text : codigo
        Text(product.code, style: textStyleSecundary.copyWith(fontSize: 12)),
        // text : fecha de la ultima actualización
        Text(valueDataUpdate, style: textStyleSecundary.copyWith(fontSize: 12)),
        // Text : id del usuario que creo el producto
        product.idUserCreation==''?Container():Text('creado por ${product.idUserCreation}', style: textStyleSecundary.copyWith(fontSize: 12)),
        // text : id del usuario que actualizo el producto\
        product.idUserUpgrade==''?Container():Text('actualizado por ${product.idUserUpgrade}', style: textStyleSecundary.copyWith(fontSize: 12)),
      ],
    );

    return ElasticIn(
      child: InkWell(
        onTap: ()=> controller.goToProductEdit(product),
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
                    padding: EdgeInsets.symmetric(
                        horizontal: product.image == '' ? 27 : 0),
                    child: ImageProductAvatarApp(
                        url: product.image,
                        size: product.image == '' ? 25 : 80),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        !product.outstanding
                                            ? Container()
                                            : const Icon(
                                                Icons.star_purple500_sharp,
                                                size: 12,
                                                color: Colors.orange),
                                        !product.outstanding
                                            ? Container()
                                            : const SizedBox(width: 2),
                                        Flexible(
                                            child: Text(product.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    textStylePrimery.copyWith(
                                                        fontSize: titleSize))),
                                      ],
                                    ),
                                    description,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Opacity(opacity: 0.3, child: Divider(height: 0)),
          ],
        ),
      ),
    );
  }
}


class ViewSeachProductsCataloguie extends StatefulWidget {
  // description: vista para buscar productos en el catalogo 
  const ViewSeachProductsCataloguie({super.key});

  @override
  State<ViewSeachProductsCataloguie> createState() => _ViewSeachProductsCataloguieState();
}

class _ViewSeachProductsCataloguieState extends State<ViewSeachProductsCataloguie> {


  

  // controllers  
  final ModeratorController controller = Get.find<ModeratorController>();
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

    return Material( 
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        appBar: appBar,
        body: body,  
    
      ),
    ); 
  }
  //
  // WIDGETS VIEW
  //
  PreferredSizeWidget get appBar{
    // description: appbar de la vista, con un textfield search, un iconbutton de clean y un vista de productos seleccionados
    return AppBar(   
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
        controller.getMarks.isEmpty? Container() : Text('Marcas',style: textStylePrimary),
        const SizedBox(height: 5), 
        Wrap(
          children: [
            for (Mark element in controller.getMarks)
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
    
    /// Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query]. 
    final List<Product> filteredSuggestions = filteredItems(query: getQuery);

    // condition : si no hay query entonces mostramos las categorias
    if(getQuery.isEmpty){
      return Padding(
        padding: const EdgeInsets.only(top: 0,left: 12,right: 12),
        child: ListView(
            children: [ 
              viewMarks,
            ],
          ),
      );
    }
    // condition : si se consulto pero no se obtuvieron resultados
    if(filteredSuggestions.isEmpty && getQuery.isNotEmpty){
      return const Center(child: Text('No se encontraron resultados'));
    }
 

    return ListView.builder( 
      itemCount: filteredSuggestions.length,
      itemBuilder: (context, index) { 
        // values
        Product product = filteredSuggestions[index];  
        return item(product:product); 
      },
    ); 
  }
   

  //
  // WIDGETS COMPONENTS
  //
  Widget item({required Product  product}){

    // var 
    String valueDataUpdate ='Actualizado ${Publications.getFechaPublicacion(fechaPublicacion:product.upgrade.toDate(),fechaActual:  Timestamp.now().toDate() )}'; 


    // styles
    final Color highlightColor = Get.isDarkMode?Colors.white:Colors.black;
    final Color primaryTextColor  = Get.isDarkMode?Colors.white54:Colors.black45;
    final TextStyle textStyleSecundary = TextStyle(color: primaryTextColor,fontWeight: FontWeight.w400);
    // widgets
    final Widget dividerCircle = ComponentApp().dividerDot(color: primaryTextColor);
 
    return Column(
      children: [
        InkWell( 
          // color del cliqueable
          splashColor: Colors.blue, 
          highlightColor: highlightColor.withOpacity(0.1), 
          onTap: () {
            controller.goToProductEdit(product); 
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // image
                ImageProductAvatarApp(url: product.image,size: 75 ),
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
                          product.outstanding?const Icon(Icons.star_rounded,color: Colors.amber,size: 14,):Container(),
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
              ],
            ),
          ),
        ), 
      ComponentApp().divider(), 
      ],
    );
  }

  // FUCTIONS
  List<Product> filteredItems({required String query}) {
    // description : Filtra una lista de elementos [ProductCatalogue] basándose en el criterio de búsqueda [query].
    // Los elementos se filtran de acuerdo a coincidencias encontradas en los atributos
    // 'description', 'nombre de la marca' y 'codigo' de cada elemento.
    return query.isEmpty
    ? controller.getProducts
    : controller.getProducts.where((item) {
        // Convertimos la descripción, marca y código del elemento y el query a minúsculas
        final description = item.description.toLowerCase();
        final brand = item.nameMark.toLowerCase();
        final code = item.code.toLowerCase(); 
        final lowerCaseQuery = query.toLowerCase();  
        // Dividimos el query en palabras individuales
        final queryWords = lowerCaseQuery.split(' '); 
        // Verificamos que todas las palabras del query estén presentes en la descripción, marca código
        return queryWords.every((word) => description.contains(word) || brand.contains(word) || code.contains(word));
      }).toList();
  }
  
}