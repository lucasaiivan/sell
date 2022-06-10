// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/utils/dimensions.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';
import 'package:search_page/search_page.dart';
import '../controller/sales_controller.dart';

class SalesView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SalesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesController>(
      init: SalesController(),
      initState: (_) {},
      builder: (controller) {
        return Obx(() => Scaffold(
              appBar: appbar(),
              drawer: drawerApp(),
              body: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  controller.getTicketView?Container():Expanded(child: body(controller: controller)),
                  drawerTicket(controller: controller),
                ],
              ),
              floatingActionButton: controller.getTicketView
                  ? floatingActionButtonTicket(controller: controller)
                  : floatingActionButton(controller: controller),
            ));
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar() {
    return AppBar(
      title: Text('Vender'),
    );
  }

  Widget body({required SalesController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* Row(
          crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20,left: 20),
              child: Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Icon(Icons.check_circle_outline,color: Colors.green),
                  SizedBox(width: 5),
                  Text('Lector de código de barras activado',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(child: Container()),
            const Padding(
              padding: EdgeInsets.only(top: 20,left: 20,right: 20),
              child: Material(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                  child: Text('Caja 1',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            ),
          ],
        ), */
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:3,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0),
            itemCount: controller.getListProductsSelested.length + 14,
            itemBuilder: (context, index) {
              // en la primera posición muestra el botón para agregar un nuevo objeto
              if (index == 0) {
                // item defaul add
                return Card(
                  elevation: 0,
                  color: Colors.grey.withOpacity(0.1),
                  child: Stack(
                    children: [
                      Center(
                          child: Icon(Icons.add,
                              color: Colors.grey.withOpacity(0.8), size: 30)),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showSearch(
                                context: context,
                                delegate: SearchPage<ProductCatalogue>(
                                  items: controller.listProducts,
                                  searchLabel: 'Buscar',
                                  suggestion:
                                      const Center(child: Text('ej. alfajor')),
                                  failure: const Center(
                                      child: Text('No se encontro :(')),
                                  filter: (product) =>
                                      [product.description, product.nameMark],
                                  builder: (product) => ListTile(
                                    title: Text(product.nameMark),
                                    subtitle: Text(product.description),
                                    onTap: () {
                                      controller.addProduct = product;
                                      Get.back();
                                      //Get.toNamed(Routes.PRODUCT,arguments: {'product': product});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // mostramos un número de elementos vacíos de los cuales el primero tendrá un icono 'add'
              if ((index) <= controller.getListProductsSelested.length) {
                return ProductoItem(
                    producto: controller.getListProductsSelested[index - 1]);
              } else {
                return Card(elevation: 0, color: Colors.grey.withOpacity(0.1));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget drawerTicket({required SalesController controller}) {
    return AnimatedContainer(
      width: controller.getTicketView ? Get.size.width : 0,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: controller.getTicketView ? 1 : 0,
        duration: Duration(milliseconds: controller.getTicketView ? 1500 : 100),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0,top: 12,right: 0,left:24),
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Get.theme.dividerColor,
            child: Drawer(
              backgroundColor: Colors.transparent,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ticket 1',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(
                        'Total: ${Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}',
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGETS COMPONENTS
  Widget floatingActionButton({required SalesController controller}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
            backgroundColor: Colors.amber,
            onPressed: () {
              // dialog show
              Get.defaultDialog(
                  title: 'Vender ítem no registrado',
                  titlePadding: const EdgeInsets.all(20),
                  cancel: TextButton(
                      onPressed: Get.back, child: const Text('Cancelar')),
                  confirm: TextButton(
                      onPressed: () {
                        controller.addSaleFlash(
                            value:
                                controller.textEditingControllerAddFlash.text);
                      },
                      child: const Text('Agregar')),
                  content: TextField(
                    autofocus: true,
                    controller: controller.textEditingControllerAddFlash,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        hintText: '\$0', border: OutlineInputBorder()),
                  ));
            },
            child: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
            )),
        const SizedBox(width: 8),
        FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: () {},
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
            )),
        const SizedBox(width: 8),
        FloatingActionButton.extended(
            onPressed: () {
              controller.setTicketView = true;
            },
            label: Text(
                'Cobrar ${Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}')),
      ],
    );
  }

  Widget floatingActionButtonTicket({required SalesController controller}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: () {
              controller.setTicketView = false;
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
            )),
        const SizedBox(width: 8),
        FloatingActionButton.extended(
            onPressed: () {}, label: const Text('Siguiente')),
      ],
    );
  }
}
