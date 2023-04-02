import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:url_launcher/url_launcher.dart';
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
      // initState : se activa cuando se crea el widget
      initState: (_) {  },
      builder: (controller) {

        return Obx(() => Scaffold(
              appBar: appbar(controller: controller),
              drawer: drawerApp(),
              body: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  controller.getTicketView? Container(): Expanded(child: body(controller: controller )),
                  drawerTicket(controller: controller),
                ],
              ),
              floatingActionButton: controller.getTicketView ? floatingActionButtonTicket(controller: controller): floatingActionButton(controller: controller).animate(delay: Duration(milliseconds: homeController.salesUserGuideVisibility?500:0)).fade(),
            ));
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required SalesController controller}) {
    return AppBar(
      title: Text(controller.valueResponseChatGpt),
      actions: [
        controller.getListProductsSelestedLength != 0
            ? TextButton.icon(icon: const Icon(Icons.clear_rounded),label: const Text('Descartar Ticket'),onPressed: controller.dialogCleanTicketAlert)
            : Container(
              key: homeController.floatingActionButtonSelectedCajaKey,
              child: cashRegisterNumberPopupMenuButton()),
      ],
    );
  }

  Widget body(  {required SalesController controller} ) {

    // Widgets
    Widget updateview = homeController.getUpdateApp?
      InkWell(
        onTap: () async => await launchUrl(Uri.parse( homeController.getUrlPlayStore),mode: LaunchMode.externalApplication),
        child: AnimatedContainer(
          margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        duration: const Duration(milliseconds: 300),
        width: double.infinity ,
        color: Colors.green,
        child: const Center(child: Text('ACTUALIZAR',style: TextStyle(color: Colors.white,fontSize: 18),)),
      ),
    ):Container();
    return NestedScrollView(
      /* le permite crear una lista de elementos que se desplazarían hasta que el cuerpo alcanzara la parte superior */
      floatHeaderSlivers: true,
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // atentos a cualquier cambio que surja en los datos de la lista de marcas
          SliverList(delegate: SliverChildListDelegate([updateview, widgeSuggestedProducts(context: context,controller1: controller)]))
        ];
      },
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [ 
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

    // style 
    final TextStyle textValuesStyle = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold,color: Get.theme.brightness == Brightness.dark? Colors.white: Colors.black);
    final TextStyle textDescrpitionStyle = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold,color: Get.theme.brightness == Brightness.dark? Colors.white70: Colors.black87);

    // widgets
    Widget dividerLinesWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
      child: CustomDivider(
              height: 0.3,
              dashWidth: 10.0,
              dashGap: 5.0,
              color: Get.theme.brightness == Brightness.dark? Colors.white: Colors.black,
            ),
    );
    
    
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Ticket',textAlign: TextAlign.center,style: textDescrpitionStyle.copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
                          ), 
                          Material(
                            color: Colors.transparent,//Colors.blueGrey.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(homeController.getProfileAccountSelected.name,textAlign: TextAlign.center,style: textValuesStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                            )),
                            // view : lines ------
                            dividerLinesWidget,  
                            const SizedBox(height: 20),
                          // text : cantidad de elementos 'productos' seleccionados
                          Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                Opacity(opacity: 0.7,child: Text('Productos:',style:textDescrpitionStyle)),
                                const Spacer(),
                                Text(controller.getListProductsSelestedLength.toString(),style:textValuesStyle),
                              ],
                            ),
                          ),
                          // text : medio de pago
                          Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                Opacity(opacity: 0.7,child: Text('Medio:',style:textDescrpitionStyle)),
                                const Spacer(),
                                Text(controller.getTicket.getPayMode,style:textValuesStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // view : lines ------
                          dividerLinesWidget,
                          // text : el monto total de la transacción
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Opacity(opacity: 0.7,child: Text('Total',style: textDescrpitionStyle.copyWith(fontSize: 20,fontWeight: FontWeight.w900,color: Colors.blue,))),
                                const Spacer(),
                                Text(Publications.getFormatoPrecio(monto: controller.getCountPriceTotal()),style: textValuesStyle.copyWith(color: Colors.blue,fontSize: 24,fontWeight: FontWeight.w900)),
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
                                  Opacity(opacity: 0.7,child: Text('Pago con:',style: textDescrpitionStyle,)),
                                  const Spacer(),
                                  Text(controller.getValueReceived(),style:textValuesStyle),
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
                                  Opacity(opacity: 0.7,child:  Text('Vuelto:',style:textDescrpitionStyle)),
                                  const Spacer(),
                                  Material(
                                    elevation: 0,
                                    color: Colors.green.shade300,
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                      child: Row(
                                        children: [
                                          Text('Dar vuelto ',style:textValuesStyle.copyWith(color: Colors.white)),
                                          Text(controller.getValueChange(),style: textValuesStyle.copyWith(color: Colors.white,fontSize: 16),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ),
                          // view : lines ------
                          dividerLinesWidget,
                          // view 2
                          Padding(
                            padding:const EdgeInsets.only(bottom: 24, top: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [ 
                                Text('El cliente paga con:',style:textDescrpitionStyle),
                                const SizedBox(height: 12),
                                Container(
                                  key: homeController.buttonsPaymenyMode,
                                  child: Row( 
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
                  color: homeController.getDarkMode?Colors.white:Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical:1),
                    child: Row(
                      children: [
                        Text('Caja ${salesController.cashRegisterNumber}',style:TextStyle(color: homeController.getDarkMode?Colors.black:Colors.white)),
                        const SizedBox(width: 5),
                        Icon(Icons.keyboard_arrow_down_rounded,color: homeController.getDarkMode?Colors.black:Colors.white),
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
    int numItemDefault = 5;
    const double height = 120;
    final bool viewDefault = controller.getProductsOutstandingList.isEmpty;
    final int itemCount = viewDefault?6:controller.getProductsOutstandingList.length+numItemDefault;


    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
                itemBuilder: (context, index) {

                  // values 
                  Widget widget = index <= (controller.getProductsOutstandingList.length-1) && index < itemCount-numItemDefault? circleAvatarProduct(productCatalogue:controller.getProductsOutstandingList[index]):circleAvatarProduct(productCatalogue: ProductCatalogue(creation: Timestamp.now(), upgrade: Timestamp.now(), documentCreation: Timestamp.now(), documentUpgrade: Timestamp.now()));
                  
                  // condition : views default
                  if( viewDefault){ return Padding(
                    padding: EdgeInsets.only(left: index==0?5:0),
                    child: circleAvatarSeachAndDefault(context: context),
                  ); }
                  // condition : vista de productos destacados
                  if(index == 0){ return Row(crossAxisAlignment: CrossAxisAlignment.start,children: [const SizedBox(width: 95.0,height: height),Container(key: homeController.itemProductFlashKeyButton,child: widget)]);}
                  
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
        circleAvatarSeachAndDefault(context: context, seach: true)
      ],
    );
  }

  Widget circleAvatarSeachAndDefault({bool seach = false, required BuildContext context}) {
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
                    InkWell(
                      hoverColor: Colors.red,
                      splashColor: Colors.amber,focusColor: Colors.pink, 
                      onTap: () => salesController.showSeach(context: context),
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            radius: radius,
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            child: Icon(Icons.search,color: Get.theme.brightness == Brightness.dark? Colors.white: Colors.black54),
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
        : ElasticIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
        );
  }

  Widget circleAvatarProduct({required ProductCatalogue productCatalogue}) {
    // controller
    final SalesController salesController = Get.find();

    // values
    bool defaultValues = productCatalogue.id == '';
    double radius = 35.0;
    double spaceImageText = 10; 
    Color backgroundColor = Colors.grey.withOpacity(0.1);
    bool stateAlertStock = productCatalogue.stock && homeController.getProfileAccountSelected.subscribed ? productCatalogue.quantityStock < 5 : false;
    Color borderCicleColor = stateAlertStock? Colors.red: productCatalogue.favorite? Colors.amber:backgroundColor; 

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
                        backgroundColor: backgroundColor,
                        child: defaultValues?Container():Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyLarge?.color))),
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: radius,
                      backgroundColor: borderCicleColor,
                      child: CircleAvatar(
                        radius: radius - 1.5,
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        child: CircleAvatar(
                            radius: radius - 5,
                            backgroundColor: backgroundColor,
                            child:defaultValues?Container(): CircleAvatar(radius: radius, backgroundImage: image)),
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: radius,
                      backgroundColor: backgroundColor,
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
              children: [
                const Icon(Icons.check_rounded,size: 200,color:accentColor),
                const SizedBox(height:25),
                const Text('Hecho',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: accentColor)),
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
          key: homeController.floatingActionButtonRegisterFlashKeyButton,
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
          key: homeController.floatingActionButtonScanCodeBarKey,
            backgroundColor: Colors.blue,
            onPressed: controller.scanBarcodeNormal,
            child: SizedBox(
              width: 30,height: 30,
              child: imageBarCode,
            )),
        const SizedBox(width: 8),
        ElasticIn(
          key: homeController.floatingActionButtonTransacctionRegister,
          controller: (p0) => controller.floatingActionButtonAnimateController=p0,
          child: FloatingActionButton.extended( 
              onPressed: controller.getListProductsSelested.isEmpty? null: () { controller.setTicketView = true;controller.setValueReceivedTicket = 0.0; },
              backgroundColor:controller.getListProductsSelested.isEmpty ? Colors.grey : null,
              label: Text( 'Cobrar ${controller.getListProductsSelested.isEmpty ? '' : Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}',style:const  TextStyle(color: Colors.white))),
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
                key: homeController.floatingActionButtonTransacctionConfirm,
                  onPressed: controller.confirmedPurchase,
                  label: const Text('Confirmar venta',style: TextStyle(color: Colors.white),)),
            ],
          );
  }
} 
class CustomDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashGap;
  final Color color;

  const CustomDivider({super.key, 
    this.height = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashHeight = height;
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
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
