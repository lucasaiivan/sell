import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:sell/app/domain/entities/catalogo_model.dart'; 
import 'package:snapping_sheet/snapping_sheet.dart';
import '../../../core/utils/fuctions.dart';
import '../../../core/utils/widgets_utils.dart';
import '../controller/product_controller.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key}); 


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (controller) {
        return Scaffold(
          appBar: appbar,
          body: body,
        );
      },
    );
  }

  // -- WIDGETS VIEWS -- //
  PreferredSizeWidget get appbar {
    // controller
    final controller = Get.find<ProductController>();
    // widgets
    Widget titleWidget =  controller.getProduct.idMark==''?const Text('Producto'):Row(
      children: [
        controller.getProduct.imageMark==''?Container():ComponentApp().userAvatarCircle(urlImage: controller.getProduct.imageMark,radius: 12,empty: true),
        controller.getProduct.imageMark==''?Container():const SizedBox(width: 8),
        Flexible(child: Text(controller.getProduct.nameMark,overflow: TextOverflow.ellipsis,maxLines: 1)),
      ],
    );

    return AppBar(
      titleSpacing: 0,
      title: titleWidget,
      actions: [
        IconButton(
          icon: const  Icon(Icons.report_gmailerrorred),
          onPressed:showDialogProductReport,
        ),
      ],
    );
  }

  Widget get body { 

    // controller
    final controller = Get.find<ProductController>();

    return SnappingSheet(
      lockOverflowDrag: true,  
      // snappingPositions : posiciones de la hoja
      snappingPositions: const [
        // posicion inicial
        SnappingPosition.factor(
          positionFactor: 0.0,
          snappingCurve: Curves.easeOutExpo,
          snappingDuration: Duration(seconds: 1),
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        // posicion media
        SnappingPosition.factor(
          snappingCurve: Curves.elasticOut,
          snappingDuration: Duration(milliseconds: 1750),
          positionFactor: 0.5,
        ),
        // posicion final
        SnappingPosition.factor(
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(seconds: 1),
          positionFactor: 1,
        ),
      ],
      grabbing: persistentHeader,// contenido cabecera persistente
      grabbingHeight: 170,
      sheetAbove: null,
      sheetBelow: SnappingSheetContent(
        draggable: true,  
        sizeBehavior: const SheetSizeFill(), // sirve para que el contenido se ajuste al tamaño del contenido
        child: expandableContent, // contenido expandible
      ),
      // child : contenido principal
      child: ListView(  
        controller: controller.scrollController,
        children: [
          productDataView, 
          categoryView,
          providerView,
          markView,
          const SizedBox(height: 200),
        ],
      ),  
    );
  }
  // ------------------  //
  // -- WIDGETS VIEWS -- //
  // ------------------  //
  Widget get persistentHeader {
    // controller
    final controller = Get.find<ProductController>();
    // style
    const Color colorBackground = Colors.black;
    const Color colorText = Colors.white; 
    // var 
    String numberOfStoresText = controller.getListPricesForProduct.isEmpty? '':'${Publications.getFormatAmount(value: controller.getListPricesForProduct.length )}${controller.getListPricesForProduct.length == 1 ? ' comercio publicó su precio' : ' comercios publicaron su precio'}';

    Widget content = ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: Container(
        color: colorBackground,
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12.0, top: 12.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [ 
              // view : line de Bottom sheets
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // view : precio de venta al publico del producto si es esta en el catalogo
              !controller.getItsInTheCatalogue?
              // sino esta en el catalogo
              Flexible(
                fit: FlexFit.loose,  
                child: Center(child: Opacity(
                  opacity: 0.6,
                  child: Material(
                    color: Colors.grey.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.monetization_on_outlined,color:colorText),
                    )),
                )),
              )
              // si esta en el catalogo
              :Expanded(   
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    !controller.getItsInTheCatalogue?Container():
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // text : precio de venta al publico del producto si es esta en el catalogo
                        Text(
                            Publications.getFormatoPrecio( value: controller.getProduct.salePrice ),
                            style: const TextStyle(color: colorText,fontSize: 30, fontWeight: FontWeight.bold),textAlign: TextAlign.end),
                        // text : fecha de publicacion
                        Padding(
                          padding: const EdgeInsets.symmetric( horizontal: 12, vertical: 8),
                          child: Text(Publications.getFechaPublicacion(fechaActual: Timestamp.now().toDate(),fechaPublicacion:controller.getProduct.upgrade.toDate()).toLowerCase(),
                          style: const TextStyle(color: colorText),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textDirection: TextDirection.ltr,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // text : porcentaje de ganancia
                        controller.getProduct.purchasePrice != 0.0
                            ? Material(
                              color: Colors.green.withOpacity(0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical:1.0),
                                child: Text(controller.getProduct.getPorcentageFormat,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                            : Container(), 
                        controller.getProduct.purchasePrice != 0.0?const SizedBox(width: 8):Container(),
                        // text : monto de beneficio de ganancia
                        controller.getProduct.purchasePrice != 0.0
                            ? Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: controller.getProduct.getBenefits,
                                      style: TextStyle(
                                          color: Colors.green.withOpacity(0.9),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ' de Ganancia',
                                      style: TextStyle(
                                          color: Colors.green.withOpacity(0.8), fontSize: 12.0),
                                    ),
                                    
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_up,color: colorText), 
              Opacity(
                opacity: 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,  
                  children: [
                    // text : cantidad de precios publicados
                    numberOfStoresText==''?Container()
                    :Material( 
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical:1,horizontal:5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.store_mall_directory_rounded,size:14,color: colorText),
                            const SizedBox(width: 4),
                            Text(
                              numberOfStoresText,
                              style: const TextStyle(color: colorText, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // text : accion
                    const Text(
                      'Deslice hacia arriba para ver',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorText, fontSize: 12.0)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return content;
  }
  Widget get expandableContent {
    // style
    const Color colorBackground = Colors.black;
    return Obx(() => Container(
      color: colorBackground,
      width: double.infinity,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.only(bottom: 12.0, left: 12.0, right: 12.0, top: 12.0),
      child: latestPricesUI,
      ),
    );
  }
  Widget get productDataView {

    // controller
    final controller = Get.find<ProductController>();
    // var
    final Color textDescriptionStyleColor = Get.isDarkMode?Colors.white.withOpacity(0.8):Colors.black.withOpacity(0.8); 

    // view : descripcion del producto
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [  
          // view : texto y imagen
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              //  image : avatar del producto
              controller.getProduct.local? Container():Padding(padding: const EdgeInsets.only(right: 12.0),child: ImageProductAvatarApp(url: controller.getProduct.image,size:75,radius:15)),
              // text  : descripción del producto
              Expanded(
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // view : codigo y candiadad de comercios
                    Row( 
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // icon : verificacion
                        controller.getProduct.verified
                            ? const Icon(Icons.verified_rounded,size: 16, color: Colors.blue)
                            : Container(),
                        // spacer si esta verificado
                        controller.getProduct.verified
                            ? const SizedBox(width: 2)
                            : Container(),
                        // text : codigo
                        controller.getProduct.code != ""
                            ? Text(controller.getProduct.code,style: const TextStyle(height: 1, fontSize: 14, fontWeight: FontWeight.w400))
                            : Container(),
                        // text : etiqueta de producto local (en el cátalogo)
                        !controller.getProduct.local?Container():const Opacity(opacity: 0.4, child: Text(' (Cátalogo) ',style: TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400))),
                        // barra separadora
                        controller.getProduct.local?Container():const Opacity(opacity: 0.4,child: Text(' | ',style: TextStyle(height: 1,fontSize: 14, fontWeight: FontWeight.w400))),
                        // text : cantidad de comercios que tienen el producto
                        controller.getProduct.local? Container():Opacity(opacity: 0.4,child: Text('${Publications.getFormatAmount(value: controller.getProduct.followers)} ${controller.getProduct.followers == 1 ? 'comercio' : 'comercios'}')),
                      ],
                    ),
                    const SizedBox(height:12),
                    // text : descripcion del producto
                    Text(controller.getProduct.description,style: TextStyle(height: 1,fontSize: 14,fontWeight: FontWeight.w400,color: textDescriptionStyleColor),textAlign:TextAlign.start ),
                  ],
                ),
              ),
            ],
          ),  
          // view : etiquetas
          Padding(
            padding: const EdgeInsets.only(top: 12,bottom: 12),
            child: Wrap( 
              spacing: 2,
              children: [
                // etiques : [Chip] favorito
                controller.getProduct.local?Container():const SizedBox(height: 12),
                controller.getProduct.favorite?Chip( 
                  side: BorderSide(color: Colors.amber.withOpacity(0.1),width: 1),
                  // icon 
                  avatar: const Icon(Icons.star,size: 16,color: Colors.amber), 
                  label: const Text('Favorito'),
                  backgroundColor: Colors.amber.withOpacity(0.2),
                ):Container(),
                // etiqueta : [Chip] cantidad de stock si es que es premium
                controller.homeController.getIsSubscribedPremium?const SizedBox(height: 12):Container(),
                controller.homeController.getIsSubscribedPremium && controller.getProduct.stock?Chip( 
                  side: BorderSide(color:controller.getProduct.quantityStock<=controller.getProduct.alertStock? Colors.red.withOpacity(0.1):Colors.orange.withOpacity(0.1),width: 1),
                  // icon 
                  avatar: Icon(Icons.archive_rounded,size: 16 ,color: Get.theme.textTheme.bodyLarge?.color,), 
                  label: Text('${controller.getProduct.quantityStock} Disponibles'),
                  backgroundColor: controller.getProduct.quantityStock<=controller.getProduct.alertStock?Colors.red.withOpacity(0.2):Colors.orange.withOpacity(0.2),
                ):Container(),
              ],
            ),
          ), 
          // buttons : actions in catalogue
          controller.getDataUploadStatusProduct==false? const Center(child: SizedBox(height: 24,width: 24,child: CircularProgressIndicator()))
          :Row(
            children: [
              // button : editar producto
              Flexible(
                flex: 1,
                child: ComponentApp().button(
                  padding: const EdgeInsets.symmetric(vertical:0,horizontal: 0),
                  margin: const EdgeInsets.all(0),
                  text: controller.getItsInTheCatalogue?'Editar':'Agregar a mi catálogo',
                  onPressed: () {
                    controller.toNavigationProductEdit(); 
                  }, 
                ),
              ),
              // button : iconbutton con tres puntitos
              controller.getItsInTheCatalogue?PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded),
                itemBuilder: (context) => [
                  // item : eliminar del catalogo
                  const PopupMenuItem(
                    value: 1,
                    child: Text('Eliminar del catálogo'),
                  ),
                ],
                onSelected: (value) {
                  // switch : opciones del menu
                  switch (value) {
                    case 1:
                      showDialogDelete();
                      break;
                  }
                },
              ):Container(),
            ],
          ),  

        ],
      ),
    );
  }
  Widget get categoryView{
    // controllers
    final controller = Get.find<ProductController>();

    if(!controller.getItsInTheCatalogue || controller.getListProductsCategory.isEmpty) return Container();
    
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // view : categoria 
          ListTile(
            title: Text(controller.getProduct.nameCategory,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
            subtitle: const Text('Cátegoria'),
            // trailing : cicle avatar de cantidad de productos de la categoria
            trailing: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Text(controller.getListProductsCategory.length.toString() ),
            ), 
          ),
          // view : lista de productos de la categoria 
          SizedBox(
            height: 165,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal:12.0),
              scrollDirection: Axis.horizontal,
              itemCount: controller.getListProductsCategory.length,
              itemBuilder: (context, index) {
                return itemProduct(product: controller.getListProductsCategory[index]);
              },
            ),
          ),
        ],
      ),
    );

  }
  Widget get providerView{
    // controllers
    final controller = Get.find<ProductController>();

    if(controller.getListProductsProvider.isEmpty || !controller.getItsInTheCatalogue) return Container();
    
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        color: Colors.grey.withOpacity(0.04),
        child: Column(
          children: [
            // view : proveedor 
            ListTile(
              title: Text(controller.getProduct.nameProvider,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
              subtitle: const Text('Proveedor'),
              // trailing : cicle avatar de cantidad de productos del proveedor
              trailing: CircleAvatar(
                backgroundColor: Colors.black12,
                child: Text(controller.getListProductsProvider.length.toString() ),
              ), 
            ),
            // view : lista de productos del proveedor 
            SizedBox(
              height: 100,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal:12.0),
                scrollDirection: Axis.horizontal,
                itemCount: controller.getListProductsProvider.length,
                itemBuilder: (context, index) { 
                  return itemProduct(product: controller.getListProductsProvider[index],direction: Axis.horizontal);
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
  Widget get markView{
    // controllers
    final controller = Get.find<ProductController>();

    if(controller.getListProductsMark.isEmpty || !controller.getItsInTheCatalogue) return Container();
    
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // view : marca 
          ListTile(
            title: Row(
              children: [
                // avatar : de la marca si tiene
                controller.getProduct.imageMark==''?Container():ComponentApp().userAvatarCircle(urlImage: controller.getProduct.imageMark,radius: 14,empty: true),
                controller.getProduct.imageMark==''?Container():const SizedBox(width: 8),
                Text(controller.getProduct.nameMark,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
              ],
            ),
            subtitle: const Text('Marca'),
            // trailing : cicle avatar de cantidad de productos de la marca
            trailing: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Text(controller.getListProductsMark.length.toString() ),
            ), 
          ),
          // view : lista de productos de la marca 
          SizedBox(
            height: 165,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal:12.0),
              scrollDirection: Axis.horizontal,
              itemCount: controller.getListProductsMark.length,
              itemBuilder: (context, index) {
                return itemProduct(product: controller.getListProductsMark[index]);
              },
            ),
          ),
        ],
      ),
    );

  }
  Widget get latestPricesUI {

    // controllers
    final controller = Get.find<ProductController>();
    // style 
    const Color colorText = Colors.white; 
 

    if (controller.getListPricesForProduct.isNotEmpty) { 

      return controller.getListPricesForProduct.isEmpty
              // view : no hay precios
              ? const Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  child: Text(
                    "No se registró ningún precio para este producto",
                    style: TextStyle(fontSize: 20.0, color: colorText),
                    textAlign: TextAlign.center,
                  ),
                )
              // view : si hay precios del producto
              :ListView.builder( 
              //physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 0.16),
              shrinkWrap: true,
              itemCount: controller.getListPricesForProduct.length,
              itemBuilder: (context, index) {

                // var 
                String town = controller.getListPricesForProduct[index].town;
                String province = controller.getListPricesForProduct[index].province;
                String location = town == '' ? province : '$town, $province';

                return Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 0.0),
                      leading: controller.getListPricesForProduct[index]
                                      .idAccount ==
                                  "" ||
                              controller.getListPricesForProduct[index]
                                      .imageAccount ==
                                  ""
                          ? const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 24.0,
                            )
                          : CachedNetworkImage(
                              imageUrl: controller
                                  .getListPricesForProduct[index].imageAccount,
                              placeholder: (context, url) => const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 24.0,
                              ),
                              imageBuilder: (context, image) => CircleAvatar(
                                backgroundImage: image,
                                radius: 24.0,
                              ),
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 24.0,
                              ),
                            ),
                      title: Text(
                          Publications.getFormatoPrecio(
                              value: controller
                                  .getListPricesForProduct[index].price),
                          style: const TextStyle(
                              color: colorText,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w400)),
                      subtitle: Text(
                          controller.getListPricesForProduct[index].nameAccount,
                          style: TextStyle(color: colorText.withOpacity(0.7),overflow: TextOverflow.ellipsis,fontWeight: FontWeight.w300)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          //vtext : fecha de publicacion
                          Text(
                            Publications.getFechaPublicacion(fechaActual: Timestamp.now().toDate(),fechaPublicacion: controller.getListPricesForProduct[index].time.toDate()).toLowerCase(),
                            textAlign: TextAlign.end,
                            style: TextStyle(fontStyle: FontStyle.normal,fontSize: 12,color: colorText.withOpacity(0.4))),
                          const SizedBox(height: 4),
                          // view : dato de la ubicacion del precio registrado
                          Opacity(
                            opacity: 0.8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // icon
                                const Opacity(opacity: 0.7,child: Icon(Icons.location_on_rounded,size: 12,color:colorText)),
                                const SizedBox(width: 4),
                                // text : ubicacion de la ciudad  del precio
                                Text(location,style: const TextStyle(color: colorText,fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 5.0),
                    (index + 1) == 9 && controller.getListPricesForProduct.length == 9
                        ? TextButton(
                            onPressed: () {
                              controller.readListPricesForProduct(limit: false);
                            },
                            child: const Text('Ver todos'))
                        : Container(),
                  ],
                );
              },
            );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Text(
          "Aun no se registró ningún precio para este producto",
          style: TextStyle(fontSize: 20.0, color: Colors.grey.withOpacity(0.5)),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
  // ----------------------  //
  // ---- WIDGET DIALOG ---- //
  // ----------------------  //
  void showDialogProductReport(){  
    // dialog : permite al usuario reportar un producto
    showDialog(
      context: Get.context!,
      builder: (context) {
        return const ProductReportAlertDialog();
      },
    );
  }
  // dialog : muestra el dialogo para eliminar el producto
  void showDialogDelete() {
    // controller
    final controller = Get.find<ProductController>();
    // widget
    Widget widget = AlertDialog(
      title: const Text(
          "¿Seguro que quieres eliminar este producto de tu catálogo?"),
      content: const Text(
          "El producto será eliminado de tu catálogo y toda la información acumulada"),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          onPressed: (){
            Get.back();
            controller.deleteProductInCatalogue();
          },
          child: const Text('Si, eliminar'),
        ),
      ],
    );

    Get.dialog(widget);
  }
  // ----------------------  //
  // -- WIDGET COMPONENTS -- //
  // ----------------------  // 
  Widget itemProduct({required ProductCatalogue product,Axis direction = Axis.vertical}){

    // controllers
    final controller = Get.find<ProductController>();

    return Container( 
      padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.all(0.0), 
      width: direction==Axis.vertical?110:220, 
      child: InkWell(
        borderRadius:  BorderRadius.circular(8),
        onTap: () {
          // condition : si el producto es local
          if(product.local){
            // navegar a la vista del producto seleccionado
            controller.toNavigationProductEdit();
            return;
          }else{
            // navegar a la vista del producto seleccionado
            controller.loadData(product: product);
            controller.scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
          }
            
        },
        child: direction==Axis.vertical?Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar : imagen del producto
            ImageProductAvatarApp(url:product.image,size: 80),
            const SizedBox(height: 4),
            // text : descripcion del producto
            Flexible(child: Opacity(opacity: 0.8,child: Text(product.description,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),maxLines: 2,overflow: TextOverflow.ellipsis))),
            // text : precio del producto
            Text(Publications.getFormatoPrecio(value: product.salePrice),style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
          ],
        ):Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // avatar : imagen del producto
            ImageProductAvatarApp(url:product.image,size: 80),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left:12),
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    // text : descripcion dxel producto
                    Flexible(child: Opacity(opacity: 0.8,child: Text(product.description,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),maxLines: 2,overflow: TextOverflow.ellipsis))),
                    // text : precio del producto
                    Text(Publications.getFormatoPrecio(value: product.salePrice),style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class ProductReportAlertDialog extends StatefulWidget {
  // crea un ui [AlertDialog] con opciones ([CheckboxListTile]) y un mensaje ([textfield]) para reportar un producto por el usuario
 
  const ProductReportAlertDialog({super.key});

  @override
  State<ProductReportAlertDialog> createState() => _ProductReportAlertDialogState();
}

class _ProductReportAlertDialogState extends State<ProductReportAlertDialog> {

  // controller
  final controller = Get.find<ProductController>();

  // var
  bool stateLoading = false;
  final TextEditingController controller0 = TextEditingController();
  final List<String> listOptions = ['Imagen','Descripción','Marca'];
  final List<bool> listCheck = [false,false,false];

  // ----------- fuctions -----------  //
  void sendReport(){ 
    // function : envia el reporte del producto
    controller.sendReportProduct(
      reports: listOptions.where((element) => listCheck[listOptions.indexOf(element)]).toList(),
      description: controller0.text,
    );
  }

  @override
  Widget build(BuildContext context) {

    return body;
  }
  // ----------------------  //
  // ----- WIDGET VIEW ----- //
  // ----------------------  //
  Widget get body {
    return AlertDialog(
      title: const Row(
        children: [
          // text
          Text('Reportar producto',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          // icon
          Icon(Icons.report_gmailerrorred),
        ],
      ), 
      
      content: SingleChildScrollView(
        child:stateLoading? const Center(child: CircularProgressIndicator()): Column(
          mainAxisSize: MainAxisSize.min,
          children: [ 
            // text : descripcion del reporte
            const Text('Selecciona las opciones que consideres que no corresponde al código del producto'),
            const SizedBox(height: 12),
            // checkbutton : opciones
            Column(
              children: List.generate(listOptions.length, (index) {
                return CheckboxListTile(
                  title: Text(listOptions[index]),
                  value: listCheck[index],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                  
                  onChanged: (value) {
                    // set : valor de la opcion
                    listCheck[index] = value!; 
                    setState(() {});
                    
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            // textfield : mensaje
            TextField(
              controller: controller0,
              maxLines:2, 
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Escribe tu mensaje',
                labelText: 'Mensaje (opcional)',
              ),
            ),
          ],
        ),
      ),
      actions: stateLoading?null: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            // condition : comprobar si hay opciones seleccionadas
            if(listCheck.every((element) => element==false)){
              // mostrar mensaje de error
              Get.snackbar('Debes seleccionar una opción','');
              return;
            }else{
              setState(() {
                stateLoading = true;
                sendReport();
              });
              // cerrar el dialogo
              Get.back();
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  } 


}
