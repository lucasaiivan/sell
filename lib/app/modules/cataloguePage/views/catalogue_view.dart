import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/modules/cataloguePage/controller/catalogue_controller.dart';
import 'package:sell/app/modules/home/controller/home_controller.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';

import '../../../utils/dynamicTheme_lb.dart';

class CataloguePage extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  CataloguePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CataloguePageController>(
      init: CataloguePageController(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          appBar: appbar(context: context),
          drawer: drawerApp(),
          body: body(context: context),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {}, //controller.add,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              )),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required BuildContext context}) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: const Text('Catálogo'),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list))
      ],
    );
  }

  Widget body({required BuildContext context}) {
    // controllers
    final HomeController controller = Get.find();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints.expand(height: 50),
            child:
                TabBar(labelColor: Get.theme.textTheme.bodyText1?.color, tabs: [
              Tab(text: "${controller.getCataloProducts.length} productos"),
              const Tab(text: "Cátegorias"),
            ]),
          ),
          Expanded(
            child: TabBarView(children: [
              widgetListVertical(),
              viewCategory(),
            ]),
          )
        ],
      ),
    );
  }

  Widget widgetListVertical() {
    // controllers
    final HomeController controller = Get.find();

    return Obx(() => ListView.builder(
          itemCount: controller.getCataloProducts.length,
          itemBuilder: (context, index) {
            return listTileProduct(item: controller.getCataloProducts[index]);
          },
        ));
  }

  Widget viewCategory() {
    // mostramos las categorias en un lista
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              title: Container(
                width: 100,
                height: 14,
                color: Colors.grey,
              ),
              subtitle: Container(
                width: 100,
                height: 14,
                color: Colors.grey,
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  // WIDGETS COMPONENTS
  Widget listTileProduct({required ProductCatalogue item}) {

    //  controller
    final CataloguePageController cataloguePageController = Get.find();
    // values
    Color tileColor = item.stock
        ? (item.quantityStock == 0
            ? Colors.red.withOpacity(0.5)
            : Colors.transparent)
        : Colors.transparent;
    String alertStockText =
        item.stock ? (item.quantityStock == 0 ? 'Sin stock' : '') : '';

    return ElasticIn(
      child: Column(
        children: [
          ListTile(
            tileColor: tileColor,
            contentPadding: const EdgeInsets.all(12),
            onTap: () =>
                cataloguePageController.toProductEdit(productCatalogue: item),
            title: Text(item.description, maxLines: 1),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(Publications.getFormatoPrecio(monto: item.salePrice)),
                    item.sales == 0
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.circle,
                                size: 8, color: Get.theme.dividerColor),
                          ),
                    item.sales == 0
                        ? Container()
                        : Text(
                            '${item.sales} ${item.sales == 1 ? 'venta' : 'ventas'}'),
                  ],
                ),
                alertStockText == '' ? Container() : Text(alertStockText),
              ],
            ),
            leading: CachedNetworkImage(
              imageUrl: item.image,
              placeholder: (context, url) =>
                  CircleAvatar(backgroundColor: Get.theme.dividerColor),
              imageBuilder: (context, image) => CircleAvatar(
                backgroundImage: image,
              ),
              errorWidget: (context, url, error) =>
                  CircleAvatar(backgroundColor: Get.theme.dividerColor),
            ),
            trailing: item.stock
                ? Material(
                    color: Get.theme.dividerColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item.quantityStock.toString()),
                    ),
                  )
                : null,
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }

  Widget get widgetProducts {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                ],
              );
            }

            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey.withOpacity(0.1),
              ),
            );
            /* return CachedNetworkImage(
                      imageUrl: cataloguePageController
                          .getCataloProducts[index].image,
                      placeholder: (context, url) =>
                          CircleAvatar(backgroundColor: Get.theme.dividerColor),
                      imageBuilder: (context, image) => CircleAvatar(
                        backgroundImage: image,
                      ),
                      errorWidget: (context, url, error) =>
                          CircleAvatar(backgroundColor: Get.theme.dividerColor),
                    ); */
          },
        ),
      ),
    );
  }
}
