import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import '../../../domain/entities/catalogo_model.dart';
import '../../../core/utils/dynamicTheme_lb.dart';
import '../../home/controller/home_controller.dart';
import '../controller/sell_controller.dart';

// ignore: must_be_immutable
class SalesView extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  SalesView({Key? key}) : super(key: key);

  late BuildContext buildContext;

  // others controllers
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {

    // set 
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
                  controller.getTicketView? Container(): Expanded(child: body(controller: controller)),
                  drawerTicket(controller: controller),
                ],
              ),
              floatingActionButton: controller.getTicketView ? floatingActionButtonTicket(controller: controller): floatingActionButton(controller: controller),
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
            ? TextButton.icon(icon: const Icon(Icons.clear_rounded),label: const Text('Descartar Ticket'),onPressed: controller.dialogCleanTicketAlert)
            : cashRegisterNumberPopupMenuButton(),
      ],
    );
  }

  Widget body(  {required SalesController controller} ) {
    return NestedScrollView(
      /* le permite crear una lista de elementos que se desplazarían hasta que el cuerpo alcanzara la parte superior */
      floatHeaderSlivers: true,
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // atentos a cualquier cambio que surja en los datos de la lista de marcas
          SliverList(delegate: SliverChildListDelegate([controller.widgetProductSuggestionInfo, widgeSuggestedProducts(context: context,controller1: controller)]))
        ];
      },
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          controller.widgetSelectedProductsInformation,
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,crossAxisSpacing: 1.0,mainAxisSpacing: 1.0),
              itemCount: controller.getListProductsSelested.length + 15,
              itemBuilder: (context, index) {
                // mostramos un número de elementos vacíos de los cuales el primero tendrá un icono 'add'
                List list = controller.getListProductsSelested.reversed.toList();
                if (index < list.length) {
                  if(index == 0 ){return ZoomIn(controller: (p0) => controller.newProductSelectedAnimationController=p0,child: ProductoItem(producto:list[index]));}
                  return ProductoItem(producto:list[index]);
                } else {
                  return ElasticIn(child: Card(elevation: 0, color: Colors.grey.withOpacity(0.1)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget drawerTicket({required SalesController controller}) {

    // values 
    const EdgeInsets  padding = EdgeInsets.symmetric(horizontal: 20,vertical: 2);

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
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Get.theme.brightness == Brightness.dark? Colors.white10: Colors.white,
            child: Drawer(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Center(
                child: controller.getStateConfirmPurchase
                    ? widgetConfirmedPurchase()
                    : ListView(
                      shrinkWrap: false,
                        children: [
                          const SizedBox(height: 20),
                          const Text('Ticket',textAlign: TextAlign.center,style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          Material(
                            color: Colors.blueGrey.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(homeController.getProfileAccountSelected.name,textAlign: TextAlign.center,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            )),
                          const SizedBox(height: 25),
                          // text : cantidad de elementos 'productos' seleccionados
                          Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                const Text('Productos:'),
                                const Spacer(),
                                Text(controller.getListProductsSelestedLength.toString()),
                              ],
                            ),
                          ),
                          // text : medio de pago
                          Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                const Text('Medio:'),
                                const Spacer(),
                                Text(controller.getTicket.getPayMode),
                              ],
                            ),
                          ),
                          // view : lines ------
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),child: Dash(color: Get.theme.dividerColor,height: 2, width: 12)),
                          // text : el monto total de la transacción
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Text('Total',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900,color: Colors.blue)),
                                const Spacer(),
                                Text(Publications.getFormatoPrecio(monto: controller.getCountPriceTotal()),style: const TextStyle(color: Colors.blue,fontSize: 24,fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          // text : paga con 
                          controller.getValueReceivedTicket == 0 ||controller.getTicket.payMode !='effective'
                            ? Container()
                            :Padding(
                              padding: padding,
                              child: Row(
                                children: [
                                  const Text('Pago con:'),
                                  const Spacer(),
                                  Text(controller.getValueReceived()),
                                ],
                              ),
                          ),
                          // text : vuelto 
                          controller.getValueReceivedTicket == 0 ||controller.getTicket.payMode !='effective'
                            ? Container()
                            :Padding(
                              padding: padding,
                              child: Row(
                                children: [
                                  const Text('Vuelto:'),
                                  const Spacer(),
                                  Material(
                                    elevation: 0,
                                    color: Colors.green.shade300,
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                      child: Row(
                                        children: [
                                          const Text('Dar vuelto ',style:TextStyle(color: Colors.white)),
                                          Text(controller.getValueChange(),style: const TextStyle(color: Colors.white,fontSize: 16),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ),
                          // view : lines ------
                          Padding(padding: const EdgeInsets.all(20.0),child: Dash(color: Get.theme.dividerColor,height: 2, width: 12)),
                          // view 2
                          Padding(
                            padding:const EdgeInsets.only(bottom: 24, top: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // texto : texto que se va a mostrar por unica ves
                                controller.widgetTextFirstSale,
                                const Text('El cliente paga con:',style:TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //  button : pago con efectivo
                                    ElevatedButton.icon(
                                      style: ButtonStyle(elevation: MaterialStateProperty.all(controller.getTicket.payMode =='effective'? 5: 0)),
                                      icon: controller.getTicket.payMode != 'effective'?Container():const Icon(Icons.money_rounded),
                                      onPressed: (){
                                        controller.setPayModeTicket = 'effective'; // se
                                        controller.dialogSelectedIncomeCash();
                                      },
                                      label: Text(controller.getValueReceivedTicket != 0.0? Publications.getFormatoPrecio(monto: controller.getValueReceivedTicket): 'Efectivo'),
                                    ),
                                    // button : pago con mercado pago
                                    ElevatedButton.icon(
                                      style: ButtonStyle(elevation: MaterialStateProperty.all(controller.getTicket.payMode == 'mercadopago'? 5: 0)),
                                      icon: controller.getTicket.payMode != 'mercadopago'?Container():const Icon(Icons.check_circle_rounded),
                                      onPressed: () {
                                        controller.setPayModeTicket = 'mercadopago';
                                        // default value
                                        controller.setValueReceivedTicket=0.0;
                                      },
                                      label: const Text('Mercado Pago'),
                                    ),
                                  ],
                                ),
                                //  button : pago con tarjeta de credito/debito
                                ElevatedButton.icon(
                                  style: ButtonStyle(elevation: MaterialStateProperty.all(controller.getTicket.payMode =='card'? 5 : 0)),
                                  icon: controller.getTicket.payMode != 'card'?Container(): const Icon(Icons.credit_card_outlined),
                                  onPressed: (){
                                    controller.setPayModeTicket = 'card';
                                    // default values
                                    controller.setValueReceivedTicket=0.0;
                                  },
                                  label:const Text('Tarjeta de Debito/Credito'),
                                ),
                                const SizedBox(height: 12),
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
  Widget cashRegisterNumberPopupMenuButton(){

    // controllers
    final SalesController salesController = Get.find();

    return PopupMenuButton(
                icon: Material(
                  color: homeController.getIsDarkMode?Colors.white:Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical:1),
                    child: Row(
                      children: [
                        Text('Caja ${salesController.cashRegisterNumber}',style:TextStyle(color: homeController.getIsDarkMode?Colors.black:Colors.white)),
                        const SizedBox(width: 5),
                        Icon(Icons.keyboard_arrow_down_rounded,color: homeController.getIsDarkMode?Colors.black:Colors.white),
                      ],
                    ),
                  ),
                ),
                onSelected: (selectedValue) {
                  salesController.setCashRegisterNumber(number: selectedValue);
                },
                itemBuilder: (BuildContext ctx) => [
                      const PopupMenuItem(value: 1, child: Text('Caja 1')),
                      const PopupMenuItem(value: 2, child: Text('Caja 2')),
                      const PopupMenuItem(value: 3, child: Text('Caja 3')),
                      const PopupMenuItem(value: 4, child: Text('Caja 4')),
                      const PopupMenuItem(value: 5, child: Text('Caja 5')),
                    ]);
  }
  Widget widgeSuggestedProducts({required SalesController controller1,required BuildContext context}) {

    // controllers
    HomeController controller  = Get.find();

    // values
    const double height = 120;

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.getProductsOutstandingList.length ,
                itemBuilder: (context, index) {

                  // values 
                  Widget widget = index <= (controller.getProductsOutstandingList.length-1)? circleAvatarProduct(productCatalogue:controller.getProductsOutstandingList[index]):circleAvatarProduct(productCatalogue: ProductCatalogue(creation: Timestamp.now(), upgrade: Timestamp.now(), documentCreation: Timestamp.now(), documentUpgrade: Timestamp.now()));
                  
                  if(index == 0){ return Row(crossAxisAlignment: CrossAxisAlignment.start,children: [const SizedBox(width: 95.0,height: height),widget]);}
                  return widget;
                },
              ),
        ),
        SizedBox(
          width: 110.0,height: height,
          child: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: <Color>[
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor,
            ], 
            tileMode: TileMode.mirror,
          ),
        ),
          ),
        ),
        circleAvatarBSeachDefault(context: context, seach: true)
      ],
    );
  }

  Widget circleAvatarBSeachDefault({bool seach = false, required BuildContext context}) {
    // controller
    final SalesController salesController = Get.find();

    // values
    double radius = 35.0;
    double spaceImageText = 10;

    return seach
        ? ElasticIn(
            child: Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Container(
                width: 81.0,
                height: 110.0,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => salesController.showSeach(context: context),
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            radius: radius,
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            child: Icon(Icons.search,
                                color: Get.theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black54),
                          ),
                          SizedBox(
                            height: spaceImageText,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text('Buscar',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                softWrap: false),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 12),
            child: ElasticIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      radius: radius,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  const Text(''),
                ],
              ),
            ),
          );
  }

  Widget circleAvatarProduct({required ProductCatalogue productCatalogue}) {
    // controller
    final SalesController salesController = Get.find();

    // values
    bool defaultValues = productCatalogue.id == '';
    double radius = 35.0;
    double spaceImageText = 10;

    // alert control stock
    bool stateAlertStock = productCatalogue.stock && homeController.getProfileAccountSelected.subscribed ? productCatalogue.quantityStock < 5 : false;
    Color borderCicleColor = stateAlertStock? Colors.red: productCatalogue.favorite? Colors.amber: Get.theme.dividerColor;

    return ElasticIn(
      child: Container(
        width: 81.0,
        height: 110.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if( defaultValues == false ){
                  salesController.selectedProduct(item: productCatalogue);
                }
              },
              child: Column(
                children: <Widget>[
                  // image
                  CachedNetworkImage(
                    imageUrl: productCatalogue.image,
                    placeholder: (context, url) => CircleAvatar(
                        radius: radius,
                        backgroundColor: Get.theme.dividerColor,
                        child: defaultValues?Container():Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyText1?.color))),
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: radius,
                      backgroundColor: borderCicleColor,
                      child: CircleAvatar(
                        radius: radius - 1.5,
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        child: CircleAvatar(
                            radius: radius - 5,
                            backgroundColor: Get.theme.scaffoldBackgroundColor,
                            child:defaultValues?Container(): CircleAvatar(radius: radius, backgroundImage: image)),
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: radius,
                      backgroundColor: Get.theme.dividerColor,
                      child: defaultValues?Container(): Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice),style:TextStyle(color: Get.textTheme.bodyMedium?.color)),
                    ),
                  ), 
                  SizedBox(height: spaceImageText),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child:defaultValues?Container(): Text(productCatalogue.description,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget widgetConfirmedPurchase() {
    //----------------------//
    // Slpach view : hecho! //
    //----------------------//

    // values 
    const Color accentColor = Colors.white;
    Color? background = Colors.green[400];


    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: ElasticIn(
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: background,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_rounded,size: 200,color:accentColor),
                SizedBox(height:25),
                Text('Hecho',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: accentColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget floatingActionButton({required SalesController controller}) {

    Widget imageBarCode = Image.asset('assets/scanbarcode.png',color: Colors.white,);

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
            child: SizedBox(
              width: 30,height: 30,
              child: imageBarCode,
            )),
        const SizedBox(width: 8),
        ElasticIn(
          controller: (p0) => controller.floatingActionButtonAnimateController=p0,
          child: FloatingActionButton.extended(
              onPressed: controller.getListProductsSelested.isEmpty? null: () {controller.setTicketView = true;controller.setValueReceivedTicket = 0.0;},
              backgroundColor:controller.getListProductsSelested.isEmpty ? Colors.grey : null,
              label: Text( 'Cobrar ${controller.getListProductsSelested.isEmpty ? '' : Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}')),
        ),
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
                  child: const Icon(Icons.close, color: Colors.white)),
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

  const Dash(
      {super.key, this.height = 1, this.width = 3, this.color = Colors.black});

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
