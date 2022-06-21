import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/models/catalogo_model.dart';
import 'package:sell/app/utils/fuctions.dart';
import 'package:sell/app/utils/widgets_utils.dart';
import '../../../utils/dynamicTheme_lb.dart';
import '../controller/sell_controller.dart';

class SalesView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SalesView({Key? key}) : super(key: key);

  late BuildContext buildContext;

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return GetBuilder<SalesController>(
      init: SalesController(),
      initState: (_) {},
      builder: (controller) {
        return Obx(() => Scaffold(
              appBar: appbar(controller: controller),
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
  PreferredSizeWidget appbar({required SalesController controller}) {
    return AppBar(
      title: const Text('Vender'),
      actions: [
        controller.getListProductsSelestedLength != 0
            ? TextButton.icon(
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Descartar Ticket'),
                onPressed: controller.dialogCleanTicketAlert)
            : Container(),
      ],
    );
  }

  Widget body({required SalesController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widgetProducts,
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 1.0, mainAxisSpacing: 1.0),
            itemCount: controller.getListProductsSelested.length + 15,
            itemBuilder: (context, index) {
              // mostramos un número de elementos vacíos de los cuales el primero tendrá un icono 'add'
              if (index < controller.getListProductsSelested.length) {
                return ProductoItem(
                    producto: controller.getListProductsSelested[index]);
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
          padding:
              const EdgeInsets.only(bottom: 2, top: 12, right: 5, left: 24),
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: Get.theme.brightness == Brightness.dark
                ? Colors.white10
                : Colors.white,
            child: Drawer(
              backgroundColor: Colors.transparent,
              child: Center(
                child: controller.getStateConfirmPurchase
                    ? widgetConfirmedPurchase()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 20),
                          const Text('Ticket',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          Text(
                              '${controller.getListProductsSelestedLength} items'),
                          Text(
                              'Total: ${Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          // lines ------
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Dash(
                                color: Get.theme.dividerColor,
                                height: 5,
                                width: 12),
                          ),
                          // view 2
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 24,
                                top: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text('Paga con:'),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(
                                            controller.getTicket.payMode ==
                                                    'effective'
                                                ? 5
                                                : 0)),
                                    icon:
                                        const Icon(Icons.person_outline_sharp),
                                    onPressed: controller.showDialogMount,
                                    label: Text(
                                        controller.getValueReceivedTicket != 0.0
                                            ? Publications.getFormatoPrecio(
                                                monto: controller
                                                    .getValueReceivedTicket)
                                            : 'Ingresar efectivo'),
                                  ),
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(
                                            controller.getTicket.payMode ==
                                                    'mercadopago'
                                                ? 5
                                                : 0)),
                                    icon:
                                        const Icon(Icons.check_circle_rounded),
                                    onPressed: () => controller
                                        .setPayModeTicket = 'mercadopago',
                                    label: const Text('Mercado Pago'),
                                  ),
                                  ElevatedButton.icon(
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(
                                            controller.getTicket.payMode ==
                                                    'card'
                                                ? 5
                                                : 0)),
                                    icon:
                                        const Icon(Icons.credit_card_outlined),
                                    onPressed: () =>
                                        controller.setPayModeTicket = 'card',
                                    label:
                                        const Text('Tarjeta de Debito/Credito'),
                                  ),
                                  const SizedBox(height: 12),
                                  controller.getValueReceivedTicket == 0 ||
                                          controller.getTicket.payMode !=
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
                                                text: controller
                                                    .getValueReceived(),
                                                style: const TextStyle(
                                                    fontSize: 30),
                                              ),
                                            ],
                                          ),
                                        )
                                ],
                              ),
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

  Widget get widgetProducts {
    // controller
    final SalesController salesController = Get.find();

    return SizedBox(
      width: double.infinity,
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:
            salesController.getRecentlySelectedProductsList.length + 10,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            salesController.seach(context: context);
                          },
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            child: Icon(
                              Icons.search,
                              color: Colors.grey.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                      const Text('Buscar'),
                    ],
                  ),
                ),
                (index <
                        salesController
                            .getRecentlySelectedProductsList.length)
                    ? circleAvatarProduct(productCatalogue: salesController.getRecentlySelectedProductsList[index])
                    : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.withOpacity(0.05),
                  ),
                ),
                const Text(''),
              ],
            ),
              ],
            );
          }
          // mostramos un número de elementos vacíos de los cuales el primero tendrá un icono 'add'
          if (index <
              salesController.getRecentlySelectedProductsList.length) {
            return circleAvatarProduct(productCatalogue: salesController.getRecentlySelectedProductsList[index]);
            
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.withOpacity(0.05),
                  ),
                ),
                const Text(''),
              ],
            );
          }
        },
      ),
    );
  }

  Widget circleAvatarProduct({required ProductCatalogue productCatalogue}) {

    // controller
    final SalesController salesController = Get.find();

    return Container(
      width: 81.0,
      height: 110.0,
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              salesController.verifyExistenceInSelected(item: productCatalogue);
            },
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: productCatalogue.image,
                  placeholder: (context, url) =>
                      CircleAvatar(backgroundColor: Get.theme.dividerColor,child: Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice))),
                  imageBuilder: (context, image) => CircleAvatar(
                    radius: 35,
                    backgroundImage: image,
                  ),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(radius: 35,backgroundColor: Get.theme.dividerColor,child:Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyText1?.color)),),
                ),
                const SizedBox(
                  height: 3.0,
                ),
                Text(productCatalogue.description,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                    overflow: TextOverflow.clip,maxLines: 1,
                    softWrap: false)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget widgetConfirmedPurchase() {
    // controller
    final SalesController controller = Get.find();
    // var
    TextStyle styleText = const TextStyle(fontSize: 18);
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: ElasticIn(
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: Colors.green[400],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                // icon
                const Icon(
                  Icons.check_rounded,
                  size: 120,
                  color: Colors.white,
                ),
                const Text('Hecho',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 100),
                Text(
                    style: styleText,
                    'Monto total: ${Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}'),
                const SizedBox(height: 12),
                controller.getValueReceivedTicket == 0
                    ? Container()
                    : Text(
                        style: styleText,
                        'Pago con: ${Publications.getFormatoPrecio(monto: (controller.getValueReceivedTicket))}'),
                const SizedBox(height: 12),
                controller.getValueReceivedTicket == 0
                    ? Container()
                    : Text(
                        style: styleText,
                        'Vuelto: ${Publications.getFormatoPrecio(monto: (controller.getValueReceivedTicket - controller.getCountPriceTotal()))}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              controller.showDialogQuickSale();
            },
            child: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
            )),
        const SizedBox(width: 8),
        FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: controller.scanBarcodeNormal,
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
                    controller.setValueReceivedTicket = 0.0;
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
    return controller.getStateConfirmPurchase
        ? Container()
        : Row(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
