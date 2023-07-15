import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:sell/app/core/utils/fuctions.dart';
import 'package:sell/app/core/utils/widgets_utils.dart';
import 'package:sell/app/domain/entities/ticket_model.dart'; 
import 'package:shimmer/shimmer.dart';
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
      initState: (_) {
        // init : inicializamos el controlador
        Get.put(SalesController());
      },
      builder: (controller) {
        return Obx(() {
            return Scaffold(
              // view : barra de navegacion supeior de la app
              appBar: appbar(controller: controller),
              // view : barra de navegacion de la app
              drawer: drawerApp(),
              // view : cuerpo de la app
              body: LayoutBuilder(builder: (context, constraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(child: body(controller: controller)),
                    drawerTicket(controller: controller),
                  ],
                );
              }),
              // view : barra de navegacion inferior de la app
              floatingActionButton: controller.getTicketView
                  ? floatingActionButtonTicket(controller: controller)
                  : floatingActionButton(controller: controller).animate( delay: Duration( milliseconds: homeController.salesUserGuideVisibility ? 500: 0)).fade(),
            );
          }
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required SalesController controller}) {
    return AppBar(
      title: Text(controller.titleText, textAlign: TextAlign.center),
      centerTitle: false,
      actions: [
        controller.getListProductsSelestedLength != 0
            ? TextButton.icon(
                icon: const Icon(Icons.clear_rounded),
                label: const Text('Descartar Ticket'),
                onPressed: controller.dialogCleanTicketAlert)
            : Container(
                key: homeController.floatingActionButtonSelectedCajaKey,
                child: cashRegisterNumberPopupMenuButton()),
      ],
    );
  }

  Widget body({required SalesController controller}) {
    // Widgets
    Widget updateview = homeController.getUpdateApp
        ? InkWell(
          onTap: () async => await launchUrl(Uri.parse(homeController.getUrlPlayStore),mode: LaunchMode.externalApplication),
          child: AnimatedContainer(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            color: Colors.green,
            child: const Center(child: Text('ACTUALIZAR',style: TextStyle(color: Colors.white, fontSize: 18))),
          ),
        )
      : Container();
    return NestedScrollView(
      /* le permite crear una lista de elementos que se desplazarían hasta que el cuerpo alcanzara la parte superior */
      floatHeaderSlivers: true,
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // atentos a cualquier cambio que surja en los datos de la lista de marcas
          SliverList(
              delegate: SliverChildListDelegate([
                updateview,
                widgeSuggestedProducts(context: context, controller1: controller)
              ])
          ),
        ];
      },
      //  LayoutBuilder : control de vista
      body: LayoutBuilder(builder: (context, constraints) {
        // var : logica de la vista para la web
        int crossAxisCount = constraints.maxWidth<700?3:constraints.maxWidth<900?4:5;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0),
                itemCount: controller.getListProductsSelested.length + 15,
                itemBuilder: (context, index) {
                  // mostramos un número de elementos vacíos de los cuales el primero tendrá un icono 'add'
                  List list =
                      controller.getListProductsSelested.reversed.toList();
                  if (index < list.length) {
                    if (index == 0) {
                      return ZoomIn(
                          controller: (p0) => controller
                              .newProductSelectedAnimationController = p0,
                          child: ProductoItem(producto: list[index]));
                    }
                    return ProductoItem(producto: list[index]);
                  } else {
                    return ElasticIn(
                        child: Card(
                            elevation: 0, color: Colors.grey.withOpacity(0.1)));
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget drawerTicket({required SalesController controller}) {
    // values
    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 2);
    final TicketModel ticket = controller.getTicket;
    ticket.priceTotal = 500.0;

    // style
    final TextStyle textValuesStyle = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold,color: Get.theme.brightness == Brightness.dark? Colors.white: Colors.black);
    final TextStyle textDescrpitionStyle = TextStyle(fontFamily: 'monospace',fontWeight: FontWeight.bold,color: Get.theme.brightness == Brightness.dark ? Colors.white38 : Colors.black45);

    // widgets
    Widget dividerLinesWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: CustomDivider(
        height: 0.2,
        dashWidth: 10.0,
        dashGap: 5.0,
        color: Get.theme.brightness == Brightness.dark?Colors.white:Colors.black,
      ),
    );

    // var : logica de la vista para la web
    final screenWidth = Get.size.width;
    final isMobile = screenWidth < 700; // ejemplo: pantalla de teléfono

    return AnimatedContainer(
      width: controller.getTicketView ? isMobile ? screenWidth : 400 : 0,
      curve: Curves.fastOutSlowIn, // Curva de animación
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: controller.getTicketView ? 1 : 0,
        duration: Duration(milliseconds: controller.getTicketView ? 1500 : 100),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            clipBehavior: Clip.antiAlias,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Get.theme.brightness == Brightness.dark?Colors.white10: const Color.fromARGB(255, 231, 238, 244),
            child: Drawer(
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Center(
                child: controller.getStateConfirmPurchase
                    ? widgetConfirmedPurchase()
                    : ListView(
                        key: const Key('ticket'),
                        shrinkWrap: false,
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Ticket',textAlign: TextAlign.center,style: textDescrpitionStyle.copyWith(fontSize: 30, fontWeight: FontWeight.bold))),
                          Material(
                              color: Colors.transparent, //Colors.blueGrey.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(homeController.getProfileAccountSelected.name,textAlign: TextAlign.center,style: textValuesStyle.copyWith(fontSize: 18,fontWeight: FontWeight.bold)),
                              )),
                          // view : lines ------
                          dividerLinesWidget,
                          const SizedBox(height: 20),
                          // text : cantidad de elementos 'productos' seleccionados
                          Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                Opacity(opacity: 0.7,child: Text('Productos:',style: textDescrpitionStyle)),
                                const Spacer(),
                                Text(controller.getListProductsSelestedLength.toString(),style: textValuesStyle),
                              ],
                            ),
                          ),
                          // text : medio de pago
                          Padding(
                            padding: padding,
                            child: Row(
                              children: [
                                Opacity(opacity: 0.7,child: Text('Medio:',style: textDescrpitionStyle)),
                                const Spacer(),
                                Text(controller.getTicket.getNamePayMode,style: textValuesStyle),
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
                                Opacity(opacity: 0.7,child: Text('Total',style: textDescrpitionStyle.copyWith(fontSize: 20,fontWeight: FontWeight.w900,color: Colors.blue))),
                                const Spacer(),
                                Text(Publications.getFormatoPrecio(monto: controller.getCountPriceTotal()),style: textValuesStyle.copyWith(color: Colors.blue,fontSize: 24,fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          // text : paga con
                          controller.getValueReceivedTicket == 0 || controller.getTicket.payMode != 'effective'
                              ? Container()
                              : Padding(
                                  padding: padding,
                                  child: Row(
                                    children: [
                                      Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            'Pago con:',
                                            style: textDescrpitionStyle,
                                          )),
                                      const Spacer(),
                                      Text(controller.getValueReceived(),style: textValuesStyle),
                                    ],
                                  ),
                                ),
                          // text : vuelto
                          controller.getValueReceivedTicket == 0 || controller.getTicket.payMode != 'effective'
                              ? Container()
                              : Padding(
                                  padding: padding,
                                  child: Row(
                                    children: [
                                      Opacity(opacity: 0.7,child: Text('Vuelto:',style: textDescrpitionStyle)),
                                      const Spacer(),
                                      Material(
                                        elevation: 0,
                                        color: Colors.green.shade300,
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          child: Row(
                                            children: [
                                              Text('Dar vuelto ', style: textValuesStyle.copyWith(color: Colors.white)),
                                              Text(
                                                controller.getValueChange(),
                                                style: textValuesStyle.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
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
                            padding: const EdgeInsets.only(bottom: 24, top: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('El cliente paga con:',style: textDescrpitionStyle),
                                const SizedBox(height: 12),
                                Row(
                                  key: homeController.buttonsPaymenyMode,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    //  button : pago con efectivo
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ElevatedButton.icon( 
                                        style: ButtonStyle(elevation: MaterialStateProperty.all(controller.getTicket.payMode =='effective'? 5: 0)),
                                        icon: controller.getTicket.payMode != 'effective'? Container(): const Icon(Icons.money_rounded),
                                        onPressed: () {
                                          controller.setPayModeTicket = 'effective'; 
                                          controller.dialogSelectedIncomeCash();
                                        },
                                        label: Text(controller.getValueReceivedTicket != 0.0 ? Publications.getFormatoPrecio(monto: controller.getValueReceivedTicket): 'Efectivo'),
                                      ),
                                    ),
                                    // button : pago con mercado pago
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(elevation:MaterialStateProperty.all(controller.getTicket.payMode =='mercadopago'? 5: 0)),
                                        icon: controller.getTicket.payMode != 'mercadopago'?Container(): const Icon(Icons.check_circle_rounded),
                                        onPressed: () {
                                          controller.setPayModeTicket = 'mercadopago';
                                          // default value
                                          controller.setValueReceivedTicket = 0.0;
                                        },
                                        label: const Text('Mercado Pago'),
                                      ),
                                    ),
                                  ],
                                ),
                                //  button : pago con tarjeta de credito/debito
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ElevatedButton.icon(
                                    style: ButtonStyle(elevation: MaterialStateProperty.all(controller.getTicket.payMode == 'card'?5:0)),
                                    icon: controller.getTicket.payMode != 'card'? Container(): const Icon(Icons.credit_card_outlined),
                                    onPressed: () {
                                      controller.setPayModeTicket = 'card';
                                      // default values
                                      controller.setValueReceivedTicket = 0.0;
                                    },
                                    label: const Text('Tarjeta de Debito/Credito'),
                                  ),
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
  Widget cashRegisterNumberPopupMenuButton() {
    // opcion premium : esta funcionalidad de arqueo de caja solo esta disponible en la version premium
    bool isPremium = homeController.getIsSubscribedPremium;
    // controllers
    final controller = Get.find<SalesController>(); 
    // condition : si no es premium se muestra el boton de suscribirse a premium 
    if(homeController.getIsSubscribedPremium==false){ 
      // condition : si el usuario de la cuenta no es administrador no se muestra el boton de suscribirse a premium
      if(homeController.getProfileAdminUser.admin == false){
        return Container();
      }
      // button : suscribirse a premium
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: isPremium?homeController.getDarkMode ? Colors.white : Colors.black:Colors.amber[600],
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: InkWell(
            onTap: () => homeController.showModalBottomSheetSubcription(id: 'arching'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Row(
                children: [ 
                  Text('Iniciar caja', style: TextStyle( color: isPremium?homeController.getDarkMode ? Colors.black : Colors.white:Colors.white)),
                  const SizedBox(width: 5),
                  Icon(Icons.keyboard_arrow_down_rounded, color: isPremium?homeController.getDarkMode ? Colors.black : Colors.white:Colors.white),
                ],
              ),
            ),
          ),
        ),
      );
    }
    // condition : si no hay caja abierta
    if (homeController.cashRegisterActive.id == '') {
      // no hay caja abierta
      // view : button : iniciar caja
      return PopupMenuButton(
          icon: Material(
            color: isPremium?homeController.getDarkMode ? Colors.white : Colors.black:Colors.amber[600],
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Row(
                children: [ 
                  Text('Iniciar caja', style: TextStyle( color: isPremium?homeController.getDarkMode ? Colors.black : Colors.white:Colors.white)),
                  const SizedBox(width: 5),
                  Icon(Icons.keyboard_arrow_down_rounded, color: isPremium?homeController.getDarkMode ? Colors.black : Colors.white:Colors.white),
                ],
              ),
            ),
          ), 
          onSelected: (selectedValue) { 
            // opcion premium : esta funcionalidad de arqueo de caja solo esta disponible en la version premium
            if(homeController.getIsSubscribedPremium==true){ 
              // es premium
              if (selectedValue == 'apertura') {
                // Get : abrir dialogo de apertura de caja 
                Get.dialog(CashRegister(id: 'apertura'));
              } else {
                // Get : abrir dialogo de apertura de caja
                controller.upgradeCashRegister(id: selectedValue);
              }
            }else{
              // no es premium 
              //...
            }
          },
          itemBuilder: (BuildContext ctx) {
            
            // var : list of items
            List<PopupMenuItem> items = [];
            items.add(const PopupMenuItem(
                value: 'apertura',
                child: Row(children: [
                  Icon(Icons.add),
                  Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Text('Nueva arqueo de caja')),
                ])));
            // agregar las cajas existentes
            for (var element in homeController.listCashRegister) {
              items.add(PopupMenuItem(
                  value: element.id,
                  child: Row(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Text(element.description)),
                  ])));
            }
            // generate vista de cada item de homeController.cashRegisterList
            return List.generate(homeController.listCashRegister.length + 1,
                (index) {
              return items[index];
            });
          });
    }

    return PopupMenuButton( 
        icon: Material(
          color: homeController.getDarkMode ? Colors.white : Colors.black,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            child: Row(
              children: [
                Text('Caja ${homeController.cashRegisterActive.description}',
                    style: TextStyle(color: homeController.getDarkMode? Colors.black: Colors.white)),
                const SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: homeController.getDarkMode
                        ? Colors.black
                        : Colors.white),
              ],
            ),
          ),
        ),
        onSelected: (selectedValue) {
          late String id;
          switch (selectedValue) {
            case 0:
              id = 'detalles';
              break;
            case 1:
              id = 'ingreso';
              break;
            case 2:
              id = 'egreso';
              break;
            case 3:
              id = 'cierre';
              break;
            default:
              id = 'apertura';
              break;
          }
          // Get : view dialog
          Get.dialog(CashRegister(id: id), useSafeArea: true);
        },
        itemBuilder: (BuildContext ctx) => [
              PopupMenuItem(
                  value: 0,
                  child: RichText(
                    text: TextSpan(
                      text: "Balance total\n",
                      style: TextStyle(
                          color: homeController.getDarkMode
                              ? Colors.white
                              : Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: Publications.getFormatoPrecio(
                              monto: homeController
                                  .cashRegisterActive.getExpectedBalance),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ],
                    ),
                  )),
              PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      // icon
                      Icon(Icons.south_west_rounded,
                          color: Colors.green.shade400),
                      // text
                      RichText(
                        text: TextSpan(
                          text: 'Ingreso',
                          style: TextStyle(
                              color: Colors.green.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          children: homeController.cashRegisterActive.cashInFlow == 0
                              ? null
                              : <TextSpan>[
                                  TextSpan(
                                    text:
                                        '\n${Publications.getFormatoPrecio(monto: homeController.cashRegisterActive.cashInFlow)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.green.shade400
                                            .withOpacity(0.5)),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  )),
              PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      // icon
                      Icon(Icons.arrow_outward_rounded,
                          color: Colors.red.shade400),
                      // text
                      RichText(
                        text: TextSpan(
                          text: 'Egreso',
                          style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          children: homeController.cashRegisterActive.cashOutFlow == 0
                              ? null
                              : <TextSpan>[
                                  TextSpan(
                                    text:
                                        '\n${Publications.getFormatoPrecio(monto: homeController.cashRegisterActive.cashOutFlow)}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Colors.red.shade400
                                            .withOpacity(0.5)),
                                  ),
                                ],
                        ),
                      ),
                    ],
                  )),
              const PopupMenuItem(
                  value: 3,
                  child: Row(children: [
                    Icon(Icons.close),
                    Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Text('Cerrar Caja')),
                  ])),
            ]);
  }

  Widget widgeSuggestedProducts({required SalesController controller1, required BuildContext context}) {
    // controllers
    HomeController controller = Get.find();

    // values
    int numItemDefault = 5;
    const double height = 120;
    final bool viewDefault = controller.getProductsOutstandingList.isEmpty;
    final int itemCount = viewDefault?6:controller.getProductsOutstandingList.length + numItemDefault;
    // views : load widget mientras se carga la data
    if(homeController.productsBestSellersLoadComplete.value == false ){
      return SizedBox(
        height: 130,
        width: double.infinity,
        child: Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Get.theme.scaffoldBackgroundColor,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 10),
                scrollDirection: Axis.horizontal,
                itemCount: 15,
                itemBuilder: (context, index) => circleAvatarSeachAndDefault(context: context),
              ),
            ),
      );
    }

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
              Widget widget = index <= (controller.getProductsOutstandingList.length - 1) && index < itemCount - numItemDefault
                ? circleAvatarProduct(productCatalogue:controller.getProductsOutstandingList[index])
                : circleAvatarProduct(productCatalogue: ProductCatalogue(creation: Timestamp.now(),upgrade: Timestamp.now(),documentCreation: Timestamp.now(),documentUpgrade: Timestamp.now()));
              // condition : views default
              if (viewDefault) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 5 : 0),
                  child: circleAvatarSeachAndDefault(context: context),
                );
              }
              // condition : vista de productos destacados
              if (index == 0) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 95.0, height: height),
                    Container(key: homeController.itemProductFlashKeyButton,child: widget)
                  ]);
              }

              return widget;
            },
          ),
        ),
        SizedBox(
          width: 110.0,
          height: height,
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
    double radius = 40.0;
    double spaceImageText = 1; 

    return seach
        ? ElasticIn(
            child: Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Container(
                width: 81.0,
                height: 120.0,
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    InkWell(
                      hoverColor: Colors.red,
                      splashColor: Colors.amber,
                      focusColor: Colors.pink,
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
                          SizedBox(height: spaceImageText),
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
                Container(margin: const EdgeInsets.only(top:5),width: radius, height: 10.0,color: Colors.grey.withOpacity(0.1),),
              ],
            ),
          );
  }

  Widget circleAvatarProduct({required ProductCatalogue productCatalogue}) {
    // controller
    final SalesController salesController = Get.find();

    // values
    bool defaultValues = productCatalogue.id == '';
    double radius = 40.0;
    double spaceImageText = 1;
    Color backgroundColor = Colors.grey.withOpacity(0.1);
    bool stateAlertStock = productCatalogue.stock && homeController.getProfileAccountSelected.subscribed ? productCatalogue.quantityStock < 5 : false;
    Color borderCicleColor = stateAlertStock ? Colors.red : productCatalogue.favorite ? Colors.amber : backgroundColor;

    return ElasticIn(
      child: Container(
        width: 81.0,
        height: 110.0,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (defaultValues == false) {
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
                        child: defaultValues ? Container(): Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyLarge?.color))),
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: radius,
                      backgroundColor: borderCicleColor,
                      child: CircleAvatar(
                        radius: radius - 6.5,
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        child: CircleAvatar(radius: radius - 8,backgroundColor: backgroundColor,child: defaultValues ? Container() : CircleAvatar(radius: radius, backgroundImage: image)),
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: radius,
                      backgroundColor: backgroundColor,
                      child: defaultValues? Container():Text(Publications.getFormatoPrecio(monto: productCatalogue.salePrice),style: TextStyle(color: Get.textTheme.bodyMedium?.color)),
                    ),
                  ),
                  SizedBox(height: spaceImageText),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(productCatalogue.description,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        softWrap: false),
                  ),
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

    // controllers
    final SalesController salesController = Get.find();
    // values
    const Color accentColor = Colors.white;
    Color? background = Colors.green.shade300;
    

    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: ElasticIn(
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: background,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_outlined, size: 100, color: accentColor),
                      const SizedBox(height: 25),
                      const Text('Hecho',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: accentColor)),
                      // text : monto del precio total del ticket
                      Text( Publications.getFormatoPrecio(monto: salesController.getRecibeTicket.priceTotal),style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: accentColor)),
                    ],
                  ),
                ),
              ),
              //view : buttons
              Column( 
                children: [
                  // elevateButton : boton con un icon y un texto  que diga 'Recibo'
                  /* ComponentApp().button( 
                    text: 'Recibo',
                    colorAccent: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical:5),
                    icon: Icon(salesController.homeController.getIsSubscribedPremium==false?Icons.star_rounded:Icons.receipt_long_outlined,color: Colors.black),
                    colorButton: Colors.white,  
                    onPressed: () {
                      if(salesController.homeController.getIsSubscribedPremium==false){
                        homeController.showModalBottomSheetSubcription();
                      }else{
                        //views 
                        salesController.setStateConfirmPurchase = false;
                        salesController.setTicketView = false; 
                      }
                    },
                  ),  */
                  // elevateButton : boton con un icon y un texto  que diga 'ok'
                  ComponentApp().button(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical:5),
                    icon: const Text('Ok',style:TextStyle(color: Colors.white)),
                    colorButton: Colors.blue,  
                    onPressed: () {
                      //views
                      salesController.setStateConfirmPurchase = false;
                      salesController.setTicketView = false;
                      // default values
                      salesController.setTicket = TicketModel(creation: Timestamp.now(), listPoduct: []);
                    },
                  ), 
                ],
              ),
            const SizedBox(height: 20), 
            ],
          ),
        ),
      ),
    );
  }

  Widget floatingActionButton({required SalesController controller}) {
    // var
    Widget imageBarCode = Image.asset(
      'assets/scanbarcode.png',
      color: Colors.white,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        // FloatingActionButton : efectuar una venta rapida
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
        // FloatingActionButton : determinar si es un dispositivo movil o web para mostrar este buton
        const SizedBox(width: kIsWeb?0:8), 
        kIsWeb? const SizedBox(width: kIsWeb?0:8):FloatingActionButton(
          key: homeController.floatingActionButtonScanCodeBarKey,
          backgroundColor: Colors.blue,
          onPressed: controller.scanBarcodeNormal,
          child: SizedBox(width: 30,height: 30,child: imageBarCode),
        ),
        const SizedBox(width: 8),
        // floationActionButton : cobrar
        ElasticIn(
          key: homeController.floatingActionButtonTransacctionRegister,
          controller: (p0) => controller.floatingActionButtonAnimateController = p0,
          child: FloatingActionButton.extended(
              onPressed: controller.getListProductsSelested.isEmpty
                  ? null
                  : () {
                      controller.setTicketView = true;
                      controller.setValueReceivedTicket = 0.0;
                    },
              backgroundColor: controller.getListProductsSelested.isEmpty
                  ? Colors.grey
                  : null,
              label: Text(
                  'Cobrar ${controller.getListProductsSelested.isEmpty ? '' : Publications.getFormatoPrecio(monto: controller.getCountPriceTotal())}',
                  style: const TextStyle(color: Colors.white))),
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
                  label: const Text(
                    'Confirmar venta',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          );
  }
}

class CustomDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashGap;
  final Color color;

  const CustomDivider({
    super.key,
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

// ignore: must_be_immutable
class CashRegister extends StatefulWidget {
  late String id;
  CashRegister({super.key, required this.id});

  @override
  State<CashRegister> createState() => _CashRegisterState();
}

class _CashRegisterState extends State<CashRegister> {
  // controllers views
  final HomeController homeController = Get.find<HomeController>();
  final SalesController salesController = Get.find<SalesController>();
  // others controllers
  final MoneyMaskedTextController moneyMaskedTextController =
      MoneyMaskedTextController(
          leftSymbol: '\$',
          decimalSeparator: ',',
          thousandSeparator: '.',
          precision: 2);
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode _amountCashRegisterFocusNode = FocusNode();
  // var
  String titleAppBar = '';
  bool confirmCloseState = false;
  late Widget view;

  // void
  void loadData() {
    switch (widget.id) {
      case 'apertura':
        titleAppBar = 'Apertura de caja';
        view = body;
        break;
      case 'detalles':
        titleAppBar = 'Arqueo de caja';
        view = detailContent;
        break;
      case 'cierre':
        confirmCloseState = true;
        titleAppBar = 'Cierre de caja';
        view = detailContent;
        break;
      case 'ingreso':
        titleAppBar = 'Ingreso';
        view = bodyEgresoIngreso();
        break;
      case 'egreso':
        titleAppBar = 'Egreso';
        view = bodyEgresoIngreso(isEgreso: true);
        break;
      default:
        titleAppBar = 'Apertura de caja';
        view = body;
        break;
    }
  }

  // init
  @override
  void initState() {
    super.initState();
    //  set : values
    homeController.cashRegisterActive.balance =
        0; // reseteamos el balance  para evitar que se acumule
  }

  @override
  void dispose() {
    _amountCashRegisterFocusNode.dispose();
    textEditingController.dispose();
    moneyMaskedTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loadData();

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Material(
            color: Colors.transparent,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Scaffold(
                appBar: appbar(text: widget.id),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: view,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // WIDGETS VIEWS
  PreferredSizeWidget appbar({required String text}) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(titleAppBar[0].toUpperCase() + titleAppBar.substring(1)),
      centerTitle: true,
      actions: [
        IconButton(onPressed: Get.back, icon: const Icon(Icons.close)),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget bodyEgresoIngreso({
    bool isEgreso = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // textfield : efectivo inicial de la caja
        const Text('Escriba el monto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        const SizedBox(height: 8),
        TextField(
          controller: moneyMaskedTextController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(),
            labelText: 'Monto',
          ),
        ),
        // textfield : descripcion (opcional)
        const SizedBox(height: 20),
        TextField(
          controller: textEditingController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(),
            labelText: 'Descripción (opcional)',
          ),
        ),
        const Spacer(),
        // button : iniciar caja
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (moneyMaskedTextController.numberValue > 0) {
                  if (isEgreso) {
                    salesController.cashRegisterOutFlow(
                        amount: -moneyMaskedTextController.numberValue,
                        description: textEditingController.text);
                  } else {
                    salesController.cashRegisterInFlow(
                        amount: moneyMaskedTextController.numberValue,
                        description: textEditingController.text);
                  }

                  Get.back();
                }
                Get.back();
              },
              style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2)))),
              child: const Text('Confirmar'),
            ),
          ),
        ),
        // textButton : cancelar
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancelar'),
            ),
          ),
        ),
      ],
    );
  }

  Widget get detailContent {
    // var
    ButtonStyle buttonStyle = ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(confirmCloseState ? Colors.blue : null),
        padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(2))));
    TextStyle textStylebutton =
        TextStyle(color: confirmCloseState ? Colors.white : Colors.blue);
    TextStyle textStyleDescription =
        const TextStyle(fontWeight: FontWeight.w300);
    TextStyle textStyleValue =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // view info : descripcion
              Row(children: [
                Text('Descripción', style: textStyleDescription),
                const Spacer(),
                Text(homeController.cashRegisterActive.description,
                    style: textStyleValue)
              ]),

              // view info : fecha
              const SizedBox(height: 12),
              Row(children: [
                Text('Apertura', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFechaPublicacionFormating(
                        dateTime: homeController.cashRegisterActive.opening),
                    style: textStyleValue)
              ]),
              // view info : efectivo incial
              const SizedBox(height: 12),
              Row(children: [
                Text('Efectivo inicial', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFormatoPrecio(
                        monto: homeController.cashRegisterActive.expectedBalance),
                    style: textStyleValue)
              ]),
              // view info : cantidad de ventas
              const SizedBox(height: 12),
              Row(children: [
                Text('Ventas', style: textStyleDescription),
                const Spacer(),
                Text(homeController.cashRegisterActive.sales.toString(),
                    style: textStyleValue)
              ]),
              // view info : facturacion
              const SizedBox(height: 12),
              Row(children: [
                Text('Facturación', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFormatoPrecio(
                        monto: homeController.cashRegisterActive.billing),
                    style: textStyleValue)
              ]),
              // view info : egresos
              const SizedBox(height: 12),
              Row(children: [
                Text('Egresos', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFormatoPrecio(
                        monto: homeController.cashRegisterActive.cashOutFlow),
                    style: textStyleValue.copyWith(color: Colors.red.shade300))
              ]),
              // view info : ingresos
              const SizedBox(height: 12),
              Row(children: [
                Text('Ingresos', style: textStyleDescription),
                const Spacer(),
                Text(
                    Publications.getFormatoPrecio(
                        monto: homeController.cashRegisterActive.cashInFlow),
                    style: textStyleValue)
              ]),
              // divider
              const SizedBox(height: 20),
              ComponentApp().divider(thickness: 1),
              // view info : monto esperado en la caja
              const SizedBox(height: 12),
              Row(children: [
                Text('Balance esperado en la caja',
                    style: textStyleDescription),
                const Spacer(),
                Text(Publications.getFormatoPrecio(monto: homeController.cashRegisterActive.getExpectedBalance),style: textStyleValue)
              ]),
              const SizedBox(height: 20),
              // textfield : Monto en caja
              confirmCloseState
                  ? TextField(
                      focusNode: _amountCashRegisterFocusNode,
                      controller: moneyMaskedTextController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(),
                        labelText: 'Balance real en caja (opcional)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          // get diference
                          homeController.cashRegisterActive.balance =
                              moneyMaskedTextController.numberValue;
                        });
                      },
                    )
                  : Container(),
              // text : diferencia
              confirmCloseState ? const SizedBox(height: 20) : Container(),
              homeController.cashRegisterActive.getDifference == 0
                  ? Container()
                  : confirmCloseState
                      ? Row(children: [
                          Text('Diferencia', style: textStyleDescription),
                          const Spacer(),
                          // text : monto de la diferencia
                          Text(Publications.getFormatoPrecio(monto: homeController.cashRegisterActive.getDifference),style: textStyleValue.copyWith(color: homeController.cashRegisterActive.getDifference<0?Colors.red.shade300: Colors.green.shade300))
                        ])
                      : Container(),
            ],
          ),
        ),
        // button : iniciar caja
        Container(
          padding: const EdgeInsets.only(bottom: 20, top: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // comprobamos si el usuario ya confirmo el cierre de caja
                if (confirmCloseState) {
                  // comprobamos si el usuario ingreso un monto en caja
                  if (moneyMaskedTextController.numberValue != 0) {
                    homeController.cashRegisterActive.balance =
                        moneyMaskedTextController.numberValue;
                  }
                  // cerramos la caja
                  salesController.closeCashRegisterDefault();
                  Get.back();
                } else {
                  setState(() {
                    confirmCloseState = !confirmCloseState;
                    _amountCashRegisterFocusNode.requestFocus();
                  });
                }
              },
              style: buttonStyle,
              child: Text(
                  confirmCloseState
                      ? 'Confirmar cierre de caja'
                      : 'Cerrar caja',
                  style: textStylebutton),
            ),
          ),
        ),
        // textButton : cancelar
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancelar'),
            ),
          ),
        ),
      ],
    );
  }

  Widget get body {
    // description : vista para la apertura de la caja
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 12),
              // textfield : efectivo inicial de la caja
              const Text('Efectivo inicial',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              const SizedBox(height: 5),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
                controller: moneyMaskedTextController,
                style: const TextStyle(fontSize: 24),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  labelText: 'Monto',
                ),
              ),
              // textfield : descripcion (opcional)
              const SizedBox(height: 12),
              const Text('Descripción de la caja',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
              const SizedBox(height: 5),
              // textfield con autocompletado: descripcion (opcional)
              FutureBuilder<List<String>>(
                  future: salesController.loadFixerDescriotions(),
                  initialData: const [],
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // textfield autocomplete
                      return Autocomplete<String>(
                        optionsViewBuilder: (context, onSelected, options) {
                          // recrea la vista original de las opciones
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: ()=> onSelected(option),
                                    child: ListTile(
                                      visualDensity: VisualDensity.compact,
                                      title: Text(option),
                                      // icon : delete
                                      trailing: Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () {
                                            setState(() {
                                              // eliminar de 'snapshot' la descripcion
                                              snapshot.data!.remove(option);
                                              // eliminamos la descripcion de la base de datos
                                              salesController.deleteFixedDescription(description: option);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return snapshot.data!.where((String option) {
                            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        fieldViewBuilder: (context,
                            textEditingAutoCompleteController,
                            focusNode,
                            onFieldSubmitted) {
                          return TextField(
                            controller: textEditingAutoCompleteController,
                            focusNode: focusNode,
                            keyboardType: TextInputType.text,
                            maxLength: 9, // Límite de caracteres
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              labelText: 'Descripción',
                            ),
                            onChanged: (value) {
                              textEditingController.text = value;
                            },
                          );
                        },
                        onSelected: (String selection) {
                          textEditingController.text = selection;
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ],
          ),
        ),
        // button : iniciar caja
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // recordamos la descripcion ingresada por el usuario
                salesController.registerFixerDescription(
                    description: textEditingController.text);
                // iniciamos la caja
                salesController.startCashRegister(
                    description: textEditingController.text,
                    initialCash: moneyMaskedTextController.numberValue,
                    expectedBalance: moneyMaskedTextController.numberValue);
                Get.back();
              },
              style: ButtonStyle(padding: MaterialStateProperty.all(const EdgeInsets.all(20)),shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)))),
              child: const Text('Iniciar caja'),
            ),
          ),
        ),
      ],
    );
  }
}
