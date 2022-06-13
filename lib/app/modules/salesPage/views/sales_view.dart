import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
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
                  controller.getTicketView
                      ? Container()
                      : Expanded(child: body(controller: controller)),
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
      title: const Text('Vender'),
    );
  }

  Widget body({required SalesController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 1.0, mainAxisSpacing: 1.0),
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
          padding:const EdgeInsets.only(bottom: 2, top: 12, right: 5, left: 24),
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Get.theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.white,
            child: Drawer(
              backgroundColor: Colors.transparent,
              child: Center(
                child:controller.getConfirmPurchase? const Text('Confirm Purchase'): Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    const Text('Ticket',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    Text(
                        'Total: ${Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    // lines ------
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Dash(
                          color: Get.theme.dividerColor, height: 5, width: 12),
                    ),
                    // view 2
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 24,
                              top: 24,
                            ),
                            child: Column(
                              children: [
                                const Text('Paga con:'),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(
                                          controller.ticketModel.payMode ==
                                                  'effective'
                                              ? 5
                                              : 0)),
                                  icon: const Icon(Icons.person_outline_sharp),
                                  onPressed: controller.voidShowDialogMount,
                                  label: Text(controller.getTicketMount != 0.0
                                      ? Publications.getFormatoPrecio(
                                          monto: controller.getTicketMount)
                                      : 'Ingresar efectivo'),
                                ),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(
                                          controller.ticketModel.payMode ==
                                                  'mercadopago'
                                              ? 5
                                              : 0)),
                                  icon: const Icon(Icons.check_circle_rounded),
                                  onPressed: () => controller.setPayModeTicket =
                                      'mercadopago',
                                  label: const Text('Mercado Pago'),
                                ),
                                ElevatedButton.icon(
                                  style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(
                                          controller.ticketModel.payMode ==
                                                  'card'
                                              ? 5
                                              : 0)),
                                  icon: const Icon(Icons.credit_card_outlined),
                                  onPressed: () =>
                                      controller.setPayModeTicket = 'card',
                                  label:
                                      const Text('Tarjeta de Debito/Credito'),
                                ),
                                const SizedBox(height: 12),
                                controller.getTicketMount == 0 ||
                                        controller.ticketModel.payMode !=
                                            'effective'
                                    ? Container()
                                    : RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: 'Vuelto:  ',
                                          style: TextStyle(
                                              color: Get.theme.textTheme
                                                  .headline1?.color),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: controller.getChangeMount(),
                                              style:
                                                  const TextStyle(fontSize: 30),
                                            ),
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
              // default values
              controller.textEditingControllerAddFlashPrice.text = '';
              controller.textEditingControllerAddFlashDescription.text = '';
              // dialog show
              Get.defaultDialog(
                  title: 'Venta rápida',
                  titlePadding: const EdgeInsets.all(20),
                  cancel: TextButton(
                      onPressed: () {
                        controller.textEditingControllerAddFlashPrice.text = '';
                        Get.back();
                      },
                      child: const Text('Cancelar')),
                  confirm: Theme(
                    data: Get.theme.copyWith(brightness: Get.theme.brightness),
                    child: TextButton(
                        onPressed: () {
                          controller.addSaleFlash();
                          controller.textEditingControllerAddFlashPrice.text =
                              '';
                        },
                        child: const Text('Agregar')),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        // mount textfield
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            autofocus: true,
                            controller:
                                controller.textEditingControllerAddFlashPrice,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[1234567890]'))
                            ],
                            decoration: const InputDecoration(
                              hintText: '\$',
                              labelText: "Escribe el precio",
                            ),
                            style: const TextStyle(fontSize: 20.0),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {
                              controller.addSaleFlash();
                              controller
                                  .textEditingControllerAddFlashPrice.text = '';
                            },
                          ),
                        ),
                        // descrption textfield
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextField(
                            autofocus: true,
                            controller: controller
                                .textEditingControllerAddFlashDescription,
                            decoration: const InputDecoration(
                                labelText: "Descripción (opcional)"),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {
                              controller.addSaleFlash();
                            },
                          ),
                        ),
                      ],
                    ),
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
            onPressed: controller.getListProductsSelested.length == 0
                ? null
                : () {
                    controller.setTicketView = true;
                    controller.setTicketMount = 0.0;
                  },
            backgroundColor: controller.getListProductsSelested.length == 0
                ? Colors.grey
                : null,
            label: Text(
                'Cobrar ${controller.getListProductsSelested.length == 0 ? '' : Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}')),
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
            onPressed: controller.confirmedPurchase,
            label: const Text('Confirmar venta')),
      ],
    );
  }
}

class Dash extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const Dash({this.height = 1, this.width = 3, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = width;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
