import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_page/search_page.dart';
import 'package:sell/app/presentation/home/controller/home_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart'; 
import '../../../core/utils/dynamicTheme_lb.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../../../data/datasource/database_cloud.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../controller/moderator_controller.dart';

class ModeratorView extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ModeratorView({Key? key}) : super(key: key);

  @override
  State<ModeratorView> createState() => _ModeratorViewState();
  
}

class _ModeratorViewState extends State<ModeratorView> {
  
  // controllers
  final ScrollController _scrollController = ScrollController();
  // var
  bool _showScrollButton = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ModeratorController>(
      init: ModeratorController(), 
      builder: (controller) {
        return Scaffold(
          appBar: appbar(context: context,controller: controller),
          body: Obx(() => body(controller: controller)),
          floatingActionButton:floatingActionButton ,
        );
      },
    );
  }

  // WIDGETS VIEWS
  String stringFormatLimit({required String input}) {
  int limit = 19;
  if (input.length > limit) {
    return '${input.substring(0,limit)}...';
  } else {
    return input;
  }
}

  PreferredSizeWidget appbar({ required BuildContext context,required ModeratorController controller}) {


    return AppBar(
    title: ComponentApp().buttonAppbar(
        context:  context,
        onTap: () => controller.viewBrands?showSeachMarks(context:context): controller.showSeachDialog(),
        text: controller.viewBrands?'Buscar':'Database',
        iconLeading: Icons.search,
        colorBackground: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        colorAccent: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.7),
        ),
    // barra de carga 
    bottom: controller.getLoading?const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()):viewUserDetails,
    actions: [     
      // buttons : filter list
      PopupMenuButton( 
        icon: ComponentApp().buttonAppbar(
          context: context,
          text: stringFormatLimit(input: controller.getFilterText),
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
            case 'reports':
              controller.setFilterText = 'Reportes';
              controller.viewReports = true;
              controller.update();
              break;
            case 'noData':
              controller.setFilterText = 'Datos faltantes';
              controller.filterProducts(noData: true);
              break;
            default: 
          }
          
        },
        itemBuilder: (BuildContext ctx) => [
              const PopupMenuItem(value: 'all', child: Text('Mostrar todos')),
              const PopupMenuItem(value: 'verified', child: Text('Verificados')),
              const PopupMenuItem(value: 'noVerified', child: Text('Sin verificar')), 
              const PopupMenuItem(value: 'noData', child: Text('Datos faltantes')), 
              const PopupMenuItem(value: '', child: Divider()),
              const PopupMenuItem(value: 'reports', child: Row(
                children: [
                  Icon(Icons.report_gmailerrorred),
                  SizedBox(width: 10),
                  Text('Reportes de usuarios'),
                ],
              )),
            ]),
    ], 
    );
  }

  Widget body({required ModeratorController controller}) {

    // widget
    Widget wrapChipsInfo = Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 6,
        runSpacing: 6,
        children: [
          // chip : cantidad de articulos del catalogo y filtrados
          chipReport(
            color: Colors.black,
            value: controller.totalProducts,
            description: 'Productos',
            onTap: (){
              controller.setFilterText = 'Todos';
              controller.filterProducts();
            },
          ),
          // chip : total de productos destacados
          chipReport(
            color: Colors.black,
            value: controller.totalProductsFavorite,
            description: 'Destacados',
            onTap: (){
              controller.setFilterText = 'Destacados';
              controller.filterProducts(favorite: true);
            },
          ),
          // chip : total de productos verificados
          chipReport(
            color: Colors.black,
            value: controller.totalVerifiedProducts,
            description: 'Verificados',
            onTap: (){
              controller.setFilterText = 'Verificados';
              controller.filterProducts(verified: true);
            },
          ),
          // chip : total de productos no verificados
          chipReport(
            color: controller.totalUnverifiedProducts > 0 ? Colors.orange : Colors.black,
            value: controller.totalUnverifiedProducts,
            description: 'No verificados',
            onTap: (){
              controller.setFilterText = 'No verificados';
              controller.filterProducts(verified: false);
            },
          ), 
          // chip : total de productos revisados sin verificar
          chipReport(
            color: controller.totalReviewedProducts > 0 ? Colors.orange : Colors.black,
            value: controller.totalReviewedProducts,
            description: 'Revisados',
            onTap: (){
              controller.setFilterText = 'Revisados';
              controller.filterProducts(reviewed: true);
            },
          ), 
          // chip : sin revisar
          chipReport(
            color: Colors.red,
            value: controller.totalNotReviewedProducts,
            description: 'Sin revisar',
            onTap: (){
              controller.setFilterText = 'Sin revisar';
              controller.filterProducts(reviewed: false );
            },
          ),
          // chip : total de productos sin algun dato
          chipReport(
            color: controller.totalProductsNoData>0?Colors.orange:Colors.black,
            value: controller.totalProductsNoData,
            description: 'Datos faltantes',
            onTap: (){
              controller.setFilterText = 'Sin datos';
              controller.filterProducts(noData: true);
            },
          ), 
          // chip : total de reportes
          chipReport(
            color: controller.getReports.isNotEmpty ? Colors.orange : Colors.black,
            value: controller.getReports.length,
            description: 'Reportes',
            onTap: (){
              controller.setFilterText = 'Reportes';
              controller.viewReports = true;
              controller.viewProducts = false;
              controller.update();
            },
          ), 
          // chip : marcas de los productos
          chipReport(
            color: Colors.black,
            value: controller.getMarks.length,
            description: 'Marcas',
            onTap: (){
              controller.setFilterText = 'Marcas';
              controller.viewBrands = true;
              controller.viewProducts = false;
              controller.update();
            },
          ),
        ],
      ),
    );  
    Widget chipsDataView = wrapChipsInfo;
    // condition : si esta cargando
    if(controller.getLoading){
      return const Center(child: CircularProgressIndicator());
    }
    // condition : muestra las marcas
    if(controller.viewBrands){
      if(controller.getMarks.isNotEmpty){
        return Stack(
          children: [
            // listview : items
            ListView.builder(
              controller: _scrollController ,
              itemCount: controller.getMarks.length,
              itemBuilder: (BuildContext context, int index) { 
                return Column(
                  children: [
                    index==0?chipsDataView:Container(),
                    listTileBrand(item: controller.getMarks[index]),
                    const Divider(height: 0,thickness:0.4),
                  ],
                );
              },
            ),
            // button : posicionar en la parte superior : _showScrollButton
            if (_showScrollButton)
              Positioned( 
                top: 10, 
                right: 0,
                left: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      _scrollController.animateTo(0,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut).whenComplete(
                        () => setState(() {
                          _showScrollButton = false;
                        }),
                      ); 
                    },
                    child: const Icon(Icons.arrow_upward),
                  ),
                ),
              ),
          ],
        );
      }
    }
    // condition : muestra los reportes de los usuarios
    if(controller.viewReports){ 
      // condition : si no hay reportes
      if(controller.getReports.isEmpty){
        return Column(
          children:[
            chipsDataView,
            const Flexible(child: Center(child: Text('Sin reportes',style: TextStyle(fontWeight: FontWeight.w300)))),
          ]
        );
      }

      return ListView.builder(
        itemCount: controller.getReports.length,
        itemBuilder: (BuildContext context, int index) { 

          return Column(
            children: [
              index==0?chipsDataView:Container(), 
              listTileReport(context: context,item: controller.getReports[index] ),
              const Divider(height: 0,thickness:0.4),
            ],
          );
        },
      );
    }
    // condition : si no hay productos
    if(controller.getProductsFiltered.isEmpty){
      return Column(
        children: [
          chipsDataView,
          const Flexible(child: Center(child: Text('Sin productos',style: TextStyle(fontWeight: FontWeight.w300)))),
        ],
      );
    }

    // description : cuerpo de la vista
    return Stack(
      children: [
        // listview : items
        ListView.builder( 
          controller: _scrollController ,
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
        ),
        // button : posicionar en la parte superior : _showScrollButton
        if (_showScrollButton)
          Positioned( 
            top: 10, 
            right: 0,
            left: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(0,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut).whenComplete(
                    () => setState(() {
                      _showScrollButton = false;
                    }),
                  
                  ); 
                },
                child: const Icon(Icons.arrow_upward),
              ),
            ),
          ),
      ],
    );
  }
  PreferredSize get viewUserDetails{
    // description : muestra informacion basica del usuario actual de la cuenta
    // controllers  
    final ModeratorController moderatorController = Get.find<ModeratorController>(); 
    // return
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Column(
        children: [
          const Divider(height: 0,thickness:0.4),
          Container(
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
            child: Row( 
              children: [
                // view : datos del usaurio actual
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // view : icon y nombre del usuario
                      Opacity(
                        opacity: 0.5,
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings_outlined,size:14),
                            const SizedBox(width:3),
                            Flexible(child: Text( moderatorController.userFilter['title'],style: const TextStyle(fontWeight: FontWeight.w400),maxLines: 1,overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      // textButton : email del usuario
                      TextButton(
                        onPressed:  ()=> showDialogUserSCreator(),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.all(0)), 
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(moderatorController.userFilter['id'],style: const TextStyle(fontWeight: FontWeight.w300),maxLines: 1,overflow: TextOverflow.ellipsis),
                      ), 
                    ],
                  ),
                ),
                const Spacer(flex:1),
                // view : cantidad de productos creados y actualizados el dia de hoy y el mes actual 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max ,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // view : datos del dia de hoy
                    Row( 
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [ 
                        const Text('Hoy',style: TextStyle(fontWeight: FontWeight.w200)),
                        const SizedBox(width: 5),
                        // chip : productos creados el dia de hoy
                        chipDataPersonality(title: 'create',value: Publications.getFormatAmount(value: moderatorController.totalProductsCreatedTodayByUser(id: moderatorController.userFilter['id'])) ), 
                        // chip : productos creados el mes actual
                        chipDataPersonality(title: 'update',value: Publications.getFormatAmount(value: moderatorController.totalProductsUpdateTodayByUser(id: moderatorController.userFilter['id'])) ),
                    
                      ],
                    ),
                    // view : datos del mes actual
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Este Mes',style: TextStyle(fontWeight: FontWeight.w200)),
                        const SizedBox(width: 5),
                        // chip : productos creados el dia de hoy
                        chipDataPersonality(title: 'create',value: Publications.getFormatAmount(value: moderatorController.totalProductsCreatedCurrentMonthByUser(id: moderatorController.userFilter['id']))),
                        // chip : productos creados el mes actual
                        chipDataPersonality(title: 'update',value: Publications.getFormatAmount(value: moderatorController.totalProductsUpdateCurrentMonthByUser(id: moderatorController.userFilter['id'])) ),
                      ],
                    ),
                    // view : datos totales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Total',style: TextStyle(fontWeight: FontWeight.w200)),
                        const SizedBox(width: 5),
                        // chip : productos creados el dia de hoy
                        chipDataPersonality(title: 'create',value: Publications.getFormatAmount(value: moderatorController.totalProductsCreatedByUser(id: moderatorController.userFilter['id'])) ),
                        // chip : productos creados el mes actual
                        chipDataPersonality(title: 'update',value: Publications.getFormatAmount(value: moderatorController.totalProductsUpdateByUser(id: moderatorController.userFilter['id'])) ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0,thickness:0.4),
        ],
      ),
    );

     
  }
  // WIDGETS COMPONENTS
  Widget chipDataPersonality({required String title,required String value, Color color = Colors.blueGrey}){
    // description : chip con informacion personal
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:4,vertical:0),
      margin: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [ 
          Text(title,style: TextStyle(color: color,fontWeight: FontWeight.w300)),
          const SizedBox(width:2),
          Text(value,style: TextStyle(color: color,fontWeight: FontWeight.w400)),
        ],
      ),
    
    );
  }
  Widget actionChipUser({required String name, required int create ,required int updated ,required bool filterCreator}){

    // controlles
    final ModeratorController controller = Get.find<ModeratorController>();

    return PopupMenuButton<String>( 
      child: Container( 
        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 2), 
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row( 
          mainAxisSize: MainAxisSize.min,
          children: [
            // text : id del usuario
            Flexible(fit:FlexFit.tight,child: Text( name,style: const TextStyle(fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,maxLines: 1)),
            // text : cantidad de productos creados por el usuario
            Text(' (${ Publications.getFormatAmount(value:create).toString()}) (${ Publications.getFormatAmount(value:updated).toString()})',style: const TextStyle(fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,maxLines: 1),
          ],
        ), 
      ),
      onSelected: (value) { 
        if(value=='create'){ 
          controller.filterProducts(idUserCreator: name);
        }
        if(value=='update'){
          controller.filterProducts(idUserUpdate: name);
        }
        if(value=='all'){
          controller.filterProducts(idUserCreator: name,idUserUpdate: name);
        }  
        controller.loadFilteredProductsByUser(idUser: name);
        Get.back();
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem(value: 'create', child: Text('Ver creados')), 
          const PopupMenuItem(value: 'update', child: Text('Ver actualizados')),
          const PopupMenuItem(value: 'all', child: Text('Ver todos')),
        ];
      },
    ); 
  }

  Widget listTileProduct({required Product product}) {
    // description : ListTile con detalles del producto
    // controlles 
    final ModeratorController controller = Get.find<ModeratorController>();
    // var
    double titleSize = 16;
    String valueDataUpdate ='Actualizado ${Publications.getFechaPublicacion(fechaPublicacion: product.upgrade.toDate(), fechaActual: Timestamp.now().toDate())}';

    // styles
    final Color primaryTextColor = Get.isDarkMode ? Colors.white : Colors.black;
    final Color secundayTextColor = Get.isDarkMode ? Colors.white.withOpacity(0.5)  : Colors.black.withOpacity(0.5);
    final TextStyle textStylePrimery = TextStyle(color: primaryTextColor, fontWeight: FontWeight.w400);
    final TextStyle textStyleSecundary = TextStyle(color: secundayTextColor, fontWeight: FontWeight.w400);

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
        //  textrich 
        RichText(
          text: TextSpan( 
            children: <TextSpan>[
              TextSpan(text:product.code, style: textStyleSecundary.copyWith(fontSize: 12)), 
              product.verified?const TextSpan(text:''): const TextSpan(text: ' | ', style: TextStyle(color: Colors.black54)),
              // text : si el producto fue revisado y no esta verificado
              product.verified?const TextSpan(text:''):product.reviewed ? const TextSpan(text: 'Revisado sin verificar', style: TextStyle(color: Colors.orange)): TextSpan(text:'Sin revisar', style: TextStyle(color: Colors.red[300]))
            ],
          ),
        ), 
        // text : fecha de la ultima actualización
        Text(valueDataUpdate, style: textStyleSecundary.copyWith(fontSize: 12)),
        // Text : id del usuario que creo el producto
        product.idUserCreation==''?Container():Row(
          children: [
            Text('Creado por ', style: textStyleSecundary.copyWith(fontSize: 12)),
            Flexible(
              child: Container(
                color: Colors.blue.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal:5),
                child: Text(product.idUserCreation, style: textStyleSecundary.copyWith(fontSize: 12),maxLines: 1)),
            ),
          ],
        ),
        // text : id del usuario que actualizo el producto\
        product.idUserUpgrade==''?Container():Padding(
          padding: const EdgeInsets.only(top:2),
          child: Row(
            children: [
              Text('Modificado por ', style: textStyleSecundary.copyWith(fontSize: 12)),
              Flexible(
                child: Container(
                  color: Colors.blue.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal:5),
                  child: Text(product.idUserUpgrade, style: textStyleSecundary.copyWith(fontSize: 12),maxLines: 1)),
              ),
            ],
          ),
        ),
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
                  Padding(padding: EdgeInsets.symmetric(horizontal: product.image == '' ? 27 : 0),child: ImageProductAvatarApp(url: product.image,size: product.image == '' ? 25 : 80)),
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
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        !product.favorite? Container(): const Icon(Icons.star_purple500_sharp,size: 12,color: Colors.orange),!product.favorite? Container() : const SizedBox(width: 2),
                                        Flexible(child: Text(product.description,maxLines: 1,overflow: TextOverflow.ellipsis,style:textStylePrimery.copyWith(fontSize: titleSize))),
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

  Widget listTileReport({required ReportProduct item,required BuildContext context}){

    // controlles 
    final ModeratorController controller = Get.find<ModeratorController>();
    // var 
    String description = item.description == '' ? 'sin datos' :item.description;

     
    

    return ElasticIn(
      child: ListTile(
        title: Text(item.idProduct),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // text : descripcion del reporte
            RichText(
              text: TextSpan( 
                style: DefaultTextStyle.of(context).style,  
                children: <TextSpan>[
                  TextSpan(text:'Description: ', style: TextStyle(color: DefaultTextStyle.of(context).style.color?.withOpacity(0.5))), 
                  TextSpan(text:description, style: const TextStyle(fontWeight: FontWeight.w300)), 
                ],
              ),
            ),
            // text : datos reportados
            Text('Datos reportados:',style: TextStyle(color: DefaultTextStyle.of(context).style.color?.withOpacity(0.5))),
            // text : reportes items
            controller.getReports.isEmpty?Container():Row(
              children: item.reports.map((e) => Padding(
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
        leading:  Column(
          children: [
            // avatar : product 
            ImageProductAvatarApp(url:controller.getProduct(id: item.idProduct) == null?'': controller.getProduct(id: item.idProduct)!.image,size: 40),
            // text : descripcion del producto
            SizedBox(
              width: 75,
              child: Text(controller.getProduct(id: item.idProduct) == null?'null':controller.getProduct(id: item.idProduct)!.description,style: const TextStyle(fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis,maxLines:1)),
          ],
        ),
        // trailing : eliminar reporte
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            // condition : si se selecciona eliminar reporte
            if(value=='Eliminar reporte'){
              controller.deleteReport(id: item.id);
            }
            // condition : si se selecciona navegar al producto
            if(value=='Ver producto'){
              if(controller.getProduct(id: item.idProduct) != null){
                controller.goToProductEdit(controller.getProduct(id: item.idProduct)!);
              }
            }
      
          },
          itemBuilder: (BuildContext context) {
            return ['Ver producto', 'Eliminar reporte', ''].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
        onTap: ()=> controller.goToProductEdit(controller.getProduct(id: item.idProduct)!),
          
      ),
    );
  }

  Widget listTileBrand({required Mark item}){

    // controlles 
    final ModeratorController controller = Get.find<ModeratorController>();

    return ElasticIn(
      child: ListTile(
        title: Text(item.name,maxLines:1),
        subtitle: item.description.isEmpty?null:Opacity(opacity: 0.7,child: Text(item.description,maxLines:2)),
        leading: ImageProductAvatarApp(url: item.image,size: 40), 
        trailing: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: Text(controller.totalNumberOfBrandedProducts(idBrand: item.id).toString())),
        onTap: ()=> controller.showEditBrandDialogFullscreen(mark: item),
      ),
    );
  }

  Widget chipReport({required int value,required String description,required Function() onTap,Color color = Colors.blue}) {
    // description : chip con la cantidad de reportes
    return ActionChip(
      color: WidgetStateProperty.all(color.withOpacity(0.1)),
      onPressed: onTap,
      side: const BorderSide(color: Colors.transparent),
      visualDensity: VisualDensity.compact,
      label: Column(
        children: [
          Text(Publications.getFormatAmount(value: value),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(description,
              style:const  TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
        ],
      ),
      backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
    );
  }

  Widget get floatingActionButton{
    // controllers
    final ModeratorController controller = Get.find<ModeratorController>();

    if(controller.viewProducts == false && controller.viewBrands == false){
      return Container();
    }

    return  FloatingActionButton(
      onPressed: (){
        if(controller.viewProducts){
          // crear producto
          controller.goToSeachProduct();
        }
        if(controller.viewBrands){
          // crear marca
          controller.showEditBrandDialogFullscreen(mark: Mark(upgrade: Timestamp.now(),creation: Timestamp.now()));
        }

      },
      backgroundColor: Colors.blue, 
      child: const Icon(Icons.add,color: Colors.white,),
    );
  }

  // DIALOG //  
  void showDialogUserSCreator(){
    // controlles 
    final ModeratorController controller = Get.find<ModeratorController>(); 
    final HomeController homeController = Get.find<HomeController>();
    // var 
    List ids = controller.usersMap.keys.toList();
    // posicionar el usuario actual al inicio de la lista
    ids.remove(homeController.getProfileAdminUser.email);
    ids.insert(0,homeController.getProfileAdminUser.email);
    // dialog
    showDialog(
      context: Get.overlayContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Usuarios'), 
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder( 
              shrinkWrap: true, 
              itemCount: ids.length,
              itemBuilder: (BuildContext context, int index) {
                // var
                String key = ids[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // text : 'usuario actual'
                    key == homeController.getProfileAdminUser.email?const Text('Moderador',style: TextStyle(fontWeight: FontWeight.w300,fontSize:12),textAlign: TextAlign.start,):Container(),
                    // view : chip de usuario
                    actionChipUser(filterCreator: true,name: key,create: controller.totalProductsCreatedByUser(id:key) ,updated: controller.totalProductsUpdateByUser(id:key)),
                    key == homeController.getProfileAdminUser.email? const Divider():Container(),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    ); 
  } 
  void showSeachMarks({required BuildContext context}){
    // description: muestra un dialogo de busqueda de marcas

    // controllers
    final ModeratorController controller = Get.find<ModeratorController>();

    // var
    Color colorAccent = Get.theme.brightness == Brightness.dark ? Colors.white : Colors.black;


    showSearch(
      context: context,
      delegate: SearchPage<Mark>(
        searchStyle: TextStyle(color: colorAccent),
        barTheme: Get.theme.copyWith(hintColor: colorAccent, highlightColor: colorAccent,inputDecorationTheme: const InputDecorationTheme(filled: false)),
        items: controller.getMarks,
        searchLabel: 'Buscar marca',
        suggestion: const Center(child: Text('ej. Miller')),
        failure: const Center(child: Text('No se encontro :(')),
        filter: (product) => [product.name,product.description],
        builder: (mark) => Column(mainAxisSize: MainAxisSize.min,children: <Widget>[
          listTileBrand(item: mark),
          const Divider(),
          ]),
      ),
    );
  }
  // OVERRIDE //
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  } 
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.offset >= 5000) {
        if(_showScrollButton) return;
        setState(() {
          _showScrollButton = true;
        });
      } 
    });
    super.initState();
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
  Widget item({required Product product}) {
    // description : ListTile con detalles del producto

    // var
    double titleSize = 16;
    String valueDataUpdate ='Actualizado ${Publications.getFechaPublicacion(fechaPublicacion: product.upgrade.toDate(), fechaActual: Timestamp.now().toDate())}';

    // styles
    final Color primaryTextColor = Get.isDarkMode ? Colors.white : Colors.black;
    final Color secundayTextColor = Get.isDarkMode ? Colors.white.withOpacity(0.5)  : Colors.black.withOpacity(0.5);
    final TextStyle textStylePrimery = TextStyle(color: primaryTextColor, fontWeight: FontWeight.w400);
    final TextStyle textStyleSecundary = TextStyle(color: secundayTextColor, fontWeight: FontWeight.w400);

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
        product.idUserCreation==''?Container():Row(
          children: [
            Text('Creado por ', style: textStyleSecundary.copyWith(fontSize: 12)),
            Flexible(
              child: Container(
                color: Colors.blue.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal:5),
                child: Text(product.idUserCreation, style: textStyleSecundary.copyWith(fontSize: 12))),
            ),
          ],
        ),
        // text : id del usuario que actualizo el producto\
        product.idUserUpgrade==''?Container():Padding(
          padding: const EdgeInsets.only(top:2),
          child: Row(
            children: [
              Text('Modificado por ', style: textStyleSecundary.copyWith(fontSize: 12)),
              Flexible(
                child: Container(
                  color: Colors.blue.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal:5),
                  child: Text(product.idUserUpgrade, style: textStyleSecundary.copyWith(fontSize: 12))),
              ),
            ],
          ),
        ),
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
                  Padding(padding: EdgeInsets.symmetric(horizontal: product.image == '' ? 27 : 0),child: ImageProductAvatarApp(url: product.image,size: product.image == '' ? 25 : 80)),
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
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        !product.favorite? Container(): const Icon(Icons.star_purple500_sharp,size: 12,color: Colors.orange),!product.favorite? Container() : const SizedBox(width: 2),
                                        Flexible(child: Text(product.description,maxLines: 1,overflow: TextOverflow.ellipsis,style:textStylePrimery.copyWith(fontSize: titleSize))),
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

class CreateMark extends StatefulWidget {
  final Mark mark;
  const CreateMark({required this.mark, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateMarkState createState() => _CreateMarkState();
}
class _CreateMarkState extends State<CreateMark> {

  // others controllers 
  final ModeratorController controllerModerator = Get.find<ModeratorController>();

  //var
  var uuid = const Uuid();
  bool newMark = false;
  String title = 'Nueva marca';
  bool load = false;
  TextStyle textStyle = const TextStyle(fontSize: 24.0);
  final ImagePicker _picker = ImagePicker();
  XFile xFile = XFile('');

  @override
  void initState() {
    newMark = widget.mark.id == '';
    title = newMark ? 'Nueva marca' : 'Editar';
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
    Color? colorAccent = Get.theme.textTheme.bodyLarge!.color;

    return AppBar(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      elevation: 0,
      title: Text(title, style: TextStyle(color: colorAccent)),
      iconTheme: Get.theme.iconTheme.copyWith(color: colorAccent),
      actions: [
        newMark || load ? Container(): IconButton(onPressed: delete, icon: const Icon(Icons.delete)),
        load? Container() : IconButton(icon: const Icon(Icons.check),onPressed: save),
      ],
      bottom: load ? ComponentApp().linearProgressBarApp() : null,
    );
  }

  Widget body() {

    // widgets
    Widget circleAvatarDefault = CircleAvatar(backgroundColor: Colors.grey.shade300,radius: 75.0);

    // var
    final Color fillColor = Get.isDarkMode?Colors.white.withOpacity(0.03):Colors.black.withOpacity(0.03);
    
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              xFile.path != ''
                  ? CircleAvatar(backgroundImage: FileImage(File(xFile.path)),radius: 76,)
                  : CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.mark.image,
                      placeholder: (context, url) => circleAvatarDefault,
                      imageBuilder: (context, image) => CircleAvatar(backgroundImage: image,radius: 75.0),
                      errorWidget: (context, url, error) => circleAvatarDefault,
                    ),
              load ? Container(): TextButton(onPressed: getLoadImageMark,child: const Text("Cambiar imagen")),
            ],
          ),
        ),
        // view : nombre de la marca
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.name),
            onChanged: (value) => widget.mark.name = value,
            decoration: InputDecoration(
                filled: true, 
                fillColor: fillColor,
                labelText: "Nombre de la marca"),
            style: textStyle,
          ),
        ),
        // view : descripcion de la marca
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            enabled: !load,
            controller: TextEditingController(text: widget.mark.description),
            onChanged: (value) => widget.mark.description = value, 
            minLines: 1, // Definir el mínimo de líneas
            maxLines: null, // se expandirá automáticamente
            maxLength: 160,
            decoration: InputDecoration(filled: true,fillColor: fillColor,labelText: "Descripción (opcional)"),
            style: textStyle,
          ),
        ),
        // view : botones de edicion
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // view : buscar en google
              Row(
                children: [
                  // text 
                  const Text('Buscar en google:'),
                  const Spacer(),
                  // button : textButton : buscar en google
                  TextButton(
                      onPressed: () async {
                        String clave = 'logo ${widget.mark.name}';
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave&source=lnms&tbm=isch&sa");
                        await launchUrl(uri,mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Imagen del logo' )),
                  // textButton : buscar en google
                  TextButton(
                      onPressed: () async {
                        String clave = 'que industria es la marca ${widget.mark.name}?';
                        Uri uri = Uri.parse("https://www.google.com/search?q=$clave");
                        await launchUrl(uri,mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Información')),
                ],
              ),
              // buttom : edicion de imagen
              TextButton(
                onPressed: () async{
                  // values
                  Uri uri = Uri.parse('https://play.google.com/store/apps/details?id=com.camerasideas.instashot&pcampaignid=web_share');
                  //  redireccionara para la tienda de aplicaciones
                  await launchUrl(uri,mode: LaunchMode.externalApplication);
                },
                child: const Text('Editar imagen con InstaShot'),
              ),
            ],
          ),
        ), 
      ],
    );
  }

  //  MARK CREATE
  void getLoadImageMark() {
    _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 720.0,
      maxHeight: 720.0,
      imageQuality: 55,
    ).then((value) {
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
      await Database.referenceStorageProductPublic(id: widget.mark.id).delete().catchError((_) => null);
      // delete document firestore
      await Database.refFirestoreMark().doc(widget.mark.id).delete()
          .then((value) {
        // eliminar el objeto de la lista manualmente para evitar hacer una consulta innecesaria
        controllerModerator.getMarks.remove(widget.mark);
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
    if (newMark) {
      // generate Id
      widget.mark.id = uuid.v1();
      // en el caso que la ID siga siendo '' generar un ID con la marca del tiempo
      if (widget.mark.id == '') {widget.mark.id = DateTime.now().millisecondsSinceEpoch.toString();}
    }
    if (widget.mark.name != '') {
      // image save
      // Si el "path" es distinto '' procede a guardar la imagen en la base de dato de almacenamiento
      if (xFile.path != '') {
        Reference ref = Database.referenceStorageProductPublic(id: widget.mark.id);
        // referencia de la imagen
        UploadTask uploadTask = ref.putFile(File(xFile.path));
        // cargamos la imagen a storage
        await uploadTask;
        // obtenemos la url de la imagen guardada
        await ref.getDownloadURL().then((value) => widget.mark.image = value);
      } 
      
      // mark save
      if( newMark ){
        // set
        widget.mark.creation = Timestamp.now();
        widget.mark.upgrade = Timestamp.now();
        // creamos un docuemnto nuevo
        await Database.refFirestoreMark().doc(widget.mark.id).set(widget.mark.toJson()).whenComplete(() {
          
          // agregar el obj manualmente para evitar consulta a la db  innecesaria
          controllerModerator.getMarks.add(widget.mark); 
          Get.back();
        });
      }else{
        // set
        widget.mark.upgrade = Timestamp.now();
        // actualizamos un documento existente
        await Database.refFirestoreMark().doc(widget.mark.id).update(widget.mark.toJson()).whenComplete(() {
 
          // actualizar el objeto manualmente para evitar consulta a la db  innecesaria
          for (var element in controllerModerator.getMarks) {
            if(element.id == widget.mark.id){
              element = widget.mark;
            }
          }
          Get.back();
        });
      }
      // logic : actualizamos la vista 
      controllerModerator.setUpdateCount = controllerModerator.getUpdateCount + 1;
      controllerModerator.update();

    } else {
      Get.snackbar('', 'Debes escribir un nombre de la marca');
    }
  }

}


