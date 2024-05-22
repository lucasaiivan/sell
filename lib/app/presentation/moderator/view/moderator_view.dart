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
    title: const Text('Productos publicados'),
    actions: [
      // buttons : filter list
      PopupMenuButton( 
        icon: ComponentApp().buttonAppbar(
          context: context,
          text:  controller.getFilterText,
          iconTrailing: Icons.filter_list,  
        ), 
          onSelected: (selectedValue) => controller.filterProducts(id: selectedValue),
          itemBuilder: (BuildContext ctx) => [
                const PopupMenuItem(value: 'all', child: Text('Mostrar todos')),
                const PopupMenuItem(value: 'verified', child: Text('No verificados')),
                const PopupMenuItem(value: 'create', child: Text('Creados por mi')), 
              ]),
    ], 
    );
  }
  Widget get body {

    // widget
    Widget infoChips = Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 10,
        children: [
          // chip : cantidad de articulos del catalogo y filtrados
          Chip(
            side: const BorderSide(color: Colors.transparent),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(controller.getProducts.length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Artículos',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // chip : total de productos verificados
          Chip(
            side: BorderSide(
                color: Get.theme.colorScheme.secondary.withOpacity(0.0)),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(controller.getProductsFiltered.length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Verificados',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // chip : total de productos no verificados
          Chip(
            side: BorderSide(
                color: Get.theme.colorScheme.secondary.withOpacity(0.0)),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(
                    controller.getProductsFilteredNotVerified.length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('No verificados',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
          // chip : total de productos creados por el usuario
          Chip(
            side: BorderSide(
                color: Get.theme.colorScheme.secondary.withOpacity(0.0)),
            visualDensity: VisualDensity.compact,
            label: Column(
              children: [
                Text(controller.getProductsUser.length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Creados por ti',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
              ],
            ),
            backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          ),
        ],
      ),
    ); 

    // description : cuerpo de la vista
    return Obx(() => controller.getLoading? const Center(child: CircularProgressIndicator()): ListView.builder(
          itemCount: controller.getProducts.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return infoChips;
            }
            return listTileProduct(product: controller.getProducts[index]);
          },
        ));
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
